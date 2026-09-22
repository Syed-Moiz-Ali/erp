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

 String get id; String get moduleId; String get entityId; String get operation; Map<String, dynamic> get payload; DateTime get createdAt; String? get companyId; String? get entityType; String? get requestId; OutboxOperationStatus get status; int get attemptCount; DateTime? get lastAttemptAt; DateTime? get nextAttemptAt; String? get failureCode; String? get lastFailureMessageSafe; Map<String, dynamic>? get serverResponseMetadata; int get payloadVersion; DateTime? get processingStartedAt; String? get processorId;
/// Create a copy of PendingMutation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingMutationCopyWith<PendingMutation> get copyWith => _$PendingMutationCopyWithImpl<PendingMutation>(this as PendingMutation, _$identity);

  /// Serializes this PendingMutation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingMutation&&(identical(other.id, id) || other.id == id)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.operation, operation) || other.operation == operation)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.status, status) || other.status == status)&&(identical(other.attemptCount, attemptCount) || other.attemptCount == attemptCount)&&(identical(other.lastAttemptAt, lastAttemptAt) || other.lastAttemptAt == lastAttemptAt)&&(identical(other.nextAttemptAt, nextAttemptAt) || other.nextAttemptAt == nextAttemptAt)&&(identical(other.failureCode, failureCode) || other.failureCode == failureCode)&&(identical(other.lastFailureMessageSafe, lastFailureMessageSafe) || other.lastFailureMessageSafe == lastFailureMessageSafe)&&const DeepCollectionEquality().equals(other.serverResponseMetadata, serverResponseMetadata)&&(identical(other.payloadVersion, payloadVersion) || other.payloadVersion == payloadVersion)&&(identical(other.processingStartedAt, processingStartedAt) || other.processingStartedAt == processingStartedAt)&&(identical(other.processorId, processorId) || other.processorId == processorId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,moduleId,entityId,operation,const DeepCollectionEquality().hash(payload),createdAt,companyId,entityType,requestId,status,attemptCount,lastAttemptAt,nextAttemptAt,failureCode,lastFailureMessageSafe,const DeepCollectionEquality().hash(serverResponseMetadata),payloadVersion,processingStartedAt,processorId]);

@override
String toString() {
  return 'PendingMutation(id: $id, moduleId: $moduleId, entityId: $entityId, operation: $operation, payload: $payload, createdAt: $createdAt, companyId: $companyId, entityType: $entityType, requestId: $requestId, status: $status, attemptCount: $attemptCount, lastAttemptAt: $lastAttemptAt, nextAttemptAt: $nextAttemptAt, failureCode: $failureCode, lastFailureMessageSafe: $lastFailureMessageSafe, serverResponseMetadata: $serverResponseMetadata, payloadVersion: $payloadVersion, processingStartedAt: $processingStartedAt, processorId: $processorId)';
}


}

