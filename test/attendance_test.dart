import 'package:bloc_test/bloc_test.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/core/utils/local_time.dart';
import 'package:modular_erp/core/sync/outbox_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/modules/hr/employees/data/employee_seed.dart';
import 'package:modular_erp/modules/hr/employees/data/employee_dao.dart';
import 'package:modular_erp/modules/hr/employees/data/local_employee_repository.dart';
import 'package:modular_erp/modules/hr/employees/data/account_provisioning_repository.dart';
import 'package:modular_erp/modules/hr/demo/demo_configuration_seed.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_engine.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_context_resolver.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_state_machine.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_summary_calculator.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_location_validator.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/hr/attendance/data/attendance_local_data_source.dart';
import 'package:modular_erp/modules/hr/attendance/data/local_attendance_repository.dart';
import 'package:modular_erp/modules/hr/attendance/data/attendance_sync_handler.dart';
import 'package:modular_erp/modules/hr/attendance/application/execute_attendance_action.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_bloc.dart';
import 'employee_test.dart' show employeeContext, unwrap, until;

class FakeClock implements AppClock {
  FakeClock(this.time);
  DateTime time;
  @override
  DateTime now() => time;
}

class MockAuth extends Mock implements AuthRepository {}

class MockCapture extends Mock implements AttendanceLocationCapture {}

class TestSender implements AttendanceRemoteSender {
  TestSender(this.callback);
  final Future<Result<AttendanceRemoteConfirmation>> Function(AttendanceEvent)
  callback;
  @override
  Future<Result<AttendanceRemoteConfirmation>> send(AttendanceEvent e) =>
      callback(e);
}

final baseline = DateTime.utc(2026, 9, 17);
Shift fixtureShift({bool night = false}) => Shift(
  id: 's',
  companyId: 'demo-company',
  name: 'Shift',
  startTime: LocalTime(hour: night ? 22 : 9, minute: 0),
  endTime: LocalTime(hour: night ? 7 : 18, minute: 0),
  workingDays: WorkingDay.values.toSet(),
  gracePeriodMinutes: 10,
  createdAt: baseline,
  updatedAt: baseline,
);
AttendancePolicy fixturePolicy() => AttendancePolicy(
  id: 'p',
  companyId: 'demo-company',
  name: 'Policy',
  requireLocation: false,
  allowEarlyPunchIn: true,
  earlyPunchInLimitMinutes: 30,
  allowEarlyPunchOut: true,
  createdAt: baseline,
  updatedAt: baseline,
);
AttendanceConfigurationSnapshot fixtureSnapshot({
  Shift? shift,
  AttendancePolicy? policy,
  WorkLocation? location,
  bool night = false,
  AttendanceWorkMode mode = AttendanceWorkMode.office,
}) => AttendanceConfigurationSnapshot(
  shift: shift ?? fixtureShift(night: night),
  policy: policy ?? fixturePolicy(),
  workLocation: location,
  timezone: 'UTC',
  scheduledStart: baseline.add(Duration(hours: night ? 22 : 9)),
  scheduledEnd: baseline.add(
    Duration(days: night ? 1 : 0, hours: night ? 7 : 18),
  ),
  workMode: mode,
);
AttendanceEvent fixtureEvent(
  AttendanceEventType type,
  int minutes,
  int sequence, {
  DateTime? server,
}) => AttendanceEvent(
  id: 'e$sequence',
  attendanceDayId: 'day',
  companyId: 'demo-company',
  employeeId: 'employee-employee',
  eventType: type,
  deviceTimestamp: baseline.add(Duration(minutes: minutes)),
  serverTimestamp: server,
  sequence: sequence,
  locationValidation: const AttendanceLocationValidation(
    state: AttendanceLocationState.notRequired,
  ),
  requestId: const Uuid().v4(),
  source: AttendanceEventSource.mobile,
  syncStatus: AttendanceSyncStatus.pending,
  createdAt: baseline.add(Duration(minutes: minutes)),
);
List<AttendanceEvent> fixtureEvents(List<(AttendanceEventType, int)> values) =>
    [
      for (var i = 0; i < values.length; i++)
        fixtureEvent(values[i].$1, values[i].$2, i),
    ];
WorkLocation fixtureLocation({double radius = 150}) => WorkLocation(
  id: 'l',
  companyId: 'demo-company',
  name: 'Office',
  addressLine1: 'Street',
  city: 'City',
  countryCode: 'AE',
  latitude: 0,
  longitude: 0,
  allowedRadiusMeters: radius,
  createdAt: baseline,
  updatedAt: baseline,
);
AttendanceLocationEvidence evidence({
  double lat = 0,
  double lon = 0,
  double accuracy = 10,
  DateTime? captured,
}) => AttendanceLocationEvidence(
  latitude: lat,
  longitude: lon,
  accuracyMeters: accuracy,
  capturedAt: captured ?? baseline.add(const Duration(hours: 9)),
);
void failure<T>(Result<T> result, AttendanceFailureCode code) {
  expect(result, isA<Failed<T>>());
  expect((result as Failed<T>).failure.code, code.name);
}

