import 'dart:async';

import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_engine.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_history.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_state_machine.dart';
import 'package:modular_erp/modules/hr/attendance/live/data/attendance_api.dart';
import 'package:modular_erp/modules/hr/attendance/live/data/attendance_mapper.dart';
import 'package:modular_erp/modules/hr/attendance/live/domain/attendance_day.dart'
    as live;
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';

/// Backend-mode attendance adapter for the two self-service endpoints:
/// `GET /api/attendance/today` and `POST /api/attendance/punch`.
///
/// History, corrections, requests, team and all-employees views have no
/// backend endpoint. They return the existing empty/unsupported results and
/// never fall back to the local database.
class RemoteAttendanceRepository implements AttendanceRepository {
  RemoteAttendanceRepository(
    this._api,
    this._auth, {
    this.clock = const SystemAppClock(),
    this.mapper = const RemoteAttendanceMapper(),
  });
  final AttendanceApiClient _api;
  final AuthRepository _auth;
  final AppClock clock;
  final RemoteAttendanceMapper mapper;
  final _revision = StreamController<void>.broadcast();

  Future<Result<AuthContext>> _session() async {
    final result = await _auth.checkSession();
    if (result case Failed<AuthContext?>(:final failure)) {
      return Failed(failure);
    }
    final context = (result as Success<AuthContext?>).value;
    if (context == null) {
      return Failed(attendanceFailure(AttendanceFailureCode.accountInactive));
    }
    if (context.user.status != AccountStatus.active) {
      return Failed(attendanceFailure(AttendanceFailureCode.accountInactive));
    }
    if (context.employeeReference == null) {
      return Failed(
        attendanceFailure(AttendanceFailureCode.notLinkedToEmployee),
      );
    }
    return Success(context);
  }

  Future<Result<RemoteAttendanceSnapshot>> _loadToday(
    AuthContext auth,
    DateTime now,
  ) async {
    final result = await _api.today();
    return switch (result) {
      Failed<live.AttendanceDay>(:final failure) => Failed(failure),
      Success<live.AttendanceDay>(:final value) => mapper.map(
        today: value,
        auth: auth,
        now: now,
      ),
    };
  }

  @override
  Future<Result<DateTime>> getCompanyAttendanceDate() async {
    final session = await _session();
    if (session case Failed<AuthContext>(:final failure)) {
      return Failed(failure);
    }
    final result = await _api.today();
    return switch (result) {
      Failed<live.AttendanceDay>(:final failure) => Failed(failure),
      Success<live.AttendanceDay>(:final value) => _date(value),
    };
  }

  Result<DateTime> _date(live.AttendanceDay day) {
    final parsed = DateTime.tryParse(day.date);
    if (parsed == null) {
      return Failed(
        attendanceFailure(AttendanceFailureCode.invalidAttendanceState),
      );
    }
    return Success(DateTime.utc(parsed.year, parsed.month, parsed.day));
  }

  @override
  Future<Result<AttendanceContext>> getCurrentAttendance({
    AttendanceWorkMode workMode = AttendanceWorkMode.office,
    String? expectedUserId,
    String? expectedCompanyId,
  }) async {
    final session = await _session();
    if (session case Failed<AuthContext>(:final failure)) {
      return Failed(failure);
    }
    final auth = (session as Success<AuthContext>).value;
    if ((expectedUserId != null && expectedUserId != auth.user.id) ||
        (expectedCompanyId != null && expectedCompanyId != auth.company.id)) {
      return Failed(attendanceFailure(AttendanceFailureCode.permissionDenied));
    }
    final loaded = await _loadToday(auth, clock.now().toUtc());
    return switch (loaded) {
      Failed<RemoteAttendanceSnapshot>(:final failure) => Failed(failure),
      Success<RemoteAttendanceSnapshot>(:final value) => Success(value.context),
    };
  }

