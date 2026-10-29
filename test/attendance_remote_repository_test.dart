import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_engine.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_history.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_repository.dart';
import 'package:modular_erp/modules/hr/attendance/live/data/attendance_mapper.dart';
import 'package:modular_erp/modules/hr/attendance/live/data/remote_attendance_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

import 'support/attendance_test_doubles.dart';

class FixedClock implements AppClock {
  const FixedClock(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
}

final DateTime testNow = DateTime.utc(2026, 10, 28, 12);
const mapper = RemoteAttendanceMapper();

RemoteAttendanceSnapshot mapFixture(
  String name, {
  AuthContext? auth,
  DateTime? now,
}) {
  final result = mapper.map(
    today: attendanceDayFixture(name),
    auth: auth ?? attendanceAuth(),
    now: now ?? testNow,
  );
  expect(result, isA<Success<RemoteAttendanceSnapshot>>(), reason: name);
  return (result as Success<RemoteAttendanceSnapshot>).value;
}

RemoteAttendanceSnapshot mapData(
  Map<String, dynamic> data, {
  AuthContext? auth,
  DateTime? now,
}) {
  final result = mapper.map(
    today: attendanceDayFrom(data),
    auth: auth ?? attendanceAuth(),
    now: now ?? testNow,
  );
  expect(result, isA<Success<RemoteAttendanceSnapshot>>());
  return (result as Success<RemoteAttendanceSnapshot>).value;
}

Map<String, dynamic> workingData() =>
    (loadAttendanceFixture('today_working.json')['data'] as Map)
        .cast<String, dynamic>();

AttendanceCommand command(
  AttendanceEventType type, {
  AttendanceLocationEvidence? evidence,
}) => AttendanceCommand(
  type: type,
  requestId: '00000000-0000-4000-8000-000000000001',
  expectedUserId: '5',
  expectedCompanyId: '3',
  expectedEmployeeId: '29',
  expectedWorkday: DateTime.utc(2026, 10, 28),
  expectedDayId: 'remote-29-2026-10-28',
  deviceTimestamp: testNow,
  source: AttendanceEventSource.mobile,
  locationEvidence: evidence,
);

AttendanceLocationEvidence evidence() => AttendanceLocationEvidence(
  latitude: 25.20485,
  longitude: 55.27078,
  accuracyMeters: 10,
  capturedAt: testNow,
);

RemoteAttendanceRepository repository(
  FakeAttendanceApi api, {
  AuthContext? auth,
}) => RemoteAttendanceRepository(
  api,
  FakeAttendanceAuth(auth ?? attendanceAuth()),
  clock: FixedClock(testNow),
);

void main() {
  group('today state mapping', () {
    test('working maps to working with events and allowed actions', () {
      final snapshot = mapFixture('today_working.json');
      expect(snapshot.context.day?.state, AttendanceWorkdayState.working);
      expect(snapshot.context.events, isNotEmpty);
      expect(snapshot.allowedActions, {
        AttendanceEventType.breakStart,
        AttendanceEventType.punchOut,
      });
      final summary = const AttendanceEngine().calculateSummary(
        snapshot.context,
      );
      expect(
        (summary as Success<AttendanceSummary>).value.currentState,
        AttendanceWorkdayState.working,
      );
    });

    test('completed maps to completed with a real punch-out', () {
      final snapshot = mapFixture('today_completed.json');
      expect(snapshot.context.day?.state, AttendanceWorkdayState.completed);
      expect(snapshot.context.day?.punchOutAt, isNotNull);
      expect(snapshot.allowedActions, isEmpty);
    });

    test('noShift is notStarted with an empty context', () {
      final auth = attendanceAuth(employeeId: '1');
      final snapshot = mapFixture('today_no_shift.json', auth: auth);
      expect(
        snapshot.context.day,
        isNull,
        reason: 'no attendance record exists',
      );
      expect(snapshot.context.events, isEmpty);
      expect(snapshot.allowedActions, isEmpty);
      expect(snapshot.shifts, isEmpty);
      expect(snapshot.currentShift, isNull);
      expect(snapshot.nextShift, isNull);
    });

    test('waitingForShift is notStarted and keeps upcoming shift detail', () {
      final auth = attendanceAuth(
        employeeId: '27',
        timezone: 'America/Chicago',
      );
      final snapshot = mapFixture('today_employee.json', auth: auth);
      expect(snapshot.context.day, isNull);
      expect(snapshot.context.events, isEmpty);
      expect(snapshot.allowedActions, isEmpty);
      expect(snapshot.shifts, hasLength(2));
      expect(snapshot.currentShift, isNull);
      expect(snapshot.nextShift?.shiftNo, 2);
      expect(snapshot.nextShift?.plannedStart, '23:00:00');
      expect(snapshot.nextShift?.crossesMidnight, isTrue);
    });

    test('administrator noShift is notStarted', () {
      final snapshot = mapFixture(
        'today_admin.json',
        auth: attendanceAuth(employeeId: '1'),
      );
      expect(snapshot.context.day, isNull);
      expect(snapshot.allowedActions, isEmpty);
    });

    test('readyToPunchIn maps to notStarted with punch-in allowed', () {
      final snapshot = mapData({
        ...workingData(),
        'state': 'readyToPunchIn',
        'allowedActions': ['punchIn'],
        'shifts': <dynamic>[],
        'workedMinutes': 0,
        'workedHours': 0,
        'breakMinutes': 0,
      });
      expect(snapshot.context.day, isNull);
      expect(snapshot.allowedActions, {AttendanceEventType.punchIn});
      final actions = const AttendanceEngine().getAvailableActions(
        snapshot.context,
      );
      expect(actions.canPunchIn, isTrue);
      expect(actions.canStartBreak, isFalse);
    });

    test('onBreak maps an open break and summary state', () {
      final snapshot = mapData({
        'employeeId': 29,
        'date': '2026-10-28',
        'timeZone': 'Asia/Dubai',
        'state': 'onBreak',
        'allowedActions': ['resume', 'punchOut'],
        'currentShiftNo': 1,
        'nextShiftNo': null,
        'workedMinutes': 120,
        'workedHours': 2,
        'breakMinutes': 0,
        'serverTime': '2026-10-28T11:27:08+05:30',
        'shifts': [
          {
            'shiftNo': 1,
            'shiftName': 'Shift 1',
            'shiftDate': '2026-10-28',
            'timeZone': 'Asia/Dubai',
            'plannedStart': '09:00:00',
            'plannedEnd': '12:00:00',
            'status': 'working',
            'punchIn': '2026-10-28T09:07:08+05:30',
            'punchOut': null,
            'lateMinutes': 0,
            'workedMinutes': 120,
            'breakMinutes': 0,
            'breaks': [
              {'start': '2026-10-28T10:00:00+05:30', 'end': null, 'minutes': 0},
            ],
          },
        ],
      });
      expect(snapshot.context.day?.state, AttendanceWorkdayState.onBreak);
      expect(snapshot.allowedActions, {
        AttendanceEventType.breakEnd,
        AttendanceEventType.punchOut,
      });
      final summary = const AttendanceEngine().calculateSummary(
        snapshot.context,
      );
      expect(
        (summary as Success<AttendanceSummary>).value.currentState,
        AttendanceWorkdayState.onBreak,
      );
    });

    test('unknown state fails closed instead of inventing a state', () {
      final result = mapper.map(
        today: attendanceDayFrom({...workingData(), 'state': 'teleported'}),
        auth: attendanceAuth(),
        now: testNow,
      );
      expect(result, isA<Failed<RemoteAttendanceSnapshot>>());
      expect(
        (result as Failed<RemoteAttendanceSnapshot>).failure.code,
        AttendanceFailureCode.invalidAttendanceState.name,
      );
    });
  });

  group('allowed actions', () {
    test('omitted actions are not enabled', () {
      final snapshot = mapData({
        ...workingData(),
        'allowedActions': ['punchOut'],
      });
      final actions = const AttendanceEngine().getAvailableActions(
        snapshot.context,
      );
      expect(actions.canPunchOut, isTrue);
      expect(actions.canStartBreak, isFalse);
      expect(actions.canEndBreak, isFalse);
      expect(actions.canPunchIn, isFalse);
    });

    test('unknown action names are ignored', () {
      final snapshot = mapData({
        ...workingData(),
        'allowedActions': ['break', 'teleport'],
      });
      expect(snapshot.allowedActions, {AttendanceEventType.breakStart});
      final actions = const AttendanceEngine().getAvailableActions(
        snapshot.context,
      );
      expect(actions.canStartBreak, isTrue);
      expect(actions.canPunchOut, isFalse);
    });

    test('completed day enables no actions', () {
      final snapshot = mapFixture('today_completed.json');
      final actions = const AttendanceEngine().getAvailableActions(
        snapshot.context,
      );
      expect(actions.canPunchIn, isFalse);
      expect(actions.canPunchOut, isFalse);
      expect(actions.canStartBreak, isFalse);
      expect(actions.canEndBreak, isFalse);
    });
  });

  group('timeline mapping', () {
    test('shifts, punches, breaks and minutes map from the payload', () {
      final snapshot = mapFixture('today_working.json');
      expect(snapshot.shifts, hasLength(2));
      final first = snapshot.shifts.first;
      expect(first.shiftNo, 1);
      expect(first.shiftName, 'Shift 1');
      expect(first.plannedStart, '09:00:00');
      expect(first.plannedEnd, '12:00:00');
      expect(first.status, 'working');
      expect(first.punchIn, isNotNull);
      expect(first.punchOut, isNull);
      expect(first.lateMinutes, 7);
      expect(first.workedMinutes, 120);
      expect(first.breakMinutes, 15);
      expect(first.breaks.single.minutes, 15);
      expect(first.breaks.single.end, isNotNull);
      expect(snapshot.currentShift?.shiftNo, 1);
      expect(snapshot.nextShift?.shiftNo, 2);
      expect(snapshot.workedMinutes, 120);
      expect(snapshot.breakMinutes, 15);
      final second = snapshot.shifts[1];
      expect(second.shiftNo, 2);
      expect(second.plannedStart, '18:45:00');
      expect(second.punchIn, isNull);
    });

    test('completed shift keeps its punch-out and late minutes', () {
      final snapshot = mapFixture('today_completed.json');
      final shift = snapshot.shifts.single;
      expect(shift.punchIn, isNotNull);
      expect(shift.punchOut, isNotNull);
      expect(shift.lateMinutes, 7);
      expect(shift.workedMinutes, 180);
      expect(snapshot.context.day?.punchOutAt, isNotNull);
    });
  });

  group('punch', () {
    test('sends the mapped action and location evidence', () async {
      final api = FakeAttendanceApi()
        ..onPunch = (action, latitude, longitude) async =>
            Success(attendanceDayFixture('today_completed.json'));
      final repo = repository(api);
      final result = await repo.execute(
        command(AttendanceEventType.punchOut, evidence: evidence()),
      );
      expect(result, isA<Success<AttendanceMutationResult>>());
      expect(api.lastAction, 'punchOut');
      expect(api.lastLatitude, 25.20485);
      expect(api.lastLongitude, 55.27078);
      final mutation = (result as Success<AttendanceMutationResult>).value;
      expect(mutation.day.state, AttendanceWorkdayState.completed);
      expect(mutation.event.eventType, AttendanceEventType.punchOut);
    });

    test('maps every event type to the documented action name', () async {
      final cases = <AttendanceEventType, String>{
        AttendanceEventType.punchIn: 'punchIn',
        AttendanceEventType.breakStart: 'break',
        AttendanceEventType.breakEnd: 'resume',
        AttendanceEventType.punchOut: 'punchOut',
      };
      for (final entry in cases.entries) {
        final api = FakeAttendanceApi()
          ..onPunch = (action, latitude, longitude) async => Success(
            attendanceDayFixture(
              entry.key == AttendanceEventType.punchOut
                  ? 'today_completed.json'
                  : 'today_working.json',
            ),
          );
        final result = await repository(
          api,
        ).execute(command(entry.key, evidence: evidence()));
        expect(result, isA<Success<AttendanceMutationResult>>());
        expect(api.lastAction, entry.value);
      }
    });

    test('day complete maps to alreadyCompleted', () async {
      final api = FakeAttendanceApi()
        ..onPunch = (action, latitude, longitude) async => const Failed(
          Failure(code: 'DAY_COMPLETE', kind: FailureKind.conflict),
        );
      final result = await repository(
        api,
      ).execute(command(AttendanceEventType.punchOut));
      expect(result, isA<Failed<AttendanceMutationResult>>());
      expect(
        (result as Failed<AttendanceMutationResult>).failure.code,
        AttendanceFailureCode.alreadyCompleted.name,
      );
    });

    test('no shift maps to shiftNotAssigned', () async {
      final api = FakeAttendanceApi()
        ..onPunch = (action, latitude, longitude) async => const Failed(
          Failure(code: 'ATTENDANCE_NO_SHIFT', kind: FailureKind.conflict),
        );
      final result = await repository(
        api,
      ).execute(command(AttendanceEventType.punchIn));
      expect(
        (result as Failed<AttendanceMutationResult>).failure.code,
        AttendanceFailureCode.shiftNotAssigned.name,
      );
    });

    test('invalid location maps to invalidLocationEvidence', () async {
      final api = FakeAttendanceApi()
        ..onPunch = (action, latitude, longitude) async => const Failed(
          Failure(code: 'INVALID_LOCATION', kind: FailureKind.validation),
        );
      final result = await repository(
        api,
      ).execute(command(AttendanceEventType.punchIn));
      expect(
        (result as Failed<AttendanceMutationResult>).failure.code,
        AttendanceFailureCode.invalidLocationEvidence.name,
      );
    });

    test('unauthorized maps to a session-expired failure', () async {
      final api = FakeAttendanceApi()
        ..onPunch = (action, latitude, longitude) async => const Failed(
          Failure(code: 'AUTH_UNAUTHORIZED', kind: FailureKind.sessionExpired),
        );
      final result = await repository(
        api,
      ).execute(command(AttendanceEventType.punchIn));
      final failure = (result as Failed<AttendanceMutationResult>).failure;
      expect(failure.code, AttendanceFailureCode.permissionDenied.name);
      expect(failure.kind, FailureKind.sessionExpired);
    });
  });

  group('history and unsupported views', () {
    test(
      'history and corrections return empty data without local reads',
      () async {
        final api = FakeAttendanceApi();
        final repo = repository(api);
        final query = AttendanceHistoryQuery(year: 2026, month: 10);
        final history = await repo.getAttendanceHistory(query);
        expect(history, isA<Success<AttendanceHistoryPageData>>());
        final page = (history as Success<AttendanceHistoryPageData>).value;
        expect(page.items, isEmpty);
        expect(page.total, 0);
        expect(await repo.getAttendanceDayById('day'), isA<Success>());
        expect(
          (await repo.getAttendanceDayById('day') as Success).value,
          isNull,
        );
        expect(
          await repo.getAttendanceForDate(DateTime.utc(2026, 10, 1)),
          isA<Success>(),
        );
        expect(
          (await repo.getAttendanceForDate(DateTime.utc(2026, 10, 1))
                  as Success)
              .value,
          isNull,
        );
        final events = await repo.watchAttendanceEvents('day').first;
        expect((events as Success<List<AttendanceEvent>>).value, isEmpty);
        final retry = await repo.retryPendingOperation('op');
        expect(retry, isA<Failed<void>>());
        expect((retry as Failed<void>).failure.code, 'unsupported');
        expect(api.todayCalls, 0);
      },
    );

    test('company attendance date comes from the today payload', () async {
      final api = FakeAttendanceApi()
        ..onToday = () async =>
            Success(attendanceDayFixture('today_no_shift.json'));
      final repo = repository(api, auth: attendanceAuth(employeeId: '1'));
      final result = await repo.getCompanyAttendanceDate();
      expect((result as Success<DateTime>).value, DateTime.utc(2026, 10, 29));
    });

    test('expected identity mismatch fails before any network call', () async {
      final api = FakeAttendanceApi();
      final repo = repository(api);
      final result = await repo.getCurrentAttendance(expectedUserId: 'other');
      expect(result, isA<Failed<AttendanceContext>>());
      expect(
        (result as Failed<AttendanceContext>).failure.code,
        AttendanceFailureCode.permissionDenied.name,
      );
      expect(api.todayCalls, 0);
    });

    test('watchCurrentAttendance emits the mapped context', () async {
      final api = FakeAttendanceApi()
        ..onToday = () async =>
            Success(attendanceDayFixture('today_working.json'));
      final repo = repository(api);
      final result = await repo.watchCurrentAttendance().first;
      expect(result, isA<Success<AttendanceContext>>());
    });
  });
}
