import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';

/// Optional capability: a repository that can persist the effective permission
/// set computed from grants back into the stored session, so record-scope
/// queries (which read the session context) reflect live grant changes.
abstract interface class SessionPermissionSink {
  Future<void> applyEffectivePermissions(PermissionSet permissions);
}

abstract interface class AuthRepository {
  Future<Result<AuthContext?>> restoreSession();
  Future<Result<AuthContext?>> checkSession();
  Future<Result<AuthContext>> login(AuthIdentifier identifier, String password);
  Future<Result<void>> logout();
  Future<Result<void>> requestPasswordReset(AuthIdentifier identifier);
  Future<Result<void>> changePassword(
    String currentPassword,
    String newPassword,
  );

  /// Repository-owned lifecycle signal: expiry, refresh or context replacement.
  Stream<AuthContext?> get sessionChanges;
  Future<void> dispose();
}
