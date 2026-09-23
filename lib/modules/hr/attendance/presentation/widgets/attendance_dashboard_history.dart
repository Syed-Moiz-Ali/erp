import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/utils/local_time.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_history.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/attendance_history_presentation.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_history_bloc.dart';

/// Employee workday workspace: Today (passed in) followed by full-width
/// attendance surfaces (This month, This week, Recent attendance) sharing a
/// single [AttendanceHistoryBloc]. Presentation only — no direct data access.
class EmployeeWorkdayDashboard extends StatelessWidget {
  const EmployeeWorkdayDashboard({
    super.key,
    required this.compact,
    required this.today,
  });

  final bool compact;
  final Widget today;

  @override
  Widget build(BuildContext context) {
    final attendance = context.read<AttendanceBloc?>();
    if (attendance == null) return today;
    return BlocProvider(
      create: (_) =>
          AttendanceHistoryBloc(attendance.repository)
            ..add(const AttendanceHistoryStarted()),
      child: BlocBuilder<AttendanceHistoryBloc, AttendanceHistoryState>(
        builder: (context, s) {
          final data = s.data;
          final month = data != null && data.summary.records > 0
              ? _MonthCard(summary: data.summary)
              : null;
          final week = data != null
              ? _WeekCard(
                  items: data.items,
                  asOf: data.asOf,
                  workingDays:
                      attendance.state.context?.snapshot.shift.workingDays,
                )
              : null;
          final recent = data != null
              ? _RecentCard(
                  items: data.items.where((item) => item.isCompleted).toList(),
                  maxRows: compact ? 3 : 5,
                  compact: compact,
                )
              : null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              today,
              if (month != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                month,
              ],
              if (!compact && week != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                week,
              ],
              if (recent != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                recent,
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.summary});
  final AttendanceMonthSummary summary;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n,
        n = AppNumberFormatter(Localizations.localeOf(context));
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(title: l.dashboardMonth, upperCase: true),
          const SizedBox(height: AppSpacing.lg),
          AppInlineStats(
            stats: [
              (
                label: l.attendanceWorkedTime,
                value: AppTimeFormatter(
                  Localizations.localeOf(context),
                ).duration(summary.work, l),
              ),
              (
                label: l.historyPresent,
                value: n.integer(
                  summary.counts[AttendanceHistoryStatus.present]!,
                ),
              ),
              (
                label: l.historyLate,
                value: n.integer(summary.counts[AttendanceHistoryStatus.late]!),
              ),
              (
                label: l.historyNeedsAttention,
                value: n.integer(
                  summary.counts[AttendanceHistoryStatus.incomplete]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.items, required this.asOf, this.workingDays});
  final List<AttendanceHistoryItem> items;
  final DateTime asOf;
  final Set<WorkingDay>? workingDays;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final formatter = AppDateFormatter(Localizations.localeOf(context));
    final today = DateTime.utc(asOf.year, asOf.month, asOf.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final byDate = {
      for (final item in items)
        DateTime.utc(
          item.attendanceDate.year,
          item.attendanceDate.month,
          item.attendanceDate.day,
        ): item,
    };
    final days = [for (var i = 0; i < 7; i++) monday.add(Duration(days: i))];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(title: l.dashboardThisWeek, upperCase: true),
          const SizedBox(height: AppSpacing.lg),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < days.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _DayCell(
                      day: days[i],
                      item: byDate[days[i]],
                      isToday: days[i] == today,
                      isWorkingDay: workingDays?.any(
                        (d) => d.isoWeekday == days[i].weekday,
                      ),
                      weekdayShort: formatter.weekdayShort(days[i]),
                      dayNumber: formatter.dayOfMonth(days[i]),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.item,
    required this.isToday,
    required this.weekdayShort,
    required this.dayNumber,
    this.isWorkingDay,
  });
  final DateTime day;
  final AttendanceHistoryItem? item;
  final bool isToday;

  /// Null when the shift schedule is unknown; false means a configured
  /// non-working day (week off).
  final bool? isWorkingDay;
  final String weekdayShort, dayNumber;

  @override
  Widget build(BuildContext context) {
    final theme = AppTypography.of(context);
    final record = item;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: isToday ? AppColors.brandSubtle : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusMd + 2),
        border: Border.all(
          color: isToday
              ? AppColors.brandPrimary.withValues(alpha: 0.35)
              : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            weekdayShort,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.metricLabel.copyWith(letterSpacing: 0.3),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            dayNumber,
            style: theme.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (record == null && isWorkingDay == false)
            Text(
              context.l10n.dashboardWeekOff,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.caption.copyWith(color: AppColors.textDisabled),
            )
          else if (record == null)
            Text(
              context.l10n.historyNotRecorded,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.caption.copyWith(color: AppColors.textDisabled),
            )
          else ...[
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AttendanceHistoryPresentation.color(
                      record.status,
                    ).color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    AttendanceHistoryPresentation.label(context, record.status),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              record.isCompleted
                  ? AppTimeFormatter(
                      Localizations.localeOf(context),
                    ).duration(record.totalWorkDuration, context.l10n)
                  : context.l10n.historyNotRecorded,
              maxLines: 1,
              style: theme.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({
    required this.items,
    required this.maxRows,
    this.compact = false,
  });
  final List<AttendanceHistoryItem> items;
  final int maxRows;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final rows = items.take(maxRows).toList();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(
            title: l.dashboardRecentAttendance,
            upperCase: true,
            action: AppTextButton(
              label: l.dashboardViewFullHistory,
              onPressed: () => context.go(AppRoutes.attendanceHistory),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.dashboardNoRecentAttendance,
                    style: AppTypography.of(context).bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l.dashboardNoRecentAttendanceMessage,
                    style: AppTypography.of(context).caption,
                  ),
                ],
              ),
            )
          else
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              _RecentRow(item: rows[i], compact: compact),
            ],
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.item, this.compact = false});
  final AttendanceHistoryItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = AppTypography.of(context);
    final locale = Localizations.localeOf(context);
    final formatter = AppDateFormatter(locale);
    final timeFormatter = AppTimeFormatter(locale);
    final punchIn = AttendanceHistoryPresentation.itemTime(
      context,
      item,
      item.punchInAt,
    );
    final punchOut = AttendanceHistoryPresentation.itemTime(
      context,
      item,
      item.punchOutAt,
    );
    final worked = item.isCompleted
        ? timeFormatter.duration(item.totalWorkDuration, context.l10n)
        : context.l10n.historyNotRecorded;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final dateStyle = theme.bodySmall.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
    final times = '$punchIn → $punchOut';
    return InkWell(
      onTap: () => context.go(AppRoutes.attendanceDayDetails(item.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatter.date(item.attendanceDate),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: dateStyle,
                        ),
                      ),
                      AttendanceHistoryPresentation.badge(context, item.status),
                      Icon(
                        rtl ? Icons.chevron_left : Icons.chevron_right,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          times,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      Text(
                        worked,
                        style: theme.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  SizedBox(
                    width: 148,
                    child: Text(
                      formatter.date(item.attendanceDate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: dateStyle,
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AttendanceHistoryPresentation.badge(
                        context,
                        item.status,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      times,
                      style: theme.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 96,
                    child: Text(
                      worked,
                      textAlign: TextAlign.end,
                      style: theme.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  Icon(
                    rtl ? Icons.chevron_left : Icons.chevron_right,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
      ),
    );
  }
}
