import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift.dart';

Map<String, dynamic> load(String name) =>
    jsonDecode(File('test/fixtures/employee_shifts/$name').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('assignment list keeps paging, filters and IANA zones', () {
    final envelope = load('employee_shifts_list.json');
    expect(envelope['message'], 'Shift assignments retrieved.');
    final data = envelope['data'] as Map<String, dynamic>;
    expect(data['page'], 1);
    expect(data['pageSize'], 25);
    expect(data['totalItems'], 25);
    final items = data['items'] as List;
    expect(items, hasLength(25));
    expect(
      items.every(
        (item) =>
            (item as Map)['timeZoneId'] is String &&
            (item['timeZoneId'] as String).contains('/'),
      ),
      isTrue,
    );
    expect(items.any((item) => (item as Map)['statusId'] == 2), isTrue);
  });

  test('assignment detail exposes dates, shift and login-zone state', () {
    final detail = load('employee_shift_detail.json')['data'] as Map;
    expect(detail['employeeShiftId'], 1);
    expect(detail['employeeId'], 2);
    expect(detail['shiftId'], 1);
    expect(detail['fromDate'], '2026-09-01');
    expect(detail['toDate'], '2026-10-31');
    expect(detail['timeZoneId'], 'Asia/Dubai');
    expect(detail['punchInOpensAt'], '08:40:00');
    expect(detail['crossesMidnight'], isFalse);
  });

  test('assignment 404 and employee 403 envelopes are explicit', () {
    final notFound = load('employee_shift_not_found.json');
    expect(
      (notFound['errors'] as List).single['code'],
      'EMPLOYEE_SHIFT_NOT_FOUND',
    );
    final forbidden = load('employee_shifts_forbidden_employee.json');
    expect((forbidden['errors'] as List).single['code'], 'ACCESS_DENIED');
  });

  test('overlap and timezone failures map to date/timezone fields', () {
    final overlap = mapEmployeeShiftError(
      const Failure(
        code: 'EMPLOYEE_SHIFT_OVERLAP',
        kind: FailureKind.conflict,
        serverMessage: 'Overlaps another assignment.',
      ),
    );
    expect(overlap.keys, contains('toDate'));
    expect(overlap['toDate'], 'Overlaps another assignment.');

    final timezone = mapEmployeeShiftError(
      const Failure(
        code: 'EMPLOYEE_SHIFT_TIMEZONE_MISMATCH',
        kind: FailureKind.conflict,
        serverMessage: 'Time zone mismatch.',
      ),
    );
    expect(timezone.keys, contains('timeZoneId'));

    final field = mapEmployeeShiftError(
      const Failure(
        code: 'VALIDATION_ERROR',
        kind: FailureKind.validation,
        field: 'fromDate',
        serverMessage: 'Invalid date.',
      ),
    );
    expect(field, {'fromDate': 'Invalid date.'});
  });

  test('assignment body uses immutable employee only on create', () {
    const draft = EmployeeShiftDraft(
      employeeId: 2,
      shiftId: 3,
      fromDate: '2026-10-01',
      toDate: '2026-10-31',
      timeZoneId: 'Asia/Dubai',
    );
    expect(draft.toBody()['employeeId'], 2);
    expect(
      draft.toBody(includeEmployee: false).containsKey('employeeId'),
      isFalse,
    );
    expect(draft.toBody()['timeZoneId'], 'Asia/Dubai');
  });
}