/// @nodoc
abstract mixin class $PendingMutationCopyWith<$Res>  {
  factory $PendingMutationCopyWith(PendingMutation value, $Res Function(PendingMutation) _then) = _$PendingMutationCopyWithImpl;
@useResult
$Res call({
 String id, String moduleId, String entityId, String operation, Map<String, dynamic> payload, DateTime createdAt, String? companyId, String? entityType, String? requestId, OutboxOperationStatus status, int attemptCount, DateTime? lastAttemptAt, DateTime? nextAttemptAt, String? failureCode, String? lastFailureMessageSafe, Map<String, dynamic>? serverResponseMetadata, int payloadVersion, DateTime? processingStartedAt, String? processorId
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? moduleId = null,Object? entityId = null,Object? operation = null,Object? payload = null,Object? createdAt = null,Object? companyId = freezed,Object? entityType = freezed,Object? requestId = freezed,Object? status = null,Object? attemptCount = null,Object? lastAttemptAt = freezed,Object? nextAttemptAt = freezed,Object? failureCode = freezed,Object? lastFailureMessageSafe = freezed,Object? serverResponseMetadata = freezed,Object? payloadVersion = null,Object? processingStartedAt = freezed,Object? processorId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,moduleId: null == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,entityType: freezed == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OutboxOperationStatus,attemptCount: null == attemptCount ? _self.attemptCount : attemptCount // ignore: cast_nullable_to_non_nullable
as int,lastAttemptAt: freezed == lastAttemptAt ? _self.lastAttemptAt : lastAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nextAttemptAt: freezed == nextAttemptAt ? _self.nextAttemptAt : nextAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureCode: freezed == failureCode ? _self.failureCode : failureCode // ignore: cast_nullable_to_non_nullable
as String?,lastFailureMessageSafe: freezed == lastFailureMessageSafe ? _self.lastFailureMessageSafe : lastFailureMessageSafe // ignore: cast_nullable_to_non_nullable
as String?,serverResponseMetadata: freezed == serverResponseMetadata ? _self.serverResponseMetadata : serverResponseMetadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,payloadVersion: null == payloadVersion ? _self.payloadVersion : payloadVersion // ignore: cast_nullable_to_non_nullable
as int,processingStartedAt: freezed == processingStartedAt ? _self.processingStartedAt : processingStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,processorId: freezed == processorId ? _self.processorId : processorId // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String moduleId,  String entityId,  String operation,  Map<String, dynamic> payload,  DateTime createdAt,  String? companyId,  String? entityType,  String? requestId,  OutboxOperationStatus status,  int attemptCount,  DateTime? lastAttemptAt,  DateTime? nextAttemptAt,  String? failureCode,  String? lastFailureMessageSafe,  Map<String, dynamic>? serverResponseMetadata,  int payloadVersion,  DateTime? processingStartedAt,  String? processorId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingMutation() when $default != null:
return $default(_that.id,_that.moduleId,_that.entityId,_that.operation,_that.payload,_that.createdAt,_that.companyId,_that.entityType,_that.requestId,_that.status,_that.attemptCount,_that.lastAttemptAt,_that.nextAttemptAt,_that.failureCode,_that.lastFailureMessageSafe,_that.serverResponseMetadata,_that.payloadVersion,_that.processingStartedAt,_that.processorId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String moduleId,  String entityId,  String operation,  Map<String, dynamic> payload,  DateTime createdAt,  String? companyId,  String? entityType,  String? requestId,  OutboxOperationStatus status,  int attemptCount,  DateTime? lastAttemptAt,  DateTime? nextAttemptAt,  String? failureCode,  String? lastFailureMessageSafe,  Map<String, dynamic>? serverResponseMetadata,  int payloadVersion,  DateTime? processingStartedAt,  String? processorId)  $default,) {final _that = this;
switch (_that) {
case _PendingMutation():
return $default(_that.id,_that.moduleId,_that.entityId,_that.operation,_that.payload,_that.createdAt,_that.companyId,_that.entityType,_that.requestId,_that.status,_that.attemptCount,_that.lastAttemptAt,_that.nextAttemptAt,_that.failureCode,_that.lastFailureMessageSafe,_that.serverResponseMetadata,_that.payloadVersion,_that.processingStartedAt,_that.processorId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String moduleId,  String entityId,  String operation,  Map<String, dynamic> payload,  DateTime createdAt,  String? companyId,  String? entityType,  String? requestId,  OutboxOperationStatus status,  int attemptCount,  DateTime? lastAttemptAt,  DateTime? nextAttemptAt,  String? failureCode,  String? lastFailureMessageSafe,  Map<String, dynamic>? serverResponseMetadata,  int payloadVersion,  DateTime? processingStartedAt,  String? processorId)?  $default,) {final _that = this;
switch (_that) {
case _PendingMutation() when $default != null:
return $default(_that.id,_that.moduleId,_that.entityId,_that.operation,_that.payload,_that.createdAt,_that.companyId,_that.entityType,_that.requestId,_that.status,_that.attemptCount,_that.lastAttemptAt,_that.nextAttemptAt,_that.failureCode,_that.lastFailureMessageSafe,_that.serverResponseMetadata,_that.payloadVersion,_that.processingStartedAt,_that.processorId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingMutation extends PendingMutation {
  const _PendingMutation({required this.id, required this.moduleId, required this.entityId, required this.operation, required final  Map<String, dynamic> payload, required this.createdAt, this.companyId, this.entityType, this.requestId, this.status = OutboxOperationStatus.pending, this.attemptCount = 0, this.lastAttemptAt, this.nextAttemptAt, this.failureCode, this.lastFailureMessageSafe, final  Map<String, dynamic>? serverResponseMetadata, this.payloadVersion = 1, this.processingStartedAt, this.processorId}): _payload = payload,_serverResponseMetadata = serverResponseMetadata,super._();
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
@override final  String? companyId;
@override final  String? entityType;
@override final  String? requestId;
@override@JsonKey() final  OutboxOperationStatus status;
@override@JsonKey() final  int attemptCount;
@override final  DateTime? lastAttemptAt;
@override final  DateTime? nextAttemptAt;
@override final  String? failureCode;
@override final  String? lastFailureMessageSafe;
 final  Map<String, dynamic>? _serverResponseMetadata;
@override Map<String, dynamic>? get serverResponseMetadata {
  final value = _serverResponseMetadata;
  if (value == null) return null;
  if (_serverResponseMetadata is EqualUnmodifiableMapView) return _serverResponseMetadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  int payloadVersion;
@override final  DateTime? processingStartedAt;
@override final  String? processorId;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingMutation&&(identical(other.id, id) || other.id == id)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.operation, operation) || other.operation == operation)&&const DeepCollectionEquality().equals(other._payload, _payload)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.status, status) || other.status == status)&&(identical(other.attemptCount, attemptCount) || other.attemptCount == attemptCount)&&(identical(other.lastAttemptAt, lastAttemptAt) || other.lastAttemptAt == lastAttemptAt)&&(identical(other.nextAttemptAt, nextAttemptAt) || other.nextAttemptAt == nextAttemptAt)&&(identical(other.failureCode, failureCode) || other.failureCode == failureCode)&&(identical(other.lastFailureMessageSafe, lastFailureMessageSafe) || other.lastFailureMessageSafe == lastFailureMessageSafe)&&const DeepCollectionEquality().equals(other._serverResponseMetadata, _serverResponseMetadata)&&(identical(other.payloadVersion, payloadVersion) || other.payloadVersion == payloadVersion)&&(identical(other.processingStartedAt, processingStartedAt) || other.processingStartedAt == processingStartedAt)&&(identical(other.processorId, processorId) || other.processorId == processorId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,moduleId,entityId,operation,const DeepCollectionEquality().hash(_payload),createdAt,companyId,entityType,requestId,status,attemptCount,lastAttemptAt,nextAttemptAt,failureCode,lastFailureMessageSafe,const DeepCollectionEquality().hash(_serverResponseMetadata),payloadVersion,processingStartedAt,processorId]);

@override
String toString() {
  return 'PendingMutation(id: $id, moduleId: $moduleId, entityId: $entityId, operation: $operation, payload: $payload, createdAt: $createdAt, companyId: $companyId, entityType: $entityType, requestId: $requestId, status: $status, attemptCount: $attemptCount, lastAttemptAt: $lastAttemptAt, nextAttemptAt: $nextAttemptAt, failureCode: $failureCode, lastFailureMessageSafe: $lastFailureMessageSafe, serverResponseMetadata: $serverResponseMetadata, payloadVersion: $payloadVersion, processingStartedAt: $processingStartedAt, processorId: $processorId)';
}


}

/// @nodoc
abstract mixin class _$PendingMutationCopyWith<$Res> implements $PendingMutationCopyWith<$Res> {
  factory _$PendingMutationCopyWith(_PendingMutation value, $Res Function(_PendingMutation) _then) = __$PendingMutationCopyWithImpl;
@override @useResult
$Res call({
 String id, String moduleId, String entityId, String operation, Map<String, dynamic> payload, DateTime createdAt, String? companyId, String? entityType, String? requestId, OutboxOperationStatus status, int attemptCount, DateTime? lastAttemptAt, DateTime? nextAttemptAt, String? failureCode, String? lastFailureMessageSafe, Map<String, dynamic>? serverResponseMetadata, int payloadVersion, DateTime? processingStartedAt, String? processorId
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? moduleId = null,Object? entityId = null,Object? operation = null,Object? payload = null,Object? createdAt = null,Object? companyId = freezed,Object? entityType = freezed,Object? requestId = freezed,Object? status = null,Object? attemptCount = null,Object? lastAttemptAt = freezed,Object? nextAttemptAt = freezed,Object? failureCode = freezed,Object? lastFailureMessageSafe = freezed,Object? serverResponseMetadata = freezed,Object? payloadVersion = null,Object? processingStartedAt = freezed,Object? processorId = freezed,}) {
  return _then(_PendingMutation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,moduleId: null == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,entityType: freezed == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OutboxOperationStatus,attemptCount: null == attemptCount ? _self.attemptCount : attemptCount // ignore: cast_nullable_to_non_nullable
as int,lastAttemptAt: freezed == lastAttemptAt ? _self.lastAttemptAt : lastAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nextAttemptAt: freezed == nextAttemptAt ? _self.nextAttemptAt : nextAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureCode: freezed == failureCode ? _self.failureCode : failureCode // ignore: cast_nullable_to_non_nullable
as String?,lastFailureMessageSafe: freezed == lastFailureMessageSafe ? _self.lastFailureMessageSafe : lastFailureMessageSafe // ignore: cast_nullable_to_non_nullable
as String?,serverResponseMetadata: freezed == serverResponseMetadata ? _self._serverResponseMetadata : serverResponseMetadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,payloadVersion: null == payloadVersion ? _self.payloadVersion : payloadVersion // ignore: cast_nullable_to_non_nullable
as int,processingStartedAt: freezed == processingStartedAt ? _self.processingStartedAt : processingStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,processorId: freezed == processorId ? _self.processorId : processorId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
