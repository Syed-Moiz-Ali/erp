import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
part 'work_location.freezed.dart';
part 'work_location.g.dart';

enum LocationValidationMode {
  geofenceRequired,
  geofencePreferred,
  locationCaptureOnly,
  none,
}

@freezed
abstract class WorkLocation with _$WorkLocation implements ConfigurationRecord {
  const WorkLocation._();
  const factory WorkLocation({
    required String id,
    required String companyId,
    required String name,
    String? code,
    required String addressLine1,
    @Default('') String addressLine2,
    required String city,
    @Default('') String stateRegion,
    @Default('') String postalCode,
    required String countryCode,
    required double latitude,
    required double longitude,
    required double allowedRadiusMeters,
    double? maximumAccuracyMeters,
    @Default(LocationValidationMode.geofenceRequired)
    LocationValidationMode validationMode,
    @Default(ConfigurationStatus.active) ConfigurationStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(RecordSyncStatus.pending) RecordSyncStatus syncStatus,
  }) = _WorkLocation;
  String get address => [
    addressLine1,
    addressLine2,
    city,
    stateRegion,
    postalCode,
    countryCode,
  ].where((v) => v.isNotEmpty).join(', ');
  factory WorkLocation.fromJson(Map<String, dynamic> json) =>
      _$WorkLocationFromJson(json);
}

@freezed
abstract class WorkLocationDraft with _$WorkLocationDraft {
  const WorkLocationDraft._();
  const factory WorkLocationDraft({
    @Default('') String name,
    @Default('') String code,
    @Default('') String addressLine1,
    @Default('') String addressLine2,
    @Default('') String city,
    @Default('') String stateRegion,
    @Default('') String postalCode,
    @Default('') String countryCode,
    double? latitude,
    double? longitude,
    @Default(150) double? allowedRadiusMeters,
    double? maximumAccuracyMeters,
    @Default(LocationValidationMode.geofenceRequired)
    LocationValidationMode validationMode,
    @Default(ConfigurationStatus.active) ConfigurationStatus status,
  }) = _WorkLocationDraft;
  WorkLocationDraft normalized() => copyWith(
    name: name.trim(),
    code: code.trim().toUpperCase(),
    addressLine1: addressLine1.trim(),
    addressLine2: addressLine2.trim(),
    city: city.trim(),
    stateRegion: stateRegion.trim(),
    postalCode: postalCode.trim(),
    countryCode: countryCode.trim().toUpperCase(),
  );
  Map<String, String> validate() {
    final errors = <String, String>{};
    if (name.trim().isEmpty) errors['name'] = 'required';
    if (addressLine1.trim().isEmpty) errors['addressLine1'] = 'required';
    if (city.trim().isEmpty) errors['city'] = 'required';
    if (!RegExp(r'^[A-Za-z]{2}$').hasMatch(countryCode.trim())) {
      errors['countryCode'] = 'countryCode';
    }
    if (latitude == null ||
        !latitude!.isFinite ||
        latitude! < -90 ||
        latitude! > 90) {
      errors['latitude'] = 'invalidCoordinates';
    }
    if (longitude == null ||
        !longitude!.isFinite ||
        longitude! < -180 ||
        longitude! > 180) {
      errors['longitude'] = 'invalidCoordinates';
    }
    if (allowedRadiusMeters == null ||
        !allowedRadiusMeters!.isFinite ||
        allowedRadiusMeters! <= 0) {
      errors['allowedRadiusMeters'] = 'invalidRadius';
    }
    if (maximumAccuracyMeters != null &&
        (!maximumAccuracyMeters!.isFinite || maximumAccuracyMeters! <= 0)) {
      errors['maximumAccuracyMeters'] = 'invalidAccuracy';
    }
    return Map.unmodifiable(errors);
  }

  factory WorkLocationDraft.fromLocation(WorkLocation l) => WorkLocationDraft(
    name: l.name,
    code: l.code ?? '',
    addressLine1: l.addressLine1,
    addressLine2: l.addressLine2,
    city: l.city,
    stateRegion: l.stateRegion,
    postalCode: l.postalCode,
    countryCode: l.countryCode,
    latitude: l.latitude,
    longitude: l.longitude,
    allowedRadiusMeters: l.allowedRadiusMeters,
    maximumAccuracyMeters: l.maximumAccuracyMeters,
    validationMode: l.validationMode,
    status: l.status,
  );
}
