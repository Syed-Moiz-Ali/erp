// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceLocationEvidence _$AttendanceLocationEvidenceFromJson(
  Map<String, dynamic> json,
) => _AttendanceLocationEvidence(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  accuracyMeters: (json['accuracyMeters'] as num).toDouble(),
  capturedAt: DateTime.parse(json['capturedAt'] as String),
  permissionState:
      $enumDecodeNullable(
        _$AttendancePermissionStateEnumMap,
        json['permissionState'],
      ) ??
      AttendancePermissionState.granted,
);

Map<String, dynamic> _$AttendanceLocationEvidenceToJson(
  _AttendanceLocationEvidence instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'accuracyMeters': instance.accuracyMeters,
  'capturedAt': instance.capturedAt.toIso8601String(),
  'permissionState':
      _$AttendancePermissionStateEnumMap[instance.permissionState]!,
};

const _$AttendancePermissionStateEnumMap = {
  AttendancePermissionState.granted: 'granted',
  AttendancePermissionState.denied: 'denied',
  AttendancePermissionState.permanentlyDenied: 'permanentlyDenied',
  AttendancePermissionState.serviceDisabled: 'serviceDisabled',
  AttendancePermissionState.unavailable: 'unavailable',
};

_AttendanceLocationValidation _$AttendanceLocationValidationFromJson(
  Map<String, dynamic> json,
) => _AttendanceLocationValidation(
  state: $enumDecode(_$AttendanceLocationStateEnumMap, json['state']),
  distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
  accuracyAccepted: json['accuracyAccepted'] as bool? ?? true,
);

Map<String, dynamic> _$AttendanceLocationValidationToJson(
  _AttendanceLocationValidation instance,
) => <String, dynamic>{
  'state': _$AttendanceLocationStateEnumMap[instance.state]!,
  'distanceMeters': instance.distanceMeters,
  'accuracyAccepted': instance.accuracyAccepted,
};

const _$AttendanceLocationStateEnumMap = {
  AttendanceLocationState.notRequired: 'notRequired',
  AttendanceLocationState.insideAllowedArea: 'insideAllowedArea',
  AttendanceLocationState.outsideAllowedAreaAllowed:
      'outsideAllowedAreaAllowed',
  AttendanceLocationState.outsideAllowedAreaRejected:
      'outsideAllowedAreaRejected',
  AttendanceLocationState.accuracyRejected: 'accuracyRejected',
  AttendanceLocationState.locationUnavailable: 'locationUnavailable',
  AttendanceLocationState.captured: 'captured',
  AttendanceLocationState.remoteAllowed: 'remoteAllowed',
};

_AttendanceConfigurationSnapshot _$AttendanceConfigurationSnapshotFromJson(
  Map<String, dynamic> json,
) => _AttendanceConfigurationSnapshot(
  shift: Shift.fromJson(json['shift'] as Map<String, dynamic>),
  policy: AttendancePolicy.fromJson(json['policy'] as Map<String, dynamic>),
  workLocation: json['workLocation'] == null
      ? null
      : WorkLocation.fromJson(json['workLocation'] as Map<String, dynamic>),
  timezone: json['timezone'] as String,
  scheduledStart: DateTime.parse(json['scheduledStart'] as String),
  scheduledEnd: DateTime.parse(json['scheduledEnd'] as String),
  workMode:
      $enumDecodeNullable(_$AttendanceWorkModeEnumMap, json['workMode']) ??
      AttendanceWorkMode.office,
);

Map<String, dynamic> _$AttendanceConfigurationSnapshotToJson(
  _AttendanceConfigurationSnapshot instance,
) => <String, dynamic>{
  'shift': instance.shift.toJson(),
  'policy': instance.policy.toJson(),
  'workLocation': instance.workLocation?.toJson(),
  'timezone': instance.timezone,
  'scheduledStart': instance.scheduledStart.toIso8601String(),
  'scheduledEnd': instance.scheduledEnd.toIso8601String(),
  'workMode': _$AttendanceWorkModeEnumMap[instance.workMode]!,
};

const _$AttendanceWorkModeEnumMap = {
  AttendanceWorkMode.office: 'office',
  AttendanceWorkMode.remote: 'remote',
};

