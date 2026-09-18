import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_formatters.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/attendance_history.dart';
import '../../domain/attendance_models.dart';
import '../attendance_history_presentation.dart';
import '../attendance_presentation.dart';

class AttendanceMonthSelector extends StatelessWidget {
  const AttendanceMonthSelector({
    super.key,
    required this.month,
    required this.current,
    required this.onChanged,
  });
  final DateTime month, current;
  final ValueChanged<DateTime> onChanged;
  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Row(
      children: [
        AppIconButton(
          icon: rtl ? Icons.chevron_right : Icons.chevron_left,
          tooltip: context.l10n.historyPreviousMonth,
          size: AppButtonSize.large,
          onPressed: month.year == 1 && month.month == 1
              ? null
              : () => onChanged(DateTime.utc(month.year, month.month - 1)),
        ),
        Expanded(
          child: Text(
            AppDateFormatter(Localizations.localeOf(context)).month(month),
            textAlign: TextAlign.center,
            style: AppTypography.of(context).sectionTitle,
          ),
        ),
        AppIconButton(
          icon: rtl ? Icons.chevron_left : Icons.chevron_right,
          tooltip: context.l10n.historyNextMonth,
          size: AppButtonSize.large,
          onPressed: month.isBefore(current)
              ? () => onChanged(DateTime.utc(month.year, month.month + 1))
              : null,
        ),
      ],
    );
  }
}

class AttendanceMonthlySummary extends StatelessWidget {
  const AttendanceMonthlySummary({super.key, required this.summary});
  final AttendanceMonthSummary summary;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n,
        n = AppNumberFormatter(Localizations.localeOf(context));
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppResponsiveGrid(
            minItemWidth: 130,
            maxColumns: 4,
            children: [
              AppDetailField(
                label: l.attendanceWorkedTime,
                value: AttendancePresentation.duration(context, summary.work),
              ),
              AppDetailField(
                label: l.historyPresent,
                value: n.integer(
                  summary.counts[AttendanceHistoryStatus.present]!,
                ),
              ),
              AppDetailField(
                label: l.historyLate,
                value: n.integer(summary.counts[AttendanceHistoryStatus.late]!),
              ),
              AppDetailField(
                label: l.historyNeedsAttention,
                value: n.integer(
                  summary.counts[AttendanceHistoryStatus.incomplete]!,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l.historyCompletedOnly,
            style: AppTypography.of(context).caption,
          ),
        ],
      ),
    );
  }
}

class AttendanceHistorySkeleton extends StatelessWidget {
  const AttendanceHistorySkeleton({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const AppSkeleton(height: 100),
      const SizedBox(height: AppSpacing.lg),
      for (var i = 0; i < 5; i++)
        const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: AppSkeleton(height: 66),
        ),
    ],
  );
}

