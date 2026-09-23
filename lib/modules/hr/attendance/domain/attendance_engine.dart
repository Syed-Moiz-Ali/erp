import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy.dart';
import 'attendance_models.dart';
import 'attendance_state_machine.dart';
import 'attendance_summary_calculator.dart';
import 'attendance_location_validator.dart';
import 'shift_workday_resolver.dart';

class AttendanceContext {
  AttendanceContext({
    required this.auth,
    required this.employee,
    required this.snapshot,
    required this.workday,
    required this.currentTime,
    required this.scheduled,
    required this.remoteAvailable,
    required this.authority,
    this.day,
    required List<AttendanceEvent> events,
  }) : events = List.unmodifiable(events);
  final AuthContext auth;
  final Employee employee;
  final AttendanceConfigurationSnapshot snapshot;
  final DateTime workday, currentTime;
  final bool scheduled, remoteAvailable;
  final AttendanceAuthority authority;
  final AttendanceDay? day;
  final List<AttendanceEvent> events;
}

class AttendanceActionDecision {
  AttendanceActionDecision({
    this.failure,
    this.nextState,
    required this.requiresLocation,
    required this.locationValidation,
    List<AttendanceWarningCode> warnings = const [],
  }) : warnings = List.unmodifiable(warnings);
  final AttendanceFailureCode? failure;
  final AttendanceWorkdayState? nextState;
  final bool requiresLocation;
  final AttendanceLocationValidation locationValidation;
  final List<AttendanceWarningCode> warnings;
  bool get allowed => failure == null;
}

class AttendanceAvailableActions {
  AttendanceAvailableActions(
    Map<AttendanceEventType, AttendanceActionDecision> decisions,
  ) : decisions = Map.unmodifiable(decisions);
  final Map<AttendanceEventType, AttendanceActionDecision> decisions;
  bool get canPunchIn => decisions[AttendanceEventType.punchIn]!.allowed;
  bool get canPunchOut => decisions[AttendanceEventType.punchOut]!.allowed;
  bool get canStartBreak => decisions[AttendanceEventType.breakStart]!.allowed;
  bool get canEndBreak => decisions[AttendanceEventType.breakEnd]!.allowed;
}

class AttendanceEngine {
  const AttendanceEngine({this.allowUnscheduledWithWarning = false});
  final bool allowUnscheduledWithWarning;
  Result<AttendanceSummary> calculateSummary(AttendanceContext c) =>
      const AttendanceSummaryCalculator().calculate(c.events, c.currentTime);
  AttendanceAvailableActions getAvailableActions(AttendanceContext c) =>
      AttendanceAvailableActions({
        for (final action in AttendanceEventType.values)
          action: decide(c, action, checkEvidence: false),
      });

  /// A single meaningful clock boundary, independent of display ticking.
  DateTime? nextActionEvaluationAt(AttendanceContext c) {
    final summary = calculateSummary(c);
    if (summary is! Success<AttendanceSummary>) return null;
    return switch (summary.value.currentState) {
      AttendanceWorkdayState.notStarted =>
        const AttendanceTimingEvaluator().nextPunchInChange(
          c.snapshot,
          c.currentTime,
        ),
      AttendanceWorkdayState.working || AttendanceWorkdayState.onBreak =>
        c.snapshot.scheduledEnd.isAfter(c.currentTime)
            ? c.snapshot.scheduledEnd
            : null,
      AttendanceWorkdayState.completed => null,
    };
  }

