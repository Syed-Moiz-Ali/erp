import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/access/erp_access_catalog.dart';
import 'package:modular_erp/core/security/access_tree.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/backend_access_policy.dart';

PermissionSet _permissions(Set<String> keys) => PermissionSet({
  for (final key in keys) ...?BackendAccessPolicy.keyPermissions[key],
});

List<String> _visibleModules(Set<String> keys) {
  final permissions = _permissions(keys);
  return accessTree
      .visibleModules(permissions)
      .map((module) => module.id)
      .toList();
}

List<String> _visibleScreens(Set<String> keys) {
  final permissions = _permissions(keys);
  return accessTree
      .visibleScreens(permissions)
      .map((screen) => screen.id)
      .toList();
}

bool _canAction(Set<String> keys, String screenId, String actionId) =>
    accessTree.canAction(
      accessTree.screen(screenId)!,
      actionId,
      _permissions(keys),
    );

bool _canOpen(Set<String> keys, String path) {
  final screen = accessTree.screenForPath(path)!;
  return accessTree.canOpenRoute(screen, path, _permissions(keys));
}

void main() {
  group('permission-driven navigation table', () {
    final cases =
        <
          ({
            String name,
            Set<String> keys,
            List<String> modules,
            List<String> screens,
          })
        >[
          (name: 'no permissions', keys: {}, modules: [], screens: []),
          (
            name: 'unknown and orphan keys are ignored',
            keys: {'hr.unknown.view', 'services.customers.view'},
            modules: [],
            screens: [],
          ),
          (
            name: 'employee view only',
            keys: {'hr.employees.view'},
            modules: ['hr'],
            screens: ['hr.employees'],
          ),
          (
            name: 'employee view and create',
            keys: {'hr.employees.view', 'hr.employees.create'},
            modules: ['hr'],
            screens: ['hr.employees'],
          ),
          (
            name: 'attendance view only',
            keys: {'hr.attendance.self.view'},
            modules: ['hr'],
            screens: ['hr.attendance.self'],
          ),
          (
            name: 'shifts view exposes both shift screens',
            keys: {'hr.attendance.shifts.view'},
            modules: ['hr'],
            screens: ['hr.attendance.shifts', 'hr.attendance.employeeShifts'],
          ),
          (
            name: 'company branches view only',
            keys: {'company.branches.view'},
            modules: ['company'],
            screens: ['company.branches'],
          ),
          (
            name: 'access users view exposes grants and master screens',
            keys: {'company.access.users.view'},
            modules: ['access'],
            screens: ['access.users', 'access.permissions'],
          ),
          (
            name: 'admin keys expose every module and screen',
            keys: {
              'hr.employees.view',
              'hr.employees.create',
              'hr.employees.edit',
              'hr.employees.deactivate',
              'company.users.manage',
              'hr.departments.view',
              'hr.departments.manage',
              'hr.attendance.self.view',
              'hr.attendance.self.punch',
              'hr.attendance.shifts.view',
              'hr.attendance.shifts.manage',
              'company.branches.view',
              'company.branches.manage',
              'company.access.users.view',
              'company.access.permissions.manage',
            },
            modules: ['hr', 'company', 'access'],
            screens: [
              'hr.employees',
              'hr.departments',
              'hr.attendance.self',
              'hr.attendance.shifts',
              'hr.attendance.employeeShifts',
              'company.branches',
              'access.users',
              'access.permissions',
            ],
          ),
        ];

    for (final testCase in cases) {
      test(testCase.name, () {
        expect(_visibleModules(testCase.keys), testCase.modules);
        expect(_visibleScreens(testCase.keys), testCase.screens);
      });
    }
  });

  group('actions are table-driven', () {
    test('view only has no employee actions', () {
      final keys = {'hr.employees.view'};
      for (final action in ['create', 'edit', 'deactivate', 'login']) {
        expect(_canAction(keys, 'hr.employees', action), isFalse);
      }
    });

    test('employee create, edit, deactivate and login gates are separate', () {
      expect(
        _canAction(
          {'hr.employees.view', 'hr.employees.create'},
          'hr.employees',
          'create',
        ),
        isTrue,
      );
      expect(
        _canAction(
          {'hr.employees.view', 'hr.employees.create'},
          'hr.employees',
          'edit',
        ),
        isFalse,
      );
      expect(
        _canAction(
          {'hr.employees.view', 'hr.employees.edit'},
          'hr.employees',
          'edit',
        ),
        isTrue,
      );
      expect(
        _canAction(
          {'hr.employees.view', 'hr.employees.deactivate'},
          'hr.employees',
          'deactivate',
        ),
        isTrue,
      );
      expect(
        _canAction(
          {'hr.employees.view', 'company.users.manage'},
          'hr.employees',
          'login',
        ),
        isTrue,
      );
    });

    test('attendance punch action does not grant view', () {
      final punchOnly = {'hr.attendance.self.punch'};
      expect(_visibleScreens(punchOnly), isEmpty);
      expect(_canAction(punchOnly, 'hr.attendance.self', 'punch'), isTrue);
      expect(
        _canAction(
          {'hr.attendance.self.view', 'hr.attendance.self.punch'},
          'hr.attendance.self',
          'punch',
        ),
        isTrue,
      );
    });

    test('manage actions require their own key', () {
      expect(
        _canAction({'company.branches.view'}, 'company.branches', 'manage'),
        isFalse,
      );
      expect(
        _canAction(
          {'company.branches.view', 'company.branches.manage'},
          'company.branches',
          'manage',
        ),
        isTrue,
      );
      expect(
        _canAction({'company.access.users.view'}, 'access.users', 'manage'),
        isFalse,
      );
      expect(
        _canAction(
          {'company.access.users.view', 'company.access.permissions.manage'},
          'access.users',
          'manage',
        ),
        isTrue,
      );
    });
  });

  group('route matching and deep-link actions', () {
    test('nested access route uses the most specific screen', () {
      expect(
        accessTree.screenForPath('/app/settings/access/permissions')?.id,
        'access.permissions',
      );
      expect(
        accessTree.screenForPath('/app/settings/access/users/7')?.id,
        'access.users',
      );
    });

    test('view-only employee cannot open new or edit routes', () {
      expect(_canOpen({'hr.employees.view'}, '/app/hr/employees'), isTrue);
      expect(_canOpen({'hr.employees.view'}, '/app/hr/employees/7'), isTrue);
      expect(_canOpen({'hr.employees.view'}, '/app/hr/employees/new'), isFalse);
      expect(
        _canOpen({'hr.employees.view'}, '/app/hr/employees/7/edit'),
        isFalse,
      );
    });

    test('action keys open the matching employee routes', () {
      expect(
        _canOpen({
          'hr.employees.view',
          'hr.employees.create',
        }, '/app/hr/employees/new'),
        isTrue,
      );
      expect(
        _canOpen({
          'hr.employees.view',
          'hr.employees.edit',
        }, '/app/hr/employees/7/edit'),
        isTrue,
      );
    });

    test('missing key is reported for unauthorized routes', () {
      final screen = accessTree.screenForPath('/app/hr/employees/new')!;
      expect(
        accessTree.missingKeyForRoute(
          screen,
          '/app/hr/employees/new',
          _permissions({'hr.employees.view'}),
        ),
        'hr.employees.create',
      );
    });
  });

  test(
    'every tree key exists in the backend policy and permission catalog',
    () {
      for (final key in accessTree.allPermissionKeys) {
        expect(
          BackendAccessPolicy.supports(key),
          isTrue,
          reason: '$key is not supported by BackendAccessPolicy',
        );
        expect(
          erpAccessCatalog.byKey(key),
          isNotNull,
          reason: '$key is missing from the permission catalog',
        );
      }
    },
  );

  test('every action key belongs to its screen view key namespace', () {
    for (final screen in accessTree.screens) {
      for (final action in screen.actions) {
        expect(
          action.permissionKey.contains('.'),
          isTrue,
          reason: '${action.permissionKey} must be a dotted key',
        );
      }
    }
  });

  test('catalog runtime permissions map back to the tree keys', () {
    for (final screen in accessTree.screens) {
      final permissions = accessTree.permissionsForKey(
        screen.viewPermissionKey,
      );
      expect(
        permissions,
        isNotEmpty,
        reason: '${screen.viewPermissionKey} has no runtime permission',
      );
    }
  });
}


