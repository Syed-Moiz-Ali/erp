import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/backend_access_policy.dart';
import 'package:modular_erp/l10n/l10n.dart';

/// Permission-driven navigation source of truth.
///
/// Every in-scope screen owns exactly one backend view key and, optionally,
/// action keys. Navigation, route guards and quick links read this tree; no
/// destination may define its own permission mapping.
class AccessAction {
  const AccessAction({required this.id, required this.permissionKey});
  final String id;
  final String permissionKey;
}

class AccessScreen {
  const AccessScreen({
    required this.id,
    required this.moduleId,
    required this.submoduleId,
    required this.route,
    required this.viewPermissionKey,
    required this.name,
    this.actions = const [],
    this.routeActions = const {},
    this.showInNavigation = true,
    this.order = 0,
  });

  final String id;
  final String moduleId;
  final String submoduleId;
  final String route;
  final String viewPermissionKey;
  final LocalizedText name;
  final List<AccessAction> actions;

  /// Route suffix -> action id. Used for deep-link action guards (`/new`,
  /// `/edit`). The screen view key always guards the route itself.
  final Map<String, String> routeActions;
  final bool showInNavigation;
  final int order;

  AccessAction? action(String id) {
    for (final action in actions) {
      if (action.id == id) return action;
    }
    return null;
  }

  bool owns(String path) => path == route || path.startsWith('$route/');

  String? requiredActionId(String path) {
    if (!owns(path)) return null;
    for (final entry in routeActions.entries) {
      if (path.endsWith(entry.key)) return entry.value;
    }
    return null;
  }
}

class AccessSubmodule {
  const AccessSubmodule({
    required this.id,
    required this.name,
    required this.screens,
    this.order = 0,
  });
  final String id;
  final LocalizedText name;
  final List<AccessScreen> screens;
  final int order;
}

class AccessModule {
  const AccessModule({
    required this.id,
    required this.name,
    required this.submodules,
    this.order = 0,
  });
  final String id;
  final LocalizedText name;
  final List<AccessSubmodule> submodules;
  final int order;
}

class AccessTree {
  const AccessTree(this.modules);

  final List<AccessModule> modules;

  List<AccessScreen> get screens => [
    for (final module in modules)
      for (final submodule in module.submodules) ...submodule.screens,
  ];

  AccessScreen? screen(String id) {
    for (final screen in screens) {
      if (screen.id == id) return screen;
    }
    return null;
  }

  AccessModule? module(String id) {
    for (final module in modules) {
      if (module.id == id) return module;
    }
    return null;
  }

  /// Longest route prefix wins, so a nested screen such as
  /// `/app/settings/access/permissions` is not swallowed by its parent.
  AccessScreen? screenForPath(String path) {
    final candidates = screens.where((screen) => screen.owns(path)).toList()
      ..sort((a, b) => b.route.length.compareTo(a.route.length));
    return candidates.firstOrNull;
  }

  Set<AppPermission> permissionsForKey(String key) =>
      BackendAccessPolicy.keyPermissions[key] ?? const <AppPermission>{};

  bool canView(AccessScreen screen, PermissionSet permissions) {
    final required = permissionsForKey(screen.viewPermissionKey);
    return required.any(permissions.contains);
  }

  bool canAction(
    AccessScreen screen,
    String actionId,
    PermissionSet permissions,
  ) {
    final action = screen.action(actionId);
    if (action == null) return false;
    final required = permissionsForKey(action.permissionKey);
    return required.any(permissions.contains);
  }

  bool canOpen(AccessScreen screen, PermissionSet permissions) =>
      canView(screen, permissions);

  bool canOpenRoute(
    AccessScreen screen,
    String path,
    PermissionSet permissions,
  ) {
    if (!canView(screen, permissions)) return false;
    final actionId = screen.requiredActionId(path);
    return actionId == null || canAction(screen, actionId, permissions);
  }

  String? missingKeyForRoute(
    AccessScreen screen,
    String path,
    PermissionSet permissions,
  ) {
    if (!canView(screen, permissions)) return screen.viewPermissionKey;
    final actionId = screen.requiredActionId(path);
    if (actionId == null) return null;
    final action = screen.action(actionId);
    if (action == null || canAction(screen, actionId, permissions)) {
      return null;
    }
    return action.permissionKey;
  }

  List<AccessScreen> visibleScreens(PermissionSet permissions) => [
    for (final screen in screens)
      if (canView(screen, permissions)) screen,
  ];

  List<AccessScreen> visibleNavigationScreens(PermissionSet permissions) => [
    for (final screen in visibleScreens(permissions))
      if (screen.showInNavigation) screen,
  ];

  bool isModuleVisible(AccessModule module, PermissionSet permissions) => module
      .submodules
      .any((submodule) => isSubmoduleVisible(submodule, permissions));

  bool isSubmoduleVisible(
    AccessSubmodule submodule,
    PermissionSet permissions,
  ) => submodule.screens.any((screen) => canView(screen, permissions));

  List<AccessModule> visibleModules(PermissionSet permissions) => [
    for (final module in modules)
      if (isModuleVisible(module, permissions)) module,
  ];

  Set<AppPermission> get allViewPermissions => {
    for (final screen in screens)
      ...permissionsForKey(screen.viewPermissionKey),
  };

  Set<String> get allPermissionKeys => {
    for (final screen in screens) ...[
      screen.viewPermissionKey,
      for (final action in screen.actions) action.permissionKey,
    ],
  };
}

