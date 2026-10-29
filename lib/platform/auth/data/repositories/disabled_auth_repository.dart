import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';

/// Explicit safe failure used when no authentication implementation is
/// configured (for example a release build with no `API_BASE_URL` and demo mode
/// off). This guarantees the app never silently falls back to demo login and
/// produces an actionable, configuration-related error instead.
class DisabledAuthRepository implements AuthRepository {
  const DisabledAuthRepository();

  static const _notConfigured = Failure(
    code: 'auth_not_configured',
    kind: FailureKind.notConfigured,
  );

  @override
  Future<Result<AuthContext?>> restoreSession() async => const Success(null);

  @override
  Future<Result<AuthContext?>> checkSession() async => const Success(null);

  @override
  Future<Result<AuthContext>> login(
    AuthIdentifier identifier,
    String password,
  ) async => const Failed<AuthContext>(_notConfigured);

  @override
  Future<Result<void>> logout() async => const Success(null);

  @override
  Future<Result<void>> requestPasswordReset(AuthIdentifier identifier) async =>
      const Failed<void>(_notConfigured);

  @override
  Future<Result<void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async => const Failed<void>(_notConfigured);

  @override
  Stream<AuthContext?> get sessionChanges => const Stream<AuthContext?>.empty();

  @override
  Future<void> dispose() async {}
}