class AttendanceHistoryList extends StatelessWidget {
  const AttendanceHistoryList({
    super.key,
    required this.data,
    required this.onOpen,
  });
  final AttendanceHistoryPageData data;
  final ValueChanged<AttendanceHistoryItem> onOpen;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final day in data.items)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            onTap: () => onOpen(day),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    Text(
                      AppDateFormatter(
                        Localizations.localeOf(context),
                      ).date(day.attendanceDate),
                      style: AppTypography.of(context).cardTitle,
                    ),
                    AttendanceHistoryPresentation.badge(context, day.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AttendanceHistoryPresentation.range(
                    context,
                    AttendanceHistoryPresentation.itemTime(
                      context,
                      day,
                      day.punchInAt,
                    ),
                    day.punchOutAt == null
                        ? (day.status == AttendanceHistoryStatus.working
                              ? context.l10n.historyNow
                              : context.l10n.historyMissingOut)
                        : AttendanceHistoryPresentation.itemTime(
                            context,
                            day,
                            day.punchOutAt,
                            includeDate: true,
                          ),
                  ),
                  style: AppTypography.of(context).bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.lg,
                  runSpacing: AppSpacing.xs,
                  children: [
                    if (day.isCompleted) ...[
                      Text(
                        context.l10n.labeledValue(
                          context.l10n.attendanceWorkedTime,
                          AttendancePresentation.duration(
                            context,
                            day.totalWorkDuration,
                          ),
                        ),
                        style: AppTypography.of(context).bodySmall,
                      ),
                      Text(
                        context.l10n.labeledValue(
                          context.l10n.attendanceTotalBreak,
                          AttendancePresentation.duration(
                            context,
                            day.totalBreakDuration,
                          ),
                        ),
                        style: AppTypography.of(context).bodySmall,
                      ),
                    ],
                    if (day.syncStatus != AttendanceSyncStatus.synced)
                      AppStatusBadge(
                        label: AttendancePresentation.sync(
                          context,
                          day.syncStatus,
                        ),
                        status: day.syncStatus == AttendanceSyncStatus.pending
                            ? AppStatus.info
                            : AppStatus.danger,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

class AttendanceHistoryTable extends StatelessWidget {
  const AttendanceHistoryTable({
    super.key,
    required this.data,
    required this.onOpen,
  });
  final AttendanceHistoryPageData data;
  final ValueChanged<AttendanceHistoryItem> onOpen;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppDataTable(
      dataRowMinHeight: AppSpacing.lg * 4,
      columns: [
        for (final label in [
          l.historyDate,
          l.historyStatus,
          l.dashboardShift,
          l.attendancePunchIn,
          l.attendancePunchOut,
          l.attendanceWorkedTime,
          l.attendanceTotalBreak,
        ])
          DataColumn(label: Text(label)),
      ],
      rows: [
        for (final day in data.items)
          DataRow(
            onSelectChanged: (_) => onOpen(day),
            cells: [
              DataCell(
                Text(
                  AppDateFormatter(
                    Localizations.localeOf(context),
                  ).date(day.attendanceDate),
                ),
              ),
              DataCell(
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AttendanceHistoryPresentation.badge(context, day.status),
                    if (day.syncStatus != AttendanceSyncStatus.synced)
                      Text(
                        AttendancePresentation.sync(context, day.syncStatus),
                        style: AppTypography.of(context).caption,
                      ),
                  ],
                ),
              ),
              DataCell(Text(day.shiftName)),
              DataCell(
                Text(
                  AttendanceHistoryPresentation.itemTime(
                    context,
                    day,
                    day.punchInAt,
                  ),
                ),
              ),
              DataCell(
                Text(
                  day.punchOutAt == null
                      ? (day.status == AttendanceHistoryStatus.working
                            ? l.historyNow
                            : l.historyMissingOut)
                      : AttendanceHistoryPresentation.itemTime(
                          context,
                          day,
                          day.punchOutAt,
                          includeDate: true,
                        ),
                ),
              ),
              DataCell(
                Text(
                  day.isCompleted
                      ? AttendancePresentation.duration(
                          context,
                          day.totalWorkDuration,
                        )
                      : l.historyIncomplete,
                ),
              ),
              DataCell(
                Text(
                  day.isCompleted
                      ? AttendancePresentation.duration(
                          context,
                          day.totalBreakDuration,
                        )
                      : '—',
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class AttendanceHistoryFilterDraft extends Cubit<Set<AttendanceHistoryStatus>> {
  AttendanceHistoryFilterDraft(Set<AttendanceHistoryStatus> values)
    : super(Set.unmodifiable(values));
  void toggle(AttendanceHistoryStatus status, bool selected) => emit(
    Set.unmodifiable(
      {...state}
        ..remove(status)
        ..addAll(selected ? [status] : []),
    ),
  );
  void reset() => emit(const {});
}

class AttendanceHistoryFilterSheet extends StatelessWidget {
  const AttendanceHistoryFilterSheet({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AttendanceHistoryFilterDraft, Set<AttendanceHistoryStatus>>(
        builder: (context, statuses) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSectionHeader(title: context.l10n.historyFilters),
            const SizedBox(height: AppSpacing.lg),
            AppFilterBar(
              children: [
                for (final s in AttendanceHistoryStatus.values)
                  AppFilterChip(
                    label: AttendanceHistoryPresentation.label(context, s),
                    selected: statuses.contains(s),
                    onSelected: (v) => context
                        .read<AttendanceHistoryFilterDraft>()
                        .toggle(s, v),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSecondaryButton(
              label: context.l10n.historyReset,
              onPressed: () =>
                  context.read<AttendanceHistoryFilterDraft>().reset(),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppPrimaryButton(
              label: context.l10n.historyApply,
              onPressed: () => Navigator.of(context).pop(statuses),
            ),
          ],
        ),
      );
}
