import '../../../core/errors/result.dart';
import '../../../core/security/app_permission.dart';
import '../../auth/domain/entities/auth_context.dart';
import '../domain/dashboard_models.dart';
import '../domain/dashboard_repository.dart';
import '../domain/dashboard_scope_resolver.dart';
import 'demo_dashboard_source.dart';

class LocalDashboardRepository implements DashboardRepository {
  const LocalDashboardRepository({
    this.source = const DemoDashboardSource(),
    this.demoEnabled = true,
    this.scopeResolver = const DashboardScopeResolver(),
  });
  final DemoDashboardSource source;
  final bool demoEnabled;
  final DashboardScopeResolver scopeResolver;
  @override
  Future<Result<DashboardSummary>> load(
    AuthContext context, {
    bool refresh = false,
  }) async {
    if (!demoEnabled) {
      return const Failed(
        Failure(
          code: 'dashboard.demo_disabled',
          kind: FailureKind.demoDisabled,
        ),
      );
    }
    try {
      final scope = scopeResolver.resolve(context);
      final raw = source.read(scope, context.user.displayName);
      final can = PermissionChecker(context.user.permissions).can;
      bool allowed(DashboardMetric m) => switch (m.kind) {
        DashboardMetricKind.employees =>
          context.company.enabledModules.contains('employees') &&
              can(AppPermission.employeeViewAll),
        DashboardMetricKind.teamSize =>
          context.company.enabledModules.contains('employees') &&
              (can(AppPermission.employeeViewTeam) ||
                  can(AppPermission.employeeViewAll)),
        DashboardMetricKind.locations => can(AppPermission.workLocationView),
        DashboardMetricKind.users =>
          context.company.enabledModules.contains('settings') &&
              can(AppPermission.userManage),
        DashboardMetricKind.corrections =>
          can(AppPermission.attendanceApprove) ||
              can(AppPermission.attendanceCorrect),
        _ => scope != DashboardScope.none,
      };
      final review =
          can(AppPermission.attendanceApprove) ||
          can(AppPermission.attendanceCorrect);
      return Success(
        DashboardSummary(
          scope: scope,
          asOf: raw.asOf,
          isDemo: raw.isDemo,
          metrics: raw.metrics.where(allowed).toList(),
          status: raw.status,
          today: raw.today,
          activities: raw.activities
              .where(
                (a) =>
                    a.kind != DashboardActivityKind.correctionSubmitted ||
                    scope == DashboardScope.self &&
                        can(AppPermission.attendanceRequestCorrection) ||
                    review,
              )
              .toList(),
          alerts: raw.alerts
              .where(
                (a) =>
                    a.kind != DashboardAlertKind.pendingCorrections || review,
              )
              .toList(),
        ),
      );
    } catch (_) {
      return const Failed(
        Failure(
          code: 'dashboard.local_read',
          kind: FailureKind.unknown,
          retryable: true,
        ),
      );
    }
  }
}
