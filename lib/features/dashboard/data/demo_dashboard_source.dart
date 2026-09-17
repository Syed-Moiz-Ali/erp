import '../domain/dashboard_models.dart';

/// Deterministic, display-only fixtures. No employees or attendance records
/// are created, and no writes/remote requests occur.
class DemoDashboardSource {
  const DemoDashboardSource();
  static final asOf = DateTime(2026, 9, 17, 12, 30);
  DashboardSummary read(DashboardScope scope, String person) {
    if (scope == DashboardScope.none) {
      return DashboardSummary(scope: scope, asOf: asOf, isDemo: true);
    }
    final self = scope == DashboardScope.self;
    final team = scope == DashboardScope.team;
    final status = self
        ? null
        : team
        ? const DashboardStatusSummary(
            onTime: 8,
            late: 1,
            absent: 1,
            onLeave: 2,
          )
        : const DashboardStatusSummary(
            onTime: 68,
            late: 5,
            absent: 4,
            onLeave: 7,
          );
    final corrections = team ? 2 : 6;
    return DashboardSummary(
      scope: scope,
      asOf: asOf,
      isDemo: true,
      status: status,
      today: self
          ? DashboardToday(
              shiftStart: DateTime(2026, 9, 17, 9),
              shiftEnd: DateTime(2026, 9, 17, 18),
            )
          : null,
      metrics: self
          ? const [
              DashboardMetric(DashboardMetricKind.present, 17),
              DashboardMetric(DashboardMetricKind.late, 2),
              DashboardMetric(DashboardMetricKind.leave, 1),
              DashboardMetric(DashboardMetricKind.hours, 138),
            ]
          : [
              DashboardMetric(
                team
                    ? DashboardMetricKind.teamSize
                    : DashboardMetricKind.employees,
                status!.total,
              ),
              DashboardMetric(DashboardMetricKind.present, status.present),
              DashboardMetric(DashboardMetricKind.late, status.late),
              DashboardMetric(DashboardMetricKind.leave, status.onLeave),
              DashboardMetric(DashboardMetricKind.working, team ? 8 : 70),
              DashboardMetric(DashboardMetricKind.onBreak, team ? 1 : 3),
              DashboardMetric(DashboardMetricKind.corrections, corrections),
              if (!team) ...const [
                DashboardMetric(DashboardMetricKind.attendanceRate, 73 / 84),
                DashboardMetric(DashboardMetricKind.locations, 3),
                DashboardMetric(DashboardMetricKind.users, 90),
              ],
            ],
      alerts: self
          ? const []
          : [
              DashboardAlert(DashboardAlertKind.lateArrivals, status!.late),
              DashboardAlert(
                DashboardAlertKind.pendingCorrections,
                corrections,
              ),
            ],
      activities: [
        DashboardActivity(
          kind: DashboardActivityKind.checkedIn,
          person: self ? person : 'Ahmed Khan',
          timestamp: DateTime(2026, 9, self ? 16 : 17, 9, 3),
        ),
        DashboardActivity(
          kind: DashboardActivityKind.breakStarted,
          person: self ? person : 'Sara Rahman',
          timestamp: DateTime(2026, 9, self ? 16 : 17, 11, 24),
        ),
        DashboardActivity(
          kind: DashboardActivityKind.correctionSubmitted,
          person: self ? person : 'Ahmed Khan',
          timestamp: DateTime(2026, 9, 16, 16, 40),
        ),
      ]..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
    );
  }
}
