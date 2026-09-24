import 'package:modular_erp/core/security/access_scope_resolver.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Resolved visibility scope for Job Assignments.
enum ServiceJobAssignmentScope { none, assigned, team, all }

/// Resolves the broadest granted Job Assignment view scope.
///
/// ASSIGNED includes assignments where the linked employee is directly selected
/// on a line or belongs to an assigned Service Team. TEAM uses the Services team
/// scope and never silently becomes company-wide. ALL is company-scoped.
class ServiceJobAssignmentScopeResolver {
  const ServiceJobAssignmentScopeResolver();

  ServiceJobAssignmentScope resolve(AuthContext context) {
    if (!context.company.enabledModules.contains('services')) {
      return ServiceJobAssignmentScope.none;
    }
    return switch (const AccessScopeResolver().resolve(
      context.user.permissions,
      all: AppPermission.serviceJobAssignmentViewAll,
      team: AppPermission.serviceJobAssignmentViewTeam,
      assigned: AppPermission.serviceJobAssignmentViewAssigned,
    )) {
      PermissionScope.all => ServiceJobAssignmentScope.all,
      PermissionScope.team => ServiceJobAssignmentScope.team,
      PermissionScope.assigned => ServiceJobAssignmentScope.assigned,
      _ => ServiceJobAssignmentScope.none,
    };
  }
}
