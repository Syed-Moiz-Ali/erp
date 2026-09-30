import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/workspace/dashboard/domain/dashboard_contribution.dart';

/// A module-owned dashboard read contract.
///
/// Each business module registers exactly one contributor. The universal
/// dashboard never imports a module DAO, Drift table or bloc: it only receives
/// the typed [DashboardContribution] this contributor builds from the module's
/// own public read models, already filtered by permission and record scope.
abstract interface class DashboardContributor {
  /// Stable contributor id (unique per registration).
  String get id;

  /// Owning module id, used for the subtle module tag and future module checks.
  String get moduleId;

  /// Lower order renders first when sections are composed.
  int get order;

  /// Whether this module may contribute for the current capability context.
  /// A false result must mean the contributor performs no reads at all.
  bool isVisible(DashboardCapabilityContext context);

  /// Loads only authorized, scope-filtered data and maps it to a typed
  /// contribution. Implementations must catch nothing that would leak data:
  /// the coordinator isolates failures per contributor.
  Future<DashboardContribution> load(DashboardCapabilityContext context);
}

/// Gathers every visible contributor into one merged snapshot.
///
/// A contributor failure degrades that module's section only: the coordinator
/// records a partial failure and keeps every other contribution, so a broken
/// Services read never blanks HR My Day.
class UniversalDashboardCoordinator {
  const UniversalDashboardCoordinator(
    this.contributors, {
    this.clock,
    this.businessToday,
  });

  final List<DashboardContributor> contributors;
  final AppClock? clock;

  /// Resolves the company-local business date for the active session using the
  /// application clock + company timezone. Injected by the composition root so
  /// the platform dashboard stays free of any HR/time-zone dependency.
  final DateTime? Function(AuthContext auth)? businessToday;

  Future<UniversalDashboardSnapshot> load(
    DashboardCapabilityContext context,
  ) async {
    final ordered = [...contributors]
      ..sort((a, b) {
        final order = a.order.compareTo(b.order);
        return order != 0 ? order : a.id.compareTo(b.id);
      });
    final results = <DashboardContribution>[];
    var partialFailure = false;
    for (final contributor in ordered) {
      bool visible;
      try {
        visible = contributor.isVisible(context);
      } catch (_) {
        visible = false;
      }
      if (!visible) continue;
      try {
        results.add(await contributor.load(context));
      } catch (_) {
        partialFailure = true;
      }
    }
    return UniversalDashboardSnapshot(
      contributions: results,
      generatedAt: (clock ?? const SystemAppClock()).now(),
      today: businessToday?.call(context.auth),
      partialFailure: partialFailure,
    );
  }
}
