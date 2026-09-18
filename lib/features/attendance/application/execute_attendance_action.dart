import 'package:uuid/uuid.dart';
import '../../../core/errors/result.dart';
import '../../../core/utils/app_clock.dart';
import '../domain/attendance_models.dart';
import '../domain/attendance_engine.dart';
import '../domain/attendance_repository.dart';
import '../domain/attendance_state_machine.dart';

abstract interface class AttendanceLocationCapture {
  Future<Result<AttendanceLocationEvidence>> capture();
}

/// Shared action workflow: preflight, optional explicit GPS capture, then transactional revalidation.
class ExecuteAttendanceAction {
  const ExecuteAttendanceAction(
    this.repository,
    this.location,
    this.clock,
    this.source, {
    this.engine = const AttendanceEngine(),
  });
  final AttendanceRepository repository;
  final AttendanceLocationCapture location;
  final AppClock clock;
  final AttendanceEventSource source;
  final AttendanceEngine engine;
  Future<Result<AttendanceMutationResult>> call(
    AttendanceEventType type, {
    AttendanceWorkMode workMode = AttendanceWorkMode.office,
  }) async {
    final current = await repository.getCurrentAttendance(workMode: workMode);
    if (current case Failed<AttendanceContext>(:final failure)) {
      return Failed(failure);
    }
    final c = (current as Success<AttendanceContext>).value;
    final decision = engine.decide(c, type, checkEvidence: false);
    if (!decision.allowed) return Failed(attendanceFailure(decision.failure!));
    AttendanceLocationEvidence? evidence;
    if (decision.requiresLocation) {
      final captured = await location.capture();
      if (captured case Failed<AttendanceLocationEvidence>(:final failure)) {
        return Failed(failure);
      }
      evidence = (captured as Success<AttendanceLocationEvidence>).value;
    }
    // UUID and timestamp created once; retries target the persisted operation.
    return repository.execute(
      AttendanceCommand(
        type: type,
        requestId: const Uuid().v4(),
        expectedUserId: c.auth.user.id,
        deviceTimestamp: clock.now().toUtc(),
        source: source,
        locationEvidence: evidence,
        workMode: workMode,
      ),
    );
  }
}
