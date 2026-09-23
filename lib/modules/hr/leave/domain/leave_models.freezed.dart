// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leave_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeaveType {

 String get id; String get companyId; String get name; String get code; String get description; LeaveCompensationType get compensation; bool get requiresApproval; bool get allowsHalfDay; bool get requiresReason; bool get requiresAttachment; String get colorKey; ConfigurationStatus get status; DateTime get createdAt; DateTime get updatedAt; RecordSyncStatus get syncStatus;
/// Create a copy of LeaveType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaveTypeCopyWith<LeaveType> get copyWith => _$LeaveTypeCopyWithImpl<LeaveType>(this as LeaveType, _$identity);

  /// Serializes this LeaveType to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaveType&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&(identical(other.compensation, compensation) || other.compensation == compensation)&&(identical(other.requiresApproval, requiresApproval) || other.requiresApproval == requiresApproval)&&(identical(other.allowsHalfDay, allowsHalfDay) || other.allowsHalfDay == allowsHalfDay)&&(identical(other.requiresReason, requiresReason) || other.requiresReason == requiresReason)&&(identical(other.requiresAttachment, requiresAttachment) || other.requiresAttachment == requiresAttachment)&&(identical(other.colorKey, colorKey) || other.colorKey == colorKey)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,name,code,description,compensation,requiresApproval,allowsHalfDay,requiresReason,requiresAttachment,colorKey,status,createdAt,updatedAt,syncStatus);

@override
String toString() {
  return 'LeaveType(id: $id, companyId: $companyId, name: $name, code: $code, description: $description, compensation: $compensation, requiresApproval: $requiresApproval, allowsHalfDay: $allowsHalfDay, requiresReason: $requiresReason, requiresAttachment: $requiresAttachment, colorKey: $colorKey, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $LeaveTypeCopyWith<$Res>  {
  factory $LeaveTypeCopyWith(LeaveType value, $Res Function(LeaveType) _then) = _$LeaveTypeCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String name, String code, String description, LeaveCompensationType compensation, bool requiresApproval, bool allowsHalfDay, bool requiresReason, bool requiresAttachment, String colorKey, ConfigurationStatus status, DateTime createdAt, DateTime updatedAt, RecordSyncStatus syncStatus
});




}
/// @nodoc
class _$LeaveTypeCopyWithImpl<$Res>
    implements $LeaveTypeCopyWith<$Res> {
  _$LeaveTypeCopyWithImpl(this._self, this._then);

  final LeaveType _self;
  final $Res Function(LeaveType) _then;

/// Create a copy of LeaveType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? code = null,Object? description = null,Object? compensation = null,Object? requiresApproval = null,Object? allowsHalfDay = null,Object? requiresReason = null,Object? requiresAttachment = null,Object? colorKey = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,compensation: null == compensation ? _self.compensation : compensation // ignore: cast_nullable_to_non_nullable
as LeaveCompensationType,requiresApproval: null == requiresApproval ? _self.requiresApproval : requiresApproval // ignore: cast_nullable_to_non_nullable
as bool,allowsHalfDay: null == allowsHalfDay ? _self.allowsHalfDay : allowsHalfDay // ignore: cast_nullable_to_non_nullable
as bool,requiresReason: null == requiresReason ? _self.requiresReason : requiresReason // ignore: cast_nullable_to_non_nullable
as bool,requiresAttachment: null == requiresAttachment ? _self.requiresAttachment : requiresAttachment // ignore: cast_nullable_to_non_nullable
as bool,colorKey: null == colorKey ? _self.colorKey : colorKey // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as RecordSyncStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaveType].
extension LeaveTypePatterns on LeaveType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaveType value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaveType() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaveType value)  $default,){
final _that = this;
switch (_that) {
case _LeaveType():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaveType value)?  $default,){
final _that = this;
switch (_that) {
case _LeaveType() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  String code,  String description,  LeaveCompensationType compensation,  bool requiresApproval,  bool allowsHalfDay,  bool requiresReason,  bool requiresAttachment,  String colorKey,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaveType() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.code,_that.description,_that.compensation,_that.requiresApproval,_that.allowsHalfDay,_that.requiresReason,_that.requiresAttachment,_that.colorKey,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  String code,  String description,  LeaveCompensationType compensation,  bool requiresApproval,  bool allowsHalfDay,  bool requiresReason,  bool requiresAttachment,  String colorKey,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)  $default,) {final _that = this;
switch (_that) {
case _LeaveType():
return $default(_that.id,_that.companyId,_that.name,_that.code,_that.description,_that.compensation,_that.requiresApproval,_that.allowsHalfDay,_that.requiresReason,_that.requiresAttachment,_that.colorKey,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String name,  String code,  String description,  LeaveCompensationType compensation,  bool requiresApproval,  bool allowsHalfDay,  bool requiresReason,  bool requiresAttachment,  String colorKey,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _LeaveType() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.code,_that.description,_that.compensation,_that.requiresApproval,_that.allowsHalfDay,_that.requiresReason,_that.requiresAttachment,_that.colorKey,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaveType implements LeaveType {
  const _LeaveType({required this.id, required this.companyId, required this.name, required this.code, this.description = '', this.compensation = LeaveCompensationType.paid, this.requiresApproval = true, this.allowsHalfDay = true, this.requiresReason = true, this.requiresAttachment = false, this.colorKey = 'annual', this.status = ConfigurationStatus.active, required this.createdAt, required this.updatedAt, this.syncStatus = RecordSyncStatus.pending});
  factory _LeaveType.fromJson(Map<String, dynamic> json) => _$LeaveTypeFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  String name;
@override final  String code;
@override@JsonKey() final  String description;
@override@JsonKey() final  LeaveCompensationType compensation;
@override@JsonKey() final  bool requiresApproval;
@override@JsonKey() final  bool allowsHalfDay;
@override@JsonKey() final  bool requiresReason;
@override@JsonKey() final  bool requiresAttachment;
@override@JsonKey() final  String colorKey;
@override@JsonKey() final  ConfigurationStatus status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  RecordSyncStatus syncStatus;

/// Create a copy of LeaveType
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaveTypeCopyWith<_LeaveType> get copyWith => __$LeaveTypeCopyWithImpl<_LeaveType>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaveTypeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaveType&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&(identical(other.compensation, compensation) || other.compensation == compensation)&&(identical(other.requiresApproval, requiresApproval) || other.requiresApproval == requiresApproval)&&(identical(other.allowsHalfDay, allowsHalfDay) || other.allowsHalfDay == allowsHalfDay)&&(identical(other.requiresReason, requiresReason) || other.requiresReason == requiresReason)&&(identical(other.requiresAttachment, requiresAttachment) || other.requiresAttachment == requiresAttachment)&&(identical(other.colorKey, colorKey) || other.colorKey == colorKey)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,name,code,description,compensation,requiresApproval,allowsHalfDay,requiresReason,requiresAttachment,colorKey,status,createdAt,updatedAt,syncStatus);

@override
String toString() {
  return 'LeaveType(id: $id, companyId: $companyId, name: $name, code: $code, description: $description, compensation: $compensation, requiresApproval: $requiresApproval, allowsHalfDay: $allowsHalfDay, requiresReason: $requiresReason, requiresAttachment: $requiresAttachment, colorKey: $colorKey, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$LeaveTypeCopyWith<$Res> implements $LeaveTypeCopyWith<$Res> {
  factory _$LeaveTypeCopyWith(_LeaveType value, $Res Function(_LeaveType) _then) = __$LeaveTypeCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String name, String code, String description, LeaveCompensationType compensation, bool requiresApproval, bool allowsHalfDay, bool requiresReason, bool requiresAttachment, String colorKey, ConfigurationStatus status, DateTime createdAt, DateTime updatedAt, RecordSyncStatus syncStatus
});




}
/// @nodoc
class __$LeaveTypeCopyWithImpl<$Res>
    implements _$LeaveTypeCopyWith<$Res> {
  __$LeaveTypeCopyWithImpl(this._self, this._then);

  final _LeaveType _self;
  final $Res Function(_LeaveType) _then;

/// Create a copy of LeaveType
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? code = null,Object? description = null,Object? compensation = null,Object? requiresApproval = null,Object? allowsHalfDay = null,Object? requiresReason = null,Object? requiresAttachment = null,Object? colorKey = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,}) {
  return _then(_LeaveType(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,compensation: null == compensation ? _self.compensation : compensation // ignore: cast_nullable_to_non_nullable
as LeaveCompensationType,requiresApproval: null == requiresApproval ? _self.requiresApproval : requiresApproval // ignore: cast_nullable_to_non_nullable
as bool,allowsHalfDay: null == allowsHalfDay ? _self.allowsHalfDay : allowsHalfDay // ignore: cast_nullable_to_non_nullable
as bool,requiresReason: null == requiresReason ? _self.requiresReason : requiresReason // ignore: cast_nullable_to_non_nullable
as bool,requiresAttachment: null == requiresAttachment ? _self.requiresAttachment : requiresAttachment // ignore: cast_nullable_to_non_nullable
as bool,colorKey: null == colorKey ? _self.colorKey : colorKey // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as RecordSyncStatus,
  ));
}


}


