// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkLocation _$WorkLocationFromJson(Map<String, dynamic> json) =>
    _WorkLocation(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String? ?? '',
      city: json['city'] as String,
      stateRegion: json['stateRegion'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      countryCode: json['countryCode'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      allowedRadiusMeters: (json['allowedRadiusMeters'] as num).toDouble(),
      maximumAccuracyMeters: (json['maximumAccuracyMeters'] as num?)
          ?.toDouble(),
      validationMode:
          $enumDecodeNullable(
            _$LocationValidationModeEnumMap,
            json['validationMode'],
          ) ??
          LocationValidationMode.geofenceRequired,
      status:
          $enumDecodeNullable(_$ConfigurationStatusEnumMap, json['status']) ??
          ConfigurationStatus.active,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus:
          $enumDecodeNullable(_$RecordSyncStatusEnumMap, json['syncStatus']) ??
          RecordSyncStatus.pending,
    );

Map<String, dynamic> _$WorkLocationToJson(
  _WorkLocation instance,
) => <String, dynamic>{
  'id': instance.id,
  'companyId': instance.companyId,
  'name': instance.name,
  'code': instance.code,
  'addressLine1': instance.addressLine1,
  'addressLine2': instance.addressLine2,
  'city': instance.city,
  'stateRegion': instance.stateRegion,
  'postalCode': instance.postalCode,
  'countryCode': instance.countryCode,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'allowedRadiusMeters': instance.allowedRadiusMeters,
  'maximumAccuracyMeters': instance.maximumAccuracyMeters,
  'validationMode': _$LocationValidationModeEnumMap[instance.validationMode]!,
  'status': _$ConfigurationStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'syncStatus': _$RecordSyncStatusEnumMap[instance.syncStatus]!,
};

const _$LocationValidationModeEnumMap = {
  LocationValidationMode.geofenceRequired: 'geofenceRequired',
  LocationValidationMode.geofencePreferred: 'geofencePreferred',
  LocationValidationMode.locationCaptureOnly: 'locationCaptureOnly',
  LocationValidationMode.none: 'none',
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
