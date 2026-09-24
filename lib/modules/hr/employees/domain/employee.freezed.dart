// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employee.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Employee {

 String get id; String get companyId; String get employeeCode; String get firstName; String get middleName; String get lastName; String get email; String get phone; String? get avatarUrl; String get departmentId; String get designationId; String? get managerId; DateTime get joiningDate; EmploymentType get employmentType; EmploymentStatus get status; String? get shiftId; String? get workLocationId; String? get attendancePolicyId; String? get linkedUserId; bool get loginEnabled; DateTime get createdAt; DateTime get updatedAt; EmployeeSyncStatus get syncStatus;
/// Create a copy of Employee
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmployeeCopyWith<Employee> get copyWith => _$EmployeeCopyWithImpl<Employee>(this as Employee, _$identity);

  /// Serializes this Employee to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Employee&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.employeeCode, employeeCode) || other.employeeCode == employeeCode)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.departmentId, departmentId) || other.departmentId == departmentId)&&(identical(other.designationId, designationId) || other.designationId == designationId)&&(identical(other.managerId, managerId) || other.managerId == managerId)&&(identical(other.joiningDate, joiningDate) || other.joiningDate == joiningDate)&&(identical(other.employmentType, employmentType) || other.employmentType == employmentType)&&(identical(other.status, status) || other.status == status)&&(identical(other.shiftId, shiftId) || other.shiftId == shiftId)&&(identical(other.workLocationId, workLocationId) || other.workLocationId == workLocationId)&&(identical(other.attendancePolicyId, attendancePolicyId) || other.attendancePolicyId == attendancePolicyId)&&(identical(other.linkedUserId, linkedUserId) || other.linkedUserId == linkedUserId)&&(identical(other.loginEnabled, loginEnabled) || other.loginEnabled == loginEnabled)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,employeeCode,firstName,middleName,lastName,email,phone,avatarUrl,departmentId,designationId,managerId,joiningDate,employmentType,status,shiftId,workLocationId,attendancePolicyId,linkedUserId,loginEnabled,createdAt,updatedAt,syncStatus]);

