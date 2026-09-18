// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceLocationEvidence {

 double get latitude; double get longitude; double get accuracyMeters; DateTime get capturedAt; AttendancePermissionState get permissionState;
/// Create a copy of AttendanceLocationEvidence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceLocationEvidenceCopyWith<AttendanceLocationEvidence> get copyWith => _$AttendanceLocationEvidenceCopyWithImpl<AttendanceLocationEvidence>(this as AttendanceLocationEvidence, _$identity);

  /// Serializes this AttendanceLocationEvidence to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceLocationEvidence&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.accuracyMeters, accuracyMeters) || other.accuracyMeters == accuracyMeters)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&(identical(other.permissionState, permissionState) || other.permissionState == permissionState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,accuracyMeters,capturedAt,permissionState);

@override
String toString() {
  return 'AttendanceLocationEvidence(latitude: $latitude, longitude: $longitude, accuracyMeters: $accuracyMeters, capturedAt: $capturedAt, permissionState: $permissionState)';
}


}

/// @nodoc
abstract mixin class $AttendanceLocationEvidenceCopyWith<$Res>  {
  factory $AttendanceLocationEvidenceCopyWith(AttendanceLocationEvidence value, $Res Function(AttendanceLocationEvidence) _then) = _$AttendanceLocationEvidenceCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, double accuracyMeters, DateTime capturedAt, AttendancePermissionState permissionState
});




}
/// @nodoc
class _$AttendanceLocationEvidenceCopyWithImpl<$Res>
    implements $AttendanceLocationEvidenceCopyWith<$Res> {
  _$AttendanceLocationEvidenceCopyWithImpl(this._self, this._then);

  final AttendanceLocationEvidence _self;
  final $Res Function(AttendanceLocationEvidence) _then;

/// Create a copy of AttendanceLocationEvidence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,Object? accuracyMeters = null,Object? capturedAt = null,Object? permissionState = null,}) {
  return _then(_self.copyWith(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracyMeters: null == accuracyMeters ? _self.accuracyMeters : accuracyMeters // ignore: cast_nullable_to_non_nullable
as double,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,permissionState: null == permissionState ? _self.permissionState : permissionState // ignore: cast_nullable_to_non_nullable
as AttendancePermissionState,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceLocationEvidence].
extension AttendanceLocationEvidencePatterns on AttendanceLocationEvidence {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceLocationEvidence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceLocationEvidence() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceLocationEvidence value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceLocationEvidence():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceLocationEvidence value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceLocationEvidence() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double accuracyMeters,  DateTime capturedAt,  AttendancePermissionState permissionState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceLocationEvidence() when $default != null:
return $default(_that.latitude,_that.longitude,_that.accuracyMeters,_that.capturedAt,_that.permissionState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double accuracyMeters,  DateTime capturedAt,  AttendancePermissionState permissionState)  $default,) {final _that = this;
switch (_that) {
case _AttendanceLocationEvidence():
return $default(_that.latitude,_that.longitude,_that.accuracyMeters,_that.capturedAt,_that.permissionState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude,  double accuracyMeters,  DateTime capturedAt,  AttendancePermissionState permissionState)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceLocationEvidence() when $default != null:
return $default(_that.latitude,_that.longitude,_that.accuracyMeters,_that.capturedAt,_that.permissionState);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceLocationEvidence implements AttendanceLocationEvidence {
  const _AttendanceLocationEvidence({required this.latitude, required this.longitude, required this.accuracyMeters, required this.capturedAt, this.permissionState = AttendancePermissionState.granted});
  factory _AttendanceLocationEvidence.fromJson(Map<String, dynamic> json) => _$AttendanceLocationEvidenceFromJson(json);

@override final  double latitude;
@override final  double longitude;
@override final  double accuracyMeters;
@override final  DateTime capturedAt;
@override@JsonKey() final  AttendancePermissionState permissionState;

/// Create a copy of AttendanceLocationEvidence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceLocationEvidenceCopyWith<_AttendanceLocationEvidence> get copyWith => __$AttendanceLocationEvidenceCopyWithImpl<_AttendanceLocationEvidence>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceLocationEvidenceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceLocationEvidence&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.accuracyMeters, accuracyMeters) || other.accuracyMeters == accuracyMeters)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&(identical(other.permissionState, permissionState) || other.permissionState == permissionState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,accuracyMeters,capturedAt,permissionState);

@override
String toString() {
  return 'AttendanceLocationEvidence(latitude: $latitude, longitude: $longitude, accuracyMeters: $accuracyMeters, capturedAt: $capturedAt, permissionState: $permissionState)';
}


}

/// @nodoc
abstract mixin class _$AttendanceLocationEvidenceCopyWith<$Res> implements $AttendanceLocationEvidenceCopyWith<$Res> {
  factory _$AttendanceLocationEvidenceCopyWith(_AttendanceLocationEvidence value, $Res Function(_AttendanceLocationEvidence) _then) = __$AttendanceLocationEvidenceCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude, double accuracyMeters, DateTime capturedAt, AttendancePermissionState permissionState
});




}
/// @nodoc
class __$AttendanceLocationEvidenceCopyWithImpl<$Res>
    implements _$AttendanceLocationEvidenceCopyWith<$Res> {
  __$AttendanceLocationEvidenceCopyWithImpl(this._self, this._then);

  final _AttendanceLocationEvidence _self;
  final $Res Function(_AttendanceLocationEvidence) _then;

/// Create a copy of AttendanceLocationEvidence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? accuracyMeters = null,Object? capturedAt = null,Object? permissionState = null,}) {
  return _then(_AttendanceLocationEvidence(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracyMeters: null == accuracyMeters ? _self.accuracyMeters : accuracyMeters // ignore: cast_nullable_to_non_nullable
as double,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,permissionState: null == permissionState ? _self.permissionState : permissionState // ignore: cast_nullable_to_non_nullable
as AttendancePermissionState,
  ));
}


}


/// @nodoc
mixin _$AttendanceLocationValidation {

 AttendanceLocationState get state; double? get distanceMeters; bool get accuracyAccepted;
/// Create a copy of AttendanceLocationValidation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceLocationValidationCopyWith<AttendanceLocationValidation> get copyWith => _$AttendanceLocationValidationCopyWithImpl<AttendanceLocationValidation>(this as AttendanceLocationValidation, _$identity);

  /// Serializes this AttendanceLocationValidation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceLocationValidation&&(identical(other.state, state) || other.state == state)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.accuracyAccepted, accuracyAccepted) || other.accuracyAccepted == accuracyAccepted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,state,distanceMeters,accuracyAccepted);

@override
String toString() {
  return 'AttendanceLocationValidation(state: $state, distanceMeters: $distanceMeters, accuracyAccepted: $accuracyAccepted)';
}


}

/// @nodoc
abstract mixin class $AttendanceLocationValidationCopyWith<$Res>  {
  factory $AttendanceLocationValidationCopyWith(AttendanceLocationValidation value, $Res Function(AttendanceLocationValidation) _then) = _$AttendanceLocationValidationCopyWithImpl;
@useResult
$Res call({
 AttendanceLocationState state, double? distanceMeters, bool accuracyAccepted
});




}
/// @nodoc
class _$AttendanceLocationValidationCopyWithImpl<$Res>
    implements $AttendanceLocationValidationCopyWith<$Res> {
  _$AttendanceLocationValidationCopyWithImpl(this._self, this._then);

  final AttendanceLocationValidation _self;
  final $Res Function(AttendanceLocationValidation) _then;

/// Create a copy of AttendanceLocationValidation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? state = null,Object? distanceMeters = freezed,Object? accuracyAccepted = null,}) {
  return _then(_self.copyWith(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as AttendanceLocationState,distanceMeters: freezed == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double?,accuracyAccepted: null == accuracyAccepted ? _self.accuracyAccepted : accuracyAccepted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceLocationValidation].
extension AttendanceLocationValidationPatterns on AttendanceLocationValidation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceLocationValidation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceLocationValidation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceLocationValidation value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceLocationValidation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceLocationValidation value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceLocationValidation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AttendanceLocationState state,  double? distanceMeters,  bool accuracyAccepted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceLocationValidation() when $default != null:
return $default(_that.state,_that.distanceMeters,_that.accuracyAccepted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AttendanceLocationState state,  double? distanceMeters,  bool accuracyAccepted)  $default,) {final _that = this;
switch (_that) {
case _AttendanceLocationValidation():
return $default(_that.state,_that.distanceMeters,_that.accuracyAccepted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AttendanceLocationState state,  double? distanceMeters,  bool accuracyAccepted)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceLocationValidation() when $default != null:
return $default(_that.state,_that.distanceMeters,_that.accuracyAccepted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceLocationValidation implements AttendanceLocationValidation {
  const _AttendanceLocationValidation({required this.state, this.distanceMeters, this.accuracyAccepted = true});
  factory _AttendanceLocationValidation.fromJson(Map<String, dynamic> json) => _$AttendanceLocationValidationFromJson(json);

@override final  AttendanceLocationState state;
@override final  double? distanceMeters;
@override@JsonKey() final  bool accuracyAccepted;

/// Create a copy of AttendanceLocationValidation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceLocationValidationCopyWith<_AttendanceLocationValidation> get copyWith => __$AttendanceLocationValidationCopyWithImpl<_AttendanceLocationValidation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceLocationValidationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceLocationValidation&&(identical(other.state, state) || other.state == state)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.accuracyAccepted, accuracyAccepted) || other.accuracyAccepted == accuracyAccepted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,state,distanceMeters,accuracyAccepted);

@override
String toString() {
  return 'AttendanceLocationValidation(state: $state, distanceMeters: $distanceMeters, accuracyAccepted: $accuracyAccepted)';
}


}

/// @nodoc
abstract mixin class _$AttendanceLocationValidationCopyWith<$Res> implements $AttendanceLocationValidationCopyWith<$Res> {
  factory _$AttendanceLocationValidationCopyWith(_AttendanceLocationValidation value, $Res Function(_AttendanceLocationValidation) _then) = __$AttendanceLocationValidationCopyWithImpl;
@override @useResult
$Res call({
 AttendanceLocationState state, double? distanceMeters, bool accuracyAccepted
});




}
/// @nodoc
class __$AttendanceLocationValidationCopyWithImpl<$Res>
    implements _$AttendanceLocationValidationCopyWith<$Res> {
  __$AttendanceLocationValidationCopyWithImpl(this._self, this._then);

  final _AttendanceLocationValidation _self;
  final $Res Function(_AttendanceLocationValidation) _then;

/// Create a copy of AttendanceLocationValidation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? state = null,Object? distanceMeters = freezed,Object? accuracyAccepted = null,}) {
  return _then(_AttendanceLocationValidation(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as AttendanceLocationState,distanceMeters: freezed == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double?,accuracyAccepted: null == accuracyAccepted ? _self.accuracyAccepted : accuracyAccepted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AttendanceConfigurationSnapshot {

 Shift get shift; AttendancePolicy get policy; WorkLocation? get workLocation; String get timezone; DateTime get scheduledStart; DateTime get scheduledEnd; AttendanceWorkMode get workMode;
/// Create a copy of AttendanceConfigurationSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceConfigurationSnapshotCopyWith<AttendanceConfigurationSnapshot> get copyWith => _$AttendanceConfigurationSnapshotCopyWithImpl<AttendanceConfigurationSnapshot>(this as AttendanceConfigurationSnapshot, _$identity);

  /// Serializes this AttendanceConfigurationSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceConfigurationSnapshot&&(identical(other.shift, shift) || other.shift == shift)&&(identical(other.policy, policy) || other.policy == policy)&&(identical(other.workLocation, workLocation) || other.workLocation == workLocation)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.scheduledStart, scheduledStart) || other.scheduledStart == scheduledStart)&&(identical(other.scheduledEnd, scheduledEnd) || other.scheduledEnd == scheduledEnd)&&(identical(other.workMode, workMode) || other.workMode == workMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shift,policy,workLocation,timezone,scheduledStart,scheduledEnd,workMode);

@override
String toString() {
  return 'AttendanceConfigurationSnapshot(shift: $shift, policy: $policy, workLocation: $workLocation, timezone: $timezone, scheduledStart: $scheduledStart, scheduledEnd: $scheduledEnd, workMode: $workMode)';
}


}

/// @nodoc
abstract mixin class $AttendanceConfigurationSnapshotCopyWith<$Res>  {
  factory $AttendanceConfigurationSnapshotCopyWith(AttendanceConfigurationSnapshot value, $Res Function(AttendanceConfigurationSnapshot) _then) = _$AttendanceConfigurationSnapshotCopyWithImpl;
@useResult
$Res call({
 Shift shift, AttendancePolicy policy, WorkLocation? workLocation, String timezone, DateTime scheduledStart, DateTime scheduledEnd, AttendanceWorkMode workMode
});


$ShiftCopyWith<$Res> get shift;$AttendancePolicyCopyWith<$Res> get policy;$WorkLocationCopyWith<$Res>? get workLocation;

}
/// @nodoc
class _$AttendanceConfigurationSnapshotCopyWithImpl<$Res>
    implements $AttendanceConfigurationSnapshotCopyWith<$Res> {
  _$AttendanceConfigurationSnapshotCopyWithImpl(this._self, this._then);

  final AttendanceConfigurationSnapshot _self;
  final $Res Function(AttendanceConfigurationSnapshot) _then;

/// Create a copy of AttendanceConfigurationSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shift = null,Object? policy = null,Object? workLocation = freezed,Object? timezone = null,Object? scheduledStart = null,Object? scheduledEnd = null,Object? workMode = null,}) {
  return _then(_self.copyWith(
shift: null == shift ? _self.shift : shift // ignore: cast_nullable_to_non_nullable
as Shift,policy: null == policy ? _self.policy : policy // ignore: cast_nullable_to_non_nullable
as AttendancePolicy,workLocation: freezed == workLocation ? _self.workLocation : workLocation // ignore: cast_nullable_to_non_nullable
as WorkLocation?,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,scheduledStart: null == scheduledStart ? _self.scheduledStart : scheduledStart // ignore: cast_nullable_to_non_nullable
as DateTime,scheduledEnd: null == scheduledEnd ? _self.scheduledEnd : scheduledEnd // ignore: cast_nullable_to_non_nullable
as DateTime,workMode: null == workMode ? _self.workMode : workMode // ignore: cast_nullable_to_non_nullable
as AttendanceWorkMode,
  ));
}
/// Create a copy of AttendanceConfigurationSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShiftCopyWith<$Res> get shift {
  
  return $ShiftCopyWith<$Res>(_self.shift, (value) {
    return _then(_self.copyWith(shift: value));
  });
}/// Create a copy of AttendanceConfigurationSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendancePolicyCopyWith<$Res> get policy {
  
  return $AttendancePolicyCopyWith<$Res>(_self.policy, (value) {
    return _then(_self.copyWith(policy: value));
  });
}/// Create a copy of AttendanceConfigurationSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkLocationCopyWith<$Res>? get workLocation {
    if (_self.workLocation == null) {
    return null;
  }

  return $WorkLocationCopyWith<$Res>(_self.workLocation!, (value) {
    return _then(_self.copyWith(workLocation: value));
  });
}
}


/// Adds pattern-matching-related methods to [AttendanceConfigurationSnapshot].
extension AttendanceConfigurationSnapshotPatterns on AttendanceConfigurationSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceConfigurationSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceConfigurationSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceConfigurationSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceConfigurationSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceConfigurationSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceConfigurationSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Shift shift,  AttendancePolicy policy,  WorkLocation? workLocation,  String timezone,  DateTime scheduledStart,  DateTime scheduledEnd,  AttendanceWorkMode workMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceConfigurationSnapshot() when $default != null:
return $default(_that.shift,_that.policy,_that.workLocation,_that.timezone,_that.scheduledStart,_that.scheduledEnd,_that.workMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Shift shift,  AttendancePolicy policy,  WorkLocation? workLocation,  String timezone,  DateTime scheduledStart,  DateTime scheduledEnd,  AttendanceWorkMode workMode)  $default,) {final _that = this;
switch (_that) {
case _AttendanceConfigurationSnapshot():
return $default(_that.shift,_that.policy,_that.workLocation,_that.timezone,_that.scheduledStart,_that.scheduledEnd,_that.workMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Shift shift,  AttendancePolicy policy,  WorkLocation? workLocation,  String timezone,  DateTime scheduledStart,  DateTime scheduledEnd,  AttendanceWorkMode workMode)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceConfigurationSnapshot() when $default != null:
return $default(_that.shift,_that.policy,_that.workLocation,_that.timezone,_that.scheduledStart,_that.scheduledEnd,_that.workMode);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _AttendanceConfigurationSnapshot implements AttendanceConfigurationSnapshot {
  const _AttendanceConfigurationSnapshot({required this.shift, required this.policy, this.workLocation, required this.timezone, required this.scheduledStart, required this.scheduledEnd, this.workMode = AttendanceWorkMode.office});
  factory _AttendanceConfigurationSnapshot.fromJson(Map<String, dynamic> json) => _$AttendanceConfigurationSnapshotFromJson(json);

@override final  Shift shift;
@override final  AttendancePolicy policy;
@override final  WorkLocation? workLocation;
@override final  String timezone;
@override final  DateTime scheduledStart;
@override final  DateTime scheduledEnd;
@override@JsonKey() final  AttendanceWorkMode workMode;

/// Create a copy of AttendanceConfigurationSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceConfigurationSnapshotCopyWith<_AttendanceConfigurationSnapshot> get copyWith => __$AttendanceConfigurationSnapshotCopyWithImpl<_AttendanceConfigurationSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceConfigurationSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceConfigurationSnapshot&&(identical(other.shift, shift) || other.shift == shift)&&(identical(other.policy, policy) || other.policy == policy)&&(identical(other.workLocation, workLocation) || other.workLocation == workLocation)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.scheduledStart, scheduledStart) || other.scheduledStart == scheduledStart)&&(identical(other.scheduledEnd, scheduledEnd) || other.scheduledEnd == scheduledEnd)&&(identical(other.workMode, workMode) || other.workMode == workMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shift,policy,workLocation,timezone,scheduledStart,scheduledEnd,workMode);

@override
String toString() {
  return 'AttendanceConfigurationSnapshot(shift: $shift, policy: $policy, workLocation: $workLocation, timezone: $timezone, scheduledStart: $scheduledStart, scheduledEnd: $scheduledEnd, workMode: $workMode)';
}


}

/// @nodoc
abstract mixin class _$AttendanceConfigurationSnapshotCopyWith<$Res> implements $AttendanceConfigurationSnapshotCopyWith<$Res> {
  factory _$AttendanceConfigurationSnapshotCopyWith(_AttendanceConfigurationSnapshot value, $Res Function(_AttendanceConfigurationSnapshot) _then) = __$AttendanceConfigurationSnapshotCopyWithImpl;
@override @useResult
$Res call({
 Shift shift, AttendancePolicy policy, WorkLocation? workLocation, String timezone, DateTime scheduledStart, DateTime scheduledEnd, AttendanceWorkMode workMode
});


@override $ShiftCopyWith<$Res> get shift;@override $AttendancePolicyCopyWith<$Res> get policy;@override $WorkLocationCopyWith<$Res>? get workLocation;

}
/// @nodoc
class __$AttendanceConfigurationSnapshotCopyWithImpl<$Res>
    implements _$AttendanceConfigurationSnapshotCopyWith<$Res> {
  __$AttendanceConfigurationSnapshotCopyWithImpl(this._self, this._then);

  final _AttendanceConfigurationSnapshot _self;
  final $Res Function(_AttendanceConfigurationSnapshot) _then;

/// Create a copy of AttendanceConfigurationSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shift = null,Object? policy = null,Object? workLocation = freezed,Object? timezone = null,Object? scheduledStart = null,Object? scheduledEnd = null,Object? workMode = null,}) {
  return _then(_AttendanceConfigurationSnapshot(
shift: null == shift ? _self.shift : shift // ignore: cast_nullable_to_non_nullable
as Shift,policy: null == policy ? _self.policy : policy // ignore: cast_nullable_to_non_nullable
as AttendancePolicy,workLocation: freezed == workLocation ? _self.workLocation : workLocation // ignore: cast_nullable_to_non_nullable
as WorkLocation?,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,scheduledStart: null == scheduledStart ? _self.scheduledStart : scheduledStart // ignore: cast_nullable_to_non_nullable
as DateTime,scheduledEnd: null == scheduledEnd ? _self.scheduledEnd : scheduledEnd // ignore: cast_nullable_to_non_nullable
as DateTime,workMode: null == workMode ? _self.workMode : workMode // ignore: cast_nullable_to_non_nullable
as AttendanceWorkMode,
  ));
}

/// Create a copy of AttendanceConfigurationSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShiftCopyWith<$Res> get shift {
  
  return $ShiftCopyWith<$Res>(_self.shift, (value) {
    return _then(_self.copyWith(shift: value));
  });
}/// Create a copy of AttendanceConfigurationSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendancePolicyCopyWith<$Res> get policy {
  
  return $AttendancePolicyCopyWith<$Res>(_self.policy, (value) {
    return _then(_self.copyWith(policy: value));
  });
}/// Create a copy of AttendanceConfigurationSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkLocationCopyWith<$Res>? get workLocation {
    if (_self.workLocation == null) {
    return null;
  }

  return $WorkLocationCopyWith<$Res>(_self.workLocation!, (value) {
    return _then(_self.copyWith(workLocation: value));
  });
}
}


/// @nodoc
mixin _$AttendanceDay {

 String get id; String get companyId; String get employeeId; DateTime get attendanceDate; AttendanceConfigurationSnapshot get snapshot; AttendanceWorkdayState get state; DateTime? get punchInAt; DateTime? get punchOutAt; int get elapsedMilliseconds; int get breakMilliseconds; int get workMilliseconds; AttendanceDayStatus get status; AttendanceSyncStatus get syncStatus; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of AttendanceDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceDayCopyWith<AttendanceDay> get copyWith => _$AttendanceDayCopyWithImpl<AttendanceDay>(this as AttendanceDay, _$identity);

  /// Serializes this AttendanceDay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceDay&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.attendanceDate, attendanceDate) || other.attendanceDate == attendanceDate)&&(identical(other.snapshot, snapshot) || other.snapshot == snapshot)&&(identical(other.state, state) || other.state == state)&&(identical(other.punchInAt, punchInAt) || other.punchInAt == punchInAt)&&(identical(other.punchOutAt, punchOutAt) || other.punchOutAt == punchOutAt)&&(identical(other.elapsedMilliseconds, elapsedMilliseconds) || other.elapsedMilliseconds == elapsedMilliseconds)&&(identical(other.breakMilliseconds, breakMilliseconds) || other.breakMilliseconds == breakMilliseconds)&&(identical(other.workMilliseconds, workMilliseconds) || other.workMilliseconds == workMilliseconds)&&(identical(other.status, status) || other.status == status)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,employeeId,attendanceDate,snapshot,state,punchInAt,punchOutAt,elapsedMilliseconds,breakMilliseconds,workMilliseconds,status,syncStatus,createdAt,updatedAt);

@override
String toString() {
  return 'AttendanceDay(id: $id, companyId: $companyId, employeeId: $employeeId, attendanceDate: $attendanceDate, snapshot: $snapshot, state: $state, punchInAt: $punchInAt, punchOutAt: $punchOutAt, elapsedMilliseconds: $elapsedMilliseconds, breakMilliseconds: $breakMilliseconds, workMilliseconds: $workMilliseconds, status: $status, syncStatus: $syncStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AttendanceDayCopyWith<$Res>  {
  factory $AttendanceDayCopyWith(AttendanceDay value, $Res Function(AttendanceDay) _then) = _$AttendanceDayCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String employeeId, DateTime attendanceDate, AttendanceConfigurationSnapshot snapshot, AttendanceWorkdayState state, DateTime? punchInAt, DateTime? punchOutAt, int elapsedMilliseconds, int breakMilliseconds, int workMilliseconds, AttendanceDayStatus status, AttendanceSyncStatus syncStatus, DateTime createdAt, DateTime updatedAt
});


$AttendanceConfigurationSnapshotCopyWith<$Res> get snapshot;

}
/// @nodoc
class _$AttendanceDayCopyWithImpl<$Res>
    implements $AttendanceDayCopyWith<$Res> {
  _$AttendanceDayCopyWithImpl(this._self, this._then);

  final AttendanceDay _self;
  final $Res Function(AttendanceDay) _then;

/// Create a copy of AttendanceDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? employeeId = null,Object? attendanceDate = null,Object? snapshot = null,Object? state = null,Object? punchInAt = freezed,Object? punchOutAt = freezed,Object? elapsedMilliseconds = null,Object? breakMilliseconds = null,Object? workMilliseconds = null,Object? status = null,Object? syncStatus = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,attendanceDate: null == attendanceDate ? _self.attendanceDate : attendanceDate // ignore: cast_nullable_to_non_nullable
as DateTime,snapshot: null == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as AttendanceConfigurationSnapshot,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as AttendanceWorkdayState,punchInAt: freezed == punchInAt ? _self.punchInAt : punchInAt // ignore: cast_nullable_to_non_nullable
as DateTime?,punchOutAt: freezed == punchOutAt ? _self.punchOutAt : punchOutAt // ignore: cast_nullable_to_non_nullable
as DateTime?,elapsedMilliseconds: null == elapsedMilliseconds ? _self.elapsedMilliseconds : elapsedMilliseconds // ignore: cast_nullable_to_non_nullable
as int,breakMilliseconds: null == breakMilliseconds ? _self.breakMilliseconds : breakMilliseconds // ignore: cast_nullable_to_non_nullable
as int,workMilliseconds: null == workMilliseconds ? _self.workMilliseconds : workMilliseconds // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceDayStatus,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as AttendanceSyncStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of AttendanceDay
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceConfigurationSnapshotCopyWith<$Res> get snapshot {
  
  return $AttendanceConfigurationSnapshotCopyWith<$Res>(_self.snapshot, (value) {
    return _then(_self.copyWith(snapshot: value));
  });
}
}


