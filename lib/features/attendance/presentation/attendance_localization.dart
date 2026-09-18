import '../../../l10n/generated/app_localizations.dart';
import '../domain/attendance_models.dart';

String attendanceFailureLabel(
  AppLocalizations l,
  AttendanceFailureCode code,
) => switch (code) {
  AttendanceFailureCode.notLinkedToEmployee => l.attendanceNotLinkedToEmployee,
  AttendanceFailureCode.employeeInactive => l.attendanceEmployeeInactive,
  AttendanceFailureCode.accountInactive => l.attendanceAccountInactive,
  AttendanceFailureCode.permissionDenied => l.attendancePermissionDenied,
  AttendanceFailureCode.shiftNotAssigned => l.attendanceShiftNotAssigned,
  AttendanceFailureCode.policyNotAssigned => l.attendancePolicyNotAssigned,
  AttendanceFailureCode.workLocationRequiredButMissing =>
    l.attendanceWorkLocationRequiredButMissing,
  AttendanceFailureCode.locationRequired => l.attendanceLocationRequired,
  AttendanceFailureCode.locationUnavailable => l.attendanceLocationUnavailable,
  AttendanceFailureCode.locationPermissionDenied =>
    l.attendanceLocationPermissionDenied,
  AttendanceFailureCode.locationServicesDisabled =>
    l.attendanceLocationServicesDisabled,
  AttendanceFailureCode.locationAccuracyTooLow =>
    l.attendanceLocationAccuracyTooLow,
  AttendanceFailureCode.outsideAllowedLocation =>
    l.attendanceOutsideAllowedLocation,
  AttendanceFailureCode.alreadyPunchedIn => l.attendanceAlreadyPunchedIn,
  AttendanceFailureCode.notPunchedIn => l.attendanceNotPunchedIn,
  AttendanceFailureCode.alreadyOnBreak => l.attendanceAlreadyOnBreak,
  AttendanceFailureCode.notOnBreak => l.attendanceNotOnBreak,
  AttendanceFailureCode.breakTrackingDisabled =>
    l.attendanceBreakTrackingDisabled,
  AttendanceFailureCode.multipleBreaksNotAllowed =>
    l.attendanceMultipleBreaksNotAllowed,
  AttendanceFailureCode.punchOutDuringBreakNotAllowed =>
    l.attendancePunchOutDuringBreakNotAllowed,
  AttendanceFailureCode.alreadyCompleted => l.attendanceAlreadyCompleted,
  AttendanceFailureCode.tooEarlyToPunchIn => l.attendanceTooEarlyToPunchIn,
  AttendanceFailureCode.latePunchInNotAllowed =>
    l.attendanceLatePunchInNotAllowed,
  AttendanceFailureCode.earlyPunchOutNotAllowed =>
    l.attendanceEarlyPunchOutNotAllowed,
  AttendanceFailureCode.unscheduledDay => l.attendanceUnscheduledDay,
  AttendanceFailureCode.offlineAttendanceNotAllowed =>
    l.attendanceOfflineAttendanceNotAllowed,
  AttendanceFailureCode.invalidAttendanceState =>
    l.attendanceInvalidAttendanceState,
  AttendanceFailureCode.persistenceFailure => l.attendancePersistenceFailure,
  AttendanceFailureCode.invalidLocationEvidence =>
    l.attendanceInvalidLocationEvidence,
  AttendanceFailureCode.staleLocationEvidence =>
    l.attendanceStaleLocationEvidence,
  AttendanceFailureCode.remoteAttendanceNotAllowed =>
    l.attendanceRemoteAttendanceNotAllowed,
  AttendanceFailureCode.invalidTimestamp => l.attendanceInvalidTimestamp,
  AttendanceFailureCode.duplicateRequestId => l.attendanceDuplicateRequestId,
  AttendanceFailureCode.operationNotFound => l.attendanceOperationNotFound,
  AttendanceFailureCode.syncUnavailable => l.attendanceSyncUnavailable,
  AttendanceFailureCode.synchronizationFailed =>
    l.attendanceSynchronizationFailed,
  AttendanceFailureCode.unsupportedTimezone => l.attendanceUnsupportedTimezone,
  AttendanceFailureCode.companyUnavailable => l.attendanceCompanyUnavailable,
};
String attendanceWarningLabel(AppLocalizations l, AttendanceWarningCode code) =>
    switch (code) {
      AttendanceWarningCode.outsideAllowedLocation =>
        l.attendanceWarningOutsideAllowedLocation,
      AttendanceWarningCode.offlinePending => l.attendanceWarningOfflinePending,
      AttendanceWarningCode.latePunchIn => l.attendanceWarningLatePunchIn,
      AttendanceWarningCode.earlyPunchOut => l.attendanceWarningEarlyPunchOut,
      AttendanceWarningCode.unscheduledDay => l.attendanceWarningUnscheduledDay,
    };
