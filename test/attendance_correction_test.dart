import 'package:drift/native.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/bootstrap/demo_attendance_seed.dart';
import 'package:modular_erp/bootstrap/demo_configuration_seed.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/features/attendance/data/attendance_local_data_source.dart';
import 'package:modular_erp/features/attendance/data/local_attendance_correction_repository.dart';
import 'package:modular_erp/features/attendance/domain/attendance_correction.dart';
import 'package:modular_erp/features/attendance/domain/attendance_models.dart';
import 'package:modular_erp/features/attendance/domain/attendance_history.dart';
import 'package:modular_erp/features/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/features/employees/data/employee_seed.dart';
import 'attendance_test.dart' show FakeClock, MockAuth;
import 'employee_test.dart' show employeeContext;

void main() {
  late AppDatabase db;
  late LocalAttendanceCorrectionRepository repo;
  late AttendanceLocalDataSource local;
  late FakeClock clock;
  late MockAuth auth;
  var actor = employeeContext(AppRole.employee);
  setUp(() async {
    actor = employeeContext(AppRole.employee);
    db = AppDatabase(NativeDatabase.memory());
    await seedEmployees(db);
    await seedAttendanceConfiguration(db);
    clock = FakeClock(DateTime.utc(2026, 9, 18, 12));
    await seedDemoAttendance(db, enabled: true, clock: clock);
    auth = MockAuth();
    when(() => auth.checkSession()).thenAnswer((_) async => Success(actor));
    repo = LocalAttendanceCorrectionRepository(db, auth, clock);
    local = AttendanceLocalDataSource(db);
  });
  tearDown(() async => db.close());

  Future<AttendanceCorrectionRequest> request() async {
    final day = (await local.forDate(
      'demo-company',
      'employee-employee',
      DateTime.utc(2026, 9, 17),
    ))!;
    final events = await local.events(
      'demo-company',
      'employee-employee',
      day.id,
    );
    final pin = events.firstWhere(
      (e) => e.eventType == AttendanceEventType.punchIn,
    );
    return AttendanceCorrectionRequest(
      id: 'r-1',
      companyId: 'demo-company',
      employeeId: 'employee-employee',
      attendanceDayId: day.id,
      requestType: AttendanceCorrectionType.changePunchIn,
      status: AttendanceCorrectionStatus.pending,
      reason: 'Incorrect punch time',
      originalSnapshot: '',
      changes: [
        AttendanceCorrectionChange(
          eventType: AttendanceEventType.punchIn,
          originalEventId: pin.id,
          originalTimestamp: pin.effectiveTimestamp,
          requestedTimestamp: pin.effectiveTimestamp.subtract(
            const Duration(minutes: 2),
          ),
          changeType: AttendanceCorrectionChangeType.replace,
        ),
      ],
      requestedByUserId: actor.user.id,
      requestedAt: clock.now(),
      createdAt: clock.now(),
      updatedAt: clock.now(),
    );
  }

  test(
    'approval updates effective caches, preserves originals and audit',
    () async {
      final draft = await request();
      final before = (await local.byId(
        'demo-company',
        'employee-employee',
        draft.attendanceDayId,
      ))!;
      final originals = await local.events(
        'demo-company',
        'employee-employee',
        draft.attendanceDayId,
      );
      final created = await repo.createRequest(draft);
      expect(created, isA<Success<AttendanceCorrectionRequest>>());
      actor = employeeContext(AppRole.manager);
      final reviewed = await repo.approveRequest(
        'r-1',
        reviewerId: actor.user.id,
      );
      expect(reviewed, isA<Success<AttendanceCorrectionRequest>>());
      final after = (await local.byId(
        'demo-company',
        'employee-employee',
        draft.attendanceDayId,
      ))!;
      expect(
        after.totalWorkDuration,
        before.totalWorkDuration + const Duration(minutes: 2),
      );
      expect(
        (await local.events(
          'demo-company',
          'employee-employee',
          draft.attendanceDayId,
        )),
        originals,
      );
      expect(
        (await repo.effectiveEvents(
          'demo-company',
          'employee-employee',
          draft.attendanceDayId,
        )).first.effectiveTimestamp,
        draft.changes.single.requestedTimestamp,
      );
      actor = employeeContext(AppRole.employee);
      final history = await local.history(
        'demo-company',
        'employee-employee',
        AttendanceHistoryQuery(year: 2026, month: 9),
        clock.now(),
      );
      expect(
        history.items
            .firstWhere((i) => i.id == draft.attendanceDayId)
            .totalWorkDuration,
        after.totalWorkDuration,
      );
    },
  );

  test('duplicate pending, cancel and rejection reason are enforced', () async {
    final draft = await request();
    expect(
      await repo.createRequest(draft),
      isA<Success<AttendanceCorrectionRequest>>(),
    );
    expect(
      await repo.createRequest(draft),
      isA<Failed<AttendanceCorrectionRequest>>(),
    );
    expect(await repo.cancelRequest(draft.id), isA<Success<void>>());
    expect(
      (await repo.getRequestById(draft.id)
              as Success<AttendanceCorrectionRequest?>)
          .value!
          .status,
      AttendanceCorrectionStatus.cancelled,
    );
    final another = await request();
    final r = AttendanceCorrectionRequest(
      id: 'r-2',
      companyId: another.companyId,
      employeeId: another.employeeId,
      attendanceDayId: another.attendanceDayId,
      requestType: another.requestType,
      status: another.status,
      reason: another.reason,
      originalSnapshot: '',
      changes: another.changes,
      requestedByUserId: another.requestedByUserId,
      requestedAt: another.requestedAt,
      createdAt: another.createdAt,
      updatedAt: another.updatedAt,
    );
    expect(
      await repo.createRequest(r),
      isA<Success<AttendanceCorrectionRequest>>(),
    );
    actor = employeeContext(AppRole.manager);
    expect(
      await repo.rejectRequest(r.id, reviewerId: actor.user.id, note: ''),
      isA<Failed<AttendanceCorrectionRequest>>(),
    );
    expect(
      await repo.rejectRequest(
        r.id,
        reviewerId: actor.user.id,
        note: 'Cannot verify',
      ),
      isA<Success<AttendanceCorrectionRequest>>(),
    );
    expect(
      await repo.approveRequest(r.id, reviewerId: actor.user.id),
      isA<Failed<AttendanceCorrectionRequest>>(),
    );
  });

  test(
    'production correction writes a scoped pending outbox operation',
    () async {
      repo = LocalAttendanceCorrectionRepository(
        db,
        auth,
        clock,
        demoEnabled: false,
      );
      final draft = await request();
      expect(
        await repo.createRequest(draft),
        isA<Success<AttendanceCorrectionRequest>>(),
      );
      final queued = await db.select(db.syncOutbox).get();
      expect(queued, hasLength(1));
      expect(queued.single.moduleId, 'attendance-correction');
      expect(queued.single.companyId, draft.companyId);
      expect(queued.single.entityId, draft.id);
      expect(queued.single.operation, 'request');
    },
  );

  test('v4 migration adds corrections and keeps attendance/events', () async {
    final folder = Directory.systemTemp.createTempSync(
      'erp_correction_migration_',
    );
    final file = File('${folder.path}/erp.sqlite');
    try {
      final old = AppDatabase(NativeDatabase(file));
      await seedEmployees(old);
      await seedAttendanceConfiguration(old);
      await seedDemoAttendance(old, enabled: true, clock: clock);
      final beforeDays = (await old.select(old.attendanceDays).get()).length;
      final beforeEvents =
          (await old.select(old.attendanceEvents).get()).length;
      await old.customStatement('DROP TABLE attendance_correction_requests');
      await old.customStatement('PRAGMA user_version=4');
      await old.close();
      final upgraded = AppDatabase(NativeDatabase(file));
      expect(
        (await upgraded.select(upgraded.attendanceDays).get()).length,
        beforeDays,
      );
      expect(
        (await upgraded.select(upgraded.attendanceEvents).get()).length,
        beforeEvents,
      );
      expect(
        await upgraded.select(upgraded.attendanceCorrectionRequests).get(),
        isEmpty,
      );
      expect(
        (await upgraded.customSelect('PRAGMA user_version').getSingle())
            .read<int>('user_version'),
        6,
      );
      await upgraded.close();
    } finally {
      file.deleteSync();
      folder.deleteSync();
    }
  });
}
