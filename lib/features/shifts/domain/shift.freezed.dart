// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shift.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Shift {

 String get id; String get companyId; String get name; String? get code; LocalTime get startTime; LocalTime get endTime; Set<WorkingDay> get workingDays; int get gracePeriodMinutes; ShiftBreakMode get breakMode; int? get defaultBreakMinutes; int? get minimumWorkMinutes; ConfigurationStatus get status; DateTime get createdAt; DateTime get updatedAt; RecordSyncStatus get syncStatus;
/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShiftCopyWith<Shift> get copyWith => _$ShiftCopyWithImpl<Shift>(this as Shift, _$identity);

  /// Serializes this Shift to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Shift&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other.workingDays, workingDays)&&(identical(other.gracePeriodMinutes, gracePeriodMinutes) || other.gracePeriodMinutes == gracePeriodMinutes)&&(identical(other.breakMode, breakMode) || other.breakMode == breakMode)&&(identical(other.defaultBreakMinutes, defaultBreakMinutes) || other.defaultBreakMinutes == defaultBreakMinutes)&&(identical(other.minimumWorkMinutes, minimumWorkMinutes) || other.minimumWorkMinutes == minimumWorkMinutes)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,name,code,startTime,endTime,const DeepCollectionEquality().hash(workingDays),gracePeriodMinutes,breakMode,defaultBreakMinutes,minimumWorkMinutes,status,createdAt,updatedAt,syncStatus);

@override
String toString() {
  return 'Shift(id: $id, companyId: $companyId, name: $name, code: $code, startTime: $startTime, endTime: $endTime, workingDays: $workingDays, gracePeriodMinutes: $gracePeriodMinutes, breakMode: $breakMode, defaultBreakMinutes: $defaultBreakMinutes, minimumWorkMinutes: $minimumWorkMinutes, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $ShiftCopyWith<$Res>  {
  factory $ShiftCopyWith(Shift value, $Res Function(Shift) _then) = _$ShiftCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String name, String? code, LocalTime startTime, LocalTime endTime, Set<WorkingDay> workingDays, int gracePeriodMinutes, ShiftBreakMode breakMode, int? defaultBreakMinutes, int? minimumWorkMinutes, ConfigurationStatus status, DateTime createdAt, DateTime updatedAt, RecordSyncStatus syncStatus
});


$LocalTimeCopyWith<$Res> get startTime;$LocalTimeCopyWith<$Res> get endTime;

}
/// @nodoc
class _$ShiftCopyWithImpl<$Res>
    implements $ShiftCopyWith<$Res> {
  _$ShiftCopyWithImpl(this._self, this._then);

  final Shift _self;
  final $Res Function(Shift) _then;

/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? code = freezed,Object? startTime = null,Object? endTime = null,Object? workingDays = null,Object? gracePeriodMinutes = null,Object? breakMode = null,Object? defaultBreakMinutes = freezed,Object? minimumWorkMinutes = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as LocalTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as LocalTime,workingDays: null == workingDays ? _self.workingDays : workingDays // ignore: cast_nullable_to_non_nullable
as Set<WorkingDay>,gracePeriodMinutes: null == gracePeriodMinutes ? _self.gracePeriodMinutes : gracePeriodMinutes // ignore: cast_nullable_to_non_nullable
as int,breakMode: null == breakMode ? _self.breakMode : breakMode // ignore: cast_nullable_to_non_nullable
as ShiftBreakMode,defaultBreakMinutes: freezed == defaultBreakMinutes ? _self.defaultBreakMinutes : defaultBreakMinutes // ignore: cast_nullable_to_non_nullable
as int?,minimumWorkMinutes: freezed == minimumWorkMinutes ? _self.minimumWorkMinutes : minimumWorkMinutes // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as RecordSyncStatus,
  ));
}
/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalTimeCopyWith<$Res> get startTime {
  
  return $LocalTimeCopyWith<$Res>(_self.startTime, (value) {
    return _then(_self.copyWith(startTime: value));
  });
}/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalTimeCopyWith<$Res> get endTime {
  
  return $LocalTimeCopyWith<$Res>(_self.endTime, (value) {
    return _then(_self.copyWith(endTime: value));
  });
}
}