@override
String toString() {
  return 'Employee(id: $id, companyId: $companyId, employeeCode: $employeeCode, firstName: $firstName, middleName: $middleName, lastName: $lastName, email: $email, phone: $phone, avatarUrl: $avatarUrl, departmentId: $departmentId, designationId: $designationId, managerId: $managerId, joiningDate: $joiningDate, employmentType: $employmentType, status: $status, shiftId: $shiftId, workLocationId: $workLocationId, attendancePolicyId: $attendancePolicyId, linkedUserId: $linkedUserId, loginEnabled: $loginEnabled, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $EmployeeCopyWith<$Res>  {
  factory $EmployeeCopyWith(Employee value, $Res Function(Employee) _then) = _$EmployeeCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String employeeCode, String firstName, String middleName, String lastName, String email, String phone, String? avatarUrl, String departmentId, String designationId, String? managerId, DateTime joiningDate, EmploymentType employmentType, EmploymentStatus status, String? shiftId, String? workLocationId, String? attendancePolicyId, String? linkedUserId, bool loginEnabled, DateTime createdAt, DateTime updatedAt, EmployeeSyncStatus syncStatus
});




}
/// @nodoc
class _$EmployeeCopyWithImpl<$Res>
    implements $EmployeeCopyWith<$Res> {
  _$EmployeeCopyWithImpl(this._self, this._then);

  final Employee _self;
  final $Res Function(Employee) _then;

/// Create a copy of Employee
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? employeeCode = null,Object? firstName = null,Object? middleName = null,Object? lastName = null,Object? email = null,Object? phone = null,Object? avatarUrl = freezed,Object? departmentId = null,Object? designationId = null,Object? managerId = freezed,Object? joiningDate = null,Object? employmentType = null,Object? status = null,Object? shiftId = freezed,Object? workLocationId = freezed,Object? attendancePolicyId = freezed,Object? linkedUserId = freezed,Object? loginEnabled = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,employeeCode: null == employeeCode ? _self.employeeCode : employeeCode // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,middleName: null == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,departmentId: null == departmentId ? _self.departmentId : departmentId // ignore: cast_nullable_to_non_nullable
as String,designationId: null == designationId ? _self.designationId : designationId // ignore: cast_nullable_to_non_nullable
as String,managerId: freezed == managerId ? _self.managerId : managerId // ignore: cast_nullable_to_non_nullable
as String?,joiningDate: null == joiningDate ? _self.joiningDate : joiningDate // ignore: cast_nullable_to_non_nullable
as DateTime,employmentType: null == employmentType ? _self.employmentType : employmentType // ignore: cast_nullable_to_non_nullable
as EmploymentType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EmploymentStatus,shiftId: freezed == shiftId ? _self.shiftId : shiftId // ignore: cast_nullable_to_non_nullable
as String?,workLocationId: freezed == workLocationId ? _self.workLocationId : workLocationId // ignore: cast_nullable_to_non_nullable
as String?,attendancePolicyId: freezed == attendancePolicyId ? _self.attendancePolicyId : attendancePolicyId // ignore: cast_nullable_to_non_nullable
as String?,linkedUserId: freezed == linkedUserId ? _self.linkedUserId : linkedUserId // ignore: cast_nullable_to_non_nullable
as String?,loginEnabled: null == loginEnabled ? _self.loginEnabled : loginEnabled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as EmployeeSyncStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Employee].
extension EmployeePatterns on Employee {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Employee value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Employee() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Employee value)  $default,){
final _that = this;
switch (_that) {
case _Employee():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Employee value)?  $default,){
final _that = this;
switch (_that) {
case _Employee() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String employeeCode,  String firstName,  String middleName,  String lastName,  String email,  String phone,  String? avatarUrl,  String departmentId,  String designationId,  String? managerId,  DateTime joiningDate,  EmploymentType employmentType,  EmploymentStatus status,  String? shiftId,  String? workLocationId,  String? attendancePolicyId,  String? linkedUserId,  bool loginEnabled,  DateTime createdAt,  DateTime updatedAt,  EmployeeSyncStatus syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Employee() when $default != null:
return $default(_that.id,_that.companyId,_that.employeeCode,_that.firstName,_that.middleName,_that.lastName,_that.email,_that.phone,_that.avatarUrl,_that.departmentId,_that.designationId,_that.managerId,_that.joiningDate,_that.employmentType,_that.status,_that.shiftId,_that.workLocationId,_that.attendancePolicyId,_that.linkedUserId,_that.loginEnabled,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String employeeCode,  String firstName,  String middleName,  String lastName,  String email,  String phone,  String? avatarUrl,  String departmentId,  String designationId,  String? managerId,  DateTime joiningDate,  EmploymentType employmentType,  EmploymentStatus status,  String? shiftId,  String? workLocationId,  String? attendancePolicyId,  String? linkedUserId,  bool loginEnabled,  DateTime createdAt,  DateTime updatedAt,  EmployeeSyncStatus syncStatus)  $default,) {final _that = this;
switch (_that) {
case _Employee():
return $default(_that.id,_that.companyId,_that.employeeCode,_that.firstName,_that.middleName,_that.lastName,_that.email,_that.phone,_that.avatarUrl,_that.departmentId,_that.designationId,_that.managerId,_that.joiningDate,_that.employmentType,_that.status,_that.shiftId,_that.workLocationId,_that.attendancePolicyId,_that.linkedUserId,_that.loginEnabled,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String employeeCode,  String firstName,  String middleName,  String lastName,  String email,  String phone,  String? avatarUrl,  String departmentId,  String designationId,  String? managerId,  DateTime joiningDate,  EmploymentType employmentType,  EmploymentStatus status,  String? shiftId,  String? workLocationId,  String? attendancePolicyId,  String? linkedUserId,  bool loginEnabled,  DateTime createdAt,  DateTime updatedAt,  EmployeeSyncStatus syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _Employee() when $default != null:
return $default(_that.id,_that.companyId,_that.employeeCode,_that.firstName,_that.middleName,_that.lastName,_that.email,_that.phone,_that.avatarUrl,_that.departmentId,_that.designationId,_that.managerId,_that.joiningDate,_that.employmentType,_that.status,_that.shiftId,_that.workLocationId,_that.attendancePolicyId,_that.linkedUserId,_that.loginEnabled,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Employee extends Employee {
  const _Employee({required this.id, required this.companyId, required this.employeeCode, required this.firstName, this.middleName = '', this.lastName = '', required this.email, required this.phone, this.avatarUrl, required this.departmentId, required this.designationId, this.managerId, required this.joiningDate, this.employmentType = EmploymentType.fullTime, this.status = EmploymentStatus.active, this.shiftId, this.workLocationId, this.attendancePolicyId, this.linkedUserId, this.loginEnabled = false, required this.createdAt, required this.updatedAt, this.syncStatus = EmployeeSyncStatus.pending}): super._();
  factory _Employee.fromJson(Map<String, dynamic> json) => _$EmployeeFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  String employeeCode;
@override final  String firstName;
@override@JsonKey() final  String middleName;
@override@JsonKey() final  String lastName;
@override final  String email;
@override final  String phone;
@override final  String? avatarUrl;
@override final  String departmentId;
@override final  String designationId;
@override final  String? managerId;
@override final  DateTime joiningDate;
@override@JsonKey() final  EmploymentType employmentType;
@override@JsonKey() final  EmploymentStatus status;
@override final  String? shiftId;
@override final  String? workLocationId;
@override final  String? attendancePolicyId;
@override final  String? linkedUserId;
@override@JsonKey() final  bool loginEnabled;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  EmployeeSyncStatus syncStatus;

/// Create a copy of Employee
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmployeeCopyWith<_Employee> get copyWith => __$EmployeeCopyWithImpl<_Employee>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmployeeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Employee&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.employeeCode, employeeCode) || other.employeeCode == employeeCode)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.departmentId, departmentId) || other.departmentId == departmentId)&&(identical(other.designationId, designationId) || other.designationId == designationId)&&(identical(other.managerId, managerId) || other.managerId == managerId)&&(identical(other.joiningDate, joiningDate) || other.joiningDate == joiningDate)&&(identical(other.employmentType, employmentType) || other.employmentType == employmentType)&&(identical(other.status, status) || other.status == status)&&(identical(other.shiftId, shiftId) || other.shiftId == shiftId)&&(identical(other.workLocationId, workLocationId) || other.workLocationId == workLocationId)&&(identical(other.attendancePolicyId, attendancePolicyId) || other.attendancePolicyId == attendancePolicyId)&&(identical(other.linkedUserId, linkedUserId) || other.linkedUserId == linkedUserId)&&(identical(other.loginEnabled, loginEnabled) || other.loginEnabled == loginEnabled)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,employeeCode,firstName,middleName,lastName,email,phone,avatarUrl,departmentId,designationId,managerId,joiningDate,employmentType,status,shiftId,workLocationId,attendancePolicyId,linkedUserId,loginEnabled,createdAt,updatedAt,syncStatus]);

