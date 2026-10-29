import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/platform/access/domain/effective_access.dart';

/// Single mapping from MassERP backend permission keys to the runtime
/// [AppPermission] set.
///
/// The backend has no scopes. For scoped client permissions we grant the
/// broadest client scope (ALL) because that is the only truthful reading of a
/// key-only grant. Self-service keys (for example
/// `hr.attendance.self.view`) remain SELF by their own semantics.
///
/// Module entitlement is intentionally **derived here** because the backend
/// exposes no enabled-modules endpoint. This derivation is the one place to
/// replace when the backend supplies real entitlement (see
/// `docs/client-decisions.md` and `docs/backend-handoff.md`).
abstract final class BackendAccessPolicy {
  const BackendAccessPolicy._();

  static const Map<String, Set<AppPermission>> keyPermissions = {
    'company.access.permissions.manage': {
      AppPermission.accessPermissionsManage,
    },
    'company.access.users.view': {AppPermission.accessUsersView},
    'hr.departments.manage': {AppPermission.departmentManage},
    'hr.departments.view': {AppPermission.departmentView},
    // Branch keys are added when the Branches module is approved.
    'company.users.manage': {AppPermission.userManage},
    'hr.attendance.self.punch': {
      AppPermission.attendancePunchIn,
      AppPermission.attendancePunchOut,
      AppPermission.attendanceBreak,
    },
    'hr.attendance.self.view': {AppPermission.attendanceViewSelf},
    'hr.attendance.shifts.manage': {AppPermission.shiftManage},
    'hr.attendance.shifts.view': {AppPermission.shiftView},
    'hr.employees.create': {AppPermission.employeeCreate},
    'hr.employees.deactivate': {AppPermission.employeeDeactivate},
    'hr.employees.edit': {AppPermission.employeeUpdate},
    'hr.employees.view': {AppPermission.employeeViewAll},
  };

  /// Backend keys the client understands. Used by the catalog/UI to hide
  /// client-only permissions in backend mode.
  static Set<String> get backendKeys => keyPermissions.keys.toSet();

  static bool supports(String key) => keyPermissions.containsKey(key);

  /// Applies the key-only backend grant set. Unknown keys fail closed (ignored)
  /// and are returned separately for diagnostics.
  static EffectiveAccess resolve(Iterable<String> keys) {
    final grants = keys
        .map((key) => key.trim().toLowerCase())
        .where((key) => key.isNotEmpty)
        .toSet();
    final permissions = <AppPermission>{};
    final known = <String>{};
    for (final key in grants) {
      final mapped = keyPermissions[key];
      if (mapped == null) continue;
      known.add(key);
      permissions.addAll(mapped);
    }
    final scopes = <AppPermission, PermissionScope>{};
    if (permissions.contains(AppPermission.employeeViewAll)) {
      scopes[AppPermission.employeeViewAll] = PermissionScope.all;
    }
    return EffectiveAccess(
      permissions: PermissionSet(permissions, scopes: scopes),
      enabledModules: enabledModulesFor(permissions),
      permissionKeys: grants.toList(growable: false)..sort(),
      unknownKeys: grants.difference(known).toList(growable: false)..sort(),
    );
  }

  /// Derives company module flags from granted runtime permissions.
  ///
  /// This is an explicit client assumption, not backend data. The dashboard and
  /// account modules are always available independently of this set.
  static Set<String> enabledModulesFor(Set<AppPermission> permissions) {
    const moduleEmployees = 'employees';
    const moduleAttendance = 'attendance';
    const moduleSettings = 'settings';
    final modules = <String>{};
    if (permissions.any(_employeePermissions.contains)) {
      modules.add(moduleEmployees);
    }
    if (permissions.any(_attendancePermissions.contains)) {
      modules.add(moduleAttendance);
    }
    if (permissions.any(_settingsPermissions.contains)) {
      modules.add(moduleSettings);
    }
    return Set.unmodifiable(modules);
  }

  static const Set<AppPermission> _employeePermissions = {
    AppPermission.employeeViewSelf,
    AppPermission.employeeViewTeam,
    AppPermission.employeeViewAll,
    AppPermission.employeeCreate,
    AppPermission.employeeUpdate,
    AppPermission.employeeDeactivate,
    AppPermission.userManage,
  };

  static const Set<AppPermission> _attendancePermissions = {
    AppPermission.attendanceViewSelf,
    AppPermission.attendancePunchIn,
    AppPermission.attendancePunchOut,
    AppPermission.attendanceBreak,
  };

  static const Set<AppPermission> _settingsPermissions = {
    AppPermission.shiftView,
    AppPermission.shiftManage,
    AppPermission.departmentView,
    AppPermission.departmentManage,
    AppPermission.accessUsersView,
    AppPermission.accessPermissionsManage,
  };
}