/// Adds pattern-matching-related methods to [AttendanceDay].
extension AttendanceDayPatterns on AttendanceDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceDay value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceDay value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String employeeId,  DateTime attendanceDate,  AttendanceConfigurationSnapshot snapshot,  AttendanceWorkdayState state,  DateTime? punchInAt,  DateTime? punchOutAt,  int elapsedMilliseconds,  int breakMilliseconds,  int workMilliseconds,  AttendanceDayStatus status,  AttendanceSyncStatus syncStatus,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceDay() when $default != null:
return $default(_that.id,_that.companyId,_that.employeeId,_that.attendanceDate,_that.snapshot,_that.state,_that.punchInAt,_that.punchOutAt,_that.elapsedMilliseconds,_that.breakMilliseconds,_that.workMilliseconds,_that.status,_that.syncStatus,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String employeeId,  DateTime attendanceDate,  AttendanceConfigurationSnapshot snapshot,  AttendanceWorkdayState state,  DateTime? punchInAt,  DateTime? punchOutAt,  int elapsedMilliseconds,  int breakMilliseconds,  int workMilliseconds,  AttendanceDayStatus status,  AttendanceSyncStatus syncStatus,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AttendanceDay():
return $default(_that.id,_that.companyId,_that.employeeId,_that.attendanceDate,_that.snapshot,_that.state,_that.punchInAt,_that.punchOutAt,_that.elapsedMilliseconds,_that.breakMilliseconds,_that.workMilliseconds,_that.status,_that.syncStatus,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String employeeId,  DateTime attendanceDate,  AttendanceConfigurationSnapshot snapshot,  AttendanceWorkdayState state,  DateTime? punchInAt,  DateTime? punchOutAt,  int elapsedMilliseconds,  int breakMilliseconds,  int workMilliseconds,  AttendanceDayStatus status,  AttendanceSyncStatus syncStatus,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceDay() when $default != null:
return $default(_that.id,_that.companyId,_that.employeeId,_that.attendanceDate,_that.snapshot,_that.state,_that.punchInAt,_that.punchOutAt,_that.elapsedMilliseconds,_that.breakMilliseconds,_that.workMilliseconds,_that.status,_that.syncStatus,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _AttendanceDay extends AttendanceDay {
  const _AttendanceDay({required this.id, required this.companyId, required this.employeeId, required this.attendanceDate, required this.snapshot, required this.state, this.punchInAt, this.punchOutAt, this.elapsedMilliseconds = 0, this.breakMilliseconds = 0, this.workMilliseconds = 0, required this.status, required this.syncStatus, required this.createdAt, required this.updatedAt}): super._();
  factory _AttendanceDay.fromJson(Map<String, dynamic> json) => _$AttendanceDayFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  String employeeId;
@override final  DateTime attendanceDate;
@override final  AttendanceConfigurationSnapshot snapshot;
@override final  AttendanceWorkdayState state;
@override final  DateTime? punchInAt;
@override final  DateTime? punchOutAt;
@override@JsonKey() final  int elapsedMilliseconds;
@override@JsonKey() final  int breakMilliseconds;
@override@JsonKey() final  int workMilliseconds;
@override final  AttendanceDayStatus status;
@override final  AttendanceSyncStatus syncStatus;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of AttendanceDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceDayCopyWith<_AttendanceDay> get copyWith => __$AttendanceDayCopyWithImpl<_AttendanceDay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceDayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceDay&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.attendanceDate, attendanceDate) || other.attendanceDate == attendanceDate)&&(identical(other.snapshot, snapshot) || other.snapshot == snapshot)&&(identical(other.state, state) || other.state == state)&&(identical(other.punchInAt, punchInAt) || other.punchInAt == punchInAt)&&(identical(other.punchOutAt, punchOutAt) || other.punchOutAt == punchOutAt)&&(identical(other.elapsedMilliseconds, elapsedMilliseconds) || other.elapsedMilliseconds == elapsedMilliseconds)&&(identical(other.breakMilliseconds, breakMilliseconds) || other.breakMilliseconds == breakMilliseconds)&&(identical(other.workMilliseconds, workMilliseconds) || other.workMilliseconds == workMilliseconds)&&(identical(other.status, status) || other.status == status)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,employeeId,attendanceDate,snapshot,state,punchInAt,punchOutAt,elapsedMilliseconds,breakMilliseconds,workMilliseconds,status,syncStatus,createdAt,updatedAt);

@override
String toString() {
  return 'AttendanceDay(id: $id, companyId: $companyId, employeeId: $employeeId, attendanceDate: $attendanceDate, snapshot: $snapshot, state: $state, punchInAt: $punchInAt, punchOutAt: $punchOutAt, elapsedMilliseconds: $elapsedMilliseconds, breakMilliseconds: $breakMilliseconds, workMilliseconds: $workMilliseconds, status: $status, syncStatus: $syncStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AttendanceDayCopyWith<$Res> implements $AttendanceDayCopyWith<$Res> {
  factory _$AttendanceDayCopyWith(_AttendanceDay value, $Res Function(_AttendanceDay) _then) = __$AttendanceDayCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String employeeId, DateTime attendanceDate, AttendanceConfigurationSnapshot snapshot, AttendanceWorkdayState state, DateTime? punchInAt, DateTime? punchOutAt, int elapsedMilliseconds, int breakMilliseconds, int workMilliseconds, AttendanceDayStatus status, AttendanceSyncStatus syncStatus, DateTime createdAt, DateTime updatedAt
});