/// Adds pattern-matching-related methods to [Shift].
extension ShiftPatterns on Shift {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Shift value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Shift() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Shift value)  $default,){
final _that = this;
switch (_that) {
case _Shift():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Shift value)?  $default,){
final _that = this;
switch (_that) {
case _Shift() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  String? code,  LocalTime startTime,  LocalTime endTime,  Set<WorkingDay> workingDays,  int gracePeriodMinutes,  ShiftBreakMode breakMode,  int? defaultBreakMinutes,  int? minimumWorkMinutes,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Shift() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.code,_that.startTime,_that.endTime,_that.workingDays,_that.gracePeriodMinutes,_that.breakMode,_that.defaultBreakMinutes,_that.minimumWorkMinutes,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  String? code,  LocalTime startTime,  LocalTime endTime,  Set<WorkingDay> workingDays,  int gracePeriodMinutes,  ShiftBreakMode breakMode,  int? defaultBreakMinutes,  int? minimumWorkMinutes,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)  $default,) {final _that = this;
switch (_that) {
case _Shift():
return $default(_that.id,_that.companyId,_that.name,_that.code,_that.startTime,_that.endTime,_that.workingDays,_that.gracePeriodMinutes,_that.breakMode,_that.defaultBreakMinutes,_that.minimumWorkMinutes,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String name,  String? code,  LocalTime startTime,  LocalTime endTime,  Set<WorkingDay> workingDays,  int gracePeriodMinutes,  ShiftBreakMode breakMode,  int? defaultBreakMinutes,  int? minimumWorkMinutes,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _Shift() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.code,_that.startTime,_that.endTime,_that.workingDays,_that.gracePeriodMinutes,_that.breakMode,_that.defaultBreakMinutes,_that.minimumWorkMinutes,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Shift extends Shift {
  const _Shift({required this.id, required this.companyId, required this.name, this.code, required this.startTime, required this.endTime, required final  Set<WorkingDay> workingDays, this.gracePeriodMinutes = 0, this.breakMode = ShiftBreakMode.manualBreak, this.defaultBreakMinutes, this.minimumWorkMinutes, this.status = ConfigurationStatus.active, required this.createdAt, required this.updatedAt, this.syncStatus = RecordSyncStatus.pending}): _workingDays = workingDays,super._();
  factory _Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  String name;
@override final  String? code;
@override final  LocalTime startTime;
@override final  LocalTime endTime;
 final  Set<WorkingDay> _workingDays;
@override Set<WorkingDay> get workingDays {
  if (_workingDays is EqualUnmodifiableSetView) return _workingDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_workingDays);
}

@override@JsonKey() final  int gracePeriodMinutes;
@override@JsonKey() final  ShiftBreakMode breakMode;
@override final  int? defaultBreakMinutes;
@override final  int? minimumWorkMinutes;
@override@JsonKey() final  ConfigurationStatus status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  RecordSyncStatus syncStatus;

/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShiftCopyWith<_Shift> get copyWith => __$ShiftCopyWithImpl<_Shift>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShiftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Shift&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other._workingDays, _workingDays)&&(identical(other.gracePeriodMinutes, gracePeriodMinutes) || other.gracePeriodMinutes == gracePeriodMinutes)&&(identical(other.breakMode, breakMode) || other.breakMode == breakMode)&&(identical(other.defaultBreakMinutes, defaultBreakMinutes) || other.defaultBreakMinutes == defaultBreakMinutes)&&(identical(other.minimumWorkMinutes, minimumWorkMinutes) || other.minimumWorkMinutes == minimumWorkMinutes)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,name,code,startTime,endTime,const DeepCollectionEquality().hash(_workingDays),gracePeriodMinutes,breakMode,defaultBreakMinutes,minimumWorkMinutes,status,createdAt,updatedAt,syncStatus);

@override
String toString() {
  return 'Shift(id: $id, companyId: $companyId, name: $name, code: $code, startTime: $startTime, endTime: $endTime, workingDays: $workingDays, gracePeriodMinutes: $gracePeriodMinutes, breakMode: $breakMode, defaultBreakMinutes: $defaultBreakMinutes, minimumWorkMinutes: $minimumWorkMinutes, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$ShiftCopyWith<$Res> implements $ShiftCopyWith<$Res> {
  factory _$ShiftCopyWith(_Shift value, $Res Function(_Shift) _then) = __$ShiftCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String name, String? code, LocalTime startTime, LocalTime endTime, Set<WorkingDay> workingDays, int gracePeriodMinutes, ShiftBreakMode breakMode, int? defaultBreakMinutes, int? minimumWorkMinutes, ConfigurationStatus status, DateTime createdAt, DateTime updatedAt, RecordSyncStatus syncStatus
});