/// @nodoc
mixin _$LeavePolicy {

 String get id; String get companyId; String get name; String get code; String get leaveTypeId; double get annualEntitlementDays; bool get allowHalfDay; double get minimumRequestDays; int? get maximumConsecutiveDays; int get advanceNoticeDays; bool get allowPastRequest; int get pastRequestWindowDays; int? get requiresAttachmentAfterDays; bool get allowNegativeBalance; bool get carryForwardEnabled; double? get carryForwardLimitDays; Set<EmploymentType> get applicableEmploymentTypes; ConfigurationStatus get status; DateTime get createdAt; DateTime get updatedAt; RecordSyncStatus get syncStatus;
/// Create a copy of LeavePolicy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeavePolicyCopyWith<LeavePolicy> get copyWith => _$LeavePolicyCopyWithImpl<LeavePolicy>(this as LeavePolicy, _$identity);

  /// Serializes this LeavePolicy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeavePolicy&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.leaveTypeId, leaveTypeId) || other.leaveTypeId == leaveTypeId)&&(identical(other.annualEntitlementDays, annualEntitlementDays) || other.annualEntitlementDays == annualEntitlementDays)&&(identical(other.allowHalfDay, allowHalfDay) || other.allowHalfDay == allowHalfDay)&&(identical(other.minimumRequestDays, minimumRequestDays) || other.minimumRequestDays == minimumRequestDays)&&(identical(other.maximumConsecutiveDays, maximumConsecutiveDays) || other.maximumConsecutiveDays == maximumConsecutiveDays)&&(identical(other.advanceNoticeDays, advanceNoticeDays) || other.advanceNoticeDays == advanceNoticeDays)&&(identical(other.allowPastRequest, allowPastRequest) || other.allowPastRequest == allowPastRequest)&&(identical(other.pastRequestWindowDays, pastRequestWindowDays) || other.pastRequestWindowDays == pastRequestWindowDays)&&(identical(other.requiresAttachmentAfterDays, requiresAttachmentAfterDays) || other.requiresAttachmentAfterDays == requiresAttachmentAfterDays)&&(identical(other.allowNegativeBalance, allowNegativeBalance) || other.allowNegativeBalance == allowNegativeBalance)&&(identical(other.carryForwardEnabled, carryForwardEnabled) || other.carryForwardEnabled == carryForwardEnabled)&&(identical(other.carryForwardLimitDays, carryForwardLimitDays) || other.carryForwardLimitDays == carryForwardLimitDays)&&const DeepCollectionEquality().equals(other.applicableEmploymentTypes, applicableEmploymentTypes)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,name,code,leaveTypeId,annualEntitlementDays,allowHalfDay,minimumRequestDays,maximumConsecutiveDays,advanceNoticeDays,allowPastRequest,pastRequestWindowDays,requiresAttachmentAfterDays,allowNegativeBalance,carryForwardEnabled,carryForwardLimitDays,const DeepCollectionEquality().hash(applicableEmploymentTypes),status,createdAt,updatedAt,syncStatus]);

@override
String toString() {
  return 'LeavePolicy(id: $id, companyId: $companyId, name: $name, code: $code, leaveTypeId: $leaveTypeId, annualEntitlementDays: $annualEntitlementDays, allowHalfDay: $allowHalfDay, minimumRequestDays: $minimumRequestDays, maximumConsecutiveDays: $maximumConsecutiveDays, advanceNoticeDays: $advanceNoticeDays, allowPastRequest: $allowPastRequest, pastRequestWindowDays: $pastRequestWindowDays, requiresAttachmentAfterDays: $requiresAttachmentAfterDays, allowNegativeBalance: $allowNegativeBalance, carryForwardEnabled: $carryForwardEnabled, carryForwardLimitDays: $carryForwardLimitDays, applicableEmploymentTypes: $applicableEmploymentTypes, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $LeavePolicyCopyWith<$Res>  {
  factory $LeavePolicyCopyWith(LeavePolicy value, $Res Function(LeavePolicy) _then) = _$LeavePolicyCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String name, String code, String leaveTypeId, double annualEntitlementDays, bool allowHalfDay, double minimumRequestDays, int? maximumConsecutiveDays, int advanceNoticeDays, bool allowPastRequest, int pastRequestWindowDays, int? requiresAttachmentAfterDays, bool allowNegativeBalance, bool carryForwardEnabled, double? carryForwardLimitDays, Set<EmploymentType> applicableEmploymentTypes, ConfigurationStatus status, DateTime createdAt, DateTime updatedAt, RecordSyncStatus syncStatus
});




}
/// @nodoc
class _$LeavePolicyCopyWithImpl<$Res>
    implements $LeavePolicyCopyWith<$Res> {
  _$LeavePolicyCopyWithImpl(this._self, this._then);

  final LeavePolicy _self;
  final $Res Function(LeavePolicy) _then;

/// Create a copy of LeavePolicy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? code = null,Object? leaveTypeId = null,Object? annualEntitlementDays = null,Object? allowHalfDay = null,Object? minimumRequestDays = null,Object? maximumConsecutiveDays = freezed,Object? advanceNoticeDays = null,Object? allowPastRequest = null,Object? pastRequestWindowDays = null,Object? requiresAttachmentAfterDays = freezed,Object? allowNegativeBalance = null,Object? carryForwardEnabled = null,Object? carryForwardLimitDays = freezed,Object? applicableEmploymentTypes = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,leaveTypeId: null == leaveTypeId ? _self.leaveTypeId : leaveTypeId // ignore: cast_nullable_to_non_nullable
as String,annualEntitlementDays: null == annualEntitlementDays ? _self.annualEntitlementDays : annualEntitlementDays // ignore: cast_nullable_to_non_nullable
as double,allowHalfDay: null == allowHalfDay ? _self.allowHalfDay : allowHalfDay // ignore: cast_nullable_to_non_nullable
as bool,minimumRequestDays: null == minimumRequestDays ? _self.minimumRequestDays : minimumRequestDays // ignore: cast_nullable_to_non_nullable
as double,maximumConsecutiveDays: freezed == maximumConsecutiveDays ? _self.maximumConsecutiveDays : maximumConsecutiveDays // ignore: cast_nullable_to_non_nullable
as int?,advanceNoticeDays: null == advanceNoticeDays ? _self.advanceNoticeDays : advanceNoticeDays // ignore: cast_nullable_to_non_nullable
as int,allowPastRequest: null == allowPastRequest ? _self.allowPastRequest : allowPastRequest // ignore: cast_nullable_to_non_nullable
as bool,pastRequestWindowDays: null == pastRequestWindowDays ? _self.pastRequestWindowDays : pastRequestWindowDays // ignore: cast_nullable_to_non_nullable
as int,requiresAttachmentAfterDays: freezed == requiresAttachmentAfterDays ? _self.requiresAttachmentAfterDays : requiresAttachmentAfterDays // ignore: cast_nullable_to_non_nullable
as int?,allowNegativeBalance: null == allowNegativeBalance ? _self.allowNegativeBalance : allowNegativeBalance // ignore: cast_nullable_to_non_nullable
as bool,carryForwardEnabled: null == carryForwardEnabled ? _self.carryForwardEnabled : carryForwardEnabled // ignore: cast_nullable_to_non_nullable
as bool,carryForwardLimitDays: freezed == carryForwardLimitDays ? _self.carryForwardLimitDays : carryForwardLimitDays // ignore: cast_nullable_to_non_nullable
as double?,applicableEmploymentTypes: null == applicableEmploymentTypes ? _self.applicableEmploymentTypes : applicableEmploymentTypes // ignore: cast_nullable_to_non_nullable
as Set<EmploymentType>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as RecordSyncStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [LeavePolicy].
extension LeavePolicyPatterns on LeavePolicy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeavePolicy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeavePolicy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeavePolicy value)  $default,){
final _that = this;
switch (_that) {
case _LeavePolicy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeavePolicy value)?  $default,){
final _that = this;
switch (_that) {
case _LeavePolicy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  String code,  String leaveTypeId,  double annualEntitlementDays,  bool allowHalfDay,  double minimumRequestDays,  int? maximumConsecutiveDays,  int advanceNoticeDays,  bool allowPastRequest,  int pastRequestWindowDays,  int? requiresAttachmentAfterDays,  bool allowNegativeBalance,  bool carryForwardEnabled,  double? carryForwardLimitDays,  Set<EmploymentType> applicableEmploymentTypes,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeavePolicy() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.code,_that.leaveTypeId,_that.annualEntitlementDays,_that.allowHalfDay,_that.minimumRequestDays,_that.maximumConsecutiveDays,_that.advanceNoticeDays,_that.allowPastRequest,_that.pastRequestWindowDays,_that.requiresAttachmentAfterDays,_that.allowNegativeBalance,_that.carryForwardEnabled,_that.carryForwardLimitDays,_that.applicableEmploymentTypes,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  String code,  String leaveTypeId,  double annualEntitlementDays,  bool allowHalfDay,  double minimumRequestDays,  int? maximumConsecutiveDays,  int advanceNoticeDays,  bool allowPastRequest,  int pastRequestWindowDays,  int? requiresAttachmentAfterDays,  bool allowNegativeBalance,  bool carryForwardEnabled,  double? carryForwardLimitDays,  Set<EmploymentType> applicableEmploymentTypes,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)  $default,) {final _that = this;
switch (_that) {
case _LeavePolicy():
return $default(_that.id,_that.companyId,_that.name,_that.code,_that.leaveTypeId,_that.annualEntitlementDays,_that.allowHalfDay,_that.minimumRequestDays,_that.maximumConsecutiveDays,_that.advanceNoticeDays,_that.allowPastRequest,_that.pastRequestWindowDays,_that.requiresAttachmentAfterDays,_that.allowNegativeBalance,_that.carryForwardEnabled,_that.carryForwardLimitDays,_that.applicableEmploymentTypes,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String name,  String code,  String leaveTypeId,  double annualEntitlementDays,  bool allowHalfDay,  double minimumRequestDays,  int? maximumConsecutiveDays,  int advanceNoticeDays,  bool allowPastRequest,  int pastRequestWindowDays,  int? requiresAttachmentAfterDays,  bool allowNegativeBalance,  bool carryForwardEnabled,  double? carryForwardLimitDays,  Set<EmploymentType> applicableEmploymentTypes,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _LeavePolicy() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.code,_that.leaveTypeId,_that.annualEntitlementDays,_that.allowHalfDay,_that.minimumRequestDays,_that.maximumConsecutiveDays,_that.advanceNoticeDays,_that.allowPastRequest,_that.pastRequestWindowDays,_that.requiresAttachmentAfterDays,_that.allowNegativeBalance,_that.carryForwardEnabled,_that.carryForwardLimitDays,_that.applicableEmploymentTypes,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeavePolicy implements LeavePolicy {
  const _LeavePolicy({required this.id, required this.companyId, required this.name, required this.code, required this.leaveTypeId, this.annualEntitlementDays = 0, this.allowHalfDay = true, this.minimumRequestDays = 0.5, this.maximumConsecutiveDays, this.advanceNoticeDays = 0, this.allowPastRequest = false, this.pastRequestWindowDays = 0, this.requiresAttachmentAfterDays, this.allowNegativeBalance = false, this.carryForwardEnabled = false, this.carryForwardLimitDays, final  Set<EmploymentType> applicableEmploymentTypes = const <EmploymentType>{}, this.status = ConfigurationStatus.active, required this.createdAt, required this.updatedAt, this.syncStatus = RecordSyncStatus.pending}): _applicableEmploymentTypes = applicableEmploymentTypes;
  factory _LeavePolicy.fromJson(Map<String, dynamic> json) => _$LeavePolicyFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  String name;
@override final  String code;
@override final  String leaveTypeId;
@override@JsonKey() final  double annualEntitlementDays;
@override@JsonKey() final  bool allowHalfDay;
@override@JsonKey() final  double minimumRequestDays;
@override final  int? maximumConsecutiveDays;
@override@JsonKey() final  int advanceNoticeDays;
@override@JsonKey() final  bool allowPastRequest;
@override@JsonKey() final  int pastRequestWindowDays;
@override final  int? requiresAttachmentAfterDays;
@override@JsonKey() final  bool allowNegativeBalance;
@override@JsonKey() final  bool carryForwardEnabled;
@override final  double? carryForwardLimitDays;
 final  Set<EmploymentType> _applicableEmploymentTypes;
@override@JsonKey() Set<EmploymentType> get applicableEmploymentTypes {
  if (_applicableEmploymentTypes is EqualUnmodifiableSetView) return _applicableEmploymentTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_applicableEmploymentTypes);
}

@override@JsonKey() final  ConfigurationStatus status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  RecordSyncStatus syncStatus;

/// Create a copy of LeavePolicy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeavePolicyCopyWith<_LeavePolicy> get copyWith => __$LeavePolicyCopyWithImpl<_LeavePolicy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeavePolicyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeavePolicy&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.leaveTypeId, leaveTypeId) || other.leaveTypeId == leaveTypeId)&&(identical(other.annualEntitlementDays, annualEntitlementDays) || other.annualEntitlementDays == annualEntitlementDays)&&(identical(other.allowHalfDay, allowHalfDay) || other.allowHalfDay == allowHalfDay)&&(identical(other.minimumRequestDays, minimumRequestDays) || other.minimumRequestDays == minimumRequestDays)&&(identical(other.maximumConsecutiveDays, maximumConsecutiveDays) || other.maximumConsecutiveDays == maximumConsecutiveDays)&&(identical(other.advanceNoticeDays, advanceNoticeDays) || other.advanceNoticeDays == advanceNoticeDays)&&(identical(other.allowPastRequest, allowPastRequest) || other.allowPastRequest == allowPastRequest)&&(identical(other.pastRequestWindowDays, pastRequestWindowDays) || other.pastRequestWindowDays == pastRequestWindowDays)&&(identical(other.requiresAttachmentAfterDays, requiresAttachmentAfterDays) || other.requiresAttachmentAfterDays == requiresAttachmentAfterDays)&&(identical(other.allowNegativeBalance, allowNegativeBalance) || other.allowNegativeBalance == allowNegativeBalance)&&(identical(other.carryForwardEnabled, carryForwardEnabled) || other.carryForwardEnabled == carryForwardEnabled)&&(identical(other.carryForwardLimitDays, carryForwardLimitDays) || other.carryForwardLimitDays == carryForwardLimitDays)&&const DeepCollectionEquality().equals(other._applicableEmploymentTypes, _applicableEmploymentTypes)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,name,code,leaveTypeId,annualEntitlementDays,allowHalfDay,minimumRequestDays,maximumConsecutiveDays,advanceNoticeDays,allowPastRequest,pastRequestWindowDays,requiresAttachmentAfterDays,allowNegativeBalance,carryForwardEnabled,carryForwardLimitDays,const DeepCollectionEquality().hash(_applicableEmploymentTypes),status,createdAt,updatedAt,syncStatus]);

@override
String toString() {
  return 'LeavePolicy(id: $id, companyId: $companyId, name: $name, code: $code, leaveTypeId: $leaveTypeId, annualEntitlementDays: $annualEntitlementDays, allowHalfDay: $allowHalfDay, minimumRequestDays: $minimumRequestDays, maximumConsecutiveDays: $maximumConsecutiveDays, advanceNoticeDays: $advanceNoticeDays, allowPastRequest: $allowPastRequest, pastRequestWindowDays: $pastRequestWindowDays, requiresAttachmentAfterDays: $requiresAttachmentAfterDays, allowNegativeBalance: $allowNegativeBalance, carryForwardEnabled: $carryForwardEnabled, carryForwardLimitDays: $carryForwardLimitDays, applicableEmploymentTypes: $applicableEmploymentTypes, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$LeavePolicyCopyWith<$Res> implements $LeavePolicyCopyWith<$Res> {
  factory _$LeavePolicyCopyWith(_LeavePolicy value, $Res Function(_LeavePolicy) _then) = __$LeavePolicyCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String name, String code, String leaveTypeId, double annualEntitlementDays, bool allowHalfDay, double minimumRequestDays, int? maximumConsecutiveDays, int advanceNoticeDays, bool allowPastRequest, int pastRequestWindowDays, int? requiresAttachmentAfterDays, bool allowNegativeBalance, bool carryForwardEnabled, double? carryForwardLimitDays, Set<EmploymentType> applicableEmploymentTypes, ConfigurationStatus status, DateTime createdAt, DateTime updatedAt, RecordSyncStatus syncStatus
});




}
/// @nodoc
class __$LeavePolicyCopyWithImpl<$Res>
    implements _$LeavePolicyCopyWith<$Res> {
  __$LeavePolicyCopyWithImpl(this._self, this._then);

  final _LeavePolicy _self;
  final $Res Function(_LeavePolicy) _then;

/// Create a copy of LeavePolicy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? code = null,Object? leaveTypeId = null,Object? annualEntitlementDays = null,Object? allowHalfDay = null,Object? minimumRequestDays = null,Object? maximumConsecutiveDays = freezed,Object? advanceNoticeDays = null,Object? allowPastRequest = null,Object? pastRequestWindowDays = null,Object? requiresAttachmentAfterDays = freezed,Object? allowNegativeBalance = null,Object? carryForwardEnabled = null,Object? carryForwardLimitDays = freezed,Object? applicableEmploymentTypes = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,}) {
  return _then(_LeavePolicy(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,leaveTypeId: null == leaveTypeId ? _self.leaveTypeId : leaveTypeId // ignore: cast_nullable_to_non_nullable
as String,annualEntitlementDays: null == annualEntitlementDays ? _self.annualEntitlementDays : annualEntitlementDays // ignore: cast_nullable_to_non_nullable
as double,allowHalfDay: null == allowHalfDay ? _self.allowHalfDay : allowHalfDay // ignore: cast_nullable_to_non_nullable
as bool,minimumRequestDays: null == minimumRequestDays ? _self.minimumRequestDays : minimumRequestDays // ignore: cast_nullable_to_non_nullable
as double,maximumConsecutiveDays: freezed == maximumConsecutiveDays ? _self.maximumConsecutiveDays : maximumConsecutiveDays // ignore: cast_nullable_to_non_nullable
as int?,advanceNoticeDays: null == advanceNoticeDays ? _self.advanceNoticeDays : advanceNoticeDays // ignore: cast_nullable_to_non_nullable
as int,allowPastRequest: null == allowPastRequest ? _self.allowPastRequest : allowPastRequest // ignore: cast_nullable_to_non_nullable
as bool,pastRequestWindowDays: null == pastRequestWindowDays ? _self.pastRequestWindowDays : pastRequestWindowDays // ignore: cast_nullable_to_non_nullable
as int,requiresAttachmentAfterDays: freezed == requiresAttachmentAfterDays ? _self.requiresAttachmentAfterDays : requiresAttachmentAfterDays // ignore: cast_nullable_to_non_nullable
as int?,allowNegativeBalance: null == allowNegativeBalance ? _self.allowNegativeBalance : allowNegativeBalance // ignore: cast_nullable_to_non_nullable
as bool,carryForwardEnabled: null == carryForwardEnabled ? _self.carryForwardEnabled : carryForwardEnabled // ignore: cast_nullable_to_non_nullable
as bool,carryForwardLimitDays: freezed == carryForwardLimitDays ? _self.carryForwardLimitDays : carryForwardLimitDays // ignore: cast_nullable_to_non_nullable
as double?,applicableEmploymentTypes: null == applicableEmploymentTypes ? _self._applicableEmploymentTypes : applicableEmploymentTypes // ignore: cast_nullable_to_non_nullable
as Set<EmploymentType>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as RecordSyncStatus,
  ));
}


}


