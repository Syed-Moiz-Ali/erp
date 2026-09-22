import '../../attendance/domain/workforce_attendance.dart';

enum AttendanceReportType {
  overview,
  workHours,
  lateAttendance,
  breakAnalysis,
  issues,
  employeeSummary,
}

enum AttendanceReportPeriod { today, thisWeek, thisMonth, lastMonth, custom }

enum AttendanceReportSort { newest, oldest, employee, workedMost, breaksMost }

enum AttendanceReportGroup { department, shift, location }

class AttendanceReportOption {
  const AttendanceReportOption(this.id, this.name);
  final String id, name;
}

class AttendanceReportOptions {
  const AttendanceReportOptions({
    required this.employees,
    required this.departments,
    required this.shifts,
    required this.locations,
  });
  final List<AttendanceReportOption> employees, departments, shifts, locations;
}

class AttendanceReportFilter {
  AttendanceReportFilter({
    required this.period,
    required this.from,
    required this.to,
    required this.scope,
    Set<String> employeeIds = const {},
    Set<String> departmentIds = const {},
    Set<String> shiftIds = const {},
    Set<String> locationIds = const {},
    Set<String> statuses = const {},
    this.hasIssues,
    this.hasCorrections,
    this.group = AttendanceReportGroup.department,
  }) : employeeIds = Set.unmodifiable(employeeIds),
       departmentIds = Set.unmodifiable(departmentIds),
       shiftIds = Set.unmodifiable(shiftIds),
       locationIds = Set.unmodifiable(locationIds),
       statuses = Set.unmodifiable(statuses);

  final AttendanceReportPeriod period;
  final DateTime from, to;
  final AttendanceScope scope;
  final Set<String> employeeIds, departmentIds, shiftIds, locationIds, statuses;
  final bool? hasIssues, hasCorrections;
  final AttendanceReportGroup group;

  AttendanceReportFilter copyWith({
    AttendanceReportPeriod? period,
    DateTime? from,
    DateTime? to,
    Set<String>? employeeIds,
    Set<String>? departmentIds,
    Set<String>? shiftIds,
    Set<String>? locationIds,
    Set<String>? statuses,
    bool? hasIssues,
    bool? hasCorrections,
    bool clearIssues = false,
    bool clearCorrections = false,
    AttendanceReportGroup? group,
  }) => AttendanceReportFilter(
    period: period ?? this.period,
    from: from ?? this.from,
    to: to ?? this.to,
    scope: scope,
    employeeIds: employeeIds ?? this.employeeIds,
    departmentIds: departmentIds ?? this.departmentIds,
    shiftIds: shiftIds ?? this.shiftIds,
    locationIds: locationIds ?? this.locationIds,
    statuses: statuses ?? this.statuses,
    hasIssues: clearIssues ? null : hasIssues ?? this.hasIssues,
    hasCorrections: clearCorrections
        ? null
        : hasCorrections ?? this.hasCorrections,
    group: group ?? this.group,
  );

  static AttendanceReportFilter preset(
    AttendanceReportPeriod period,
    DateTime today,
    AttendanceScope scope,
  ) {
    final day = DateTime.utc(today.year, today.month, today.day);
    final (from, to) = switch (period) {
      AttendanceReportPeriod.today => (day, day),
      AttendanceReportPeriod.thisWeek => (
        day.subtract(Duration(days: day.weekday - 1)),
        day,
      ),
      AttendanceReportPeriod.thisMonth => (
        DateTime.utc(day.year, day.month),
        day,
      ),
      AttendanceReportPeriod.lastMonth => (
        DateTime.utc(day.year, day.month - 1),
        DateTime.utc(day.year, day.month).subtract(const Duration(days: 1)),
      ),
      AttendanceReportPeriod.custom => (day, day),
    };
    return AttendanceReportFilter(
      period: period,
      from: from,
      to: to,
      scope: scope,
    );
  }
}

class AttendanceReportSummary {
  const AttendanceReportSummary({
    this.recordedDays = 0,
    this.completedDays = 0,
    this.lateDays = 0,
    this.incompleteDays = 0,
    this.employees = 0,
    this.workMilliseconds = 0,
    this.breakMilliseconds = 0,
    this.pendingCorrections = 0,
    this.issueDays = 0,
  });
  final int recordedDays, completedDays, lateDays, incompleteDays, employees;
  final int workMilliseconds, breakMilliseconds, pendingCorrections, issueDays;
  Duration get totalWork => Duration(milliseconds: workMilliseconds);
  Duration get totalBreak => Duration(milliseconds: breakMilliseconds);
  Duration get averageWork => recordedDays == 0
      ? Duration.zero
      : Duration(milliseconds: workMilliseconds ~/ recordedDays);
}