@override $LocalTimeCopyWith<$Res> get startTime;@override $LocalTimeCopyWith<$Res> get endTime;

}
/// @nodoc
class __$ShiftCopyWithImpl<$Res>
    implements _$ShiftCopyWith<$Res> {
  __$ShiftCopyWithImpl(this._self, this._then);

  final _Shift _self;
  final $Res Function(_Shift) _then;

/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? code = freezed,Object? startTime = null,Object? endTime = null,Object? workingDays = null,Object? gracePeriodMinutes = null,Object? breakMode = null,Object? defaultBreakMinutes = freezed,Object? minimumWorkMinutes = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,}) {
  return _then(_Shift(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as LocalTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as LocalTime,workingDays: null == workingDays ? _self._workingDays : workingDays // ignore: cast_nullable_to_non_nullable
as Set<WorkingDay>,gracePeriodMinutes: null == gracePeriodMinutes ? _self.gracePeriodMinutes : gracePeriodMinutes // ignore: cast_nullable_to_non_nullable
as int,breakMode: null == breakMode ? _self.breakMode : breakMode // ignore: cast_nullable_to_non_nullable
as ShiftBreakMode,defaultBreakMinutes: freezed == defaultBreakMinutes ? _self.defaultBreakMinutes : defaultBreakMinutes // ignore: cast_nullable_to_non_nullable
as int?,minimumWorkMinutes: freezed == minimumWorkMinutes ? _self.minimumWorkMinutes : minimumWorkMinutes // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as RecordSyncStatus,
  ));
}

/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalTimeCopyWith<$Res> get startTime {
  
  return $LocalTimeCopyWith<$Res>(_self.startTime, (value) {
    return _then(_self.copyWith(startTime: value));
  });
}/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalTimeCopyWith<$Res> get endTime {
  
  return $LocalTimeCopyWith<$Res>(_self.endTime, (value) {
    return _then(_self.copyWith(endTime: value));
  });
}
}

/// @nodoc
mixin _$ShiftDraft {

 String get name; String get code; LocalTime? get startTime; LocalTime? get endTime; Set<WorkingDay> get workingDays; int get gracePeriodMinutes; ShiftBreakMode get breakMode; int? get defaultBreakMinutes; int? get minimumWorkMinutes; ConfigurationStatus get status;
/// Create a copy of ShiftDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShiftDraftCopyWith<ShiftDraft> get copyWith => _$ShiftDraftCopyWithImpl<ShiftDraft>(this as ShiftDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShiftDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other.workingDays, workingDays)&&(identical(other.gracePeriodMinutes, gracePeriodMinutes) || other.gracePeriodMinutes == gracePeriodMinutes)&&(identical(other.breakMode, breakMode) || other.breakMode == breakMode)&&(identical(other.defaultBreakMinutes, defaultBreakMinutes) || other.defaultBreakMinutes == defaultBreakMinutes)&&(identical(other.minimumWorkMinutes, minimumWorkMinutes) || other.minimumWorkMinutes == minimumWorkMinutes)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,name,code,startTime,endTime,const DeepCollectionEquality().hash(workingDays),gracePeriodMinutes,breakMode,defaultBreakMinutes,minimumWorkMinutes,status);

@override
String toString() {
  return 'ShiftDraft(name: $name, code: $code, startTime: $startTime, endTime: $endTime, workingDays: $workingDays, gracePeriodMinutes: $gracePeriodMinutes, breakMode: $breakMode, defaultBreakMinutes: $defaultBreakMinutes, minimumWorkMinutes: $minimumWorkMinutes, status: $status)';
}


}

