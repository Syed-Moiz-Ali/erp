// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shift_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShiftDto {

 int get shiftId; String get shiftName; String get startTime; String get endTime; int get durationMinutes; bool get crossesMidnight; String? get punchInOpensAt; int get earlyPunchInMinutes; int get lateGraceMinutes; int get statusId; String get status; int get activeAssignments; DateTime? get createdOn; DateTime? get modifiedOn;
/// Create a copy of ShiftDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShiftDtoCopyWith<ShiftDto> get copyWith => _$ShiftDtoCopyWithImpl<ShiftDto>(this as ShiftDto, _$identity);

  /// Serializes this ShiftDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShiftDto&&(identical(other.shiftId, shiftId) || other.shiftId == shiftId)&&(identical(other.shiftName, shiftName) || other.shiftName == shiftName)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.crossesMidnight, crossesMidnight) || other.crossesMidnight == crossesMidnight)&&(identical(other.punchInOpensAt, punchInOpensAt) || other.punchInOpensAt == punchInOpensAt)&&(identical(other.earlyPunchInMinutes, earlyPunchInMinutes) || other.earlyPunchInMinutes == earlyPunchInMinutes)&&(identical(other.lateGraceMinutes, lateGraceMinutes) || other.lateGraceMinutes == lateGraceMinutes)&&(identical(other.statusId, statusId) || other.statusId == statusId)&&(identical(other.status, status) || other.status == status)&&(identical(other.activeAssignments, activeAssignments) || other.activeAssignments == activeAssignments)&&(identical(other.createdOn, createdOn) || other.createdOn == createdOn)&&(identical(other.modifiedOn, modifiedOn) || other.modifiedOn == modifiedOn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shiftId,shiftName,startTime,endTime,durationMinutes,crossesMidnight,punchInOpensAt,earlyPunchInMinutes,lateGraceMinutes,statusId,status,activeAssignments,createdOn,modifiedOn);

@override
String toString() {
  return 'ShiftDto(shiftId: $shiftId, shiftName: $shiftName, startTime: $startTime, endTime: $endTime, durationMinutes: $durationMinutes, crossesMidnight: $crossesMidnight, punchInOpensAt: $punchInOpensAt, earlyPunchInMinutes: $earlyPunchInMinutes, lateGraceMinutes: $lateGraceMinutes, statusId: $statusId, status: $status, activeAssignments: $activeAssignments, createdOn: $createdOn, modifiedOn: $modifiedOn)';
}


}