  @override
  Stream<Result<AttendanceContext>> watchCurrentAttendance() {
    late StreamController<Result<AttendanceContext>> controller;
    StreamSubscription<void>? revision;
    void load() {
      getCurrentAttendance().then((result) {
        if (!controller.isClosed) controller.add(result);
      });
    }

    controller = StreamController<Result<AttendanceContext>>(
      onListen: () {
        load();
        revision = _revision.stream.listen((_) => load());
      },
      onCancel: () async {
        await revision?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<Result<AttendanceHistoryPageData>> getAttendanceHistory(
    AttendanceHistoryQuery query,
  ) async => Success(_emptyHistory(query, clock.now().toUtc()));

  @override
  Stream<Result<AttendanceHistoryPageData>> watchAttendanceHistory(
    AttendanceHistoryQuery query,
  ) => Stream.fromFuture(getAttendanceHistory(query));

  @override
  Future<Result<AttendanceDayDetails?>> getAttendanceDayById(
    String dayId,
  ) async => const Success(null);

  @override
  Stream<Result<AttendanceDayDetails?>> watchAttendanceDayById(String dayId) =>
      Stream.value(const Success<AttendanceDayDetails?>(null));

  @override
  Future<Result<AttendanceDay?>> getAttendanceForDate(DateTime date) async =>
      const Success(null);

  @override
  Stream<Result<List<AttendanceEvent>>> watchAttendanceEvents(String dayId) =>
      Stream.value(const Success<List<AttendanceEvent>>(<AttendanceEvent>[]));

  @override
  Future<Result<void>> retryPendingOperation(String operationId) async =>
      const Failed(
        Failure(code: 'unsupported', kind: FailureKind.notConfigured),
      );

  @override
  Future<Result<AttendanceMutationResult>> execute(
    AttendanceCommand command,
  ) async {
    final session = await _session();
    if (session case Failed<AuthContext>(:final failure)) {
      return Failed(failure);
    }
    final auth = (session as Success<AuthContext>).value;
    if (auth.user.id != command.expectedUserId ||
        (command.expectedCompanyId != null &&
            command.expectedCompanyId != auth.company.id) ||
        (command.expectedEmployeeId != null &&
            command.expectedEmployeeId != auth.employeeReference!.id)) {
      return Failed(attendanceFailure(AttendanceFailureCode.permissionDenied));
    }
    final evidence = command.locationEvidence;
    final result = await _api.punch(
      _actionFor(command.type),
      latitude: evidence?.latitude,
      longitude: evidence?.longitude,
    );
    switch (result) {
      case Failed<live.AttendanceDay>(:final failure):
        return Failed(_mapPunchFailure(failure));
      case Success<live.AttendanceDay>(:final value):
        final now = clock.now().toUtc();
        final mapped = mapper.map(today: value, auth: auth, now: now);
        if (mapped case Failed<RemoteAttendanceSnapshot>(:final failure)) {
          return Failed(failure);
        }
        final snapshot = (mapped as Success<RemoteAttendanceSnapshot>).value;
        final day = snapshot.context.day;
        if (day == null) {
          return Failed(
            attendanceFailure(AttendanceFailureCode.invalidAttendanceState),
          );
        }
        final event = _lastEventOf(snapshot.context.events, command.type);
        if (event == null) {
          return Failed(
            attendanceFailure(AttendanceFailureCode.invalidAttendanceState),
          );
        }
        final warnings = <AttendanceWarningCode>[
          if (command.type == AttendanceEventType.punchIn &&
              day.status == AttendanceDayStatus.late)
            AttendanceWarningCode.latePunchIn,
        ];
        final decision = AttendanceActionDecision(
          nextState: day.state,
          requiresLocation: evidence != null,
          locationValidation: const AttendanceLocationValidation(
            state: AttendanceLocationState.notRequired,
          ),
          warnings: warnings,
        );
        if (!_revision.isClosed) _revision.add(null);
        return Success(AttendanceMutationResult(day, event, decision));
    }
  }

  static AttendanceEvent? _lastEventOf(
    List<AttendanceEvent> events,
    AttendanceEventType type,
  ) {
    for (final event in events.reversed) {
      if (event.eventType == type) return event;
    }
    return null;
  }

  static String _actionFor(AttendanceEventType type) => switch (type) {
    AttendanceEventType.punchIn => 'punchIn',
    AttendanceEventType.breakStart => 'break',
    AttendanceEventType.breakEnd => 'resume',
    AttendanceEventType.punchOut => 'punchOut',
  };

  static AttendanceHistoryPageData _emptyHistory(
    AttendanceHistoryQuery query,
    DateTime now,
  ) => AttendanceHistoryPageData(
    query,
    const [],
    0,
    AttendanceMonthSummary(
      counts: const {},
      work: Duration.zero,
      breaks: Duration.zero,
      completed: 0,
    ),
    now,
  );

  /// The documented punch envelopes mapped onto the existing attendance failure
  /// vocabulary. Unknown codes keep their original safe [Failure].
  static Failure _mapPunchFailure(Failure failure) {
    final code = failure.code.toUpperCase();
    if (code.contains('DAY_COMPLETE') || code.contains('ALREADY_COMPLETED')) {
      return attendanceFailure(AttendanceFailureCode.alreadyCompleted);
    }
    if (code.contains('NO_SHIFT')) {
      return attendanceFailure(AttendanceFailureCode.shiftNotAssigned);
    }
    if (code.contains('UNSCHEDULED')) {
      return attendanceFailure(AttendanceFailureCode.unscheduledDay);
    }
    if (code.contains('LOCATION_REQUIRED') ||
        code.contains('LOCATION_MISSING')) {
      return attendanceFailure(AttendanceFailureCode.locationRequired);
    }
    if (code.contains('INVALID_LOCATION') ||
        code.contains('INVALID_COORDINATES')) {
      return attendanceFailure(AttendanceFailureCode.invalidLocationEvidence);
    }
    if (code == 'ACCESS_DENIED' ||
        code.contains('PERMISSION_DENIED') ||
        failure.kind == FailureKind.forbidden) {
      return attendanceFailure(AttendanceFailureCode.permissionDenied);
    }
    if (code.contains('UNAUTHORIZED') ||
        code.contains('TOKEN') ||
        failure.kind == FailureKind.sessionExpired) {
      return Failure(
        code: AttendanceFailureCode.permissionDenied.name,
        kind: FailureKind.sessionExpired,
      );
    }
    return failure;
  }

  Future<void> dispose() => _revision.close();
}
