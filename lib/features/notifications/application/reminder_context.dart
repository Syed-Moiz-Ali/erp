import '../../../core/errors/result.dart';
import '../../attendance/domain/attendance_models.dart';

/// Snapshot required to decide shift/punch-out reminders without touching UI.
class ReminderContext {
  const ReminderContext({
    required this.employeeId,
    required this.scheduled,
    required this.workday,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.state,
  });
  final String employeeId;
  final bool scheduled;
  final DateTime workday, scheduledStart, scheduledEnd;
  final AttendanceWorkdayState state;
}

abstract interface class ReminderContextSource {
  /// Returns the current employee attendance context, or null when no session
  /// is available. Failures are safe/typed and never fabricated.
  Future<Result<ReminderContext?>> load();
}
