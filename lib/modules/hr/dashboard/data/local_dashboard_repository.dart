import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/modules/hr/attendance/data/workforce_attendance_read_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_correction_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_correction.dart';
import 'package:modular_erp/modules/hr/attendance/domain/workforce_attendance.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_models.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_repository.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_scope_resolver.dart';
import 'demo_dashboard_source.dart';

class LocalDashboardRepository implements DashboardRepository {
  const LocalDashboardRepository({
    this.source = const DemoDashboardSource(),
    this.demoEnabled = true,
    this.scopeResolver = const DashboardScopeResolver(),
    this.workforce,
    this.corrections,
  });
  final DemoDashboardSource source;
  final bool demoEnabled;
  final DashboardScopeResolver scopeResolver;
  final WorkforceAttendanceReadRepository? workforce;
  final AttendanceCorrectionRepository? corrections;
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
      var raw = source.read(scope, context.user.displayName);
      if (workforce != null &&
          scope != DashboardScope.none &&
          scope != DashboardScope.self &&
          context.company.enabledModules.contains('attendance')) {
        raw = DashboardSummary(
          scope: scope,
          asOf: DateTime.now(),
          isDemo: false,
        );
        final date = await workforce!.companyToday();
        if (date is Success<DateTime>) {
          final result = await workforce!.read(
            date: date.value,
            scope: scope == DashboardScope.team
                ? AttendanceScope.team
                : AttendanceScope.company,
            filter: const WorkforceAttendanceFilter(pageSize: 100),
          );
          if (result is Success<WorkforceAttendancePage>) {
            final page = result.value;
            int count(WorkforceAttendanceState state) =>
                page.counts[state] ?? 0;
            final present =
                count(WorkforceAttendanceState.working) +
                count(WorkforceAttendanceState.onBreak) +
                count(WorkforceAttendanceState.completed);
            final late = page.lateCount;
            var pending = 0;
            if (corrections != null &&
                (PermissionChecker(
                      context.user.permissions,
                    ).can(AppPermission.attendanceApprove) ||
                    PermissionChecker(
                      context.user.permissions,
                    ).can(AppPermission.attendanceCorrect))) {
              final queue = await corrections!.watchPendingRequests().first;
              if (queue is Success<List<AttendanceCorrectionRequest>>) {
                pending = queue.value.length;
              }
            }
            final status = DashboardStatusSummary(
              onTime: present - late,
              late: late,
              absent: count(WorkforceAttendanceState.noRecord),
              onLeave: 0,
            );
            raw = DashboardSummary(
              scope: scope,
              asOf: DateTime.now(),
              isDemo: false,
              status: status,
              metrics: [
                DashboardMetric(
                  scope == DashboardScope.team
                      ? DashboardMetricKind.teamSize
                      : DashboardMetricKind.employees,
                  page.total,
                ),
                DashboardMetric(DashboardMetricKind.present, present),
                DashboardMetric(DashboardMetricKind.late, late),
                const DashboardMetric(DashboardMetricKind.leave, 0),
                DashboardMetric(
                  DashboardMetricKind.working,
                  count(WorkforceAttendanceState.working),
                ),
                DashboardMetric(
                  DashboardMetricKind.onBreak,
                  count(WorkforceAttendanceState.onBreak),
                ),
                DashboardMetric(DashboardMetricKind.corrections, pending),
                if (scope == DashboardScope.company)
                  DashboardMetric(
                    DashboardMetricKind.attendanceRate,
                    page.total == 0 ? 0 : present / page.total,
                  ),
              ],
              alerts: [
                if (late > 0)
                  DashboardAlert(DashboardAlertKind.lateArrivals, late),
                if (pending > 0)
                  DashboardAlert(
                    DashboardAlertKind.pendingCorrections,
                    pending,
                  ),
              ],
            );
          }
        }
      }
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
