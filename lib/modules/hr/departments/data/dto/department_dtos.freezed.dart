// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'department_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DepartmentDto {

 int get departmentId; String get departmentName; int get employeeCount;
/// Create a copy of DepartmentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DepartmentDtoCopyWith<DepartmentDto> get copyWith => _$DepartmentDtoCopyWithImpl<DepartmentDto>(this as DepartmentDto, _$identity);

  /// Serializes this DepartmentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DepartmentDto&&(identical(other.departmentId, departmentId) || other.departmentId == departmentId)&&(identical(other.departmentName, departmentName) || other.departmentName == departmentName)&&(identical(other.employeeCount, employeeCount) || other.employeeCount == employeeCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,departmentId,departmentName,employeeCount);

@override
String toString() {
  return 'DepartmentDto(departmentId: $departmentId, departmentName: $departmentName, employeeCount: $employeeCount)';
}


}

/// @nodoc
abstract mixin class $DepartmentDtoCopyWith<$Res>  {
  factory $DepartmentDtoCopyWith(DepartmentDto value, $Res Function(DepartmentDto) _then) = _$DepartmentDtoCopyWithImpl;
@useResult
$Res call({
 int departmentId, String departmentName, int employeeCount
});




}
/// @nodoc
class _$DepartmentDtoCopyWithImpl<$Res>
    implements $DepartmentDtoCopyWith<$Res> {
  _$DepartmentDtoCopyWithImpl(this._self, this._then);

  final DepartmentDto _self;
  final $Res Function(DepartmentDto) _then;

/// Create a copy of DepartmentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? departmentId = null,Object? departmentName = null,Object? employeeCount = null,}) {
  return _then(_self.copyWith(
departmentId: null == departmentId ? _self.departmentId : departmentId // ignore: cast_nullable_to_non_nullable
as int,departmentName: null == departmentName ? _self.departmentName : departmentName // ignore: cast_nullable_to_non_nullable
as String,employeeCount: null == employeeCount ? _self.employeeCount : employeeCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DepartmentDto].
extension DepartmentDtoPatterns on DepartmentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DepartmentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DepartmentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DepartmentDto value)  $default,){
final _that = this;
switch (_that) {
case _DepartmentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DepartmentDto value)?  $default,){
final _that = this;
switch (_that) {
case _DepartmentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int departmentId,  String departmentName,  int employeeCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DepartmentDto() when $default != null:
return $default(_that.departmentId,_that.departmentName,_that.employeeCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int departmentId,  String departmentName,  int employeeCount)  $default,) {final _that = this;
switch (_that) {
case _DepartmentDto():
return $default(_that.departmentId,_that.departmentName,_that.employeeCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int departmentId,  String departmentName,  int employeeCount)?  $default,) {final _that = this;
switch (_that) {
case _DepartmentDto() when $default != null:
return $default(_that.departmentId,_that.departmentName,_that.employeeCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DepartmentDto implements DepartmentDto {
  const _DepartmentDto({required this.departmentId, required this.departmentName, this.employeeCount = 0});
  factory _DepartmentDto.fromJson(Map<String, dynamic> json) => _$DepartmentDtoFromJson(json);

@override final  int departmentId;
@override final  String departmentName;
@override@JsonKey() final  int employeeCount;

/// Create a copy of DepartmentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DepartmentDtoCopyWith<_DepartmentDto> get copyWith => __$DepartmentDtoCopyWithImpl<_DepartmentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DepartmentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DepartmentDto&&(identical(other.departmentId, departmentId) || other.departmentId == departmentId)&&(identical(other.departmentName, departmentName) || other.departmentName == departmentName)&&(identical(other.employeeCount, employeeCount) || other.employeeCount == employeeCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,departmentId,departmentName,employeeCount);

@override
String toString() {
  return 'DepartmentDto(departmentId: $departmentId, departmentName: $departmentName, employeeCount: $employeeCount)';
}


}

/// @nodoc
abstract mixin class _$DepartmentDtoCopyWith<$Res> implements $DepartmentDtoCopyWith<$Res> {
  factory _$DepartmentDtoCopyWith(_DepartmentDto value, $Res Function(_DepartmentDto) _then) = __$DepartmentDtoCopyWithImpl;
@override @useResult
$Res call({
 int departmentId, String departmentName, int employeeCount
});




}
/// @nodoc
class __$DepartmentDtoCopyWithImpl<$Res>
    implements _$DepartmentDtoCopyWith<$Res> {
  __$DepartmentDtoCopyWithImpl(this._self, this._then);

  final _DepartmentDto _self;
  final $Res Function(_DepartmentDto) _then;

/// Create a copy of DepartmentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? departmentId = null,Object? departmentName = null,Object? employeeCount = null,}) {
  return _then(_DepartmentDto(
departmentId: null == departmentId ? _self.departmentId : departmentId // ignore: cast_nullable_to_non_nullable
as int,departmentName: null == departmentName ? _self.departmentName : departmentName // ignore: cast_nullable_to_non_nullable
as String,employeeCount: null == employeeCount ? _self.employeeCount : employeeCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$DepartmentUpsertDto {

 String get departmentName;
/// Create a copy of DepartmentUpsertDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DepartmentUpsertDtoCopyWith<DepartmentUpsertDto> get copyWith => _$DepartmentUpsertDtoCopyWithImpl<DepartmentUpsertDto>(this as DepartmentUpsertDto, _$identity);

  /// Serializes this DepartmentUpsertDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DepartmentUpsertDto&&(identical(other.departmentName, departmentName) || other.departmentName == departmentName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,departmentName);

@override
String toString() {
  return 'DepartmentUpsertDto(departmentName: $departmentName)';
}


}

/// @nodoc
abstract mixin class $DepartmentUpsertDtoCopyWith<$Res>  {
  factory $DepartmentUpsertDtoCopyWith(DepartmentUpsertDto value, $Res Function(DepartmentUpsertDto) _then) = _$DepartmentUpsertDtoCopyWithImpl;
@useResult
$Res call({
 String departmentName
});




}
/// @nodoc
class _$DepartmentUpsertDtoCopyWithImpl<$Res>
    implements $DepartmentUpsertDtoCopyWith<$Res> {
  _$DepartmentUpsertDtoCopyWithImpl(this._self, this._then);

  final DepartmentUpsertDto _self;
  final $Res Function(DepartmentUpsertDto) _then;

/// Create a copy of DepartmentUpsertDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? departmentName = null,}) {
  return _then(_self.copyWith(
departmentName: null == departmentName ? _self.departmentName : departmentName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DepartmentUpsertDto].
extension DepartmentUpsertDtoPatterns on DepartmentUpsertDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DepartmentUpsertDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DepartmentUpsertDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DepartmentUpsertDto value)  $default,){
final _that = this;
switch (_that) {
case _DepartmentUpsertDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DepartmentUpsertDto value)?  $default,){
final _that = this;
switch (_that) {
case _DepartmentUpsertDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String departmentName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DepartmentUpsertDto() when $default != null:
return $default(_that.departmentName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String departmentName)  $default,) {final _that = this;
switch (_that) {
case _DepartmentUpsertDto():
return $default(_that.departmentName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String departmentName)?  $default,) {final _that = this;
switch (_that) {
case _DepartmentUpsertDto() when $default != null:
return $default(_that.departmentName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DepartmentUpsertDto implements DepartmentUpsertDto {
  const _DepartmentUpsertDto({required this.departmentName});
  factory _DepartmentUpsertDto.fromJson(Map<String, dynamic> json) => _$DepartmentUpsertDtoFromJson(json);

@override final  String departmentName;

/// Create a copy of DepartmentUpsertDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DepartmentUpsertDtoCopyWith<_DepartmentUpsertDto> get copyWith => __$DepartmentUpsertDtoCopyWithImpl<_DepartmentUpsertDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DepartmentUpsertDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DepartmentUpsertDto&&(identical(other.departmentName, departmentName) || other.departmentName == departmentName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,departmentName);

@override
String toString() {
  return 'DepartmentUpsertDto(departmentName: $departmentName)';
}


}

/// @nodoc
abstract mixin class _$DepartmentUpsertDtoCopyWith<$Res> implements $DepartmentUpsertDtoCopyWith<$Res> {
  factory _$DepartmentUpsertDtoCopyWith(_DepartmentUpsertDto value, $Res Function(_DepartmentUpsertDto) _then) = __$DepartmentUpsertDtoCopyWithImpl;
@override @useResult
$Res call({
 String departmentName
});




}
/// @nodoc
class __$DepartmentUpsertDtoCopyWithImpl<$Res>
    implements _$DepartmentUpsertDtoCopyWith<$Res> {
  __$DepartmentUpsertDtoCopyWithImpl(this._self, this._then);

  final _DepartmentUpsertDto _self;
  final $Res Function(_DepartmentUpsertDto) _then;

/// Create a copy of DepartmentUpsertDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? departmentName = null,}) {
  return _then(_DepartmentUpsertDto(
departmentName: null == departmentName ? _self.departmentName : departmentName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
