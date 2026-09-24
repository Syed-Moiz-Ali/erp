import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_scope.dart';

/// The single source of truth for **which granted record scope wins**.
///
/// Every module scope resolver delegates here instead of re-implementing the
/// `all > team > assigned > self > none` precedence. Pass the runtime
/// [AppPermission] that represents each scope for the domain; the broadest
/// granted scope is returned. This keeps scope resolution identical across
/// employees, attendance, leave, reports and the dashboard, and free of any
/// role-based logic.
class AccessScopeResolver {
  const AccessScopeResolver();

  PermissionScope resolve(
    PermissionSet permissions, {
    AppPermission? all,
    AppPermission? team,
    AppPermission? assigned,
    AppPermission? self,
  }) {
    if (all != null && permissions.contains(all)) return PermissionScope.all;
    if (team != null && permissions.contains(team)) {
      return PermissionScope.team;
    }
    if (assigned != null && permissions.contains(assigned)) {
      return PermissionScope.assigned;
    }
    if (self != null && permissions.contains(self)) return PermissionScope.self;
    return PermissionScope.none;
  }
}
