import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_models.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Backend-mode dashboard source.
///
/// The backend exposes no dashboard endpoint, and v3 forbids showing local/demo
/// business data in backend mode. Returning an empty summary lets the existing
/// universal dashboard render its built-in empty state (no new UI, no call).
class EmptyDashboardRepository implements DashboardRepository {
  const EmptyDashboardRepository();

  @override
  Future<Result<DashboardSummary>> load(
    AuthContext context, {
    bool refresh = false,
  }) async => Success(
    DashboardSummary(
      scope: DashboardScope.none,
      asOf: DateTime.now().toUtc(),
      isDemo: false,
    ),
  );
}
