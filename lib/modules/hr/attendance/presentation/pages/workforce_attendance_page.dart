import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/attendance/domain/workforce_attendance.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/workforce_attendance_bloc.dart';

class WorkforceAttendancePage extends StatefulWidget {
  const WorkforceAttendancePage({super.key, required this.scope});
  final AttendanceScope scope;
  @override
  State<WorkforceAttendancePage> createState() =>
      _WorkforceAttendancePageState();
}

class _WorkforceAttendancePageState extends State<WorkforceAttendancePage> {
  final search = TextEditingController();
  late final Future<Result<WorkforceFilterOptions>> options = context
      .read<WorkforceAttendanceBloc>()
      .repository
      .options(widget.scope);
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  String label(BuildContext context, WorkforceAttendanceState status) {
    final l = context.l10n;
    return switch (status) {
      WorkforceAttendanceState.notStarted => l.workforceNotStarted,
      WorkforceAttendanceState.working => l.workforceWorking,
      WorkforceAttendanceState.onBreak => l.workforceOnBreak,
      WorkforceAttendanceState.completed => l.workforceCompleted,
      WorkforceAttendanceState.incomplete => l.workforceIncomplete,
      WorkforceAttendanceState.noSchedule => l.workforceNoSchedule,
      WorkforceAttendanceState.noRecord => l.workforceNoRecord,
    };
  }

  String itemLabel(BuildContext context, WorkforceAttendanceItem item) =>
      switch (item.classification) {
        WorkdayClassification.approvedLeave => context.l10n.workdayOnLeave,
        WorkdayClassification.holiday => context.l10n.workdayHoliday,
        _ => label(context, item.attendanceState),
      };