/// @nodoc
abstract mixin class $ShiftDraftCopyWith<$Res>  {
  factory $ShiftDraftCopyWith(ShiftDraft value, $Res Function(ShiftDraft) _then) = _$ShiftDraftCopyWithImpl;
@useResult
$Res call({
 String name, String code, LocalTime? startTime, LocalTime? endTime, Set<WorkingDay> workingDays, int gracePeriodMinutes, ShiftBreakMode breakMode, int? defaultBreakMinutes, int? minimumWorkMinutes, ConfigurationStatus status
});


$LocalTimeCopyWith<$Res>? get startTime;$LocalTimeCopyWith<$Res>? get endTime;

}
/// @nodoc
class _$ShiftDraftCopyWithImpl<$Res>
    implements $ShiftDraftCopyWith<$Res> {
  _$ShiftDraftCopyWithImpl(this._self, this._then);

  final ShiftDraft _self;
  final $Res Function(ShiftDraft) _then;

/// Create a copy of ShiftDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? code = null,Object? startTime = freezed,Object? endTime = freezed,Object? workingDays = null,Object? gracePeriodMinutes = null,Object? breakMode = null,Object? defaultBreakMinutes = freezed,Object? minimumWorkMinutes = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as LocalTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as LocalTime?,workingDays: null == workingDays ? _self.workingDays : workingDays // ignore: cast_nullable_to_non_nullable
as Set<WorkingDay>,gracePeriodMinutes: null == gracePeriodMinutes ? _self.gracePeriodMinutes : gracePeriodMinutes // ignore: cast_nullable_to_non_nullable
as int,breakMode: null == breakMode ? _self.breakMode : breakMode // ignore: cast_nullable_to_non_nullable
as ShiftBreakMode,defaultBreakMinutes: freezed == defaultBreakMinutes ? _self.defaultBreakMinutes : defaultBreakMinutes // ignore: cast_nullable_to_non_nullable
as int?,minimumWorkMinutes: freezed == minimumWorkMinutes ? _self.minimumWorkMinutes : minimumWorkMinutes // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,
  ));
}
/// Create a copy of ShiftDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalTimeCopyWith<$Res>? get startTime {
    if (_self.startTime == null) {
    return null;
  }

  return $LocalTimeCopyWith<$Res>(_self.startTime!, (value) {
    return _then(_self.copyWith(startTime: value));
  });
}/// Create a copy of ShiftDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalTimeCopyWith<$Res>? get endTime {
    if (_self.endTime == null) {
    return null;
  }

  return $LocalTimeCopyWith<$Res>(_self.endTime!, (value) {
    return _then(_self.copyWith(endTime: value));
  });
}
}


