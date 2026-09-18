import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/features/attendance/application/execute_attendance_action.dart';
import 'package:modular_erp/features/attendance/data/attendance_local_data_source.dart';
import 'package:modular_erp/features/attendance/data/local_attendance_repository.dart';
import 'package:modular_erp/features/attendance/domain/attendance_context_resolver.dart';
import 'package:modular_erp/features/attendance/domain/attendance_models.dart';
import 'package:modular_erp/features/attendance/domain/attendance_repository.dart';
import 'package:modular_erp/features/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/features/attendance/presentation/attendance_ticker_cubit.dart';
import 'package:modular_erp/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:modular_erp/features/attendance/presentation/pages/attendance_today_page.dart';
import 'package:modular_erp/features/attendance/presentation/widgets/attendance_confirmation_sheet.dart';
import 'package:modular_erp/features/attendance/presentation/widgets/attendance_state_card.dart';
import 'package:modular_erp/features/employees/data/employee_dao.dart';
import 'package:modular_erp/features/employees/data/local_employee_repository.dart';
import 'package:modular_erp/features/employees/data/account_provisioning_repository.dart';
import 'package:modular_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'attendance_test.dart' show FakeClock, MockCapture, TestSender;
import 'employee_test.dart' show employeeContext;
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/features/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/features/attendance/data/attendance_sync_handler.dart';
import 'auth_widget_test.dart' as h;

class Experience {
  Experience(this.harness, this.bloc, this.clock, this.capture, this.settings);
  final h.Harness harness;
  final AttendanceBloc bloc;
  final FakeClock clock;
  final MockCapture capture;
  final List<bool> settings;
  AppDatabase get db => harness.database!;
}

Future<void> settle(WidgetTester t) async {
  for (var i = 0; i < 8; i++) {
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 8)),
    );
    await h.pump(t);
  }
}

Future<Experience> mount(
  WidgetTester t,
  AppLanguage language,
  double width, {
  bool gps = false,
  bool configured = true,
  AuthContext? authContext,
}) async {
  h.viewport(t, width);
  final clock = FakeClock(DateTime.utc(2026, 9, 17, 5));
  final capture = MockCapture();
  when(() => capture.capture()).thenAnswer(
    (_) async => Success(
      AttendanceLocationEvidence(
        latitude: 17.385044,
        longitude: 78.486671,
        accuracyMeters: 10,
        capturedAt: clock.now(),
      ),
    ),
  );
  late AttendanceBloc bloc;
  final settings = <bool>[];
  h.MockAuth? authOverride;
  if (authContext != null) {
    authOverride = h.MockAuth();
    when(
      () => authOverride!.sessionChanges,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => authOverride!.checkSession(),
    ).thenAnswer((_) async => Success(authContext));
    when(
      () => authOverride!.restoreSession(),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => authOverride!.login(any(), any()),
    ).thenAnswer((_) async => Success(authContext));
    when(() => authOverride!.dispose()).thenAnswer((_) async {});
  }
  final harness = await h.mount(
    t,
    language,
    repository: authOverride,
    attendanceClock: clock,
    createAttendanceBloc: (auth, db) {
      final employees = LocalEmployeeRepository(
        EmployeeDao(db),
        LocalAccountProvisioningRepository(db),
      );
      final repo = LocalAttendanceRepository(
        AttendanceLocalDataSource(db),
        auth,
        AttendanceContextResolver(
          employees,
          const ShiftWorkdayResolver(FixedOffsetCompanyTimeService()),
        ),
        clock,
        const UnconfiguredAttendanceRemote(),
      );
      return bloc = AttendanceBloc(
        repo,
        ExecuteAttendanceAction(
          repo,
          capture,
          clock,
          AttendanceEventSource.web,
        ),
        requireConfirmation: true,
        openSettings: (gps) async {
          settings.add(gps);
          return const Success(true);
        },
      );
    },
  );
  addTearDown(() async {
    if (!harness.disposed) await h.unmount(t, harness);
  });
  await t.runAsync(
    () => harness.database!.customStatement(
      "UPDATE attendance_policy_records SET offline_mode='allowWithWarning'",
    ),
  );
  if (configured) {
    await t.runAsync(
      () => harness.database!.customStatement(
        "UPDATE workforce_employees SET shift_id='shift-general',attendance_policy_id='${gps ? 'policy-office' : 'policy-remote'}',work_location_id='location-hyderabad' WHERE id='employee-employee'",
      ),
    );
  }
  harness.auth.add(
    const AuthLoginRequested('employee@erp.demo', 'Employee@123'),
  );
  await settle(t);
  h.router(t).go('/app/attendance');
  await settle(t);
  return Experience(harness, bloc, clock, capture, settings);
}

