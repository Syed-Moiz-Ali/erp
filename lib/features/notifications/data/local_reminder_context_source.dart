import '../../../core/errors/result.dart';
import '../../attendance/domain/attendance_engine.dart';
import '../../attendance/domain/attendance_models.dart';
import '../../attendance/domain/attendance_repository.dart';
import '../application/reminder_context.dart';

/// Derives reminder context from the existing attendance engine so shift and
/// snapshot rules stay identical to the attendance feature.
class LocalReminderContextSource implements ReminderContextSource {
  const LocalReminderContextSource(this.attendance);
  final AttendanceRepository attendance;

  @override
  Future<Result<ReminderContext?>> load() async {
    final result = await attendance.getCurrentAttendance();
    if (result case Failed<AttendanceContext>(:final failure)) {
      return Failed(failure);
    }
    final context = (result as Success<AttendanceContext>).value;
    return Success(
      ReminderContext(
        employeeId: context.employee.id,
        scheduled: context.scheduled,
        workday: context.workday,
        scheduledStart: context.snapshot.scheduledStart,
        scheduledEnd: context.snapshot.scheduledEnd,
        state: context.day?.state ?? AttendanceWorkdayState.notStarted,
      ),
    );
  }
}
