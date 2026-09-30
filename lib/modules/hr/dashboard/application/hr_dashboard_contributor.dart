import 'package:flutter/material.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/widgets/attendance_dashboard_preview.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_models.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_repository.dart';
import 'package:modular_erp/modules/hr/dashboard/presentation/dashboard_presentation.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_repository.dart';
import 'package:modular_erp/modules/hr/leave/presentation/widgets/leave_today_banner.dart';
import 'package:modular_erp/platform/workspace/dashboard/domain/dashboard_contribution.dart';
import 'package:modular_erp/platform/workspace/dashboard/domain/dashboard_contributor.dart';

/// HR's public dashboard contribution.
///
/// Reuses the existing HR dashboard read contract ([DashboardRepository]) and
/// the HR-owned attendance/leave widgets. It exposes dashboard-ready data only;
/// the universal dashboard never sees an HR DAO, Drift table or bloc.
class HrDashboardContributor implements DashboardContributor {
  const HrDashboardContributor({
    required this.repository,
    this.leaveRepository,
    this.demoWidgets = true,
  });

  final DashboardRepository repository;
  final LeaveRepository? leaveRepository;

  /// When false, personal widgets are omitted (used by pure-data tests).
  final bool demoWidgets;

  @override
  String get id => 'hr';

  @override
  String get moduleId => 'hr';

  @override
  int get order => 10;

  static const _visibilityPermissions = <AppPermission>{
    AppPermission.attendanceViewSelf,
    AppPermission.attendanceViewTeam,
    AppPermission.attendanceViewAll,
    AppPermission.attendanceApprove,
    AppPermission.attendanceCorrect,
    AppPermission.attendanceRequestCorrection,
    AppPermission.leaveViewSelf,
    AppPermission.leaveViewTeam,
    AppPermission.leaveViewAll,
    AppPermission.leaveRequest,
    AppPermission.leaveApproveTeam,
    AppPermission.leaveApproveAll,
    AppPermission.employeeViewSelf,
    AppPermission.employeeViewTeam,
    AppPermission.employeeViewAll,
  };

  bool _moduleEnabled(DashboardCapabilityContext context) =>
      context.moduleEnabled('attendance') ||
      context.moduleEnabled('employees') ||
      context.moduleEnabled('leave');

  @override
  bool isVisible(DashboardCapabilityContext context) =>
      _moduleEnabled(context) &&
      (context.employeeId != null || context.anyCan(_visibilityPermissions));

  @override
  Future<DashboardContribution> load(DashboardCapabilityContext context) async {
    final l = context.l10n;
    final locale = Locale(l.localeName);
    final summaryResult = await repository.load(context.auth);
    final summary = summaryResult is Success<DashboardSummary>
        ? summaryResult.value
        : null;

    final myDay = <Widget>[
      if (demoWidgets &&
          context.employeeId != null &&
          context.moduleEnabled('attendance') &&
          context.can(AppPermission.attendanceViewSelf))
        const AppCard(child: AttendanceDashboardPreview()),
      // Personal leave is shown only with the leave self-view grant; the
      // repository also enforces this at its boundary.
      if (demoWidgets &&
          context.employeeId != null &&
          context.moduleEnabled('leave') &&
          context.can(AppPermission.leaveViewSelf) &&
          leaveRepository != null)
        LeaveTodayBanner(repository: leaveRepository!),
    ];

    if (summary == null) {
      return DashboardContribution(
        moduleId: moduleId,
        order: order,
        myDay: myDay,
        quickActions: _quickActions(context, l),
      );
    }

    final kpis = <DashboardKpi>[
      for (final metric in summary.metrics)
        if (_kpiRank(metric.kind) != null)
          DashboardKpi(
            id: 'hr-${metric.kind.name}',
            moduleId: moduleId,
            label: DashboardPresentation.label(l, metric.kind),
            value: _metricValue(locale, l, metric),
            detail: metric.kind == DashboardMetricKind.present
                ? l.dashboardPresentDetail
                : '',
            icon: DashboardPresentation.icon(metric.kind),
            tone: _tone(metric.kind),
            rank: _kpiRank(metric.kind)!,
            route: _metricRoute(context, metric.kind),
          ),
    ];

    final attention = <DashboardAttentionItem>[
      for (final alert in summary.alerts)
        DashboardAttentionItem(
          id: 'hr-alert-${alert.kind.name}',
          moduleId: moduleId,
          type: alert.kind.name,
          title: switch (alert.kind) {
            DashboardAlertKind.lateArrivals => l.dashboardLateAlert(
              AppNumberFormatter(locale).integer(alert.count),
            ),
            DashboardAlertKind.pendingCorrections =>
              l.dashboardCorrectionsAlert(
                AppNumberFormatter(locale).integer(alert.count),
              ),
          },
          subtitle: switch (alert.kind) {
            DashboardAlertKind.lateArrivals => l.dashboardLateAlertDetail,
            DashboardAlertKind.pendingCorrections =>
              l.dashboardCorrectionsAlertDetail,
          },
          icon: alert.kind == DashboardAlertKind.lateArrivals
              ? Icons.schedule
              : Icons.rule_outlined,
          tone: DashboardTone.warning,
          priority: alert.kind == DashboardAlertKind.lateArrivals ? 40 : 60,
          route: alert.kind == DashboardAlertKind.lateArrivals
              ? AppRoutes.attendance
              : AppRoutes.attendanceRequests,
        ),
    ];

    final schedule = <DashboardScheduleItem>[];
    final today = summary.today;
    if (today != null) {
      final time = AppTimeFormatter(locale);
      schedule.add(
        DashboardScheduleItem(
          id: 'hr-shift',
          moduleId: moduleId,
          title: l.dashboardShift,
          subtitle: l.dashboardTimeRange(
            time.time(today.shiftStart),
            time.time(today.shiftEnd),
          ),
          statusLabel: '',
          icon: Icons.schedule_outlined,
          time: today.shiftStart,
          route: AppRoutes.attendance,
        ),
      );
    }

    return DashboardContribution(
      moduleId: moduleId,
      order: order,
      scopeLabel: summary.scope == DashboardScope.none
          ? ''
          : DashboardPresentation.contextLabel(l, summary.scope),
      kpis: kpis,
      attention: attention,
      schedule: schedule,
      activity: [
        for (final item in summary.activities)
          DashboardActivityItem(
            id: 'hr-activity-${item.kind.name}-${item.timestamp.microsecondsSinceEpoch}',
            moduleId: moduleId,
            title: DashboardPresentation.activity(l, item),
            description: l.navSectionHr,
            icon: switch (item.kind) {
              DashboardActivityKind.checkedIn => Icons.login,
              DashboardActivityKind.breakStarted => Icons.coffee_outlined,
              DashboardActivityKind.correctionSubmitted => Icons.edit_note,
            },
            occurredAt: item.timestamp,
            tone: item.kind == DashboardActivityKind.checkedIn
                ? DashboardTone.success
                : DashboardTone.neutral,
          ),
      ],
      quickActions: _quickActions(context, l),
      myDay: myDay,
      viewAll: {
        if (context.can(AppPermission.attendanceApprove))
          DashboardSection.attention: AppRoutes.attendanceRequests,
        DashboardSection.schedule: AppRoutes.attendance,
        if (context.can(AppPermission.attendanceViewSelf) &&
            context.employeeId != null)
          DashboardSection.activity: AppRoutes.attendanceHistory,
      },
    );
  }

