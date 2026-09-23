// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_policy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendancePolicy {

 String get id; String get companyId; String get name; String get description; bool get requireLocation; bool get allowOutsideLocation; bool get allowRemoteAttendance; bool get requireLocationOnPunchIn; bool get requireLocationOnPunchOut; bool get requireLocationOnBreak; bool get requireLocationAccuracy; double? get maximumAcceptedAccuracyMeters; bool get trackBreaks; bool get allowMultipleBreaks; bool get allowPunchOutDuringBreak; bool get allowEmployeeCorrectionRequest; bool get allowEarlyPunchIn; int? get earlyPunchInLimitMinutes; bool get allowLatePunchIn; bool get allowEarlyPunchOut; OfflineAttendanceMode get offlineMode; ConfigurationStatus get status; DateTime get createdAt; DateTime get updatedAt; RecordSyncStatus get syncStatus;
/// Create a copy of AttendancePolicy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendancePolicyCopyWith<AttendancePolicy> get copyWith => _$AttendancePolicyCopyWithImpl<AttendancePolicy>(this as AttendancePolicy, _$identity);

  /// Serializes this AttendancePolicy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendancePolicy&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.requireLocation, requireLocation) || other.requireLocation == requireLocation)&&(identical(other.allowOutsideLocation, allowOutsideLocation) || other.allowOutsideLocation == allowOutsideLocation)&&(identical(other.allowRemoteAttendance, allowRemoteAttendance) || other.allowRemoteAttendance == allowRemoteAttendance)&&(identical(other.requireLocationOnPunchIn, requireLocationOnPunchIn) || other.requireLocationOnPunchIn == requireLocationOnPunchIn)&&(identical(other.requireLocationOnPunchOut, requireLocationOnPunchOut) || other.requireLocationOnPunchOut == requireLocationOnPunchOut)&&(identical(other.requireLocationOnBreak, requireLocationOnBreak) || other.requireLocationOnBreak == requireLocationOnBreak)&&(identical(other.requireLocationAccuracy, requireLocationAccuracy) || other.requireLocationAccuracy == requireLocationAccuracy)&&(identical(other.maximumAcceptedAccuracyMeters, maximumAcceptedAccuracyMeters) || other.maximumAcceptedAccuracyMeters == maximumAcceptedAccuracyMeters)&&(identical(other.trackBreaks, trackBreaks) || other.trackBreaks == trackBreaks)&&(identical(other.allowMultipleBreaks, allowMultipleBreaks) || other.allowMultipleBreaks == allowMultipleBreaks)&&(identical(other.allowPunchOutDuringBreak, allowPunchOutDuringBreak) || other.allowPunchOutDuringBreak == allowPunchOutDuringBreak)&&(identical(other.allowEmployeeCorrectionRequest, allowEmployeeCorrectionRequest) || other.allowEmployeeCorrectionRequest == allowEmployeeCorrectionRequest)&&(identical(other.allowEarlyPunchIn, allowEarlyPunchIn) || other.allowEarlyPunchIn == allowEarlyPunchIn)&&(identical(other.earlyPunchInLimitMinutes, earlyPunchInLimitMinutes) || other.earlyPunchInLimitMinutes == earlyPunchInLimitMinutes)&&(identical(other.allowLatePunchIn, allowLatePunchIn) || other.allowLatePunchIn == allowLatePunchIn)&&(identical(other.allowEarlyPunchOut, allowEarlyPunchOut) || other.allowEarlyPunchOut == allowEarlyPunchOut)&&(identical(other.offlineMode, offlineMode) || other.offlineMode == offlineMode)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,name,description,requireLocation,allowOutsideLocation,allowRemoteAttendance,requireLocationOnPunchIn,requireLocationOnPunchOut,requireLocationOnBreak,requireLocationAccuracy,maximumAcceptedAccuracyMeters,trackBreaks,allowMultipleBreaks,allowPunchOutDuringBreak,allowEmployeeCorrectionRequest,allowEarlyPunchIn,earlyPunchInLimitMinutes,allowLatePunchIn,allowEarlyPunchOut,offlineMode,status,createdAt,updatedAt,syncStatus]);

