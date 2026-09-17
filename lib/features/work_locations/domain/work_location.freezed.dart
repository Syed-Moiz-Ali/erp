// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'work_location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkLocation {

 String get id; String get companyId; String get name; String? get code; String get addressLine1; String get addressLine2; String get city; String get stateRegion; String get postalCode; String get countryCode; double get latitude; double get longitude; double get allowedRadiusMeters; double? get maximumAccuracyMeters; LocationValidationMode get validationMode; ConfigurationStatus get status; DateTime get createdAt; DateTime get updatedAt; RecordSyncStatus get syncStatus;
/// Create a copy of WorkLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkLocationCopyWith<WorkLocation> get copyWith => _$WorkLocationCopyWithImpl<WorkLocation>(this as WorkLocation, _$identity);

  /// Serializes this WorkLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkLocation&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.addressLine1, addressLine1) || other.addressLine1 == addressLine1)&&(identical(other.addressLine2, addressLine2) || other.addressLine2 == addressLine2)&&(identical(other.city, city) || other.city == city)&&(identical(other.stateRegion, stateRegion) || other.stateRegion == stateRegion)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.allowedRadiusMeters, allowedRadiusMeters) || other.allowedRadiusMeters == allowedRadiusMeters)&&(identical(other.maximumAccuracyMeters, maximumAccuracyMeters) || other.maximumAccuracyMeters == maximumAccuracyMeters)&&(identical(other.validationMode, validationMode) || other.validationMode == validationMode)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,name,code,addressLine1,addressLine2,city,stateRegion,postalCode,countryCode,latitude,longitude,allowedRadiusMeters,maximumAccuracyMeters,validationMode,status,createdAt,updatedAt,syncStatus]);