/// The single approved MassERP access tree for the in-scope modules.
final accessTree = AccessTree([
  AccessModule(
    id: 'hr',
    name: _nodeName('navSectionHr'),
    order: 10,
    submodules: [
      AccessSubmodule(
        id: 'employees',
        name: _nodeName('employees'),
        order: 10,
        screens: [
          AccessScreen(
            id: 'hr.employees',
            moduleId: 'hr',
            submoduleId: 'employees',
            route: AppRoutes.liveEmployees,
            viewPermissionKey: 'hr.employees.view',
            name: _nodeName('employees'),
            order: 10,
            actions: [
              AccessAction(id: 'create', permissionKey: 'hr.employees.create'),
              AccessAction(id: 'edit', permissionKey: 'hr.employees.edit'),
              AccessAction(
                id: 'deactivate',
                permissionKey: 'hr.employees.deactivate',
              ),
              AccessAction(id: 'login', permissionKey: 'company.users.manage'),
            ],
            routeActions: {'/new': 'create', '/edit': 'edit'},
          ),
        ],
      ),
      AccessSubmodule(
        id: 'departments',
        name: _nodeName('cfgDepartments'),
        order: 20,
        screens: [
          AccessScreen(
            id: 'hr.departments',
            moduleId: 'hr',
            submoduleId: 'departments',
            route: AppRoutes.departments,
            viewPermissionKey: 'hr.departments.view',
            name: _nodeName('cfgDepartments'),
            order: 10,
            actions: [
              AccessAction(
                id: 'manage',
                permissionKey: 'hr.departments.manage',
              ),
            ],
            routeActions: {'/new': 'manage', '/edit': 'manage'},
          ),
        ],
      ),
      AccessSubmodule(
        id: 'attendance',
        name: _nodeName('attendanceTodayTitle'),
        order: 30,
        screens: [
          AccessScreen(
            id: 'hr.attendance.self',
            moduleId: 'hr',
            submoduleId: 'attendance',
            route: AppRoutes.liveAttendance,
            viewPermissionKey: 'hr.attendance.self.view',
            name: _nodeName('attendanceTodayTitle'),
            order: 10,
            actions: [
              AccessAction(
                id: 'punch',
                permissionKey: 'hr.attendance.self.punch',
              ),
            ],
          ),
          AccessScreen(
            id: 'hr.attendance.shifts',
            moduleId: 'hr',
            submoduleId: 'attendance',
            route: AppRoutes.shifts,
            viewPermissionKey: 'hr.attendance.shifts.view',
            name: _nodeName('cfgShifts'),
            order: 20,
            actions: [
              AccessAction(
                id: 'manage',
                permissionKey: 'hr.attendance.shifts.manage',
              ),
            ],
            routeActions: {'/new': 'manage', '/edit': 'manage'},
          ),
          AccessScreen(
            id: 'hr.attendance.employeeShifts',
            moduleId: 'hr',
            submoduleId: 'attendance',
            route: AppRoutes.employeeShifts,
            viewPermissionKey: 'hr.attendance.shifts.view',
            name: _nodeName('employeeShiftsTitle'),
            order: 30,
            actions: [
              AccessAction(
                id: 'manage',
                permissionKey: 'hr.attendance.shifts.manage',
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  AccessModule(
    id: 'company',
    name: _nodeName('navSectionSettings'),
    order: 20,
    submodules: [
      AccessSubmodule(
        id: 'branches',
        name: _nodeName('branchTitle'),
        order: 10,
        screens: [
          AccessScreen(
            id: 'company.branches',
            moduleId: 'company',
            submoduleId: 'branches',
            route: AppRoutes.branches,
            viewPermissionKey: 'company.branches.view',
            name: _nodeName('branchTitle'),
            order: 10,
            actions: [
              AccessAction(
                id: 'manage',
                permissionKey: 'company.branches.manage',
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  AccessModule(
    id: 'access',
    name: _nodeName('accessManage'),
    order: 30,
    submodules: [
      AccessSubmodule(
        id: 'permissions',
        name: _nodeName('accessPermissionCatalog'),
        order: 10,
        screens: [
          AccessScreen(
            id: 'access.users',
            moduleId: 'access',
            submoduleId: 'permissions',
            route: AppRoutes.access,
            viewPermissionKey: 'company.access.users.view',
            name: _nodeName('usersAccessTitle'),
            order: 10,
            actions: [
              AccessAction(
                id: 'manage',
                permissionKey: 'company.access.permissions.manage',
              ),
            ],
          ),
          AccessScreen(
            id: 'access.permissions',
            moduleId: 'access',
            submoduleId: 'permissions',
            route: AppRoutes.permissionMasters,
            viewPermissionKey: 'company.access.users.view',
            name: _nodeName('accessPermissionCatalog'),
            order: 20,
            showInNavigation: false,
            actions: [
              AccessAction(
                id: 'manage',
                permissionKey: 'company.access.permissions.manage',
              ),
            ],
          ),
        ],
      ),
    ],
  ),
]);

/// Const-compatible localization callback factory.
LocalizedText _nodeName(String key) =>
    (l10n) => switch (key) {
      'navSectionHr' => l10n.navSectionHr,
      'navSectionSettings' => l10n.navSectionSettings,
      'employees' => l10n.employees,
      'cfgDepartments' => l10n.cfgDepartments,
      'cfgShifts' => l10n.cfgShifts,
      'attendanceTodayTitle' => l10n.attendanceTodayTitle,
      'employeeShiftsTitle' => l10n.employeeShiftsTitle,
      'branchTitle' => l10n.branchTitle,
      'accessManage' => l10n.accessManage,
      'accessPermissionCatalog' => l10n.accessPermissionCatalog,
      'usersAccessTitle' => l10n.usersAccessTitle,
      _ => key,
    };
