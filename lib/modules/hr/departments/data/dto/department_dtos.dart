import 'package:freezed_annotation/freezed_annotation.dart';

part 'department_dtos.freezed.dart';
part 'department_dtos.g.dart';

/// Wire DTO for a department as returned by the MassERP API.
///
/// Transport-only: never exposed to presentation. [departmentId] is the backend
/// integer identity; [employeeCount] drives the deactivate guard.
@freezed
abstract class DepartmentDto with _$DepartmentDto {
  const factory DepartmentDto({
    required int departmentId,
    required String departmentName,
    @Default(0) int employeeCount,
  }) = _DepartmentDto;

  factory DepartmentDto.fromJson(Map<String, dynamic> json) =>
      _$DepartmentDtoFromJson(json);
}

/// Request body for create (`POST`) and rename (`PUT`).
@freezed
abstract class DepartmentUpsertDto with _$DepartmentUpsertDto {
  const factory DepartmentUpsertDto({required String departmentName}) =
      _DepartmentUpsertDto;

  factory DepartmentUpsertDto.fromJson(Map<String, dynamic> json) =>
      _$DepartmentUpsertDtoFromJson(json);
}