_AttendanceDay _$AttendanceDayFromJson(Map<String, dynamic> json) =>
    _AttendanceDay(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      employeeId: json['employeeId'] as String,
      attendanceDate: DateTime.parse(json['attendanceDate'] as String),
      snapshot: AttendanceConfigurationSnapshot.fromJson(
        json['snapshot'] as Map<String, dynamic>,
      ),
      state: $enumDecode(_$AttendanceWorkdayStateEnumMap, json['state']),
      punchInAt: json['punchInAt'] == null
          ? null
          : DateTime.parse(json['punchInAt'] as String),
      punchOutAt: json['punchOutAt'] == null
          ? null
          : DateTime.parse(json['punchOutAt'] as String),
      elapsedMilliseconds: (json['elapsedMilliseconds'] as num?)?.toInt() ?? 0,
      breakMilliseconds: (json['breakMilliseconds'] as num?)?.toInt() ?? 0,
      workMilliseconds: (json['workMilliseconds'] as num?)?.toInt() ?? 0,
      status: $enumDecode(_$AttendanceDayStatusEnumMap, json['status']),
      syncStatus: $enumDecode(
        _$AttendanceSyncStatusEnumMap,
        json['syncStatus'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AttendanceDayToJson(_AttendanceDay instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'employeeId': instance.employeeId,
      'attendanceDate': instance.attendanceDate.toIso8601String(),
      'snapshot': instance.snapshot.toJson(),
      'state': _$AttendanceWorkdayStateEnumMap[instance.state]!,
      'punchInAt': instance.punchInAt?.toIso8601String(),
      'punchOutAt': instance.punchOutAt?.toIso8601String(),
      'elapsedMilliseconds': instance.elapsedMilliseconds,
      'breakMilliseconds': instance.breakMilliseconds,
      'workMilliseconds': instance.workMilliseconds,
      'status': _$AttendanceDayStatusEnumMap[instance.status]!,
      'syncStatus': _$AttendanceSyncStatusEnumMap[instance.syncStatus]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$AttendanceWorkdayStateEnumMap = {
  AttendanceWorkdayState.notStarted: 'notStarted',
  AttendanceWorkdayState.working: 'working',
  AttendanceWorkdayState.onBreak: 'onBreak',
  AttendanceWorkdayState.completed: 'completed',
};

const _$AttendanceDayStatusEnumMap = {
  AttendanceDayStatus.working: 'working',
  AttendanceDayStatus.completed: 'completed',
  AttendanceDayStatus.late: 'late',
};

const _$AttendanceSyncStatusEnumMap = {
  AttendanceSyncStatus.pending: 'pending',
  AttendanceSyncStatus.synced: 'synced',
  AttendanceSyncStatus.failed: 'failed',
  AttendanceSyncStatus.rejected: 'rejected',
};

_AttendanceEvent _$AttendanceEventFromJson(Map<String, dynamic> json) =>
    _AttendanceEvent(
      id: json['id'] as String,
      attendanceDayId: json['attendanceDayId'] as String,
      companyId: json['companyId'] as String,
      employeeId: json['employeeId'] as String,
      eventType: $enumDecode(_$AttendanceEventTypeEnumMap, json['eventType']),
      deviceTimestamp: DateTime.parse(json['deviceTimestamp'] as String),
      serverTimestamp: json['serverTimestamp'] == null
          ? null
          : DateTime.parse(json['serverTimestamp'] as String),
      sequence: (json['sequence'] as num).toInt(),
      locationEvidence: json['locationEvidence'] == null
          ? null
          : AttendanceLocationEvidence.fromJson(
              json['locationEvidence'] as Map<String, dynamic>,
            ),
      workLocationId: json['workLocationId'] as String?,
      locationValidation: AttendanceLocationValidation.fromJson(
        json['locationValidation'] as Map<String, dynamic>,
      ),
      requestId: json['requestId'] as String,
      source: $enumDecode(_$AttendanceEventSourceEnumMap, json['source']),
      syncStatus: $enumDecode(
        _$AttendanceSyncStatusEnumMap,
        json['syncStatus'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AttendanceEventToJson(_AttendanceEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'attendanceDayId': instance.attendanceDayId,
      'companyId': instance.companyId,
      'employeeId': instance.employeeId,
      'eventType': _$AttendanceEventTypeEnumMap[instance.eventType]!,
      'deviceTimestamp': instance.deviceTimestamp.toIso8601String(),
      'serverTimestamp': instance.serverTimestamp?.toIso8601String(),
      'sequence': instance.sequence,
      'locationEvidence': instance.locationEvidence?.toJson(),
      'workLocationId': instance.workLocationId,
      'locationValidation': instance.locationValidation.toJson(),
      'requestId': instance.requestId,
      'source': _$AttendanceEventSourceEnumMap[instance.source]!,
      'syncStatus': _$AttendanceSyncStatusEnumMap[instance.syncStatus]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$AttendanceEventTypeEnumMap = {
  AttendanceEventType.punchIn: 'punchIn',
  AttendanceEventType.breakStart: 'breakStart',
  AttendanceEventType.breakEnd: 'breakEnd',
  AttendanceEventType.punchOut: 'punchOut',
};

const _$AttendanceEventSourceEnumMap = {
  AttendanceEventSource.mobile: 'mobile',
  AttendanceEventSource.web: 'web',
  AttendanceEventSource.manual: 'manual',
  AttendanceEventSource.kiosk: 'kiosk',
};
