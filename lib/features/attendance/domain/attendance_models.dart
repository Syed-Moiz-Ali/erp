import 'package:freezed_annotation/freezed_annotation.dart';
import '../../shifts/domain/shift.dart';
import '../../work_locations/domain/work_location.dart';
import '../../attendance_policies/domain/attendance_policy.dart';
part 'attendance_models.freezed.dart';
part 'attendance_models.g.dart';

/// Canonical precision of persisted attendance instants: UTC epoch milliseconds.
DateTime attendanceInstant(DateTime value) =>
    DateTime.fromMillisecondsSinceEpoch(
      value.millisecondsSinceEpoch,
      isUtc: true,
    );

enum AttendanceWorkdayState { notStarted, working, onBreak, completed }

enum AttendanceEventType { punchIn, breakStart, breakEnd, punchOut }

enum AttendanceEventSource { mobile, web, manual, kiosk }

enum AttendanceSyncStatus { pending, synced, failed, rejected }

enum AttendanceDayStatus { working, completed, late }

enum AttendanceAuthority { demoLocal, productionPending }

enum AttendanceWorkMode { office, remote }

enum AttendancePermissionState {
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
  unavailable,
}

enum AttendanceLocationState {
  notRequired,
  insideAllowedArea,
  outsideAllowedAreaAllowed,
  outsideAllowedAreaRejected,
  accuracyRejected,
  locationUnavailable,
  captured,
  remoteAllowed,
}

enum AttendanceWarningCode {
  outsideAllowedLocation,
  offlinePending,
  latePunchIn,
  earlyPunchOut,
  unscheduledDay,
}

enum AttendanceFailureCode {
  notLinkedToEmployee,
  employeeInactive,
  accountInactive,
  permissionDenied,
  shiftNotAssigned,
  policyNotAssigned,
  workLocationRequiredButMissing,
  locationRequired,
  locationUnavailable,
  locationPermissionDenied,
  locationPermissionPermanentlyDenied,
  locationServicesDisabled,
  locationAccuracyTooLow,
  outsideAllowedLocation,
  alreadyPunchedIn,
  notPunchedIn,
  alreadyOnBreak,
  notOnBreak,
  breakTrackingDisabled,
  multipleBreaksNotAllowed,
  punchOutDuringBreakNotAllowed,
  alreadyCompleted,
  tooEarlyToPunchIn,
  latePunchInNotAllowed,
  earlyPunchOutNotAllowed,
  unscheduledDay,
  offlineAttendanceNotAllowed,
  invalidAttendanceState,
  persistenceFailure,
  invalidLocationEvidence,
  staleLocationEvidence,
  remoteAttendanceNotAllowed,
  invalidTimestamp,
  duplicateRequestId,
  operationNotFound,
  syncUnavailable,
  synchronizationFailed,
  unsupportedTimezone,
  companyUnavailable,
}

@freezed
abstract class AttendanceLocationEvidence with _$AttendanceLocationEvidence {
  const factory AttendanceLocationEvidence({
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required DateTime capturedAt,
    @Default(AttendancePermissionState.granted)
    AttendancePermissionState permissionState,
  }) = _AttendanceLocationEvidence;
  factory AttendanceLocationEvidence.fromJson(Map<String, dynamic> json) =>
      _$AttendanceLocationEvidenceFromJson(json);
}

@freezed
abstract class AttendanceLocationValidation
    with _$AttendanceLocationValidation {
  const factory AttendanceLocationValidation({
    required AttendanceLocationState state,
    double? distanceMeters,
    @Default(true) bool accuracyAccepted,
  }) = _AttendanceLocationValidation;
  factory AttendanceLocationValidation.fromJson(Map<String, dynamic> json) =>
      _$AttendanceLocationValidationFromJson(json);
}

/// Full immutable typed configuration snapshots; never reload live rows for an open day.
@freezed
abstract class AttendanceConfigurationSnapshot
    with _$AttendanceConfigurationSnapshot {
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory AttendanceConfigurationSnapshot({
    required Shift shift,
    required AttendancePolicy policy,
    WorkLocation? workLocation,
    required String timezone,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    @Default(AttendanceWorkMode.office) AttendanceWorkMode workMode,
  }) = _AttendanceConfigurationSnapshot;
  factory AttendanceConfigurationSnapshot.fromJson(Map<String, dynamic> json) =>
      _$AttendanceConfigurationSnapshotFromJson(json);
}

