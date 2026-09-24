import 'package:modular_erp/core/security/access_scope_resolver.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'employee.dart';

class EmployeeScopeResolver {
  const EmployeeScopeResolver();
  EmployeeScope resolve(AuthContext context) {
    if (!context.company.enabledModules.contains('employees')) {
      return EmployeeScope.none;
    }
    return switch (const AccessScopeResolver().resolve(
      context.user.permissions,
      all: AppPermission.employeeViewAll,
      team: AppPermission.employeeViewTeam,
      self: AppPermission.employeeViewSelf,
    )) {
      PermissionScope.all => EmployeeScope.all,
      PermissionScope.team => EmployeeScope.team,
      PermissionScope.self => EmployeeScope.self,
      _ => EmployeeScope.none,
    };
  }
}
