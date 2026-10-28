import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/access/erp_access_catalog.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/user_capability.dart';
import 'support/demo/demo_scenario_grants.dart';

void main() {
  group('permission catalog', () {
    test('every runtime permission is catalogued', () {
      for (final permission in AppPermission.values) {
        expect(
          erpAccessCatalog.forPermission(permission),
          isNotNull,
          reason: '${permission.name} has no PermissionDefinition',
        );
      }
    });

    test('grant round-trips through (key, scope)', () {
      for (final definition in erpAccessCatalog.definitions) {
        for (final scope in definition.supportedScopes) {
          final permission = definition.permissionFor(scope)!;
          final grants = erpAccessCatalog.grantsFor([permission]);
          expect(grants, contains((key: definition.key, scope: scope)));
          expect(erpAccessCatalog.permissionsFor(grants), contains(permission));
        }
      }
    });

    test('manage/view dependencies stay centralized', () {
      expect(
        normalizePermissionGrants([AppPermission.shiftManage]),
        containsAll([AppPermission.shiftManage, AppPermission.shiftView]),
      );
      final definition = erpAccessCatalog.byKey('hr.attendance.shifts.manage');
      expect(definition, isNotNull);
      expect(definition!.supportedScopes, {PermissionScope.none});
    });
  });


  group('role independence', () {
    CompanyContext company() => const CompanyContext(
      id: 'c1',
      name: 'Company',
      code: 'C',
      timezone: 'UTC',
      defaultLocale: 'en',
      enabledModules: {'employees', 'attendance', 'leave'},
    );
    AuthContext account(DemoScenario role, PermissionSet permissions) =>
        AuthContext(
          user: UserAccount(
            id: 'u1',
            displayName: 'User',
            email: 'u@erp.demo',
            companyId: 'c1',
            permissions: permissions,
            status: AccountStatus.active,
          ),
          company: company(),
        );

    test('changing the legacy role label does not change capabilities', () {
      final permissions = PermissionSet([
        AppPermission.attendanceViewSelf,
        AppPermission.leaveViewSelf,
        AppPermission.leaveRequest,
      ]);
      const resolver = UserCapabilityResolver();
      final asAdmin = resolver.forAuthContext(
        account(DemoScenario.platformAdmin, permissions),
      );
      final asEmployee = resolver.forAuthContext(
        account(DemoScenario.employee, permissions),
      );
      expect(asAdmin.granted, asEmployee.granted);
      // Unlinked users get no self-service capability regardless of role label.
      expect(asAdmin.has(UserCapability.selfAttendance), isFalse);
      expect(asAdmin.has(UserCapability.viewCompanyLeave), isFalse);
    });

    test('ALL records access does not imply SELF actions', () {
      final unlinked = account(
        DemoScenario.manager,
        PermissionSet([
          AppPermission.leaveViewAll,
          AppPermission.leaveApproveAll,
        ]),
      );
      final capabilities = const UserCapabilityResolver().forAuthContext(
        unlinked,
      );
      expect(capabilities.has(UserCapability.viewCompanyLeave), isTrue);
      expect(capabilities.has(UserCapability.requestLeave), isFalse);
      expect(capabilities.hasLinkedEmployee, isFalse);
    });

    test('role templates are demo seed fixtures only', () {
      // A role template is explicit grants; it never implies authority by name.
      final template = demoScenarioGrants(DemoScenario.employee);
      expect(template.contains(AppPermission.leaveRequest), isTrue);
      expect(template.contains(AppPermission.employeeViewAll), isFalse);
    });
  });
}
