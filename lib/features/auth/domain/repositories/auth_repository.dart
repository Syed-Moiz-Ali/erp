import '../../../../core/errors/result.dart';
import '../entities/auth_context.dart';
import '../../../../core/auth/auth_identifier.dart';

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
