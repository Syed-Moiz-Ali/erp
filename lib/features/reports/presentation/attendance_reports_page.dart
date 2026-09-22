import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../core/localization/app_formatters.dart';
import '../../../design_system/design_system.dart';
import '../../../design_system/theme/app_breakpoints.dart';
import '../../../l10n/l10n.dart';
import '../../attendance/domain/workforce_attendance.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../data/attendance_report_export_service.dart';
import '../domain/attendance_report_models.dart';
import 'bloc/attendance_report_bloc.dart';

class AttendanceReportsPage extends StatelessWidget {
  const AttendanceReportsPage({super.key});

  String _typeLabel(AppLocalizations l, AttendanceReportType type) =>
      switch (type) {
        AttendanceReportType.overview => l.reportOverview,
        AttendanceReportType.workHours => l.reportWorkHours,
        AttendanceReportType.lateAttendance => l.reportLate,
        AttendanceReportType.breakAnalysis => l.reportBreaks,
        AttendanceReportType.issues => l.reportIssues,
        AttendanceReportType.employeeSummary => l.reportEmployees,
      };
  String _periodLabel(AppLocalizations l, AttendanceReportPeriod period) =>
      switch (period) {
        AttendanceReportPeriod.today => l.reportToday,
        AttendanceReportPeriod.thisWeek => l.reportThisWeek,
        AttendanceReportPeriod.thisMonth => l.reportThisMonth,
        AttendanceReportPeriod.lastMonth => l.reportLastMonth,
        AttendanceReportPeriod.custom => l.reportCustom,
      };

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<AttendanceReportBloc, AttendanceReportState>(
    builder: (context, state) {
      final l = context.l10n;
      final compact = AppBreakpoints.of(context) == AppSize.compact;
      final bloc = context.read<AttendanceReportBloc>();
      final filter = state.filter;
      final data = state.data;
      final locale = Localizations.localeOf(context);
      final date = AppDateFormatter(locale);
      final duration = AppTimeFormatter(locale);
      final granularity = filter == null
          ? ReportGranularity.day
          : resolveReportGranularity(filter.from, filter.to);
      final trendPoints = data == null
          ? const <AttendanceTrendPoint>[]
          : aggregateTrend(data.trend, granularity);
      void change(AttendanceReportFilter next) =>
          bloc.add(AttendanceReportFilterChanged(next));
      return AppPage(
        header: AppPageHeader(
          title: l.reportTitle,
          subtitle: filter == null
              ? null
              : '${date.date(filter.from)} – ${date.date(filter.to)}',
          compactActionsInline: true,
          actions: [
            AppIconButton(
              icon: Icons.refresh,
              tooltip: l.dashboardRefresh,
              onPressed: () =>
                  bloc.add(const AttendanceReportRefreshRequested()),
            ),
            if (data != null) _exportButton(context, state, compact),
          ],
        ),
        child: filter == null
            ? (state.failure != null
                  ? AppErrorState(
                      message: l.reportRefreshFailed,
                      onRetry: () => bloc.add(const AttendanceReportStarted()),
                    )
                  : const AppLoadingState())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppStatusBadge(
                    label: filter.scope == AttendanceScope.team
                        ? l.reportScopeTeam
                        : l.reportScopeCompany,
                    status: AppStatus.info,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppDateRangePresetSelector<AttendanceReportPeriod>(
                    options: [
                      for (final p in AttendanceReportPeriod.values)
                        (p, _periodLabel(l, p)),
                    ],
                    selected: filter.period,
                    onChanged: (p) {
                      if (p == AttendanceReportPeriod.custom) {
                        change(filter.copyWith(period: p));
                      } else {
                        final preset = AttendanceReportFilter.preset(
                          p,
                          state.today!,
                          filter.scope,
                        );
                        change(
                          preset.copyWith(
                            employeeIds: filter.employeeIds,
                            departmentIds: filter.departmentIds,
                            shiftIds: filter.shiftIds,
                            locationIds: filter.locationIds,
                            statuses: filter.statuses,
                            hasIssues: filter.hasIssues,
                            hasCorrections: filter.hasCorrections,
                            group: filter.group,
                          ),
                        );
                      }
                    },
                  ),
                  if (filter.period == AttendanceReportPeriod.custom) ...[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: [
                        SizedBox(
                          width: 230,
                          child: AppDateField(
                            label: l.reportFrom,
                            value: filter.from,
                            lastDate: state.today,
                            onChanged: (v) => change(filter.copyWith(from: v)),
                          ),
                        ),
                        SizedBox(
                          width: 230,
                          child: AppDateField(
                            label: l.reportTo,
                            value: filter.to,
                            lastDate: state.today,
                            onChanged: (v) => change(filter.copyWith(to: v)),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  AppDateRangePresetSelector<AttendanceReportType>(
                    options: [
                      for (final type in AttendanceReportType.values)
                        (type, _typeLabel(l, type)),
                    ],
                    selected: state.type,
                    onChanged: (type) =>
                        bloc.add(AttendanceReportTypeChanged(type)),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (compact)
                    AppSecondaryButton(
                      label: l.reportFilter,
                      icon: Icons.tune,
                      onPressed: () => _mobileFilters(context, state),
                    )
                  else
                    AppToolbar(filters: _filters(context, state)),
                  const SizedBox(height: AppSpacing.xl),
                  if (state.refreshing) ...[
                    const LinearProgressIndicator(minHeight: 2),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (state.failure != null) ...[
                    AppNotice(
                      title: l.reportRefreshFailed,
                      status: AppStatus.warning,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (state.exported) ...[
                    AppNotice(
                      title: l.reportExported,
                      status: AppStatus.success,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (state.exportFailure != null) ...[
                    AppNotice(
                      title: l.reportExportFailed,
                      status: AppStatus.danger,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (data == null)
                    const AppSkeleton(height: 150)
                  else if (data.summary.recordedDays == 0)
                    AppEmptyState(
                      title: l.reportNoData,
                      message: l.reportNoData,
                      actionLabel: l.reportClearFilters,
                      onAction: () => change(
                        AttendanceReportFilter(
                          period: filter.period,
                          from: filter.from,
                          to: filter.to,
                          scope: filter.scope,
                        ),
                      ),
                    )
                  else ...[
                    _metricGrid(context, data, state.type),
                    const SizedBox(height: AppSpacing.xl),
                    if (filter.to == state.today) ...[
                      AppNotice(
                        title: l.reportInProgress,
                        status: AppStatus.info,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    _analytics(
                      context,
                      data,
                      trendPoints,
                      state.type,
                      granularity,
                    ),
                    if (_hasAttention(data)) ...[
                      const SizedBox(height: AppSpacing.xl),
                      _attention(context, data, filter, change),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    AppSectionHeader(title: l.reportDetailedRecords),
                    const SizedBox(height: AppSpacing.md),
                    if (compact) ...[
                      for (final row in data.rows)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: AppCard(
                            variant: AppCardVariant.interactive,
                            onTap: () => _openRow(context, filter.scope, row),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row.employeeName,
                                  style: AppTypography.of(context).cardTitle,
                                ),
                                Text(
                                  row.date == null
                                      ? row.employeeCode
                                      : date.date(row.date!),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  _labeled(
                                    l.reportWorked,
                                    duration.duration(row.work, l),
                                  ),
                                ),
                                Text(
                                  _labeled(
                                    l.reportBreak,
                                    duration.duration(row.breaks, l),
                                  ),
                                ),
                                if (row.issueDays > 0)
                                  AppStatusBadge(
                                    label: l.reportIssuesCount,
                                    status: AppStatus.warning,
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ] else
                      _table(context, data),
                    AppTablePagination(
                      page: state.page,
                      pageSize: state.pageSize,
                      total: data.totalRows,
                      onPageChanged: (page) =>
                          bloc.add(AttendanceReportPageChanged(page)),
                    ),
                  ],
                ],
              ),
      );
    },
  );

  Widget _metric(String label, String value) => SizedBox(
    width: 185,
    child: AppMetricCard(
      label: label,
      value: value,
      variant: AppMetricVariant.secondary,
    ),
  );

  String _labeled(String label, String value) => '$label: $value';

  String _granularityLabel(AppLocalizations l, ReportGranularity granularity) =>
      switch (granularity) {
        ReportGranularity.day => l.reportDaily,
        ReportGranularity.week => l.reportWeekly,
        ReportGranularity.month => l.reportMonthly,
      };

  Widget _metricGrid(
    BuildContext context,
    AttendanceReportData data,
    AttendanceReportType type,
  ) {
    final l = context.l10n;
    final number = AppNumberFormatter(Localizations.localeOf(context));
    final duration = AppTimeFormatter(Localizations.localeOf(context));
    final summary = data.summary;
    final entries = switch (type) {
      AttendanceReportType.overview => [
        (l.reportRecordedDays, number.integer(summary.recordedDays)),
        (l.reportCompletedDays, number.integer(summary.completedDays)),
        (l.reportLateDays, number.integer(summary.lateDays)),
        (l.reportWorkTotal, duration.duration(summary.totalWork, l)),
        (l.reportBreakTotal, duration.duration(summary.totalBreak, l)),
        (l.reportIssueDays, number.integer(summary.issueDays)),
      ],
      AttendanceReportType.workHours => [
        (l.reportRecordedEmployees, number.integer(summary.employees)),
        (l.reportRecordedDays, number.integer(summary.recordedDays)),
        (l.reportCompletedDays, number.integer(summary.completedDays)),
        (l.reportWorkTotal, duration.duration(summary.totalWork, l)),
        (l.reportAverageWork, duration.duration(summary.averageWork, l)),
      ],
      AttendanceReportType.lateAttendance => [
        (l.reportLateDays, number.integer(summary.lateDays)),
        (l.reportRecordedEmployees, number.integer(summary.employees)),
        (l.reportRecordedDays, number.integer(summary.recordedDays)),
        (l.reportCompletedDays, number.integer(summary.completedDays)),
      ],
      AttendanceReportType.breakAnalysis => [
        (l.reportBreakTotal, duration.duration(summary.totalBreak, l)),
        (l.reportRecordedDays, number.integer(summary.recordedDays)),
        (l.reportRecordedEmployees, number.integer(summary.employees)),
        (l.reportCompletedDays, number.integer(summary.completedDays)),
      ],
      AttendanceReportType.issues => [
        (l.reportIssueDays, number.integer(summary.issueDays)),
        (
          l.reportPendingCorrections,
          number.integer(summary.pendingCorrections),
        ),
        (l.reportRecordedDays, number.integer(summary.recordedDays)),
        (l.reportLateDays, number.integer(summary.lateDays)),
      ],
      AttendanceReportType.employeeSummary => [
        (l.reportRecordedEmployees, number.integer(summary.employees)),
        (l.reportRecordedDays, number.integer(summary.recordedDays)),
        (l.reportCompletedDays, number.integer(summary.completedDays)),
        (l.reportWorkTotal, duration.duration(summary.totalWork, l)),
        (l.reportLateDays, number.integer(summary.lateDays)),
      ],
    };
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [for (final (label, value) in entries) _metric(label, value)],
    );
  }

  String _statusLabel(AppLocalizations l, AttendanceReportStatus status) =>
      switch (status) {
        AttendanceReportStatus.completed => l.reportStatusCompleted,
        AttendanceReportStatus.late => l.reportStatusLate,
        AttendanceReportStatus.working => l.reportStatusWorking,
        AttendanceReportStatus.issues => l.reportStatusIssues,
      };

  String _issueLabel(AppLocalizations l, String code) => switch (code) {
    'missingPunchOut' => l.reportIssueMissingPunchOut,
    'syncFailure' => l.reportIssueSyncFailure,
    'rejected' => l.reportIssueRejected,
    'pendingCorrection' => l.reportIssuePendingCorrection,
    _ => code,
  };

  AppStatus _issueStatus(String code) => switch (code) {
    'rejected' || 'syncFailure' => AppStatus.danger,
    'pendingCorrection' || 'missingPunchOut' => AppStatus.warning,
    _ => AppStatus.neutral,
  };

  /// Descriptive analytics: primary activity trend + capability-free secondary
  /// visuals + optional group comparison. Charts are driven by typed report
  /// data only (no widget-side aggregation beyond bucketing done in domain).
  Widget _analytics(
    BuildContext context,
    AttendanceReportData data,
    List<AttendanceTrendPoint> trend,
    AttendanceReportType type,
    ReportGranularity granularity,
  ) {
    final l = context.l10n;
    final date = AppDateFormatter(Localizations.localeOf(context));
    final labels = [for (final p in trend) date.dayOfMonth(p.date)];
    double hours(int ms) => ms / Duration.millisecondsPerHour;
    String hourLabel(double value) => '${value.round()}h';
    final hasTrend = trend.length >= 2;

    final secondary = <Widget>[
      if (data.statusDistribution.isNotEmpty)
        AppChartCard(
          title: l.reportStatusDistribution,
          description: l.reportStatusDistributionDesc,
          height: 220,
          semanticLabel: l.reportStatusDistribution,
          legend: AppChartLegend(
            items: [
              for (final slice in data.statusDistribution)
                AppChartLegendItem(
                  _statusLabel(l, slice.status),
                  _statusColor(slice.status),
                ),
            ],
          ),
          child: AppDonutChart(
            centerValue: AppNumberFormatter(Localizations.localeOf(context))
                .integer(
                  data.statusDistribution.fold<int>(
                    0,
                    (sum, s) => sum + s.count,
                  ),
                ),
            centerTitle: l.reportStatusDistribution,
            slices: [
              for (final slice in data.statusDistribution)
                AppDonutSlice(
                  label: _statusLabel(l, slice.status),
                  value: slice.count.toDouble(),
                  color: _statusColor(slice.status),
                ),
            ],
          ),
        ),
      if (hasTrend)
        AppChartCard(
          title: l.reportWorkHoursTrend,
          description: l.reportWorkHoursTrendDesc,
          height: 220,
          semanticLabel: l.reportWorkHoursTrend,
          emptyMessage: l.reportNoData,
          child: AppBarChart(
            labels: labels,
            values: [for (final p in trend) hours(p.workMilliseconds)],
            color: AppChartColors.working,
            formatY: hourLabel,
          ),
        ),
      if (hasTrend && data.summary.lateDays > 0)
        AppChartCard(
          title: l.reportLateTrend,
          description: l.reportLateTrendDesc,
          height: 220,
          semanticLabel: l.reportLateTrend,
          child: AppBarChart(
            labels: labels,
            values: [for (final p in trend) p.lateDays.toDouble()],
            color: AppChartColors.late,
          ),
        ),
      if (hasTrend && data.summary.breakMilliseconds > 0)
        AppChartCard(
          title: l.reportBreakTrend,
          description: l.reportBreakTrendDesc,
          height: 220,
          semanticLabel: l.reportBreakTrend,
          child: AppBarChart(
            labels: labels,
            values: [for (final p in trend) hours(p.breakMilliseconds)],
            color: AppChartColors.breakTime,
            formatY: hourLabel,
          ),
        ),
      if (data.issueBreakdown.isNotEmpty)
        AppChartCard(
          title: l.reportIssuesByType,
          description: l.reportIssuesByTypeDesc,
          height: 220,
          semanticLabel: l.reportIssuesByType,
          child: AppBarChart(
            labels: [
              for (final issue in data.issueBreakdown)
                _issueLabel(l, issue.code),
            ],
            values: [
              for (final issue in data.issueBreakdown) issue.count.toDouble(),
            ],
            color: AppChartColors.issues,
          ),
        ),
      if (data.groups.isNotEmpty)
        AppChartCard(
          title: l.reportGroupBy,
          description: l.reportGroupBy,
          height: 220,
          semanticLabel: l.reportGroupBy,
          child: AppBarChart(
            labels: [
              for (final group in data.groups)
                group.name.isEmpty ? l.historyNotRecorded : group.name,
            ],
            values: [
              for (final group in data.groups) hours(group.workMilliseconds),
            ],
            color: AppChartColors.series(4),
            formatY: hourLabel,
          ),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppChartCard(
          title: l.reportActivityTrend,
          description: l.reportActivityTrendDesc,
          height: 300,
          loading: false,
          empty: !hasTrend,
          emptyMessage: l.reportNoData,
          semanticLabel: l.reportActivityTrend,
          legend: hasTrend
              ? AppChartLegend(
                  items: [
                    AppChartLegendItem(
                      l.reportRecordedDays,
                      AppChartColors.working,
                    ),
                    AppChartLegendItem(
                      l.reportCompletedDays,
                      AppChartColors.completed,
                    ),
                  ],
                )
              : null,
          footer: _granularityLabel(l, granularity),
          child: hasTrend
              ? AppLineChart(
                  labels: labels,
                  series: [
                    AppChartSeries(
                      label: l.reportRecordedDays,
                      color: AppChartColors.working,
                      values: [
                        for (final p in trend) p.recordedDays.toDouble(),
                      ],
                    ),
                    AppChartSeries(
                      label: l.reportCompletedDays,
                      color: AppChartColors.completed,
                      values: [
                        for (final p in trend) p.completedDays.toDouble(),
                      ],
                    ),
                  ],
                )
              : null,
        ),
        if (secondary.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          AppResponsiveGrid(
            minItemWidth: 420,
            maxColumns: 2,
            children: secondary,
          ),
        ],
      ],
    );
  }

  Color _statusColor(AttendanceReportStatus status) => switch (status) {
    AttendanceReportStatus.completed => AppChartColors.completed,
    AttendanceReportStatus.late => AppChartColors.late,
    AttendanceReportStatus.working => AppChartColors.working,
    AttendanceReportStatus.issues => AppChartColors.issues,
  };

  Widget _attention(
    BuildContext context,
    AttendanceReportData data,
    AttendanceReportFilter filter,
    ValueChanged<AttendanceReportFilter> change,
  ) {
    final l = context.l10n;
    final number = AppNumberFormatter(Localizations.localeOf(context));
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(title: l.reportNeedsAttention),
          const SizedBox(height: AppSpacing.md),
          for (final issue in data.issueBreakdown)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Expanded(child: Text(_issueLabel(l, issue.code))),
                  AppStatusBadge(
                    label: number.integer(issue.count),
                    status: _issueStatus(issue.code),
                    showDot: true,
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppTextButton(
              label: l.reportIssues,
              onPressed: () => change(filter.copyWith(hasIssues: true)),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasAttention(AttendanceReportData data) =>
      data.issueBreakdown.isNotEmpty;

  List<Widget> _filters(
    BuildContext context,
    AttendanceReportState state, {
    AttendanceReportFilter? draft,
    AttendanceReportSort? draftSort,
    ValueChanged<AttendanceReportFilter>? onDraftChanged,
    ValueChanged<AttendanceReportSort>? onSortChanged,
  }) {
    final l = context.l10n;
    final filter = draft ?? state.filter!;
    final options = state.options;
    final bloc = context.read<AttendanceReportBloc>();
    void apply(AttendanceReportFilter value) => onDraftChanged == null
        ? bloc.add(AttendanceReportFilterChanged(value))
        : onDraftChanged(value);
    void applySort(AttendanceReportSort value) => onSortChanged == null
        ? bloc.add(AttendanceReportSortChanged(value))
        : onSortChanged(value);
    void selected(
      Set<String> ids,
      AttendanceReportFilter Function(Set<String>) copy,
    ) => apply(copy(ids));
    Widget select(
      String label,
      Set<String> chosen,
      List<AttendanceReportOption> choices,
      AttendanceReportFilter Function(Set<String>) copy,
    ) => SizedBox(
      width: 190,
      child: AppDropdown<String>(
        label: label,
        value: chosen.isEmpty ? '' : chosen.first,
        items: [
          DropdownMenuItem(value: '', child: Text(l.reportAny)),
          for (final option in choices)
            DropdownMenuItem(value: option.id, child: Text(option.name)),
        ],
        onChanged: (v) => selected(v == null || v.isEmpty ? {} : {v}, copy),
      ),
    );
    return [
      select(
        l.reportEmployee,
        filter.employeeIds,
        options?.employees ?? [],
        (ids) => filter.copyWith(employeeIds: ids),
      ),
      select(
        l.reportDepartment,
        filter.departmentIds,
        options?.departments ?? [],
        (ids) => filter.copyWith(departmentIds: ids),
      ),
      select(
        l.workforceShift,
        filter.shiftIds,
        options?.shifts ?? [],
        (ids) => filter.copyWith(shiftIds: ids),
      ),
      select(
        l.reportLocation,
        filter.locationIds,
        options?.locations ?? [],
        (ids) => filter.copyWith(locationIds: ids),
      ),
      SizedBox(
        width: 170,
        child: AppDropdown<String>(
          label: l.reportStatus,
          value: filter.statuses.isEmpty ? '' : filter.statuses.first,
          items: [
            DropdownMenuItem(value: '', child: Text(l.reportAny)),
            DropdownMenuItem(value: 'working', child: Text(l.workforceWorking)),
            DropdownMenuItem(
              value: 'completed',
              child: Text(l.workforceCompleted),
            ),
            DropdownMenuItem(value: 'late', child: Text(l.reportLateCount)),
          ],
          onChanged: (v) => apply(
            filter.copyWith(statuses: v == null || v.isEmpty ? {} : {v}),
          ),
        ),
      ),
      SizedBox(
        width: 170,
        child: AppDropdown<String>(
          label: l.reportCorrections,
          value: filter.hasCorrections == null
              ? ''
              : filter.hasCorrections!
              ? 'yes'
              : 'no',
          items: [
            DropdownMenuItem(value: '', child: Text(l.reportAny)),
            DropdownMenuItem(value: 'yes', child: Text(l.reportYes)),
            DropdownMenuItem(value: 'no', child: Text(l.reportNo)),
          ],
          onChanged: (v) => apply(
            filter.copyWith(
              hasCorrections: v == 'yes'
                  ? true
                  : v == 'no'
                  ? false
                  : null,
              clearCorrections: v == null || v.isEmpty,
            ),
          ),
        ),
      ),
      SizedBox(
        width: 170,
        child: AppDropdown<String>(
          label: l.reportIssues,
          value: filter.hasIssues == null
              ? ''
              : filter.hasIssues!
              ? 'yes'
              : 'no',
          items: [
            DropdownMenuItem(value: '', child: Text(l.reportAny)),
            DropdownMenuItem(value: 'yes', child: Text(l.reportYes)),
            DropdownMenuItem(value: 'no', child: Text(l.reportNo)),
          ],
          onChanged: (v) => apply(
            filter.copyWith(
              hasIssues: v == 'yes'
                  ? true
                  : v == 'no'
                  ? false
                  : null,
              clearIssues: v == null || v.isEmpty,
            ),
          ),
        ),
      ),
      SizedBox(
        width: 190,
        child: AppDropdown<AttendanceReportGroup>(
          label: l.reportGroupBy,
          value: filter.group,
          items: [
            DropdownMenuItem(
              value: AttendanceReportGroup.department,
              child: Text(l.reportDepartment),
            ),
            DropdownMenuItem(
              value: AttendanceReportGroup.shift,
              child: Text(l.workforceShift),
            ),
            DropdownMenuItem(
              value: AttendanceReportGroup.location,
              child: Text(l.reportLocation),
            ),
          ],
          onChanged: (v) {
            if (v != null) {
              apply(filter.copyWith(group: v));
            }
          },
        ),
      ),
      SizedBox(
        width: 190,
        child: AppDropdown<AttendanceReportSort>(
          label: l.workforceSort,
          value: draftSort ?? state.sort,
          items: [
            DropdownMenuItem(
              value: AttendanceReportSort.newest,
              child: Text(l.reportSortNewest),
            ),
            DropdownMenuItem(
              value: AttendanceReportSort.oldest,
              child: Text(l.reportSortOldest),
            ),
            DropdownMenuItem(
              value: AttendanceReportSort.employee,
              child: Text(l.reportSortEmployee),
            ),
            DropdownMenuItem(
              value: AttendanceReportSort.workedMost,
              child: Text(l.reportSortWork),
            ),
            DropdownMenuItem(
              value: AttendanceReportSort.breaksMost,
              child: Text(l.reportSortBreak),
            ),
          ],
          onChanged: (v) {
            if (v != null) applySort(v);
          },
        ),
      ),
      AppTextButton(
        label: l.reportClearFilters,
        onPressed: () => apply(
          AttendanceReportFilter(
            period: filter.period,
            from: filter.from,
            to: filter.to,
            scope: filter.scope,
          ),
        ),
      ),
    ];
  }

  Future<void> _mobileFilters(
    BuildContext context,
    AttendanceReportState state,
  ) async {
    var draft = state.filter!;
    var draftSort = state.sort;
    await AppBottomSheet.show<void>(
      context,
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, setSheet) => Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSectionHeader(title: context.l10n.reportFilter),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _filters(
                  context,
                  state,
                  draft: draft,
                  draftSort: draftSort,
                  onDraftChanged: (value) => setSheet(() => draft = value),
                  onSortChanged: (value) => setSheet(() => draftSort = value),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                label: context.l10n.reportApply,
                onPressed: () {
                  context.read<AttendanceReportBloc>().add(
                    AttendanceReportSettingsChanged(draft, draftSort),
                  );
                  Navigator.pop(sheet);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _table(BuildContext context, AttendanceReportData data) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context);
    final dates = AppDateFormatter(locale);
    final time = AppTimeFormatter(locale);
    final number = AppNumberFormatter(locale);
    final grouped =
        data.type == AttendanceReportType.workHours ||
        data.type == AttendanceReportType.breakAnalysis ||
        data.type == AttendanceReportType.employeeSummary;
    DataColumn column(String text) => DataColumn(label: Text(text));
    String stamp(DateTime? instant) =>
        instant == null ? l.historyNotRecorded : time.time(instant);
    String status(AttendanceReportRow row) => switch (row.status) {
      'late' => l.reportLateCount,
      'completed' => l.reportCompleted,
      'working' => l.workforceWorking,
      _ => l.historyNotRecorded,
    };
    List<DataColumn> columns() {
      if (grouped) {
        return [
          column(l.reportEmployee),
          column(l.reportDepartment),
          column(l.reportRecorded),
          column(l.reportCompleted),
          column(l.reportLateCount),
          column(l.reportWorked),
          column(l.reportBreak),
          column(l.reportIssuesCount),
        ];
      }
      if (data.type == AttendanceReportType.lateAttendance) {
        return [
          column(l.reportDate),
          column(l.reportEmployee),
          column(l.reportShiftStart),
          column(l.reportPunchIn),
          column(l.reportLateBy),
          column(l.reportDepartment),
          column(l.reportLocation),
          column(l.reportCorrections),
        ];
      }
      if (data.type == AttendanceReportType.issues) {
        return [
          column(l.reportDate),
          column(l.reportEmployee),
          column(l.reportStatus),
          column(l.reportIssuesCount),
          column(l.reportPendingCorrections),
          column(l.reportDepartment),
        ];
      }
      return [
        column(l.reportDate),
        column(l.reportEmployee),
        column(l.reportStatus),
        column(l.reportWorked),
        column(l.reportBreak),
        column(l.reportLateBy),
        column(l.reportDepartment),
      ];
    }

    List<DataCell> cells(AttendanceReportRow row) {
      if (grouped) {
        return [
          DataCell(Text(row.employeeName)),
          DataCell(Text(row.department)),
          DataCell(Text(number.integer(row.recordedDays))),
          DataCell(Text(number.integer(row.completedDays))),
          DataCell(Text(number.integer(row.lateDays))),
          DataCell(Text(time.duration(row.work, l))),
          DataCell(Text(time.duration(row.breaks, l))),
          DataCell(Text(number.integer(row.issueDays))),
        ];
      }
      if (data.type == AttendanceReportType.lateAttendance) {
        return [
          DataCell(Text(dates.date(row.date!))),
          DataCell(Text(row.employeeName)),
          DataCell(Text(stamp(row.scheduledStart))),
          DataCell(Text(stamp(row.punchIn))),
          DataCell(Text(time.duration(row.lateBy, l))),
          DataCell(Text(row.department)),
          DataCell(Text(row.location ?? '')),
          DataCell(Text(number.integer(row.pendingCorrections))),
        ];
      }
      if (data.type == AttendanceReportType.issues) {
        return [
          DataCell(Text(dates.date(row.date!))),
          DataCell(Text(row.employeeName)),
          DataCell(Text(status(row))),
          DataCell(Text(number.integer(row.issueDays))),
          DataCell(Text(number.integer(row.pendingCorrections))),
          DataCell(Text(row.department)),
        ];
      }
      return [
        DataCell(Text(dates.date(row.date!))),
        DataCell(Text(row.employeeName)),
        DataCell(Text(status(row))),
        DataCell(Text(time.duration(row.work, l))),
        DataCell(Text(time.duration(row.breaks, l))),
        DataCell(Text(time.duration(row.lateBy, l))),
        DataCell(Text(row.department)),
      ];
    }

    return AppDataTable(
      columns: columns(),
      rows: [
        for (final row in data.rows)
          DataRow(
            onSelectChanged: (_) => _openRow(context, data.filter.scope, row),
            cells: cells(row),
          ),
      ],
    );
  }

  void _openRow(
    BuildContext context,
    AttendanceScope scope,
    AttendanceReportRow row,
  ) {
    if (row.dayId != null) {
      context.go(
        AppRoutes.attendanceWorkforceDetails(
          row.employeeId,
          row.dayId!,
          team: scope == AttendanceScope.team,
        ),
      );
    } else {
      context.go(
        scope == AttendanceScope.team
            ? AppRoutes.attendanceTeam
            : AppRoutes.attendanceAll,
      );
    }
  }

  Widget _exportButton(
    BuildContext context,
    AttendanceReportState state,
    bool compact,
  ) {
    final l = context.l10n;
    final actor = context.read<AuthBloc?>()?.state.context;
    void export(ReportExportFormat format) {
      if (actor == null) return;
      context.read<AttendanceReportBloc>().add(
        AttendanceReportExportRequested(
          format: format,
          locale: Localizations.localeOf(context),
          companyName: actor.company.name,
        ),
      );
    }

    if (compact) {
      return AppTextButton(
        label: l.reportExport,
        onPressed: state.exporting
            ? null
            : () => AppBottomSheet.show<void>(
                context,
                builder: (sheet) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppSectionHeader(title: l.reportExport),
                    const SizedBox(height: AppSpacing.md),
                    AppSecondaryButton(
                      label: l.reportCsv,
                      onPressed: () {
                        Navigator.pop(sheet);
                        export(ReportExportFormat.csv);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppSecondaryButton(
                      label: l.reportPdf,
                      onPressed: () {
                        Navigator.pop(sheet);
                        export(ReportExportFormat.pdf);
                      },
                    ),
                  ],
                ),
              ),
      );
    }
    return PopupMenuButton<ReportExportFormat>(
      tooltip: l.reportExport,
      onSelected: export,
      enabled: !state.exporting,
      itemBuilder: (_) => [
        PopupMenuItem(value: ReportExportFormat.csv, child: Text(l.reportCsv)),
        PopupMenuItem(value: ReportExportFormat.pdf, child: Text(l.reportPdf)),
      ],
      child: AppStatusBadge(
        label: state.exporting ? l.reportLoading : l.reportExport,
        status: AppStatus.info,
      ),
    );
  }
}