class AttendanceReportRow {
  const AttendanceReportRow({
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.department,
    required this.recordedDays,
    required this.completedDays,
    required this.lateDays,
    required this.issueDays,
    required this.workMilliseconds,
    required this.breakMilliseconds,
    required this.pendingCorrections,
    this.dayId,
    this.date,
    this.shift,
    this.location,
    this.status,
    this.punchIn,
    this.punchOut,
    this.scheduledStart,
    this.graceMinutes = 0,
    this.syncStatus,
  });
  final String employeeId, employeeCode, employeeName, department;
  final int recordedDays, completedDays, lateDays, issueDays;
  final int workMilliseconds, breakMilliseconds, pendingCorrections;
  final String? dayId, shift, location, status, syncStatus;
  final DateTime? date, punchIn, punchOut, scheduledStart;
  final int graceMinutes;
  Duration get work => Duration(milliseconds: workMilliseconds);
  Duration get breaks => Duration(milliseconds: breakMilliseconds);
  Duration get averageWork => recordedDays == 0
      ? Duration.zero
      : Duration(milliseconds: workMilliseconds ~/ recordedDays);
  Duration get lateBy {
    if (punchIn == null || scheduledStart == null) return Duration.zero;
    final late = punchIn!.difference(
      scheduledStart!.add(Duration(minutes: graceMinutes)),
    );
    return late.isNegative ? Duration.zero : late;
  }
}

class AttendanceTrendPoint {
  const AttendanceTrendPoint(
    this.date,
    this.recordedDays,
    this.workMilliseconds,
  );
  final DateTime date;
  final int recordedDays, workMilliseconds;
}

enum ReportGranularity { day, week, month }

/// Coarse granularity keeps long-range trends readable instead of rendering
/// hundreds of daily axis labels. Weeks start on Monday.
ReportGranularity resolveReportGranularity(DateTime from, DateTime to) {
  final days = to.difference(from).inDays + 1;
  if (days <= 31) return ReportGranularity.day;
  if (days <= 180) return ReportGranularity.week;
  return ReportGranularity.month;
}

DateTime _bucketStart(DateTime date, ReportGranularity granularity) {
  final day = DateTime.utc(date.year, date.month, date.day);
  return switch (granularity) {
    ReportGranularity.day => day,
    ReportGranularity.week => day.subtract(Duration(days: day.weekday - 1)),
    ReportGranularity.month => DateTime.utc(day.year, day.month),
  };
}

/// Aggregates already query-aggregated daily points into week/month buckets.
List<AttendanceTrendPoint> aggregateTrend(
  List<AttendanceTrendPoint> points,
  ReportGranularity granularity,
) {
  if (granularity == ReportGranularity.day) return points;
  final buckets = <DateTime, AttendanceTrendPoint>{};
  for (final point in points) {
    final key = _bucketStart(point.date, granularity);
    final existing = buckets[key];
    buckets[key] = existing == null
        ? AttendanceTrendPoint(key, point.recordedDays, point.workMilliseconds)
        : AttendanceTrendPoint(
            key,
            existing.recordedDays + point.recordedDays,
            existing.workMilliseconds + point.workMilliseconds,
          );
  }
  return buckets.values.toList()..sort((a, b) => a.date.compareTo(b.date));
}

class AttendanceGroupSummary {
  const AttendanceGroupSummary(
    this.name,
    this.recordedDays,
    this.workMilliseconds,
  );
  final String name;
  final int recordedDays, workMilliseconds;
}

class AttendanceReportData {
  AttendanceReportData({
    required this.type,
    required this.filter,
    required this.summary,
    required this.totalRows,
    required this.page,
    required this.pageSize,
    required List<AttendanceReportRow> rows,
    required List<AttendanceTrendPoint> trend,
    required List<AttendanceGroupSummary> groups,
  }) : rows = List.unmodifiable(rows),
       trend = List.unmodifiable(trend),
       groups = List.unmodifiable(groups);
  final AttendanceReportType type;
  final AttendanceReportFilter filter;
  final AttendanceReportSummary summary;
  final int totalRows, page, pageSize;
  final List<AttendanceReportRow> rows;
  final List<AttendanceTrendPoint> trend;
  final List<AttendanceGroupSummary> groups;
}