/// @nodoc
mixin _$Holiday {

 String get id; String get companyId; String get name; DateTime get date; DateTime? get endDate; HolidayType get type; HolidayScope get scope; Set<String> get workLocationIds; String get description; bool get isOptional; HolidaySource get source; String? get calendarId; String? get countryCode; String? get regionCode; ConfigurationStatus get status; DateTime get createdAt; DateTime get updatedAt; RecordSyncStatus get syncStatus;
/// Create a copy of Holiday
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HolidayCopyWith<Holiday> get copyWith => _$HolidayCopyWithImpl<Holiday>(this as Holiday, _$identity);

  /// Serializes this Holiday to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Holiday&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.date, date) || other.date == date)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.type, type) || other.type == type)&&(identical(other.scope, scope) || other.scope == scope)&&const DeepCollectionEquality().equals(other.workLocationIds, workLocationIds)&&(identical(other.description, description) || other.description == description)&&(identical(other.isOptional, isOptional) || other.isOptional == isOptional)&&(identical(other.source, source) || other.source == source)&&(identical(other.calendarId, calendarId) || other.calendarId == calendarId)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.regionCode, regionCode) || other.regionCode == regionCode)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,name,date,endDate,type,scope,const DeepCollectionEquality().hash(workLocationIds),description,isOptional,source,calendarId,countryCode,regionCode,status,createdAt,updatedAt,syncStatus);

@override
String toString() {
  return 'Holiday(id: $id, companyId: $companyId, name: $name, date: $date, endDate: $endDate, type: $type, scope: $scope, workLocationIds: $workLocationIds, description: $description, isOptional: $isOptional, source: $source, calendarId: $calendarId, countryCode: $countryCode, regionCode: $regionCode, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $HolidayCopyWith<$Res>  {
  factory $HolidayCopyWith(Holiday value, $Res Function(Holiday) _then) = _$HolidayCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String name, DateTime date, DateTime? endDate, HolidayType type, HolidayScope scope, Set<String> workLocationIds, String description, bool isOptional, HolidaySource source, String? calendarId, String? countryCode, String? regionCode, ConfigurationStatus status, DateTime createdAt, DateTime updatedAt, RecordSyncStatus syncStatus
});




}
/// @nodoc
class _$HolidayCopyWithImpl<$Res>
    implements $HolidayCopyWith<$Res> {
  _$HolidayCopyWithImpl(this._self, this._then);

  final Holiday _self;
  final $Res Function(Holiday) _then;

/// Create a copy of Holiday
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? date = null,Object? endDate = freezed,Object? type = null,Object? scope = null,Object? workLocationIds = null,Object? description = null,Object? isOptional = null,Object? source = null,Object? calendarId = freezed,Object? countryCode = freezed,Object? regionCode = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as HolidayType,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as HolidayScope,workLocationIds: null == workLocationIds ? _self.workLocationIds : workLocationIds // ignore: cast_nullable_to_non_nullable
as Set<String>,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isOptional: null == isOptional ? _self.isOptional : isOptional // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as HolidaySource,calendarId: freezed == calendarId ? _self.calendarId : calendarId // ignore: cast_nullable_to_non_nullable
as String?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,regionCode: freezed == regionCode ? _self.regionCode : regionCode // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as RecordSyncStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Holiday].
extension HolidayPatterns on Holiday {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Holiday value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Holiday() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Holiday value)  $default,){
final _that = this;
switch (_that) {
case _Holiday():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Holiday value)?  $default,){
final _that = this;
switch (_that) {
case _Holiday() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  DateTime date,  DateTime? endDate,  HolidayType type,  HolidayScope scope,  Set<String> workLocationIds,  String description,  bool isOptional,  HolidaySource source,  String? calendarId,  String? countryCode,  String? regionCode,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Holiday() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.date,_that.endDate,_that.type,_that.scope,_that.workLocationIds,_that.description,_that.isOptional,_that.source,_that.calendarId,_that.countryCode,_that.regionCode,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  DateTime date,  DateTime? endDate,  HolidayType type,  HolidayScope scope,  Set<String> workLocationIds,  String description,  bool isOptional,  HolidaySource source,  String? calendarId,  String? countryCode,  String? regionCode,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)  $default,) {final _that = this;
switch (_that) {
case _Holiday():
return $default(_that.id,_that.companyId,_that.name,_that.date,_that.endDate,_that.type,_that.scope,_that.workLocationIds,_that.description,_that.isOptional,_that.source,_that.calendarId,_that.countryCode,_that.regionCode,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String name,  DateTime date,  DateTime? endDate,  HolidayType type,  HolidayScope scope,  Set<String> workLocationIds,  String description,  bool isOptional,  HolidaySource source,  String? calendarId,  String? countryCode,  String? regionCode,  ConfigurationStatus status,  DateTime createdAt,  DateTime updatedAt,  RecordSyncStatus syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _Holiday() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.date,_that.endDate,_that.type,_that.scope,_that.workLocationIds,_that.description,_that.isOptional,_that.source,_that.calendarId,_that.countryCode,_that.regionCode,_that.status,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Holiday implements Holiday {
  const _Holiday({required this.id, required this.companyId, required this.name, required this.date, this.endDate, this.type = HolidayType.companyHoliday, this.scope = HolidayScope.companyWide, final  Set<String> workLocationIds = const <String>{}, this.description = '', this.isOptional = false, this.source = HolidaySource.manual, this.calendarId, this.countryCode, this.regionCode, this.status = ConfigurationStatus.active, required this.createdAt, required this.updatedAt, this.syncStatus = RecordSyncStatus.pending}): _workLocationIds = workLocationIds;
  factory _Holiday.fromJson(Map<String, dynamic> json) => _$HolidayFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  String name;
@override final  DateTime date;
@override final  DateTime? endDate;
@override@JsonKey() final  HolidayType type;
@override@JsonKey() final  HolidayScope scope;
 final  Set<String> _workLocationIds;
@override@JsonKey() Set<String> get workLocationIds {
  if (_workLocationIds is EqualUnmodifiableSetView) return _workLocationIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_workLocationIds);
}

@override@JsonKey() final  String description;
@override@JsonKey() final  bool isOptional;
@override@JsonKey() final  HolidaySource source;
@override final  String? calendarId;
@override final  String? countryCode;
@override final  String? regionCode;
@override@JsonKey() final  ConfigurationStatus status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  RecordSyncStatus syncStatus;

/// Create a copy of Holiday
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HolidayCopyWith<_Holiday> get copyWith => __$HolidayCopyWithImpl<_Holiday>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HolidayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Holiday&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.date, date) || other.date == date)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.type, type) || other.type == type)&&(identical(other.scope, scope) || other.scope == scope)&&const DeepCollectionEquality().equals(other._workLocationIds, _workLocationIds)&&(identical(other.description, description) || other.description == description)&&(identical(other.isOptional, isOptional) || other.isOptional == isOptional)&&(identical(other.source, source) || other.source == source)&&(identical(other.calendarId, calendarId) || other.calendarId == calendarId)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.regionCode, regionCode) || other.regionCode == regionCode)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,name,date,endDate,type,scope,const DeepCollectionEquality().hash(_workLocationIds),description,isOptional,source,calendarId,countryCode,regionCode,status,createdAt,updatedAt,syncStatus);

@override
String toString() {
  return 'Holiday(id: $id, companyId: $companyId, name: $name, date: $date, endDate: $endDate, type: $type, scope: $scope, workLocationIds: $workLocationIds, description: $description, isOptional: $isOptional, source: $source, calendarId: $calendarId, countryCode: $countryCode, regionCode: $regionCode, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$HolidayCopyWith<$Res> implements $HolidayCopyWith<$Res> {
  factory _$HolidayCopyWith(_Holiday value, $Res Function(_Holiday) _then) = __$HolidayCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String name, DateTime date, DateTime? endDate, HolidayType type, HolidayScope scope, Set<String> workLocationIds, String description, bool isOptional, HolidaySource source, String? calendarId, String? countryCode, String? regionCode, ConfigurationStatus status, DateTime createdAt, DateTime updatedAt, RecordSyncStatus syncStatus
});




}
/// @nodoc
class __$HolidayCopyWithImpl<$Res>
    implements _$HolidayCopyWith<$Res> {
  __$HolidayCopyWithImpl(this._self, this._then);

  final _Holiday _self;
  final $Res Function(_Holiday) _then;

/// Create a copy of Holiday
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? date = null,Object? endDate = freezed,Object? type = null,Object? scope = null,Object? workLocationIds = null,Object? description = null,Object? isOptional = null,Object? source = null,Object? calendarId = freezed,Object? countryCode = freezed,Object? regionCode = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,}) {
  return _then(_Holiday(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as HolidayType,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as HolidayScope,workLocationIds: null == workLocationIds ? _self._workLocationIds : workLocationIds // ignore: cast_nullable_to_non_nullable
as Set<String>,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isOptional: null == isOptional ? _self.isOptional : isOptional // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as HolidaySource,calendarId: freezed == calendarId ? _self.calendarId : calendarId // ignore: cast_nullable_to_non_nullable
as String?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,regionCode: freezed == regionCode ? _self.regionCode : regionCode // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as RecordSyncStatus,
  ));
}


}


/// @nodoc
mixin _$LeaveTypeSnapshot {

 String get typeId; String get name; String get code; LeaveCompensationType get compensation; bool get requiresReason; bool get requiresAttachment; bool get allowsHalfDay;
/// Create a copy of LeaveTypeSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaveTypeSnapshotCopyWith<LeaveTypeSnapshot> get copyWith => _$LeaveTypeSnapshotCopyWithImpl<LeaveTypeSnapshot>(this as LeaveTypeSnapshot, _$identity);

  /// Serializes this LeaveTypeSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaveTypeSnapshot&&(identical(other.typeId, typeId) || other.typeId == typeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.compensation, compensation) || other.compensation == compensation)&&(identical(other.requiresReason, requiresReason) || other.requiresReason == requiresReason)&&(identical(other.requiresAttachment, requiresAttachment) || other.requiresAttachment == requiresAttachment)&&(identical(other.allowsHalfDay, allowsHalfDay) || other.allowsHalfDay == allowsHalfDay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,typeId,name,code,compensation,requiresReason,requiresAttachment,allowsHalfDay);

@override
String toString() {
  return 'LeaveTypeSnapshot(typeId: $typeId, name: $name, code: $code, compensation: $compensation, requiresReason: $requiresReason, requiresAttachment: $requiresAttachment, allowsHalfDay: $allowsHalfDay)';
}


}

