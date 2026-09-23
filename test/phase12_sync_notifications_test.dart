import 'dart:math';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/connectivity/connectivity_service.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/preferences/app_preferences_repository.dart';
import 'package:modular_erp/core/sync/app_sync_status_cubit.dart';
import 'package:modular_erp/core/sync/outbox_repository.dart';
import 'package:modular_erp/core/sync/pending_mutation.dart';
import 'package:modular_erp/core/sync/sync_retry_policy.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/notifications/application/attendance_reminder_service.dart';
import 'package:modular_erp/platform/notifications/application/reminder_context.dart';
import 'package:modular_erp/platform/notifications/data/local_notification_repository.dart';
import 'package:modular_erp/platform/notifications/domain/app_notification.dart';
import 'package:modular_erp/platform/notifications/domain/device_notification_service.dart';
import 'package:modular_erp/platform/notifications/presentation/notification_presentation.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'support/memory_preferences.dart';
import 'attendance_test.dart' show FakeClock, MockAuth;
import 'employee_test.dart' show employeeContext;

class MockConnectivity extends Mock implements ConnectivityService {}

class _FakeDevice implements DeviceNotificationService {
  DeviceNotificationPermission permission =
      DeviceNotificationPermission.granted;
  final List<DeviceNotificationRequest> scheduled = [];
  final List<String> cancelled = [];
  @override
  Future<DeviceNotificationPermission> permissionStatus() async => permission;
  @override
  Future<DeviceNotificationPermission> requestPermission() async => permission;
  @override
  Future<void> schedule(DeviceNotificationRequest request) async =>
      scheduled.add(request);
  @override
  Future<void> cancel(String id) async => cancelled.add(id);
  @override
  Future<void> cancelAll() async {}
  @override
  Future<void> openSettings() async {}
}

class _FakeContext implements ReminderContextSource {
  _FakeContext(this.value);
  ReminderContext? value;
  @override
  Future<Result<ReminderContext?>> load() async => Success(value);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime.utc(2026, 9, 17, 12);

  test('retry policy grows exponentially, caps and jitters', () {
    const policy = SyncRetryPolicy(
      baseDelay: Duration(seconds: 5),
      maxDelay: Duration(minutes: 30),
      maxExponent: 12,
    );
    expect(policy.delayFor(1), const Duration(seconds: 5));
    expect(policy.delayFor(2), const Duration(seconds: 10));
    expect(policy.delayFor(3), const Duration(seconds: 20));
    expect(policy.delayFor(20), const Duration(minutes: 30));
    final random = Random(7);
    for (var attempt = 1; attempt <= 8; attempt++) {
      final at = policy.nextAttemptAt(now, attempt, random: random);
      final delay = at.difference(now);
      expect(delay, greaterThan(Duration.zero));
      expect(
        delay.inMilliseconds,
        lessThanOrEqualTo(policy.maxDelay.inMilliseconds * 1.25),
      );
    }
  });

