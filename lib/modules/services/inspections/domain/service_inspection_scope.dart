import 'package:modular_erp/core/security/access_scope_resolver.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Resolved visibility scope for Inspections.
enum ServiceInspectionScope { none, assigned, team, all }

/// Resolves the broadest granted Inspection view scope.
///
/// ASSIGNED includes inspections where the linked employee is the technician,
/// is directly assigned on the source Job Assignment, or belongs to an assigned
/// Service Team. TEAM uses the Services team scope (never ALL). ALL is company.
class ServiceInspectionScopeResolver {
  const ServiceInspectionScopeResolver();

  ServiceInspectionScope resolve(AuthContext context) {
    if (!context.company.enabledModules.contains('services')) {
      return ServiceInspectionScope.none;
    }
    return switch (const AccessScopeResolver().resolve(
      context.user.permissions,
      all: AppPermission.serviceInspectionViewAll,
      team: AppPermission.serviceInspectionViewTeam,
      assigned: AppPermission.serviceInspectionViewAssigned,
    )) {
      PermissionScope.all => ServiceInspectionScope.all,
      PermissionScope.team => ServiceInspectionScope.team,
      PermissionScope.assigned => ServiceInspectionScope.assigned,
      _ => ServiceInspectionScope.none,
    };
  }
}