@freezed
abstract class AttendanceDay with _$AttendanceDay {
  const AttendanceDay._();
  String get shiftId => snapshot.shift.id;
  String get attendancePolicyId => snapshot.policy.id;
  String? get workLocationId => snapshot.workLocation?.id;
  Duration get totalElapsedDuration =>
      Duration(milliseconds: elapsedMilliseconds);
  Duration get totalBreakDuration => Duration(milliseconds: breakMilliseconds);
  Duration get totalWorkDuration => Duration(milliseconds: workMilliseconds);
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory AttendanceDay({
    required String id,
    required String companyId,
    required String employeeId,
    required DateTime attendanceDate,
    required AttendanceConfigurationSnapshot snapshot,
    required AttendanceWorkdayState state,
    DateTime? punchInAt,
    DateTime? punchOutAt,
    @Default(0) int elapsedMilliseconds,
    @Default(0) int breakMilliseconds,
    @Default(0) int workMilliseconds,
    required AttendanceDayStatus status,
    required AttendanceSyncStatus syncStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AttendanceDay;
  factory AttendanceDay.fromJson(Map<String, dynamic> json) =>
      _$AttendanceDayFromJson(json);
}

@freezed
abstract class AttendanceEvent with _$AttendanceEvent {
  const AttendanceEvent._();
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory AttendanceEvent({
    required String id,
    required String attendanceDayId,
    required String companyId,
    required String employeeId,
    required AttendanceEventType eventType,
    required DateTime deviceTimestamp,
    DateTime? serverTimestamp,
    required int sequence,
    AttendanceLocationEvidence? locationEvidence,
    String? workLocationId,
    required AttendanceLocationValidation locationValidation,
    required String requestId,
    required AttendanceEventSource source,
    required AttendanceSyncStatus syncStatus,
    required DateTime createdAt,
  }) = _AttendanceEvent;
  DateTime get effectiveTimestamp =>
      (serverTimestamp ?? deviceTimestamp).toUtc();
  DateTime get eventTimestamp => effectiveTimestamp;
  factory AttendanceEvent.fromJson(Map<String, dynamic> json) =>
      _$AttendanceEventFromJson(json);
}

class BreakSession {
  const BreakSession({
    required this.startEventId,
    this.endEventId,
    required this.startedAt,
    this.endedAt,
    required this.duration,
  });
  final String startEventId;
  final String? endEventId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final Duration duration;
  bool get isOpen => endedAt == null;
}

class AttendanceSummary {
  AttendanceSummary({
    required this.elapsedDuration,
    required this.workDuration,
    required this.breakDuration,
    required this.openBreakDuration,
    this.punchInTime,
    this.punchOutTime,
    required this.currentState,
    required List<BreakSession> breaks,
  }) : breaks = List.unmodifiable(breaks);
  final Duration elapsedDuration,
      workDuration,
      breakDuration,
      openBreakDuration;
  final DateTime? punchInTime, punchOutTime;
  final AttendanceWorkdayState currentState;
  final List<BreakSession> breaks;
}

class AttendanceCommand {
  const AttendanceCommand({
    required this.type,
    required this.requestId,
    required this.expectedUserId,
    this.expectedCompanyId,
    this.expectedEmployeeId,
    this.expectedWorkday,
    this.expectedDayId,
    required this.deviceTimestamp,
    required this.source,
    this.locationEvidence,
    this.workMode = AttendanceWorkMode.office,
  });
  final AttendanceEventType type;
  final String requestId, expectedUserId;
  final String? expectedCompanyId, expectedEmployeeId, expectedDayId;
  final DateTime? expectedWorkday;
  final DateTime deviceTimestamp;
  final AttendanceEventSource source;
  final AttendanceLocationEvidence? locationEvidence;
  final AttendanceWorkMode workMode;
}