@override
String toString() {
  return 'WorkLocation(id: $id, companyId: $companyId, name: $name, code: $code, addressLine1: $addressLine1, addressLine2: $addressLine2, city: $city, stateRegion: $stateRegion, postalCode: $postalCode, countryCode: $countryCode, latitude: $latitude, longitude: $longitude, allowedRadiusMeters: $allowedRadiusMeters, maximumAccuracyMeters: $maximumAccuracyMeters, validationMode: $validationMode, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $WorkLocationCopyWith<$Res>  {
  factory $WorkLocationCopyWith(WorkLocation value, $Res Function(WorkLocation) _then) = _$WorkLocationCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String name, String? code, String addressLine1, String addressLine2, String city, String stateRegion, String postalCode, String countryCode, double latitude, double longitude, double allowedRadiusMeters, double? maximumAccuracyMeters, LocationValidationMode validationMode, ConfigurationStatus status, DateTime createdAt, DateTime updatedAt, RecordSyncStatus syncStatus
});




}
/// @nodoc
class _$WorkLocationCopyWithImpl<$Res>
    implements $WorkLocationCopyWith<$Res> {
  _$WorkLocationCopyWithImpl(this._self, this._then);

  final WorkLocation _self;
  final $Res Function(WorkLocation) _then;

/// Create a copy of WorkLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? code = freezed,Object? addressLine1 = null,Object? addressLine2 = null,Object? city = null,Object? stateRegion = null,Object? postalCode = null,Object? countryCode = null,Object? latitude = null,Object? longitude = null,Object? allowedRadiusMeters = null,Object? maximumAccuracyMeters = freezed,Object? validationMode = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,addressLine1: null == addressLine1 ? _self.addressLine1 : addressLine1 // ignore: cast_nullable_to_non_nullable
as String,addressLine2: null == addressLine2 ? _self.addressLine2 : addressLine2 // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,stateRegion: null == stateRegion ? _self.stateRegion : stateRegion // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,allowedRadiusMeters: null == allowedRadiusMeters ? _self.allowedRadiusMeters : allowedRadiusMeters // ignore: cast_nullable_to_non_nullable
as double,maximumAccuracyMeters: freezed == maximumAccuracyMeters ? _self.maximumAccuracyMeters : maximumAccuracyMeters // ignore: cast_nullable_to_non_nullable
as double?,validationMode: null == validationMode ? _self.validationMode : validationMode // ignore: cast_nullable_to_non_nullable
as LocationValidationMode,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as RecordSyncStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkLocation].
extension WorkLocationPatterns on WorkLocation {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkLocation() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkLocation value)  $default,){
final _that = this;
switch (_that) {
case _WorkLocation():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkLocation value)?  $default,){
final _that = this;
switch (_that) {
case _WorkLocation() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  String? code,  String addressLine1,  String addressLine2,  String city,  String stateRegion,  String postalCode,  String countryCode,  double latitude,  double longitude,  double allowedRadiusMeters,  double? maximumAccuracyMeters,  LocationValidationMode validationMode,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkLocation() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.code,_that.addressLine1,_that.addressLine2,_that.city,_that.stateRegion,_that.postalCode,_that.countryCode,_that.latitude,_that.longitude,_that.allowedRadiusMeters,_that.maximumAccuracyMeters,_that.validationMode,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  String? code,  String addressLine1,  String addressLine2,  String city,  String stateRegion,  String postalCode,  String countryCode,  double latitude,  double longitude,  double allowedRadiusMeters,  double? maximumAccuracyMeters,  LocationValidationMode validationMode,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)  $default,) {final _that = this;
switch (_that) {
case _WorkLocation():
return $default(_that.id,_that.companyId,_that.name,_that.code,_that.addressLine1,_that.addressLine2,_that.city,_that.stateRegion,_that.postalCode,_that.countryCode,_that.latitude,_that.longitude,_that.allowedRadiusMeters,_that.maximumAccuracyMeters,_that.validationMode,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String name,  String? code,  String addressLine1,  String addressLine2,  String city,  String stateRegion,  String postalCode,  String countryCode,  double latitude,  double longitude,  double allowedRadiusMeters,  double? maximumAccuracyMeters,  LocationValidationMode validationMode,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _WorkLocation() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.code,_that.addressLine1,_that.addressLine2,_that.city,_that.stateRegion,_that.postalCode,_that.countryCode,_that.latitude,_that.longitude,_that.allowedRadiusMeters,_that.maximumAccuracyMeters,_that.validationMode,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkLocation extends WorkLocation {
  const _WorkLocation({required this.id, required this.companyId, required this.name, this.code, required this.addressLine1, this.addressLine2 = '', required this.city, this.stateRegion = '', this.postalCode = '', required this.countryCode, required this.latitude, required this.longitude, required this.allowedRadiusMeters, this.maximumAccuracyMeters, this.validationMode = LocationValidationMode.geofenceRequired, this.status = ConfigurationStatus.active, required this.createdAt, required this.updatedAt, this.syncStatus = RecordSyncStatus.pending}): super._();
  factory _WorkLocation.fromJson(Map<String, dynamic> json) => _$WorkLocationFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  String name;
@override final  String? code;
@override final  String addressLine1;
@override@JsonKey() final  String addressLine2;
@override final  String city;
@override@JsonKey() final  String stateRegion;
@override@JsonKey() final  String postalCode;
@override final  String countryCode;
@override final  double latitude;
@override final  double longitude;
@override final  double allowedRadiusMeters;
@override final  double? maximumAccuracyMeters;
@override@JsonKey() final  LocationValidationMode validationMode;
@override@JsonKey() final  ConfigurationStatus status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  RecordSyncStatus syncStatus;

/// Create a copy of WorkLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkLocationCopyWith<_WorkLocation> get copyWith => __$WorkLocationCopyWithImpl<_WorkLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkLocation&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.addressLine1, addressLine1) || other.addressLine1 == addressLine1)&&(identical(other.addressLine2, addressLine2) || other.addressLine2 == addressLine2)&&(identical(other.city, city) || other.city == city)&&(identical(other.stateRegion, stateRegion) || other.stateRegion == stateRegion)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.allowedRadiusMeters, allowedRadiusMeters) || other.allowedRadiusMeters == allowedRadiusMeters)&&(identical(other.maximumAccuracyMeters, maximumAccuracyMeters) || other.maximumAccuracyMeters == maximumAccuracyMeters)&&(identical(other.validationMode, validationMode) || other.validationMode == validationMode)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,name,code,addressLine1,addressLine2,city,stateRegion,postalCode,countryCode,latitude,longitude,allowedRadiusMeters,maximumAccuracyMeters,validationMode,status,createdAt,updatedAt,syncStatus]);

@override
String toString() {
  return 'WorkLocation(id: $id, companyId: $companyId, name: $name, code: $code, addressLine1: $addressLine1, addressLine2: $addressLine2, city: $city, stateRegion: $stateRegion, postalCode: $postalCode, countryCode: $countryCode, latitude: $latitude, longitude: $longitude, allowedRadiusMeters: $allowedRadiusMeters, maximumAccuracyMeters: $maximumAccuracyMeters, validationMode: $validationMode, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$WorkLocationCopyWith<$Res> implements $WorkLocationCopyWith<$Res> {
  factory _$WorkLocationCopyWith(_WorkLocation value, $Res Function(_WorkLocation) _then) = __$WorkLocationCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String name, String? code, String addressLine1, String addressLine2, String city, String stateRegion, String postalCode, String countryCode, double latitude, double longitude, double allowedRadiusMeters, double? maximumAccuracyMeters, LocationValidationMode validationMode, ConfigurationStatus status, DateTime createdAt, DateTime updatedAt, RecordSyncStatus syncStatus
});




}
/// @nodoc
class __$WorkLocationCopyWithImpl<$Res>
    implements _$WorkLocationCopyWith<$Res> {
  __$WorkLocationCopyWithImpl(this._self, this._then);

  final _WorkLocation _self;
  final $Res Function(_WorkLocation) _then;

/// Create a copy of WorkLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? code = freezed,Object? addressLine1 = null,Object? addressLine2 = null,Object? city = null,Object? stateRegion = null,Object? postalCode = null,Object? countryCode = null,Object? latitude = null,Object? longitude = null,Object? allowedRadiusMeters = null,Object? maximumAccuracyMeters = freezed,Object? validationMode = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,}) {
  return _then(_WorkLocation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,addressLine1: null == addressLine1 ? _self.addressLine1 : addressLine1 // ignore: cast_nullable_to_non_nullable
as String,addressLine2: null == addressLine2 ? _self.addressLine2 : addressLine2 // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,stateRegion: null == stateRegion ? _self.stateRegion : stateRegion // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,allowedRadiusMeters: null == allowedRadiusMeters ? _self.allowedRadiusMeters : allowedRadiusMeters // ignore: cast_nullable_to_non_nullable
as double,maximumAccuracyMeters: freezed == maximumAccuracyMeters ? _self.maximumAccuracyMeters : maximumAccuracyMeters // ignore: cast_nullable_to_non_nullable
as double?,validationMode: null == validationMode ? _self.validationMode : validationMode // ignore: cast_nullable_to_non_nullable
as LocationValidationMode,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as RecordSyncStatus,
  ));
}


}