  test('outbox eligibility, stale recovery, counts and purge', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final outbox = OutboxLocalDataSource(db);
    Future<void> insert(
      String id,
      OutboxOperationStatus status, {
      DateTime? nextAttemptAt,
    }) => outbox.insert(
      PendingMutation(
        id: id,
        moduleId: 'attendance',
        entityId: 'event-$id',
        operation: 'attendancePunchIn',
        payload: const {},
        createdAt: now,
        companyId: 'c1',
        requestId: id,
        status: status,
        attemptCount: 1,
        nextAttemptAt: nextAttemptAt,
      ),
    );

    await insert('a', OutboxOperationStatus.pending);
    await insert(
      'b',
      OutboxOperationStatus.retryScheduled,
      nextAttemptAt: now.add(const Duration(minutes: 10)),
    );
    await insert(
      'c',
      OutboxOperationStatus.retryScheduled,
      nextAttemptAt: now.subtract(const Duration(minutes: 1)),
    );
    await insert('d', OutboxOperationStatus.failed);
    final eligible = await outbox.eligible(companyId: 'c1', now: now);
    expect(eligible.map((e) => e.id), ['a', 'c']);

    final counts = await outbox.counts(companyId: 'c1');
    expect(counts.waiting, 3);
    expect(counts.needsAttention, 1);

    // A crash while processing leaves a stale `processing` row that recovers.
    await (db.update(db.syncOutbox)..where((t) => t.id.equals('a'))).write(
      SyncOutboxCompanion(
        status: const Value('processing'),
        processingStartedAt: Value(now.subtract(const Duration(minutes: 30))),
      ),
    );
    final recovered = await outbox.recoverStaleProcessing(now: now);
    expect(recovered, 1);
    final rowA = await (db.select(
      db.syncOutbox,
    )..where((t) => t.id.equals('a'))).getSingle();
    expect(rowA.status, 'pending');
    expect(rowA.requestId, 'a');
  });

  test(
    'notification repository isolates scope, dedupes and marks read',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repository = LocalNotificationRepository(db);
      AppNotification note(String id, {String user = 'u1', String? dedupe}) =>
          AppNotification(
            id: id,
            companyId: 'c1',
            userId: user,
            type: AppNotificationType.correctionApproved,
            dedupeKey: dedupe,
            createdAt: now,
          );
      await repository.createLocal(note('n1'));
      await repository.createLocal(note('n2', user: 'u2'));
      await repository.createLocal(note('n3', dedupe: 'same'));
      await repository.createLocal(note('n4', dedupe: 'same'));

      final first = await repository
          .watchNotifications(companyId: 'c1', userId: 'u1')
          .first;
      expect(first.map((n) => n.id).toSet(), {'n1', 'n3'});
      expect(
        await repository.watchUnreadCount(companyId: 'c1', userId: 'u1').first,
        2,
      );
      expect(
        await repository.watchUnreadCount(companyId: 'c1', userId: 'u2').first,
        1,
      );
      expect(
        await repository.markRead(
          companyId: 'c1',
          userId: 'u1',
          id: 'n1',
          at: now,
        ),
        isA<Success<void>>(),
      );
      expect(
        await repository.watchUnreadCount(companyId: 'c1', userId: 'u1').first,
        1,
      );
      await repository.markAllRead(companyId: 'c1', userId: 'u1', at: now);
      expect(
        await repository.watchUnreadCount(companyId: 'c1', userId: 'u1').first,
        0,
      );
      expect(
        await repository.purgeOlderThan(
          companyId: 'c1',
          userId: 'u1',
          cutoff: now.add(const Duration(days: 1)),
        ),
        isA<Success<int>>(),
      );
      expect(
        (await repository
                .watchNotifications(companyId: 'c1', userId: 'u1')
                .first)
            .length,
        0,
      );
    },
  );

  group('attendance reminders', () {
    late MemoryPreferences storage;
    late LocalAppPreferencesRepository preferences;
    late _FakeDevice device;
    late _FakeContext source;

    setUp(() {
      storage = MemoryPreferences();
      preferences = LocalAppPreferencesRepository(storage);
      device = _FakeDevice();
      source = _FakeContext(null);
    });

    AttendanceReminderService service() => AttendanceReminderService(
      preferences: preferences,
      source: source,
      device: device,
      clock: FakeClock(now),
    );

    ReminderContext context({
      required bool scheduled,
      required AttendanceWorkdayState state,
      DateTime? start,
      DateTime? end,
    }) => ReminderContext(
      employeeId: 'e1',
      scheduled: scheduled,
      workday: DateTime.utc(2026, 9, 17),
      scheduledStart: start ?? DateTime.utc(2026, 9, 17, 22),
      scheduledEnd: end ?? DateTime.utc(2026, 9, 18, 7),
      state: state,
    );

    test('schedules shift and punch out reminders when enabled', () async {
      await preferences.saveReminderPreferences(
        const ReminderPreferences(
          shiftReminderEnabled: true,
          shiftReminderMinutesBefore: 15,
          punchOutReminderEnabled: true,
        ),
      );
      source.value = context(
        scheduled: true,
        state: AttendanceWorkdayState.working,
      );
      await service().reconcile();
      expect(
        device.cancelled,
        containsAll([
          AttendanceReminderService.shiftReminderId,
          AttendanceReminderService.punchOutReminderId,
        ]),
      );
      final punchOut = device.scheduled.single;
      expect(punchOut.id, AttendanceReminderService.punchOutReminderId);
      expect(punchOut.route, AppRoutes.attendance);
    });

    test('schedules shift reminder for an overnight shift', () async {
      await preferences.saveReminderPreferences(
        const ReminderPreferences(shiftReminderEnabled: true),
      );
      source.value = context(
        scheduled: true,
        state: AttendanceWorkdayState.notStarted,
      );
      final clock = FakeClock(DateTime.utc(2026, 9, 17, 20));
      await AttendanceReminderService(
        preferences: preferences,
        source: source,
        device: device,
        clock: clock,
      ).reconcile();
      final shift = device.scheduled.single;
      expect(shift.id, AttendanceReminderService.shiftReminderId);
      expect(shift.scheduledAt, DateTime.utc(2026, 9, 17, 21, 45));
    });

    test('skips off days, completed days and disabled reminders', () async {
      await preferences.saveReminderPreferences(
        const ReminderPreferences(
          shiftReminderEnabled: true,
          punchOutReminderEnabled: true,
        ),
      );
      source.value = context(
        scheduled: false,
        state: AttendanceWorkdayState.completed,
      );
      await service().reconcile();
      expect(device.scheduled, isEmpty);

      source.value = context(
        scheduled: true,
        state: AttendanceWorkdayState.completed,
      );
      await service().reconcile();
      expect(device.scheduled, isEmpty);

      await preferences.saveReminderPreferences(const ReminderPreferences());
      source.value = context(
        scheduled: true,
        state: AttendanceWorkdayState.working,
      );
      await service().reconcile();
      expect(device.scheduled, isEmpty);
    });

    test('does not schedule without OS permission', () async {
      device.permission = DeviceNotificationPermission.denied;
      await preferences.saveReminderPreferences(
        const ReminderPreferences(shiftReminderEnabled: true),
      );
      source.value = context(
        scheduled: true,
        state: AttendanceWorkdayState.notStarted,
      );
      await service().reconcile();
      expect(device.scheduled, isEmpty);
    });
  });

  test('notification content and deep links are typed and guarded', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final notification = AppNotification(
      id: 'n',
      companyId: 'c1',
      userId: 'u1',
      type: AppNotificationType.correctionApproved,
      payload: const {'correctionId': 'corr-1'},
      createdAt: now,
    );
    expect(
      notificationContent(notification, en).title,
      en.notifCorrectionApprovedTitle,
    );
    expect(
      notificationRoute(notification),
      AppRoutes.attendanceCorrectionDetails('corr-1'),
    );
    expect(
      notificationRoute(
        AppNotification(
          id: 'n',
          companyId: 'c1',
          userId: 'u1',
          type: AppNotificationType.shiftStartingSoon,
          createdAt: now,
        ),
      ),
      AppRoutes.attendance,
    );
  });

  test('global sync status aggregates counts and offline state', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final outbox = OutboxLocalDataSource(db);
    final auth = MockAuth();
    final actor = employeeContext(AppRole.employee);
    when(() => auth.checkSession()).thenAnswer((_) async => Success(actor));
    when(() => auth.sessionChanges).thenAnswer((_) => const Stream.empty());
    final connectivity = MockConnectivity();
    when(() => connectivity.isConnected).thenAnswer((_) async => false);
    when(() => connectivity.changes).thenAnswer((_) => const Stream.empty());
    final cubit = AppSyncStatusCubit(
      outbox: outbox,
      connectivity: connectivity,
      preferences: LocalAppPreferencesRepository(MemoryPreferences()),
      auth: auth,
    );
    addTearDown(cubit.close);
    await cubit.start();
    expect(cubit.state.offline, true);
    await outbox.insert(
      PendingMutation(
        id: 'op1',
        moduleId: 'attendance',
        entityId: 'e1',
        operation: 'attendancePunchIn',
        payload: const {},
        createdAt: now,
        companyId: actor.company.id,
        requestId: 'op1',
      ),
    );
    await Future<void>.delayed(Duration.zero);
    await cubit.reportSuccess(now);
    expect(cubit.state.counts.waiting, greaterThanOrEqualTo(1));
    expect(cubit.state.lastSyncedAt, now);
  });
}
