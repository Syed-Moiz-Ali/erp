import 'package:modular_erp/core/errors/result.dart';
import 'attendance_models.dart';
import 'attendance_state_machine.dart';

class AttendanceSummaryCalculator {
  const AttendanceSummaryCalculator();
  List<AttendanceEvent> ordered(Iterable<AttendanceEvent> events) =>
      events.toList()..sort((a, b) {
        final time = a.effectiveTimestamp.compareTo(b.effectiveTimestamp);
        if (time != 0) return time;
        final sequence = a.sequence.compareTo(b.sequence);
        return sequence != 0 ? sequence : a.id.compareTo(b.id);
      });
  Result<AttendanceSummary> calculate(
    Iterable<AttendanceEvent> events,
    DateTime now,
  ) {
    var state = AttendanceWorkdayState.notStarted;
    DateTime? punchIn, punchOut;
    AttendanceEvent? open;
    final breaks = <BreakSession>[];
    for (final e in ordered(events)) {
      final t = e.effectiveTimestamp;
      switch (e.eventType) {
        case AttendanceEventType.punchIn:
          if (state != AttendanceWorkdayState.notStarted) return _invalid();
          punchIn = t;
          state = AttendanceWorkdayState.working;
        case AttendanceEventType.breakStart:
          if (state != AttendanceWorkdayState.working) return _invalid();
          open = e;
          state = AttendanceWorkdayState.onBreak;
        case AttendanceEventType.breakEnd:
          if (state != AttendanceWorkdayState.onBreak || open == null) {
            return _invalid();
          }
          breaks.add(
            BreakSession(
              startEventId: open.id,
              endEventId: e.id,
              startedAt: open.effectiveTimestamp,
              endedAt: t,
              duration: _positive(t.difference(open.effectiveTimestamp)),
            ),
          );
          open = null;
          state = AttendanceWorkdayState.working;
        case AttendanceEventType.punchOut:
          if (state != AttendanceWorkdayState.working &&
              state != AttendanceWorkdayState.onBreak) {
            return _invalid();
          }
          // Composite punch-out closes the open break with this terminal event.
          if (open != null) {
            breaks.add(
              BreakSession(
                startEventId: open.id,
                endEventId: e.id,
                startedAt: open.effectiveTimestamp,
                endedAt: t,
                duration: _positive(t.difference(open.effectiveTimestamp)),
              ),
            );
            open = null;
          }
          punchOut = t;
          state = AttendanceWorkdayState.completed;
      }
    }
    final end = punchOut ?? now.toUtc();
    final elapsed = punchIn == null
        ? Duration.zero
        : _positive(end.difference(punchIn));
    final openDuration = open == null
        ? Duration.zero
        : _positive(end.difference(open.effectiveTimestamp));
    if (open != null) {
      breaks.add(
        BreakSession(
          startEventId: open.id,
          startedAt: open.effectiveTimestamp,
          duration: openDuration,
        ),
      );
    }
    final sum = breaks.fold<Duration>(Duration.zero, (d, b) => d + b.duration);
    final totalBreak = sum > elapsed ? elapsed : sum;
    return Success(
      AttendanceSummary(
        elapsedDuration: elapsed,
        workDuration: elapsed - totalBreak,
        breakDuration: totalBreak,
        openBreakDuration: openDuration > elapsed ? elapsed : openDuration,
        punchInTime: punchIn,
        punchOutTime: punchOut,
        currentState: state,
        breaks: breaks,
      ),
    );
  }

  Duration _positive(Duration value) =>
      value.isNegative ? Duration.zero : value;
  Result<AttendanceSummary> _invalid() =>
      Failed(attendanceFailure(AttendanceFailureCode.invalidAttendanceState));
}