/// @nodoc
mixin _$WorkLocationDraft {

 String get name; String get code; String get addressLine1; String get addressLine2; String get city; String get stateRegion; String get postalCode; String get countryCode; double? get latitude; double? get longitude; double? get allowedRadiusMeters; double? get maximumAccuracyMeters; LocationValidationMode get validationMode; ConfigurationStatus get status;
/// Create a copy of WorkLocationDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkLocationDraftCopyWith<WorkLocationDraft> get copyWith => _$WorkLocationDraftCopyWithImpl<WorkLocationDraft>(this as WorkLocationDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkLocationDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.addressLine1, addressLine1) || other.addressLine1 == addressLine1)&&(identical(other.addressLine2, addressLine2) || other.addressLine2 == addressLine2)&&(identical(other.city, city) || other.city == city)&&(identical(other.stateRegion, stateRegion) || other.stateRegion == stateRegion)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.allowedRadiusMeters, allowedRadiusMeters) || other.allowedRadiusMeters == allowedRadiusMeters)&&(identical(other.maximumAccuracyMeters, maximumAccuracyMeters) || other.maximumAccuracyMeters == maximumAccuracyMeters)&&(identical(other.validationMode, validationMode) || other.validationMode == validationMode)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,name,code,addressLine1,addressLine2,city,stateRegion,postalCode,countryCode,latitude,longitude,allowedRadiusMeters,maximumAccuracyMeters,validationMode,status);

@override
String toString() {
  return 'WorkLocationDraft(name: $name, code: $code, addressLine1: $addressLine1, addressLine2: $addressLine2, city: $city, stateRegion: $stateRegion, postalCode: $postalCode, countryCode: $countryCode, latitude: $latitude, longitude: $longitude, allowedRadiusMeters: $allowedRadiusMeters, maximumAccuracyMeters: $maximumAccuracyMeters, validationMode: $validationMode, status: $status)';
}


}