@override
String toString() {
  return 'Employee(id: $id, companyId: $companyId, employeeCode: $employeeCode, firstName: $firstName, middleName: $middleName, lastName: $lastName, email: $email, phone: $phone, avatarUrl: $avatarUrl, departmentId: $departmentId, designationId: $designationId, managerId: $managerId, joiningDate: $joiningDate, employmentType: $employmentType, status: $status, shiftId: $shiftId, workLocationId: $workLocationId, attendancePolicyId: $attendancePolicyId, linkedUserId: $linkedUserId, loginEnabled: $loginEnabled, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$EmployeeCopyWith<$Res> implements $EmployeeCopyWith<$Res> {
  factory _$EmployeeCopyWith(_Employee value, $Res Function(_Employee) _then) = __$EmployeeCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String employeeCode, String firstName, String middleName, String lastName, String email, String phone, String? avatarUrl, String departmentId, String designationId, String? managerId, DateTime joiningDate, EmploymentType employmentType, EmploymentStatus status, String? shiftId, String? workLocationId, String? attendancePolicyId, String? linkedUserId, bool loginEnabled, DateTime createdAt, DateTime updatedAt, EmployeeSyncStatus syncStatus
});




}
/// @nodoc
class __$EmployeeCopyWithImpl<$Res>
    implements _$EmployeeCopyWith<$Res> {
  __$EmployeeCopyWithImpl(this._self, this._then);

  final _Employee _self;
  final $Res Function(_Employee) _then;

/// Create a copy of Employee
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? employeeCode = null,Object? firstName = null,Object? middleName = null,Object? lastName = null,Object? email = null,Object? phone = null,Object? avatarUrl = freezed,Object? departmentId = null,Object? designationId = null,Object? managerId = freezed,Object? joiningDate = null,Object? employmentType = null,Object? status = null,Object? shiftId = freezed,Object? workLocationId = freezed,Object? attendancePolicyId = freezed,Object? linkedUserId = freezed,Object? loginEnabled = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,}) {
  return _then(_Employee(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,employeeCode: null == employeeCode ? _self.employeeCode : employeeCode // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,middleName: null == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,departmentId: null == departmentId ? _self.departmentId : departmentId // ignore: cast_nullable_to_non_nullable
as String,designationId: null == designationId ? _self.designationId : designationId // ignore: cast_nullable_to_non_nullable
as String,managerId: freezed == managerId ? _self.managerId : managerId // ignore: cast_nullable_to_non_nullable
as String?,joiningDate: null == joiningDate ? _self.joiningDate : joiningDate // ignore: cast_nullable_to_non_nullable
as DateTime,employmentType: null == employmentType ? _self.employmentType : employmentType // ignore: cast_nullable_to_non_nullable
as EmploymentType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EmploymentStatus,shiftId: freezed == shiftId ? _self.shiftId : shiftId // ignore: cast_nullable_to_non_nullable
as String?,workLocationId: freezed == workLocationId ? _self.workLocationId : workLocationId // ignore: cast_nullable_to_non_nullable
as String?,attendancePolicyId: freezed == attendancePolicyId ? _self.attendancePolicyId : attendancePolicyId // ignore: cast_nullable_to_non_nullable
as String?,linkedUserId: freezed == linkedUserId ? _self.linkedUserId : linkedUserId // ignore: cast_nullable_to_non_nullable
as String?,loginEnabled: null == loginEnabled ? _self.loginEnabled : loginEnabled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as EmployeeSyncStatus,
  ));
}


}

