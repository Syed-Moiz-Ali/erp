import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/security/access_tree.dart';
import 'package:modular_erp/core/security/backend_access_policy.dart';
import 'package:modular_erp/modules/hr/employees/live/data/dto/live_employee_dtos.dart';

Map<String, dynamic> load(String name) =>
    jsonDecode(File('test/fixtures/employees/$name').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> data(String name) =>
    (load(name)['data'] as Map).cast<String, dynamic>();

List<String> mePermissions(String name) {
  final value =
      jsonDecode(File('test/fixtures/permissions/$name').readAsStringSync())
          as Map<String, dynamic>;
  return ((value['data'] as Map)['permissions'] as List).cast<String>();
}

void main() {
  test('live list keeps paging, filters and backend list shape', () {
    final envelope = load('employees_list.json');
    final page = data('employees_list.json');
    expect(page['page'], 1);
    expect(page['pageSize'], 25);
    expect(page['totalItems'], greaterThanOrEqualTo(25));
    expect(page['items'], hasLength(25));
    final item = (page['items'] as List).first as Map;
    expect(item['employeeId'], isA<int>());
    expect(item['employeeCode'], isA<String>());
    expect(item['statusId'], 1);
    expect(item['loginEnabled'], isA<bool>());
    expect(item['canLogin'], isA<bool>());
    expect(envelope['errors'], isEmpty);

    final filtered = data('employees_list_filtered.json');
    expect(filtered['pageSize'], 5);
    expect(filtered['items'], isNotEmpty);
  });

  test('live employee account sees the same list and lookups as Admin', () {
    final adminPage = data('employees_list.json');
    final employeePage = data('employees_list_employee.json');
    expect(employeePage['totalItems'], adminPage['totalItems']);
    expect(employeePage['items'], hasLength(25));
    expect(load('employee_lookups_employee.json')['success'], isTrue);
  });

  test('live detail models every returned field', () {
    final detail = data('employee_detail.json');
    final employee = LiveEmployeeDto.fromJson(detail).toDomain();
    expect(employee.id, detail['employeeId']);
    expect(employee.code, detail['employeeCode']);
    expect(employee.dateOfBirth, '1995-05-20');
    expect(employee.maritalStatus, 'Single');
    expect(employee.employeeType, 'Revenue');
    expect(employee.gratuity, 'Limited Contract');
    expect(employee.workingHours, 8);
    expect(employee.basicSalary, 3000);
    expect(employee.transportation, 500);
    expect(employee.accommodation, 1000);
    expect(employee.totalSalary, 4500);
    expect(employee.loginEnabled, isTrue);
    expect(employee.canLogin, isTrue);
    expect(employee.loginId, 'sanitized@example.com');
    expect(employee.loginUserId, 31);
    expect(employee.loginStatus, 'Active');
    expect(employee.loginStartDate, '2026-09-30');
    expect(employee.loginBranchIds, [1]);
    expect(employee.loginBranchNames, isA<String>());
    expect(employee.photoPath, isNull);
    expect(employee.passportNumber, isNull);
  });

  test('live PUT drops no field and strips userType only', () {
    final detail = data('employee_detail.json');
    final employee = LiveEmployeeDto.fromJson(detail).toDomain();
    final draft = LiveEmployeeDto.fromJson(detail).toDraft();
    final body = draft.toBody(base: employee.raw);
    for (final entry in detail.entries) {
      if (entry.key == 'login') continue;
      expect(
        body.containsKey(entry.key),
        isTrue,
        reason: 'PUT dropped ${entry.key}',
      );
      expect(body[entry.key], entry.value, reason: 'PUT changed ${entry.key}');
    }
    final sentLogin = (body['login'] as Map).cast<String, dynamic>();
    final loadedLogin = (detail['login'] as Map).cast<String, dynamic>();
    for (final entry in loadedLogin.entries) {
      if (entry.key == 'userType') continue;
      expect(sentLogin.containsKey(entry.key), isTrue, reason: entry.key);
      expect(sentLogin[entry.key], entry.value, reason: entry.key);
    }
    expect(sentLogin.containsKey('userType'), isFalse);
  });

  test('live lookups expose selector sources', () {
    final lookup = data('employee_lookups.json');
    expect(lookup['branches'], isA<List>());
    expect(lookup['departments'], isA<List>());
    expect(lookup['nationalities'], isA<List>());
    expect(lookup['statuses'], isA<List>());
    expect(lookup['maritalStatuses'], contains('Single'));
    expect(lookup['employeeTypes'], contains('Revenue'));
    expect(lookup['gratuityTypes'], contains('Limited Contract'));
  });

  test('live 404 and pre-grant 403 envelopes are explicit', () {
    final notFound = load('employee_not_found.json');
    expect((notFound['errors'] as List).single['code'], 'EMP_NOT_FOUND');
    final preGrant = load('employees_forbidden_admin_pregrant.json');
    expect(preGrant['success'], isFalse);
    expect((preGrant['errors'] as List).single['code'], 'ACCESS_DENIED');
  });

  test('employee view+edit and Admin view both expose the Employees entry', () {
    for (final fixture in [
      'me_permissions_employee.json',
      'me_permissions_admin.json',
    ]) {
      final permissions = mePermissions(fixture);
      expect(permissions, contains('hr.employees.view'), reason: fixture);
      final access = BackendAccessPolicy.resolve(permissions);
      final screen = accessTree.screen('hr.employees')!;
      expect(accessTree.canView(screen, access.permissions), isTrue);
      expect(
        accessTree
            .visibleNavigationScreens(access.permissions)
            .map((screen) => screen.id),
        contains('hr.employees'),
      );
    }
    expect(
      mePermissions('me_permissions_employee.json'),
      contains('hr.employees.edit'),
    );
  });
}