  AppStatus itemStatus(WorkforceAttendanceItem item) =>
      switch (item.classification) {
        WorkdayClassification.approvedLeave => AppStatus.brand,
        WorkdayClassification.holiday => AppStatus.success,
        _ => item.hasIssue ? AppStatus.warning : AppStatus.neutral,
      };

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<WorkforceAttendanceBloc, WorkforceAttendanceViewState>(
    builder: (context, state) {
      final l = context.l10n, bloc = context.read<WorkforceAttendanceBloc>();
      final current = state.date, today = state.today, filter = state.filter;
      void update({
        String? query,
        WorkforceAttendanceState? status,
        bool clearStatus = false,
        int? page,
        String? department,
        String? shift,
        String? location,
        WorkforceAttendanceSort? sort,
      }) {
        bloc.add(
          WorkforceAttendanceFilterChanged(
            WorkforceAttendanceFilter(
              search: query ?? filter.search,
              status: clearStatus ? null : status ?? filter.status,
              departmentId: department == null
                  ? filter.departmentId
                  : department.isEmpty
                  ? null
                  : department,
              shiftId: shift == null
                  ? filter.shiftId
                  : shift.isEmpty
                  ? null
                  : shift,
              workLocationId: location == null
                  ? filter.workLocationId
                  : location.isEmpty
                  ? null
                  : location,
              page: page ?? 0,
              pageSize: filter.pageSize,
              sort: sort ?? filter.sort,
            ),
          ),
        );
      }

      return AppPage(
        header: AppPageHeader(
          title: widget.scope == AttendanceScope.team
              ? l.workforceTeam
              : l.workforceAll,
          compactActionsInline: true,
          actions: [
            AppIconButton(
              icon: Icons.refresh,
              tooltip: l.historyRetry,
              onPressed: () => bloc.add(const WorkforceAttendanceRefreshed()),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (current != null && today != null)
              Row(
                children: [
                  AppIconButton(
                    icon: Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_right
                        : Icons.chevron_left,
                    tooltip: l.workforcePrevious,
                    onPressed: () => bloc.add(
                      WorkforceAttendanceDateChanged(
                        current.subtract(const Duration(days: 1)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      AppDateFormatter(
                        Localizations.localeOf(context),
                      ).date(current),
                      textAlign: TextAlign.center,
                      style: AppTypography.of(context).sectionTitle,
                    ),
                  ),
                  AppIconButton(
                    icon: Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left
                        : Icons.chevron_right,
                    tooltip: l.workforceNext,
                    onPressed: current.isBefore(today)
                        ? () => bloc.add(
                            WorkforceAttendanceDateChanged(
                              current.add(const Duration(days: 1)),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.lg),
            if (current != null && today != null)
              AppDateField(
                label: l.workforceDate,
                value: current,
                lastDate: today,
                onChanged: (date) =>
                    bloc.add(WorkforceAttendanceDateChanged(date)),
              ),
            const SizedBox(height: AppSpacing.lg),
            if (state.data case final data?) ...[
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final s in [
                    WorkforceAttendanceState.working,
                    WorkforceAttendanceState.onBreak,
                    WorkforceAttendanceState.completed,
                    WorkforceAttendanceState.notStarted,
                    WorkforceAttendanceState.incomplete,
                  ])
                    SizedBox(
                      width: 185,
                      child: AppMetricCard(
                        label: label(context, s),
                        value: AppNumberFormatter(
                          Localizations.localeOf(context),
                        ).integer(data.counts[s] ?? 0),
                        variant: AppMetricVariant.secondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            AppTextField(
              label: l.workforceSearch,
              controller: search,
              prefixIcon: Icons.search,
              onChanged: (value) => update(query: value),
            ),
            const SizedBox(height: AppSpacing.md),
            FutureBuilder<Result<WorkforceFilterOptions>>(
              future: options,
              builder: (context, snapshot) {
                if (snapshot.data is! Success<WorkforceFilterOptions>) {
                  return const SizedBox.shrink();
                }
                final available =
                    (snapshot.data as Success<WorkforceFilterOptions>).value;
                Widget dropdown(
                  String label,
                  String? selected,
                  List<WorkforceFilterOption> values,
                  ValueChanged<String> changed,
                ) => SizedBox(
                  width: 240,
                  child: AppDropdown<String>(
                    label: label,
                    value: selected ?? '',
                    items: [
                      DropdownMenuItem(
                        value: '',
                        child: Text(l.workforceAllFilter),
                      ),
                      for (final option in values)
                        DropdownMenuItem(
                          value: option.id,
                          child: Text(option.name),
                        ),
                    ],
                    onChanged: (v) => changed(v ?? ''),
                  ),
                );
                return Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    dropdown(
                      l.workforceDepartment,
                      filter.departmentId,
                      available.departments,
                      (v) => update(department: v),
                    ),
                    dropdown(
                      l.workforceShift,
                      filter.shiftId,
                      available.shifts,
                      (v) => update(shift: v),
                    ),
                    dropdown(
                      l.workforceLocation,
                      filter.workLocationId,
                      available.locations,
                      (v) => update(location: v),
                    ),
                    SizedBox(
                      width: 240,
                      child: AppDropdown<WorkforceAttendanceSort>(
                        label: l.workforceSort,
                        value: filter.sort,
                        items: [
                          DropdownMenuItem(
                            value: WorkforceAttendanceSort.nameAscending,
                            child: Text(l.workforceName),
                          ),
                          DropdownMenuItem(
                            value: WorkforceAttendanceSort.nameDescending,
                            child: Text(l.workforceNameDescending),
                          ),
                          DropdownMenuItem(
                            value: WorkforceAttendanceSort.code,
                            child: Text(l.workforceCode),
                          ),
                          DropdownMenuItem(
                            value: WorkforceAttendanceSort.status,
                            child: Text(l.historyAllStatuses),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) update(sort: v);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppFilterBar(
              children: [
                AppFilterChip(
                  label: l.historyAllStatuses,
                  selected: filter.status == null,
                  onSelected: (_) => update(clearStatus: true),
                ),
                for (final s in WorkforceAttendanceState.values)
                  AppFilterChip(
                    label: label(context, s),
                    selected: filter.status == s,
                    onSelected: (_) => update(status: s),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            if (state.loading && state.data == null) const AppLoadingState(),
            if (state.failure != null)
              AppNotice(
                title: l.attendanceUnavailableTitle,
                status: AppStatus.danger,
              ),
            if (state.data case final data?) ...[
              if (data.items.isEmpty)
                AppEmptyState(
                  title: l.workforceNoEmployees,
                  message: l.workforceNoEmployees,
                ),
              if (data.items.isNotEmpty)
                LayoutBuilder(
                  builder: (context, c) {
                    final desktop =
                        AppBreakpoints.classify(c.maxWidth) ==
                            AppSize.expanded ||
                        AppBreakpoints.classify(c.maxWidth) == AppSize.large;
                    void open(WorkforceAttendanceItem item) {
                      if (item.attendanceDayId != null) {
                        context.push(
                          AppRoutes.attendanceWorkforceDetails(
                            item.employeeId,
                            item.attendanceDayId!,
                            team: widget.scope == AttendanceScope.team,
                          ),
                        );
                      }
                    }

                    return desktop
                        ? AppCard(
                            padding: EdgeInsets.zero,
                            child: AppDataTable(
                              columns: [
                                DataColumn(label: Text(l.shellEmployees)),
                                DataColumn(label: Text(l.workforceDepartment)),
                                DataColumn(label: Text(l.workforceShift)),
                                DataColumn(label: Text(l.workforceToday)),
                              ],
                              rows: [
                                for (final item in data.items)
                                  DataRow(
                                    onSelectChanged: (_) => open(item),
                                    cells: [
                                      DataCell(Text(item.employeeName)),
                                      DataCell(Text(item.department ?? '—')),
                                      DataCell(Text(item.shiftName ?? '—')),
                                      DataCell(
                                        AppStatusBadge(
                                          label: itemLabel(context, item),
                                          status: itemStatus(item),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              for (final item in data.items)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.md,
                                  ),
                                  child: AppCard(
                                    variant: AppCardVariant.interactive,
                                    onTap: () => open(item),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.employeeName,
                                          style: AppTypography.of(
                                            context,
                                          ).cardTitle,
                                        ),
                                        Text(item.employeeCode),
                                        const SizedBox(height: AppSpacing.sm),
                                        Wrap(
                                          spacing: AppSpacing.sm,
                                          children: [
                                            AppStatusBadge(
                                              label: itemLabel(context, item),
                                              status: itemStatus(item),
                                            ),
                                            if (item.hasPendingCorrection)
                                              AppStatusBadge(
                                                label: l
                                                    .workforcePendingCorrection,
                                                status: AppStatus.info,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          );
                  },
                ),
              AppTablePagination(
                page: filter.page,
                pageSize: filter.pageSize,
                total: data.total,
                onPageChanged: (page) => update(page: page),
              ),
            ],
          ],
        ),
      );
    },
  );
}