/// @nodoc
abstract mixin class $ShiftDtoCopyWith<$Res>  {
  factory $ShiftDtoCopyWith(ShiftDto value, $Res Function(ShiftDto) _then) = _$ShiftDtoCopyWithImpl;
@useResult
$Res call({
 int shiftId, String shiftName, String startTime, String endTime, int durationMinutes, bool crossesMidnight, String? punchInOpensAt, int earlyPunchInMinutes, int lateGraceMinutes, int statusId, String status, int activeAssignments, DateTime? createdOn, DateTime? modifiedOn
});




}
/// @nodoc
class _$ShiftDtoCopyWithImpl<$Res>
    implements $ShiftDtoCopyWith<$Res> {
  _$ShiftDtoCopyWithImpl(this._self, this._then);

  final ShiftDto _self;
  final $Res Function(ShiftDto) _then;

/// Create a copy of ShiftDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shiftId = null,Object? shiftName = null,Object? startTime = null,Object? endTime = null,Object? durationMinutes = null,Object? crossesMidnight = null,Object? punchInOpensAt = freezed,Object? earlyPunchInMinutes = null,Object? lateGraceMinutes = null,Object? statusId = null,Object? status = null,Object? activeAssignments = null,Object? createdOn = freezed,Object? modifiedOn = freezed,}) {
  return _then(_self.copyWith(
shiftId: null == shiftId ? _self.shiftId : shiftId // ignore: cast_nullable_to_non_nullable
as int,shiftName: null == shiftName ? _self.shiftName : shiftName // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,crossesMidnight: null == crossesMidnight ? _self.crossesMidnight : crossesMidnight // ignore: cast_nullable_to_non_nullable
as bool,punchInOpensAt: freezed == punchInOpensAt ? _self.punchInOpensAt : punchInOpensAt // ignore: cast_nullable_to_non_nullable
as String?,earlyPunchInMinutes: null == earlyPunchInMinutes ? _self.earlyPunchInMinutes : earlyPunchInMinutes // ignore: cast_nullable_to_non_nullable
as int,lateGraceMinutes: null == lateGraceMinutes ? _self.lateGraceMinutes : lateGraceMinutes // ignore: cast_nullable_to_non_nullable
as int,statusId: null == statusId ? _self.statusId : statusId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,activeAssignments: null == activeAssignments ? _self.activeAssignments : activeAssignments // ignore: cast_nullable_to_non_nullable
as int,createdOn: freezed == createdOn ? _self.createdOn : createdOn // ignore: cast_nullable_to_non_nullable
as DateTime?,modifiedOn: freezed == modifiedOn ? _self.modifiedOn : modifiedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ShiftDto].
extension ShiftDtoPatterns on ShiftDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShiftDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShiftDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShiftDto value)  $default,){
final _that = this;
switch (_that) {
case _ShiftDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShiftDto value)?  $default,){
final _that = this;
switch (_that) {
case _ShiftDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int shiftId,  String shiftName,  String startTime,  String endTime,  int durationMinutes,  bool crossesMidnight,  String? punchInOpensAt,  int earlyPunchInMinutes,  int lateGraceMinutes,  int statusId,  String status,  int activeAssignments,  DateTime? createdOn,  DateTime? modifiedOn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShiftDto() when $default != null:
return $default(_that.shiftId,_that.shiftName,_that.startTime,_that.endTime,_that.durationMinutes,_that.crossesMidnight,_that.punchInOpensAt,_that.earlyPunchInMinutes,_that.lateGraceMinutes,_that.statusId,_that.status,_that.activeAssignments,_that.createdOn,_that.modifiedOn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int shiftId,  String shiftName,  String startTime,  String endTime,  int durationMinutes,  bool crossesMidnight,  String? punchInOpensAt,  int earlyPunchInMinutes,  int lateGraceMinutes,  int statusId,  String status,  int activeAssignments,  DateTime? createdOn,  DateTime? modifiedOn)  $default,) {final _that = this;
switch (_that) {
case _ShiftDto():
return $default(_that.shiftId,_that.shiftName,_that.startTime,_that.endTime,_that.durationMinutes,_that.crossesMidnight,_that.punchInOpensAt,_that.earlyPunchInMinutes,_that.lateGraceMinutes,_that.statusId,_that.status,_that.activeAssignments,_that.createdOn,_that.modifiedOn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int shiftId,  String shiftName,  String startTime,  String endTime,  int durationMinutes,  bool crossesMidnight,  String? punchInOpensAt,  int earlyPunchInMinutes,  int lateGraceMinutes,  int statusId,  String status,  int activeAssignments,  DateTime? createdOn,  DateTime? modifiedOn)?  $default,) {final _that = this;
switch (_that) {
case _ShiftDto() when $default != null:
return $default(_that.shiftId,_that.shiftName,_that.startTime,_that.endTime,_that.durationMinutes,_that.crossesMidnight,_that.punchInOpensAt,_that.earlyPunchInMinutes,_that.lateGraceMinutes,_that.statusId,_that.status,_that.activeAssignments,_that.createdOn,_that.modifiedOn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShiftDto implements ShiftDto {
  const _ShiftDto({required this.shiftId, required this.shiftName, required this.startTime, required this.endTime, this.durationMinutes = 0, this.crossesMidnight = false, this.punchInOpensAt, this.earlyPunchInMinutes = 15, this.lateGraceMinutes = 15, this.statusId = 1, this.status = 'Active', this.activeAssignments = 0, this.createdOn, this.modifiedOn});
  factory _ShiftDto.fromJson(Map<String, dynamic> json) => _$ShiftDtoFromJson(json);

@override final  int shiftId;
@override final  String shiftName;
@override final  String startTime;
@override final  String endTime;
@override@JsonKey() final  int durationMinutes;
@override@JsonKey() final  bool crossesMidnight;
@override final  String? punchInOpensAt;
@override@JsonKey() final  int earlyPunchInMinutes;
@override@JsonKey() final  int lateGraceMinutes;
@override@JsonKey() final  int statusId;
@override@JsonKey() final  String status;
@override@JsonKey() final  int activeAssignments;
@override final  DateTime? createdOn;
@override final  DateTime? modifiedOn;

/// Create a copy of ShiftDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShiftDtoCopyWith<_ShiftDto> get copyWith => __$ShiftDtoCopyWithImpl<_ShiftDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShiftDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShiftDto&&(identical(other.shiftId, shiftId) || other.shiftId == shiftId)&&(identical(other.shiftName, shiftName) || other.shiftName == shiftName)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.crossesMidnight, crossesMidnight) || other.crossesMidnight == crossesMidnight)&&(identical(other.punchInOpensAt, punchInOpensAt) || other.punchInOpensAt == punchInOpensAt)&&(identical(other.earlyPunchInMinutes, earlyPunchInMinutes) || other.earlyPunchInMinutes == earlyPunchInMinutes)&&(identical(other.lateGraceMinutes, lateGraceMinutes) || other.lateGraceMinutes == lateGraceMinutes)&&(identical(other.statusId, statusId) || other.statusId == statusId)&&(identical(other.status, status) || other.status == status)&&(identical(other.activeAssignments, activeAssignments) || other.activeAssignments == activeAssignments)&&(identical(other.createdOn, createdOn) || other.createdOn == createdOn)&&(identical(other.modifiedOn, modifiedOn) || other.modifiedOn == modifiedOn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shiftId,shiftName,startTime,endTime,durationMinutes,crossesMidnight,punchInOpensAt,earlyPunchInMinutes,lateGraceMinutes,statusId,status,activeAssignments,createdOn,modifiedOn);

@override
String toString() {
  return 'ShiftDto(shiftId: $shiftId, shiftName: $shiftName, startTime: $startTime, endTime: $endTime, durationMinutes: $durationMinutes, crossesMidnight: $crossesMidnight, punchInOpensAt: $punchInOpensAt, earlyPunchInMinutes: $earlyPunchInMinutes, lateGraceMinutes: $lateGraceMinutes, statusId: $statusId, status: $status, activeAssignments: $activeAssignments, createdOn: $createdOn, modifiedOn: $modifiedOn)';
}


}

/// @nodoc
abstract mixin class _$ShiftDtoCopyWith<$Res> implements $ShiftDtoCopyWith<$Res> {
  factory _$ShiftDtoCopyWith(_ShiftDto value, $Res Function(_ShiftDto) _then) = __$ShiftDtoCopyWithImpl;
@override @useResult
$Res call({
 int shiftId, String shiftName, String startTime, String endTime, int durationMinutes, bool crossesMidnight, String? punchInOpensAt, int earlyPunchInMinutes, int lateGraceMinutes, int statusId, String status, int activeAssignments, DateTime? createdOn, DateTime? modifiedOn
});




}
/// @nodoc
class __$ShiftDtoCopyWithImpl<$Res>
    implements _$ShiftDtoCopyWith<$Res> {
  __$ShiftDtoCopyWithImpl(this._self, this._then);

  final _ShiftDto _self;
  final $Res Function(_ShiftDto) _then;

/// Create a copy of ShiftDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shiftId = null,Object? shiftName = null,Object? startTime = null,Object? endTime = null,Object? durationMinutes = null,Object? crossesMidnight = null,Object? punchInOpensAt = freezed,Object? earlyPunchInMinutes = null,Object? lateGraceMinutes = null,Object? statusId = null,Object? status = null,Object? activeAssignments = null,Object? createdOn = freezed,Object? modifiedOn = freezed,}) {
  return _then(_ShiftDto(
shiftId: null == shiftId ? _self.shiftId : shiftId // ignore: cast_nullable_to_non_nullable
as int,shiftName: null == shiftName ? _self.shiftName : shiftName // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,crossesMidnight: null == crossesMidnight ? _self.crossesMidnight : crossesMidnight // ignore: cast_nullable_to_non_nullable
as bool,punchInOpensAt: freezed == punchInOpensAt ? _self.punchInOpensAt : punchInOpensAt // ignore: cast_nullable_to_non_nullable
as String?,earlyPunchInMinutes: null == earlyPunchInMinutes ? _self.earlyPunchInMinutes : earlyPunchInMinutes // ignore: cast_nullable_to_non_nullable
as int,lateGraceMinutes: null == lateGraceMinutes ? _self.lateGraceMinutes : lateGraceMinutes // ignore: cast_nullable_to_non_nullable
as int,statusId: null == statusId ? _self.statusId : statusId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,activeAssignments: null == activeAssignments ? _self.activeAssignments : activeAssignments // ignore: cast_nullable_to_non_nullable
as int,createdOn: freezed == createdOn ? _self.createdOn : createdOn // ignore: cast_nullable_to_non_nullable
as DateTime?,modifiedOn: freezed == modifiedOn ? _self.modifiedOn : modifiedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ShiftUpsertDto {

 String get shiftName; String get startTime; String get endTime; int get earlyPunchInMinutes; int get lateGraceMinutes;
/// Create a copy of ShiftUpsertDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShiftUpsertDtoCopyWith<ShiftUpsertDto> get copyWith => _$ShiftUpsertDtoCopyWithImpl<ShiftUpsertDto>(this as ShiftUpsertDto, _$identity);

  /// Serializes this ShiftUpsertDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShiftUpsertDto&&(identical(other.shiftName, shiftName) || other.shiftName == shiftName)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.earlyPunchInMinutes, earlyPunchInMinutes) || other.earlyPunchInMinutes == earlyPunchInMinutes)&&(identical(other.lateGraceMinutes, lateGraceMinutes) || other.lateGraceMinutes == lateGraceMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shiftName,startTime,endTime,earlyPunchInMinutes,lateGraceMinutes);

@override
String toString() {
  return 'ShiftUpsertDto(shiftName: $shiftName, startTime: $startTime, endTime: $endTime, earlyPunchInMinutes: $earlyPunchInMinutes, lateGraceMinutes: $lateGraceMinutes)';
}


}

/// @nodoc
abstract mixin class $ShiftUpsertDtoCopyWith<$Res>  {
  factory $ShiftUpsertDtoCopyWith(ShiftUpsertDto value, $Res Function(ShiftUpsertDto) _then) = _$ShiftUpsertDtoCopyWithImpl;
@useResult
$Res call({
 String shiftName, String startTime, String endTime, int earlyPunchInMinutes, int lateGraceMinutes
});




}
/// @nodoc
class _$ShiftUpsertDtoCopyWithImpl<$Res>
    implements $ShiftUpsertDtoCopyWith<$Res> {
  _$ShiftUpsertDtoCopyWithImpl(this._self, this._then);

  final ShiftUpsertDto _self;
  final $Res Function(ShiftUpsertDto) _then;

/// Create a copy of ShiftUpsertDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shiftName = null,Object? startTime = null,Object? endTime = null,Object? earlyPunchInMinutes = null,Object? lateGraceMinutes = null,}) {
  return _then(_self.copyWith(
shiftName: null == shiftName ? _self.shiftName : shiftName // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,earlyPunchInMinutes: null == earlyPunchInMinutes ? _self.earlyPunchInMinutes : earlyPunchInMinutes // ignore: cast_nullable_to_non_nullable
as int,lateGraceMinutes: null == lateGraceMinutes ? _self.lateGraceMinutes : lateGraceMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ShiftUpsertDto].
extension ShiftUpsertDtoPatterns on ShiftUpsertDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShiftUpsertDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShiftUpsertDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShiftUpsertDto value)  $default,){
final _that = this;
switch (_that) {
case _ShiftUpsertDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShiftUpsertDto value)?  $default,){
final _that = this;
switch (_that) {
case _ShiftUpsertDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String shiftName,  String startTime,  String endTime,  int earlyPunchInMinutes,  int lateGraceMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShiftUpsertDto() when $default != null:
return $default(_that.shiftName,_that.startTime,_that.endTime,_that.earlyPunchInMinutes,_that.lateGraceMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String shiftName,  String startTime,  String endTime,  int earlyPunchInMinutes,  int lateGraceMinutes)  $default,) {final _that = this;
switch (_that) {
case _ShiftUpsertDto():
return $default(_that.shiftName,_that.startTime,_that.endTime,_that.earlyPunchInMinutes,_that.lateGraceMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String shiftName,  String startTime,  String endTime,  int earlyPunchInMinutes,  int lateGraceMinutes)?  $default,) {final _that = this;
switch (_that) {
case _ShiftUpsertDto() when $default != null:
return $default(_that.shiftName,_that.startTime,_that.endTime,_that.earlyPunchInMinutes,_that.lateGraceMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShiftUpsertDto implements ShiftUpsertDto {
  const _ShiftUpsertDto({required this.shiftName, required this.startTime, required this.endTime, required this.earlyPunchInMinutes, required this.lateGraceMinutes});
  factory _ShiftUpsertDto.fromJson(Map<String, dynamic> json) => _$ShiftUpsertDtoFromJson(json);

@override final  String shiftName;
@override final  String startTime;
@override final  String endTime;
@override final  int earlyPunchInMinutes;
@override final  int lateGraceMinutes;

/// Create a copy of ShiftUpsertDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShiftUpsertDtoCopyWith<_ShiftUpsertDto> get copyWith => __$ShiftUpsertDtoCopyWithImpl<_ShiftUpsertDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShiftUpsertDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShiftUpsertDto&&(identical(other.shiftName, shiftName) || other.shiftName == shiftName)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.earlyPunchInMinutes, earlyPunchInMinutes) || other.earlyPunchInMinutes == earlyPunchInMinutes)&&(identical(other.lateGraceMinutes, lateGraceMinutes) || other.lateGraceMinutes == lateGraceMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shiftName,startTime,endTime,earlyPunchInMinutes,lateGraceMinutes);

@override
String toString() {
  return 'ShiftUpsertDto(shiftName: $shiftName, startTime: $startTime, endTime: $endTime, earlyPunchInMinutes: $earlyPunchInMinutes, lateGraceMinutes: $lateGraceMinutes)';
}


}

/// @nodoc
abstract mixin class _$ShiftUpsertDtoCopyWith<$Res> implements $ShiftUpsertDtoCopyWith<$Res> {
  factory _$ShiftUpsertDtoCopyWith(_ShiftUpsertDto value, $Res Function(_ShiftUpsertDto) _then) = __$ShiftUpsertDtoCopyWithImpl;
@override @useResult
$Res call({
 String shiftName, String startTime, String endTime, int earlyPunchInMinutes, int lateGraceMinutes
});




}
/// @nodoc
class __$ShiftUpsertDtoCopyWithImpl<$Res>
    implements _$ShiftUpsertDtoCopyWith<$Res> {
  __$ShiftUpsertDtoCopyWithImpl(this._self, this._then);

  final _ShiftUpsertDto _self;
  final $Res Function(_ShiftUpsertDto) _then;

/// Create a copy of ShiftUpsertDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shiftName = null,Object? startTime = null,Object? endTime = null,Object? earlyPunchInMinutes = null,Object? lateGraceMinutes = null,}) {
  return _then(_ShiftUpsertDto(
shiftName: null == shiftName ? _self.shiftName : shiftName // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,earlyPunchInMinutes: null == earlyPunchInMinutes ? _self.earlyPunchInMinutes : earlyPunchInMinutes // ignore: cast_nullable_to_non_nullable
as int,lateGraceMinutes: null == lateGraceMinutes ? _self.lateGraceMinutes : lateGraceMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