@override $AttendanceConfigurationSnapshotCopyWith<$Res> get snapshot;

}
/// @nodoc
class __$AttendanceDayCopyWithImpl<$Res>
    implements _$AttendanceDayCopyWith<$Res> {
  __$AttendanceDayCopyWithImpl(this._self, this._then);

  final _AttendanceDay _self;
  final $Res Function(_AttendanceDay) _then;

/// Create a copy of AttendanceDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? employeeId = null,Object? attendanceDate = null,Object? snapshot = null,Object? state = null,Object? punchInAt = freezed,Object? punchOutAt = freezed,Object? elapsedMilliseconds = null,Object? breakMilliseconds = null,Object? workMilliseconds = null,Object? status = null,Object? syncStatus = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_AttendanceDay(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,attendanceDate: null == attendanceDate ? _self.attendanceDate : attendanceDate // ignore: cast_nullable_to_non_nullable
as DateTime,snapshot: null == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as AttendanceConfigurationSnapshot,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as AttendanceWorkdayState,punchInAt: freezed == punchInAt ? _self.punchInAt : punchInAt // ignore: cast_nullable_to_non_nullable
as DateTime?,punchOutAt: freezed == punchOutAt ? _self.punchOutAt : punchOutAt // ignore: cast_nullable_to_non_nullable
as DateTime?,elapsedMilliseconds: null == elapsedMilliseconds ? _self.elapsedMilliseconds : elapsedMilliseconds // ignore: cast_nullable_to_non_nullable
as int,breakMilliseconds: null == breakMilliseconds ? _self.breakMilliseconds : breakMilliseconds // ignore: cast_nullable_to_non_nullable
as int,workMilliseconds: null == workMilliseconds ? _self.workMilliseconds : workMilliseconds // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceDayStatus,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as AttendanceSyncStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of AttendanceDay
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceConfigurationSnapshotCopyWith<$Res> get snapshot {
  
  return $AttendanceConfigurationSnapshotCopyWith<$Res>(_self.snapshot, (value) {
    return _then(_self.copyWith(snapshot: value));
  });
}
}