@override
String toString() {
  return 'AttendancePolicy(id: $id, companyId: $companyId, name: $name, description: $description, requireLocation: $requireLocation, allowOutsideLocation: $allowOutsideLocation, allowRemoteAttendance: $allowRemoteAttendance, requireLocationOnPunchIn: $requireLocationOnPunchIn, requireLocationOnPunchOut: $requireLocationOnPunchOut, requireLocationOnBreak: $requireLocationOnBreak, requireLocationAccuracy: $requireLocationAccuracy, maximumAcceptedAccuracyMeters: $maximumAcceptedAccuracyMeters, trackBreaks: $trackBreaks, allowMultipleBreaks: $allowMultipleBreaks, allowPunchOutDuringBreak: $allowPunchOutDuringBreak, allowEmployeeCorrectionRequest: $allowEmployeeCorrectionRequest, allowEarlyPunchIn: $allowEarlyPunchIn, earlyPunchInLimitMinutes: $earlyPunchInLimitMinutes, allowLatePunchIn: $allowLatePunchIn, allowEarlyPunchOut: $allowEarlyPunchOut, offlineMode: $offlineMode, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $AttendancePolicyCopyWith<$Res>  {
  factory $AttendancePolicyCopyWith(AttendancePolicy value, $Res Function(AttendancePolicy) _then) = _$AttendancePolicyCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String name, String description, bool requireLocation, bool allowOutsideLocation, bool allowRemoteAttendance, bool requireLocationOnPunchIn, bool requireLocationOnPunchOut, bool requireLocationOnBreak, bool requireLocationAccuracy, double? maximumAcceptedAccuracyMeters, bool trackBreaks, bool allowMultipleBreaks, bool allowPunchOutDuringBreak, bool allowEmployeeCorrectionRequest, bool allowEarlyPunchIn, int? earlyPunchInLimitMinutes, bool allowLatePunchIn, bool allowEarlyPunchOut, OfflineAttendanceMode offlineMode, ConfigurationStatus status, DateTime createdAt, DateTime updatedAt, RecordSyncStatus syncStatus
});




}
/// @nodoc
class _$AttendancePolicyCopyWithImpl<$Res>
    implements $AttendancePolicyCopyWith<$Res> {
  _$AttendancePolicyCopyWithImpl(this._self, this._then);

  final AttendancePolicy _self;
  final $Res Function(AttendancePolicy) _then;

/// Create a copy of AttendancePolicy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? description = null,Object? requireLocation = null,Object? allowOutsideLocation = null,Object? allowRemoteAttendance = null,Object? requireLocationOnPunchIn = null,Object? requireLocationOnPunchOut = null,Object? requireLocationOnBreak = null,Object? requireLocationAccuracy = null,Object? maximumAcceptedAccuracyMeters = freezed,Object? trackBreaks = null,Object? allowMultipleBreaks = null,Object? allowPunchOutDuringBreak = null,Object? allowEmployeeCorrectionRequest = null,Object? allowEarlyPunchIn = null,Object? earlyPunchInLimitMinutes = freezed,Object? allowLatePunchIn = null,Object? allowEarlyPunchOut = null,Object? offlineMode = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,requireLocation: null == requireLocation ? _self.requireLocation : requireLocation // ignore: cast_nullable_to_non_nullable
as bool,allowOutsideLocation: null == allowOutsideLocation ? _self.allowOutsideLocation : allowOutsideLocation // ignore: cast_nullable_to_non_nullable
as bool,allowRemoteAttendance: null == allowRemoteAttendance ? _self.allowRemoteAttendance : allowRemoteAttendance // ignore: cast_nullable_to_non_nullable
as bool,requireLocationOnPunchIn: null == requireLocationOnPunchIn ? _self.requireLocationOnPunchIn : requireLocationOnPunchIn // ignore: cast_nullable_to_non_nullable
as bool,requireLocationOnPunchOut: null == requireLocationOnPunchOut ? _self.requireLocationOnPunchOut : requireLocationOnPunchOut // ignore: cast_nullable_to_non_nullable
as bool,requireLocationOnBreak: null == requireLocationOnBreak ? _self.requireLocationOnBreak : requireLocationOnBreak // ignore: cast_nullable_to_non_nullable
as bool,requireLocationAccuracy: null == requireLocationAccuracy ? _self.requireLocationAccuracy : requireLocationAccuracy // ignore: cast_nullable_to_non_nullable
as bool,maximumAcceptedAccuracyMeters: freezed == maximumAcceptedAccuracyMeters ? _self.maximumAcceptedAccuracyMeters : maximumAcceptedAccuracyMeters // ignore: cast_nullable_to_non_nullable
as double?,trackBreaks: null == trackBreaks ? _self.trackBreaks : trackBreaks // ignore: cast_nullable_to_non_nullable
as bool,allowMultipleBreaks: null == allowMultipleBreaks ? _self.allowMultipleBreaks : allowMultipleBreaks // ignore: cast_nullable_to_non_nullable
as bool,allowPunchOutDuringBreak: null == allowPunchOutDuringBreak ? _self.allowPunchOutDuringBreak : allowPunchOutDuringBreak // ignore: cast_nullable_to_non_nullable
as bool,allowEmployeeCorrectionRequest: null == allowEmployeeCorrectionRequest ? _self.allowEmployeeCorrectionRequest : allowEmployeeCorrectionRequest // ignore: cast_nullable_to_non_nullable
as bool,allowEarlyPunchIn: null == allowEarlyPunchIn ? _self.allowEarlyPunchIn : allowEarlyPunchIn // ignore: cast_nullable_to_non_nullable
as bool,earlyPunchInLimitMinutes: freezed == earlyPunchInLimitMinutes ? _self.earlyPunchInLimitMinutes : earlyPunchInLimitMinutes // ignore: cast_nullable_to_non_nullable
as int?,allowLatePunchIn: null == allowLatePunchIn ? _self.allowLatePunchIn : allowLatePunchIn // ignore: cast_nullable_to_non_nullable
as bool,allowEarlyPunchOut: null == allowEarlyPunchOut ? _self.allowEarlyPunchOut : allowEarlyPunchOut // ignore: cast_nullable_to_non_nullable
as bool,offlineMode: null == offlineMode ? _self.offlineMode : offlineMode // ignore: cast_nullable_to_non_nullable
as OfflineAttendanceMode,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as RecordSyncStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendancePolicy].
extension AttendancePolicyPatterns on AttendancePolicy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendancePolicy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendancePolicy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendancePolicy value)  $default,){
final _that = this;
switch (_that) {
case _AttendancePolicy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendancePolicy value)?  $default,){
final _that = this;
switch (_that) {
case _AttendancePolicy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  String description,  bool requireLocation,  bool allowOutsideLocation,  bool allowRemoteAttendance,  bool requireLocationOnPunchIn,  bool requireLocationOnPunchOut,  bool requireLocationOnBreak,  bool requireLocationAccuracy,  double? maximumAcceptedAccuracyMeters,  bool trackBreaks,  bool allowMultipleBreaks,  bool allowPunchOutDuringBreak,  bool allowEmployeeCorrectionRequest,  bool allowEarlyPunchIn,  int? earlyPunchInLimitMinutes,  bool allowLatePunchIn,  bool allowEarlyPunchOut,  OfflineAttendanceMode offlineMode,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendancePolicy() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.description,_that.requireLocation,_that.allowOutsideLocation,_that.allowRemoteAttendance,_that.requireLocationOnPunchIn,_that.requireLocationOnPunchOut,_that.requireLocationOnBreak,_that.requireLocationAccuracy,_that.maximumAcceptedAccuracyMeters,_that.trackBreaks,_that.allowMultipleBreaks,_that.allowPunchOutDuringBreak,_that.allowEmployeeCorrectionRequest,_that.allowEarlyPunchIn,_that.earlyPunchInLimitMinutes,_that.allowLatePunchIn,_that.allowEarlyPunchOut,_that.offlineMode,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  String description,  bool requireLocation,  bool allowOutsideLocation,  bool allowRemoteAttendance,  bool requireLocationOnPunchIn,  bool requireLocationOnPunchOut,  bool requireLocationOnBreak,  bool requireLocationAccuracy,  double? maximumAcceptedAccuracyMeters,  bool trackBreaks,  bool allowMultipleBreaks,  bool allowPunchOutDuringBreak,  bool allowEmployeeCorrectionRequest,  bool allowEarlyPunchIn,  int? earlyPunchInLimitMinutes,  bool allowLatePunchIn,  bool allowEarlyPunchOut,  OfflineAttendanceMode offlineMode,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)  $default,) {final _that = this;
switch (_that) {
case _AttendancePolicy():
return $default(_that.id,_that.companyId,_that.name,_that.description,_that.requireLocation,_that.allowOutsideLocation,_that.allowRemoteAttendance,_that.requireLocationOnPunchIn,_that.requireLocationOnPunchOut,_that.requireLocationOnBreak,_that.requireLocationAccuracy,_that.maximumAcceptedAccuracyMeters,_that.trackBreaks,_that.allowMultipleBreaks,_that.allowPunchOutDuringBreak,_that.allowEmployeeCorrectionRequest,_that.allowEarlyPunchIn,_that.earlyPunchInLimitMinutes,_that.allowLatePunchIn,_that.allowEarlyPunchOut,_that.offlineMode,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String name,  String description,  bool requireLocation,  bool allowOutsideLocation,  bool allowRemoteAttendance,  bool requireLocationOnPunchIn,  bool requireLocationOnPunchOut,  bool requireLocationOnBreak,  bool requireLocationAccuracy,  double? maximumAcceptedAccuracyMeters,  bool trackBreaks,  bool allowMultipleBreaks,  bool allowPunchOutDuringBreak,  bool allowEmployeeCorrectionRequest,  bool allowEarlyPunchIn,  int? earlyPunchInLimitMinutes,  bool allowLatePunchIn,  bool allowEarlyPunchOut,  OfflineAttendanceMode offlineMode,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _AttendancePolicy() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.description,_that.requireLocation,_that.allowOutsideLocation,_that.allowRemoteAttendance,_that.requireLocationOnPunchIn,_that.requireLocationOnPunchOut,_that.requireLocationOnBreak,_that.requireLocationAccuracy,_that.maximumAcceptedAccuracyMeters,_that.trackBreaks,_that.allowMultipleBreaks,_that.allowPunchOutDuringBreak,_that.allowEmployeeCorrectionRequest,_that.allowEarlyPunchIn,_that.earlyPunchInLimitMinutes,_that.allowLatePunchIn,_that.allowEarlyPunchOut,_that.offlineMode,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendancePolicy extends AttendancePolicy {
  const _AttendancePolicy({required this.id, required this.companyId, required this.name, this.description = '', this.requireLocation = true, this.allowOutsideLocation = false, this.allowRemoteAttendance = false, this.requireLocationOnPunchIn = true, this.requireLocationOnPunchOut = true, this.requireLocationOnBreak = false, this.requireLocationAccuracy = false, this.maximumAcceptedAccuracyMeters, this.trackBreaks = true, this.allowMultipleBreaks = true, this.allowPunchOutDuringBreak = false, this.allowEmployeeCorrectionRequest = true, this.allowEarlyPunchIn = false, this.earlyPunchInLimitMinutes, this.allowLatePunchIn = true, this.allowEarlyPunchOut = false, this.offlineMode = OfflineAttendanceMode.allowPending, this.status = ConfigurationStatus.active, required this.createdAt, required this.updatedAt, this.syncStatus = RecordSyncStatus.pending}): super._();
  factory _AttendancePolicy.fromJson(Map<String, dynamic> json) => _$AttendancePolicyFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  String name;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool requireLocation;
@override@JsonKey() final  bool allowOutsideLocation;
@override@JsonKey() final  bool allowRemoteAttendance;
@override@JsonKey() final  bool requireLocationOnPunchIn;
@override@JsonKey() final  bool requireLocationOnPunchOut;
@override@JsonKey() final  bool requireLocationOnBreak;
@override@JsonKey() final  bool requireLocationAccuracy;
@override final  double? maximumAcceptedAccuracyMeters;
@override@JsonKey() final  bool trackBreaks;
@override@JsonKey() final  bool allowMultipleBreaks;
@override@JsonKey() final  bool allowPunchOutDuringBreak;
@override@JsonKey() final  bool allowEmployeeCorrectionRequest;
@override@JsonKey() final  bool allowEarlyPunchIn;
@override final  int? earlyPunchInLimitMinutes;
@override@JsonKey() final  bool allowLatePunchIn;
@override@JsonKey() final  bool allowEarlyPunchOut;
@override@JsonKey() final  OfflineAttendanceMode offlineMode;
@override@JsonKey() final  ConfigurationStatus status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  RecordSyncStatus syncStatus;

/// Create a copy of AttendancePolicy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendancePolicyCopyWith<_AttendancePolicy> get copyWith => __$AttendancePolicyCopyWithImpl<_AttendancePolicy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendancePolicyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendancePolicy&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.requireLocation, requireLocation) || other.requireLocation == requireLocation)&&(identical(other.allowOutsideLocation, allowOutsideLocation) || other.allowOutsideLocation == allowOutsideLocation)&&(identical(other.allowRemoteAttendance, allowRemoteAttendance) || other.allowRemoteAttendance == allowRemoteAttendance)&&(identical(other.requireLocationOnPunchIn, requireLocationOnPunchIn) || other.requireLocationOnPunchIn == requireLocationOnPunchIn)&&(identical(other.requireLocationOnPunchOut, requireLocationOnPunchOut) || other.requireLocationOnPunchOut == requireLocationOnPunchOut)&&(identical(other.requireLocationOnBreak, requireLocationOnBreak) || other.requireLocationOnBreak == requireLocationOnBreak)&&(identical(other.requireLocationAccuracy, requireLocationAccuracy) || other.requireLocationAccuracy == requireLocationAccuracy)&&(identical(other.maximumAcceptedAccuracyMeters, maximumAcceptedAccuracyMeters) || other.maximumAcceptedAccuracyMeters == maximumAcceptedAccuracyMeters)&&(identical(other.trackBreaks, trackBreaks) || other.trackBreaks == trackBreaks)&&(identical(other.allowMultipleBreaks, allowMultipleBreaks) || other.allowMultipleBreaks == allowMultipleBreaks)&&(identical(other.allowPunchOutDuringBreak, allowPunchOutDuringBreak) || other.allowPunchOutDuringBreak == allowPunchOutDuringBreak)&&(identical(other.allowEmployeeCorrectionRequest, allowEmployeeCorrectionRequest) || other.allowEmployeeCorrectionRequest == allowEmployeeCorrectionRequest)&&(identical(other.allowEarlyPunchIn, allowEarlyPunchIn) || other.allowEarlyPunchIn == allowEarlyPunchIn)&&(identical(other.earlyPunchInLimitMinutes, earlyPunchInLimitMinutes) || other.earlyPunchInLimitMinutes == earlyPunchInLimitMinutes)&&(identical(other.allowLatePunchIn, allowLatePunchIn) || other.allowLatePunchIn == allowLatePunchIn)&&(identical(other.allowEarlyPunchOut, allowEarlyPunchOut) || other.allowEarlyPunchOut == allowEarlyPunchOut)&&(identical(other.offlineMode, offlineMode) || other.offlineMode == offlineMode)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,name,description,requireLocation,allowOutsideLocation,allowRemoteAttendance,requireLocationOnPunchIn,requireLocationOnPunchOut,requireLocationOnBreak,requireLocationAccuracy,maximumAcceptedAccuracyMeters,trackBreaks,allowMultipleBreaks,allowPunchOutDuringBreak,allowEmployeeCorrectionRequest,allowEarlyPunchIn,earlyPunchInLimitMinutes,allowLatePunchIn,allowEarlyPunchOut,offlineMode,status,createdAt,updatedAt,syncStatus]);

@override
String toString() {
  return 'AttendancePolicy(id: $id, companyId: $companyId, name: $name, description: $description, requireLocation: $requireLocation, allowOutsideLocation: $allowOutsideLocation, allowRemoteAttendance: $allowRemoteAttendance, requireLocationOnPunchIn: $requireLocationOnPunchIn, requireLocationOnPunchOut: $requireLocationOnPunchOut, requireLocationOnBreak: $requireLocationOnBreak, requireLocationAccuracy: $requireLocationAccuracy, maximumAcceptedAccuracyMeters: $maximumAcceptedAccuracyMeters, trackBreaks: $trackBreaks, allowMultipleBreaks: $allowMultipleBreaks, allowPunchOutDuringBreak: $allowPunchOutDuringBreak, allowEmployeeCorrectionRequest: $allowEmployeeCorrectionRequest, allowEarlyPunchIn: $allowEarlyPunchIn, earlyPunchInLimitMinutes: $earlyPunchInLimitMinutes, allowLatePunchIn: $allowLatePunchIn, allowEarlyPunchOut: $allowEarlyPunchOut, offlineMode: $offlineMode, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$AttendancePolicyCopyWith<$Res> implements $AttendancePolicyCopyWith<$Res> {
  factory _$AttendancePolicyCopyWith(_AttendancePolicy value, $Res Function(_AttendancePolicy) _then) = __$AttendancePolicyCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String name, String description, bool requireLocation, bool allowOutsideLocation, bool allowRemoteAttendance, bool requireLocationOnPunchIn, bool requireLocationOnPunchOut, bool requireLocationOnBreak, bool requireLocationAccuracy, double? maximumAcceptedAccuracyMeters, bool trackBreaks, bool allowMultipleBreaks, bool allowPunchOutDuringBreak, bool allowEmployeeCorrectionRequest, bool allowEarlyPunchIn, int? earlyPunchInLimitMinutes, bool allowLatePunchIn, bool allowEarlyPunchOut, OfflineAttendanceMode offlineMode, ConfigurationStatus status, DateTime createdAt, DateTime updatedAt, RecordSyncStatus syncStatus
});




}
/// @nodoc
class __$AttendancePolicyCopyWithImpl<$Res>
    implements _$AttendancePolicyCopyWith<$Res> {
  __$AttendancePolicyCopyWithImpl(this._self, this._then);

  final _AttendancePolicy _self;
  final $Res Function(_AttendancePolicy) _then;

/// Create a copy of AttendancePolicy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? description = null,Object? requireLocation = null,Object? allowOutsideLocation = null,Object? allowRemoteAttendance = null,Object? requireLocationOnPunchIn = null,Object? requireLocationOnPunchOut = null,Object? requireLocationOnBreak = null,Object? requireLocationAccuracy = null,Object? maximumAcceptedAccuracyMeters = freezed,Object? trackBreaks = null,Object? allowMultipleBreaks = null,Object? allowPunchOutDuringBreak = null,Object? allowEmployeeCorrectionRequest = null,Object? allowEarlyPunchIn = null,Object? earlyPunchInLimitMinutes = freezed,Object? allowLatePunchIn = null,Object? allowEarlyPunchOut = null,Object? offlineMode = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,}) {
  return _then(_AttendancePolicy(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,requireLocation: null == requireLocation ? _self.requireLocation : requireLocation // ignore: cast_nullable_to_non_nullable
as bool,allowOutsideLocation: null == allowOutsideLocation ? _self.allowOutsideLocation : allowOutsideLocation // ignore: cast_nullable_to_non_nullable
as bool,allowRemoteAttendance: null == allowRemoteAttendance ? _self.allowRemoteAttendance : allowRemoteAttendance // ignore: cast_nullable_to_non_nullable
as bool,requireLocationOnPunchIn: null == requireLocationOnPunchIn ? _self.requireLocationOnPunchIn : requireLocationOnPunchIn // ignore: cast_nullable_to_non_nullable
as bool,requireLocationOnPunchOut: null == requireLocationOnPunchOut ? _self.requireLocationOnPunchOut : requireLocationOnPunchOut // ignore: cast_nullable_to_non_nullable
as bool,requireLocationOnBreak: null == requireLocationOnBreak ? _self.requireLocationOnBreak : requireLocationOnBreak // ignore: cast_nullable_to_non_nullable
as bool,requireLocationAccuracy: null == requireLocationAccuracy ? _self.requireLocationAccuracy : requireLocationAccuracy // ignore: cast_nullable_to_non_nullable
as bool,maximumAcceptedAccuracyMeters: freezed == maximumAcceptedAccuracyMeters ? _self.maximumAcceptedAccuracyMeters : maximumAcceptedAccuracyMeters // ignore: cast_nullable_to_non_nullable
as double?,trackBreaks: null == trackBreaks ? _self.trackBreaks : trackBreaks // ignore: cast_nullable_to_non_nullable
as bool,allowMultipleBreaks: null == allowMultipleBreaks ? _self.allowMultipleBreaks : allowMultipleBreaks // ignore: cast_nullable_to_non_nullable
as bool,allowPunchOutDuringBreak: null == allowPunchOutDuringBreak ? _self.allowPunchOutDuringBreak : allowPunchOutDuringBreak // ignore: cast_nullable_to_non_nullable
as bool,allowEmployeeCorrectionRequest: null == allowEmployeeCorrectionRequest ? _self.allowEmployeeCorrectionRequest : allowEmployeeCorrectionRequest // ignore: cast_nullable_to_non_nullable
as bool,allowEarlyPunchIn: null == allowEarlyPunchIn ? _self.allowEarlyPunchIn : allowEarlyPunchIn // ignore: cast_nullable_to_non_nullable
as bool,earlyPunchInLimitMinutes: freezed == earlyPunchInLimitMinutes ? _self.earlyPunchInLimitMinutes : earlyPunchInLimitMinutes // ignore: cast_nullable_to_non_nullable
as int?,allowLatePunchIn: null == allowLatePunchIn ? _self.allowLatePunchIn : allowLatePunchIn // ignore: cast_nullable_to_non_nullable
as bool,allowEarlyPunchOut: null == allowEarlyPunchOut ? _self.allowEarlyPunchOut : allowEarlyPunchOut // ignore: cast_nullable_to_non_nullable
as bool,offlineMode: null == offlineMode ? _self.offlineMode : offlineMode // ignore: cast_nullable_to_non_nullable
as OfflineAttendanceMode,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as RecordSyncStatus,
  ));
}


}

/// @nodoc
mixin _$AttendancePolicyDraft {

 String get name; String get description; bool get requireLocation; bool get allowOutsideLocation; bool get allowRemoteAttendance; bool get requireLocationOnPunchIn; bool get requireLocationOnPunchOut; bool get requireLocationOnBreak; bool get requireLocationAccuracy; double? get maximumAcceptedAccuracyMeters; bool get trackBreaks; bool get allowMultipleBreaks; bool get allowPunchOutDuringBreak; bool get allowEmployeeCorrectionRequest; bool get allowEarlyPunchIn; int? get earlyPunchInLimitMinutes; bool get allowLatePunchIn; bool get allowEarlyPunchOut; OfflineAttendanceMode get offlineMode; ConfigurationStatus get status;
/// Create a copy of AttendancePolicyDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendancePolicyDraftCopyWith<AttendancePolicyDraft> get copyWith => _$AttendancePolicyDraftCopyWithImpl<AttendancePolicyDraft>(this as AttendancePolicyDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendancePolicyDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.requireLocation, requireLocation) || other.requireLocation == requireLocation)&&(identical(other.allowOutsideLocation, allowOutsideLocation) || other.allowOutsideLocation == allowOutsideLocation)&&(identical(other.allowRemoteAttendance, allowRemoteAttendance) || other.allowRemoteAttendance == allowRemoteAttendance)&&(identical(other.requireLocationOnPunchIn, requireLocationOnPunchIn) || other.requireLocationOnPunchIn == requireLocationOnPunchIn)&&(identical(other.requireLocationOnPunchOut, requireLocationOnPunchOut) || other.requireLocationOnPunchOut == requireLocationOnPunchOut)&&(identical(other.requireLocationOnBreak, requireLocationOnBreak) || other.requireLocationOnBreak == requireLocationOnBreak)&&(identical(other.requireLocationAccuracy, requireLocationAccuracy) || other.requireLocationAccuracy == requireLocationAccuracy)&&(identical(other.maximumAcceptedAccuracyMeters, maximumAcceptedAccuracyMeters) || other.maximumAcceptedAccuracyMeters == maximumAcceptedAccuracyMeters)&&(identical(other.trackBreaks, trackBreaks) || other.trackBreaks == trackBreaks)&&(identical(other.allowMultipleBreaks, allowMultipleBreaks) || other.allowMultipleBreaks == allowMultipleBreaks)&&(identical(other.allowPunchOutDuringBreak, allowPunchOutDuringBreak) || other.allowPunchOutDuringBreak == allowPunchOutDuringBreak)&&(identical(other.allowEmployeeCorrectionRequest, allowEmployeeCorrectionRequest) || other.allowEmployeeCorrectionRequest == allowEmployeeCorrectionRequest)&&(identical(other.allowEarlyPunchIn, allowEarlyPunchIn) || other.allowEarlyPunchIn == allowEarlyPunchIn)&&(identical(other.earlyPunchInLimitMinutes, earlyPunchInLimitMinutes) || other.earlyPunchInLimitMinutes == earlyPunchInLimitMinutes)&&(identical(other.allowLatePunchIn, allowLatePunchIn) || other.allowLatePunchIn == allowLatePunchIn)&&(identical(other.allowEarlyPunchOut, allowEarlyPunchOut) || other.allowEarlyPunchOut == allowEarlyPunchOut)&&(identical(other.offlineMode, offlineMode) || other.offlineMode == offlineMode)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hashAll([runtimeType,name,description,requireLocation,allowOutsideLocation,allowRemoteAttendance,requireLocationOnPunchIn,requireLocationOnPunchOut,requireLocationOnBreak,requireLocationAccuracy,maximumAcceptedAccuracyMeters,trackBreaks,allowMultipleBreaks,allowPunchOutDuringBreak,allowEmployeeCorrectionRequest,allowEarlyPunchIn,earlyPunchInLimitMinutes,allowLatePunchIn,allowEarlyPunchOut,offlineMode,status]);

@override
String toString() {
  return 'AttendancePolicyDraft(name: $name, description: $description, requireLocation: $requireLocation, allowOutsideLocation: $allowOutsideLocation, allowRemoteAttendance: $allowRemoteAttendance, requireLocationOnPunchIn: $requireLocationOnPunchIn, requireLocationOnPunchOut: $requireLocationOnPunchOut, requireLocationOnBreak: $requireLocationOnBreak, requireLocationAccuracy: $requireLocationAccuracy, maximumAcceptedAccuracyMeters: $maximumAcceptedAccuracyMeters, trackBreaks: $trackBreaks, allowMultipleBreaks: $allowMultipleBreaks, allowPunchOutDuringBreak: $allowPunchOutDuringBreak, allowEmployeeCorrectionRequest: $allowEmployeeCorrectionRequest, allowEarlyPunchIn: $allowEarlyPunchIn, earlyPunchInLimitMinutes: $earlyPunchInLimitMinutes, allowLatePunchIn: $allowLatePunchIn, allowEarlyPunchOut: $allowEarlyPunchOut, offlineMode: $offlineMode, status: $status)';
}


}

/// @nodoc
abstract mixin class $AttendancePolicyDraftCopyWith<$Res>  {
  factory $AttendancePolicyDraftCopyWith(AttendancePolicyDraft value, $Res Function(AttendancePolicyDraft) _then) = _$AttendancePolicyDraftCopyWithImpl;
@useResult
$Res call({
 String name, String description, bool requireLocation, bool allowOutsideLocation, bool allowRemoteAttendance, bool requireLocationOnPunchIn, bool requireLocationOnPunchOut, bool requireLocationOnBreak, bool requireLocationAccuracy, double? maximumAcceptedAccuracyMeters, bool trackBreaks, bool allowMultipleBreaks, bool allowPunchOutDuringBreak, bool allowEmployeeCorrectionRequest, bool allowEarlyPunchIn, int? earlyPunchInLimitMinutes, bool allowLatePunchIn, bool allowEarlyPunchOut, OfflineAttendanceMode offlineMode, ConfigurationStatus status
});




}
/// @nodoc
class _$AttendancePolicyDraftCopyWithImpl<$Res>
    implements $AttendancePolicyDraftCopyWith<$Res> {
  _$AttendancePolicyDraftCopyWithImpl(this._self, this._then);

  final AttendancePolicyDraft _self;
  final $Res Function(AttendancePolicyDraft) _then;

/// Create a copy of AttendancePolicyDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = null,Object? requireLocation = null,Object? allowOutsideLocation = null,Object? allowRemoteAttendance = null,Object? requireLocationOnPunchIn = null,Object? requireLocationOnPunchOut = null,Object? requireLocationOnBreak = null,Object? requireLocationAccuracy = null,Object? maximumAcceptedAccuracyMeters = freezed,Object? trackBreaks = null,Object? allowMultipleBreaks = null,Object? allowPunchOutDuringBreak = null,Object? allowEmployeeCorrectionRequest = null,Object? allowEarlyPunchIn = null,Object? earlyPunchInLimitMinutes = freezed,Object? allowLatePunchIn = null,Object? allowEarlyPunchOut = null,Object? offlineMode = null,Object? status = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,requireLocation: null == requireLocation ? _self.requireLocation : requireLocation // ignore: cast_nullable_to_non_nullable
as bool,allowOutsideLocation: null == allowOutsideLocation ? _self.allowOutsideLocation : allowOutsideLocation // ignore: cast_nullable_to_non_nullable
as bool,allowRemoteAttendance: null == allowRemoteAttendance ? _self.allowRemoteAttendance : allowRemoteAttendance // ignore: cast_nullable_to_non_nullable
as bool,requireLocationOnPunchIn: null == requireLocationOnPunchIn ? _self.requireLocationOnPunchIn : requireLocationOnPunchIn // ignore: cast_nullable_to_non_nullable
as bool,requireLocationOnPunchOut: null == requireLocationOnPunchOut ? _self.requireLocationOnPunchOut : requireLocationOnPunchOut // ignore: cast_nullable_to_non_nullable
as bool,requireLocationOnBreak: null == requireLocationOnBreak ? _self.requireLocationOnBreak : requireLocationOnBreak // ignore: cast_nullable_to_non_nullable
as bool,requireLocationAccuracy: null == requireLocationAccuracy ? _self.requireLocationAccuracy : requireLocationAccuracy // ignore: cast_nullable_to_non_nullable
as bool,maximumAcceptedAccuracyMeters: freezed == maximumAcceptedAccuracyMeters ? _self.maximumAcceptedAccuracyMeters : maximumAcceptedAccuracyMeters // ignore: cast_nullable_to_non_nullable
as double?,trackBreaks: null == trackBreaks ? _self.trackBreaks : trackBreaks // ignore: cast_nullable_to_non_nullable
as bool,allowMultipleBreaks: null == allowMultipleBreaks ? _self.allowMultipleBreaks : allowMultipleBreaks // ignore: cast_nullable_to_non_nullable
as bool,allowPunchOutDuringBreak: null == allowPunchOutDuringBreak ? _self.allowPunchOutDuringBreak : allowPunchOutDuringBreak // ignore: cast_nullable_to_non_nullable
as bool,allowEmployeeCorrectionRequest: null == allowEmployeeCorrectionRequest ? _self.allowEmployeeCorrectionRequest : allowEmployeeCorrectionRequest // ignore: cast_nullable_to_non_nullable
as bool,allowEarlyPunchIn: null == allowEarlyPunchIn ? _self.allowEarlyPunchIn : allowEarlyPunchIn // ignore: cast_nullable_to_non_nullable
as bool,earlyPunchInLimitMinutes: freezed == earlyPunchInLimitMinutes ? _self.earlyPunchInLimitMinutes : earlyPunchInLimitMinutes // ignore: cast_nullable_to_non_nullable
as int?,allowLatePunchIn: null == allowLatePunchIn ? _self.allowLatePunchIn : allowLatePunchIn // ignore: cast_nullable_to_non_nullable
as bool,allowEarlyPunchOut: null == allowEarlyPunchOut ? _self.allowEarlyPunchOut : allowEarlyPunchOut // ignore: cast_nullable_to_non_nullable
as bool,offlineMode: null == offlineMode ? _self.offlineMode : offlineMode // ignore: cast_nullable_to_non_nullable
as OfflineAttendanceMode,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendancePolicyDraft].
extension AttendancePolicyDraftPatterns on AttendancePolicyDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendancePolicyDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendancePolicyDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendancePolicyDraft value)  $default,){
final _that = this;
switch (_that) {
case _AttendancePolicyDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendancePolicyDraft value)?  $default,){
final _that = this;
switch (_that) {
case _AttendancePolicyDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String description,  bool requireLocation,  bool allowOutsideLocation,  bool allowRemoteAttendance,  bool requireLocationOnPunchIn,  bool requireLocationOnPunchOut,  bool requireLocationOnBreak,  bool requireLocationAccuracy,  double? maximumAcceptedAccuracyMeters,  bool trackBreaks,  bool allowMultipleBreaks,  bool allowPunchOutDuringBreak,  bool allowEmployeeCorrectionRequest,  bool allowEarlyPunchIn,  int? earlyPunchInLimitMinutes,  bool allowLatePunchIn,  bool allowEarlyPunchOut,  OfflineAttendanceMode offlineMode,  ConfigurationStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendancePolicyDraft() when $default != null:
return $default(_that.name,_that.description,_that.requireLocation,_that.allowOutsideLocation,_that.allowRemoteAttendance,_that.requireLocationOnPunchIn,_that.requireLocationOnPunchOut,_that.requireLocationOnBreak,_that.requireLocationAccuracy,_that.maximumAcceptedAccuracyMeters,_that.trackBreaks,_that.allowMultipleBreaks,_that.allowPunchOutDuringBreak,_that.allowEmployeeCorrectionRequest,_that.allowEarlyPunchIn,_that.earlyPunchInLimitMinutes,_that.allowLatePunchIn,_that.allowEarlyPunchOut,_that.offlineMode,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String description,  bool requireLocation,  bool allowOutsideLocation,  bool allowRemoteAttendance,  bool requireLocationOnPunchIn,  bool requireLocationOnPunchOut,  bool requireLocationOnBreak,  bool requireLocationAccuracy,  double? maximumAcceptedAccuracyMeters,  bool trackBreaks,  bool allowMultipleBreaks,  bool allowPunchOutDuringBreak,  bool allowEmployeeCorrectionRequest,  bool allowEarlyPunchIn,  int? earlyPunchInLimitMinutes,  bool allowLatePunchIn,  bool allowEarlyPunchOut,  OfflineAttendanceMode offlineMode,  ConfigurationStatus status)  $default,) {final _that = this;
switch (_that) {
case _AttendancePolicyDraft():
return $default(_that.name,_that.description,_that.requireLocation,_that.allowOutsideLocation,_that.allowRemoteAttendance,_that.requireLocationOnPunchIn,_that.requireLocationOnPunchOut,_that.requireLocationOnBreak,_that.requireLocationAccuracy,_that.maximumAcceptedAccuracyMeters,_that.trackBreaks,_that.allowMultipleBreaks,_that.allowPunchOutDuringBreak,_that.allowEmployeeCorrectionRequest,_that.allowEarlyPunchIn,_that.earlyPunchInLimitMinutes,_that.allowLatePunchIn,_that.allowEarlyPunchOut,_that.offlineMode,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String description,  bool requireLocation,  bool allowOutsideLocation,  bool allowRemoteAttendance,  bool requireLocationOnPunchIn,  bool requireLocationOnPunchOut,  bool requireLocationOnBreak,  bool requireLocationAccuracy,  double? maximumAcceptedAccuracyMeters,  bool trackBreaks,  bool allowMultipleBreaks,  bool allowPunchOutDuringBreak,  bool allowEmployeeCorrectionRequest,  bool allowEarlyPunchIn,  int? earlyPunchInLimitMinutes,  bool allowLatePunchIn,  bool allowEarlyPunchOut,  OfflineAttendanceMode offlineMode,  ConfigurationStatus status)?  $default,) {final _that = this;
switch (_that) {
case _AttendancePolicyDraft() when $default != null:
return $default(_that.name,_that.description,_that.requireLocation,_that.allowOutsideLocation,_that.allowRemoteAttendance,_that.requireLocationOnPunchIn,_that.requireLocationOnPunchOut,_that.requireLocationOnBreak,_that.requireLocationAccuracy,_that.maximumAcceptedAccuracyMeters,_that.trackBreaks,_that.allowMultipleBreaks,_that.allowPunchOutDuringBreak,_that.allowEmployeeCorrectionRequest,_that.allowEarlyPunchIn,_that.earlyPunchInLimitMinutes,_that.allowLatePunchIn,_that.allowEarlyPunchOut,_that.offlineMode,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _AttendancePolicyDraft extends AttendancePolicyDraft {
  const _AttendancePolicyDraft({this.name = '', this.description = '', this.requireLocation = true, this.allowOutsideLocation = false, this.allowRemoteAttendance = false, this.requireLocationOnPunchIn = true, this.requireLocationOnPunchOut = true, this.requireLocationOnBreak = false, this.requireLocationAccuracy = false, this.maximumAcceptedAccuracyMeters, this.trackBreaks = true, this.allowMultipleBreaks = true, this.allowPunchOutDuringBreak = false, this.allowEmployeeCorrectionRequest = true, this.allowEarlyPunchIn = false, this.earlyPunchInLimitMinutes, this.allowLatePunchIn = true, this.allowEarlyPunchOut = false, this.offlineMode = OfflineAttendanceMode.allowPending, this.status = ConfigurationStatus.active}): super._();
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool requireLocation;
@override@JsonKey() final  bool allowOutsideLocation;
@override@JsonKey() final  bool allowRemoteAttendance;
@override@JsonKey() final  bool requireLocationOnPunchIn;
@override@JsonKey() final  bool requireLocationOnPunchOut;
@override@JsonKey() final  bool requireLocationOnBreak;
@override@JsonKey() final  bool requireLocationAccuracy;
@override final  double? maximumAcceptedAccuracyMeters;
@override@JsonKey() final  bool trackBreaks;
@override@JsonKey() final  bool allowMultipleBreaks;
@override@JsonKey() final  bool allowPunchOutDuringBreak;
@override@JsonKey() final  bool allowEmployeeCorrectionRequest;
@override@JsonKey() final  bool allowEarlyPunchIn;
@override final  int? earlyPunchInLimitMinutes;
@override@JsonKey() final  bool allowLatePunchIn;
@override@JsonKey() final  bool allowEarlyPunchOut;
@override@JsonKey() final  OfflineAttendanceMode offlineMode;
@override@JsonKey() final  ConfigurationStatus status;

/// Create a copy of AttendancePolicyDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendancePolicyDraftCopyWith<_AttendancePolicyDraft> get copyWith => __$AttendancePolicyDraftCopyWithImpl<_AttendancePolicyDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendancePolicyDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.requireLocation, requireLocation) || other.requireLocation == requireLocation)&&(identical(other.allowOutsideLocation, allowOutsideLocation) || other.allowOutsideLocation == allowOutsideLocation)&&(identical(other.allowRemoteAttendance, allowRemoteAttendance) || other.allowRemoteAttendance == allowRemoteAttendance)&&(identical(other.requireLocationOnPunchIn, requireLocationOnPunchIn) || other.requireLocationOnPunchIn == requireLocationOnPunchIn)&&(identical(other.requireLocationOnPunchOut, requireLocationOnPunchOut) || other.requireLocationOnPunchOut == requireLocationOnPunchOut)&&(identical(other.requireLocationOnBreak, requireLocationOnBreak) || other.requireLocationOnBreak == requireLocationOnBreak)&&(identical(other.requireLocationAccuracy, requireLocationAccuracy) || other.requireLocationAccuracy == requireLocationAccuracy)&&(identical(other.maximumAcceptedAccuracyMeters, maximumAcceptedAccuracyMeters) || other.maximumAcceptedAccuracyMeters == maximumAcceptedAccuracyMeters)&&(identical(other.trackBreaks, trackBreaks) || other.trackBreaks == trackBreaks)&&(identical(other.allowMultipleBreaks, allowMultipleBreaks) || other.allowMultipleBreaks == allowMultipleBreaks)&&(identical(other.allowPunchOutDuringBreak, allowPunchOutDuringBreak) || other.allowPunchOutDuringBreak == allowPunchOutDuringBreak)&&(identical(other.allowEmployeeCorrectionRequest, allowEmployeeCorrectionRequest) || other.allowEmployeeCorrectionRequest == allowEmployeeCorrectionRequest)&&(identical(other.allowEarlyPunchIn, allowEarlyPunchIn) || other.allowEarlyPunchIn == allowEarlyPunchIn)&&(identical(other.earlyPunchInLimitMinutes, earlyPunchInLimitMinutes) || other.earlyPunchInLimitMinutes == earlyPunchInLimitMinutes)&&(identical(other.allowLatePunchIn, allowLatePunchIn) || other.allowLatePunchIn == allowLatePunchIn)&&(identical(other.allowEarlyPunchOut, allowEarlyPunchOut) || other.allowEarlyPunchOut == allowEarlyPunchOut)&&(identical(other.offlineMode, offlineMode) || other.offlineMode == offlineMode)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hashAll([runtimeType,name,description,requireLocation,allowOutsideLocation,allowRemoteAttendance,requireLocationOnPunchIn,requireLocationOnPunchOut,requireLocationOnBreak,requireLocationAccuracy,maximumAcceptedAccuracyMeters,trackBreaks,allowMultipleBreaks,allowPunchOutDuringBreak,allowEmployeeCorrectionRequest,allowEarlyPunchIn,earlyPunchInLimitMinutes,allowLatePunchIn,allowEarlyPunchOut,offlineMode,status]);

@override
String toString() {
  return 'AttendancePolicyDraft(name: $name, description: $description, requireLocation: $requireLocation, allowOutsideLocation: $allowOutsideLocation, allowRemoteAttendance: $allowRemoteAttendance, requireLocationOnPunchIn: $requireLocationOnPunchIn, requireLocationOnPunchOut: $requireLocationOnPunchOut, requireLocationOnBreak: $requireLocationOnBreak, requireLocationAccuracy: $requireLocationAccuracy, maximumAcceptedAccuracyMeters: $maximumAcceptedAccuracyMeters, trackBreaks: $trackBreaks, allowMultipleBreaks: $allowMultipleBreaks, allowPunchOutDuringBreak: $allowPunchOutDuringBreak, allowEmployeeCorrectionRequest: $allowEmployeeCorrectionRequest, allowEarlyPunchIn: $allowEarlyPunchIn, earlyPunchInLimitMinutes: $earlyPunchInLimitMinutes, allowLatePunchIn: $allowLatePunchIn, allowEarlyPunchOut: $allowEarlyPunchOut, offlineMode: $offlineMode, status: $status)';
}


}

/// @nodoc
abstract mixin class _$AttendancePolicyDraftCopyWith<$Res> implements $AttendancePolicyDraftCopyWith<$Res> {
  factory _$AttendancePolicyDraftCopyWith(_AttendancePolicyDraft value, $Res Function(_AttendancePolicyDraft) _then) = __$AttendancePolicyDraftCopyWithImpl;
@override @useResult
$Res call({
 String name, String description, bool requireLocation, bool allowOutsideLocation, bool allowRemoteAttendance, bool requireLocationOnPunchIn, bool requireLocationOnPunchOut, bool requireLocationOnBreak, bool requireLocationAccuracy, double? maximumAcceptedAccuracyMeters, bool trackBreaks, bool allowMultipleBreaks, bool allowPunchOutDuringBreak, bool allowEmployeeCorrectionRequest, bool allowEarlyPunchIn, int? earlyPunchInLimitMinutes, bool allowLatePunchIn, bool allowEarlyPunchOut, OfflineAttendanceMode offlineMode, ConfigurationStatus status
});




}
/// @nodoc
class __$AttendancePolicyDraftCopyWithImpl<$Res>
    implements _$AttendancePolicyDraftCopyWith<$Res> {
  __$AttendancePolicyDraftCopyWithImpl(this._self, this._then);

  final _AttendancePolicyDraft _self;
  final $Res Function(_AttendancePolicyDraft) _then;

/// Create a copy of AttendancePolicyDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = null,Object? requireLocation = null,Object? allowOutsideLocation = null,Object? allowRemoteAttendance = null,Object? requireLocationOnPunchIn = null,Object? requireLocationOnPunchOut = null,Object? requireLocationOnBreak = null,Object? requireLocationAccuracy = null,Object? maximumAcceptedAccuracyMeters = freezed,Object? trackBreaks = null,Object? allowMultipleBreaks = null,Object? allowPunchOutDuringBreak = null,Object? allowEmployeeCorrectionRequest = null,Object? allowEarlyPunchIn = null,Object? earlyPunchInLimitMinutes = freezed,Object? allowLatePunchIn = null,Object? allowEarlyPunchOut = null,Object? offlineMode = null,Object? status = null,}) {
  return _then(_AttendancePolicyDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,requireLocation: null == requireLocation ? _self.requireLocation : requireLocation // ignore: cast_nullable_to_non_nullable
as bool,allowOutsideLocation: null == allowOutsideLocation ? _self.allowOutsideLocation : allowOutsideLocation // ignore: cast_nullable_to_non_nullable
as bool,allowRemoteAttendance: null == allowRemoteAttendance ? _self.allowRemoteAttendance : allowRemoteAttendance // ignore: cast_nullable_to_non_nullable
as bool,requireLocationOnPunchIn: null == requireLocationOnPunchIn ? _self.requireLocationOnPunchIn : requireLocationOnPunchIn // ignore: cast_nullable_to_non_nullable
as bool,requireLocationOnPunchOut: null == requireLocationOnPunchOut ? _self.requireLocationOnPunchOut : requireLocationOnPunchOut // ignore: cast_nullable_to_non_nullable
as bool,requireLocationOnBreak: null == requireLocationOnBreak ? _self.requireLocationOnBreak : requireLocationOnBreak // ignore: cast_nullable_to_non_nullable
as bool,requireLocationAccuracy: null == requireLocationAccuracy ? _self.requireLocationAccuracy : requireLocationAccuracy // ignore: cast_nullable_to_non_nullable
as bool,maximumAcceptedAccuracyMeters: freezed == maximumAcceptedAccuracyMeters ? _self.maximumAcceptedAccuracyMeters : maximumAcceptedAccuracyMeters // ignore: cast_nullable_to_non_nullable
as double?,trackBreaks: null == trackBreaks ? _self.trackBreaks : trackBreaks // ignore: cast_nullable_to_non_nullable
as bool,allowMultipleBreaks: null == allowMultipleBreaks ? _self.allowMultipleBreaks : allowMultipleBreaks // ignore: cast_nullable_to_non_nullable
as bool,allowPunchOutDuringBreak: null == allowPunchOutDuringBreak ? _self.allowPunchOutDuringBreak : allowPunchOutDuringBreak // ignore: cast_nullable_to_non_nullable
as bool,allowEmployeeCorrectionRequest: null == allowEmployeeCorrectionRequest ? _self.allowEmployeeCorrectionRequest : allowEmployeeCorrectionRequest // ignore: cast_nullable_to_non_nullable
as bool,allowEarlyPunchIn: null == allowEarlyPunchIn ? _self.allowEarlyPunchIn : allowEarlyPunchIn // ignore: cast_nullable_to_non_nullable
as bool,earlyPunchInLimitMinutes: freezed == earlyPunchInLimitMinutes ? _self.earlyPunchInLimitMinutes : earlyPunchInLimitMinutes // ignore: cast_nullable_to_non_nullable
as int?,allowLatePunchIn: null == allowLatePunchIn ? _self.allowLatePunchIn : allowLatePunchIn // ignore: cast_nullable_to_non_nullable
as bool,allowEarlyPunchOut: null == allowEarlyPunchOut ? _self.allowEarlyPunchOut : allowEarlyPunchOut // ignore: cast_nullable_to_non_nullable
as bool,offlineMode: null == offlineMode ? _self.offlineMode : offlineMode // ignore: cast_nullable_to_non_nullable
as OfflineAttendanceMode,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,
  ));
}


}

// dart format on
