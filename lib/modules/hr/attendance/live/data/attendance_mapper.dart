import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/utils/local_time.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_engine.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_state_machine.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_summary_calculator.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/hr/attendance/live/domain/attendance_day.dart'
    as live;
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

class RemoteAttendanceBreak {
  const RemoteAttendanceBreak({
    required this.start,
    this.end,
    required this.minutes,
  });
  final DateTime start;
  final DateTime? end;
  final int minutes;
  bool get isOpen => end == null;
}

class RemoteAttendanceShift {
  const RemoteAttendanceShift({
    required this.shiftNo,
    this.employeeShiftId,
    this.shiftId,
    required this.shiftName,
    required this.shiftDate,
    required this.timeZone,
    required this.plannedStart,
    required this.plannedEnd,
    required this.plannedStartAt,
    required this.plannedEndAt,
    required this.status,
    required this.lateMinutes,
    required this.workedMinutes,
    required this.breakMinutes,
    required this.crossesMidnight,
    this.punchIn,
    this.punchOut,
    required this.breaks,
  });
  final int shiftNo;
  final int? employeeShiftId, shiftId;
  final String shiftName, shiftDate, timeZone, plannedStart, plannedEnd;
  final DateTime plannedStartAt, plannedEndAt;
  final String status;
  final int lateMinutes, workedMinutes, breakMinutes;
  final bool crossesMidnight;
  final DateTime? punchIn, punchOut;
  final List<RemoteAttendanceBreak> breaks;

  bool get hasOpenBreak => breaks.any((b) => b.isOpen);
}

/// The typed projection of one `GET /attendance/today` payload. The context is
/// what the existing repository/BLoC consumes; the extra fields are the
/// payload-only timeline values kept for tests and future UI work.
class RemoteAttendanceSnapshot {
  const RemoteAttendanceSnapshot({
    required this.context,
    required this.allowedActions,
    required this.shifts,
    this.currentShift,
    this.nextShift,
    this.currentShiftNo,
    this.nextShiftNo,
    required this.attendanceDate,
    required this.timeZone,
    required this.workedMinutes,
    required this.breakMinutes,
    this.serverTime,
  });
  final AttendanceContext context;
  final Set<AttendanceEventType> allowedActions;
  final List<RemoteAttendanceShift> shifts;
  final RemoteAttendanceShift? currentShift, nextShift;
  final int? currentShiftNo, nextShiftNo;
  final DateTime attendanceDate;
  final String timeZone;
  final int workedMinutes, breakMinutes;
  final DateTime? serverTime;
}

/// Maps the backend attendance payload onto the frozen attendance domain.
///
/// Only values supplied by the payload are derived. Shift/policy fields the
/// backend does not provide use inert defaults so the existing context can be
/// constructed; they never invent attendance records or enable actions the
/// backend did not list in `allowedActions`.
class RemoteAttendanceMapper {
  const RemoteAttendanceMapper();

  static final DateTime _epoch = DateTime.utc(1970, 1, 1);

