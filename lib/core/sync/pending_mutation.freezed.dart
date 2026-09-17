// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pending_mutation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PendingMutation {

 String get id; String get moduleId; String get entityId; String get operation; Map<String, dynamic> get payload; DateTime get createdAt;
/// Create a copy of PendingMutation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingMutationCopyWith<PendingMutation> get copyWith => _$PendingMutationCopyWithImpl<PendingMutation>(this as PendingMutation, _$identity);

  /// Serializes this PendingMutation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingMutation&&(identical(other.id, id) || other.id == id)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.operation, operation) || other.operation == operation)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,moduleId,entityId,operation,const DeepCollectionEquality().hash(payload),createdAt);

@override
String toString() {
  return 'PendingMutation(id: $id, moduleId: $moduleId, entityId: $entityId, operation: $operation, payload: $payload, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PendingMutationCopyWith<$Res>  {
  factory $PendingMutationCopyWith(PendingMutation value, $Res Function(PendingMutation) _then) = _$PendingMutationCopyWithImpl;
@useResult
$Res call({
 String id, String moduleId, String entityId, String operation, Map<String, dynamic> payload, DateTime createdAt
});




}
/// @nodoc
class _$PendingMutationCopyWithImpl<$Res>
    implements $PendingMutationCopyWith<$Res> {
  _$PendingMutationCopyWithImpl(this._self, this._then);

  final PendingMutation _self;
  final $Res Function(PendingMutation) _then;

/// Create a copy of PendingMutation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? moduleId = null,Object? entityId = null,Object? operation = null,Object? payload = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,moduleId: null == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingMutation].
extension PendingMutationPatterns on PendingMutation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingMutation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingMutation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingMutation value)  $default,){
final _that = this;
switch (_that) {
case _PendingMutation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingMutation value)?  $default,){
final _that = this;
switch (_that) {
case _PendingMutation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String moduleId,  String entityId,  String operation,  Map<String, dynamic> payload,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingMutation() when $default != null:
return $default(_that.id,_that.moduleId,_that.entityId,_that.operation,_that.payload,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String moduleId,  String entityId,  String operation,  Map<String, dynamic> payload,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PendingMutation():
return $default(_that.id,_that.moduleId,_that.entityId,_that.operation,_that.payload,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String moduleId,  String entityId,  String operation,  Map<String, dynamic> payload,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PendingMutation() when $default != null:
return $default(_that.id,_that.moduleId,_that.entityId,_that.operation,_that.payload,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingMutation implements PendingMutation {
  const _PendingMutation({required this.id, required this.moduleId, required this.entityId, required this.operation, required final  Map<String, dynamic> payload, required this.createdAt}): _payload = payload;
  factory _PendingMutation.fromJson(Map<String, dynamic> json) => _$PendingMutationFromJson(json);

@override final  String id;
@override final  String moduleId;
@override final  String entityId;
@override final  String operation;
 final  Map<String, dynamic> _payload;
@override Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}

@override final  DateTime createdAt;

/// Create a copy of PendingMutation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingMutationCopyWith<_PendingMutation> get copyWith => __$PendingMutationCopyWithImpl<_PendingMutation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingMutationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingMutation&&(identical(other.id, id) || other.id == id)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.operation, operation) || other.operation == operation)&&const DeepCollectionEquality().equals(other._payload, _payload)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,moduleId,entityId,operation,const DeepCollectionEquality().hash(_payload),createdAt);

@override
String toString() {
  return 'PendingMutation(id: $id, moduleId: $moduleId, entityId: $entityId, operation: $operation, payload: $payload, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PendingMutationCopyWith<$Res> implements $PendingMutationCopyWith<$Res> {
  factory _$PendingMutationCopyWith(_PendingMutation value, $Res Function(_PendingMutation) _then) = __$PendingMutationCopyWithImpl;
@override @useResult
$Res call({
 String id, String moduleId, String entityId, String operation, Map<String, dynamic> payload, DateTime createdAt
});




}
/// @nodoc
class __$PendingMutationCopyWithImpl<$Res>
    implements _$PendingMutationCopyWith<$Res> {
  __$PendingMutationCopyWithImpl(this._self, this._then);

  final _PendingMutation _self;
  final $Res Function(_PendingMutation) _then;

/// Create a copy of PendingMutation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? moduleId = null,Object? entityId = null,Object? operation = null,Object? payload = null,Object? createdAt = null,}) {
  return _then(_PendingMutation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,moduleId: null == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
