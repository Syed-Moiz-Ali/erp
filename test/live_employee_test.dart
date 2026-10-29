import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/modules/hr/employees/live/data/dto/live_employee_dtos.dart';
import 'package:modular_erp/modules/hr/employees/live/domain/live_employee.dart';

void main() {
  const raw = {
    'employeeId': 29,
    'employeeCode': 'EMP-29',
    'employeeName': 'QA Employee',
    'branchId': 2,
    'branchName': 'Bitlogix',
    'departmentId': 2,
    'departmentName': 'accounts',
    'nationalityId': 99,
    'nationalityName': 'INDIA',
    'statusId': 1,
    'statusName': 'Active',
    'designation': 'QA Engineer',
    'joiningDate': '2026-10-28',
    'employeeType': 'Revenue',
    'gratuity': 'Limited Contract',
    'ticket': 0,
    'workingHours': 8,
    'basicSalary': 1100.00,
    'transportation': 0.00,
    'accommodation': 0.00,
    'login': {
      'enabled': true,
      'canLogin': true,
      'userId': 44,
      'loginId': 'qa.audit',
      'mobileNo': '0500000099',
      'status': 'Active',
      'branchIds': [2],
    },
  };

  test('maps backend employee fields including optional login', () {
    final employee = LiveEmployeeDto.fromJson(raw).toDomain();
    expect(employee.id, 29);
    expect(employee.code, 'EMP-29');
    expect(employee.name, 'QA Employee');
    expect(employee.email, isNull);
    expect(employee.loginEnabled, isTrue);
    expect(employee.loginId, 'qa.audit');
    expect(employee.loginUserId, 44);
    expect(employee.basicSalary, 1100);
  });

  test('PUT body keeps every field loaded from the backend', () {
    final employee = LiveEmployeeDto.fromJson(raw).toDomain();
    final draft = LiveEmployeeDto.fromJson(raw).toDraft();
    final body = draft.toBody(base: employee.raw);
    for (final key in raw.keys) {
      expect(
        body.containsKey(key),
        isTrue,
        reason: 'PUT body dropped loaded field $key',
      );
    }
    expect(body['employeeName'], 'QA Employee');
    expect(body['basicSalary'], 1100);
    expect((body['login'] as Map)['loginId'], 'qa.audit');
  });

  test('draft validation requires core fields and login fields', () {
    const draft = LiveEmployeeDraft(name: 'QA', loginEnabled: true);
    final errors = draft.validate();
    expect(errors['branchId'], 'required');
    expect(errors['departmentId'], 'required');
    expect(errors['nationalityId'], 'required');
    expect(errors['joiningDate'], 'required');
    expect(errors['login.loginId'], 'required');
    expect(errors['login.mobileNo'], 'required');
    expect(errors['login.branchIds'], 'required');
  });

  test('unchanged loaded values are sent back identically', () {
    final employee = LiveEmployeeDto.fromJson(raw).toDomain();
    final body = LiveEmployeeDto.fromJson(
      raw,
    ).toDraft().toBody(base: employee.raw);
    for (final key in raw.keys) {
      expect(body[key], raw[key], reason: 'PUT body changed loaded field $key');
    }
  });

  test('list query maps backend parameters', () {
    final query = employeeListQuery(
      search: ' QA ',
      statusId: 1,
      departmentId: 2,
      branchId: 3,
      sort: 'codeAsc',
      page: 2,
      pageSize: 50,
    );
    expect(query, {
      'page': 2,
      'pageSize': 50,
      'sort': 'codeAsc',
      'search': 'QA',
      'statusId': 1,
      'departmentId': 2,
      'branchId': 3,
    });
  });
}
