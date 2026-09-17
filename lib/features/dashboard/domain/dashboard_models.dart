enum DashboardScope { none, self, team, company }

enum DashboardMetricKind {
  employees,
  teamSize,
  present,
  late,
  absent,
  leave,
  working,
  onBreak,
  corrections,
  hours,
  attendanceRate,
  locations,
  users,
}

enum DashboardActivityKind { checkedIn, breakStarted, correctionSubmitted }

enum DashboardAlertKind { lateArrivals, pendingCorrections }

class DashboardMetric {
  const DashboardMetric(this.kind, this.value);
  final DashboardMetricKind kind;

  /// Counts, hours, or a 0–1 ratio for attendanceRate.
  final num value;
}

class DashboardActivity {
  const DashboardActivity({
    required this.kind,
    required this.person,
    required this.timestamp,
  });
  final DashboardActivityKind kind;
  final String person;
  final DateTime timestamp;
}

class DashboardAlert {
  const DashboardAlert(this.kind, this.count);
  final DashboardAlertKind kind;
  final int count;
}

class DashboardStatusSummary {
  const DashboardStatusSummary({
    required this.onTime,
    required this.late,
    required this.absent,
    required this.onLeave,
  });
  final int onTime, late, absent, onLeave;
  int get total => onTime + late + absent + onLeave;
  int get present => onTime + late;
}

class DashboardToday {
  const DashboardToday({required this.shiftStart, required this.shiftEnd});
  final DateTime shiftStart, shiftEnd;
  // This is a display-only preview; no attendance workflow state is stored.
}

class DashboardSummary {
  DashboardSummary({
    required this.scope,
    required this.asOf,
    required this.isDemo,
    List<DashboardMetric> metrics = const [],
    List<DashboardActivity> activities = const [],
    List<DashboardAlert> alerts = const [],
    this.status,
    this.today,
  }) : metrics = List.unmodifiable(metrics),
       activities = List.unmodifiable(activities),
       alerts = List.unmodifiable(alerts);
  final DashboardScope scope;
  final DateTime asOf;
  final bool isDemo;
  final List<DashboardMetric> metrics;
  final List<DashboardActivity> activities;
  final List<DashboardAlert> alerts;
  final DashboardStatusSummary? status;
  final DashboardToday? today;
  bool get isEmpty =>
      metrics.isEmpty &&
      activities.isEmpty &&
      alerts.isEmpty &&
      status == null &&
      today == null;
}
