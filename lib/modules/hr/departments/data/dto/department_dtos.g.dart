// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DepartmentDto _$DepartmentDtoFromJson(Map<String, dynamic> json) =>
    _DepartmentDto(
      departmentId: (json['departmentId'] as num).toInt(),
      departmentName: json['departmentName'] as String,
      employeeCount: (json['employeeCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DepartmentDtoToJson(_DepartmentDto instance) =>
    <String, dynamic>{
      'departmentId': instance.departmentId,
      'departmentName': instance.departmentName,
      'employeeCount': instance.employeeCount,
    };

_DepartmentUpsertDto _$DepartmentUpsertDtoFromJson(Map<String, dynamic> json) =>
    _DepartmentUpsertDto(departmentName: json['departmentName'] as String);

Map<String, dynamic> _$DepartmentUpsertDtoToJson(
  _DepartmentUpsertDto instance,
) => <String, dynamic>{'departmentName': instance.departmentName};
