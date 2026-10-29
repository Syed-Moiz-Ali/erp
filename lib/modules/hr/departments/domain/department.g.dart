// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Department _$DepartmentFromJson(Map<String, dynamic> json) => _Department(
  id: json['id'] as String,
  companyId: json['companyId'] as String,
  name: json['name'] as String,
  status:
      $enumDecodeNullable(_$ConfigurationStatusEnumMap, json['status']) ??
      ConfigurationStatus.active,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus:
      $enumDecodeNullable(_$RecordSyncStatusEnumMap, json['syncStatus']) ??
      RecordSyncStatus.synced,
);

Map<String, dynamic> _$DepartmentToJson(_Department instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'name': instance.name,
      'status': _$ConfigurationStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': _$RecordSyncStatusEnumMap[instance.syncStatus]!,
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