  Result<RemoteAttendanceSnapshot> map({
    required live.AttendanceDay today,
    required AuthContext auth,
    required DateTime now,
  }) {
    final reference = auth.employeeReference;
    if (reference == null) {
      return Failed(
        attendanceFailure(AttendanceFailureCode.notLinkedToEmployee),
      );
    }
    final state = _state(today.state);
    if (state == null) {
      return Failed(
        attendanceFailure(AttendanceFailureCode.invalidAttendanceState),
      );
    }
    final attendanceDate = _parseDate(today.date);
    if (attendanceDate == null) {
      return Failed(
        attendanceFailure(AttendanceFailureCode.invalidAttendanceState),
      );
    }
    final timeZone = today.timeZone.isEmpty
        ? auth.company.timezone
        : today.timeZone;
    final shifts = today.shifts
        .map((shift) => _shift(shift, attendanceDate, timeZone))
        .toList(growable: false);
    final currentShift = _byNumber(shifts, today.currentShiftNo);
    final nextShift = _byNumber(shifts, today.nextShiftNo);
    final primary = _primaryShift(
      state,
      shifts,
      today.currentShiftNo,
      today.nextShiftNo,
    );
    final allowedActions = Set<AttendanceEventType>.unmodifiable(
      _allowedActions(today.allowedActions),
    );
    final employee = _employee(auth);
    final snapshot = AttendanceConfigurationSnapshot(
      shift: _shiftRecord(primary, auth, attendanceDate),
      policy: _policy(auth, attendanceDate),
      timezone: timeZone,
      scheduledStart: primary?.plannedStartAt ?? attendanceDate,
      scheduledEnd: primary?.plannedEndAt ?? attendanceDate,
      workMode: AttendanceWorkMode.remote,
    );
    final dayId = 'remote-${reference.id}-${_isoDate(attendanceDate)}';
    AttendanceDay? day;
    var events = const <AttendanceEvent>[];
    if (state != AttendanceWorkdayState.notStarted) {
      if (primary == null) {
        return Failed(
          attendanceFailure(AttendanceFailureCode.invalidAttendanceState),
        );
      }
      final all = _eventsFor(shifts, dayId, auth, reference.id);
      if (_matches(all, state, now)) {
        events = all;
      } else {
        final fallback = _eventsFor([primary], dayId, auth, reference.id);
        if (!_matches(fallback, state, now)) {
          return Failed(
            attendanceFailure(AttendanceFailureCode.invalidAttendanceState),
          );
        }
        events = fallback;
      }
      final summary = const AttendanceSummaryCalculator().calculate(
        events,
        now,
      );
      final value = (summary as Success<AttendanceSummary>).value;
      day = AttendanceDay(
        id: dayId,
        companyId: auth.company.id,
        employeeId: reference.id,
        attendanceDate: attendanceDate,
        snapshot: snapshot,
        state: state,
        punchInAt: value.punchInTime,
        punchOutAt: value.punchOutTime,
        elapsedMilliseconds: (today.workedMinutes + today.breakMinutes) * 60000,
        breakMilliseconds: today.breakMinutes * 60000,
        workMilliseconds: today.workedMinutes * 60000,
        status: shifts.any((shift) => shift.lateMinutes > 0)
            ? AttendanceDayStatus.late
            : state == AttendanceWorkdayState.completed
            ? AttendanceDayStatus.completed
            : AttendanceDayStatus.working,
        syncStatus: AttendanceSyncStatus.synced,
        createdAt: _parseInstant(today.serverTime) ?? attendanceDate,
        updatedAt: _parseInstant(today.serverTime) ?? attendanceDate,
      );
    }
    return Success(
      RemoteAttendanceSnapshot(
        context: AttendanceContext(
          auth: auth,
          employee: employee,
          snapshot: snapshot,
          workday: attendanceDate,
          currentTime: now.toUtc(),
          scheduled: primary != null,
          remoteAvailable: true,
          authority: AttendanceAuthority.productionPending,
          day: day,
          events: events,
          allowedActions: allowedActions,
        ),
        allowedActions: allowedActions,
        shifts: shifts,
        currentShift: currentShift,
        nextShift: nextShift,
        currentShiftNo: today.currentShiftNo,
        nextShiftNo: today.nextShiftNo,
        attendanceDate: attendanceDate,
        timeZone: timeZone,
        workedMinutes: today.workedMinutes,
        breakMinutes: today.breakMinutes,
        serverTime: _parseInstant(today.serverTime),
      ),
    );
  }

  static AttendanceWorkdayState? _state(String value) => switch (value) {
    'noShift' ||
    'waitingForShift' ||
    'readyToPunchIn' => AttendanceWorkdayState.notStarted,
    'working' => AttendanceWorkdayState.working,
    'onBreak' => AttendanceWorkdayState.onBreak,
    'completed' => AttendanceWorkdayState.completed,
    _ => null,
  };

  static Set<AttendanceEventType> _allowedActions(Iterable<String> values) {
    final actions = <AttendanceEventType>{};
    for (final value in values) {
      switch (value) {
        case 'punchIn':
          actions.add(AttendanceEventType.punchIn);
        case 'break':
          actions.add(AttendanceEventType.breakStart);
        case 'resume':
          actions.add(AttendanceEventType.breakEnd);
        case 'punchOut':
          actions.add(AttendanceEventType.punchOut);
      }
    }
    return actions;
  }

