import 'package:flutter/foundation.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_catalog.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/user_permission_grant.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Derives the effective [PermissionSet] for the current session from persisted
/// grants, and exposes a reactive stream so navigation/routes/actions update
/// live when grants change (Phase 0.6 §12/§68).
abstract interface class UserGrantsController {
  Future<PermissionSet> permissionsFor(AuthContext context);
  Stream<PermissionSet> watch(AuthContext context);
}

class LocalUserGrantsController implements UserGrantsController {
  LocalUserGrantsController(this.repository, this.catalog, this.clock);
  final AccessRepository repository;
  final PermissionCatalog catalog;
  final AppClock clock;

  PermissionSet _toSet(List<UserPermissionGrant> grants) {
    final now = clock.now();
    final active = grants.where(
      (grant) =>
          grant.isActive &&
          (grant.expiresAt == null || grant.expiresAt!.isAfter(now)),
    );
    final scopes = <AppPermission, PermissionScope>{};
    for (final grant in active) {
      final permission = catalog.permissionFor(
        grant.permissionKey,
        grant.scope,
      );
      if (permission != null) scopes[permission] = grant.scope;
    }
    return PermissionSet(
      catalog.permissionsFor(
        active.map((grant) => (key: grant.permissionKey, scope: grant.scope)),
      ),
      scopes: scopes,
    );
  }

  @override
  Future<PermissionSet> permissionsFor(AuthContext context) async {
    final result = await repository.getGrants(
      companyId: context.company.id,
      userId: context.user.id,
    );
    if (result is! Success<List<UserPermissionGrant>>) {
      // Never strip access on a transient read failure; keep the session set.
      return context.user.permissions;
    }
    return _toSet(result.value);
  }

  @override
  Stream<PermissionSet> watch(AuthContext context) => repository
      .watchGrants(companyId: context.company.id, userId: context.user.id)
      .map(_toSet)
      .distinct((a, b) => setEquals(a.values, b.values));
}
