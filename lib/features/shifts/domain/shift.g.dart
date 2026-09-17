// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Shift _$ShiftFromJson(Map<String, dynamic> json) => _Shift(
  id: json['id'] as String,
  companyId: json['companyId'] as String,
  name: json['name'] as String,
  code: json['code'] as String?,
  startTime: LocalTime.fromJson(json['startTime'] as Map<String, dynamic>),
  endTime: LocalTime.fromJson(json['endTime'] as Map<String, dynamic>),
  workingDays: (json['workingDays'] as List<dynamic>)
      .map((e) => $enumDecode(_$WorkingDayEnumMap, e))
      .toSet(),
  gracePeriodMinutes: (json['gracePeriodMinutes'] as num?)?.toInt() ?? 0,
  breakMode:
      $enumDecodeNullable(_$ShiftBreakModeEnumMap, json['breakMode']) ??
      ShiftBreakMode.manualBreak,
  defaultBreakMinutes: (json['defaultBreakMinutes'] as num?)?.toInt(),
  minimumWorkMinutes: (json['minimumWorkMinutes'] as num?)?.toInt(),
  status:
      $enumDecodeNullable(_$ConfigurationStatusEnumMap, json['status']) ??
      ConfigurationStatus.active,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus:
      $enumDecodeNullable(_$RecordSyncStatusEnumMap, json['syncStatus']) ??
      RecordSyncStatus.pending,
);

Map<String, dynamic> _$ShiftToJson(_Shift instance) => <String, dynamic>{
  'id': instance.id,
  'companyId': instance.companyId,
  'name': instance.name,
  'code': instance.code,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'workingDays': instance.workingDays
      .map((e) => _$WorkingDayEnumMap[e]!)
      .toList(),
  'gracePeriodMinutes': instance.gracePeriodMinutes,
  'breakMode': _$ShiftBreakModeEnumMap[instance.breakMode]!,
  'defaultBreakMinutes': instance.defaultBreakMinutes,
  'minimumWorkMinutes': instance.minimumWorkMinutes,
  'status': _$ConfigurationStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'syncStatus': _$RecordSyncStatusEnumMap[instance.syncStatus]!,
};

const _$WorkingDayEnumMap = {
  WorkingDay.monday: 'monday',
  WorkingDay.tuesday: 'tuesday',
  WorkingDay.wednesday: 'wednesday',
  WorkingDay.thursday: 'thursday',
  WorkingDay.friday: 'friday',
  WorkingDay.saturday: 'saturday',
  WorkingDay.sunday: 'sunday',
};

const _$ShiftBreakModeEnumMap = {
  ShiftBreakMode.manualBreak: 'manualBreak',
  ShiftBreakMode.fixedBreak: 'fixedBreak',
  ShiftBreakMode.noBreak: 'noBreak',
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
