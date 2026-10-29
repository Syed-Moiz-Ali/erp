import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/modules/hr/employee_shifts/data/dto/employee_shift_dtos.dart';
import 'package:modular_erp/modules/hr/employee_shifts/data/employee_shift_mapper.dart';

Map<String, dynamic> load(String name) =>
    jsonDecode(File('test/fixtures/employee_shifts/$name').readAsStringSync())
        as Map<String, dynamic>;

List<Map<String, dynamic>> items(String name) {
  final data = load(name)['data'] as Map<String, dynamic>;
  return [
    for (final item in data['items'] as List)
      (item as Map).cast<String, dynamic>(),
  ];
}

void main() {
  test('list fixture keeps paging and maps every row', () {
    final data =
        load('employee_shifts_list.json')['data'] as Map<String, dynamic>;
    expect(data['page'], 1);
    expect(data['pageSize'], 25);
    expect(data['totalItems'], 25);
    expect(data['totalPages'], 1);

    final rows = items(
      'employee_shifts_list.json',
    ).map(EmployeeShiftDto.fromJson).toList();
    expect(rows, hasLength(25));

    final first = EmployeeShiftMapper.toDomain(rows.first);
    expect(first.employeeShiftId, 1);
    expect(first.employeeId, 2);
    expect(first.employeeCode, 'EMP-SANITIZED');
    expect(first.employeeName, 'Sanitized Employee');
    expect(first.shiftId, 1);
    expect(first.shiftName, 'Shift 1');
    expect(first.fromDate, '2026-09-01');
    expect(first.toDate, '2026-10-31');
    expect(first.startTime, '09:00:00');
    expect(first.endTime, '12:00:00');
    expect(first.earlyPunchInMinutes, 20);
    expect(first.lateGraceMinutes, 20);
    expect(first.statusId, 1);
    expect(first.status, 'Active');
    expect(first.timeZoneId, 'Asia/Dubai');
    expect(first.punchInOpensAt, '08:40:00');
    expect(first.crossesMidnight, isFalse);
    expect(first.isActive, isTrue);

    final inactive = rows.firstWhere((row) => row.employeeShiftId == 4);
    expect(inactive.statusId, 2);
    expect(inactive.status, 'InActive');
  });

  test('filtered list fixture keeps the page size', () {
    final data =
        load('employee_shifts_list_filtered.json')['data']
            as Map<String, dynamic>;
    expect(data['page'], 1);
    expect(data['pageSize'], 5);
    expect(data['totalItems'], 2);
    expect(data['totalPages'], 1);

    final rows = items(
      'employee_shifts_list_filtered.json',
    ).map(EmployeeShiftDto.fromJson).toList();
    expect(rows, hasLength(2));
    expect(rows.every((row) => row.employeeId == 2), isTrue);
  });

  test('detail fixture parses cross-midnight and time zone fields', () {
    final dto = EmployeeShiftDto.fromJson(
      (load('employee_shift_detail.json')['data'] as Map).cast(),
    );
    expect(dto.employeeShiftId, 1);
    expect(dto.timeZoneId, 'Asia/Dubai');
    expect(dto.punchInOpensAt, '08:40:00');
    expect(dto.crossesMidnight, isFalse);

    final overnight = items('employee_shifts_list.json')
        .map(EmployeeShiftDto.fromJson)
        .firstWhere((row) => row.employeeShiftId == 8);
    expect(overnight.crossesMidnight, isTrue);
    expect(overnight.endTime, '02:00:00');
  });

  test('not found envelope keeps EMPLOYEE_SHIFT_NOT_FOUND', () {
    final envelope = load('employee_shift_not_found.json');
    expect(envelope['success'], isFalse);
    expect(envelope['data'], isNull);
    final error = (envelope['errors'] as List).single as Map;
    expect(error['code'], 'EMPLOYEE_SHIFT_NOT_FOUND');
    expect(error['message'], 'Shift assignment not found.');
  });

  test('forbidden envelope keeps ACCESS_DENIED', () {
    final envelope = load('employee_shifts_forbidden_employee.json');
    expect(envelope['success'], isFalse);
    expect(envelope['data'], isNull);
    final error = (envelope['errors'] as List).single as Map;
    expect(error['code'], 'ACCESS_DENIED');
  });
}
