import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_catalog.dart';
import 'package:modular_erp/core/security/permission_definition.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/platform/access/domain/user_permission_grant.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Why an access decision was refused.
enum AccessDecisionReason {
  allowed,
  notPermitted,
  selfEscalation,
  lastAccessAdmin,
  employeeLinkRequired,
  moduleDisabled,
  notDelegable,
  platformOnly,
}

class AccessDecision {
  const AccessDecision(this.allowed, [this.reason]);
  final bool allowed;
  final AccessDecisionReason? reason;
  static const allow = AccessDecision(true, AccessDecisionReason.allowed);
  static AccessDecision deny(AccessDecisionReason reason) =>
      AccessDecision(false, reason);
}

/// Central delegation rules for the Access UI. Access administration is
/// permission-driven, never role-driven.
class GrantAuthorityResolver {
  const GrantAuthorityResolver();

  bool _can(AuthContext actor, AppPermission permission) =>
      actor.user.permissions.contains(permission);

  AccessDecision canViewAccess(AuthContext actor) =>
      _can(actor, AppPermission.accessUsersView) ||
          _can(actor, AppPermission.accessPermissionsManage)
      ? AccessDecision.allow
      : AccessDecision.deny(AccessDecisionReason.notPermitted);

  AccessDecision canManageAccess(AuthContext actor) =>
      _can(actor, AppPermission.accessPermissionsManage)
      ? AccessDecision.allow
      : AccessDecision.deny(AccessDecisionReason.notPermitted);

  /// Self-escalation is refused by default.
  AccessDecision canEditTarget(AuthContext actor, String targetUserId) {
    if (!canManageAccess(actor).allowed) {
      return AccessDecision.deny(AccessDecisionReason.notPermitted);
    }
    if (actor.user.id == targetUserId) {
      return AccessDecision.deny(AccessDecisionReason.selfEscalation);
    }
    return AccessDecision.allow;
  }

  /// Grant ceiling: the actor may only delegate permissions within their own
  /// authority, in enabled modules, and only to linked employees where required.
  AccessDecision canGrant(
    AuthContext actor,
    PermissionDefinition definition, {
    required bool targetHasEmployeeLink,
    required bool moduleEnabled,
  }) {
    final platformAdmin =
        _can(actor, AppPermission.platformModulesManage) ||
        _can(actor, AppPermission.companyManage);
    if (definition.platformOnly) {
      return platformAdmin
          ? AccessDecision.allow
          : AccessDecision.deny(AccessDecisionReason.platformOnly);
    }
    if (!definition.delegable) {
      return platformAdmin
          ? AccessDecision.allow
          : AccessDecision.deny(AccessDecisionReason.notDelegable);
    }
    if (definition.moduleId != 'platform' && !moduleEnabled) {
      return AccessDecision.deny(AccessDecisionReason.moduleDisabled);
    }
    if (definition.requiresEmployeeLink && !targetHasEmployeeLink) {
      return AccessDecision.deny(AccessDecisionReason.employeeLinkRequired);
    }
    final actorHolds = definition.permissions.values.any(
      (permission) => _can(actor, permission),
    );
    if (actorHolds) return AccessDecision.allow;
    // Administrative provisioning may grant employee self-service to a linked
    // employee without the administrator themselves holding it.
    final provisionsEmployees =
        _can(actor, AppPermission.userManage) &&
        (_can(actor, AppPermission.employeeCreate) ||
            _can(actor, AppPermission.employeeUpdate));
    if (definition.requiresEmployeeLink && provisionsEmployees) {
      return AccessDecision.allow;
    }
    return AccessDecision.deny(AccessDecisionReason.notPermitted);
  }

  /// Validates a full replacement for [targetUserId].
  ///
  /// Enforces per-grant authority, self-escalation, the last-access-admin guard
  /// and module enablement.
  Result<void> validateReplacement(
    AuthContext actor, {
    required String targetUserId,
    required List<PermissionGrantInput> grants,
    required PermissionCatalog catalog,
    required Set<String> enabledModules,
    required bool targetHasEmployeeLink,
    required bool targetIsLastAccessAdmin,
  }) {
    if (!canEditTarget(actor, targetUserId).allowed) {
      return const Failed(
        Failure(code: 'access.notPermitted', kind: FailureKind.invalidData),
      );
    }
    if (targetIsLastAccessAdmin &&
        !catalog
            .permissionsFor(grants.map((g) => g.asRecord))
            .contains(AppPermission.accessPermissionsManage)) {
      return const Failed(
        Failure(code: 'access.lastAdmin', kind: FailureKind.invalidData),
      );
    }
    for (final grant in grants) {
      final definition = catalog.byKey(grant.key);
      if (definition == null) {
        return const Failed(
          Failure(
            code: 'access.unknownPermission',
            kind: FailureKind.invalidData,
          ),
        );
      }
      if (!definition.supportedScopes.contains(grant.scope)) {
        return const Failed(
          Failure(
            code: 'access.unsupportedScope',
            kind: FailureKind.invalidData,
          ),
        );
      }
      final decision = canGrant(
        actor,
        definition,
        targetHasEmployeeLink: targetHasEmployeeLink,
        moduleEnabled:
            definition.moduleId == 'platform' ||
            enabledModules.contains(definition.requiredFeature),
      );
      if (!decision.allowed) {
        return Failed(
          Failure(
            code: 'access.${decision.reason!.name}',
            kind: FailureKind.invalidData,
          ),
        );
      }
    }
    return const Success(null);
  }
}

/// A company user's grants when computing the last-access-admin guard.
bool holdsAccessManagement(
  PermissionCatalog catalog,
  Iterable<PermissionGrantInput> grants,
) => catalog
    .permissionsFor(grants.map((g) => g.asRecord))
    .contains(AppPermission.accessPermissionsManage);

/// Scope label used by the editor; falls back to the permission's catalog scope.
PermissionScope? grantedScope(
  PermissionCatalog catalog,
  Iterable<PermissionGrantInput> grants,
  AppPermission permission,
) {
  final definition = catalog.forPermission(permission);
  if (definition == null) return null;
  for (final grant in grants) {
    if (grant.key == definition.key) return grant.scope;
  }
  return null;
}
