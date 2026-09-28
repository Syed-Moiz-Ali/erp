import 'package:modular_erp/core/security/access_scope_resolver.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Resolved visibility scope for Work Executions.
enum ServiceWorkExecutionScope { none, assigned, team, all }

/// Resolves the broadest granted Work Execution view scope.
///
/// ASSIGNED includes executions where the linked employee is directly assigned
/// on a work line, is relevant through the source Job Assignment assignment, or
/// belongs to an assigned Service Team. TEAM uses the Services team scope and
/// never expands to ALL. ALL remains company-scoped.
class ServiceWorkExecutionScopeResolver {
  const ServiceWorkExecutionScopeResolver();

  ServiceWorkExecutionScope resolve(AuthContext context) {
    if (!context.company.enabledModules.contains('services')) {
      return ServiceWorkExecutionScope.none;
    }
    return switch (const AccessScopeResolver().resolve(
      context.user.permissions,
      all: AppPermission.serviceWorkExecutionViewAll,
      team: AppPermission.serviceWorkExecutionViewTeam,
      assigned: AppPermission.serviceWorkExecutionViewAssigned,
    )) {
      PermissionScope.all => ServiceWorkExecutionScope.all,
      PermissionScope.team => ServiceWorkExecutionScope.team,
      PermissionScope.assigned => ServiceWorkExecutionScope.assigned,
      _ => ServiceWorkExecutionScope.none,
    };
  }
}
