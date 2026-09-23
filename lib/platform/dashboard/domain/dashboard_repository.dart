import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'dashboard_models.dart';

abstract interface class DashboardRepository {
  /// Read the local snapshot. Later refreshes update the local store first.
  /// The explicit context prevents global auth dependencies and cache leakage.
  Future<Result<DashboardSummary>> load(
    AuthContext context, {
    bool refresh = false,
  });
}
