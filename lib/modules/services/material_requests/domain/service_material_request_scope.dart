import 'package:modular_erp/core/security/access_scope_resolver.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Resolved visibility scope for Material Requests.
enum ServiceMaterialRequestScope { none, assigned, team, all }

/// Resolves the broadest granted Material Request view scope.
///
/// ASSIGNED resolves from the source workflow relationships: the Inspection
/// technician, a direct employee on the source Job Assignment, or membership of
/// an assigned Service Team. TEAM uses the Services team scope and never
/// silently becomes company-wide. ALL is company-scoped.
class ServiceMaterialRequestScopeResolver {
  const ServiceMaterialRequestScopeResolver();

  ServiceMaterialRequestScope resolve(AuthContext context) {
    if (!context.company.enabledModules.contains('services')) {
      return ServiceMaterialRequestScope.none;
    }
    return switch (const AccessScopeResolver().resolve(
      context.user.permissions,
      all: AppPermission.serviceMaterialRequestViewAll,
      team: AppPermission.serviceMaterialRequestViewTeam,
      assigned: AppPermission.serviceMaterialRequestViewAssigned,
    )) {
      PermissionScope.all => ServiceMaterialRequestScope.all,
      PermissionScope.team => ServiceMaterialRequestScope.team,
      PermissionScope.assigned => ServiceMaterialRequestScope.assigned,
      _ => ServiceMaterialRequestScope.none,
    };
  }
}