/// @nodoc
mixin _$AttendanceEvent {

 String get id; String get attendanceDayId; String get companyId; String get employeeId; AttendanceEventType get eventType; DateTime get deviceTimestamp; DateTime? get serverTimestamp; int get sequence; AttendanceLocationEvidence? get locationEvidence; String? get workLocationId; AttendanceLocationValidation get locationValidation; String get requestId; AttendanceEventSource get source; AttendanceSyncStatus get syncStatus; DateTime get createdAt;
/// Create a copy of AttendanceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceEventCopyWith<AttendanceEvent> get copyWith => _$AttendanceEventCopyWithImpl<AttendanceEvent>(this as AttendanceEvent, _$identity);

  /// Serializes this AttendanceEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.attendanceDayId, attendanceDayId) || other.attendanceDayId == attendanceDayId)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.deviceTimestamp, deviceTimestamp) || other.deviceTimestamp == deviceTimestamp)&&(identical(other.serverTimestamp, serverTimestamp) || other.serverTimestamp == serverTimestamp)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.locationEvidence, locationEvidence) || other.locationEvidence == locationEvidence)&&(identical(other.workLocationId, workLocationId) || other.workLocationId == workLocationId)&&(identical(other.locationValidation, locationValidation) || other.locationValidation == locationValidation)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.source, source) || other.source == source)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,attendanceDayId,companyId,employeeId,eventType,deviceTimestamp,serverTimestamp,sequence,locationEvidence,workLocationId,locationValidation,requestId,source,syncStatus,createdAt);

@override
String toString() {
  return 'AttendanceEvent(id: $id, attendanceDayId: $attendanceDayId, companyId: $companyId, employeeId: $employeeId, eventType: $eventType, deviceTimestamp: $deviceTimestamp, serverTimestamp: $serverTimestamp, sequence: $sequence, locationEvidence: $locationEvidence, workLocationId: $workLocationId, locationValidation: $locationValidation, requestId: $requestId, source: $source, syncStatus: $syncStatus, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AttendanceEventCopyWith<$Res>  {
  factory $AttendanceEventCopyWith(AttendanceEvent value, $Res Function(AttendanceEvent) _then) = _$AttendanceEventCopyWithImpl;
@useResult
$Res call({
 String id, String attendanceDayId, String companyId, String employeeId, AttendanceEventType eventType, DateTime deviceTimestamp, DateTime? serverTimestamp, int sequence, AttendanceLocationEvidence? locationEvidence, String? workLocationId, AttendanceLocationValidation locationValidation, String requestId, AttendanceEventSource source, AttendanceSyncStatus syncStatus, DateTime createdAt
});


$AttendanceLocationEvidenceCopyWith<$Res>? get locationEvidence;$AttendanceLocationValidationCopyWith<$Res> get locationValidation;

}
/// @nodoc
class _$AttendanceEventCopyWithImpl<$Res>
    implements $AttendanceEventCopyWith<$Res> {
  _$AttendanceEventCopyWithImpl(this._self, this._then);

  final AttendanceEvent _self;
  final $Res Function(AttendanceEvent) _then;

/// Create a copy of AttendanceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? attendanceDayId = null,Object? companyId = null,Object? employeeId = null,Object? eventType = null,Object? deviceTimestamp = null,Object? serverTimestamp = freezed,Object? sequence = null,Object? locationEvidence = freezed,Object? workLocationId = freezed,Object? locationValidation = null,Object? requestId = null,Object? source = null,Object? syncStatus = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,attendanceDayId: null == attendanceDayId ? _self.attendanceDayId : attendanceDayId // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as AttendanceEventType,deviceTimestamp: null == deviceTimestamp ? _self.deviceTimestamp : deviceTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime,serverTimestamp: freezed == serverTimestamp ? _self.serverTimestamp : serverTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,locationEvidence: freezed == locationEvidence ? _self.locationEvidence : locationEvidence // ignore: cast_nullable_to_non_nullable
as AttendanceLocationEvidence?,workLocationId: freezed == workLocationId ? _self.workLocationId : workLocationId // ignore: cast_nullable_to_non_nullable
as String?,locationValidation: null == locationValidation ? _self.locationValidation : locationValidation // ignore: cast_nullable_to_non_nullable
as AttendanceLocationValidation,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AttendanceEventSource,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as AttendanceSyncStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of AttendanceEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceLocationEvidenceCopyWith<$Res>? get locationEvidence {
    if (_self.locationEvidence == null) {
    return null;
  }

  return $AttendanceLocationEvidenceCopyWith<$Res>(_self.locationEvidence!, (value) {
    return _then(_self.copyWith(locationEvidence: value));
  });
}/// Create a copy of AttendanceEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceLocationValidationCopyWith<$Res> get locationValidation {
  
  return $AttendanceLocationValidationCopyWith<$Res>(_self.locationValidation, (value) {
    return _then(_self.copyWith(locationValidation: value));
  });
}
}


