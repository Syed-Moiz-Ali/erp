// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_envelope.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiEnvelope<T> {

 bool get success; String get message; T? get data; List<ApiError> get errors;
/// Create a copy of ApiEnvelope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiEnvelopeCopyWith<T, ApiEnvelope<T>> get copyWith => _$ApiEnvelopeCopyWithImpl<T, ApiEnvelope<T>>(this as ApiEnvelope<T>, _$identity);

  /// Serializes this ApiEnvelope to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiEnvelope<T>&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.data, data)&&const DeepCollectionEquality().equals(other.errors, errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message,const DeepCollectionEquality().hash(data),const DeepCollectionEquality().hash(errors));

@override
String toString() {
  return 'ApiEnvelope<$T>(success: $success, message: $message, data: $data, errors: $errors)';
}


}

/// @nodoc
abstract mixin class $ApiEnvelopeCopyWith<T,$Res>  {
  factory $ApiEnvelopeCopyWith(ApiEnvelope<T> value, $Res Function(ApiEnvelope<T>) _then) = _$ApiEnvelopeCopyWithImpl;
@useResult
$Res call({
 bool success, String message, T? data, List<ApiError> errors
});




}
/// @nodoc
class _$ApiEnvelopeCopyWithImpl<T,$Res>
    implements $ApiEnvelopeCopyWith<T, $Res> {
  _$ApiEnvelopeCopyWithImpl(this._self, this._then);

  final ApiEnvelope<T> _self;
  final $Res Function(ApiEnvelope<T>) _then;

/// Create a copy of ApiEnvelope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? message = null,Object? data = freezed,Object? errors = null,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<ApiError>,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiEnvelope].
extension ApiEnvelopePatterns<T> on ApiEnvelope<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiEnvelope<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiEnvelope() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiEnvelope<T> value)  $default,){
final _that = this;
switch (_that) {
case _ApiEnvelope():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiEnvelope<T> value)?  $default,){
final _that = this;
switch (_that) {
case _ApiEnvelope() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  String message,  T? data,  List<ApiError> errors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiEnvelope() when $default != null:
return $default(_that.success,_that.message,_that.data,_that.errors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  String message,  T? data,  List<ApiError> errors)  $default,) {final _that = this;
switch (_that) {
case _ApiEnvelope():
return $default(_that.success,_that.message,_that.data,_that.errors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  String message,  T? data,  List<ApiError> errors)?  $default,) {final _that = this;
switch (_that) {
case _ApiEnvelope() when $default != null:
return $default(_that.success,_that.message,_that.data,_that.errors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _ApiEnvelope<T> implements ApiEnvelope<T> {
  const _ApiEnvelope({required this.success, this.message = '', this.data, final  List<ApiError> errors = const <ApiError>[]}): _errors = errors;
  factory _ApiEnvelope.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$ApiEnvelopeFromJson(json,fromJsonT);

@override final  bool success;
@override@JsonKey() final  String message;
@override final  T? data;
 final  List<ApiError> _errors;
@override@JsonKey() List<ApiError> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}


/// Create a copy of ApiEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiEnvelopeCopyWith<T, _ApiEnvelope<T>> get copyWith => __$ApiEnvelopeCopyWithImpl<T, _ApiEnvelope<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$ApiEnvelopeToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiEnvelope<T>&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.data, data)&&const DeepCollectionEquality().equals(other._errors, _errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message,const DeepCollectionEquality().hash(data),const DeepCollectionEquality().hash(_errors));

@override
String toString() {
  return 'ApiEnvelope<$T>(success: $success, message: $message, data: $data, errors: $errors)';
}


}

/// @nodoc
abstract mixin class _$ApiEnvelopeCopyWith<T,$Res> implements $ApiEnvelopeCopyWith<T, $Res> {
  factory _$ApiEnvelopeCopyWith(_ApiEnvelope<T> value, $Res Function(_ApiEnvelope<T>) _then) = __$ApiEnvelopeCopyWithImpl;
@override @useResult
$Res call({
 bool success, String message, T? data, List<ApiError> errors
});




}
/// @nodoc
class __$ApiEnvelopeCopyWithImpl<T,$Res>
    implements _$ApiEnvelopeCopyWith<T, $Res> {
  __$ApiEnvelopeCopyWithImpl(this._self, this._then);

  final _ApiEnvelope<T> _self;
  final $Res Function(_ApiEnvelope<T>) _then;

/// Create a copy of ApiEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? message = null,Object? data = freezed,Object? errors = null,}) {
  return _then(_ApiEnvelope<T>(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<ApiError>,
  ));
}


}

// dart format on
