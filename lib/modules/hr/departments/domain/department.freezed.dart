// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'department.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Department {

 String get id; String get companyId; String get name; ConfigurationStatus get status; DateTime get createdAt; DateTime get updatedAt; RecordSyncStatus get syncStatus;
/// Create a copy of Department
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DepartmentCopyWith<Department> get copyWith => _$DepartmentCopyWithImpl<Department>(this as Department, _$identity);

  /// Serializes this Department to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Department&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,name,status,createdAt,updatedAt,syncStatus);

@override
String toString() {
  return 'Department(id: $id, companyId: $companyId, name: $name, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $DepartmentCopyWith<$Res>  {
  factory $DepartmentCopyWith(Department value, $Res Function(Department) _then) = _$DepartmentCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String name, ConfigurationStatus status, DateTime createdAt, DateTime updatedAt, RecordSyncStatus syncStatus
});




}
/// @nodoc
class _$DepartmentCopyWithImpl<$Res>
    implements $DepartmentCopyWith<$Res> {
  _$DepartmentCopyWithImpl(this._self, this._then);

  final Department _self;
  final $Res Function(Department) _then;

/// Create a copy of Department
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as RecordSyncStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Department].
extension DepartmentPatterns on Department {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Department value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Department() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Department value)  $default,){
final _that = this;
switch (_that) {
case _Department():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Department value)?  $default,){
final _that = this;
switch (_that) {
case _Department() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Department() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)  $default,) {final _that = this;
switch (_that) {
case _Department():
return $default(_that.id,_that.companyId,_that.name,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String name,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _Department() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Department extends Department {
  const _Department({required this.id, required this.companyId, required this.name, this.status = ConfigurationStatus.active, required this.createdAt, required this.updatedAt, this.syncStatus = RecordSyncStatus.synced}): super._();
  factory _Department.fromJson(Map<String, dynamic> json) => _$DepartmentFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  String name;
@override@JsonKey() final  ConfigurationStatus status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  RecordSyncStatus syncStatus;

/// Create a copy of Department
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DepartmentCopyWith<_Department> get copyWith => __$DepartmentCopyWithImpl<_Department>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DepartmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Department&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,name,status,createdAt,updatedAt,syncStatus);

@override
String toString() {
  return 'Department(id: $id, companyId: $companyId, name: $name, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$DepartmentCopyWith<$Res> implements $DepartmentCopyWith<$Res> {
  factory _$DepartmentCopyWith(_Department value, $Res Function(_Department) _then) = __$DepartmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String name, ConfigurationStatus status, DateTime createdAt, DateTime updatedAt, RecordSyncStatus syncStatus
});




}
/// @nodoc
class __$DepartmentCopyWithImpl<$Res>
    implements _$DepartmentCopyWith<$Res> {
  __$DepartmentCopyWithImpl(this._self, this._then);

  final _Department _self;
  final $Res Function(_Department) _then;

/// Create a copy of Department
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,}) {
  return _then(_Department(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as RecordSyncStatus,
  ));
}


}

/// @nodoc
mixin _$DepartmentDraft {

 String get name; ConfigurationStatus get status;
/// Create a copy of DepartmentDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DepartmentDraftCopyWith<DepartmentDraft> get copyWith => _$DepartmentDraftCopyWithImpl<DepartmentDraft>(this as DepartmentDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DepartmentDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,name,status);

@override
String toString() {
  return 'DepartmentDraft(name: $name, status: $status)';
}


}

/// @nodoc
abstract mixin class $DepartmentDraftCopyWith<$Res>  {
  factory $DepartmentDraftCopyWith(DepartmentDraft value, $Res Function(DepartmentDraft) _then) = _$DepartmentDraftCopyWithImpl;
@useResult
$Res call({
 String name, ConfigurationStatus status
});




}
/// @nodoc
class _$DepartmentDraftCopyWithImpl<$Res>
    implements $DepartmentDraftCopyWith<$Res> {
  _$DepartmentDraftCopyWithImpl(this._self, this._then);

  final DepartmentDraft _self;
  final $Res Function(DepartmentDraft) _then;

/// Create a copy of DepartmentDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? status = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [DepartmentDraft].
extension DepartmentDraftPatterns on DepartmentDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DepartmentDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DepartmentDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DepartmentDraft value)  $default,){
final _that = this;
switch (_that) {
case _DepartmentDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DepartmentDraft value)?  $default,){
final _that = this;
switch (_that) {
case _DepartmentDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  ConfigurationStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DepartmentDraft() when $default != null:
return $default(_that.name,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  ConfigurationStatus status)  $default,) {final _that = this;
switch (_that) {
case _DepartmentDraft():
return $default(_that.name,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  ConfigurationStatus status)?  $default,) {final _that = this;
switch (_that) {
case _DepartmentDraft() when $default != null:
return $default(_that.name,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _DepartmentDraft extends DepartmentDraft {
  const _DepartmentDraft({this.name = '', this.status = ConfigurationStatus.active}): super._();
  

@override@JsonKey() final  String name;
@override@JsonKey() final  ConfigurationStatus status;

/// Create a copy of DepartmentDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DepartmentDraftCopyWith<_DepartmentDraft> get copyWith => __$DepartmentDraftCopyWithImpl<_DepartmentDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DepartmentDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,name,status);

@override
String toString() {
  return 'DepartmentDraft(name: $name, status: $status)';
}


}

/// @nodoc
abstract mixin class _$DepartmentDraftCopyWith<$Res> implements $DepartmentDraftCopyWith<$Res> {
  factory _$DepartmentDraftCopyWith(_DepartmentDraft value, $Res Function(_DepartmentDraft) _then) = __$DepartmentDraftCopyWithImpl;
@override @useResult
$Res call({
 String name, ConfigurationStatus status
});




}
/// @nodoc
class __$DepartmentDraftCopyWithImpl<$Res>
    implements _$DepartmentDraftCopyWith<$Res> {
  __$DepartmentDraftCopyWithImpl(this._self, this._then);

  final _DepartmentDraft _self;
  final $Res Function(_DepartmentDraft) _then;

/// Create a copy of DepartmentDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? status = null,}) {
  return _then(_DepartmentDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,
  ));
}


}

// dart format on
