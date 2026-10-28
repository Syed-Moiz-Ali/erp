import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/access/erp_access_catalog.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/backend_access_policy.dart';
import 'package:modular_erp/core/security/permission_scope.dart';

void main() {
  group('BackendAccessPolicy', () {
    test('maps every backend key to at least one runtime permission', () {
      for (final key in BackendAccessPolicy.backendKeys) {
        expect(
          BackendAccessPolicy.keyPermissions[key],
          isNotEmpty,
          reason: 'No runtime permission for $key',
        );
      }
    });

    test('treats a granted employee view key as ALL', () {
      final access = BackendAccessPolicy.resolve(['hr.employees.view']);
      expect(access.permissions.contains(AppPermission.employeeViewAll), isTrue);
      expect(
        access.permissions.scopeFor(AppPermission.employeeViewAll),
        PermissionScope.all,
      );
      expect(access.enabledModules, contains('employees'));
      expect(access.unknownKeys, isEmpty);
    });

    test('expands the single punch key to punch, break and punch-out', () {
      final access = BackendAccessPolicy.resolve(['hr.attendance.self.punch']);
      expect(access.permissions.contains(AppPermission.attendancePunchIn), isTrue);
      expect(
        access.permissions.contains(AppPermission.attendancePunchOut),
        isTrue,
      );
      expect(access.permissions.contains(AppPermission.attendanceBreak), isTrue);
      expect(access.enabledModules, contains('attendance'));
    });

    test('manage implies view through the shared normalizer', () {
      final access = BackendAccessPolicy.resolve([
        'hr.departments.manage',
        'company.branches.manage',
      ]);
      expect(access.permissions.contains(AppPermission.departmentView), isTrue);
      expect(
        access.permissions.contains(AppPermission.companyBranchView),
        isTrue,
      );
      expect(access.enabledModules, contains('settings'));
    });

    test('unknown keys fail closed and are reported', () {
      final access = BackendAccessPolicy.resolve([
        'hr.employees.view',
        'future.unknown.permission',
      ]);
      expect(access.permissions.contains(AppPermission.employeeViewAll), isTrue);
      expect(access.unknownKeys, contains('future.unknown.permission'));
      expect(
        access.permissions.contains(AppPermission.accessPermissionsManage),
        isFalse,
      );
    });

    test('no keys means no permissions and no modules', () {
      final access = BackendAccessPolicy.resolve(const []);
      expect(access.permissions.values, isEmpty);
      expect(access.enabledModules, isEmpty);
    });
  });

  group('permission catalog consistency', () {
    test('every runtime permission is declared by the catalog', () {
      final missing = <AppPermission>[];
      for (final permission in AppPermission.values) {
        if (erpAccessCatalog.forPermission(permission) == null) {
          missing.add(permission);
        }
      }
      expect(
        missing,
        isEmpty,
        reason:
            'Route/menu/action permissions must be declared in the catalog: '
            '$missing',
      );
    });

    test('every backend key exists in the catalog and is backend-visible', () {
      for (final key in BackendAccessPolicy.backendKeys) {
        final definition = erpAccessCatalog.byKey(key);
        expect(definition, isNotNull, reason: 'Catalog is missing $key');
        expect(
          erpAccessCatalog.backendDefinitions.any((d) => d.key == key),
          isTrue,
          reason: '$key must be visible in backend mode',
        );
      }
    });

    test('client-only permissions are hidden in backend mode', () {
      final backendKeys = erpAccessCatalog.backendDefinitions
          .map((definition) => definition.key)
          .toSet();
      expect(backendKeys, isNot(contains('hr.attendance.self.break')));
      expect(backendKeys, isNot(contains('hr.attendance.self.punchOut')));
      expect(
        backendKeys,
        isNot(contains('hr.attendance.self.correctionRequest')),
      );
      expect(backendKeys, contains('hr.attendance.self.punch'));
    });

    test('backend view preserves modules but hides unsupported keys', () {
      final view = erpAccessCatalog.backendView;
      expect(view.byKey('hr.attendance.self.punch'), isNotNull);
      expect(view.byKey('hr.attendance.self.break'), isNull);
      expect(view.byKey('hr.leave.self.view'), isNull);
      expect(view.byKey('company.branches.view'), isNotNull);
      expect(view.orderedModules, isNotEmpty);
    });
    test('department keys use the backend namespace', () {
      expect(erpAccessCatalog.byKey('hr.departments.view'), isNotNull);
      expect(erpAccessCatalog.byKey('hr.departments.manage'), isNotNull);
      expect(erpAccessCatalog.byKey('hr.attendance.departments.view'), isNull);
      expect(erpAccessCatalog.byKey('hr.attendance.departments.manage'), isNull);
    });
  });
}