  static RemoteAttendanceShift? _byNumber(
    List<RemoteAttendanceShift> shifts,
    int? number,
  ) {
    if (number == null) return null;
    for (final shift in shifts) {
      if (shift.shiftNo == number) return shift;
    }
    return null;
  }

  static RemoteAttendanceShift? _primaryShift(
    AttendanceWorkdayState state,
    List<RemoteAttendanceShift> shifts,
    int? currentShiftNo,
    int? nextShiftNo,
  ) {
    if (shifts.isEmpty) return null;
    final current = _byNumber(shifts, currentShiftNo);
    if (current != null) return current;
    if (state == AttendanceWorkdayState.notStarted) {
      final next = _byNumber(shifts, nextShiftNo);
      if (next != null) return next;
    }
    if (state == AttendanceWorkdayState.working ||
        state == AttendanceWorkdayState.onBreak) {
      for (final shift in shifts.reversed) {
        if (shift.punchIn != null && shift.punchOut == null) return shift;
      }
    }
    if (state == AttendanceWorkdayState.completed) {
      for (final shift in shifts.reversed) {
        if (shift.punchOut != null) return shift;
      }
    }
    return shifts.first;
  }

  static RemoteAttendanceShift _shift(
    live.AttendanceShift raw,
    DateTime attendanceDate,
    String fallbackTimeZone,
  ) {
    final timeZone = raw.timeZone.isEmpty ? fallbackTimeZone : raw.timeZone;
    final shiftDate = _parseDate(raw.shiftDate) ?? attendanceDate;
    final start = _localTime(raw.plannedStart);
    final end = _localTime(raw.plannedEnd);
    final crossesMidnight = raw.crossesMidnight || end.minutes < start.minutes;
    return RemoteAttendanceShift(
      shiftNo: raw.shiftNo,
      employeeShiftId: (raw.raw['employeeShiftId'] as num?)?.toInt(),
      shiftId: (raw.raw['shiftId'] as num?)?.toInt(),
      shiftName: raw.shiftName,
      shiftDate: raw.shiftDate,
      timeZone: timeZone,
      plannedStart: raw.plannedStart,
      plannedEnd: raw.plannedEnd,
      plannedStartAt: _schedule(shiftDate, start, timeZone),
      plannedEndAt: _schedule(
        shiftDate,
        end,
        timeZone,
        addDay: crossesMidnight,
      ),
      status: raw.status,
      lateMinutes: raw.lateMinutes,
      workedMinutes: raw.workedMinutes,
      breakMinutes: raw.breakMinutes,
      crossesMidnight: crossesMidnight,
      punchIn: _parseInstant(raw.punchIn),
      punchOut: _parseInstant(raw.punchOut),
      breaks: [
        for (final item in raw.breaks)
          RemoteAttendanceBreak(
            start: _parseInstant(item.start) ?? shiftDate,
            end: _parseInstant(item.end),
            minutes: item.minutes,
          ),
      ],
    );
  }

  static Shift _shiftRecord(
    RemoteAttendanceShift? primary,
    AuthContext auth,
    DateTime date,
  ) {
    final start = _localTime(primary?.plannedStart ?? '');
    final end = _localTime(primary?.plannedEnd ?? '');
    final name = primary == null
        ? ''
        : primary.shiftName.isEmpty
        ? 'Shift ${primary.shiftNo}'
        : primary.shiftName;
    return Shift(
      id: primary?.shiftId?.toString() ?? 'remote-shift',
      companyId: auth.company.id,
      name: name,
      startTime: start,
      endTime: end,
      workingDays: WorkingDay.values.toSet(),
      createdAt: date,
      updatedAt: date,
      status: ConfigurationStatus.active,
    );
  }

