// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_policy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendancePolicy _$AttendancePolicyFromJson(
  Map<String, dynamic> json,
) => _AttendancePolicy(
  id: json['id'] as String,
  companyId: json['companyId'] as String,
  name: json['name'] as String,
  description: json['description'] as String? ?? '',
  requireLocation: json['requireLocation'] as bool? ?? true,
  allowOutsideLocation: json['allowOutsideLocation'] as bool? ?? false,
  allowRemoteAttendance: json['allowRemoteAttendance'] as bool? ?? false,
  requireLocationOnPunchIn: json['requireLocationOnPunchIn'] as bool? ?? true,
  requireLocationOnPunchOut: json['requireLocationOnPunchOut'] as bool? ?? true,
  requireLocationOnBreak: json['requireLocationOnBreak'] as bool? ?? false,
  requireLocationAccuracy: json['requireLocationAccuracy'] as bool? ?? false,
  maximumAcceptedAccuracyMeters: (json['maximumAcceptedAccuracyMeters'] as num?)
      ?.toDouble(),
  trackBreaks: json['trackBreaks'] as bool? ?? true,
  allowMultipleBreaks: json['allowMultipleBreaks'] as bool? ?? true,
  allowPunchOutDuringBreak: json['allowPunchOutDuringBreak'] as bool? ?? false,
  allowEmployeeCorrectionRequest:
      json['allowEmployeeCorrectionRequest'] as bool? ?? true,
  allowEarlyPunchIn: json['allowEarlyPunchIn'] as bool? ?? false,
  earlyPunchInLimitMinutes: (json['earlyPunchInLimitMinutes'] as num?)?.toInt(),
  allowLatePunchIn: json['allowLatePunchIn'] as bool? ?? true,
  allowEarlyPunchOut: json['allowEarlyPunchOut'] as bool? ?? false,
  offlineMode:
      $enumDecodeNullable(
        _$OfflineAttendanceModeEnumMap,
        json['offlineMode'],
      ) ??
      OfflineAttendanceMode.allowPending,
  status:
      $enumDecodeNullable(_$ConfigurationStatusEnumMap, json['status']) ??
      ConfigurationStatus.active,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus:
      $enumDecodeNullable(_$RecordSyncStatusEnumMap, json['syncStatus']) ??
      RecordSyncStatus.pending,
);

Map<String, dynamic> _$AttendancePolicyToJson(_AttendancePolicy instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'name': instance.name,
      'description': instance.description,
      'requireLocation': instance.requireLocation,
      'allowOutsideLocation': instance.allowOutsideLocation,
      'allowRemoteAttendance': instance.allowRemoteAttendance,
      'requireLocationOnPunchIn': instance.requireLocationOnPunchIn,
      'requireLocationOnPunchOut': instance.requireLocationOnPunchOut,
      'requireLocationOnBreak': instance.requireLocationOnBreak,
      'requireLocationAccuracy': instance.requireLocationAccuracy,
      'maximumAcceptedAccuracyMeters': instance.maximumAcceptedAccuracyMeters,
      'trackBreaks': instance.trackBreaks,
      'allowMultipleBreaks': instance.allowMultipleBreaks,
      'allowPunchOutDuringBreak': instance.allowPunchOutDuringBreak,
      'allowEmployeeCorrectionRequest': instance.allowEmployeeCorrectionRequest,
      'allowEarlyPunchIn': instance.allowEarlyPunchIn,
      'earlyPunchInLimitMinutes': instance.earlyPunchInLimitMinutes,
      'allowLatePunchIn': instance.allowLatePunchIn,
      'allowEarlyPunchOut': instance.allowEarlyPunchOut,
      'offlineMode': _$OfflineAttendanceModeEnumMap[instance.offlineMode]!,
      'status': _$ConfigurationStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': _$RecordSyncStatusEnumMap[instance.syncStatus]!,
    };

const _$OfflineAttendanceModeEnumMap = {
  OfflineAttendanceMode.notAllowed: 'notAllowed',
  OfflineAttendanceMode.allowPending: 'allowPending',
  OfflineAttendanceMode.allowWithWarning: 'allowWithWarning',
};

const _$ConfigurationStatusEnumMap = {
  ConfigurationStatus.active: 'active',
  ConfigurationStatus.inactive: 'inactive',
};

const _$RecordSyncStatusEnumMap = {
  RecordSyncStatus.synced: 'synced',
  RecordSyncStatus.pending: 'pending',
  RecordSyncStatus.failed: 'failed',
};
