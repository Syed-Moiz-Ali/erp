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

void main() {
  test('fallback list keeps paging and backend list shape', () {
    final envelope = load('employees_list.json');
    final page = data('employees_list.json');
    expect(page['page'], 1);
    expect(page['pageSize'], 25);
    expect(page['totalItems'], 1);
    final item = (page['items'] as List).single as Map;
    expect(item['employeeId'], isA<int>());
    expect(item['employeeCode'], isA<String>());
    expect(item['statusId'], 1);
    expect(envelope['errors'], isEmpty);

    final filtered = data('employees_list_filtered.json');
    expect(filtered['pageSize'], 5);
  });

  test('fallback detail models every documented field', () {
    final detail = data('employee_detail.json');
    final employee = LiveEmployeeDto.fromJson(detail).toDomain();
    expect(employee.id, 29);
    expect(employee.code, 'EMP-29');
    expect(employee.dateOfBirth, '1995-05-20');
    expect(employee.maritalStatus, 'Single');
    expect(employee.employeeType, 'Revenue');
    expect(employee.gratuity, 'Limited Contract');
    expect(employee.workingHours, 8);
    expect(employee.basicSalary, 3000);
    expect(employee.transportation, 500);
    expect(employee.accommodation, 1000);
    expect(employee.totalSalary, 1100);
    expect(employee.loginEnabled, isTrue);
    expect(employee.loginId, 'qa.employee');
    expect(employee.loginUserId, 44);
  });

  test('PUT from the detail fixture drops no field and changes nothing', () {
    final detail = data('employee_detail.json');
    final employee = LiveEmployeeDto.fromJson(detail).toDomain();
    final draft = LiveEmployeeDto.fromJson(detail).toDraft();
    final body = draft.toBody(base: employee.raw);
    for (final entry in detail.entries) {
      expect(
        body.containsKey(entry.key),
        isTrue,
        reason: 'PUT dropped ${entry.key}',
      );
      expect(body[entry.key], entry.value, reason: 'PUT changed ${entry.key}');
    }
    expect((body['login'] as Map)['loginId'], 'qa.employee');
    expect((body['login'] as Map)['branchIds'], [2]);
  });

  test('fallback lookups expose selector sources', () {
    final lookup = data('employee_lookups.json');
    expect(lookup['branches'], isA<List>());
    expect(lookup['departments'], isA<List>());
    expect(lookup['nationalities'], isA<List>());
    expect(lookup['statuses'], isA<List>());
    expect(lookup['maritalStatuses'], contains('Single'));
    expect(lookup['employeeTypes'], contains('Revenue'));
    expect(lookup['gratuityTypes'], contains('Limited Contract'));
    expect(lookup['userTypes'], contains('HR'));
  });

  test('employee 404 and live 403 envelopes are explicit', () {
    final notFound = load('employee_not_found.json');
    expect((notFound['errors'] as List).single['code'], 'EMP_NOT_FOUND');
    for (final name in [
      'employees_forbidden_admin.json',
      'employees_forbidden_employee.json',
    ]) {
      final forbidden = load(name);
      expect(forbidden['success'], isFalse);
      expect((forbidden['errors'] as List).single['code'], 'ACCESS_DENIED');
    }
  });

  test('edit-only live grants do not expose the Employees tree entry', () {
    final employeePermissions = (data('employee_detail.json')['login'] as Map);
    // The live employee account grants are captured under the auth fixture.
    final me =
        jsonDecode(
              File(
                'test/fixtures/permissions/me_permissions_employee.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final permissions = (me['data'] as Map)['permissions'] as List;
    expect(permissions, contains('hr.employees.edit'));
    expect(permissions, isNot(contains('hr.employees.view')));

    final access = BackendAccessPolicy.resolve(permissions.cast<String>());
    final screen = accessTree.screen('hr.employees')!;
    expect(accessTree.canView(screen, access.permissions), isFalse);
    expect(
      accessTree
          .visibleNavigationScreens(access.permissions)
          .map((screen) => screen.id),
      isNot(contains('hr.employees')),
    );
    expect(employeePermissions, isNotNull);
  });
}