void main() {
  group('state machine', () {
    const machine = AttendanceStateMachine();
    final p = fixturePolicy();
    final valid = {
      (AttendanceWorkdayState.notStarted, AttendanceEventType.punchIn):
          AttendanceWorkdayState.working,
      (AttendanceWorkdayState.working, AttendanceEventType.breakStart):
          AttendanceWorkdayState.onBreak,
      (AttendanceWorkdayState.onBreak, AttendanceEventType.breakEnd):
          AttendanceWorkdayState.working,
      (AttendanceWorkdayState.working, AttendanceEventType.punchOut):
          AttendanceWorkdayState.completed,
    };
    for (final state in AttendanceWorkdayState.values) {
      for (final type in AttendanceEventType.values) {
        test('$state $type', () {
          final r = machine.transition(state, type, p);
          if (valid.containsKey((state, type))) {
            expect(unwrap(r), valid[(state, type)]);
          } else {
            expect(r, isA<Failed<AttendanceWorkdayState>>());
          }
        });
      }
    }
    test(
      'break tracking disabled',
      () => failure(
        machine.transition(
          AttendanceWorkdayState.working,
          AttendanceEventType.breakStart,
          p.copyWith(trackBreaks: false),
        ),
        AttendanceFailureCode.breakTrackingDisabled,
      ),
    );
    test(
      'one break only',
      () => failure(
        machine.transition(
          AttendanceWorkdayState.working,
          AttendanceEventType.breakStart,
          p.copyWith(allowMultipleBreaks: false),
          breakCount: 1,
        ),
        AttendanceFailureCode.multipleBreaksNotAllowed,
      ),
    );
    test(
      'multiple breaks permitted',
      () => expect(
        unwrap(
          machine.transition(
            AttendanceWorkdayState.working,
            AttendanceEventType.breakStart,
            p,
            breakCount: 3,
          ),
        ),
        AttendanceWorkdayState.onBreak,
      ),
    );
    test(
      'punch out during break allowed',
      () => expect(
        unwrap(
          machine.transition(
            AttendanceWorkdayState.onBreak,
            AttendanceEventType.punchOut,
            p.copyWith(allowPunchOutDuringBreak: true),
          ),
        ),
        AttendanceWorkdayState.completed,
      ),
    );
  });
  group('summaries', () {
    const calc = AttendanceSummaryCalculator();
    final cases = <String, (List<(AttendanceEventType, int)>, int, int, int)>{
      'not started': ([], 780, 0, 0),
      'working': ([(AttendanceEventType.punchIn, 540)], 780, 240, 0),
      'one break': (
        [
          (AttendanceEventType.punchIn, 540),
          (AttendanceEventType.breakStart, 660),
          (AttendanceEventType.breakEnd, 675),
        ],
        780,
        240,
        15,
      ),
      'multiple breaks': (
        [
          (AttendanceEventType.punchIn, 540),
          (AttendanceEventType.breakStart, 660),
          (AttendanceEventType.breakEnd, 675),
          (AttendanceEventType.breakStart, 720),
          (AttendanceEventType.breakEnd, 730),
        ],
        780,
        240,
        25,
      ),
      'open break': (
        [
          (AttendanceEventType.punchIn, 540),
          (AttendanceEventType.breakStart, 660),
        ],
        780,
        240,
        120,
      ),
      'completed': (
        [
          (AttendanceEventType.punchIn, 540),
          (AttendanceEventType.punchOut, 1080),
        ],
        3000,
        540,
        0,
      ),
      'overnight': (
        [
          (AttendanceEventType.punchIn, 1320),
          (AttendanceEventType.punchOut, 1860),
        ],
        4000,
        540,
        0,
      ),
      'same time': (
        [
          (AttendanceEventType.punchIn, 540),
          (AttendanceEventType.breakStart, 540),
          (AttendanceEventType.breakEnd, 540),
          (AttendanceEventType.punchOut, 540),
        ],
        1000,
        0,
        0,
      ),
      'close break with punch out': (
        [
          (AttendanceEventType.punchIn, 540),
          (AttendanceEventType.breakStart, 660),
          (AttendanceEventType.punchOut, 720),
        ],
        2000,
        180,
        60,
      ),
    };
    for (final e in cases.entries) {
      test(e.key, () {
        final r = unwrap(
          calc.calculate(
            fixtureEvents(e.value.$1).reversed,
            baseline.add(Duration(minutes: e.value.$2)),
          ),
        );
        expect(r.elapsedDuration.inMinutes, e.value.$3);
        expect(r.breakDuration.inMinutes, e.value.$4);
        expect(r.workDuration.inMinutes, e.value.$3 - e.value.$4);
        if (e.key == 'open break') {
          expect(r.openBreakDuration.inMinutes, 120);
          expect(r.breaks.single.isOpen, true);
        }
      });
    }
    test('clock backwards never negative', () {
      final r = unwrap(
        calc.calculate([
          fixtureEvent(AttendanceEventType.punchIn, 540, 0),
        ], baseline),
      );
      expect(r.workDuration, Duration.zero);
    });
    for (final malformed in [
      [(AttendanceEventType.breakStart, 540)],
      [(AttendanceEventType.punchIn, 540), (AttendanceEventType.punchIn, 550)],
      [(AttendanceEventType.punchIn, 540), (AttendanceEventType.breakEnd, 550)],
    ]) {
      test(
        'malformed $malformed',
        () => failure(
          calc.calculate(fixtureEvents(malformed), baseline),
          AttendanceFailureCode.invalidAttendanceState,
        ),
      );
    }
    test('server timestamp takes precedence', () {
      final e = fixtureEvent(
        AttendanceEventType.punchIn,
        540,
        0,
        server: baseline.add(const Duration(hours: 10)),
      );
      expect(
        unwrap(
          calc.calculate([e], baseline.add(const Duration(hours: 11))),
        ).workDuration.inHours,
        1,
      );
    });
    test('snapshots and events typed JSON round trip', () {
      expect(
        AttendanceConfigurationSnapshot.fromJson(
          jsonDecode(jsonEncode(fixtureSnapshot().toJson()))
              as Map<String, dynamic>,
        ),
        fixtureSnapshot(),
      );
      final e = fixtureEvent(AttendanceEventType.punchIn, 540, 0);
      expect(AttendanceEvent.fromJson(e.toJson()), e);
    });
  });
  group('timing and timezone', () {
    const timing = AttendanceTimingEvaluator();
    final s = fixtureSnapshot();
    for (final pair in [
      (510, null),
      (509, AttendanceFailureCode.tooEarlyToPunchIn),
      (550, null),
      (551, AttendanceFailureCode.latePunchInNotAllowed),
    ]) {
      test(
        'punch minute ${pair.$1}',
        () => expect(
          timing.validate(
            s.copyWith(policy: s.policy.copyWith(allowLatePunchIn: false)),
            AttendanceEventType.punchIn,
            baseline.add(Duration(minutes: pair.$1)),
          ),
          pair.$2,
        ),
      );
    }
    test('late inclusive grace', () {
      expect(
        timing.isLate(s, baseline.add(const Duration(hours: 9, minutes: 10))),
        false,
      );
      expect(
        timing.isLate(s, baseline.add(const Duration(hours: 9, minutes: 11))),
        true,
      );
    });
    test(
      'early disabled',
      () => expect(
        timing.validate(
          s.copyWith(policy: s.policy.copyWith(allowEarlyPunchIn: false)),
          AttendanceEventType.punchIn,
          baseline.add(const Duration(hours: 8, minutes: 59)),
        ),
        AttendanceFailureCode.tooEarlyToPunchIn,
      ),
    );
    test(
      'early out blocked',
      () => expect(
        timing.validate(
          s.copyWith(policy: s.policy.copyWith(allowEarlyPunchOut: false)),
          AttendanceEventType.punchOut,
          baseline.add(const Duration(hours: 17)),
        ),
        AttendanceFailureCode.earlyPunchOutNotAllowed,
      ),
    );
    test(
      'scheduled end inclusive',
      () => expect(
        timing.validate(
          s.copyWith(policy: s.policy.copyWith(allowEarlyPunchOut: false)),
          AttendanceEventType.punchOut,
          s.scheduledEnd,
        ),
        null,
      ),
    );
    const resolver = ShiftWorkdayResolver(FixedOffsetCompanyTimeService());
    test('overnight start date', () {
      final r = unwrap(
        resolver.resolve(
          fixtureShift(night: true),
          fixturePolicy(),
          baseline.add(const Duration(hours: 22, minutes: 5)),
          'UTC',
        ),
      );
      expect(r.date, baseline);
      expect(r.end, baseline.add(const Duration(days: 1, hours: 7)));
    });
    test(
      'overnight morning date',
      () => expect(
        unwrap(
          resolver.resolve(
            fixtureShift(night: true),
            fixturePolicy(),
            baseline.add(const Duration(days: 1, hours: 7)),
            'UTC',
          ),
        ).date,
        baseline,
      ),
    );
    test(
      'company offset differs from device',
      () => expect(
        unwrap(
          resolver.resolve(
            fixtureShift(),
            fixturePolicy(),
            baseline.subtract(const Duration(hours: 2)),
            'Asia/Dubai',
          ),
        ).date,
        baseline,
      ),
    );
    test(
      'unknown DST zone fails safely',
      () => failure(
        resolver.resolve(
          fixtureShift(),
          fixturePolicy(),
          baseline,
          'America/New_York',
        ),
        AttendanceFailureCode.unsupportedTimezone,
      ),
    );
  });
  group('location', () {
    const validator = AttendanceLocationValidator();
    final now = baseline.add(const Duration(hours: 9));
    final s = fixtureSnapshot(
      policy: fixturePolicy().copyWith(
        requireLocation: true,
        requireLocationOnPunchIn: true,
        requireLocationAccuracy: true,
        maximumAcceptedAccuracyMeters: 50,
      ),
      location: fixtureLocation(),
    );
    test(
      'no location required',
      () => expect(
        validator
            .validate(fixtureSnapshot(), AttendanceEventType.punchIn, null, now)
            .validation
            .state,
        AttendanceLocationState.notRequired,
      ),
    );
    test(
      'missing evidence',
      () => expect(
        validator.validate(s, AttendanceEventType.punchIn, null, now).failure,
        AttendanceFailureCode.locationRequired,
      ),
    );
    test(
      'inside',
      () => expect(
        validator
            .validate(s, AttendanceEventType.punchIn, evidence(), now)
            .validation
            .state,
        AttendanceLocationState.insideAllowedArea,
      ),
    );
    test('exact radius', () {
      final d = AttendanceLocationValidator.distanceMeters(0, 0, 0, .001);
      expect(
        validator
            .validate(
              s.copyWith(workLocation: fixtureLocation(radius: d)),
              AttendanceEventType.punchIn,
              evidence(lon: .001),
              now,
            )
            .failure,
        null,
      );
    });
    test(
      'outside blocked',
      () => expect(
        validator
            .validate(s, AttendanceEventType.punchIn, evidence(lon: 1), now)
            .failure,
        AttendanceFailureCode.outsideAllowedLocation,
      ),
    );
    test(
      'outside allowed',
      () => expect(
        validator
            .validate(
              s.copyWith(policy: s.policy.copyWith(allowOutsideLocation: true)),
              AttendanceEventType.punchIn,
              evidence(lon: 1),
              now,
            )
            .validation
            .state,
        AttendanceLocationState.outsideAllowedAreaAllowed,
      ),
    );
    test(
      'accuracy inclusive',
      () => expect(
        validator
            .validate(
              s,
              AttendanceEventType.punchIn,
              evidence(accuracy: 50),
              now,
            )
            .failure,
        null,
      ),
    );
    test(
      'accuracy rejected',
      () => expect(
        validator
            .validate(
              s,
              AttendanceEventType.punchIn,
              evidence(accuracy: 120),
              now,
            )
            .failure,
        AttendanceFailureCode.locationAccuracyTooLow,
      ),
    );
    test(
      'stale evidence',
      () => expect(
        validator
            .validate(
              s,
              AttendanceEventType.punchIn,
              evidence(captured: baseline),
              now,
            )
            .failure,
        AttendanceFailureCode.staleLocationEvidence,
      ),
    );
    test(
      'invalid coordinates',
      () => expect(
        validator
            .validate(
              s,
              AttendanceEventType.punchIn,
              evidence(lat: double.nan),
              now,
            )
            .failure,
        AttendanceFailureCode.invalidLocationEvidence,
      ),
    );
    test(
      'unavailable',
      () => expect(
        validator
            .validate(
              s,
              AttendanceEventType.punchIn,
              evidence().copyWith(
                permissionState: AttendancePermissionState.unavailable,
              ),
              now,
            )
            .failure,
        AttendanceFailureCode.locationUnavailable,
      ),
    );
    test(
      'remote keeps capture and accuracy',
      () => expect(
        validator
            .validate(
              s.copyWith(
                workMode: AttendanceWorkMode.remote,
                policy: s.policy.copyWith(allowRemoteAttendance: true),
                workLocation: null,
              ),
              AttendanceEventType.punchIn,
              evidence(lon: 1),
              now,
            )
            .validation
            .state,
        AttendanceLocationState.remoteAllowed,
      ),
    );
    test(
      'location mode cannot disable capture',
      () => expect(
        validator
            .validate(
              s.copyWith(
                workLocation: fixtureLocation().copyWith(
                  validationMode: LocationValidationMode.none,
                ),
              ),
              AttendanceEventType.punchIn,
              null,
              now,
            )
            .failure,
        AttendanceFailureCode.locationRequired,
      ),
    );
    for (final action in AttendanceEventType.values) {
      test('per action requirement $action', () {
        final p = s.policy.copyWith(
          requireLocationOnPunchIn: true,
          requireLocationOnPunchOut: false,
          requireLocationOnBreak: true,
        );
        expect(
          const AttendanceLocationRequirementResolver().requiresLocation(
            p,
            action,
          ),
          action != AttendanceEventType.punchOut,
        );
      });
    }
  });
  integrationTests();
}