/// Adds pattern-matching-related methods to [ShiftDraft].
extension ShiftDraftPatterns on ShiftDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShiftDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShiftDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShiftDraft value)  $default,){
final _that = this;
switch (_that) {
case _ShiftDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShiftDraft value)?  $default,){
final _that = this;
switch (_that) {
case _ShiftDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String code,  LocalTime? startTime,  LocalTime? endTime,  Set<WorkingDay> workingDays,  int gracePeriodMinutes,  ShiftBreakMode breakMode,  int? defaultBreakMinutes,  int? minimumWorkMinutes,  ConfigurationStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShiftDraft() when $default != null:
return $default(_that.name,_that.code,_that.startTime,_that.endTime,_that.workingDays,_that.gracePeriodMinutes,_that.breakMode,_that.defaultBreakMinutes,_that.minimumWorkMinutes,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String code,  LocalTime? startTime,  LocalTime? endTime,  Set<WorkingDay> workingDays,  int gracePeriodMinutes,  ShiftBreakMode breakMode,  int? defaultBreakMinutes,  int? minimumWorkMinutes,  ConfigurationStatus status)  $default,) {final _that = this;
switch (_that) {
case _ShiftDraft():
return $default(_that.name,_that.code,_that.startTime,_that.endTime,_that.workingDays,_that.gracePeriodMinutes,_that.breakMode,_that.defaultBreakMinutes,_that.minimumWorkMinutes,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String code,  LocalTime? startTime,  LocalTime? endTime,  Set<WorkingDay> workingDays,  int gracePeriodMinutes,  ShiftBreakMode breakMode,  int? defaultBreakMinutes,  int? minimumWorkMinutes,  ConfigurationStatus status)?  $default,) {final _that = this;
switch (_that) {
case _ShiftDraft() when $default != null:
return $default(_that.name,_that.code,_that.startTime,_that.endTime,_that.workingDays,_that.gracePeriodMinutes,_that.breakMode,_that.defaultBreakMinutes,_that.minimumWorkMinutes,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _ShiftDraft extends ShiftDraft {
  const _ShiftDraft({this.name = '', this.code = '', this.startTime, this.endTime, final  Set<WorkingDay> workingDays = const <WorkingDay>{}, this.gracePeriodMinutes = 0, this.breakMode = ShiftBreakMode.manualBreak, this.defaultBreakMinutes, this.minimumWorkMinutes, this.status = ConfigurationStatus.active}): _workingDays = workingDays,super._();
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String code;
@override final  LocalTime? startTime;
@override final  LocalTime? endTime;
 final  Set<WorkingDay> _workingDays;
@override@JsonKey() Set<WorkingDay> get workingDays {
  if (_workingDays is EqualUnmodifiableSetView) return _workingDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_workingDays);
}

@override@JsonKey() final  int gracePeriodMinutes;
@override@JsonKey() final  ShiftBreakMode breakMode;
@override final  int? defaultBreakMinutes;
@override final  int? minimumWorkMinutes;
@override@JsonKey() final  ConfigurationStatus status;

/// Create a copy of ShiftDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShiftDraftCopyWith<_ShiftDraft> get copyWith => __$ShiftDraftCopyWithImpl<_ShiftDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShiftDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other._workingDays, _workingDays)&&(identical(other.gracePeriodMinutes, gracePeriodMinutes) || other.gracePeriodMinutes == gracePeriodMinutes)&&(identical(other.breakMode, breakMode) || other.breakMode == breakMode)&&(identical(other.defaultBreakMinutes, defaultBreakMinutes) || other.defaultBreakMinutes == defaultBreakMinutes)&&(identical(other.minimumWorkMinutes, minimumWorkMinutes) || other.minimumWorkMinutes == minimumWorkMinutes)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,name,code,startTime,endTime,const DeepCollectionEquality().hash(_workingDays),gracePeriodMinutes,breakMode,defaultBreakMinutes,minimumWorkMinutes,status);

@override
String toString() {
  return 'ShiftDraft(name: $name, code: $code, startTime: $startTime, endTime: $endTime, workingDays: $workingDays, gracePeriodMinutes: $gracePeriodMinutes, breakMode: $breakMode, defaultBreakMinutes: $defaultBreakMinutes, minimumWorkMinutes: $minimumWorkMinutes, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ShiftDraftCopyWith<$Res> implements $ShiftDraftCopyWith<$Res> {
  factory _$ShiftDraftCopyWith(_ShiftDraft value, $Res Function(_ShiftDraft) _then) = __$ShiftDraftCopyWithImpl;
@override @useResult
$Res call({
 String name, String code, LocalTime? startTime, LocalTime? endTime, Set<WorkingDay> workingDays, int gracePeriodMinutes, ShiftBreakMode breakMode, int? defaultBreakMinutes, int? minimumWorkMinutes, ConfigurationStatus status
});


@override $LocalTimeCopyWith<$Res>? get startTime;@override $LocalTimeCopyWith<$Res>? get endTime;

}
/// @nodoc
class __$ShiftDraftCopyWithImpl<$Res>
    implements _$ShiftDraftCopyWith<$Res> {
  __$ShiftDraftCopyWithImpl(this._self, this._then);

  final _ShiftDraft _self;
  final $Res Function(_ShiftDraft) _then;

/// Create a copy of ShiftDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? code = null,Object? startTime = freezed,Object? endTime = freezed,Object? workingDays = null,Object? gracePeriodMinutes = null,Object? breakMode = null,Object? defaultBreakMinutes = freezed,Object? minimumWorkMinutes = freezed,Object? status = null,}) {
  return _then(_ShiftDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as LocalTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as LocalTime?,workingDays: null == workingDays ? _self._workingDays : workingDays // ignore: cast_nullable_to_non_nullable
as Set<WorkingDay>,gracePeriodMinutes: null == gracePeriodMinutes ? _self.gracePeriodMinutes : gracePeriodMinutes // ignore: cast_nullable_to_non_nullable
as int,breakMode: null == breakMode ? _self.breakMode : breakMode // ignore: cast_nullable_to_non_nullable
as ShiftBreakMode,defaultBreakMinutes: freezed == defaultBreakMinutes ? _self.defaultBreakMinutes : defaultBreakMinutes // ignore: cast_nullable_to_non_nullable
as int?,minimumWorkMinutes: freezed == minimumWorkMinutes ? _self.minimumWorkMinutes : minimumWorkMinutes // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,
  ));
}

/// Create a copy of ShiftDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalTimeCopyWith<$Res>? get startTime {
    if (_self.startTime == null) {
    return null;
  }

  return $LocalTimeCopyWith<$Res>(_self.startTime!, (value) {
    return _then(_self.copyWith(startTime: value));
  });
}/// Create a copy of ShiftDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalTimeCopyWith<$Res>? get endTime {
    if (_self.endTime == null) {
    return null;
  }

  return $LocalTimeCopyWith<$Res>(_self.endTime!, (value) {
    return _then(_self.copyWith(endTime: value));
  });
}
}

// dart format on
