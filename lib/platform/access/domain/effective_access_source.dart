import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/access/domain/effective_access.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Loads the authoritative effective access for the current backend session.
///
/// Implementations must fail closed: a failed call returns [Failed] and the
/// caller must not reuse local/demo grants.
abstract interface class EffectiveAccessSource {
  Future<Result<EffectiveAccess>> load(AuthContext context);
}
