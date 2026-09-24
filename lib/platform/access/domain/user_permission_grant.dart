import 'package:modular_erp/core/security/permission_scope.dart';

/// Persisted, company-scoped explicit permission grant.
class UserPermissionGrant {
  const UserPermissionGrant({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.permissionKey,
    required this.scope,
    required this.grantedByUserId,
    required this.grantedAt,
    required this.updatedAt,
    required this.syncStatus,
    this.expiresAt,
    this.isActive = true,
    this.requestId,
  });
  final String id, companyId, userId, permissionKey;
  final PermissionScope scope;
  final String grantedByUserId;
  final DateTime grantedAt, updatedAt;
  final DateTime? expiresAt;
  final bool isActive;
  final String? requestId;
  final String syncStatus;
}

/// Input for a grant replacement (one effective grant per permission key).
class PermissionGrantInput {
  const PermissionGrantInput({required this.key, required this.scope});
  final String key;
  final PermissionScope scope;

  ({String key, PermissionScope scope}) get asRecord =>
      (key: key, scope: scope);

  @override
  bool operator ==(Object other) =>
      other is PermissionGrantInput && other.key == key && other.scope == scope;
  @override
  int get hashCode => Object.hash(key, scope);
}
