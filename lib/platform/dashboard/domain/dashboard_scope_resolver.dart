import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'dashboard_models.dart';

class DashboardScopeResolver {
  const DashboardScopeResolver();
  DashboardScope resolve(AuthContext context) {
    if (!context.company.enabledModules.contains('attendance')) {
      return DashboardScope.none;
    }
    final can = PermissionChecker(context.user.permissions).can;
    if (can(AppPermission.attendanceViewAll)) return DashboardScope.company;
    if (can(AppPermission.attendanceViewTeam)) return DashboardScope.team;
    if (can(AppPermission.attendanceViewSelf)) return DashboardScope.self;
    return DashboardScope.none;
  }
}