/// @nodoc
mixin _$EmployeeDraft {

 String get firstName; String get middleName; String get lastName; String get email; String get phone; String? get departmentId; String? get designationId; String? get managerId; String? get shiftId; String? get workLocationId; String? get attendancePolicyId; DateTime? get joiningDate; EmploymentType get employmentType; EmploymentStatus get status; bool get loginEnabled;
/// Create a copy of EmployeeDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmployeeDraftCopyWith<EmployeeDraft> get copyWith => _$EmployeeDraftCopyWithImpl<EmployeeDraft>(this as EmployeeDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmployeeDraft&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.departmentId, departmentId) || other.departmentId == departmentId)&&(identical(other.designationId, designationId) || other.designationId == designationId)&&(identical(other.managerId, managerId) || other.managerId == managerId)&&(identical(other.shiftId, shiftId) || other.shiftId == shiftId)&&(identical(other.workLocationId, workLocationId) || other.workLocationId == workLocationId)&&(identical(other.attendancePolicyId, attendancePolicyId) || other.attendancePolicyId == attendancePolicyId)&&(identical(other.joiningDate, joiningDate) || other.joiningDate == joiningDate)&&(identical(other.employmentType, employmentType) || other.employmentType == employmentType)&&(identical(other.status, status) || other.status == status)&&(identical(other.loginEnabled, loginEnabled) || other.loginEnabled == loginEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,firstName,middleName,lastName,email,phone,departmentId,designationId,managerId,shiftId,workLocationId,attendancePolicyId,joiningDate,employmentType,status,loginEnabled);

@override
String toString() {
  return 'EmployeeDraft(firstName: $firstName, middleName: $middleName, lastName: $lastName, email: $email, phone: $phone, departmentId: $departmentId, designationId: $designationId, managerId: $managerId, shiftId: $shiftId, workLocationId: $workLocationId, attendancePolicyId: $attendancePolicyId, joiningDate: $joiningDate, employmentType: $employmentType, status: $status, loginEnabled: $loginEnabled)';
}


}