Future<int> eventCount(WidgetTester t, Experience e) async =>
    (await t.runAsync(() => e.db.select(e.db.attendanceEvents).get()))!.length;
Future<void> action(
  WidgetTester t,
  Experience e,
  String label, {
  bool confirm = true,
}) async {
  await h.tapVisible(
    t,
    find.widgetWithText(AppPrimaryButton, label).evaluate().isNotEmpty
        ? find.widgetWithText(AppPrimaryButton, label).first
        : find.widgetWithText(AppSecondaryButton, label).first,
  );
  await settle(t);
  if (confirm &&
      find.byType(AttendanceConfirmationSheet).evaluate().isNotEmpty) {
    await h.tapVisible(t, find.byKey(const ValueKey('attendance-confirm')));
    await settle(t);
  }
}

void main() {
  setUpAll(() async {
    registerFallbackValue(AuthIdentifier.parse('employee@erp.demo')!);
    for (final font in {
      'Manrope': 'assets/fonts/Manrope-SemiBold.ttf',
      'IBMPlexSansArabic': 'assets/fonts/IBMPlexSansArabic-Regular.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      await (FontLoader(font.key)..addFont(rootBundle.load(font.value))).load();
    }
  });
  for (final language in AppLanguage.values) {
    for (final width in [
      360.0,
      390.0,
      430.0,
      600.0,
      768.0,
      900.0,
      1024.0,
      1280.0,
      1440.0,
      1920.0,
    ]) {
      testWidgets(
        '${language.name} four workday states fit $width and confirm before writing',
        (t) async {
          final e = await mount(t, language, width);
          final l = t.element(find.byType(AttendanceTodayPage)).l10n;
          expect(
            e.bloc.state.summary!.currentState,
            AttendanceWorkdayState.notStarted,
          );
          expect(
            find.widgetWithText(AppPrimaryButton, l.attendancePunchIn),
            findsOneWidget,
          );
          expect(
            find.widgetWithText(AppSecondaryButton, l.attendancePunchOut),
            findsNothing,
          );
          await action(t, e, l.attendancePunchIn, confirm: false);
          expect(find.byType(AttendanceConfirmationSheet), findsOneWidget);
          expect(await eventCount(t, e), 0);
          await h.tapVisible(
            t,
            find.byKey(const ValueKey('attendance-confirm')),
          );
          await settle(t);
          expect(
            e.bloc.state.summary!.currentState,
            AttendanceWorkdayState.working,
          );
          expect(await eventCount(t, e), 1);
          final ticker = t
              .element(find.byType(AttendanceStateCard))
              .read<AttendanceTickerCubit>();
          expect(ticker.isRunning, isTrue);
          e.clock.time = e.clock.time.add(const Duration(hours: 1));
          await t.pump(const Duration(seconds: 1));
          expect(ticker.state!.workDuration, const Duration(hours: 1));
          expect(await eventCount(t, e), 1);
          if (width == 390 || width == 1440) {
            final scroll = find
                .descendant(
                  of: find.byType(AttendanceTodayPage),
                  matching: find.byType(Scrollable),
                )
                .first;
            t.state<ScrollableState>(scroll).position.jumpTo(0);
            await h.pump(t);
            await h.screenshot(
              t,
              e.harness.key,
              'phase7_${language.name}_${width.toInt()}_working',
            );
          }
          await action(t, e, l.attendanceTakeBreak);
          expect(
            e.bloc.state.summary!.currentState,
            AttendanceWorkdayState.onBreak,
          );
          e.clock.time = e.clock.time.add(const Duration(minutes: 15));
          await t.pump(const Duration(seconds: 1));
          expect(ticker.state!.breakDuration, const Duration(minutes: 15));
          expect(ticker.state!.workDuration, const Duration(hours: 1));
          await action(t, e, l.attendanceResumeWork);
          expect(
            e.bloc.state.summary!.currentState,
            AttendanceWorkdayState.working,
          );
          e.clock.time = DateTime.utc(2026, 9, 17, 14);
          e.bloc.add(const AttendanceRefreshRequested());
          await settle(t);
          await action(t, e, l.attendancePunchOut, confirm: false);
          expect(find.byType(AttendanceConfirmationSheet), findsOneWidget);
          expect(await eventCount(t, e), 3);
          // Watch updates while the sheet is open must not stack another sheet.
          e.bloc.add(const AttendanceRefreshRequested());
          await settle(t);
          expect(find.byType(AttendanceConfirmationSheet), findsOneWidget);
          await h.tapVisible(
            t,
            find.byKey(const ValueKey('attendance-confirm')),
          );
          await settle(t);
          expect(
            e.bloc.state.summary!.currentState,
            AttendanceWorkdayState.completed,
          );
          expect(ticker.isRunning, isFalse);
          final frozenDuration = ticker.state!.workDuration;
          e.clock.time = e.clock.time.add(const Duration(hours: 1));
          await t.pump(const Duration(seconds: 1));
          expect(ticker.state!.workDuration, frozenDuration);
          expect(await eventCount(t, e), 4);
          expect(
            find.widgetWithText(AppPrimaryButton, l.attendancePunchIn),
            findsNothing,
          );
          expect(find.byType(AppTimeline), findsOneWidget);
          expect(
            t.widget<AppTimeline>(find.byType(AppTimeline)).items.length,
            4,
          );
          expect(t.takeException(), isNull);
          verifyNever(() => e.capture.capture());
          await h.unmount(t, e.harness);
        },
      );
    }
  }
  testWidgets(
    'cancel creates no event; resume derives clock and offstage stops ticker',
    (t) async {
      final e = await mount(t, AppLanguage.english, 390);
      final l = t.element(find.byType(AttendanceTodayPage)).l10n;
      await action(t, e, l.attendancePunchIn, confirm: false);
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(t);
      expect(find.byType(AttendanceConfirmationSheet), findsNothing);
      expect(await eventCount(t, e), 0);
      await action(t, e, l.attendancePunchIn, confirm: false);
      await h.tapVisible(t, find.widgetWithText(AppSecondaryButton, l.cancel));
      await settle(t);
      expect(await eventCount(t, e), 0);
      await action(t, e, l.attendancePunchIn);
      final ticker = t
          .element(find.byType(AttendanceStateCard))
          .read<AttendanceTickerCubit>();
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await h.pump(t);
      expect(ticker.isRunning, isFalse);
      e.clock.time = e.clock.time.add(const Duration(hours: 2));
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await settle(t);
      expect(ticker.state!.workDuration, const Duration(hours: 2));
      h.router(t).go('/app');
      await settle(t);
      expect(ticker.isRunning, isFalse);
      expect(e.bloc.isClosed, isFalse);
      h.router(t).go('/app/attendance');
      await settle(t);
      expect(ticker.isRunning, isTrue);
      expect(await eventCount(t, e), 1);
      await h.unmount(t, e.harness);
    },
  );
  testWidgets('missing assignments shows setup reason without punch', (
    t,
  ) async {
    final e = await mount(t, AppLanguage.arabic, 360, configured: false);
    expect(e.bloc.state.contextStatus, AttendanceContextStatus.unavailable);
    expect(find.byType(AppNotice), findsWidgets);
    expect(find.byType(AttendanceStateCard), findsNothing);
    expect(await eventCount(t, e), 0);
    await h.unmount(t, e.harness);
  });
  for (final code in [
    AttendanceFailureCode.locationPermissionDenied,
    AttendanceFailureCode.locationPermissionPermanentlyDenied,
    AttendanceFailureCode.locationServicesDisabled,
    AttendanceFailureCode.locationUnavailable,
  ]) {
    testWidgets('inline GPS $code never mutates and settings stay explicit', (
      t,
    ) async {
      final e = await mount(t, AppLanguage.english, 390, gps: true);
      when(() => e.capture.capture()).thenAnswer(
        (_) async => Failed(
          Failure(code: code.name, kind: FailureKind.locationPermission),
        ),
      );
      final l = t.element(find.byType(AttendanceTodayPage)).l10n;
      await action(t, e, l.attendancePunchIn);
      expect(e.bloc.state.failure!.code, code.name);
      expect(await eventCount(t, e), 0);
      if (code == AttendanceFailureCode.locationPermissionPermanentlyDenied ||
          code == AttendanceFailureCode.locationServicesDisabled) {
        await h.tapVisible(
          t,
          find.widgetWithText(AppSecondaryButton, l.attendanceOpenSettings),
        );
        await settle(t);
        expect(e.settings, [
          code == AttendanceFailureCode.locationServicesDisabled,
        ]);
      }
      if (code == AttendanceFailureCode.locationPermissionDenied) {
        when(() => e.capture.capture()).thenAnswer(
          (_) async => Success(
            AttendanceLocationEvidence(
              latitude: 17.385044,
              longitude: 78.486671,
              accuracyMeters: 10,
              capturedAt: e.clock.now(),
            ),
          ),
        );
        await h.tapVisible(
          t,
          find.widgetWithText(AppTextButton, l.attendanceAllowLocation),
        );
        await settle(t);
        expect(e.bloc.state.locationPreview!.decision.allowed, isTrue);
        expect(await eventCount(t, e), 0);
      }
      expect(t.takeException(), isNull);
      await h.unmount(t, e.harness);
    });
  }
  for (final accuracy in [10.0, 100.0]) {
    testWidgets(
      'GPS accuracy $accuracy displays current and required accuracy',
      (t) async {
        final e = await mount(t, AppLanguage.arabic, 390, gps: true);
        when(() => e.capture.capture()).thenAnswer(
          (_) async => Success(
            AttendanceLocationEvidence(
              latitude: 17.385044,
              longitude: 78.486671,
              accuracyMeters: accuracy,
              capturedAt: e.clock.now(),
            ),
          ),
        );
        e.bloc.add(
          const AttendanceLocationRefreshRequested(AttendanceEventType.punchIn),
        );
        await settle(t);
        expect(e.bloc.state.locationPreview!.decision.allowed, accuracy == 10);
        expect(await eventCount(t, e), 0);
        expect(find.textContaining('17.385044'), findsNothing);
        expect(t.takeException(), isNull);
        await h.unmount(t, e.harness);
      },
    );
  }
  testWidgets(
    'location capture progress remains inline and blocks duplicate actions',
    (t) async {
      final e = await mount(t, AppLanguage.english, 1280, gps: true);
      final gate = Completer<Result<AttendanceLocationEvidence>>();
      when(() => e.capture.capture()).thenAnswer((_) => gate.future);
      e.bloc.add(const PunchInRequested());
      await settle(t);
      expect(
        e.bloc.state.actionStatus,
        AttendanceActionStatus.checkingLocation,
      );
      expect(find.byType(AttendanceStateCard), findsOneWidget);
      expect(await eventCount(t, e), 0);
      e.bloc.add(const PunchInRequested());
      gate.complete(
        Success(
          AttendanceLocationEvidence(
            latitude: 17.385044,
            longitude: 78.486671,
            accuracyMeters: 10,
            capturedAt: e.clock.now(),
          ),
        ),
      );
      await settle(t);
      expect(find.byType(AttendanceConfirmationSheet), findsOneWidget);
      verify(() => e.capture.capture()).called(1);
      await h.unmount(t, e.harness);
    },
  );
  for (final outsideAllowed in [false, true]) {
    testWidgets(
      'outside geofence allowed=$outsideAllowed confirms before write',
      (t) async {
        final e = await mount(t, AppLanguage.english, 390, gps: true);
        if (outsideAllowed) {
          await t.runAsync(
            () => e.db.customStatement(
              "UPDATE attendance_policy_records SET allow_outside_location=1 WHERE id='policy-office'",
            ),
          );
        }
        when(() => e.capture.capture()).thenAnswer(
          (_) async => Success(
            AttendanceLocationEvidence(
              latitude: 18,
              longitude: 78,
              accuracyMeters: 10,
              capturedAt: e.clock.now(),
            ),
          ),
        );
        final l = t.element(find.byType(AttendanceTodayPage)).l10n;
        await action(t, e, l.attendancePunchIn, confirm: false);
        expect(await eventCount(t, e), 0);
        if (outsideAllowed) {
          expect(find.byType(AttendanceConfirmationSheet), findsOneWidget);
          expect(
            e.bloc.state.warnings,
            contains(AttendanceWarningCode.outsideAllowedLocation),
          );
          await h.tapVisible(
            t,
            find.byKey(const ValueKey('attendance-confirm')),
          );
          await settle(t);
          expect(await eventCount(t, e), 1);
        } else {
          expect(find.byType(AttendanceConfirmationSheet), findsNothing);
          expect(e.bloc.state.failure!.code, 'outsideAllowedLocation');
        }
        await h.unmount(t, e.harness);
      },
    );
  }
  for (final reject in [false, true]) {
    testWidgets(
      'server ${reject ? 'rejection' : 'failure'} preserves original operation and event',
      (t) async {
        final e = await mount(t, AppLanguage.english, 1280);
        final l = t.element(find.byType(AttendanceTodayPage)).l10n;
        await action(t, e, l.attendancePunchIn);
        final request = e.bloc.state.context!.events.single.requestId;
        final sender = TestSender(
          (event) async => reject
              ? Success(
                  AttendanceRemoteConfirmation(
                    requestId: event.requestId,
                    accepted: false,
                    rejectionCode: 'testRejected',
                  ),
                )
              : const Failed(
                  Failure(code: 'offline', kind: FailureKind.offline),
                ),
        );
        final syncAuth = h.MockAuth();
        final syncContext = e.bloc.state.context!.auth;
        when(
          () => syncAuth.checkSession(),
        ).thenAnswer((_) async => Success(syncContext));
        final syncing = AttendanceSyncHandler(
          AttendanceLocalDataSource(e.db),
          syncAuth,
          sender,
          e.clock,
        ).synchronize();
        await settle(t);
        await syncing;
        await settle(t);
        expect(
          e.bloc.state.currentDay!.syncStatus,
          reject ? AttendanceSyncStatus.rejected : AttendanceSyncStatus.failed,
        );
        expect(
          find.text(
            reject ? l.attendanceRejectedTitle : l.attendanceFailedTitle,
          ),
          findsOneWidget,
        );
        if (!reject) {
          await h.tapVisible(
            t,
            find.byKey(ValueKey('attendance-retry-$request')),
          );
          await settle(t);
          expect(
            e.bloc.state.currentDay!.syncStatus,
            AttendanceSyncStatus.pending,
          );
        } else {
          expect(
            find.byKey(ValueKey('attendance-retry-$request')),
            findsNothing,
          );
        }
        expect(await eventCount(t, e), 1);
        final rows = await t.runAsync(() => e.db.select(e.db.syncOutbox).get());
        expect(rows!.single.requestId, request);
        expect(rows.single.id, request);
        await h.unmount(t, e.harness);
      },
    );
  }
  testWidgets('view-self only hides every mutation action', (t) async {
    final base = employeeContext(AppRole.employee);
    final restricted = base.copyWith(
      user: base.user.copyWith(
        permissions: PermissionSet([
          AppPermission.attendanceViewSelf,
          AppPermission.employeeViewSelf,
        ]),
      ),
    );
    final e = await mount(t, AppLanguage.english, 390, authContext: restricted);
    expect(find.byType(AttendanceTodayPage), findsOneWidget);
    expect(e.bloc.state.actions!.canPunchIn, isFalse);
    expect(find.byType(AppPrimaryButton), findsNothing);
    expect(await eventCount(t, e), 0);
    await h.unmount(t, e.harness);
  });
  testWidgets('unlinked session has a dedicated blocked state', (t) async {
    final e = await mount(
      t,
      AppLanguage.arabic,
      390,
      authContext: employeeContext(
        AppRole.employee,
      ).copyWith(employeeReference: null),
    );
    expect(e.bloc.state.failure!.code, 'notLinkedToEmployee');
    expect(find.byType(AttendanceStateCard), findsNothing);
    expect(await eventCount(t, e), 0);
    await h.unmount(t, e.harness);
  });
  testWidgets(
    'multiple breaks stay in today timeline; punch out closes an allowed open break',
    (t) async {
      final e = await mount(t, AppLanguage.english, 390);
      await t.runAsync(
        () => e.db.customStatement(
          "UPDATE attendance_policy_records SET allow_punch_out_during_break=1 WHERE id='policy-remote'",
        ),
      );
      final l = t.element(find.byType(AttendanceTodayPage)).l10n;
      await action(t, e, l.attendancePunchIn);
      for (var i = 0; i < 2; i++) {
        e.clock.time = e.clock.time.add(const Duration(minutes: 30));
        await action(t, e, l.attendanceTakeBreak);
        e.clock.time = e.clock.time.add(const Duration(minutes: 10));
        await action(t, e, l.attendanceResumeWork);
      }
      e.clock.time = e.clock.time.add(const Duration(minutes: 30));
      await action(t, e, l.attendanceTakeBreak);
      e.clock.time = DateTime.utc(2026, 9, 17, 14);
      e.bloc.add(const AttendanceRefreshRequested());
      await settle(t);
      await action(t, e, l.attendancePunchOut, confirm: false);
      expect(find.text(l.attendanceCloseBreakNote), findsOneWidget);
      await h.tapVisible(t, find.byKey(const ValueKey('attendance-confirm')));
      await settle(t);
      expect(e.bloc.state.summary!.breaks.length, 3);
      expect(
        e.bloc.state.summary!.currentState,
        AttendanceWorkdayState.completed,
      );
      expect(await eventCount(t, e), 7);
      await h.unmount(t, e.harness);
    },
  );
  testWidgets(
    'Arabic scaled layout keeps timer LTR and a labelled minimum-size action',
    (t) async {
      t.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      final semantics = t.ensureSemantics();

      final e = await mount(t, AppLanguage.arabic, 360);
      final l = t.element(find.byType(AttendanceTodayPage)).l10n;
      final punch = find.widgetWithText(AppPrimaryButton, l.attendancePunchIn);
      expect(t.getSize(punch).height, greaterThanOrEqualTo(48));
      await action(t, e, l.attendancePunchIn, confirm: false);
      expect(find.byType(AttendanceConfirmationSheet), findsOneWidget);
      expect(t.takeException(), isNull);
      await h.tapVisible(t, find.byKey(const ValueKey('attendance-confirm')));
      await settle(t);
      expect(
        t
            .widget<Text>(find.byKey(const ValueKey('attendance-live-timer')))
            .textDirection,
        TextDirection.ltr,
      );
      expect(
        Directionality.of(t.element(find.byType(AttendanceStateCard))),
        TextDirection.rtl,
      );
      expect(t.takeException(), isNull);
      semantics.dispose();
      await h.unmount(t, e.harness);
    },
  );
  testWidgets(
    'GPS evidence expires while awaiting confirmation and cannot be committed',
    (t) async {
      final e = await mount(t, AppLanguage.english, 390, gps: true);
      final l = t.element(find.byType(AttendanceTodayPage)).l10n;
      await action(t, e, l.attendancePunchIn, confirm: false);
      e.clock.time = e.clock.time.add(const Duration(minutes: 10));
      await h.tapVisible(t, find.byKey(const ValueKey('attendance-confirm')));
      await settle(t);
      expect(e.bloc.state.failure!.code, 'staleLocationEvidence');
      expect(await eventCount(t, e), 0);
      await h.unmount(t, e.harness);
    },
  );
  testWidgets(
    'late punch warning and pending warning share one cancellable sheet',
    (t) async {
      final e = await mount(t, AppLanguage.english, 390);
      e.clock.time = e.clock.time.add(const Duration(minutes: 15));
      e.bloc.add(const AttendanceRefreshRequested());
      await settle(t);
      final l = t.element(find.byType(AttendanceTodayPage)).l10n;
      await action(t, e, l.attendancePunchIn, confirm: false);
      expect(
        e.bloc.state.warnings,
        containsAll([
          AttendanceWarningCode.latePunchIn,
          AttendanceWarningCode.offlinePending,
        ]),
      );
      expect(find.byType(AttendanceConfirmationSheet), findsOneWidget);
      expect(await eventCount(t, e), 0);
      await h.unmount(t, e.harness);
    },
  );
  testWidgets('inactive employee is blocked before any GPS capture', (t) async {
    final e = await mount(t, AppLanguage.english, 390, gps: true);
    await t.runAsync(
      () => e.db.customStatement(
        "UPDATE workforce_employees SET status='inactive' WHERE id='employee-employee'",
      ),
    );
    e.bloc.add(const AttendanceRefreshRequested());
    await settle(t);
    expect(e.bloc.state.failure!.code, 'employeeInactive');
    expect(find.byType(AttendanceStateCard), findsNothing);
    expect(await eventCount(t, e), 0);
    verifyNever(() => e.capture.capture());
    await h.unmount(t, e.harness);
  });
  testWidgets('view-team grant alone cannot access the self attendance route', (
    t,
  ) async {
    final e = await mount(t, AppLanguage.english, 390);
    final a = e.harness.auth.state.context!;
    e.harness.auth.add(
      AuthSessionUpdated(
        a.copyWith(
          user: a.user.copyWith(
            permissions: PermissionSet([
              AppPermission.attendanceViewTeam,
              AppPermission.employeeViewSelf,
            ]),
          ),
        ),
      ),
    );
    await settle(t);
    h.router(t).go('/app/attendance');
    await settle(t);
    expect(find.byType(AttendanceTodayPage), findsNothing);
    expect(e.bloc.isClosed, isTrue);
    expect(await eventCount(t, e), 0);
    await h.unmount(t, e.harness);
  });
  for (final omitted in [
    AppPermission.attendanceBreak,
    AppPermission.attendancePunchOut,
  ]) {
    testWidgets('working actions respect omitted $omitted', (t) async {
      final a = employeeContext(AppRole.employee);
      final permissions = a.user.permissions.values.where((p) => p != omitted);
      final e = await mount(
        t,
        AppLanguage.english,
        390,
        authContext: a.copyWith(
          user: a.user.copyWith(permissions: PermissionSet(permissions)),
        ),
      );
      final l = t.element(find.byType(AttendanceTodayPage)).l10n;
      await action(t, e, l.attendancePunchIn);
      e.clock.time = DateTime.utc(2026, 9, 17, 14);
      e.bloc.add(const AttendanceRefreshRequested());
      await settle(t);
      expect(
        find.widgetWithText(AppSecondaryButton, l.attendanceTakeBreak),
        omitted == AppPermission.attendanceBreak
            ? findsNothing
            : findsOneWidget,
      );
      expect(
        find.widgetWithText(AppSecondaryButton, l.attendancePunchOut),
        omitted == AppPermission.attendancePunchOut
            ? findsNothing
            : findsOneWidget,
      );
      await h.unmount(t, e.harness);
    });
  }
  testWidgets(
    'single-break policy explains exhausted breaks and forbids punch out on break',
    (t) async {
      final e = await mount(t, AppLanguage.english, 390);
      await t.runAsync(
        () => e.db.customStatement(
          "UPDATE attendance_policy_records SET allow_multiple_breaks=0 WHERE id='policy-remote'",
        ),
      );
      final l = t.element(find.byType(AttendanceTodayPage)).l10n;
      await action(t, e, l.attendancePunchIn);
      await action(t, e, l.attendanceTakeBreak);
      e.clock.time = DateTime.utc(2026, 9, 17, 14);
      e.bloc.add(const AttendanceRefreshRequested());
      await settle(t);
      expect(
        find.widgetWithText(AppSecondaryButton, l.attendancePunchOut),
        findsNothing,
      );
      await action(t, e, l.attendanceResumeWork);
      expect(
        find.widgetWithText(AppSecondaryButton, l.attendanceTakeBreak),
        findsNothing,
      );
      expect(
        e
            .bloc
            .state
            .actions!
            .decisions[AttendanceEventType.breakStart]!
            .failure,
        AttendanceFailureCode.multipleBreaksNotAllowed,
      );
      await h.unmount(t, e.harness);
    },
  );
  testWidgets(
    'dashboard preview shows real session state and opens the same attendance owner',
    (t) async {
      final e = await mount(t, AppLanguage.english, 390);
      final l = t.element(find.byType(AttendanceTodayPage)).l10n;
      await action(t, e, l.attendancePunchIn);
      h.router(t).go('/app');
      await settle(t);
      expect(find.byKey(const ValueKey('metric-hours')), findsNothing);
      expect(find.byType(AppActivityItem), findsNothing);
      expect(find.text(l.attendanceWorking), findsOneWidget);
      await h.tapVisible(
        t,
        find.widgetWithText(AppSecondaryButton, l.attendanceOpenAttendance),
      );
      await settle(t);
      expect(
        identical(
          t.element(find.byType(AttendanceTodayPage)).read<AttendanceBloc>(),
          e.bloc,
        ),
        isTrue,
      );
      expect(await eventCount(t, e), 1);
      await h.unmount(t, e.harness);
    },
  );
  testWidgets(
    'shift-end boundary refreshes eligibility without creating attendance',
    (t) async {
      final e = await mount(t, AppLanguage.english, 390);
      final l = t.element(find.byType(AttendanceTodayPage)).l10n;
      await action(t, e, l.attendancePunchIn);
      e.clock.time = DateTime.utc(2026, 9, 17, 13, 59, 59);
      e.bloc.add(const AttendanceRefreshRequested());
      // Do not advance virtual time past the boundary until the clock follows it.
      for (var i = 0; i < 8; i++) {
        await t.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 8)),
        );
        await t.pump();
      }
      expect(e.bloc.state.actions!.canPunchOut, isFalse);
      e.clock.time = DateTime.utc(2026, 9, 17, 14);
      await t.pump(const Duration(seconds: 1));
      await settle(t);
      expect(e.bloc.state.actions!.canPunchOut, isTrue);
      expect(
        find.widgetWithText(AppSecondaryButton, l.attendancePunchOut),
        findsOneWidget,
      );
      expect(await eventCount(t, e), 1);
      await h.unmount(t, e.harness);
    },
  );
}
