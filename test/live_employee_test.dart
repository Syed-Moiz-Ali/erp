import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/errors/result.dart';
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

  test('maps login with and without an ignorable userType', () {
    final withoutType = LiveEmployeeDto.fromJson(raw).toDomain();
    final withType = LiveEmployeeDto.fromJson({
      ...raw,
      'login': {...raw['login'] as Map<String, dynamic>, 'userType': 'HR'},
    }).toDomain();
    expect(withoutType.loginId, 'qa.audit');
    expect(withType.loginId, 'qa.audit');
    expect(withType.loginUserId, 44);
    expect(withType.loginEnabled, isTrue);
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

  test(
    'full replace strips login.userType but keeps every other loaded field',
    () {
      final loaded = <String, dynamic>{
        ...raw,
        'login': {...raw['login'] as Map<String, dynamic>, 'userType': 'HR'},
      };
      final employee = LiveEmployeeDto.fromJson(loaded).toDomain();
      final body = LiveEmployeeDto.fromJson(
        loaded,
      ).toDraft().toBody(base: employee.raw);
      final sentLogin = (body['login'] as Map).cast<String, dynamic>();
      final loadedLogin = (loaded['login'] as Map).cast<String, dynamic>();
      expect(sentLogin.containsKey('userType'), isFalse);
      for (final entry in loadedLogin.entries) {
        if (entry.key == 'userType') continue;
        expect(sentLogin[entry.key], entry.value, reason: entry.key);
      }
      for (final entry in loaded.entries) {
        if (entry.key == 'login') continue;
        expect(body[entry.key], entry.value, reason: entry.key);
      }
    },
  );

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

  test('create body copies email into login and keeps number types', () {
    const draft = LiveEmployeeDraft(
      name: 'QA',
      branchId: 1,
      departmentId: 2,
      nationalityId: 99,
      statusId: 1,
      designation: 'Tech',
      joiningDate: '2026-10-01',
      dateOfBirth: '1995-05-20',
      maritalStatus: 'Single',
      employeeType: 'Revenue',
      gratuity: 'Limited Contract',
      email: 'qa@example.com',
      phone: '0500000000',
      basicSalary: 3000,
      workingHours: 8,
      transportation: 500,
      accommodation: 1000,
      loginEnabled: true,
      loginId: 'ignored-login',
      loginMobile: '0500000001',
      loginPassword: 'secret1',
      loginBranchIds: [1, 2],
    );
    final body = draft.toBody();
    final login = body['login'] as Map<String, dynamic>;
    expect(login['loginId'], 'qa@example.com');
    expect(login['branchIds'], [1, 2]);
    expect(
      login.keys,
      unorderedEquals([
        'enabled',
        'loginId',
        'mobileNo',
        'password',
        'branchIds',
      ]),
    );
    expect(body['basicSalary'], 3000);
    expect(body['workingHours'], 8);
    expect(body['transportation'], 500);
    expect(body['accommodation'], 1000);
    expect(body['joiningDate'], '2026-10-01');
    expect(body['dateOfBirth'], '1995-05-20');
  });

  test('login off omits the login object entirely', () {
    const draft = LiveEmployeeDraft(
      name: 'QA',
      branchId: 1,
      departmentId: 2,
      nationalityId: 99,
      joiningDate: '2026-10-01',
    );
    expect(draft.toBody().containsKey('login'), isFalse);
  });

  test('server errors map under every form field', () {
    const fields = [
      'employeeName',
      'branchId',
      'departmentId',
      'nationalityId',
      'statusId',
      'designation',
      'joiningDate',
      'dateOfBirth',
      'maritalStatus',
      'employeeType',
      'gratuity',
      'uaeContactNumber',
      'email',
      'workingHours',
      'basicSalary',
      'transportation',
      'accommodation',
      'login.loginId',
      'login.mobileNo',
      'login.password',
      'login.branchIds',
    ];
    for (final field in fields) {
      final mapped = mapEmployeeServerError(
        Failure(
          code: 'VALIDATION_ERROR',
          kind: FailureKind.validation,
          field: field,
          serverMessage: 'invalid',
        ),
      );
      expect(mapped, {field: 'invalid'}, reason: field);
    }
    expect(
      mapEmployeeServerError(
        const Failure(
          code: 'USER_DUPLICATE_LOGINID',
          kind: FailureKind.conflict,
        ),
      ),
      contains('login.loginId'),
    );
    expect(
      mapEmployeeServerError(
        const Failure(
          code: 'USER_DUPLICATE_MOBILE',
          kind: FailureKind.conflict,
        ),
      ),
      contains('login.mobileNo'),
    );
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