/// @nodoc
abstract mixin class $EmployeeDraftCopyWith<$Res>  {
  factory $EmployeeDraftCopyWith(EmployeeDraft value, $Res Function(EmployeeDraft) _then) = _$EmployeeDraftCopyWithImpl;
@useResult
$Res call({
 String firstName, String middleName, String lastName, String email, String phone, String? departmentId, String? designationId, String? managerId, String? shiftId, String? workLocationId, String? attendancePolicyId, DateTime? joiningDate, EmploymentType employmentType, EmploymentStatus status, bool loginEnabled
});




}
/// @nodoc
class _$EmployeeDraftCopyWithImpl<$Res>
    implements $EmployeeDraftCopyWith<$Res> {
  _$EmployeeDraftCopyWithImpl(this._self, this._then);

  final EmployeeDraft _self;
  final $Res Function(EmployeeDraft) _then;

/// Create a copy of EmployeeDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? firstName = null,Object? middleName = null,Object? lastName = null,Object? email = null,Object? phone = null,Object? departmentId = freezed,Object? designationId = freezed,Object? managerId = freezed,Object? shiftId = freezed,Object? workLocationId = freezed,Object? attendancePolicyId = freezed,Object? joiningDate = freezed,Object? employmentType = null,Object? status = null,Object? loginEnabled = null,}) {
  return _then(_self.copyWith(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,middleName: null == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,departmentId: freezed == departmentId ? _self.departmentId : departmentId // ignore: cast_nullable_to_non_nullable
as String?,designationId: freezed == designationId ? _self.designationId : designationId // ignore: cast_nullable_to_non_nullable
as String?,managerId: freezed == managerId ? _self.managerId : managerId // ignore: cast_nullable_to_non_nullable
as String?,shiftId: freezed == shiftId ? _self.shiftId : shiftId // ignore: cast_nullable_to_non_nullable
as String?,workLocationId: freezed == workLocationId ? _self.workLocationId : workLocationId // ignore: cast_nullable_to_non_nullable
as String?,attendancePolicyId: freezed == attendancePolicyId ? _self.attendancePolicyId : attendancePolicyId // ignore: cast_nullable_to_non_nullable
as String?,joiningDate: freezed == joiningDate ? _self.joiningDate : joiningDate // ignore: cast_nullable_to_non_nullable
as DateTime?,employmentType: null == employmentType ? _self.employmentType : employmentType // ignore: cast_nullable_to_non_nullable
as EmploymentType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EmploymentStatus,loginEnabled: null == loginEnabled ? _self.loginEnabled : loginEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EmployeeDraft].
extension EmployeeDraftPatterns on EmployeeDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmployeeDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmployeeDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmployeeDraft value)  $default,){
final _that = this;
switch (_that) {
case _EmployeeDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmployeeDraft value)?  $default,){
final _that = this;
switch (_that) {
case _EmployeeDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String firstName,  String middleName,  String lastName,  String email,  String phone,  String? departmentId,  String? designationId,  String? managerId,  String? shiftId,  String? workLocationId,  String? attendancePolicyId,  DateTime? joiningDate,  EmploymentType employmentType,  EmploymentStatus status,  bool loginEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmployeeDraft() when $default != null:
return $default(_that.firstName,_that.middleName,_that.lastName,_that.email,_that.phone,_that.departmentId,_that.designationId,_that.managerId,_that.shiftId,_that.workLocationId,_that.attendancePolicyId,_that.joiningDate,_that.employmentType,_that.status,_that.loginEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String firstName,  String middleName,  String lastName,  String email,  String phone,  String? departmentId,  String? designationId,  String? managerId,  String? shiftId,  String? workLocationId,  String? attendancePolicyId,  DateTime? joiningDate,  EmploymentType employmentType,  EmploymentStatus status,  bool loginEnabled)  $default,) {final _that = this;
switch (_that) {
case _EmployeeDraft():
return $default(_that.firstName,_that.middleName,_that.lastName,_that.email,_that.phone,_that.departmentId,_that.designationId,_that.managerId,_that.shiftId,_that.workLocationId,_that.attendancePolicyId,_that.joiningDate,_that.employmentType,_that.status,_that.loginEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String firstName,  String middleName,  String lastName,  String email,  String phone,  String? departmentId,  String? designationId,  String? managerId,  String? shiftId,  String? workLocationId,  String? attendancePolicyId,  DateTime? joiningDate,  EmploymentType employmentType,  EmploymentStatus status,  bool loginEnabled)?  $default,) {final _that = this;
switch (_that) {
case _EmployeeDraft() when $default != null:
return $default(_that.firstName,_that.middleName,_that.lastName,_that.email,_that.phone,_that.departmentId,_that.designationId,_that.managerId,_that.shiftId,_that.workLocationId,_that.attendancePolicyId,_that.joiningDate,_that.employmentType,_that.status,_that.loginEnabled);case _:
  return null;

}
}

}

/// @nodoc


class _EmployeeDraft implements EmployeeDraft {
  const _EmployeeDraft({this.firstName = '', this.middleName = '', this.lastName = '', this.email = '', this.phone = '', this.departmentId, this.designationId, this.managerId, this.shiftId, this.workLocationId, this.attendancePolicyId, this.joiningDate, this.employmentType = EmploymentType.fullTime, this.status = EmploymentStatus.active, this.loginEnabled = false});
  

@override@JsonKey() final  String firstName;
@override@JsonKey() final  String middleName;
@override@JsonKey() final  String lastName;
@override@JsonKey() final  String email;
@override@JsonKey() final  String phone;
@override final  String? departmentId;
@override final  String? designationId;
@override final  String? managerId;
@override final  String? shiftId;
@override final  String? workLocationId;
@override final  String? attendancePolicyId;
@override final  DateTime? joiningDate;
@override@JsonKey() final  EmploymentType employmentType;
@override@JsonKey() final  EmploymentStatus status;
@override@JsonKey() final  bool loginEnabled;

/// Create a copy of EmployeeDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmployeeDraftCopyWith<_EmployeeDraft> get copyWith => __$EmployeeDraftCopyWithImpl<_EmployeeDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmployeeDraft&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.departmentId, departmentId) || other.departmentId == departmentId)&&(identical(other.designationId, designationId) || other.designationId == designationId)&&(identical(other.managerId, managerId) || other.managerId == managerId)&&(identical(other.shiftId, shiftId) || other.shiftId == shiftId)&&(identical(other.workLocationId, workLocationId) || other.workLocationId == workLocationId)&&(identical(other.attendancePolicyId, attendancePolicyId) || other.attendancePolicyId == attendancePolicyId)&&(identical(other.joiningDate, joiningDate) || other.joiningDate == joiningDate)&&(identical(other.employmentType, employmentType) || other.employmentType == employmentType)&&(identical(other.status, status) || other.status == status)&&(identical(other.loginEnabled, loginEnabled) || other.loginEnabled == loginEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,firstName,middleName,lastName,email,phone,departmentId,designationId,managerId,shiftId,workLocationId,attendancePolicyId,joiningDate,employmentType,status,loginEnabled);

@override
String toString() {
  return 'EmployeeDraft(firstName: $firstName, middleName: $middleName, lastName: $lastName, email: $email, phone: $phone, departmentId: $departmentId, designationId: $designationId, managerId: $managerId, shiftId: $shiftId, workLocationId: $workLocationId, attendancePolicyId: $attendancePolicyId, joiningDate: $joiningDate, employmentType: $employmentType, status: $status, loginEnabled: $loginEnabled)';
}


}

/// @nodoc
abstract mixin class _$EmployeeDraftCopyWith<$Res> implements $EmployeeDraftCopyWith<$Res> {
  factory _$EmployeeDraftCopyWith(_EmployeeDraft value, $Res Function(_EmployeeDraft) _then) = __$EmployeeDraftCopyWithImpl;
@override @useResult
$Res call({
 String firstName, String middleName, String lastName, String email, String phone, String? departmentId, String? designationId, String? managerId, String? shiftId, String? workLocationId, String? attendancePolicyId, DateTime? joiningDate, EmploymentType employmentType, EmploymentStatus status, bool loginEnabled
});




}
/// @nodoc
class __$EmployeeDraftCopyWithImpl<$Res>
    implements _$EmployeeDraftCopyWith<$Res> {
  __$EmployeeDraftCopyWithImpl(this._self, this._then);

  final _EmployeeDraft _self;
  final $Res Function(_EmployeeDraft) _then;

/// Create a copy of EmployeeDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? firstName = null,Object? middleName = null,Object? lastName = null,Object? email = null,Object? phone = null,Object? departmentId = freezed,Object? designationId = freezed,Object? managerId = freezed,Object? shiftId = freezed,Object? workLocationId = freezed,Object? attendancePolicyId = freezed,Object? joiningDate = freezed,Object? employmentType = null,Object? status = null,Object? loginEnabled = null,}) {
  return _then(_EmployeeDraft(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,middleName: null == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,departmentId: freezed == departmentId ? _self.departmentId : departmentId // ignore: cast_nullable_to_non_nullable
as String?,designationId: freezed == designationId ? _self.designationId : designationId // ignore: cast_nullable_to_non_nullable
as String?,managerId: freezed == managerId ? _self.managerId : managerId // ignore: cast_nullable_to_non_nullable
as String?,shiftId: freezed == shiftId ? _self.shiftId : shiftId // ignore: cast_nullable_to_non_nullable
as String?,workLocationId: freezed == workLocationId ? _self.workLocationId : workLocationId // ignore: cast_nullable_to_non_nullable
as String?,attendancePolicyId: freezed == attendancePolicyId ? _self.attendancePolicyId : attendancePolicyId // ignore: cast_nullable_to_non_nullable
as String?,joiningDate: freezed == joiningDate ? _self.joiningDate : joiningDate // ignore: cast_nullable_to_non_nullable
as DateTime?,employmentType: null == employmentType ? _self.employmentType : employmentType // ignore: cast_nullable_to_non_nullable
as EmploymentType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EmploymentStatus,loginEnabled: null == loginEnabled ? _self.loginEnabled : loginEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$EmployeeFilter {

 EmploymentStatus? get status; String? get departmentId; String? get designationId; String? get managerId; EmploymentType? get employmentType;
/// Create a copy of EmployeeFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmployeeFilterCopyWith<EmployeeFilter> get copyWith => _$EmployeeFilterCopyWithImpl<EmployeeFilter>(this as EmployeeFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmployeeFilter&&(identical(other.status, status) || other.status == status)&&(identical(other.departmentId, departmentId) || other.departmentId == departmentId)&&(identical(other.designationId, designationId) || other.designationId == designationId)&&(identical(other.managerId, managerId) || other.managerId == managerId)&&(identical(other.employmentType, employmentType) || other.employmentType == employmentType));
}


@override
int get hashCode => Object.hash(runtimeType,status,departmentId,designationId,managerId,employmentType);

@override
String toString() {
  return 'EmployeeFilter(status: $status, departmentId: $departmentId, designationId: $designationId, managerId: $managerId, employmentType: $employmentType)';
}


}

/// @nodoc
abstract mixin class $EmployeeFilterCopyWith<$Res>  {
  factory $EmployeeFilterCopyWith(EmployeeFilter value, $Res Function(EmployeeFilter) _then) = _$EmployeeFilterCopyWithImpl;
@useResult
$Res call({
 EmploymentStatus? status, String? departmentId, String? designationId, String? managerId, EmploymentType? employmentType
});




}
/// @nodoc
class _$EmployeeFilterCopyWithImpl<$Res>
    implements $EmployeeFilterCopyWith<$Res> {
  _$EmployeeFilterCopyWithImpl(this._self, this._then);

  final EmployeeFilter _self;
  final $Res Function(EmployeeFilter) _then;

/// Create a copy of EmployeeFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? departmentId = freezed,Object? designationId = freezed,Object? managerId = freezed,Object? employmentType = freezed,}) {
  return _then(_self.copyWith(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EmploymentStatus?,departmentId: freezed == departmentId ? _self.departmentId : departmentId // ignore: cast_nullable_to_non_nullable
as String?,designationId: freezed == designationId ? _self.designationId : designationId // ignore: cast_nullable_to_non_nullable
as String?,managerId: freezed == managerId ? _self.managerId : managerId // ignore: cast_nullable_to_non_nullable
as String?,employmentType: freezed == employmentType ? _self.employmentType : employmentType // ignore: cast_nullable_to_non_nullable
as EmploymentType?,
  ));
}

}


/// Adds pattern-matching-related methods to [EmployeeFilter].
extension EmployeeFilterPatterns on EmployeeFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmployeeFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmployeeFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmployeeFilter value)  $default,){
final _that = this;
switch (_that) {
case _EmployeeFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmployeeFilter value)?  $default,){
final _that = this;
switch (_that) {
case _EmployeeFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EmploymentStatus? status,  String? departmentId,  String? designationId,  String? managerId,  EmploymentType? employmentType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmployeeFilter() when $default != null:
return $default(_that.status,_that.departmentId,_that.designationId,_that.managerId,_that.employmentType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EmploymentStatus? status,  String? departmentId,  String? designationId,  String? managerId,  EmploymentType? employmentType)  $default,) {final _that = this;
switch (_that) {
case _EmployeeFilter():
return $default(_that.status,_that.departmentId,_that.designationId,_that.managerId,_that.employmentType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EmploymentStatus? status,  String? departmentId,  String? designationId,  String? managerId,  EmploymentType? employmentType)?  $default,) {final _that = this;
switch (_that) {
case _EmployeeFilter() when $default != null:
return $default(_that.status,_that.departmentId,_that.designationId,_that.managerId,_that.employmentType);case _:
  return null;

}
}

}

/// @nodoc


class _EmployeeFilter extends EmployeeFilter {
  const _EmployeeFilter({this.status, this.departmentId, this.designationId, this.managerId, this.employmentType}): super._();
  

@override final  EmploymentStatus? status;
@override final  String? departmentId;
@override final  String? designationId;
@override final  String? managerId;
@override final  EmploymentType? employmentType;

/// Create a copy of EmployeeFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmployeeFilterCopyWith<_EmployeeFilter> get copyWith => __$EmployeeFilterCopyWithImpl<_EmployeeFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmployeeFilter&&(identical(other.status, status) || other.status == status)&&(identical(other.departmentId, departmentId) || other.departmentId == departmentId)&&(identical(other.designationId, designationId) || other.designationId == designationId)&&(identical(other.managerId, managerId) || other.managerId == managerId)&&(identical(other.employmentType, employmentType) || other.employmentType == employmentType));
}


@override
int get hashCode => Object.hash(runtimeType,status,departmentId,designationId,managerId,employmentType);

@override
String toString() {
  return 'EmployeeFilter(status: $status, departmentId: $departmentId, designationId: $designationId, managerId: $managerId, employmentType: $employmentType)';
}


}