  static AttendancePolicy _policy(AuthContext auth, DateTime date) =>
      AttendancePolicy(
        id: 'remote-attendance-policy',
        companyId: auth.company.id,
        name: 'Attendance',
        requireLocation: true,
        requireLocationOnPunchIn: true,
        requireLocationOnPunchOut: true,
        requireLocationOnBreak: true,
        allowRemoteAttendance: true,
        trackBreaks: true,
        allowMultipleBreaks: true,
        allowPunchOutDuringBreak: true,
        allowEarlyPunchIn: true,
        earlyPunchInLimitMinutes: 1440,
        allowLatePunchIn: true,
        allowEarlyPunchOut: true,
        createdAt: date,
        updatedAt: date,
        status: ConfigurationStatus.active,
      );

  /// The authenticated session is the only identity source; no employee record
  /// is invented. The display name is the session's own identity.
  static Employee _employee(AuthContext auth) => Employee(
    id: auth.employeeReference!.id,
    companyId: auth.company.id,
    employeeCode: '',
    firstName: auth.user.displayName,
    email: auth.user.email,
    phone: auth.user.phone ?? '',
    departmentId: '',
    designationId: '',
    joiningDate: _epoch,
    status: EmploymentStatus.active,
    linkedUserId: auth.user.id,
    loginEnabled: true,
    createdAt: _epoch,
    updatedAt: _epoch,
    syncStatus: EmployeeSyncStatus.synced,
  );

  static List<AttendanceEvent> _eventsFor(
    Iterable<RemoteAttendanceShift> shifts,
    String dayId,
    AuthContext auth,
    String employeeId,
  ) {
    final drafts = <({AttendanceEventType type, DateTime at})>[];
    for (final shift in shifts) {
      final punchIn = shift.punchIn;
      if (punchIn != null) {
        drafts.add((type: AttendanceEventType.punchIn, at: punchIn));
      }
      for (final item in shift.breaks) {
        drafts.add((type: AttendanceEventType.breakStart, at: item.start));
        final end = item.end;
        if (end != null) {
          drafts.add((type: AttendanceEventType.breakEnd, at: end));
        }
      }
      final punchOut = shift.punchOut;
      if (punchOut != null) {
        drafts.add((type: AttendanceEventType.punchOut, at: punchOut));
      }
    }
    drafts.sort((a, b) {
      final byTime = a.at.compareTo(b.at);
      return byTime != 0 ? byTime : a.type.index.compareTo(b.type.index);
    });
    return [
      for (var index = 0; index < drafts.length; index++)
        AttendanceEvent(
          id: '$dayId-${index + 1}',
          attendanceDayId: dayId,
          companyId: auth.company.id,
          employeeId: employeeId,
          eventType: drafts[index].type,
          deviceTimestamp: drafts[index].at,
          sequence: index,
          locationValidation: const AttendanceLocationValidation(
            state: AttendanceLocationState.notRequired,
          ),
          requestId: '$dayId-${index + 1}',
          source: AttendanceEventSource.mobile,
          syncStatus: AttendanceSyncStatus.synced,
          createdAt: drafts[index].at,
        ),
    ];
  }

  static bool _matches(
    List<AttendanceEvent> events,
    AttendanceWorkdayState state,
    DateTime now,
  ) {
    final summary = const AttendanceSummaryCalculator().calculate(events, now);
    return summary is Success<AttendanceSummary> &&
        summary.value.currentState == state;
  }

  static DateTime _schedule(
    DateTime date,
    LocalTime time,
    String timeZone, {
    bool addDay = false,
  }) {
    var wall = DateTime.utc(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (addDay) wall = wall.add(const Duration(days: 1));
    final converted = const FixedOffsetCompanyTimeService().toInstant(
      wall,
      timeZone,
    );
    return converted is Success<DateTime> ? converted.value : wall;
  }

  static LocalTime _localTime(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return const LocalTime(hour: 0, minute: 0);
    return LocalTime(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  static DateTime? _parseDate(String value) {
    if (value.isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    return parsed == null
        ? null
        : DateTime.utc(parsed.year, parsed.month, parsed.day);
  }

  static DateTime? _parseInstant(String? value) =>
      value == null ? null : DateTime.tryParse(value)?.toUtc();

  static String _isoDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