/// Adds pattern-matching-related methods to [AttendanceEvent].
extension AttendanceEventPatterns on AttendanceEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceEvent value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceEvent value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String attendanceDayId,  String companyId,  String employeeId,  AttendanceEventType eventType,  DateTime deviceTimestamp,  DateTime? serverTimestamp,  int sequence,  AttendanceLocationEvidence? locationEvidence,  String? workLocationId,  AttendanceLocationValidation locationValidation,  String requestId,  AttendanceEventSource source,  AttendanceSyncStatus syncStatus,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceEvent() when $default != null:
return $default(_that.id,_that.attendanceDayId,_that.companyId,_that.employeeId,_that.eventType,_that.deviceTimestamp,_that.serverTimestamp,_that.sequence,_that.locationEvidence,_that.workLocationId,_that.locationValidation,_that.requestId,_that.source,_that.syncStatus,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String attendanceDayId,  String companyId,  String employeeId,  AttendanceEventType eventType,  DateTime deviceTimestamp,  DateTime? serverTimestamp,  int sequence,  AttendanceLocationEvidence? locationEvidence,  String? workLocationId,  AttendanceLocationValidation locationValidation,  String requestId,  AttendanceEventSource source,  AttendanceSyncStatus syncStatus,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AttendanceEvent():
return $default(_that.id,_that.attendanceDayId,_that.companyId,_that.employeeId,_that.eventType,_that.deviceTimestamp,_that.serverTimestamp,_that.sequence,_that.locationEvidence,_that.workLocationId,_that.locationValidation,_that.requestId,_that.source,_that.syncStatus,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String attendanceDayId,  String companyId,  String employeeId,  AttendanceEventType eventType,  DateTime deviceTimestamp,  DateTime? serverTimestamp,  int sequence,  AttendanceLocationEvidence? locationEvidence,  String? workLocationId,  AttendanceLocationValidation locationValidation,  String requestId,  AttendanceEventSource source,  AttendanceSyncStatus syncStatus,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceEvent() when $default != null:
return $default(_that.id,_that.attendanceDayId,_that.companyId,_that.employeeId,_that.eventType,_that.deviceTimestamp,_that.serverTimestamp,_that.sequence,_that.locationEvidence,_that.workLocationId,_that.locationValidation,_that.requestId,_that.source,_that.syncStatus,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _AttendanceEvent extends AttendanceEvent {
  const _AttendanceEvent({required this.id, required this.attendanceDayId, required this.companyId, required this.employeeId, required this.eventType, required this.deviceTimestamp, this.serverTimestamp, required this.sequence, this.locationEvidence, this.workLocationId, required this.locationValidation, required this.requestId, required this.source, required this.syncStatus, required this.createdAt}): super._();
  factory _AttendanceEvent.fromJson(Map<String, dynamic> json) => _$AttendanceEventFromJson(json);

@override final  String id;
@override final  String attendanceDayId;
@override final  String companyId;
@override final  String employeeId;
@override final  AttendanceEventType eventType;
@override final  DateTime deviceTimestamp;
@override final  DateTime? serverTimestamp;
@override final  int sequence;
@override final  AttendanceLocationEvidence? locationEvidence;
@override final  String? workLocationId;
@override final  AttendanceLocationValidation locationValidation;
@override final  String requestId;
@override final  AttendanceEventSource source;
@override final  AttendanceSyncStatus syncStatus;
@override final  DateTime createdAt;

/// Create a copy of AttendanceEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceEventCopyWith<_AttendanceEvent> get copyWith => __$AttendanceEventCopyWithImpl<_AttendanceEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.attendanceDayId, attendanceDayId) || other.attendanceDayId == attendanceDayId)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.deviceTimestamp, deviceTimestamp) || other.deviceTimestamp == deviceTimestamp)&&(identical(other.serverTimestamp, serverTimestamp) || other.serverTimestamp == serverTimestamp)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.locationEvidence, locationEvidence) || other.locationEvidence == locationEvidence)&&(identical(other.workLocationId, workLocationId) || other.workLocationId == workLocationId)&&(identical(other.locationValidation, locationValidation) || other.locationValidation == locationValidation)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.source, source) || other.source == source)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,attendanceDayId,companyId,employeeId,eventType,deviceTimestamp,serverTimestamp,sequence,locationEvidence,workLocationId,locationValidation,requestId,source,syncStatus,createdAt);

@override
String toString() {
  return 'AttendanceEvent(id: $id, attendanceDayId: $attendanceDayId, companyId: $companyId, employeeId: $employeeId, eventType: $eventType, deviceTimestamp: $deviceTimestamp, serverTimestamp: $serverTimestamp, sequence: $sequence, locationEvidence: $locationEvidence, workLocationId: $workLocationId, locationValidation: $locationValidation, requestId: $requestId, source: $source, syncStatus: $syncStatus, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AttendanceEventCopyWith<$Res> implements $AttendanceEventCopyWith<$Res> {
  factory _$AttendanceEventCopyWith(_AttendanceEvent value, $Res Function(_AttendanceEvent) _then) = __$AttendanceEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String attendanceDayId, String companyId, String employeeId, AttendanceEventType eventType, DateTime deviceTimestamp, DateTime? serverTimestamp, int sequence, AttendanceLocationEvidence? locationEvidence, String? workLocationId, AttendanceLocationValidation locationValidation, String requestId, AttendanceEventSource source, AttendanceSyncStatus syncStatus, DateTime createdAt
});


@override $AttendanceLocationEvidenceCopyWith<$Res>? get locationEvidence;@override $AttendanceLocationValidationCopyWith<$Res> get locationValidation;

}
/// @nodoc
class __$AttendanceEventCopyWithImpl<$Res>
    implements _$AttendanceEventCopyWith<$Res> {
  __$AttendanceEventCopyWithImpl(this._self, this._then);

  final _AttendanceEvent _self;
  final $Res Function(_AttendanceEvent) _then;

/// Create a copy of AttendanceEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? attendanceDayId = null,Object? companyId = null,Object? employeeId = null,Object? eventType = null,Object? deviceTimestamp = null,Object? serverTimestamp = freezed,Object? sequence = null,Object? locationEvidence = freezed,Object? workLocationId = freezed,Object? locationValidation = null,Object? requestId = null,Object? source = null,Object? syncStatus = null,Object? createdAt = null,}) {
  return _then(_AttendanceEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,attendanceDayId: null == attendanceDayId ? _self.attendanceDayId : attendanceDayId // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as AttendanceEventType,deviceTimestamp: null == deviceTimestamp ? _self.deviceTimestamp : deviceTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime,serverTimestamp: freezed == serverTimestamp ? _self.serverTimestamp : serverTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,locationEvidence: freezed == locationEvidence ? _self.locationEvidence : locationEvidence // ignore: cast_nullable_to_non_nullable
as AttendanceLocationEvidence?,workLocationId: freezed == workLocationId ? _self.workLocationId : workLocationId // ignore: cast_nullable_to_non_nullable
as String?,locationValidation: null == locationValidation ? _self.locationValidation : locationValidation // ignore: cast_nullable_to_non_nullable
as AttendanceLocationValidation,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AttendanceEventSource,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as AttendanceSyncStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of AttendanceEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceLocationEvidenceCopyWith<$Res>? get locationEvidence {
    if (_self.locationEvidence == null) {
    return null;
  }

  return $AttendanceLocationEvidenceCopyWith<$Res>(_self.locationEvidence!, (value) {
    return _then(_self.copyWith(locationEvidence: value));
  });
}/// Create a copy of AttendanceEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceLocationValidationCopyWith<$Res> get locationValidation {
  
  return $AttendanceLocationValidationCopyWith<$Res>(_self.locationValidation, (value) {
    return _then(_self.copyWith(locationValidation: value));
  });
}
}

// dart format on
