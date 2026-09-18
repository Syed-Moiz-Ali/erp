import '../domain/attendance_location_validator.dart';
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
    final result = await prepare(type, workMode: workMode);
    if (result case Failed<PreparedAttendanceAction>(:final failure)) {
      return Failed(failure);
    }
    return commit((result as Success<PreparedAttendanceAction>).value);
  }

  Future<Result<PreparedAttendanceAction>> prepare(
    AttendanceEventType type, {
    AttendanceWorkMode workMode = AttendanceWorkMode.office,
    void Function()? onCheckingLocation,
  }) async {
    final current = await repository.getCurrentAttendance(workMode: workMode);
    if (current case Failed<AttendanceContext>(:final failure)) {
      return Failed(failure);
    }
    final original = (current as Success<AttendanceContext>).value;
    final preflight = engine.decide(original, type, checkEvidence: false);
    if (!preflight.allowed) {
      return Failed(attendanceFailure(preflight.failure!));
    }
    AttendanceLocationEvidence? evidence;
    if (preflight.requiresLocation) {
      onCheckingLocation?.call();
      final captured = await location.capture();
      if (captured case Failed<AttendanceLocationEvidence>(:final failure)) {
        return Failed(failure);
      }
      evidence = (captured as Success<AttendanceLocationEvidence>).value;
    }
    final refreshed = await repository.getCurrentAttendance(
      workMode: workMode,
      expectedUserId: original.auth.user.id,
      expectedCompanyId: original.auth.company.id,
    );
    if (refreshed case Failed<AttendanceContext>(:final failure)) {
      return Failed(failure);
    }
    final c = (refreshed as Success<AttendanceContext>).value;
    if (c.auth.user.id != original.auth.user.id ||
        c.auth.company.id != original.auth.company.id ||
        c.employee.id != original.employee.id ||
        c.workday != original.workday ||
        c.day?.id != original.day?.id) {
      return Failed(attendanceFailure(AttendanceFailureCode.permissionDenied));
    }
    final decision = engine.decide(c, type, evidence: evidence);
    // Keep a blocked location decision as preview data; it cannot be committed.
    return Success(
      PreparedAttendanceAction(
        type: type,
        context: c,
        evidence: evidence,
        decision: decision,
        workMode: workMode,
      ),
    );
  }

  Future<Result<PreparedAttendanceAction>> review(
    PreparedAttendanceAction original,
  ) async {
    final current = await repository.getCurrentAttendance(
      workMode: original.workMode,
      expectedUserId: original.context.auth.user.id,
      expectedCompanyId: original.context.auth.company.id,
    );
    if (current case Failed<AttendanceContext>(:final failure)) {
      return Failed(failure);
    }
    final c = (current as Success<AttendanceContext>).value;
    if (c.auth.user.id != original.context.auth.user.id ||
        c.auth.company.id != original.context.auth.company.id ||
        c.employee.id != original.context.employee.id ||
        c.workday != original.context.workday ||
        c.day?.id != original.context.day?.id) {
      return Failed(attendanceFailure(AttendanceFailureCode.permissionDenied));
    }
    return Success(
      PreparedAttendanceAction(
        type: original.type,
        context: c,
        evidence: original.evidence,
        decision: engine.decide(c, original.type, evidence: original.evidence),
        workMode: original.workMode,
      ),
    );
  }

  Future<Result<AttendanceMutationResult>> commit(
    PreparedAttendanceAction prepared,
  ) async {
    if (!prepared.decision.allowed) {
      return Failed(attendanceFailure(prepared.decision.failure!));
    }
    return repository.execute(
      AttendanceCommand(
        type: prepared.type,
        requestId: const Uuid().v4(),
        expectedUserId: prepared.context.auth.user.id,
        expectedCompanyId: prepared.context.auth.company.id,
        expectedEmployeeId: prepared.context.employee.id,
        expectedWorkday: prepared.context.workday,
        expectedDayId: prepared.context.day?.id,
        deviceTimestamp: clock.now().toUtc(),
        source: source,
        locationEvidence: prepared.evidence,
        workMode: prepared.workMode,
      ),
    );
  }
}

class PreparedAttendanceAction {
  const PreparedAttendanceAction({
    required this.type,
    required this.context,
    required this.decision,
    this.evidence,
    required this.workMode,
  });
  final AttendanceEventType type;
  final AttendanceContext context;
  final AttendanceActionDecision decision;
  final AttendanceLocationEvidence? evidence;
  final AttendanceWorkMode workMode;
  double? get maximumAccuracyMeters =>
      const AttendanceLocationRequirementResolver().maximumAccuracy(
        context.snapshot,
      );
}
