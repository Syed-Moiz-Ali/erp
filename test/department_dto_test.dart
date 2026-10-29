import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/modules/hr/departments/data/dto/department_dtos.dart';

void main() {
  test('create/rename request serializes only departmentName', () {
    expect(const DepartmentUpsertDto(departmentName: 'Accounts').toJson(), {
      'departmentName': 'Accounts',
    });
  });

  test('decodes a department with a typed integer id and employee count', () {
    final dto = DepartmentDto.fromJson({
      'departmentId': 2,
      'departmentName': 'accounts',
      'employeeCount': 1,
    });
    expect(dto.departmentId, 2);
    expect(dto.departmentName, 'accounts');
    expect(dto.employeeCount, 1);
  });

  test('employeeCount defaults to 0 when absent', () {
    final dto = DepartmentDto.fromJson({
      'departmentId': 3,
      'departmentName': 'Developer',
    });
    expect(dto.employeeCount, 0);
  });

  test('throws on missing required fields', () {
    expect(
      () => DepartmentDto.fromJson({'departmentName': 'x'}),
      throwsA(anything),
    );
    expect(
      () => DepartmentDto.fromJson({'departmentId': 1}),
      throwsA(anything),
    );
  });

  test('round-trips through JSON', () {
    final dto = DepartmentDto.fromJson({
      'departmentId': 1,
      'departmentName': 'a',
      'employeeCount': 2,
    });
    final decoded = DepartmentDto.fromJson(
      jsonDecode(jsonEncode(dto)) as Map<String, dynamic>,
    );
    expect(decoded, dto);
  });
}
