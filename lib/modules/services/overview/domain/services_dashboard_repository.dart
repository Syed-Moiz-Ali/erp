import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/services/overview/domain/services_dashboard.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Read-only Services dashboard projection contract.
///
/// Implementations must resolve permission and record scope **before** reading,
/// so a restricted domain is never queried and no all-company data is loaded
/// then hidden. There are deliberately no mutation methods here.
abstract interface class ServicesDashboardRepository {
  /// Reads the whole snapshot once. Used by the universal dashboard
  /// contribution so it never opens a long-lived stream per frame.
  Future<ServicesDashboardSnapshot> load(AuthContext context);

  /// A live snapshot that recomputes whenever any underlying Services record
  /// changes, without manual refresh. It is assembled from batched projections
  /// (no per-item Customer/Site/Employee queries).
  Stream<Result<ServicesDashboardSnapshot>> watch(AuthContext context);
}
