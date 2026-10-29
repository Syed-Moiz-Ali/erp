import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/modules/hr/departments/data/dto/department_dtos.dart';

Map<String, dynamic> load(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

List<Map<String, dynamic>> items(String path) {
  final data = load(path)['data'] as Map<String, dynamic>;
  return [
    for (final item in data['items'] as List)
      (item as Map).cast<String, dynamic>(),
  ];
}

void main() {
  test('department list keeps paging, search and employee counts', () {
    final envelope = load('test/fixtures/departments/departments_list.json');
    expect(envelope['message'], 'Departments retrieved.');
    final data = envelope['data'] as Map<String, dynamic>;
    expect(data['page'], 1);
    expect(data['pageSize'], 25);
    expect(data['totalItems'], 5);
    expect(data['totalPages'], 1);

    final departments = items(
      'test/fixtures/departments/departments_list.json',
    ).map(DepartmentDto.fromJson).toList();
    expect(departments, hasLength(5));
    expect(departments.any((dto) => dto.employeeCount > 0), isTrue);

    final filtered =
        load('test/fixtures/departments/departments_list_filtered.json')['data']
            as Map;
    expect(filtered['totalItems'], 4);
    expect((filtered['items'] as List), hasLength(4));
  });

  test('department detail parses the exact wire shape', () {
    final dto = DepartmentDto.fromJson(
      (load('test/fixtures/departments/department_detail.json')['data'] as Map)
          .cast(),
    );
    expect(dto.departmentId, 2);
    expect(dto.departmentName, isNotEmpty);
    expect(dto.employeeCount, 4);
  });

  test('department 404 and employee 403 keep the error envelope', () {
    final notFound = load(
      'test/fixtures/departments/department_not_found.json',
    );
    expect(notFound['success'], isFalse);
    expect((notFound['errors'] as List).single['code'], 'DEPARTMENT_NOT_FOUND');
    final forbidden = load(
      'test/fixtures/departments/departments_forbidden.json',
    );
    expect(forbidden['success'], isFalse);
    expect((forbidden['errors'] as List).single['code'], 'ACCESS_DENIED');
  });

  test('there is no activate endpoint in the captured contract', () {
    // Only list/detail/deactivate operations were captured; the client must not
    // invent an activate route.
    expect(
      Directory(
        'test/fixtures/departments',
      ).listSync().map((f) => f.path).join(),
      isNot(contains('activate')),
    );
  });
}