/// @nodoc
abstract mixin class $WorkLocationDraftCopyWith<$Res>  {
  factory $WorkLocationDraftCopyWith(WorkLocationDraft value, $Res Function(WorkLocationDraft) _then) = _$WorkLocationDraftCopyWithImpl;
@useResult
$Res call({
 String name, String code, String addressLine1, String addressLine2, String city, String stateRegion, String postalCode, String countryCode, double? latitude, double? longitude, double? allowedRadiusMeters, double? maximumAccuracyMeters, LocationValidationMode validationMode, ConfigurationStatus status
});




}
/// @nodoc
class _$WorkLocationDraftCopyWithImpl<$Res>
    implements $WorkLocationDraftCopyWith<$Res> {
  _$WorkLocationDraftCopyWithImpl(this._self, this._then);

  final WorkLocationDraft _self;
  final $Res Function(WorkLocationDraft) _then;

/// Create a copy of WorkLocationDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? code = null,Object? addressLine1 = null,Object? addressLine2 = null,Object? city = null,Object? stateRegion = null,Object? postalCode = null,Object? countryCode = null,Object? latitude = freezed,Object? longitude = freezed,Object? allowedRadiusMeters = freezed,Object? maximumAccuracyMeters = freezed,Object? validationMode = null,Object? status = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,addressLine1: null == addressLine1 ? _self.addressLine1 : addressLine1 // ignore: cast_nullable_to_non_nullable
as String,addressLine2: null == addressLine2 ? _self.addressLine2 : addressLine2 // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,stateRegion: null == stateRegion ? _self.stateRegion : stateRegion // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,allowedRadiusMeters: freezed == allowedRadiusMeters ? _self.allowedRadiusMeters : allowedRadiusMeters // ignore: cast_nullable_to_non_nullable
as double?,maximumAccuracyMeters: freezed == maximumAccuracyMeters ? _self.maximumAccuracyMeters : maximumAccuracyMeters // ignore: cast_nullable_to_non_nullable
as double?,validationMode: null == validationMode ? _self.validationMode : validationMode // ignore: cast_nullable_to_non_nullable
as LocationValidationMode,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkLocationDraft].
extension WorkLocationDraftPatterns on WorkLocationDraft {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkLocationDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkLocationDraft() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkLocationDraft value)  $default,){
final _that = this;
switch (_that) {
case _WorkLocationDraft():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkLocationDraft value)?  $default,){
final _that = this;
switch (_that) {
case _WorkLocationDraft() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String code,  String addressLine1,  String addressLine2,  String city,  String stateRegion,  String postalCode,  String countryCode,  double? latitude,  double? longitude,  double? allowedRadiusMeters,  double? maximumAccuracyMeters,  LocationValidationMode validationMode,  ConfigurationStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkLocationDraft() when $default != null:
return $default(_that.name,_that.code,_that.addressLine1,_that.addressLine2,_that.city,_that.stateRegion,_that.postalCode,_that.countryCode,_that.latitude,_that.longitude,_that.allowedRadiusMeters,_that.maximumAccuracyMeters,_that.validationMode,_that.status);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String code,  String addressLine1,  String addressLine2,  String city,  String stateRegion,  String postalCode,  String countryCode,  double? latitude,  double? longitude,  double? allowedRadiusMeters,  double? maximumAccuracyMeters,  LocationValidationMode validationMode,  ConfigurationStatus status)  $default,) {final _that = this;
switch (_that) {
case _WorkLocationDraft():
return $default(_that.name,_that.code,_that.addressLine1,_that.addressLine2,_that.city,_that.stateRegion,_that.postalCode,_that.countryCode,_that.latitude,_that.longitude,_that.allowedRadiusMeters,_that.maximumAccuracyMeters,_that.validationMode,_that.status);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String code,  String addressLine1,  String addressLine2,  String city,  String stateRegion,  String postalCode,  String countryCode,  double? latitude,  double? longitude,  double? allowedRadiusMeters,  double? maximumAccuracyMeters,  LocationValidationMode validationMode,  ConfigurationStatus status)?  $default,) {final _that = this;
switch (_that) {
case _WorkLocationDraft() when $default != null:
return $default(_that.name,_that.code,_that.addressLine1,_that.addressLine2,_that.city,_that.stateRegion,_that.postalCode,_that.countryCode,_that.latitude,_that.longitude,_that.allowedRadiusMeters,_that.maximumAccuracyMeters,_that.validationMode,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _WorkLocationDraft extends WorkLocationDraft {
  const _WorkLocationDraft({this.name = '', this.code = '', this.addressLine1 = '', this.addressLine2 = '', this.city = '', this.stateRegion = '', this.postalCode = '', this.countryCode = '', this.latitude, this.longitude, this.allowedRadiusMeters = 150, this.maximumAccuracyMeters, this.validationMode = LocationValidationMode.geofenceRequired, this.status = ConfigurationStatus.active}): super._();
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String code;
@override@JsonKey() final  String addressLine1;
@override@JsonKey() final  String addressLine2;
@override@JsonKey() final  String city;
@override@JsonKey() final  String stateRegion;
@override@JsonKey() final  String postalCode;
@override@JsonKey() final  String countryCode;
@override final  double? latitude;
@override final  double? longitude;
@override@JsonKey() final  double? allowedRadiusMeters;
@override final  double? maximumAccuracyMeters;
@override@JsonKey() final  LocationValidationMode validationMode;
@override@JsonKey() final  ConfigurationStatus status;

/// Create a copy of WorkLocationDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkLocationDraftCopyWith<_WorkLocationDraft> get copyWith => __$WorkLocationDraftCopyWithImpl<_WorkLocationDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkLocationDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.addressLine1, addressLine1) || other.addressLine1 == addressLine1)&&(identical(other.addressLine2, addressLine2) || other.addressLine2 == addressLine2)&&(identical(other.city, city) || other.city == city)&&(identical(other.stateRegion, stateRegion) || other.stateRegion == stateRegion)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.allowedRadiusMeters, allowedRadiusMeters) || other.allowedRadiusMeters == allowedRadiusMeters)&&(identical(other.maximumAccuracyMeters, maximumAccuracyMeters) || other.maximumAccuracyMeters == maximumAccuracyMeters)&&(identical(other.validationMode, validationMode) || other.validationMode == validationMode)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,name,code,addressLine1,addressLine2,city,stateRegion,postalCode,countryCode,latitude,longitude,allowedRadiusMeters,maximumAccuracyMeters,validationMode,status);

@override
String toString() {
  return 'WorkLocationDraft(name: $name, code: $code, addressLine1: $addressLine1, addressLine2: $addressLine2, city: $city, stateRegion: $stateRegion, postalCode: $postalCode, countryCode: $countryCode, latitude: $latitude, longitude: $longitude, allowedRadiusMeters: $allowedRadiusMeters, maximumAccuracyMeters: $maximumAccuracyMeters, validationMode: $validationMode, status: $status)';
}


}

/// @nodoc
abstract mixin class _$WorkLocationDraftCopyWith<$Res> implements $WorkLocationDraftCopyWith<$Res> {
  factory _$WorkLocationDraftCopyWith(_WorkLocationDraft value, $Res Function(_WorkLocationDraft) _then) = __$WorkLocationDraftCopyWithImpl;
@override @useResult
$Res call({
 String name, String code, String addressLine1, String addressLine2, String city, String stateRegion, String postalCode, String countryCode, double? latitude, double? longitude, double? allowedRadiusMeters, double? maximumAccuracyMeters, LocationValidationMode validationMode, ConfigurationStatus status
});




}
/// @nodoc
class __$WorkLocationDraftCopyWithImpl<$Res>
    implements _$WorkLocationDraftCopyWith<$Res> {
  __$WorkLocationDraftCopyWithImpl(this._self, this._then);

  final _WorkLocationDraft _self;
  final $Res Function(_WorkLocationDraft) _then;

/// Create a copy of WorkLocationDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? code = null,Object? addressLine1 = null,Object? addressLine2 = null,Object? city = null,Object? stateRegion = null,Object? postalCode = null,Object? countryCode = null,Object? latitude = freezed,Object? longitude = freezed,Object? allowedRadiusMeters = freezed,Object? maximumAccuracyMeters = freezed,Object? validationMode = null,Object? status = null,}) {
  return _then(_WorkLocationDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,addressLine1: null == addressLine1 ? _self.addressLine1 : addressLine1 // ignore: cast_nullable_to_non_nullable
as String,addressLine2: null == addressLine2 ? _self.addressLine2 : addressLine2 // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,stateRegion: null == stateRegion ? _self.stateRegion : stateRegion // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,allowedRadiusMeters: freezed == allowedRadiusMeters ? _self.allowedRadiusMeters : allowedRadiusMeters // ignore: cast_nullable_to_non_nullable
as double?,maximumAccuracyMeters: freezed == maximumAccuracyMeters ? _self.maximumAccuracyMeters : maximumAccuracyMeters // ignore: cast_nullable_to_non_nullable
as double?,validationMode: null == validationMode ? _self.validationMode : validationMode // ignore: cast_nullable_to_non_nullable
as LocationValidationMode,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,
  ));
}


}

// dart format on