void integrationTests() {
  group('local repository and workflows', () {
    late AppDatabase db;
    late FakeClock clock;
    late MockAuth auth;
    late AuthContext self;
    late LocalAttendanceRepository repo;
    late AttendanceContextResolver resolver;
    late MockCapture capture;
    late ExecuteAttendanceAction execute;
    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      await seedEmployees(db);
      await seedAttendanceConfiguration(db);
      self = employeeContext(DemoScenario.employee);
      clock = FakeClock(baseline.add(const Duration(hours: 5))); // 09:00 Dubai
      auth = MockAuth();
      when(() => auth.checkSession()).thenAnswer((_) async => Success(self));
      when(() => auth.sessionChanges).thenAnswer((_) => const Stream.empty());
      await db.customStatement(
        "UPDATE workforce_employees SET shift_id='shift-general',attendance_policy_id='policy-remote',work_location_id='location-hyderabad' WHERE id='employee-employee'",
      );
      final employees = LocalEmployeeRepository(
        EmployeeDao(db),
        LocalAccountProvisioningRepository(db),
      );
      resolver = AttendanceContextResolver(
        employees,
        const ShiftWorkdayResolver(FixedOffsetCompanyTimeService()),
      );
      repo = LocalAttendanceRepository(
        AttendanceLocalDataSource(db),
        auth,
        resolver,
        clock,
        const UnconfiguredAttendanceRemote(),
      );
      capture = MockCapture();
      execute = ExecuteAttendanceAction(
        repo,
        capture,
        clock,
        AttendanceEventSource.mobile,
      );
    });
    tearDown(() async {
      await db.close();
    });
    Future<AttendanceMutationResult> action(
      AttendanceEventType type,
      int minutes,
    ) async {
      clock.time = baseline.add(Duration(hours: 5, minutes: minutes));
      return unwrap(await execute(type));
    }

    blocTest<AttendanceBloc, AttendanceBlocState>(
      'initial ready state exposes engine actions and empty summary',
      build: () => AttendanceBloc(repo, execute),
      act: (bloc) => bloc.add(const AttendanceStarted()),
      wait: const Duration(milliseconds: 80),
      expect: () => [
        predicate<AttendanceBlocState>(
          (s) => s.contextStatus == AttendanceContextStatus.loading,
        ),
        predicate<AttendanceBlocState>(
          (s) =>
              s.contextStatus == AttendanceContextStatus.ready &&
              s.currentDay == null &&
              s.actions!.canPunchIn &&
              !s.actions!.canPunchOut &&
              s.summary!.workDuration == Duration.zero,
        ),
      ],
    );
    blocTest<AttendanceBloc, AttendanceBlocState>(
      'missing configuration produces typed unavailable state',
      setUp: () async {
        await db.customStatement(
          "UPDATE workforce_employees SET shift_id=NULL WHERE id='employee-employee'",
        );
      },
      build: () => AttendanceBloc(repo, execute),
      act: (bloc) => bloc.add(const AttendanceStarted()),
      wait: const Duration(milliseconds: 80),
      expect: () => [
        predicate<AttendanceBlocState>(
          (s) => s.contextStatus == AttendanceContextStatus.loading,
        ),
        predicate<AttendanceBlocState>(
          (s) =>
              s.contextStatus == AttendanceContextStatus.unavailable &&
              s.context == null &&
              s.failure?.code == 'shiftNotAssigned',
        ),
      ],
    );
    test('full multiple break day atomic caches and outbox', () async {
      await action(AttendanceEventType.punchIn, 0);
      await action(AttendanceEventType.breakStart, 120);
      await action(AttendanceEventType.breakEnd, 135);
      await action(AttendanceEventType.breakStart, 180);
      await action(AttendanceEventType.breakEnd, 190);
      final end = await action(AttendanceEventType.punchOut, 540);
      expect(end.day.state, AttendanceWorkdayState.completed);
      expect(
        end.day.workMilliseconds,
        const Duration(minutes: 515).inMilliseconds,
      );
      expect((await db.select(db.attendanceEvents).get()).length, 6);
      expect((await db.select(db.syncOutbox).get()).length, 6);
      verifyNever(() => capture.capture());
    });
    test('duplicate request rejected, retry keeps event and request', () async {
      final first = await action(AttendanceEventType.punchIn, 0);
      final command = AttendanceCommand(
        type: AttendanceEventType.punchIn,
        requestId: first.event.requestId,
        expectedUserId: self.user.id,
        deviceTimestamp: clock.now(),
        source: AttendanceEventSource.mobile,
      );
      failure(
        await repo.execute(command),
        AttendanceFailureCode.duplicateRequestId,
      );
      unwrap(await repo.retryPendingOperation(first.event.requestId));
      expect(
        (await db.select(db.attendanceEvents).get()).single.requestId,
        first.event.requestId,
      );
      expect(
        (await db.select(db.syncOutbox).get()).single.requestId,
        first.event.requestId,
      );
    });
    test('pending survives repository reload', () async {
      final first = await action(AttendanceEventType.punchIn, 0);
      final reloaded = LocalAttendanceRepository(
        AttendanceLocalDataSource(db),
        auth,
        resolver,
        clock,
        const UnconfiguredAttendanceRemote(),
      );
      expect(
        unwrap(await reloaded.getCurrentAttendance()).day!.id,
        first.day.id,
      );
      expect(
        unwrap(await reloaded.getCurrentAttendance()).day!.syncStatus,
        AttendanceSyncStatus.pending,
      );
    });
    test('midday config and assignment changes frozen', () async {
      final first = await action(AttendanceEventType.punchIn, 0);
      await db.customStatement(
        "UPDATE shift_records SET start_minutes=720,end_minutes=1200 WHERE id='shift-general'",
      );
      await db.customStatement(
        "UPDATE attendance_policy_records SET track_breaks=0 WHERE id='policy-remote'",
      );
      await db.customStatement(
        "UPDATE work_location_records SET allowed_radius_meters=5000 WHERE id='location-hyderabad'",
      );
      await db.customStatement(
        "UPDATE workforce_employees SET shift_id=NULL,attendance_policy_id=NULL,work_location_id=NULL WHERE id='employee-employee'",
      );
      final breakResult = await action(AttendanceEventType.breakStart, 120);
      expect(breakResult.day.snapshot, first.day.snapshot);
      expect(breakResult.day.snapshot.workLocation!.allowedRadiusMeters, 150);
    });
    test('inactive assigned configs remain usable', () async {
      for (final table in [
        'shift_records',
        'attendance_policy_records',
        'work_location_records',
      ]) {
        await db.customStatement("UPDATE $table SET status='inactive'");
      }
      expect(
        unwrap(await execute(AttendanceEventType.punchIn)).day.state,
        AttendanceWorkdayState.working,
      );
    });
    for (final pair in [
      ('shift_id', AttendanceFailureCode.shiftNotAssigned),
      ('attendance_policy_id', AttendanceFailureCode.policyNotAssigned),
    ]) {
      test('missing ${pair.$1}', () async {
        await db.customStatement(
          "UPDATE workforce_employees SET ${pair.$1}=NULL WHERE id='employee-employee'",
        );
        failure(await repo.getCurrentAttendance(), pair.$2);
      });
    }
    test('required location missing', () async {
      await db.customStatement(
        "UPDATE workforce_employees SET attendance_policy_id='policy-office',work_location_id=NULL WHERE id='employee-employee'",
      );
      failure(
        await repo.getCurrentAttendance(),
        AttendanceFailureCode.workLocationRequiredButMissing,
      );
    });
    test('no employee linked', () async {
      self = self.copyWith(employeeReference: null);
      failure(
        await repo.getCurrentAttendance(),
        AttendanceFailureCode.notLinkedToEmployee,
      );
    });
    test('employee inactive', () async {
      await db.customStatement(
        "UPDATE workforce_employees SET status='inactive' WHERE id='employee-employee'",
      );
      failure(
        await execute(AttendanceEventType.punchIn),
        AttendanceFailureCode.employeeInactive,
      );
    });
    test('account inactive', () async {
      self = self.copyWith(
        user: self.user.copyWith(status: AccountStatus.inactive),
      );
      failure(
        await repo.getCurrentAttendance(),
        AttendanceFailureCode.accountInactive,
      );
    });
    test('company isolation', () async {
      self = self.copyWith(company: self.company.copyWith(id: 'other'));
      failure(
        await repo.getCurrentAttendance(),
        AttendanceFailureCode.companyUnavailable,
      );
    });
    test('employee isolation even forged relationship', () async {
      self = self.copyWith(
        employeeReference: self.employeeReference!.copyWith(
          id: 'employee-manager',
        ),
      );
      failure(
        await repo.getCurrentAttendance(),
        AttendanceFailureCode.notLinkedToEmployee,
      );
    });
    for (final pair in [
      (AttendanceEventType.punchIn, AppPermission.attendancePunchIn),
      (AttendanceEventType.punchOut, AppPermission.attendancePunchOut),
      (AttendanceEventType.breakStart, AppPermission.attendanceBreak),
    ]) {
      test('permission ${pair.$2}', () async {
        if (pair.$1 != AttendanceEventType.punchIn) {
          await action(AttendanceEventType.punchIn, 0);
        }
        self = self.copyWith(
          user: self.user.copyWith(
            permissions: PermissionSet(
              self.user.permissions.values.where((p) => p != pair.$2),
            ),
          ),
        );
        failure(await execute(pair.$1), AttendanceFailureCode.permissionDenied);
      });
    }
    test('offline not allowed rejects without write', () async {
      await db.customStatement(
        "UPDATE attendance_policy_records SET offline_mode='notAllowed' WHERE id='policy-remote'",
      );
      failure(
        await execute(AttendanceEventType.punchIn),
        AttendanceFailureCode.offlineAttendanceNotAllowed,
      );
      expect(await db.select(db.attendanceDays).get(), isEmpty);
    });
    test('offline warning persists pending', () async {
      await db.customStatement(
        "UPDATE attendance_policy_records SET offline_mode='allowWithWarning' WHERE id='policy-remote'",
      );
      expect(
        unwrap(await execute(AttendanceEventType.punchIn)).decision.warnings,
        contains(AttendanceWarningCode.offlinePending),
      );
    });
    test('demo authority no internet/no outbox', () async {
      repo = LocalAttendanceRepository(
        AttendanceLocalDataSource(db),
        auth,
        resolver,
        clock,
        const UnconfiguredAttendanceRemote(),
        authority: AttendanceAuthority.demoLocal,
      );
      execute = ExecuteAttendanceAction(
        repo,
        capture,
        clock,
        AttendanceEventSource.mobile,
      );
      await db.customStatement(
        "UPDATE attendance_policy_records SET offline_mode='notAllowed' WHERE id='policy-remote'",
      );
      expect(
        unwrap(await execute(AttendanceEventType.punchIn)).day.syncStatus,
        AttendanceSyncStatus.synced,
      );
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    });
    test('overnight punch out after end remains same workday', () async {
      await db.customStatement(
        "UPDATE workforce_employees SET shift_id='shift-night' WHERE id='employee-employee'",
      );
      clock.time = baseline.add(const Duration(hours: 18, minutes: 5));
      final first = unwrap(await execute(AttendanceEventType.punchIn));
      clock.time = baseline.add(const Duration(days: 1, hours: 3, minutes: 1));
      final last = unwrap(await execute(AttendanceEventType.punchOut));
      expect(last.day.id, first.day.id);
      expect(last.day.attendanceDate, baseline);
      expect(
        last.day.elapsedMilliseconds,
        const Duration(hours: 8, minutes: 56).inMilliseconds,
      );
    });
    test('non-working default blocks', () async {
      clock.time = DateTime.utc(2026, 9, 19, 5);
      failure(
        await execute(AttendanceEventType.punchIn),
        AttendanceFailureCode.unscheduledDay,
      );
    });
    test('punch out during break composite closes break', () async {
      await db.customStatement(
        "UPDATE attendance_policy_records SET allow_punch_out_during_break=1,allow_early_punch_out=1 WHERE id='policy-remote'",
      );
      await action(AttendanceEventType.punchIn, 0);
      await action(AttendanceEventType.breakStart, 120);
      final end = await action(AttendanceEventType.punchOut, 180);
      final c = unwrap(await repo.getCurrentAttendance()),
          s = unwrap(const AttendanceEngine().calculateSummary(c));
      expect(s.breaks.single.isOpen, false);
      expect(s.breakDuration.inMinutes, 60);
      expect(end.day.state, AttendanceWorkdayState.completed);
    });
    test('outbox failure rolls back day and event', () async {
      await db.customStatement(
        "CREATE TRIGGER reject_attendance BEFORE INSERT ON sync_outbox WHEN NEW.module_id='attendance' BEGIN SELECT RAISE(ABORT,'test'); END",
      );
      failure(
        await execute(AttendanceEventType.punchIn),
        AttendanceFailureCode.persistenceFailure,
      );
      expect(await db.select(db.attendanceDays).get(), isEmpty);
      expect(await db.select(db.attendanceEvents).get(), isEmpty);
    });
    test('generic ack cannot bypass attendance confirmation', () async {
      final first = await action(AttendanceEventType.punchIn, 0);
      expect(
        await LocalOutboxRepository(
          OutboxLocalDataSource(db),
        ).acknowledge(first.event.requestId),
        isA<Failed<void>>(),
      );
      expect((await db.select(db.syncOutbox).get()).length, 1);
    });
    test('server confirmation recalculates summary', () async {
      final first = await action(AttendanceEventType.punchIn, 0);
      clock.time = baseline.add(const Duration(hours: 6));
      final sender = TestSender(
        (e) async => Success(
          AttendanceRemoteConfirmation(
            requestId: e.requestId,
            accepted: true,
            serverTimestamp: e.deviceTimestamp.add(const Duration(minutes: 1)),
          ),
        ),
      );
      unwrap(
        await AttendanceSyncHandler(
          AttendanceLocalDataSource(db),
          auth,
          sender,
          clock,
        ).synchronize(),
      );
      final c = unwrap(await repo.getCurrentAttendance());
      expect(c.day!.syncStatus, AttendanceSyncStatus.synced);
      expect(
        c.events.single.serverTimestamp,
        first.event.deviceTimestamp.add(const Duration(minutes: 1)),
      );
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    });
    test('transport failure and retry reuse UUID', () async {
      final first = await action(AttendanceEventType.punchIn, 0);
      final ids = <String>[];
      final sender = TestSender((e) async {
        ids.add(e.requestId);
        return const Failed(
          Failure(code: 'timeout', kind: FailureKind.timeout),
        );
      });
      final handler = AttendanceSyncHandler(
        AttendanceLocalDataSource(db),
        auth,
        sender,
        clock,
      );
      expect(await handler.synchronize(), isA<Failed<void>>());
      expect(
        unwrap(await repo.getCurrentAttendance()).day!.syncStatus,
        AttendanceSyncStatus.failed,
      );
      unwrap(await repo.retryPendingOperation(first.event.requestId));
      await handler.synchronize();
      expect(ids, [first.event.requestId, first.event.requestId]);
      expect((await db.select(db.attendanceEvents).get()).length, 1);
    });
    test('rejection preserved cannot silently retry', () async {
      final first = await action(AttendanceEventType.punchIn, 0);
      final sender = TestSender(
        (e) async => Success(
          AttendanceRemoteConfirmation(
            requestId: e.requestId,
            accepted: false,
            rejectionCode: 'outsideAllowedLocation',
          ),
        ),
      );
      await AttendanceSyncHandler(
        AttendanceLocalDataSource(db),
        auth,
        sender,
        clock,
      ).synchronize();
      expect(
        unwrap(await repo.getCurrentAttendance()).day!.syncStatus,
        AttendanceSyncStatus.rejected,
      );
      failure(
        await repo.retryPendingOperation(first.event.requestId),
        AttendanceFailureCode.invalidAttendanceState,
      );
    });
    test(
      'transient failure schedules retry with the same request id',
      () async {
        final first = await action(AttendanceEventType.punchIn, 0);
        final sender = TestSender(
          (e) async =>
              const Failed(Failure(code: 'timeout', kind: FailureKind.timeout)),
        );
        expect(
          await AttendanceSyncHandler(
            AttendanceLocalDataSource(db),
            auth,
            sender,
            clock,
          ).synchronize(),
          isA<Failed<void>>(),
        );
        final row = (await db.select(db.syncOutbox).get()).single;
        expect(row.status, 'retryScheduled');
        expect(row.nextAttemptAt, isNotNull);
        expect(row.requestId, first.event.requestId);
        expect(row.attempts, 1);
      },
    );
    test('stale processing operation recovers on the next run', () async {
      final first = await action(AttendanceEventType.punchIn, 0);
      await (db.update(
        db.syncOutbox,
      )..where((t) => t.id.equals(first.event.requestId))).write(
        SyncOutboxCompanion(
          status: const Value('processing'),
          processingStartedAt: Value(
            clock.now().subtract(const Duration(hours: 1)),
          ),
        ),
      );
      final sender = TestSender(
        (e) async => Success(
          AttendanceRemoteConfirmation(
            requestId: e.requestId,
            accepted: true,
            serverTimestamp: e.deviceTimestamp,
          ),
        ),
      );
      expect(
        await AttendanceSyncHandler(
          AttendanceLocalDataSource(db),
          auth,
          sender,
          clock,
        ).synchronize(),
        isA<Success<void>>(),
      );
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    });
    test('reactive watcher changes and cancellation', () async {
      final values = <Result<AttendanceContext>>[];
      final sub = repo.watchCurrentAttendance().listen(values.add);
      await until(() => values.isNotEmpty);
      await action(AttendanceEventType.punchIn, 0);
      await until(
        () => values.any(
          (r) => r is Success<AttendanceContext> && r.value.day != null,
        ),
      );
      await sub.cancel();
    });
    test('bloc load and all workflows retain ready data', () async {
      final bloc = AttendanceBloc(repo, execute);
      final states = <AttendanceBlocState>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(const AttendanceStarted());
      await until(
        () => bloc.state.contextStatus == AttendanceContextStatus.ready,
      );
      bloc.add(const PunchInRequested());
      await until(
        () => bloc.state.currentDay?.state == AttendanceWorkdayState.working,
      );
      clock.time = baseline.add(const Duration(hours: 7));
      bloc.add(const BreakStartRequested());
      await until(
        () => bloc.state.currentDay?.state == AttendanceWorkdayState.onBreak,
      );
      clock.time = baseline.add(const Duration(hours: 7, minutes: 15));
      bloc.add(const BreakEndRequested());
      await until(
        () =>
            bloc.state.currentDay?.state == AttendanceWorkdayState.working &&
            bloc.state.context!.events.length == 3,
      );
      clock.time = baseline.add(const Duration(hours: 14));
      bloc.add(const PunchOutRequested());
      await until(
        () => bloc.state.currentDay?.state == AttendanceWorkdayState.completed,
      );
      expect(
        states
            .where((s) => s.actionStatus == AttendanceActionStatus.submitting)
            .every((s) => s.context != null),
        true,
      );
      await sub.cancel();
      await bloc.close();
    });
    test('bloc failure keeps ready data, double tap blocked', () async {
      final bloc = AttendanceBloc(repo, execute);
      bloc.add(const AttendanceStarted());
      await until(
        () => bloc.state.contextStatus == AttendanceContextStatus.ready,
      );
      bloc.add(const PunchOutRequested());
      await until(
        () => bloc.state.actionStatus == AttendanceActionStatus.failed,
      );
      expect(bloc.state.context, isNotNull);
      bloc.add(const PunchInRequested());
      bloc.add(const PunchInRequested());
      await until(() => bloc.state.currentDay != null);
      expect((await db.select(db.attendanceEvents).get()).length, 1);
      await bloc.close();
    });
    test('persisted timestamp precision and returned event agree', () async {
      clock.time = clock.time.add(const Duration(microseconds: 123));
      final first = unwrap(await execute(AttendanceEventType.punchIn));
      final loaded = unwrap(await repo.getCurrentAttendance());
      expect(loaded.events.single, first.event);
      expect(loaded.day, first.day);
      expect(first.event.deviceTimestamp.microsecond, 0);
    });
    test(
      'date query and event stream cannot bypass self relationship',
      () async {
        final first = await action(AttendanceEventType.punchIn, 0);
        self = self.copyWith(
          employeeReference: self.employeeReference!.copyWith(
            id: 'employee-manager',
          ),
        );
        failure(
          await repo.getAttendanceForDate(baseline),
          AttendanceFailureCode.notLinkedToEmployee,
        );
        failure(
          await repo.watchAttendanceEvents(first.day.id).first,
          AttendanceFailureCode.notLinkedToEmployee,
        );
      },
    );
    test(
      'events remain readable from frozen day after future assignment removed',
      () async {
        final first = await action(AttendanceEventType.punchIn, 0);
        await action(AttendanceEventType.punchOut, 540);
        await db.customStatement(
          "UPDATE workforce_employees SET shift_id=NULL,attendance_policy_id=NULL WHERE id='employee-employee'",
        );
        expect(
          unwrap(await repo.watchAttendanceEvents(first.day.id).first).length,
          2,
        );
      },
    );
    test('GPS only for configured action and location failure typed', () async {
      await db.customStatement(
        "UPDATE workforce_employees SET attendance_policy_id='policy-office' WHERE id='employee-employee'",
      );
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
      final first = unwrap(await execute(AttendanceEventType.punchIn));
      expect(
        first.event.locationValidation.state,
        AttendanceLocationState.insideAllowedArea,
      );
      verify(() => capture.capture()).called(1);
      clock.time = baseline.add(const Duration(hours: 7));
      when(() => capture.capture()).thenAnswer(
        (_) async => const Failed(
          Failure(
            code: 'locationPermissionDenied',
            kind: FailureKind.locationPermission,
          ),
        ),
      );
      failure(
        await execute(AttendanceEventType.breakStart),
        AttendanceFailureCode.locationPermissionDenied,
      );
      expect((await db.select(db.attendanceEvents).get()).length, 1);
    });
    test('session changes during GPS cannot punch for another user', () async {
      await db.customStatement(
        "UPDATE workforce_employees SET attendance_policy_id='policy-office' WHERE id='employee-employee'",
      );
      when(() => capture.capture()).thenAnswer((_) async {
        self = employeeContext(DemoScenario.manager);
        return Success(
          AttendanceLocationEvidence(
            latitude: 17.385044,
            longitude: 78.486671,
            accuracyMeters: 10,
            capturedAt: clock.now(),
          ),
        );
      });
      failure(
        await execute(AttendanceEventType.punchIn),
        AttendanceFailureCode.permissionDenied,
      );
      expect(await db.select(db.attendanceEvents).get(), isEmpty);
    });
    test(
      'outbox schema constraints prevent duplicate request outside bloc',
      () async {
        final first = await action(AttendanceEventType.punchIn, 0);
        expect(
          () => db
              .into(db.attendanceEvents)
              .insert(
                AttendanceEventsCompanion.insert(
                  id: 'duplicate',
                  attendanceDayId: first.day.id,
                  companyId: first.day.companyId,
                  employeeId: first.day.employeeId,
                  eventType: 'punchIn',
                  deviceMilliseconds: clock.now().millisecondsSinceEpoch,
                  effectiveMilliseconds: clock.now().millisecondsSinceEpoch,
                  sequence: 99,
                  locationValidation: '{}',
                  requestId: first.event.requestId,
                  source: 'mobile',
                  syncStatus: 'pending',
                  createdMilliseconds: clock.now().millisecondsSinceEpoch,
                ),
              ),
          throwsA(anything),
        );
      },
    );
    test('invalid server timeline rolls back confirmation', () async {
      final first = await action(AttendanceEventType.punchIn, 0);
      await action(AttendanceEventType.breakStart, 10);
      final sender = TestSender(
        (e) async => Success(
          AttendanceRemoteConfirmation(
            requestId: e.requestId,
            accepted: true,
            serverTimestamp: e.deviceTimestamp.add(const Duration(hours: 1)),
          ),
        ),
      );
      expect(
        await AttendanceSyncHandler(
          AttendanceLocalDataSource(db),
          auth,
          sender,
          clock,
        ).synchronize(),
        isA<Failed<void>>(),
      );
      final row = (await db.select(db.attendanceEvents).get()).first;
      expect(row.serverMilliseconds, isNull);
      expect(
        (await db.select(db.syncOutbox).get()).any(
          (r) => r.requestId == first.event.requestId,
        ),
        true,
      );
    });
    test('bloc external repository changes update ready data', () async {
      final bloc = AttendanceBloc(repo, execute);
      bloc.add(const AttendanceStarted());
      await until(
        () => bloc.state.contextStatus == AttendanceContextStatus.ready,
      );
      await action(AttendanceEventType.punchIn, 0);
      await until(() => bloc.state.currentDay != null);
      expect(bloc.state.actions!.canStartBreak, true);
      await bloc.close();
    });
    test('bloc configuration failure and offline warning', () async {
      await db.customStatement(
        "UPDATE attendance_policy_records SET offline_mode='allowWithWarning' WHERE id='policy-remote'",
      );
      final bloc = AttendanceBloc(repo, execute);
      bloc.add(const AttendanceStarted());
      await until(
        () => bloc.state.contextStatus == AttendanceContextStatus.ready,
      );
      bloc.add(const PunchInRequested());
      await until(() => bloc.state.currentDay != null);
      expect(
        bloc.state.warnings,
        contains(AttendanceWarningCode.offlinePending),
      );
      await bloc.close();
    });
    test('migration phase 5 retains all data and outbox', () async {
      await db.close();
      final dir = Directory.systemTemp.createTempSync('erp_attendance_');
      final file = File('${dir.path}/erp.sqlite');
      final old = AppDatabase(NativeDatabase(file));
      await seedEmployees(old);
      await seedAttendanceConfiguration(old);
      await old
          .into(old.syncOutbox)
          .insert(
            SyncOutboxCompanion.insert(
              id: 'retained',
              moduleId: 'employees',
              entityId: 'e',
              operation: 'update',
              payload: '{}',
              createdAt: baseline,
              attempts: const Value(2),
            ),
          );
      await old.customStatement('DROP TABLE attendance_events');
      await old.customStatement('DROP TABLE attendance_days');
      await old.customStatement('DROP TABLE attendance_correction_requests');
      await old.customStatement('DROP INDEX outbox_request');
      await old.customStatement('DROP INDEX IF EXISTS outbox_status_next');
      await old.customStatement('DROP INDEX IF EXISTS outbox_company_status');
      for (final c in [
        'company_id',
        'request_id',
        'status',
        'last_attempt_at',
        'failure_code',
      ]) {
        await old.customStatement('ALTER TABLE sync_outbox DROP COLUMN $c');
      }
      await old.customStatement('PRAGMA user_version=3');
      await old.close();
      final migrated = AppDatabase(NativeDatabase(file));
      expect(
        (await migrated.select(migrated.workforceEmployees).get()).length,
        25,
      );
      expect((await migrated.select(migrated.shiftRecords).get()).length, 4);
      expect(
        (await migrated.select(migrated.attendancePolicyRecords).get()).length,
        3,
      );
      expect(
        (await migrated.select(migrated.syncOutbox).get()).single.attempts,
        2,
      );
      expect(await migrated.select(migrated.attendanceEvents).get(), isEmpty);
      await migrated.close();
      file.deleteSync();
      dir.deleteSync();
    });
  });
}