  int? _kpiRank(DashboardMetricKind kind) => switch (kind) {
    DashboardMetricKind.present => 5,
    DashboardMetricKind.leave => 12,
    DashboardMetricKind.absent => 15,
    DashboardMetricKind.teamSize => 8,
    DashboardMetricKind.employees => 9,
    DashboardMetricKind.late => 20,
    DashboardMetricKind.corrections => 30,
    DashboardMetricKind.attendanceRate => 45,
    DashboardMetricKind.locations => 70,
    DashboardMetricKind.users => 72,
    _ => null,
  };

  DashboardTone _tone(DashboardMetricKind kind) => switch (kind) {
    DashboardMetricKind.present ||
    DashboardMetricKind.working ||
    DashboardMetricKind.attendanceRate => DashboardTone.success,
    DashboardMetricKind.late ||
    DashboardMetricKind.corrections => DashboardTone.warning,
    DashboardMetricKind.absent => DashboardTone.danger,
    DashboardMetricKind.leave ||
    DashboardMetricKind.onBreak => DashboardTone.info,
    _ => DashboardTone.neutral,
  };

  String _metricValue(
    Locale locale,
    AppLocalizations l,
    DashboardMetric metric,
  ) => switch (metric.kind) {
    DashboardMetricKind.hours => AppTimeFormatter(
      locale,
    ).duration(Duration(minutes: (metric.value * 60).round()), l),
    DashboardMetricKind.attendanceRate => AppNumberFormatter(
      locale,
    ).percentage(metric.value),
    _ => AppNumberFormatter(locale).integer(metric.value.toInt()),
  };

  String? _metricRoute(
    DashboardCapabilityContext context,
    DashboardMetricKind kind,
  ) => switch (kind) {
    DashboardMetricKind.corrections => AppRoutes.attendanceRequests,
    DashboardMetricKind.locations => AppRoutes.workLocations,
    DashboardMetricKind.users => AppRoutes.access,
    _ => null,
  };

  List<DashboardQuickAction> _quickActions(
    DashboardCapabilityContext context,
    AppLocalizations l,
  ) => [
    if (context.employeeId != null && context.can(AppPermission.leaveRequest))
      DashboardQuickAction(
        id: 'hr-leave-request',
        moduleId: moduleId,
        label: l.leaveNewRequest,
        icon: Icons.event_available_outlined,
        route: AppRoutes.leaveRequest,
      ),
    if (context.can(AppPermission.attendancePunchIn) ||
        context.can(AppPermission.attendancePunchOut))
      DashboardQuickAction(
        id: 'hr-attendance',
        moduleId: moduleId,
        label: l.shellAttendance,
        icon: Icons.schedule_outlined,
        route: AppRoutes.attendance,
      ),
    if (context.can(AppPermission.employeeCreate))
      DashboardQuickAction(
        id: 'hr-employee-new',
        moduleId: moduleId,
        label: l.empAdd,
        icon: Icons.person_add_outlined,
        route: AppRoutes.employeeNew,
      ),
    if (context.can(AppPermission.leaveApproveTeam) ||
        context.can(AppPermission.leaveApproveAll))
      DashboardQuickAction(
        id: 'hr-leave-approvals',
        moduleId: moduleId,
        label: l.leaveApprovals,
        icon: Icons.fact_check_outlined,
        route: AppRoutes.leaveApprovals,
      ),
  ];
}
