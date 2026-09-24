import 'package:modular_erp/core/security/access_scope_resolver.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'dashboard_models.dart';

class DashboardScopeResolver {
  const DashboardScopeResolver();
  DashboardScope resolve(AuthContext context) {
    if (!context.company.enabledModules.contains('attendance')) {
      return DashboardScope.none;
    }
    return switch (const AccessScopeResolver().resolve(
      context.user.permissions,
      all: AppPermission.attendanceViewAll,
      team: AppPermission.attendanceViewTeam,
      self: AppPermission.attendanceViewSelf,
    )) {
      PermissionScope.all => DashboardScope.company,
      PermissionScope.team => DashboardScope.team,
      PermissionScope.self => DashboardScope.self,
      _ => DashboardScope.none,
    };
  }
}
