import 'package:modular_erp/platform/auth/domain/policies/account_role_templates.dart';
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

/// Permission ceiling: local provisioning can never grant rights the actor lacks.
/// Roles select a grant template, not implicit authority.
class AccountRolePolicy {
  const AccountRolePolicy();
  List<AppRole> available(AuthContext actor) {
    final p = PermissionChecker(actor.user.permissions);
    if (!p.can(AppPermission.employeeCreate) &&
        !p.can(AppPermission.employeeUpdate)) {
      return const [];
    }
    return <AppRole>[
          AppRole.employee,
          if (p.can(AppPermission.attendanceApprove) &&
              (p.can(AppPermission.employeeViewTeam) ||
                  p.can(AppPermission.employeeViewAll)))
            AppRole.manager,
          if (p.can(AppPermission.employeeViewAll) &&
              p.can(AppPermission.employeeCreate) &&
              p.can(AppPermission.employeeDeactivate))
            AppRole.hr,
          if (p.can(AppPermission.roleManage) &&
              p.can(AppPermission.userManage) &&
              p.can(AppPermission.companyManage))
            AppRole.companyAdmin,
        ]
        .where(
          (role) => permissionsForRole(
            role,
          ).values.every((permission) => grantAllowed(actor, permission)),
        )
        .toList(growable: false);
    // Super Admin is never provisioned through a company Employee form.
  }
}

bool grantAllowed(AuthContext actor, AppPermission permission) {
  final p = PermissionChecker(actor.user.permissions);
  if (p.can(permission)) return true;
  // Administrative provisioning may grant employee self-service grants even
  // when the administrator is not themselves linked to an employee. Granting
  // self-service access is an administrative act, not a capability escalation.
  const selfService = {
    AppPermission.employeeViewSelf,
    AppPermission.attendanceViewSelf,
    AppPermission.attendancePunchIn,
    AppPermission.attendancePunchOut,
    AppPermission.attendanceBreak,
    AppPermission.attendanceRequestCorrection,
    AppPermission.leaveViewSelf,
    AppPermission.leaveRequest,
    AppPermission.leaveCancelSelf,
    AppPermission.leaveBalanceViewSelf,
  };
  if (selfService.contains(permission) &&
      p.can(AppPermission.userManage) &&
      (p.can(AppPermission.employeeCreate) ||
          p.can(AppPermission.employeeUpdate))) {
    return true;
  }
  return permission == AppPermission.employeeViewTeam &&
          p.can(AppPermission.employeeViewAll) ||
      permission == AppPermission.attendanceViewTeam &&
          p.can(AppPermission.attendanceViewAll) ||
      permission == AppPermission.leaveViewTeam &&
          p.can(AppPermission.leaveViewAll) ||
      permission == AppPermission.leaveApproveTeam &&
          p.can(AppPermission.leaveApproveAll) ||
      permission == AppPermission.leaveBalanceViewTeam &&
          p.can(AppPermission.leaveBalanceViewAll);
}
