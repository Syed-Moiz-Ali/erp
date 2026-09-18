import '../../../core/utils/local_time.dart';
import '../../../core/errors/result.dart';
import '../../shifts/domain/shift.dart';
import '../../attendance_policies/domain/attendance_policy.dart';
import 'attendance_models.dart';
import 'attendance_state_machine.dart';

abstract interface class CompanyTimeService {
  Result<DateTime> localWallTime(DateTime instant, String timezone);
  Result<DateTime> toInstant(DateTime wallTime, String timezone);
}

/// Explicit fixed-offset zones only. Unknown/DST zones fail safely, never use device timezone.
class FixedOffsetCompanyTimeService implements CompanyTimeService {
  const FixedOffsetCompanyTimeService();
  static const offsets = {
    'UTC': 0,
    'Etc/UTC': 0,
    'Asia/Dubai': 240,
    'Asia/Riyadh': 180,
    'Asia/Karachi': 300,
    'Asia/Kolkata': 330,
    'Asia/Calcutta': 330,
  };
  @override
  Result<DateTime> localWallTime(DateTime instant, String timezone) {
    final offset = offsets[timezone];
    return offset == null
        ? Failed(attendanceFailure(AttendanceFailureCode.unsupportedTimezone))
        : Success(instant.toUtc().add(Duration(minutes: offset)));
  }

  @override
  Result<DateTime> toInstant(DateTime wallTime, String timezone) {
    final offset = offsets[timezone];
    return offset == null
        ? Failed(attendanceFailure(AttendanceFailureCode.unsupportedTimezone))
        : Success(wallTime.toUtc().subtract(Duration(minutes: offset)));
  }
}

class ShiftWorkday {
  const ShiftWorkday(this.date, this.start, this.end, this.scheduled);
  final DateTime date, start, end;
  final bool scheduled;
}

class ShiftWorkdayResolver {
  const ShiftWorkdayResolver(this.time);
  final CompanyTimeService time;
  Result<ShiftWorkday> resolve(
    Shift shift,
    AttendancePolicy policy,
    DateTime now,
    String timezone,
  ) {
    final local = time.localWallTime(now, timezone);
    if (local case Failed<DateTime>(:final failure)) return Failed(failure);
    final wall = (local as Success<DateTime>).value;
    var date = DateTime.utc(wall.year, wall.month, wall.day);
    final minutes = wall.hour * 60 + wall.minute;
    // Before overnight end belongs to yesterday. Beyond end uses today's next shift.
    if (shift.isOvernight && minutes <= shift.endTime.minutes) {
      date = date.subtract(const Duration(days: 1));
    }
    final startWall = date.add(Duration(minutes: shift.startTime.minutes));
    final endWall = date.add(
      Duration(minutes: shift.endTime.minutes, days: shift.isOvernight ? 1 : 0),
    );
    final start = time.toInstant(startWall, timezone),
        end = time.toInstant(endWall, timezone);
    if (start case Failed<DateTime>(:final failure)) return Failed(failure);
    if (end case Failed<DateTime>(:final failure)) return Failed(failure);
    return Success(
      ShiftWorkday(
        date,
        (start as Success<DateTime>).value,
        (end as Success<DateTime>).value,
        shift.workingDays.any((d) => d.isoWeekday == date.weekday),
      ),
    );
  }
}

class AttendanceTimingEvaluator {
  const AttendanceTimingEvaluator();
  bool isLate(AttendanceConfigurationSnapshot snapshot, DateTime punchIn) =>
      punchIn.isAfter(
        snapshot.scheduledStart.add(
          Duration(minutes: snapshot.shift.gracePeriodMinutes),
        ),
      );
  AttendanceFailureCode? validate(
    AttendanceConfigurationSnapshot s,
    AttendanceEventType action,
    DateTime now,
  ) {
    final p = s.policy;
    if (action == AttendanceEventType.punchIn) {
      if (now.isBefore(s.scheduledStart) &&
          (!p.allowEarlyPunchIn ||
              now.isBefore(
                s.scheduledStart.subtract(
                  Duration(minutes: p.earlyPunchInLimitMinutes ?? 0),
                ),
              ))) {
        return AttendanceFailureCode.tooEarlyToPunchIn;
      }
      if (!p.allowLatePunchIn && isLate(s, now)) {
        return AttendanceFailureCode.latePunchInNotAllowed;
      }
    }
    if (action == AttendanceEventType.punchOut &&
        !p.allowEarlyPunchOut &&
        now.isBefore(s.scheduledEnd)) {
      return AttendanceFailureCode.earlyPunchOutNotAllowed;
    }
    return null;
  }
}
