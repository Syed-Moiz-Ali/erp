import '../../../core/errors/result.dart';
import '../../attendance_policies/domain/attendance_policy.dart';
import 'attendance_models.dart';

Failure attendanceFailure(
  AttendanceFailureCode code, {
  bool retryable = false,
}) => Failure(
  code: code.name,
  kind: switch (code) {
    AttendanceFailureCode.persistenceFailure => FailureKind.storageWrite,
    AttendanceFailureCode.offlineAttendanceNotAllowed => FailureKind.offline,
    AttendanceFailureCode.synchronizationFailed ||
    AttendanceFailureCode.syncUnavailable => FailureKind.sync,
    AttendanceFailureCode.locationPermissionDenied =>
      FailureKind.locationPermission,
    AttendanceFailureCode.locationServicesDisabled =>
      FailureKind.locationDisabled,
    AttendanceFailureCode.locationUnavailable =>
      FailureKind.locationUnavailable,
    _ => FailureKind.invalidData,
  },
  retryable: retryable,
);

class AttendanceStateMachine {
  const AttendanceStateMachine();
  Result<AttendanceWorkdayState> transition(
    AttendanceWorkdayState state,
    AttendanceEventType action,
    AttendancePolicy policy, {
    int breakCount = 0,
  }) {
    AttendanceFailureCode? code;
    if (state == AttendanceWorkdayState.completed) {
      code = AttendanceFailureCode.alreadyCompleted;
    } else if (action == AttendanceEventType.punchIn) {
      if (state != AttendanceWorkdayState.notStarted) {
        code = AttendanceFailureCode.alreadyPunchedIn;
      } else {
        return const Success(AttendanceWorkdayState.working);
      }
    } else if (state == AttendanceWorkdayState.notStarted) {
      code = AttendanceFailureCode.notPunchedIn;
    } else if (action == AttendanceEventType.punchOut) {
      if (state == AttendanceWorkdayState.onBreak &&
          !policy.allowPunchOutDuringBreak) {
        code = AttendanceFailureCode.punchOutDuringBreakNotAllowed;
      } else {
        return const Success(AttendanceWorkdayState.completed);
      }
    } else if (!policy.trackBreaks) {
      code = AttendanceFailureCode.breakTrackingDisabled;
    } else if (action == AttendanceEventType.breakStart) {
      if (state == AttendanceWorkdayState.onBreak) {
        code = AttendanceFailureCode.alreadyOnBreak;
      } else if (!policy.allowMultipleBreaks && breakCount > 0) {
        code = AttendanceFailureCode.multipleBreaksNotAllowed;
      } else {
        return const Success(AttendanceWorkdayState.onBreak);
      }
    } else if (action == AttendanceEventType.breakEnd) {
      if (state != AttendanceWorkdayState.onBreak) {
        code = AttendanceFailureCode.notOnBreak;
      } else {
        return const Success(AttendanceWorkdayState.working);
      }
    }
    return Failed(
      attendanceFailure(code ?? AttendanceFailureCode.invalidAttendanceState),
    );
  }
}