/// @nodoc
abstract mixin class $LeaveTypeSnapshotCopyWith<$Res>  {
  factory $LeaveTypeSnapshotCopyWith(LeaveTypeSnapshot value, $Res Function(LeaveTypeSnapshot) _then) = _$LeaveTypeSnapshotCopyWithImpl;
@useResult
$Res call({
 String typeId, String name, String code, LeaveCompensationType compensation, bool requiresReason, bool requiresAttachment, bool allowsHalfDay
});




}
/// @nodoc
class _$LeaveTypeSnapshotCopyWithImpl<$Res>
    implements $LeaveTypeSnapshotCopyWith<$Res> {
  _$LeaveTypeSnapshotCopyWithImpl(this._self, this._then);

  final LeaveTypeSnapshot _self;
  final $Res Function(LeaveTypeSnapshot) _then;

/// Create a copy of LeaveTypeSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? typeId = null,Object? name = null,Object? code = null,Object? compensation = null,Object? requiresReason = null,Object? requiresAttachment = null,Object? allowsHalfDay = null,}) {
  return _then(_self.copyWith(
typeId: null == typeId ? _self.typeId : typeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,compensation: null == compensation ? _self.compensation : compensation // ignore: cast_nullable_to_non_nullable
as LeaveCompensationType,requiresReason: null == requiresReason ? _self.requiresReason : requiresReason // ignore: cast_nullable_to_non_nullable
as bool,requiresAttachment: null == requiresAttachment ? _self.requiresAttachment : requiresAttachment // ignore: cast_nullable_to_non_nullable
as bool,allowsHalfDay: null == allowsHalfDay ? _self.allowsHalfDay : allowsHalfDay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaveTypeSnapshot].
extension LeaveTypeSnapshotPatterns on LeaveTypeSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaveTypeSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaveTypeSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaveTypeSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _LeaveTypeSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaveTypeSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _LeaveTypeSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String typeId,  String name,  String code,  LeaveCompensationType compensation,  bool requiresReason,  bool requiresAttachment,  bool allowsHalfDay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaveTypeSnapshot() when $default != null:
return $default(_that.typeId,_that.name,_that.code,_that.compensation,_that.requiresReason,_that.requiresAttachment,_that.allowsHalfDay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String typeId,  String name,  String code,  LeaveCompensationType compensation,  bool requiresReason,  bool requiresAttachment,  bool allowsHalfDay)  $default,) {final _that = this;
switch (_that) {
case _LeaveTypeSnapshot():
return $default(_that.typeId,_that.name,_that.code,_that.compensation,_that.requiresReason,_that.requiresAttachment,_that.allowsHalfDay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String typeId,  String name,  String code,  LeaveCompensationType compensation,  bool requiresReason,  bool requiresAttachment,  bool allowsHalfDay)?  $default,) {final _that = this;
switch (_that) {
case _LeaveTypeSnapshot() when $default != null:
return $default(_that.typeId,_that.name,_that.code,_that.compensation,_that.requiresReason,_that.requiresAttachment,_that.allowsHalfDay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaveTypeSnapshot implements LeaveTypeSnapshot {
  const _LeaveTypeSnapshot({required this.typeId, required this.name, required this.code, this.compensation = LeaveCompensationType.paid, this.requiresReason = true, this.requiresAttachment = false, this.allowsHalfDay = true});
  factory _LeaveTypeSnapshot.fromJson(Map<String, dynamic> json) => _$LeaveTypeSnapshotFromJson(json);

@override final  String typeId;
@override final  String name;
@override final  String code;
@override@JsonKey() final  LeaveCompensationType compensation;
@override@JsonKey() final  bool requiresReason;
@override@JsonKey() final  bool requiresAttachment;
@override@JsonKey() final  bool allowsHalfDay;

/// Create a copy of LeaveTypeSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaveTypeSnapshotCopyWith<_LeaveTypeSnapshot> get copyWith => __$LeaveTypeSnapshotCopyWithImpl<_LeaveTypeSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaveTypeSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaveTypeSnapshot&&(identical(other.typeId, typeId) || other.typeId == typeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.compensation, compensation) || other.compensation == compensation)&&(identical(other.requiresReason, requiresReason) || other.requiresReason == requiresReason)&&(identical(other.requiresAttachment, requiresAttachment) || other.requiresAttachment == requiresAttachment)&&(identical(other.allowsHalfDay, allowsHalfDay) || other.allowsHalfDay == allowsHalfDay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,typeId,name,code,compensation,requiresReason,requiresAttachment,allowsHalfDay);

@override
String toString() {
  return 'LeaveTypeSnapshot(typeId: $typeId, name: $name, code: $code, compensation: $compensation, requiresReason: $requiresReason, requiresAttachment: $requiresAttachment, allowsHalfDay: $allowsHalfDay)';
}


}

/// @nodoc
abstract mixin class _$LeaveTypeSnapshotCopyWith<$Res> implements $LeaveTypeSnapshotCopyWith<$Res> {
  factory _$LeaveTypeSnapshotCopyWith(_LeaveTypeSnapshot value, $Res Function(_LeaveTypeSnapshot) _then) = __$LeaveTypeSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String typeId, String name, String code, LeaveCompensationType compensation, bool requiresReason, bool requiresAttachment, bool allowsHalfDay
});




}
/// @nodoc
class __$LeaveTypeSnapshotCopyWithImpl<$Res>
    implements _$LeaveTypeSnapshotCopyWith<$Res> {
  __$LeaveTypeSnapshotCopyWithImpl(this._self, this._then);

  final _LeaveTypeSnapshot _self;
  final $Res Function(_LeaveTypeSnapshot) _then;

/// Create a copy of LeaveTypeSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? typeId = null,Object? name = null,Object? code = null,Object? compensation = null,Object? requiresReason = null,Object? requiresAttachment = null,Object? allowsHalfDay = null,}) {
  return _then(_LeaveTypeSnapshot(
typeId: null == typeId ? _self.typeId : typeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,compensation: null == compensation ? _self.compensation : compensation // ignore: cast_nullable_to_non_nullable
as LeaveCompensationType,requiresReason: null == requiresReason ? _self.requiresReason : requiresReason // ignore: cast_nullable_to_non_nullable
as bool,requiresAttachment: null == requiresAttachment ? _self.requiresAttachment : requiresAttachment // ignore: cast_nullable_to_non_nullable
as bool,allowsHalfDay: null == allowsHalfDay ? _self.allowsHalfDay : allowsHalfDay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$LeavePolicySnapshot {

 String get policyId; String get name; String get code; double get annualEntitlementDays; bool get allowHalfDay; bool get allowNegativeBalance;
/// Create a copy of LeavePolicySnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeavePolicySnapshotCopyWith<LeavePolicySnapshot> get copyWith => _$LeavePolicySnapshotCopyWithImpl<LeavePolicySnapshot>(this as LeavePolicySnapshot, _$identity);

  /// Serializes this LeavePolicySnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeavePolicySnapshot&&(identical(other.policyId, policyId) || other.policyId == policyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.annualEntitlementDays, annualEntitlementDays) || other.annualEntitlementDays == annualEntitlementDays)&&(identical(other.allowHalfDay, allowHalfDay) || other.allowHalfDay == allowHalfDay)&&(identical(other.allowNegativeBalance, allowNegativeBalance) || other.allowNegativeBalance == allowNegativeBalance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,policyId,name,code,annualEntitlementDays,allowHalfDay,allowNegativeBalance);

@override
String toString() {
  return 'LeavePolicySnapshot(policyId: $policyId, name: $name, code: $code, annualEntitlementDays: $annualEntitlementDays, allowHalfDay: $allowHalfDay, allowNegativeBalance: $allowNegativeBalance)';
}


}

/// @nodoc
abstract mixin class $LeavePolicySnapshotCopyWith<$Res>  {
  factory $LeavePolicySnapshotCopyWith(LeavePolicySnapshot value, $Res Function(LeavePolicySnapshot) _then) = _$LeavePolicySnapshotCopyWithImpl;
@useResult
$Res call({
 String policyId, String name, String code, double annualEntitlementDays, bool allowHalfDay, bool allowNegativeBalance
});




}
/// @nodoc
class _$LeavePolicySnapshotCopyWithImpl<$Res>
    implements $LeavePolicySnapshotCopyWith<$Res> {
  _$LeavePolicySnapshotCopyWithImpl(this._self, this._then);

  final LeavePolicySnapshot _self;
  final $Res Function(LeavePolicySnapshot) _then;

/// Create a copy of LeavePolicySnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? policyId = null,Object? name = null,Object? code = null,Object? annualEntitlementDays = null,Object? allowHalfDay = null,Object? allowNegativeBalance = null,}) {
  return _then(_self.copyWith(
policyId: null == policyId ? _self.policyId : policyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,annualEntitlementDays: null == annualEntitlementDays ? _self.annualEntitlementDays : annualEntitlementDays // ignore: cast_nullable_to_non_nullable
as double,allowHalfDay: null == allowHalfDay ? _self.allowHalfDay : allowHalfDay // ignore: cast_nullable_to_non_nullable
as bool,allowNegativeBalance: null == allowNegativeBalance ? _self.allowNegativeBalance : allowNegativeBalance // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LeavePolicySnapshot].
extension LeavePolicySnapshotPatterns on LeavePolicySnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeavePolicySnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeavePolicySnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeavePolicySnapshot value)  $default,){
final _that = this;
switch (_that) {
case _LeavePolicySnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeavePolicySnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _LeavePolicySnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String policyId,  String name,  String code,  double annualEntitlementDays,  bool allowHalfDay,  bool allowNegativeBalance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeavePolicySnapshot() when $default != null:
return $default(_that.policyId,_that.name,_that.code,_that.annualEntitlementDays,_that.allowHalfDay,_that.allowNegativeBalance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String policyId,  String name,  String code,  double annualEntitlementDays,  bool allowHalfDay,  bool allowNegativeBalance)  $default,) {final _that = this;
switch (_that) {
case _LeavePolicySnapshot():
return $default(_that.policyId,_that.name,_that.code,_that.annualEntitlementDays,_that.allowHalfDay,_that.allowNegativeBalance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String policyId,  String name,  String code,  double annualEntitlementDays,  bool allowHalfDay,  bool allowNegativeBalance)?  $default,) {final _that = this;
switch (_that) {
case _LeavePolicySnapshot() when $default != null:
return $default(_that.policyId,_that.name,_that.code,_that.annualEntitlementDays,_that.allowHalfDay,_that.allowNegativeBalance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeavePolicySnapshot implements LeavePolicySnapshot {
  const _LeavePolicySnapshot({required this.policyId, required this.name, required this.code, this.annualEntitlementDays = 0, this.allowHalfDay = true, this.allowNegativeBalance = false});
  factory _LeavePolicySnapshot.fromJson(Map<String, dynamic> json) => _$LeavePolicySnapshotFromJson(json);

@override final  String policyId;
@override final  String name;
@override final  String code;
@override@JsonKey() final  double annualEntitlementDays;
@override@JsonKey() final  bool allowHalfDay;
@override@JsonKey() final  bool allowNegativeBalance;

/// Create a copy of LeavePolicySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeavePolicySnapshotCopyWith<_LeavePolicySnapshot> get copyWith => __$LeavePolicySnapshotCopyWithImpl<_LeavePolicySnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeavePolicySnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeavePolicySnapshot&&(identical(other.policyId, policyId) || other.policyId == policyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.annualEntitlementDays, annualEntitlementDays) || other.annualEntitlementDays == annualEntitlementDays)&&(identical(other.allowHalfDay, allowHalfDay) || other.allowHalfDay == allowHalfDay)&&(identical(other.allowNegativeBalance, allowNegativeBalance) || other.allowNegativeBalance == allowNegativeBalance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,policyId,name,code,annualEntitlementDays,allowHalfDay,allowNegativeBalance);

@override
String toString() {
  return 'LeavePolicySnapshot(policyId: $policyId, name: $name, code: $code, annualEntitlementDays: $annualEntitlementDays, allowHalfDay: $allowHalfDay, allowNegativeBalance: $allowNegativeBalance)';
}


}

/// @nodoc
abstract mixin class _$LeavePolicySnapshotCopyWith<$Res> implements $LeavePolicySnapshotCopyWith<$Res> {
  factory _$LeavePolicySnapshotCopyWith(_LeavePolicySnapshot value, $Res Function(_LeavePolicySnapshot) _then) = __$LeavePolicySnapshotCopyWithImpl;
@override @useResult
$Res call({
 String policyId, String name, String code, double annualEntitlementDays, bool allowHalfDay, bool allowNegativeBalance
});




}
/// @nodoc
class __$LeavePolicySnapshotCopyWithImpl<$Res>
    implements _$LeavePolicySnapshotCopyWith<$Res> {
  __$LeavePolicySnapshotCopyWithImpl(this._self, this._then);

  final _LeavePolicySnapshot _self;
  final $Res Function(_LeavePolicySnapshot) _then;

/// Create a copy of LeavePolicySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? policyId = null,Object? name = null,Object? code = null,Object? annualEntitlementDays = null,Object? allowHalfDay = null,Object? allowNegativeBalance = null,}) {
  return _then(_LeavePolicySnapshot(
policyId: null == policyId ? _self.policyId : policyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,annualEntitlementDays: null == annualEntitlementDays ? _self.annualEntitlementDays : annualEntitlementDays // ignore: cast_nullable_to_non_nullable
as double,allowHalfDay: null == allowHalfDay ? _self.allowHalfDay : allowHalfDay // ignore: cast_nullable_to_non_nullable
as bool,allowNegativeBalance: null == allowNegativeBalance ? _self.allowNegativeBalance : allowNegativeBalance // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$LeaveRequest {

 String get id; String get companyId; String get employeeId; LeaveTypeSnapshot get typeSnapshot; LeavePolicySnapshot? get policySnapshot; DateTime get startDate; DateTime get endDate; LeaveDayPortion get startPortion; LeaveDayPortion get endPortion; double get requestedDays; String get reason; String? get attachmentName; LeaveRequestStatus get status; DateTime? get submittedAt; DateTime? get reviewedAt; String? get reviewedBy; String? get reviewNote; DateTime? get cancelledAt; String? get cancelledBy; String? get cancellationReason; DateTime get createdAt; DateTime get updatedAt; String get requestId; String get syncStatus;
/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaveRequestCopyWith<LeaveRequest> get copyWith => _$LeaveRequestCopyWithImpl<LeaveRequest>(this as LeaveRequest, _$identity);

  /// Serializes this LeaveRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaveRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.typeSnapshot, typeSnapshot) || other.typeSnapshot == typeSnapshot)&&(identical(other.policySnapshot, policySnapshot) || other.policySnapshot == policySnapshot)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.startPortion, startPortion) || other.startPortion == startPortion)&&(identical(other.endPortion, endPortion) || other.endPortion == endPortion)&&(identical(other.requestedDays, requestedDays) || other.requestedDays == requestedDays)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.attachmentName, attachmentName) || other.attachmentName == attachmentName)&&(identical(other.status, status) || other.status == status)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewNote, reviewNote) || other.reviewNote == reviewNote)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.cancelledBy, cancelledBy) || other.cancelledBy == cancelledBy)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,employeeId,typeSnapshot,policySnapshot,startDate,endDate,startPortion,endPortion,requestedDays,reason,attachmentName,status,submittedAt,reviewedAt,reviewedBy,reviewNote,cancelledAt,cancelledBy,cancellationReason,createdAt,updatedAt,requestId,syncStatus]);

@override
String toString() {
  return 'LeaveRequest(id: $id, companyId: $companyId, employeeId: $employeeId, typeSnapshot: $typeSnapshot, policySnapshot: $policySnapshot, startDate: $startDate, endDate: $endDate, startPortion: $startPortion, endPortion: $endPortion, requestedDays: $requestedDays, reason: $reason, attachmentName: $attachmentName, status: $status, submittedAt: $submittedAt, reviewedAt: $reviewedAt, reviewedBy: $reviewedBy, reviewNote: $reviewNote, cancelledAt: $cancelledAt, cancelledBy: $cancelledBy, cancellationReason: $cancellationReason, createdAt: $createdAt, updatedAt: $updatedAt, requestId: $requestId, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $LeaveRequestCopyWith<$Res>  {
  factory $LeaveRequestCopyWith(LeaveRequest value, $Res Function(LeaveRequest) _then) = _$LeaveRequestCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String employeeId, LeaveTypeSnapshot typeSnapshot, LeavePolicySnapshot? policySnapshot, DateTime startDate, DateTime endDate, LeaveDayPortion startPortion, LeaveDayPortion endPortion, double requestedDays, String reason, String? attachmentName, LeaveRequestStatus status, DateTime? submittedAt, DateTime? reviewedAt, String? reviewedBy, String? reviewNote, DateTime? cancelledAt, String? cancelledBy, String? cancellationReason, DateTime createdAt, DateTime updatedAt, String requestId, String syncStatus
});


$LeaveTypeSnapshotCopyWith<$Res> get typeSnapshot;$LeavePolicySnapshotCopyWith<$Res>? get policySnapshot;

}
/// @nodoc
class _$LeaveRequestCopyWithImpl<$Res>
    implements $LeaveRequestCopyWith<$Res> {
  _$LeaveRequestCopyWithImpl(this._self, this._then);

  final LeaveRequest _self;
  final $Res Function(LeaveRequest) _then;

/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? employeeId = null,Object? typeSnapshot = null,Object? policySnapshot = freezed,Object? startDate = null,Object? endDate = null,Object? startPortion = null,Object? endPortion = null,Object? requestedDays = null,Object? reason = null,Object? attachmentName = freezed,Object? status = null,Object? submittedAt = freezed,Object? reviewedAt = freezed,Object? reviewedBy = freezed,Object? reviewNote = freezed,Object? cancelledAt = freezed,Object? cancelledBy = freezed,Object? cancellationReason = freezed,Object? createdAt = null,Object? updatedAt = null,Object? requestId = null,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,typeSnapshot: null == typeSnapshot ? _self.typeSnapshot : typeSnapshot // ignore: cast_nullable_to_non_nullable
as LeaveTypeSnapshot,policySnapshot: freezed == policySnapshot ? _self.policySnapshot : policySnapshot // ignore: cast_nullable_to_non_nullable
as LeavePolicySnapshot?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,startPortion: null == startPortion ? _self.startPortion : startPortion // ignore: cast_nullable_to_non_nullable
as LeaveDayPortion,endPortion: null == endPortion ? _self.endPortion : endPortion // ignore: cast_nullable_to_non_nullable
as LeaveDayPortion,requestedDays: null == requestedDays ? _self.requestedDays : requestedDays // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,attachmentName: freezed == attachmentName ? _self.attachmentName : attachmentName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LeaveRequestStatus,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewNote: freezed == reviewNote ? _self.reviewNote : reviewNote // ignore: cast_nullable_to_non_nullable
as String?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledBy: freezed == cancelledBy ? _self.cancelledBy : cancelledBy // ignore: cast_nullable_to_non_nullable
as String?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeaveTypeSnapshotCopyWith<$Res> get typeSnapshot {
  
  return $LeaveTypeSnapshotCopyWith<$Res>(_self.typeSnapshot, (value) {
    return _then(_self.copyWith(typeSnapshot: value));
  });
}/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeavePolicySnapshotCopyWith<$Res>? get policySnapshot {
    if (_self.policySnapshot == null) {
    return null;
  }

  return $LeavePolicySnapshotCopyWith<$Res>(_self.policySnapshot!, (value) {
    return _then(_self.copyWith(policySnapshot: value));
  });
}
}


/// Adds pattern-matching-related methods to [LeaveRequest].
extension LeaveRequestPatterns on LeaveRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaveRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaveRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaveRequest value)  $default,){
final _that = this;
switch (_that) {
case _LeaveRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaveRequest value)?  $default,){
final _that = this;
switch (_that) {
case _LeaveRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String employeeId,  LeaveTypeSnapshot typeSnapshot,  LeavePolicySnapshot? policySnapshot,  DateTime startDate,  DateTime endDate,  LeaveDayPortion startPortion,  LeaveDayPortion endPortion,  double requestedDays,  String reason,  String? attachmentName,  LeaveRequestStatus status,  DateTime? submittedAt,  DateTime? reviewedAt,  String? reviewedBy,  String? reviewNote,  DateTime? cancelledAt,  String? cancelledBy,  String? cancellationReason,  DateTime createdAt,  DateTime updatedAt,  String requestId,  String syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaveRequest() when $default != null:
return $default(_that.id,_that.companyId,_that.employeeId,_that.typeSnapshot,_that.policySnapshot,_that.startDate,_that.endDate,_that.startPortion,_that.endPortion,_that.requestedDays,_that.reason,_that.attachmentName,_that.status,_that.submittedAt,_that.reviewedAt,_that.reviewedBy,_that.reviewNote,_that.cancelledAt,_that.cancelledBy,_that.cancellationReason,_that.createdAt,_that.updatedAt,_that.requestId,_that.syncStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String employeeId,  LeaveTypeSnapshot typeSnapshot,  LeavePolicySnapshot? policySnapshot,  DateTime startDate,  DateTime endDate,  LeaveDayPortion startPortion,  LeaveDayPortion endPortion,  double requestedDays,  String reason,  String? attachmentName,  LeaveRequestStatus status,  DateTime? submittedAt,  DateTime? reviewedAt,  String? reviewedBy,  String? reviewNote,  DateTime? cancelledAt,  String? cancelledBy,  String? cancellationReason,  DateTime createdAt,  DateTime updatedAt,  String requestId,  String syncStatus)  $default,) {final _that = this;
switch (_that) {
case _LeaveRequest():
return $default(_that.id,_that.companyId,_that.employeeId,_that.typeSnapshot,_that.policySnapshot,_that.startDate,_that.endDate,_that.startPortion,_that.endPortion,_that.requestedDays,_that.reason,_that.attachmentName,_that.status,_that.submittedAt,_that.reviewedAt,_that.reviewedBy,_that.reviewNote,_that.cancelledAt,_that.cancelledBy,_that.cancellationReason,_that.createdAt,_that.updatedAt,_that.requestId,_that.syncStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String employeeId,  LeaveTypeSnapshot typeSnapshot,  LeavePolicySnapshot? policySnapshot,  DateTime startDate,  DateTime endDate,  LeaveDayPortion startPortion,  LeaveDayPortion endPortion,  double requestedDays,  String reason,  String? attachmentName,  LeaveRequestStatus status,  DateTime? submittedAt,  DateTime? reviewedAt,  String? reviewedBy,  String? reviewNote,  DateTime? cancelledAt,  String? cancelledBy,  String? cancellationReason,  DateTime createdAt,  DateTime updatedAt,  String requestId,  String syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _LeaveRequest() when $default != null:
return $default(_that.id,_that.companyId,_that.employeeId,_that.typeSnapshot,_that.policySnapshot,_that.startDate,_that.endDate,_that.startPortion,_that.endPortion,_that.requestedDays,_that.reason,_that.attachmentName,_that.status,_that.submittedAt,_that.reviewedAt,_that.reviewedBy,_that.reviewNote,_that.cancelledAt,_that.cancelledBy,_that.cancellationReason,_that.createdAt,_that.updatedAt,_that.requestId,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _LeaveRequest extends LeaveRequest {
  const _LeaveRequest({required this.id, required this.companyId, required this.employeeId, required this.typeSnapshot, this.policySnapshot, required this.startDate, required this.endDate, this.startPortion = LeaveDayPortion.fullDay, this.endPortion = LeaveDayPortion.fullDay, required this.requestedDays, this.reason = '', this.attachmentName, this.status = LeaveRequestStatus.pending, this.submittedAt, this.reviewedAt, this.reviewedBy, this.reviewNote, this.cancelledAt, this.cancelledBy, this.cancellationReason, required this.createdAt, required this.updatedAt, required this.requestId, this.syncStatus = 'pending'}): super._();
  factory _LeaveRequest.fromJson(Map<String, dynamic> json) => _$LeaveRequestFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  String employeeId;
@override final  LeaveTypeSnapshot typeSnapshot;
@override final  LeavePolicySnapshot? policySnapshot;
@override final  DateTime startDate;
@override final  DateTime endDate;
@override@JsonKey() final  LeaveDayPortion startPortion;
@override@JsonKey() final  LeaveDayPortion endPortion;
@override final  double requestedDays;
@override@JsonKey() final  String reason;
@override final  String? attachmentName;
@override@JsonKey() final  LeaveRequestStatus status;
@override final  DateTime? submittedAt;
@override final  DateTime? reviewedAt;
@override final  String? reviewedBy;
@override final  String? reviewNote;
@override final  DateTime? cancelledAt;
@override final  String? cancelledBy;
@override final  String? cancellationReason;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String requestId;
@override@JsonKey() final  String syncStatus;

/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaveRequestCopyWith<_LeaveRequest> get copyWith => __$LeaveRequestCopyWithImpl<_LeaveRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaveRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaveRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.typeSnapshot, typeSnapshot) || other.typeSnapshot == typeSnapshot)&&(identical(other.policySnapshot, policySnapshot) || other.policySnapshot == policySnapshot)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.startPortion, startPortion) || other.startPortion == startPortion)&&(identical(other.endPortion, endPortion) || other.endPortion == endPortion)&&(identical(other.requestedDays, requestedDays) || other.requestedDays == requestedDays)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.attachmentName, attachmentName) || other.attachmentName == attachmentName)&&(identical(other.status, status) || other.status == status)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewNote, reviewNote) || other.reviewNote == reviewNote)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.cancelledBy, cancelledBy) || other.cancelledBy == cancelledBy)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,employeeId,typeSnapshot,policySnapshot,startDate,endDate,startPortion,endPortion,requestedDays,reason,attachmentName,status,submittedAt,reviewedAt,reviewedBy,reviewNote,cancelledAt,cancelledBy,cancellationReason,createdAt,updatedAt,requestId,syncStatus]);

@override
String toString() {
  return 'LeaveRequest(id: $id, companyId: $companyId, employeeId: $employeeId, typeSnapshot: $typeSnapshot, policySnapshot: $policySnapshot, startDate: $startDate, endDate: $endDate, startPortion: $startPortion, endPortion: $endPortion, requestedDays: $requestedDays, reason: $reason, attachmentName: $attachmentName, status: $status, submittedAt: $submittedAt, reviewedAt: $reviewedAt, reviewedBy: $reviewedBy, reviewNote: $reviewNote, cancelledAt: $cancelledAt, cancelledBy: $cancelledBy, cancellationReason: $cancellationReason, createdAt: $createdAt, updatedAt: $updatedAt, requestId: $requestId, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$LeaveRequestCopyWith<$Res> implements $LeaveRequestCopyWith<$Res> {
  factory _$LeaveRequestCopyWith(_LeaveRequest value, $Res Function(_LeaveRequest) _then) = __$LeaveRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String employeeId, LeaveTypeSnapshot typeSnapshot, LeavePolicySnapshot? policySnapshot, DateTime startDate, DateTime endDate, LeaveDayPortion startPortion, LeaveDayPortion endPortion, double requestedDays, String reason, String? attachmentName, LeaveRequestStatus status, DateTime? submittedAt, DateTime? reviewedAt, String? reviewedBy, String? reviewNote, DateTime? cancelledAt, String? cancelledBy, String? cancellationReason, DateTime createdAt, DateTime updatedAt, String requestId, String syncStatus
});


@override $LeaveTypeSnapshotCopyWith<$Res> get typeSnapshot;@override $LeavePolicySnapshotCopyWith<$Res>? get policySnapshot;

}
/// @nodoc
class __$LeaveRequestCopyWithImpl<$Res>
    implements _$LeaveRequestCopyWith<$Res> {
  __$LeaveRequestCopyWithImpl(this._self, this._then);

  final _LeaveRequest _self;
  final $Res Function(_LeaveRequest) _then;

/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? employeeId = null,Object? typeSnapshot = null,Object? policySnapshot = freezed,Object? startDate = null,Object? endDate = null,Object? startPortion = null,Object? endPortion = null,Object? requestedDays = null,Object? reason = null,Object? attachmentName = freezed,Object? status = null,Object? submittedAt = freezed,Object? reviewedAt = freezed,Object? reviewedBy = freezed,Object? reviewNote = freezed,Object? cancelledAt = freezed,Object? cancelledBy = freezed,Object? cancellationReason = freezed,Object? createdAt = null,Object? updatedAt = null,Object? requestId = null,Object? syncStatus = null,}) {
  return _then(_LeaveRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,typeSnapshot: null == typeSnapshot ? _self.typeSnapshot : typeSnapshot // ignore: cast_nullable_to_non_nullable
as LeaveTypeSnapshot,policySnapshot: freezed == policySnapshot ? _self.policySnapshot : policySnapshot // ignore: cast_nullable_to_non_nullable
as LeavePolicySnapshot?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,startPortion: null == startPortion ? _self.startPortion : startPortion // ignore: cast_nullable_to_non_nullable
as LeaveDayPortion,endPortion: null == endPortion ? _self.endPortion : endPortion // ignore: cast_nullable_to_non_nullable
as LeaveDayPortion,requestedDays: null == requestedDays ? _self.requestedDays : requestedDays // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,attachmentName: freezed == attachmentName ? _self.attachmentName : attachmentName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LeaveRequestStatus,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewNote: freezed == reviewNote ? _self.reviewNote : reviewNote // ignore: cast_nullable_to_non_nullable
as String?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledBy: freezed == cancelledBy ? _self.cancelledBy : cancelledBy // ignore: cast_nullable_to_non_nullable
as String?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeaveTypeSnapshotCopyWith<$Res> get typeSnapshot {
  
  return $LeaveTypeSnapshotCopyWith<$Res>(_self.typeSnapshot, (value) {
    return _then(_self.copyWith(typeSnapshot: value));
  });
}/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeavePolicySnapshotCopyWith<$Res>? get policySnapshot {
    if (_self.policySnapshot == null) {
    return null;
  }

  return $LeavePolicySnapshotCopyWith<$Res>(_self.policySnapshot!, (value) {
    return _then(_self.copyWith(policySnapshot: value));
  });
}
}


/// @nodoc
mixin _$LeaveBalanceTransaction {

 String get id; String get companyId; String get employeeId; String get leaveTypeId; int get leaveYear; LeaveBalanceTransactionType get type; double get quantityDays; String? get leaveRequestId; String get reason; String get createdBy; DateTime get effectiveDate; DateTime get createdAt; String get requestId; String get syncStatus;
/// Create a copy of LeaveBalanceTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaveBalanceTransactionCopyWith<LeaveBalanceTransaction> get copyWith => _$LeaveBalanceTransactionCopyWithImpl<LeaveBalanceTransaction>(this as LeaveBalanceTransaction, _$identity);

  /// Serializes this LeaveBalanceTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaveBalanceTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.leaveTypeId, leaveTypeId) || other.leaveTypeId == leaveTypeId)&&(identical(other.leaveYear, leaveYear) || other.leaveYear == leaveYear)&&(identical(other.type, type) || other.type == type)&&(identical(other.quantityDays, quantityDays) || other.quantityDays == quantityDays)&&(identical(other.leaveRequestId, leaveRequestId) || other.leaveRequestId == leaveRequestId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.effectiveDate, effectiveDate) || other.effectiveDate == effectiveDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,employeeId,leaveTypeId,leaveYear,type,quantityDays,leaveRequestId,reason,createdBy,effectiveDate,createdAt,requestId,syncStatus);

@override
String toString() {
  return 'LeaveBalanceTransaction(id: $id, companyId: $companyId, employeeId: $employeeId, leaveTypeId: $leaveTypeId, leaveYear: $leaveYear, type: $type, quantityDays: $quantityDays, leaveRequestId: $leaveRequestId, reason: $reason, createdBy: $createdBy, effectiveDate: $effectiveDate, createdAt: $createdAt, requestId: $requestId, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $LeaveBalanceTransactionCopyWith<$Res>  {
  factory $LeaveBalanceTransactionCopyWith(LeaveBalanceTransaction value, $Res Function(LeaveBalanceTransaction) _then) = _$LeaveBalanceTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String employeeId, String leaveTypeId, int leaveYear, LeaveBalanceTransactionType type, double quantityDays, String? leaveRequestId, String reason, String createdBy, DateTime effectiveDate, DateTime createdAt, String requestId, String syncStatus
});




}
/// @nodoc
class _$LeaveBalanceTransactionCopyWithImpl<$Res>
    implements $LeaveBalanceTransactionCopyWith<$Res> {
  _$LeaveBalanceTransactionCopyWithImpl(this._self, this._then);

  final LeaveBalanceTransaction _self;
  final $Res Function(LeaveBalanceTransaction) _then;

/// Create a copy of LeaveBalanceTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? employeeId = null,Object? leaveTypeId = null,Object? leaveYear = null,Object? type = null,Object? quantityDays = null,Object? leaveRequestId = freezed,Object? reason = null,Object? createdBy = null,Object? effectiveDate = null,Object? createdAt = null,Object? requestId = null,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,leaveTypeId: null == leaveTypeId ? _self.leaveTypeId : leaveTypeId // ignore: cast_nullable_to_non_nullable
as String,leaveYear: null == leaveYear ? _self.leaveYear : leaveYear // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LeaveBalanceTransactionType,quantityDays: null == quantityDays ? _self.quantityDays : quantityDays // ignore: cast_nullable_to_non_nullable
as double,leaveRequestId: freezed == leaveRequestId ? _self.leaveRequestId : leaveRequestId // ignore: cast_nullable_to_non_nullable
as String?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,effectiveDate: null == effectiveDate ? _self.effectiveDate : effectiveDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaveBalanceTransaction].
extension LeaveBalanceTransactionPatterns on LeaveBalanceTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaveBalanceTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaveBalanceTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaveBalanceTransaction value)  $default,){
final _that = this;
switch (_that) {
case _LeaveBalanceTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaveBalanceTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _LeaveBalanceTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String employeeId,  String leaveTypeId,  int leaveYear,  LeaveBalanceTransactionType type,  double quantityDays,  String? leaveRequestId,  String reason,  String createdBy,  DateTime effectiveDate,  DateTime createdAt,  String requestId,  String syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaveBalanceTransaction() when $default != null:
return $default(_that.id,_that.companyId,_that.employeeId,_that.leaveTypeId,_that.leaveYear,_that.type,_that.quantityDays,_that.leaveRequestId,_that.reason,_that.createdBy,_that.effectiveDate,_that.createdAt,_that.requestId,_that.syncStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String employeeId,  String leaveTypeId,  int leaveYear,  LeaveBalanceTransactionType type,  double quantityDays,  String? leaveRequestId,  String reason,  String createdBy,  DateTime effectiveDate,  DateTime createdAt,  String requestId,  String syncStatus)  $default,) {final _that = this;
switch (_that) {
case _LeaveBalanceTransaction():
return $default(_that.id,_that.companyId,_that.employeeId,_that.leaveTypeId,_that.leaveYear,_that.type,_that.quantityDays,_that.leaveRequestId,_that.reason,_that.createdBy,_that.effectiveDate,_that.createdAt,_that.requestId,_that.syncStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String employeeId,  String leaveTypeId,  int leaveYear,  LeaveBalanceTransactionType type,  double quantityDays,  String? leaveRequestId,  String reason,  String createdBy,  DateTime effectiveDate,  DateTime createdAt,  String requestId,  String syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _LeaveBalanceTransaction() when $default != null:
return $default(_that.id,_that.companyId,_that.employeeId,_that.leaveTypeId,_that.leaveYear,_that.type,_that.quantityDays,_that.leaveRequestId,_that.reason,_that.createdBy,_that.effectiveDate,_that.createdAt,_that.requestId,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaveBalanceTransaction implements LeaveBalanceTransaction {
  const _LeaveBalanceTransaction({required this.id, required this.companyId, required this.employeeId, required this.leaveTypeId, required this.leaveYear, required this.type, required this.quantityDays, this.leaveRequestId, this.reason = '', required this.createdBy, required this.effectiveDate, required this.createdAt, required this.requestId, this.syncStatus = 'pending'});
  factory _LeaveBalanceTransaction.fromJson(Map<String, dynamic> json) => _$LeaveBalanceTransactionFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  String employeeId;
@override final  String leaveTypeId;
@override final  int leaveYear;
@override final  LeaveBalanceTransactionType type;
@override final  double quantityDays;
@override final  String? leaveRequestId;
@override@JsonKey() final  String reason;
@override final  String createdBy;
@override final  DateTime effectiveDate;
@override final  DateTime createdAt;
@override final  String requestId;
@override@JsonKey() final  String syncStatus;

/// Create a copy of LeaveBalanceTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaveBalanceTransactionCopyWith<_LeaveBalanceTransaction> get copyWith => __$LeaveBalanceTransactionCopyWithImpl<_LeaveBalanceTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaveBalanceTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaveBalanceTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.leaveTypeId, leaveTypeId) || other.leaveTypeId == leaveTypeId)&&(identical(other.leaveYear, leaveYear) || other.leaveYear == leaveYear)&&(identical(other.type, type) || other.type == type)&&(identical(other.quantityDays, quantityDays) || other.quantityDays == quantityDays)&&(identical(other.leaveRequestId, leaveRequestId) || other.leaveRequestId == leaveRequestId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.effectiveDate, effectiveDate) || other.effectiveDate == effectiveDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,employeeId,leaveTypeId,leaveYear,type,quantityDays,leaveRequestId,reason,createdBy,effectiveDate,createdAt,requestId,syncStatus);

@override
String toString() {
  return 'LeaveBalanceTransaction(id: $id, companyId: $companyId, employeeId: $employeeId, leaveTypeId: $leaveTypeId, leaveYear: $leaveYear, type: $type, quantityDays: $quantityDays, leaveRequestId: $leaveRequestId, reason: $reason, createdBy: $createdBy, effectiveDate: $effectiveDate, createdAt: $createdAt, requestId: $requestId, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$LeaveBalanceTransactionCopyWith<$Res> implements $LeaveBalanceTransactionCopyWith<$Res> {
  factory _$LeaveBalanceTransactionCopyWith(_LeaveBalanceTransaction value, $Res Function(_LeaveBalanceTransaction) _then) = __$LeaveBalanceTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String employeeId, String leaveTypeId, int leaveYear, LeaveBalanceTransactionType type, double quantityDays, String? leaveRequestId, String reason, String createdBy, DateTime effectiveDate, DateTime createdAt, String requestId, String syncStatus
});




}
/// @nodoc
class __$LeaveBalanceTransactionCopyWithImpl<$Res>
    implements _$LeaveBalanceTransactionCopyWith<$Res> {
  __$LeaveBalanceTransactionCopyWithImpl(this._self, this._then);

  final _LeaveBalanceTransaction _self;
  final $Res Function(_LeaveBalanceTransaction) _then;

/// Create a copy of LeaveBalanceTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? employeeId = null,Object? leaveTypeId = null,Object? leaveYear = null,Object? type = null,Object? quantityDays = null,Object? leaveRequestId = freezed,Object? reason = null,Object? createdBy = null,Object? effectiveDate = null,Object? createdAt = null,Object? requestId = null,Object? syncStatus = null,}) {
  return _then(_LeaveBalanceTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,leaveTypeId: null == leaveTypeId ? _self.leaveTypeId : leaveTypeId // ignore: cast_nullable_to_non_nullable
as String,leaveYear: null == leaveYear ? _self.leaveYear : leaveYear // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LeaveBalanceTransactionType,quantityDays: null == quantityDays ? _self.quantityDays : quantityDays // ignore: cast_nullable_to_non_nullable
as double,leaveRequestId: freezed == leaveRequestId ? _self.leaveRequestId : leaveRequestId // ignore: cast_nullable_to_non_nullable
as String?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,effectiveDate: null == effectiveDate ? _self.effectiveDate : effectiveDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$LeaveTypeDraft {

 String get name; String get code; String get description; LeaveCompensationType get compensation; bool get requiresApproval; bool get allowsHalfDay; bool get requiresReason; bool get requiresAttachment; String get colorKey; ConfigurationStatus get status;
/// Create a copy of LeaveTypeDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaveTypeDraftCopyWith<LeaveTypeDraft> get copyWith => _$LeaveTypeDraftCopyWithImpl<LeaveTypeDraft>(this as LeaveTypeDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaveTypeDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&(identical(other.compensation, compensation) || other.compensation == compensation)&&(identical(other.requiresApproval, requiresApproval) || other.requiresApproval == requiresApproval)&&(identical(other.allowsHalfDay, allowsHalfDay) || other.allowsHalfDay == allowsHalfDay)&&(identical(other.requiresReason, requiresReason) || other.requiresReason == requiresReason)&&(identical(other.requiresAttachment, requiresAttachment) || other.requiresAttachment == requiresAttachment)&&(identical(other.colorKey, colorKey) || other.colorKey == colorKey)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,name,code,description,compensation,requiresApproval,allowsHalfDay,requiresReason,requiresAttachment,colorKey,status);

@override
String toString() {
  return 'LeaveTypeDraft(name: $name, code: $code, description: $description, compensation: $compensation, requiresApproval: $requiresApproval, allowsHalfDay: $allowsHalfDay, requiresReason: $requiresReason, requiresAttachment: $requiresAttachment, colorKey: $colorKey, status: $status)';
}


}

/// @nodoc
abstract mixin class $LeaveTypeDraftCopyWith<$Res>  {
  factory $LeaveTypeDraftCopyWith(LeaveTypeDraft value, $Res Function(LeaveTypeDraft) _then) = _$LeaveTypeDraftCopyWithImpl;
@useResult
$Res call({
 String name, String code, String description, LeaveCompensationType compensation, bool requiresApproval, bool allowsHalfDay, bool requiresReason, bool requiresAttachment, String colorKey, ConfigurationStatus status
});




}
/// @nodoc
class _$LeaveTypeDraftCopyWithImpl<$Res>
    implements $LeaveTypeDraftCopyWith<$Res> {
  _$LeaveTypeDraftCopyWithImpl(this._self, this._then);

  final LeaveTypeDraft _self;
  final $Res Function(LeaveTypeDraft) _then;

/// Create a copy of LeaveTypeDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? code = null,Object? description = null,Object? compensation = null,Object? requiresApproval = null,Object? allowsHalfDay = null,Object? requiresReason = null,Object? requiresAttachment = null,Object? colorKey = null,Object? status = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,compensation: null == compensation ? _self.compensation : compensation // ignore: cast_nullable_to_non_nullable
as LeaveCompensationType,requiresApproval: null == requiresApproval ? _self.requiresApproval : requiresApproval // ignore: cast_nullable_to_non_nullable
as bool,allowsHalfDay: null == allowsHalfDay ? _self.allowsHalfDay : allowsHalfDay // ignore: cast_nullable_to_non_nullable
as bool,requiresReason: null == requiresReason ? _self.requiresReason : requiresReason // ignore: cast_nullable_to_non_nullable
as bool,requiresAttachment: null == requiresAttachment ? _self.requiresAttachment : requiresAttachment // ignore: cast_nullable_to_non_nullable
as bool,colorKey: null == colorKey ? _self.colorKey : colorKey // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaveTypeDraft].
extension LeaveTypeDraftPatterns on LeaveTypeDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaveTypeDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaveTypeDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaveTypeDraft value)  $default,){
final _that = this;
switch (_that) {
case _LeaveTypeDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaveTypeDraft value)?  $default,){
final _that = this;
switch (_that) {
case _LeaveTypeDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String code,  String description,  LeaveCompensationType compensation,  bool requiresApproval,  bool allowsHalfDay,  bool requiresReason,  bool requiresAttachment,  String colorKey,  ConfigurationStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaveTypeDraft() when $default != null:
return $default(_that.name,_that.code,_that.description,_that.compensation,_that.requiresApproval,_that.allowsHalfDay,_that.requiresReason,_that.requiresAttachment,_that.colorKey,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String code,  String description,  LeaveCompensationType compensation,  bool requiresApproval,  bool allowsHalfDay,  bool requiresReason,  bool requiresAttachment,  String colorKey,  ConfigurationStatus status)  $default,) {final _that = this;
switch (_that) {
case _LeaveTypeDraft():
return $default(_that.name,_that.code,_that.description,_that.compensation,_that.requiresApproval,_that.allowsHalfDay,_that.requiresReason,_that.requiresAttachment,_that.colorKey,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String code,  String description,  LeaveCompensationType compensation,  bool requiresApproval,  bool allowsHalfDay,  bool requiresReason,  bool requiresAttachment,  String colorKey,  ConfigurationStatus status)?  $default,) {final _that = this;
switch (_that) {
case _LeaveTypeDraft() when $default != null:
return $default(_that.name,_that.code,_that.description,_that.compensation,_that.requiresApproval,_that.allowsHalfDay,_that.requiresReason,_that.requiresAttachment,_that.colorKey,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _LeaveTypeDraft extends LeaveTypeDraft {
  const _LeaveTypeDraft({this.name = '', this.code = '', this.description = '', this.compensation = LeaveCompensationType.paid, this.requiresApproval = true, this.allowsHalfDay = true, this.requiresReason = true, this.requiresAttachment = false, this.colorKey = 'annual', this.status = ConfigurationStatus.active}): super._();
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String code;
@override@JsonKey() final  String description;
@override@JsonKey() final  LeaveCompensationType compensation;
@override@JsonKey() final  bool requiresApproval;
@override@JsonKey() final  bool allowsHalfDay;
@override@JsonKey() final  bool requiresReason;
@override@JsonKey() final  bool requiresAttachment;
@override@JsonKey() final  String colorKey;
@override@JsonKey() final  ConfigurationStatus status;

/// Create a copy of LeaveTypeDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaveTypeDraftCopyWith<_LeaveTypeDraft> get copyWith => __$LeaveTypeDraftCopyWithImpl<_LeaveTypeDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaveTypeDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&(identical(other.compensation, compensation) || other.compensation == compensation)&&(identical(other.requiresApproval, requiresApproval) || other.requiresApproval == requiresApproval)&&(identical(other.allowsHalfDay, allowsHalfDay) || other.allowsHalfDay == allowsHalfDay)&&(identical(other.requiresReason, requiresReason) || other.requiresReason == requiresReason)&&(identical(other.requiresAttachment, requiresAttachment) || other.requiresAttachment == requiresAttachment)&&(identical(other.colorKey, colorKey) || other.colorKey == colorKey)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,name,code,description,compensation,requiresApproval,allowsHalfDay,requiresReason,requiresAttachment,colorKey,status);

@override
String toString() {
  return 'LeaveTypeDraft(name: $name, code: $code, description: $description, compensation: $compensation, requiresApproval: $requiresApproval, allowsHalfDay: $allowsHalfDay, requiresReason: $requiresReason, requiresAttachment: $requiresAttachment, colorKey: $colorKey, status: $status)';
}


}

/// @nodoc
abstract mixin class _$LeaveTypeDraftCopyWith<$Res> implements $LeaveTypeDraftCopyWith<$Res> {
  factory _$LeaveTypeDraftCopyWith(_LeaveTypeDraft value, $Res Function(_LeaveTypeDraft) _then) = __$LeaveTypeDraftCopyWithImpl;
@override @useResult
$Res call({
 String name, String code, String description, LeaveCompensationType compensation, bool requiresApproval, bool allowsHalfDay, bool requiresReason, bool requiresAttachment, String colorKey, ConfigurationStatus status
});




}
/// @nodoc
class __$LeaveTypeDraftCopyWithImpl<$Res>
    implements _$LeaveTypeDraftCopyWith<$Res> {
  __$LeaveTypeDraftCopyWithImpl(this._self, this._then);

  final _LeaveTypeDraft _self;
  final $Res Function(_LeaveTypeDraft) _then;

/// Create a copy of LeaveTypeDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? code = null,Object? description = null,Object? compensation = null,Object? requiresApproval = null,Object? allowsHalfDay = null,Object? requiresReason = null,Object? requiresAttachment = null,Object? colorKey = null,Object? status = null,}) {
  return _then(_LeaveTypeDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,compensation: null == compensation ? _self.compensation : compensation // ignore: cast_nullable_to_non_nullable
as LeaveCompensationType,requiresApproval: null == requiresApproval ? _self.requiresApproval : requiresApproval // ignore: cast_nullable_to_non_nullable
as bool,allowsHalfDay: null == allowsHalfDay ? _self.allowsHalfDay : allowsHalfDay // ignore: cast_nullable_to_non_nullable
as bool,requiresReason: null == requiresReason ? _self.requiresReason : requiresReason // ignore: cast_nullable_to_non_nullable
as bool,requiresAttachment: null == requiresAttachment ? _self.requiresAttachment : requiresAttachment // ignore: cast_nullable_to_non_nullable
as bool,colorKey: null == colorKey ? _self.colorKey : colorKey // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,
  ));
}


}

/// @nodoc
mixin _$LeavePolicyDraft {

 String get name; String get code; String get leaveTypeId; double get annualEntitlementDays; bool get allowHalfDay; double get minimumRequestDays; int? get maximumConsecutiveDays; int get advanceNoticeDays; bool get allowPastRequest; int get pastRequestWindowDays; int? get requiresAttachmentAfterDays; bool get allowNegativeBalance; bool get carryForwardEnabled; double? get carryForwardLimitDays; Set<EmploymentType> get applicableEmploymentTypes; ConfigurationStatus get status;
/// Create a copy of LeavePolicyDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeavePolicyDraftCopyWith<LeavePolicyDraft> get copyWith => _$LeavePolicyDraftCopyWithImpl<LeavePolicyDraft>(this as LeavePolicyDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeavePolicyDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.leaveTypeId, leaveTypeId) || other.leaveTypeId == leaveTypeId)&&(identical(other.annualEntitlementDays, annualEntitlementDays) || other.annualEntitlementDays == annualEntitlementDays)&&(identical(other.allowHalfDay, allowHalfDay) || other.allowHalfDay == allowHalfDay)&&(identical(other.minimumRequestDays, minimumRequestDays) || other.minimumRequestDays == minimumRequestDays)&&(identical(other.maximumConsecutiveDays, maximumConsecutiveDays) || other.maximumConsecutiveDays == maximumConsecutiveDays)&&(identical(other.advanceNoticeDays, advanceNoticeDays) || other.advanceNoticeDays == advanceNoticeDays)&&(identical(other.allowPastRequest, allowPastRequest) || other.allowPastRequest == allowPastRequest)&&(identical(other.pastRequestWindowDays, pastRequestWindowDays) || other.pastRequestWindowDays == pastRequestWindowDays)&&(identical(other.requiresAttachmentAfterDays, requiresAttachmentAfterDays) || other.requiresAttachmentAfterDays == requiresAttachmentAfterDays)&&(identical(other.allowNegativeBalance, allowNegativeBalance) || other.allowNegativeBalance == allowNegativeBalance)&&(identical(other.carryForwardEnabled, carryForwardEnabled) || other.carryForwardEnabled == carryForwardEnabled)&&(identical(other.carryForwardLimitDays, carryForwardLimitDays) || other.carryForwardLimitDays == carryForwardLimitDays)&&const DeepCollectionEquality().equals(other.applicableEmploymentTypes, applicableEmploymentTypes)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,name,code,leaveTypeId,annualEntitlementDays,allowHalfDay,minimumRequestDays,maximumConsecutiveDays,advanceNoticeDays,allowPastRequest,pastRequestWindowDays,requiresAttachmentAfterDays,allowNegativeBalance,carryForwardEnabled,carryForwardLimitDays,const DeepCollectionEquality().hash(applicableEmploymentTypes),status);

@override
String toString() {
  return 'LeavePolicyDraft(name: $name, code: $code, leaveTypeId: $leaveTypeId, annualEntitlementDays: $annualEntitlementDays, allowHalfDay: $allowHalfDay, minimumRequestDays: $minimumRequestDays, maximumConsecutiveDays: $maximumConsecutiveDays, advanceNoticeDays: $advanceNoticeDays, allowPastRequest: $allowPastRequest, pastRequestWindowDays: $pastRequestWindowDays, requiresAttachmentAfterDays: $requiresAttachmentAfterDays, allowNegativeBalance: $allowNegativeBalance, carryForwardEnabled: $carryForwardEnabled, carryForwardLimitDays: $carryForwardLimitDays, applicableEmploymentTypes: $applicableEmploymentTypes, status: $status)';
}


}

/// @nodoc
abstract mixin class $LeavePolicyDraftCopyWith<$Res>  {
  factory $LeavePolicyDraftCopyWith(LeavePolicyDraft value, $Res Function(LeavePolicyDraft) _then) = _$LeavePolicyDraftCopyWithImpl;
@useResult
$Res call({
 String name, String code, String leaveTypeId, double annualEntitlementDays, bool allowHalfDay, double minimumRequestDays, int? maximumConsecutiveDays, int advanceNoticeDays, bool allowPastRequest, int pastRequestWindowDays, int? requiresAttachmentAfterDays, bool allowNegativeBalance, bool carryForwardEnabled, double? carryForwardLimitDays, Set<EmploymentType> applicableEmploymentTypes, ConfigurationStatus status
});




}
/// @nodoc
class _$LeavePolicyDraftCopyWithImpl<$Res>
    implements $LeavePolicyDraftCopyWith<$Res> {
  _$LeavePolicyDraftCopyWithImpl(this._self, this._then);

  final LeavePolicyDraft _self;
  final $Res Function(LeavePolicyDraft) _then;

/// Create a copy of LeavePolicyDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? code = null,Object? leaveTypeId = null,Object? annualEntitlementDays = null,Object? allowHalfDay = null,Object? minimumRequestDays = null,Object? maximumConsecutiveDays = freezed,Object? advanceNoticeDays = null,Object? allowPastRequest = null,Object? pastRequestWindowDays = null,Object? requiresAttachmentAfterDays = freezed,Object? allowNegativeBalance = null,Object? carryForwardEnabled = null,Object? carryForwardLimitDays = freezed,Object? applicableEmploymentTypes = null,Object? status = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,leaveTypeId: null == leaveTypeId ? _self.leaveTypeId : leaveTypeId // ignore: cast_nullable_to_non_nullable
as String,annualEntitlementDays: null == annualEntitlementDays ? _self.annualEntitlementDays : annualEntitlementDays // ignore: cast_nullable_to_non_nullable
as double,allowHalfDay: null == allowHalfDay ? _self.allowHalfDay : allowHalfDay // ignore: cast_nullable_to_non_nullable
as bool,minimumRequestDays: null == minimumRequestDays ? _self.minimumRequestDays : minimumRequestDays // ignore: cast_nullable_to_non_nullable
as double,maximumConsecutiveDays: freezed == maximumConsecutiveDays ? _self.maximumConsecutiveDays : maximumConsecutiveDays // ignore: cast_nullable_to_non_nullable
as int?,advanceNoticeDays: null == advanceNoticeDays ? _self.advanceNoticeDays : advanceNoticeDays // ignore: cast_nullable_to_non_nullable
as int,allowPastRequest: null == allowPastRequest ? _self.allowPastRequest : allowPastRequest // ignore: cast_nullable_to_non_nullable
as bool,pastRequestWindowDays: null == pastRequestWindowDays ? _self.pastRequestWindowDays : pastRequestWindowDays // ignore: cast_nullable_to_non_nullable
as int,requiresAttachmentAfterDays: freezed == requiresAttachmentAfterDays ? _self.requiresAttachmentAfterDays : requiresAttachmentAfterDays // ignore: cast_nullable_to_non_nullable
as int?,allowNegativeBalance: null == allowNegativeBalance ? _self.allowNegativeBalance : allowNegativeBalance // ignore: cast_nullable_to_non_nullable
as bool,carryForwardEnabled: null == carryForwardEnabled ? _self.carryForwardEnabled : carryForwardEnabled // ignore: cast_nullable_to_non_nullable
as bool,carryForwardLimitDays: freezed == carryForwardLimitDays ? _self.carryForwardLimitDays : carryForwardLimitDays // ignore: cast_nullable_to_non_nullable
as double?,applicableEmploymentTypes: null == applicableEmploymentTypes ? _self.applicableEmploymentTypes : applicableEmploymentTypes // ignore: cast_nullable_to_non_nullable
as Set<EmploymentType>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [LeavePolicyDraft].
extension LeavePolicyDraftPatterns on LeavePolicyDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeavePolicyDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeavePolicyDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeavePolicyDraft value)  $default,){
final _that = this;
switch (_that) {
case _LeavePolicyDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeavePolicyDraft value)?  $default,){
final _that = this;
switch (_that) {
case _LeavePolicyDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String code,  String leaveTypeId,  double annualEntitlementDays,  bool allowHalfDay,  double minimumRequestDays,  int? maximumConsecutiveDays,  int advanceNoticeDays,  bool allowPastRequest,  int pastRequestWindowDays,  int? requiresAttachmentAfterDays,  bool allowNegativeBalance,  bool carryForwardEnabled,  double? carryForwardLimitDays,  Set<EmploymentType> applicableEmploymentTypes,  ConfigurationStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeavePolicyDraft() when $default != null:
return $default(_that.name,_that.code,_that.leaveTypeId,_that.annualEntitlementDays,_that.allowHalfDay,_that.minimumRequestDays,_that.maximumConsecutiveDays,_that.advanceNoticeDays,_that.allowPastRequest,_that.pastRequestWindowDays,_that.requiresAttachmentAfterDays,_that.allowNegativeBalance,_that.carryForwardEnabled,_that.carryForwardLimitDays,_that.applicableEmploymentTypes,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String code,  String leaveTypeId,  double annualEntitlementDays,  bool allowHalfDay,  double minimumRequestDays,  int? maximumConsecutiveDays,  int advanceNoticeDays,  bool allowPastRequest,  int pastRequestWindowDays,  int? requiresAttachmentAfterDays,  bool allowNegativeBalance,  bool carryForwardEnabled,  double? carryForwardLimitDays,  Set<EmploymentType> applicableEmploymentTypes,  ConfigurationStatus status)  $default,) {final _that = this;
switch (_that) {
case _LeavePolicyDraft():
return $default(_that.name,_that.code,_that.leaveTypeId,_that.annualEntitlementDays,_that.allowHalfDay,_that.minimumRequestDays,_that.maximumConsecutiveDays,_that.advanceNoticeDays,_that.allowPastRequest,_that.pastRequestWindowDays,_that.requiresAttachmentAfterDays,_that.allowNegativeBalance,_that.carryForwardEnabled,_that.carryForwardLimitDays,_that.applicableEmploymentTypes,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String code,  String leaveTypeId,  double annualEntitlementDays,  bool allowHalfDay,  double minimumRequestDays,  int? maximumConsecutiveDays,  int advanceNoticeDays,  bool allowPastRequest,  int pastRequestWindowDays,  int? requiresAttachmentAfterDays,  bool allowNegativeBalance,  bool carryForwardEnabled,  double? carryForwardLimitDays,  Set<EmploymentType> applicableEmploymentTypes,  ConfigurationStatus status)?  $default,) {final _that = this;
switch (_that) {
case _LeavePolicyDraft() when $default != null:
return $default(_that.name,_that.code,_that.leaveTypeId,_that.annualEntitlementDays,_that.allowHalfDay,_that.minimumRequestDays,_that.maximumConsecutiveDays,_that.advanceNoticeDays,_that.allowPastRequest,_that.pastRequestWindowDays,_that.requiresAttachmentAfterDays,_that.allowNegativeBalance,_that.carryForwardEnabled,_that.carryForwardLimitDays,_that.applicableEmploymentTypes,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _LeavePolicyDraft extends LeavePolicyDraft {
  const _LeavePolicyDraft({this.name = '', this.code = '', this.leaveTypeId = '', this.annualEntitlementDays = 0, this.allowHalfDay = true, this.minimumRequestDays = 0.5, this.maximumConsecutiveDays, this.advanceNoticeDays = 0, this.allowPastRequest = false, this.pastRequestWindowDays = 0, this.requiresAttachmentAfterDays, this.allowNegativeBalance = false, this.carryForwardEnabled = false, this.carryForwardLimitDays, final  Set<EmploymentType> applicableEmploymentTypes = const <EmploymentType>{}, this.status = ConfigurationStatus.active}): _applicableEmploymentTypes = applicableEmploymentTypes,super._();
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String code;
@override@JsonKey() final  String leaveTypeId;
@override@JsonKey() final  double annualEntitlementDays;
@override@JsonKey() final  bool allowHalfDay;
@override@JsonKey() final  double minimumRequestDays;
@override final  int? maximumConsecutiveDays;
@override@JsonKey() final  int advanceNoticeDays;
@override@JsonKey() final  bool allowPastRequest;
@override@JsonKey() final  int pastRequestWindowDays;
@override final  int? requiresAttachmentAfterDays;
@override@JsonKey() final  bool allowNegativeBalance;
@override@JsonKey() final  bool carryForwardEnabled;
@override final  double? carryForwardLimitDays;
 final  Set<EmploymentType> _applicableEmploymentTypes;
@override@JsonKey() Set<EmploymentType> get applicableEmploymentTypes {
  if (_applicableEmploymentTypes is EqualUnmodifiableSetView) return _applicableEmploymentTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_applicableEmploymentTypes);
}

@override@JsonKey() final  ConfigurationStatus status;

/// Create a copy of LeavePolicyDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeavePolicyDraftCopyWith<_LeavePolicyDraft> get copyWith => __$LeavePolicyDraftCopyWithImpl<_LeavePolicyDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeavePolicyDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.leaveTypeId, leaveTypeId) || other.leaveTypeId == leaveTypeId)&&(identical(other.annualEntitlementDays, annualEntitlementDays) || other.annualEntitlementDays == annualEntitlementDays)&&(identical(other.allowHalfDay, allowHalfDay) || other.allowHalfDay == allowHalfDay)&&(identical(other.minimumRequestDays, minimumRequestDays) || other.minimumRequestDays == minimumRequestDays)&&(identical(other.maximumConsecutiveDays, maximumConsecutiveDays) || other.maximumConsecutiveDays == maximumConsecutiveDays)&&(identical(other.advanceNoticeDays, advanceNoticeDays) || other.advanceNoticeDays == advanceNoticeDays)&&(identical(other.allowPastRequest, allowPastRequest) || other.allowPastRequest == allowPastRequest)&&(identical(other.pastRequestWindowDays, pastRequestWindowDays) || other.pastRequestWindowDays == pastRequestWindowDays)&&(identical(other.requiresAttachmentAfterDays, requiresAttachmentAfterDays) || other.requiresAttachmentAfterDays == requiresAttachmentAfterDays)&&(identical(other.allowNegativeBalance, allowNegativeBalance) || other.allowNegativeBalance == allowNegativeBalance)&&(identical(other.carryForwardEnabled, carryForwardEnabled) || other.carryForwardEnabled == carryForwardEnabled)&&(identical(other.carryForwardLimitDays, carryForwardLimitDays) || other.carryForwardLimitDays == carryForwardLimitDays)&&const DeepCollectionEquality().equals(other._applicableEmploymentTypes, _applicableEmploymentTypes)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,name,code,leaveTypeId,annualEntitlementDays,allowHalfDay,minimumRequestDays,maximumConsecutiveDays,advanceNoticeDays,allowPastRequest,pastRequestWindowDays,requiresAttachmentAfterDays,allowNegativeBalance,carryForwardEnabled,carryForwardLimitDays,const DeepCollectionEquality().hash(_applicableEmploymentTypes),status);

@override
String toString() {
  return 'LeavePolicyDraft(name: $name, code: $code, leaveTypeId: $leaveTypeId, annualEntitlementDays: $annualEntitlementDays, allowHalfDay: $allowHalfDay, minimumRequestDays: $minimumRequestDays, maximumConsecutiveDays: $maximumConsecutiveDays, advanceNoticeDays: $advanceNoticeDays, allowPastRequest: $allowPastRequest, pastRequestWindowDays: $pastRequestWindowDays, requiresAttachmentAfterDays: $requiresAttachmentAfterDays, allowNegativeBalance: $allowNegativeBalance, carryForwardEnabled: $carryForwardEnabled, carryForwardLimitDays: $carryForwardLimitDays, applicableEmploymentTypes: $applicableEmploymentTypes, status: $status)';
}


}

/// @nodoc
abstract mixin class _$LeavePolicyDraftCopyWith<$Res> implements $LeavePolicyDraftCopyWith<$Res> {
  factory _$LeavePolicyDraftCopyWith(_LeavePolicyDraft value, $Res Function(_LeavePolicyDraft) _then) = __$LeavePolicyDraftCopyWithImpl;
@override @useResult
$Res call({
 String name, String code, String leaveTypeId, double annualEntitlementDays, bool allowHalfDay, double minimumRequestDays, int? maximumConsecutiveDays, int advanceNoticeDays, bool allowPastRequest, int pastRequestWindowDays, int? requiresAttachmentAfterDays, bool allowNegativeBalance, bool carryForwardEnabled, double? carryForwardLimitDays, Set<EmploymentType> applicableEmploymentTypes, ConfigurationStatus status
});




}
/// @nodoc
class __$LeavePolicyDraftCopyWithImpl<$Res>
    implements _$LeavePolicyDraftCopyWith<$Res> {
  __$LeavePolicyDraftCopyWithImpl(this._self, this._then);

  final _LeavePolicyDraft _self;
  final $Res Function(_LeavePolicyDraft) _then;

/// Create a copy of LeavePolicyDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? code = null,Object? leaveTypeId = null,Object? annualEntitlementDays = null,Object? allowHalfDay = null,Object? minimumRequestDays = null,Object? maximumConsecutiveDays = freezed,Object? advanceNoticeDays = null,Object? allowPastRequest = null,Object? pastRequestWindowDays = null,Object? requiresAttachmentAfterDays = freezed,Object? allowNegativeBalance = null,Object? carryForwardEnabled = null,Object? carryForwardLimitDays = freezed,Object? applicableEmploymentTypes = null,Object? status = null,}) {
  return _then(_LeavePolicyDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,leaveTypeId: null == leaveTypeId ? _self.leaveTypeId : leaveTypeId // ignore: cast_nullable_to_non_nullable
as String,annualEntitlementDays: null == annualEntitlementDays ? _self.annualEntitlementDays : annualEntitlementDays // ignore: cast_nullable_to_non_nullable
as double,allowHalfDay: null == allowHalfDay ? _self.allowHalfDay : allowHalfDay // ignore: cast_nullable_to_non_nullable
as bool,minimumRequestDays: null == minimumRequestDays ? _self.minimumRequestDays : minimumRequestDays // ignore: cast_nullable_to_non_nullable
as double,maximumConsecutiveDays: freezed == maximumConsecutiveDays ? _self.maximumConsecutiveDays : maximumConsecutiveDays // ignore: cast_nullable_to_non_nullable
as int?,advanceNoticeDays: null == advanceNoticeDays ? _self.advanceNoticeDays : advanceNoticeDays // ignore: cast_nullable_to_non_nullable
as int,allowPastRequest: null == allowPastRequest ? _self.allowPastRequest : allowPastRequest // ignore: cast_nullable_to_non_nullable
as bool,pastRequestWindowDays: null == pastRequestWindowDays ? _self.pastRequestWindowDays : pastRequestWindowDays // ignore: cast_nullable_to_non_nullable
as int,requiresAttachmentAfterDays: freezed == requiresAttachmentAfterDays ? _self.requiresAttachmentAfterDays : requiresAttachmentAfterDays // ignore: cast_nullable_to_non_nullable
as int?,allowNegativeBalance: null == allowNegativeBalance ? _self.allowNegativeBalance : allowNegativeBalance // ignore: cast_nullable_to_non_nullable
as bool,carryForwardEnabled: null == carryForwardEnabled ? _self.carryForwardEnabled : carryForwardEnabled // ignore: cast_nullable_to_non_nullable
as bool,carryForwardLimitDays: freezed == carryForwardLimitDays ? _self.carryForwardLimitDays : carryForwardLimitDays // ignore: cast_nullable_to_non_nullable
as double?,applicableEmploymentTypes: null == applicableEmploymentTypes ? _self._applicableEmploymentTypes : applicableEmploymentTypes // ignore: cast_nullable_to_non_nullable
as Set<EmploymentType>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,
  ));
}


}

/// @nodoc
mixin _$HolidayDraft {

 String get name; DateTime? get date; DateTime? get endDate; HolidayType get type; HolidayScope get scope; Set<String> get workLocationIds; String get description; bool get isOptional; HolidaySource get source; String? get calendarId; String? get countryCode; String? get regionCode; ConfigurationStatus get status;
/// Create a copy of HolidayDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HolidayDraftCopyWith<HolidayDraft> get copyWith => _$HolidayDraftCopyWithImpl<HolidayDraft>(this as HolidayDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HolidayDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.date, date) || other.date == date)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.type, type) || other.type == type)&&(identical(other.scope, scope) || other.scope == scope)&&const DeepCollectionEquality().equals(other.workLocationIds, workLocationIds)&&(identical(other.description, description) || other.description == description)&&(identical(other.isOptional, isOptional) || other.isOptional == isOptional)&&(identical(other.source, source) || other.source == source)&&(identical(other.calendarId, calendarId) || other.calendarId == calendarId)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.regionCode, regionCode) || other.regionCode == regionCode)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,name,date,endDate,type,scope,const DeepCollectionEquality().hash(workLocationIds),description,isOptional,source,calendarId,countryCode,regionCode,status);

@override
String toString() {
  return 'HolidayDraft(name: $name, date: $date, endDate: $endDate, type: $type, scope: $scope, workLocationIds: $workLocationIds, description: $description, isOptional: $isOptional, source: $source, calendarId: $calendarId, countryCode: $countryCode, regionCode: $regionCode, status: $status)';
}


}

/// @nodoc
abstract mixin class $HolidayDraftCopyWith<$Res>  {
  factory $HolidayDraftCopyWith(HolidayDraft value, $Res Function(HolidayDraft) _then) = _$HolidayDraftCopyWithImpl;
@useResult
$Res call({
 String name, DateTime? date, DateTime? endDate, HolidayType type, HolidayScope scope, Set<String> workLocationIds, String description, bool isOptional, HolidaySource source, String? calendarId, String? countryCode, String? regionCode, ConfigurationStatus status
});




}
/// @nodoc
class _$HolidayDraftCopyWithImpl<$Res>
    implements $HolidayDraftCopyWith<$Res> {
  _$HolidayDraftCopyWithImpl(this._self, this._then);

  final HolidayDraft _self;
  final $Res Function(HolidayDraft) _then;

/// Create a copy of HolidayDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? date = freezed,Object? endDate = freezed,Object? type = null,Object? scope = null,Object? workLocationIds = null,Object? description = null,Object? isOptional = null,Object? source = null,Object? calendarId = freezed,Object? countryCode = freezed,Object? regionCode = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as HolidayType,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as HolidayScope,workLocationIds: null == workLocationIds ? _self.workLocationIds : workLocationIds // ignore: cast_nullable_to_non_nullable
as Set<String>,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isOptional: null == isOptional ? _self.isOptional : isOptional // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as HolidaySource,calendarId: freezed == calendarId ? _self.calendarId : calendarId // ignore: cast_nullable_to_non_nullable
as String?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,regionCode: freezed == regionCode ? _self.regionCode : regionCode // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [HolidayDraft].
extension HolidayDraftPatterns on HolidayDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HolidayDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HolidayDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HolidayDraft value)  $default,){
final _that = this;
switch (_that) {
case _HolidayDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HolidayDraft value)?  $default,){
final _that = this;
switch (_that) {
case _HolidayDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  DateTime? date,  DateTime? endDate,  HolidayType type,  HolidayScope scope,  Set<String> workLocationIds,  String description,  bool isOptional,  HolidaySource source,  String? calendarId,  String? countryCode,  String? regionCode,  ConfigurationStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HolidayDraft() when $default != null:
return $default(_that.name,_that.date,_that.endDate,_that.type,_that.scope,_that.workLocationIds,_that.description,_that.isOptional,_that.source,_that.calendarId,_that.countryCode,_that.regionCode,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  DateTime? date,  DateTime? endDate,  HolidayType type,  HolidayScope scope,  Set<String> workLocationIds,  String description,  bool isOptional,  HolidaySource source,  String? calendarId,  String? countryCode,  String? regionCode,  ConfigurationStatus status)  $default,) {final _that = this;
switch (_that) {
case _HolidayDraft():
return $default(_that.name,_that.date,_that.endDate,_that.type,_that.scope,_that.workLocationIds,_that.description,_that.isOptional,_that.source,_that.calendarId,_that.countryCode,_that.regionCode,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  DateTime? date,  DateTime? endDate,  HolidayType type,  HolidayScope scope,  Set<String> workLocationIds,  String description,  bool isOptional,  HolidaySource source,  String? calendarId,  String? countryCode,  String? regionCode,  ConfigurationStatus status)?  $default,) {final _that = this;
switch (_that) {
case _HolidayDraft() when $default != null:
return $default(_that.name,_that.date,_that.endDate,_that.type,_that.scope,_that.workLocationIds,_that.description,_that.isOptional,_that.source,_that.calendarId,_that.countryCode,_that.regionCode,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _HolidayDraft extends HolidayDraft {
  const _HolidayDraft({this.name = '', this.date, this.endDate, this.type = HolidayType.companyHoliday, this.scope = HolidayScope.companyWide, final  Set<String> workLocationIds = const <String>{}, this.description = '', this.isOptional = false, this.source = HolidaySource.manual, this.calendarId, this.countryCode, this.regionCode, this.status = ConfigurationStatus.active}): _workLocationIds = workLocationIds,super._();
  

@override@JsonKey() final  String name;
@override final  DateTime? date;
@override final  DateTime? endDate;
@override@JsonKey() final  HolidayType type;
@override@JsonKey() final  HolidayScope scope;
 final  Set<String> _workLocationIds;
@override@JsonKey() Set<String> get workLocationIds {
  if (_workLocationIds is EqualUnmodifiableSetView) return _workLocationIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_workLocationIds);
}

@override@JsonKey() final  String description;
@override@JsonKey() final  bool isOptional;
@override@JsonKey() final  HolidaySource source;
@override final  String? calendarId;
@override final  String? countryCode;
@override final  String? regionCode;
@override@JsonKey() final  ConfigurationStatus status;

/// Create a copy of HolidayDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HolidayDraftCopyWith<_HolidayDraft> get copyWith => __$HolidayDraftCopyWithImpl<_HolidayDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HolidayDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.date, date) || other.date == date)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.type, type) || other.type == type)&&(identical(other.scope, scope) || other.scope == scope)&&const DeepCollectionEquality().equals(other._workLocationIds, _workLocationIds)&&(identical(other.description, description) || other.description == description)&&(identical(other.isOptional, isOptional) || other.isOptional == isOptional)&&(identical(other.source, source) || other.source == source)&&(identical(other.calendarId, calendarId) || other.calendarId == calendarId)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.regionCode, regionCode) || other.regionCode == regionCode)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,name,date,endDate,type,scope,const DeepCollectionEquality().hash(_workLocationIds),description,isOptional,source,calendarId,countryCode,regionCode,status);

@override
String toString() {
  return 'HolidayDraft(name: $name, date: $date, endDate: $endDate, type: $type, scope: $scope, workLocationIds: $workLocationIds, description: $description, isOptional: $isOptional, source: $source, calendarId: $calendarId, countryCode: $countryCode, regionCode: $regionCode, status: $status)';
}


}

/// @nodoc
abstract mixin class _$HolidayDraftCopyWith<$Res> implements $HolidayDraftCopyWith<$Res> {
  factory _$HolidayDraftCopyWith(_HolidayDraft value, $Res Function(_HolidayDraft) _then) = __$HolidayDraftCopyWithImpl;
@override @useResult
$Res call({
 String name, DateTime? date, DateTime? endDate, HolidayType type, HolidayScope scope, Set<String> workLocationIds, String description, bool isOptional, HolidaySource source, String? calendarId, String? countryCode, String? regionCode, ConfigurationStatus status
});




}
/// @nodoc
class __$HolidayDraftCopyWithImpl<$Res>
    implements _$HolidayDraftCopyWith<$Res> {
  __$HolidayDraftCopyWithImpl(this._self, this._then);

  final _HolidayDraft _self;
  final $Res Function(_HolidayDraft) _then;

/// Create a copy of HolidayDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? date = freezed,Object? endDate = freezed,Object? type = null,Object? scope = null,Object? workLocationIds = null,Object? description = null,Object? isOptional = null,Object? source = null,Object? calendarId = freezed,Object? countryCode = freezed,Object? regionCode = freezed,Object? status = null,}) {
  return _then(_HolidayDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as HolidayType,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as HolidayScope,workLocationIds: null == workLocationIds ? _self._workLocationIds : workLocationIds // ignore: cast_nullable_to_non_nullable
as Set<String>,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isOptional: null == isOptional ? _self.isOptional : isOptional // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as HolidaySource,calendarId: freezed == calendarId ? _self.calendarId : calendarId // ignore: cast_nullable_to_non_nullable
as String?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,regionCode: freezed == regionCode ? _self.regionCode : regionCode // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfigurationStatus,
  ));
}


}

// dart format on