/// @nodoc
abstract mixin class _$EmployeeFilterCopyWith<$Res> implements $EmployeeFilterCopyWith<$Res> {
  factory _$EmployeeFilterCopyWith(_EmployeeFilter value, $Res Function(_EmployeeFilter) _then) = __$EmployeeFilterCopyWithImpl;
@override @useResult
$Res call({
 EmploymentStatus? status, String? departmentId, String? designationId, String? managerId, EmploymentType? employmentType
});




}
/// @nodoc
class __$EmployeeFilterCopyWithImpl<$Res>
    implements _$EmployeeFilterCopyWith<$Res> {
  __$EmployeeFilterCopyWithImpl(this._self, this._then);

  final _EmployeeFilter _self;
  final $Res Function(_EmployeeFilter) _then;

/// Create a copy of EmployeeFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? departmentId = freezed,Object? designationId = freezed,Object? managerId = freezed,Object? employmentType = freezed,}) {
  return _then(_EmployeeFilter(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EmploymentStatus?,departmentId: freezed == departmentId ? _self.departmentId : departmentId // ignore: cast_nullable_to_non_nullable
as String?,designationId: freezed == designationId ? _self.designationId : designationId // ignore: cast_nullable_to_non_nullable
as String?,managerId: freezed == managerId ? _self.managerId : managerId // ignore: cast_nullable_to_non_nullable
as String?,employmentType: freezed == employmentType ? _self.employmentType : employmentType // ignore: cast_nullable_to_non_nullable
as EmploymentType?,
  ));
}


}

// dart format on
