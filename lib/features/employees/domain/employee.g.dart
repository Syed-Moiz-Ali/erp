// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Employee _$EmployeeFromJson(Map<String, dynamic> json) => _Employee(
  id: json['id'] as String,
  companyId: json['companyId'] as String,
  employeeCode: json['employeeCode'] as String,
  firstName: json['firstName'] as String,
  middleName: json['middleName'] as String? ?? '',
  lastName: json['lastName'] as String? ?? '',
  email: json['email'] as String,
  phone: json['phone'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  departmentId: json['departmentId'] as String,
  designationId: json['designationId'] as String,
  managerId: json['managerId'] as String?,
  joiningDate: DateTime.parse(json['joiningDate'] as String),
  employmentType:
      $enumDecodeNullable(_$EmploymentTypeEnumMap, json['employmentType']) ??
      EmploymentType.fullTime,
  status:
      $enumDecodeNullable(_$EmploymentStatusEnumMap, json['status']) ??
      EmploymentStatus.active,
  shiftId: json['shiftId'] as String?,
  workLocationId: json['workLocationId'] as String?,
  attendancePolicyId: json['attendancePolicyId'] as String?,
  linkedUserId: json['linkedUserId'] as String?,
  loginEnabled: json['loginEnabled'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus:
      $enumDecodeNullable(_$EmployeeSyncStatusEnumMap, json['syncStatus']) ??
      EmployeeSyncStatus.pending,
);

Map<String, dynamic> _$EmployeeToJson(_Employee instance) => <String, dynamic>{
  'id': instance.id,
  'companyId': instance.companyId,
  'employeeCode': instance.employeeCode,
  'firstName': instance.firstName,
  'middleName': instance.middleName,
  'lastName': instance.lastName,
  'email': instance.email,
  'phone': instance.phone,
  'avatarUrl': instance.avatarUrl,
  'departmentId': instance.departmentId,
  'designationId': instance.designationId,
  'managerId': instance.managerId,
  'joiningDate': instance.joiningDate.toIso8601String(),
  'employmentType': _$EmploymentTypeEnumMap[instance.employmentType]!,
  'status': _$EmploymentStatusEnumMap[instance.status]!,
  'shiftId': instance.shiftId,
  'workLocationId': instance.workLocationId,
  'attendancePolicyId': instance.attendancePolicyId,
  'linkedUserId': instance.linkedUserId,
  'loginEnabled': instance.loginEnabled,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'syncStatus': _$EmployeeSyncStatusEnumMap[instance.syncStatus]!,
};

const _$EmploymentTypeEnumMap = {
  EmploymentType.fullTime: 'fullTime',
  EmploymentType.partTime: 'partTime',
  EmploymentType.contract: 'contract',
  EmploymentType.intern: 'intern',
  EmploymentType.temporary: 'temporary',
};

const _$EmploymentStatusEnumMap = {
  EmploymentStatus.active: 'active',
  EmploymentStatus.inactive: 'inactive',
};

const _$EmployeeSyncStatusEnumMap = {
  EmployeeSyncStatus.synced: 'synced',
  EmployeeSyncStatus.pending: 'pending',
  EmployeeSyncStatus.failed: 'failed',
};