  AttendanceActionDecision decide(
    AttendanceContext c,
    AttendanceEventType action, {
    AttendanceLocationEvidence? evidence,
    bool checkEvidence = true,
  }) {
    final required = const AttendanceLocationRequirementResolver()
        .requiresLocation(c.snapshot.policy, action);
    var validation = const AttendanceLocationValidation(
      state: AttendanceLocationState.notRequired,
    );
    final warnings = <AttendanceWarningCode>[];
    AttendanceActionDecision blocked(AttendanceFailureCode code) =>
        AttendanceActionDecision(
          failure: code,
          requiresLocation: required,
          locationValidation: validation,
        );
    final auth = c.auth, ref = auth.employeeReference;
    if (auth.user.status != AccountStatus.active) {
      return blocked(AttendanceFailureCode.accountInactive);
    }
    if (auth.user.companyId != auth.company.id ||
        c.employee.companyId != auth.company.id ||
        !auth.company.enabledModules.contains('attendance')) {
      return blocked(AttendanceFailureCode.companyUnavailable);
    }
    if (ref == null ||
        ref.id != c.employee.id ||
        ref.userAccountId != auth.user.id ||
        ref.companyId != auth.company.id ||
        c.employee.linkedUserId != auth.user.id) {
      return blocked(AttendanceFailureCode.notLinkedToEmployee);
    }
    if (c.employee.status != EmploymentStatus.active ||
        !c.employee.loginEnabled) {
      return blocked(AttendanceFailureCode.employeeInactive);
    }
    final permission = switch (action) {
      AttendanceEventType.punchIn => AppPermission.attendancePunchIn,
      AttendanceEventType.punchOut => AppPermission.attendancePunchOut,
      _ => AppPermission.attendanceBreak,
    };
    if (!auth.user.permissions.contains(permission)) {
      return blocked(AttendanceFailureCode.permissionDenied);
    }
    if (c.snapshot.workMode == AttendanceWorkMode.remote &&
        !c.snapshot.policy.allowRemoteAttendance) {
      return blocked(AttendanceFailureCode.remoteAttendanceNotAllowed);
    }
    if (c.events.any(
          (e) =>
              e.companyId != c.auth.company.id ||
              e.employeeId != c.employee.id ||
              (c.day != null && e.attendanceDayId != c.day!.id),
        ) ||
        c.events.map((e) => e.sequence).toSet().length != c.events.length ||
        !c.snapshot.shift.startTime.isValid ||
        !c.snapshot.shift.endTime.isValid ||
        !c.snapshot.scheduledEnd.isAfter(c.snapshot.scheduledStart)) {
      return blocked(AttendanceFailureCode.invalidAttendanceState);
    }
    if (c.day?.syncStatus == AttendanceSyncStatus.rejected) {
      return blocked(AttendanceFailureCode.synchronizationFailed);
    }
    final summary = calculateSummary(c);
    if (summary is Failed<AttendanceSummary>) {
      return blocked(AttendanceFailureCode.invalidAttendanceState);
    }
    final value = (summary as Success<AttendanceSummary>).value;
    if (c.day != null && c.day!.state != value.currentState) {
      return blocked(AttendanceFailureCode.invalidAttendanceState);
    }
    final transition = const AttendanceStateMachine().transition(
      value.currentState,
      action,
      c.snapshot.policy,
      breakCount: value.breaks.length,
    );
    if (transition case Failed<AttendanceWorkdayState>(:final failure)) {
      return blocked(AttendanceFailureCode.values.byName(failure.code));
    }
    if (c.events.isNotEmpty &&
        c.currentTime.isBefore(
          const AttendanceSummaryCalculator()
              .ordered(c.events)
              .last
              .effectiveTimestamp,
        )) {
      return blocked(AttendanceFailureCode.invalidTimestamp);
    }
    if (action == AttendanceEventType.punchIn && !c.scheduled) {
      if (!allowUnscheduledWithWarning) {
        return blocked(AttendanceFailureCode.unscheduledDay);
      }
      warnings.add(AttendanceWarningCode.unscheduledDay);
    }
    final timing = const AttendanceTimingEvaluator().validate(
      c.snapshot,
      action,
      c.currentTime,
    );
    if (timing != null) return blocked(timing);
    if (action == AttendanceEventType.punchIn &&
        const AttendanceTimingEvaluator().isLate(c.snapshot, c.currentTime)) {
      warnings.add(AttendanceWarningCode.latePunchIn);
    }
    if (action == AttendanceEventType.punchOut &&
        c.currentTime.isBefore(c.snapshot.scheduledEnd)) {
      warnings.add(AttendanceWarningCode.earlyPunchOut);
    }
    if (c.authority == AttendanceAuthority.productionPending &&
        !c.remoteAvailable) {
      if (c.snapshot.policy.offlineMode == OfflineAttendanceMode.notAllowed) {
        return blocked(AttendanceFailureCode.offlineAttendanceNotAllowed);
      }
      if (c.snapshot.policy.offlineMode ==
          OfflineAttendanceMode.allowWithWarning) {
        warnings.add(AttendanceWarningCode.offlinePending);
      }
    }
    if (checkEvidence) {
      final outcome = const AttendanceLocationValidator().validate(
        c.snapshot,
        action,
        evidence,
        c.currentTime,
      );
      validation = outcome.validation;
      if (outcome.failure != null) return blocked(outcome.failure!);
      if (validation.state ==
          AttendanceLocationState.outsideAllowedAreaAllowed) {
        warnings.add(AttendanceWarningCode.outsideAllowedLocation);
      }
    }
    return AttendanceActionDecision(
      nextState: (transition as Success<AttendanceWorkdayState>).value,
      requiresLocation: required,
      locationValidation: validation,
      warnings: warnings,
    );
  }
}
