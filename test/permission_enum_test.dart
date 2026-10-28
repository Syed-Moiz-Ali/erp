import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/security/access_tree.dart';

void main() {
  const expectedActions = {
    PermissionFeature.employees: {
      PermissionAction.view,
      PermissionAction.create,
      PermissionAction.edit,
      PermissionAction.deactivate,
    },
    PermissionFeature.departments: {
      PermissionAction.view,
      PermissionAction.manage,
    },
    PermissionFeature.attendanceSelf: {
      PermissionAction.view,
      PermissionAction.punch,
    },
    PermissionFeature.attendanceShifts: {
      PermissionAction.view,
      PermissionAction.manage,
    },
    PermissionFeature.branches: {
      PermissionAction.view,
      PermissionAction.manage,
    },
    PermissionFeature.accessUsers: {PermissionAction.view},
    PermissionFeature.accessPermissions: {PermissionAction.manage},
    PermissionFeature.users: {PermissionAction.manage},
  };

  test('the feature/action table matches the approved contract', () {
    expect(permissionFeatureActions, expectedActions);
  });

  test('every composed key is a live tree key', () {
    expect(composedPermissionKeys, accessTree.allPermissionKeys);
    for (final feature in PermissionFeature.values) {
      for (final action in permissionActionsFor(feature)) {
        final key = composePermissionKey(feature.module, feature, action);
        expect(
          accessTree.allPermissionKeys,
          contains(key),
          reason: 'composed $key must exist in the tree',
        );
      }
    }
  });

  test('every live tree key decomposes back to the same key', () {
    for (final key in accessTree.allPermissionKeys) {
      final parts = decomposePermissionKey(key);
      expect(parts, isNotNull, reason: '$key must decompose');
      expect(parts!.key, key, reason: '$key must round-trip');
    }
  });

  test('features are filtered by module', () {
    expect(permissionFeaturesFor(PermissionModule.hr), [
      PermissionFeature.employees,
      PermissionFeature.departments,
      PermissionFeature.attendanceSelf,
      PermissionFeature.attendanceShifts,
    ]);
    expect(permissionFeaturesFor(PermissionModule.company), [
      PermissionFeature.branches,
      PermissionFeature.accessUsers,
      PermissionFeature.accessPermissions,
      PermissionFeature.users,
    ]);
    for (final module in PermissionModule.values) {
      expect(
        permissionFeaturesFor(module).every((f) => f.module == module),
        isTrue,
      );
    }
  });

  test('actions are filtered by feature and invalid pairs fail', () {
    expect(permissionActionsFor(PermissionFeature.employees), [
      PermissionAction.view,
      PermissionAction.create,
      PermissionAction.edit,
      PermissionAction.deactivate,
    ]);
    expect(permissionActionsFor(PermissionFeature.accessUsers), [
      PermissionAction.view,
    ]);
    expect(
      () => composePermissionKey(
        PermissionModule.hr,
        PermissionFeature.accessUsers,
        PermissionAction.view,
      ),
      throwsArgumentError,
    );
    expect(
      () => composePermissionKey(
        PermissionModule.hr,
        PermissionFeature.employees,
        PermissionAction.manage,
      ),
      throwsArgumentError,
    );
  });

  test('unknown and orphan keys do not decompose', () {
    for (final key in [
      '',
      'legacy.permission.key',
      'hr.employees.archive',
      'company.users.view',
      'hr.attendance.view',
      'hr.employees.view.extra',
      'unknown',
    ]) {
      expect(decomposePermissionKey(key), isNull, reason: key);
    }
  });

  test('decomposition is case-insensitive', () {
    final parts = decomposePermissionKey(' HR.Employees.VIEW ');
    expect(parts?.module, PermissionModule.hr);
    expect(parts?.feature, PermissionFeature.employees);
    expect(parts?.action, PermissionAction.view);
  });
}
