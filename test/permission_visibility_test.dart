import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/backend_access_policy.dart';
import 'package:modular_erp/platform/access/domain/effective_access.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/user_capability.dart';

List<String> fixtureKeys(String name) {
  final envelope =
      jsonDecode(File('test/fixtures/permissions/$name').readAsStringSync())
          as Map<String, dynamic>;
  final data = envelope['data'] as Map<String, dynamic>;
  return (data['permissions'] as List).map((value) => '$value').toList();
}

EffectiveAccess accessFor(List<String> keys) =>
    BackendAccessPolicy.resolve(keys);

Set<String> modulesWithSettings(EffectiveAccess access) => {
  ...access.enabledModules,
  // The loader keeps the settings hub available to every signed-in user.
  'settings',
};

AuthContext contextFor(EffectiveAccess access, {bool linked = true}) =>
    AuthContext(
      user: UserAccount(
        id: '8',
        displayName: 'Test User',
        email: 'test',
        companyId: '1',
        permissions: access.permissions,
        status: AccountStatus.active,
      ),
      company: CompanyContext(
        id: '1',
        name: 'Company',
        code: 'ORG-1',
        timezone: 'Asia/Dubai',
        defaultLocale: 'en',
        enabledModules: modulesWithSettings(access),
      ),
      employeeReference: linked
          ? const EmployeeReference(
              id: '27',
              userAccountId: '8',
              companyId: '1',
            )
          : null,
    );

void main() {
  test('admin keys expose employees, attendance, settings and access', () {
    final access = accessFor(fixtureKeys('me_permissions_admin.json'));
    final p = access.permissions;

    expect(p.contains(AppPermission.employeeViewAll), isTrue);
    expect(p.contains(AppPermission.employeeCreate), isTrue);
    expect(p.contains(AppPermission.employeeUpdate), isTrue);
    expect(p.contains(AppPermission.employeeDeactivate), isTrue);
    expect(p.contains(AppPermission.shiftView), isTrue);
    expect(p.contains(AppPermission.shiftManage), isTrue);
    expect(p.contains(AppPermission.accessUsersView), isTrue);
    expect(p.contains(AppPermission.accessPermissionsManage), isTrue);
    expect(p.contains(AppPermission.departmentView), isTrue);
    expect(p.contains(AppPermission.departmentManage), isTrue);
    expect(p.contains(AppPermission.attendanceViewSelf), isTrue);
    expect(p.contains(AppPermission.attendancePunchIn), isTrue);

    expect(
      modulesWithSettings(access),
      containsAll(<String>['employees', 'attendance', 'settings']),
    );

    // Branch keys remain intentionally deferred; department keys are live.
    expect(
      access.unknownKeys,
      containsAll(<String>['company.branches.view', 'company.branches.manage']),
    );
    expect(access.unknownKeys, isNot(contains('hr.departments.view')));
    expect(access.unknownKeys, isNot(contains('hr.departments.manage')));
  });

  test('employee view+edit sees employees and self attendance, not admin', () {
    final access = accessFor(fixtureKeys('me_permissions_employee.json'));
    final p = access.permissions;

    expect(p.contains(AppPermission.employeeViewAll), isTrue);
    expect(p.contains(AppPermission.employeeUpdate), isTrue);
    expect(p.contains(AppPermission.employeeCreate), isFalse);
    expect(p.contains(AppPermission.employeeDeactivate), isFalse);
    expect(p.contains(AppPermission.shiftView), isFalse);
    expect(p.contains(AppPermission.accessUsersView), isFalse);
    expect(p.contains(AppPermission.accessPermissionsManage), isFalse);
    expect(p.contains(AppPermission.attendanceViewSelf), isTrue);

    final modules = modulesWithSettings(access);
    expect(
      modules,
      containsAll(<String>['employees', 'attendance', 'settings']),
    );
    expect(modules.contains('services'), isFalse);
  });

  test('no grants fail closed but keep settings and personal modules', () {
    final access = accessFor(const <String>[]);
    expect(access.permissions.values, isEmpty);
    expect(access.enabledModules, isEmpty);
    expect(modulesWithSettings(access), {'settings'});

    final p = access.permissions;
    expect(p.contains(AppPermission.employeeViewAll), isFalse);
    expect(p.contains(AppPermission.employeeUpdate), isFalse);
    expect(p.contains(AppPermission.shiftView), isFalse);
    expect(p.contains(AppPermission.accessUsersView), isFalse);
    expect(p.contains(AppPermission.attendanceViewSelf), isFalse);
  });

  test(
    'existing nav/action predicates map from the resolved permission set',
    () {
      final admin = contextFor(
        accessFor(fixtureKeys('me_permissions_admin.json')),
      );
      final employee = contextFor(
        accessFor(fixtureKeys('me_permissions_employee.json')),
      );
      final none = contextFor(accessFor(const <String>[]), linked: false);

      bool employeesNav(AuthContext c) =>
          PermissionChecker(c.user.permissions).canAny(<AppPermission>[
            AppPermission.employeeViewTeam,
            AppPermission.employeeViewAll,
          ]);
      bool addEmployee(AuthContext c) =>
          c.user.permissions.contains(AppPermission.employeeCreate);
      bool editEmployee(AuthContext c) =>
          c.user.permissions.contains(AppPermission.employeeUpdate);
      bool shiftsSettings(AuthContext c) =>
          c.user.permissions.contains(AppPermission.shiftView);
      bool departmentsNav(AuthContext c) =>
          c.user.permissions.contains(AppPermission.departmentView);
      bool addDepartment(AuthContext c) =>
          c.user.permissions.contains(AppPermission.departmentManage);
      bool accessNav(AuthContext c) =>
          PermissionChecker(c.user.permissions).canAny(<AppPermission>[
            AppPermission.accessUsersView,
            AppPermission.accessPermissionsManage,
          ]);
      bool attendanceNav(AuthContext c) {
        final caps = const UserCapabilityResolver().forAuthContext(c);
        return caps.hasAny(<UserCapability>[
          UserCapability.selfAttendance,
          UserCapability.selfAttendanceHistory,
          UserCapability.teamAttendance,
          UserCapability.companyAttendance,
          UserCapability.approveAttendanceCorrections,
        ]);
      }

      expect(employeesNav(admin), isTrue);
      expect(employeesNav(employee), isTrue);
      expect(employeesNav(none), isFalse);

      expect(addEmployee(admin), isTrue);
      expect(addEmployee(employee), isFalse);
      expect(editEmployee(admin), isTrue);
      expect(editEmployee(employee), isTrue);
      expect(editEmployee(none), isFalse);

      expect(shiftsSettings(admin), isTrue);
      expect(shiftsSettings(employee), isFalse);

      expect(departmentsNav(admin), isTrue);
      expect(departmentsNav(employee), isFalse);
      expect(departmentsNav(none), isFalse);
      expect(addDepartment(admin), isTrue);
      expect(addDepartment(employee), isFalse);

      expect(accessNav(admin), isTrue);
      expect(accessNav(employee), isFalse);
      expect(accessNav(none), isFalse);

      expect(attendanceNav(admin), isTrue);
      expect(attendanceNav(employee), isTrue);
      expect(attendanceNav(none), isFalse);

      // Personal/dashboard modules are always available; settings stays enabled.
      expect(
        modulesWithSettings(accessFor(const <String>[])),
        contains('settings'),
      );
    },
  );
}
