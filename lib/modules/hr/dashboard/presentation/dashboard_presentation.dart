import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/dashboard/domain/dashboard_models.dart';

abstract final class DashboardPresentation {
  static String greeting(AppLocalizations l, DateTime now, String name) =>
      now.hour < 12
      ? l.dashboardMorning(name)
      : now.hour < 18
      ? l.dashboardAfternoon(name)
      : l.dashboardEvening(name);
  static String contextLabel(AppLocalizations l, DashboardScope scope) =>
      switch (scope) {
        DashboardScope.self => l.dashboardSelfContext,
        DashboardScope.team => l.dashboardTeamContext,
        DashboardScope.company => l.dashboardCompanyContext,
        DashboardScope.none => l.dashboardNoScope,
      };
  static String label(AppLocalizations l, DashboardMetricKind kind) =>
      switch (kind) {
        DashboardMetricKind.employees => l.dashboardEmployees,
        DashboardMetricKind.teamSize => l.dashboardTeamSize,
        DashboardMetricKind.present => l.dashboardPresent,
        DashboardMetricKind.late => l.dashboardLate,
        DashboardMetricKind.absent => l.dashboardAbsent,
        DashboardMetricKind.leave => l.dashboardLeave,
        DashboardMetricKind.working => l.dashboardWorking,
        DashboardMetricKind.onBreak => l.dashboardBreak,
        DashboardMetricKind.corrections => l.dashboardCorrections,
        DashboardMetricKind.hours => l.dashboardHours,
        DashboardMetricKind.attendanceRate => l.dashboardRate,
        DashboardMetricKind.locations => l.dashboardLocations,
        DashboardMetricKind.users => l.dashboardUsers,
      };
  static AppStatus status(DashboardMetricKind kind) => switch (kind) {
    DashboardMetricKind.present ||
    DashboardMetricKind.working ||
    DashboardMetricKind.attendanceRate => AppStatus.success,
    DashboardMetricKind.late ||
    DashboardMetricKind.corrections => AppStatus.warning,
    DashboardMetricKind.absent => AppStatus.danger,
    DashboardMetricKind.leave || DashboardMetricKind.onBreak => AppStatus.info,
    _ => AppStatus.neutral,
  };
  static IconData icon(DashboardMetricKind kind) => switch (kind) {
    DashboardMetricKind.employees ||
    DashboardMetricKind.teamSize ||
    DashboardMetricKind.users => Icons.people_outline,
    DashboardMetricKind.present ||
    DashboardMetricKind.attendanceRate => Icons.check_circle_outline,
    DashboardMetricKind.late || DashboardMetricKind.hours => Icons.schedule,
    DashboardMetricKind.absent => Icons.person_off_outlined,
    DashboardMetricKind.leave => Icons.event_available_outlined,
    DashboardMetricKind.locations => Icons.location_on_outlined,
    DashboardMetricKind.corrections => Icons.rule_outlined,
    DashboardMetricKind.onBreak => Icons.coffee_outlined,
    DashboardMetricKind.working => Icons.work_outline,
  };
  static String value(BuildContext context, DashboardMetric metric) {
    final locale = Localizations.localeOf(context),
        numbers = AppNumberFormatter(locale);
    return switch (metric.kind) {
      DashboardMetricKind.hours => AppTimeFormatter(
        locale,
      ).duration(Duration(minutes: (metric.value * 60).round()), context.l10n),
      DashboardMetricKind.attendanceRate => numbers.percentage(metric.value),
      _ => numbers.integer(metric.value.toInt()),
    };
  }

  static String activity(
    AppLocalizations l,
    DashboardActivity a, {
    bool self = false,
  }) => self
      ? switch (a.kind) {
          DashboardActivityKind.checkedIn => l.dashboardSelfCheckedIn,
          DashboardActivityKind.breakStarted => l.dashboardSelfBreakStarted,
          DashboardActivityKind.correctionSubmitted =>
            l.dashboardSelfCorrectionSubmitted,
        }
      : switch (a.kind) {
          DashboardActivityKind.checkedIn => l.dashboardCheckedIn(a.person),
          DashboardActivityKind.breakStarted => l.dashboardBreakStarted(
            a.person,
          ),
          DashboardActivityKind.correctionSubmitted =>
            l.dashboardCorrectionSubmitted(a.person),
        };
}
