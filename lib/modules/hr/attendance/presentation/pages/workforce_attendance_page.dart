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
  WorkforceFilterOptions? _available;
  @override
  void initState() {
    super.initState();
    options.then((result) {
      if (mounted && result is Success<WorkforceFilterOptions>) {
        setState(() => _available = result.value);
      }
    });
  }

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

  WorkforceAttendanceFilter _withPage(
    WorkforceAttendanceFilter base, {
    String? search,
    String? departmentId,
    bool clearDepartment = false,
    String? shiftId,
    bool clearShift = false,
    String? workLocationId,
    bool clearLocation = false,
    WorkforceAttendanceState? status,
    bool clearStatus = false,
    int page = 0,
    WorkforceAttendanceSort? sort,
  }) => WorkforceAttendanceFilter(
    search: search ?? base.search,
    departmentId: clearDepartment ? null : (departmentId ?? base.departmentId),
    shiftId: clearShift ? null : (shiftId ?? base.shiftId),
    workLocationId: clearLocation
        ? null
        : (workLocationId ?? base.workLocationId),
    status: clearStatus ? null : (status ?? base.status),
    page: page,
    pageSize: base.pageSize,
    sort: sort ?? base.sort,
  );

  int _activeCount(WorkforceAttendanceFilter f) {
    var count = 0;
    if (f.departmentId != null) count++;
    if (f.shiftId != null) count++;
    if (f.workLocationId != null) count++;
    if (f.status != null) count++;
    return count;
  }

  bool _hasFilters(WorkforceAttendanceFilter f) =>
      f.search.trim().isNotEmpty || _activeCount(f) > 0;

  List<AppActiveFilter> _activeChips(
    BuildContext context,
    WorkforceAttendanceBloc bloc,
    WorkforceFilterOptions? available,
    WorkforceAttendanceFilter filter,
  ) {
    final l = context.l10n;
    final chips = <AppActiveFilter>[];
    String? name(List<WorkforceFilterOption> values, String? id) {
      if (id == null) return null;
      for (final option in values) {
        if (option.id == id) return option.name;
      }
      return id;
    }

    void add(String label, WorkforceAttendanceFilter next) => chips.add(
      AppActiveFilter(
        label: label,
        onRemove: () => bloc.add(WorkforceAttendanceFilterChanged(next)),
      ),
    );

    if (filter.departmentId != null) {
      add(
        '${l.workforceDepartment}: ${name(available?.departments ?? const [], filter.departmentId)}',
        _withPage(filter, clearDepartment: true),
      );
    }
    if (filter.shiftId != null) {
      add(
        '${l.workforceShift}: ${name(available?.shifts ?? const [], filter.shiftId)}',
        _withPage(filter, clearShift: true),
      );
    }
    if (filter.workLocationId != null) {
      add(
        '${l.workforceLocation}: ${name(available?.locations ?? const [], filter.workLocationId)}',
        _withPage(filter, clearLocation: true),
      );
    }
    if (filter.status != null) {
      add(
        '${l.status}: ${label(context, filter.status!)}',
        _withPage(filter, clearStatus: true),
      );
    }
    return chips;
  }

  Future<void> _openFilters(
    BuildContext context,
    WorkforceAttendanceViewState state,
    WorkforceAttendanceBloc bloc,
  ) async {
    final available = _available;
    var departmentId = state.filter.departmentId;
    var shiftId = state.filter.shiftId;
    var workLocationId = state.filter.workLocationId;
    var status = state.filter.status;
    final l = context.l10n;

    Widget panel(BuildContext c) => StatefulBuilder(
      builder: (c, set) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSectionHeader(title: l.workforceFilters),
          const SizedBox(height: AppSpacing.lg),
          if (available != null) ...[
            AppDropdown<String>(
              label: l.workforceDepartment,
              value: departmentId ?? '',
              items: [
                DropdownMenuItem(value: '', child: Text(l.workforceAllFilter)),
                for (final option in available.departments)
                  DropdownMenuItem(value: option.id, child: Text(option.name)),
              ],
              onChanged: (v) =>
                  set(() => departmentId = (v == null || v.isEmpty) ? null : v),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppDropdown<String>(
              label: l.workforceShift,
              value: shiftId ?? '',
              items: [
                DropdownMenuItem(value: '', child: Text(l.workforceAllFilter)),
                for (final option in available.shifts)
                  DropdownMenuItem(value: option.id, child: Text(option.name)),
              ],
              onChanged: (v) =>
                  set(() => shiftId = (v == null || v.isEmpty) ? null : v),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppDropdown<String>(
              label: l.workforceLocation,
              value: workLocationId ?? '',
              items: [
                DropdownMenuItem(value: '', child: Text(l.workforceAllFilter)),
                for (final option in available.locations)
                  DropdownMenuItem(value: option.id, child: Text(option.name)),
              ],
              onChanged: (v) => set(
                () => workLocationId = (v == null || v.isEmpty) ? null : v,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          AppDropdown<WorkforceAttendanceState?>(
            label: l.status,
            value: status,
            items: [
              DropdownMenuItem(value: null, child: Text(l.historyAllStatuses)),
              for (final s in WorkforceAttendanceState.values)
                DropdownMenuItem(value: s, child: Text(label(c, s))),
            ],
            onChanged: (v) => set(() => status = v),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              AppTextButton(
                label: l.historyReset,
                onPressed: () => set(() {
                  departmentId = null;
                  shiftId = null;
                  workLocationId = null;
                  status = null;
                }),
              ),
              AppPrimaryButton(
                label: l.historyApply,
                onPressed: () => Navigator.pop(
                  c,
                  _withPage(
                    state.filter,
                    search: state.filter.search,
                    departmentId: departmentId,
                    clearDepartment: departmentId == null,
                    shiftId: shiftId,
                    clearShift: shiftId == null,
                    workLocationId: workLocationId,
                    clearLocation: workLocationId == null,
                    status: status,
                    clearStatus: status == null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final compact = AppBreakpoints.of(context) == AppSize.compact;
    final WorkforceAttendanceFilter? result;
    if (compact) {
      result = await AppBottomSheet.show<WorkforceAttendanceFilter>(
        context,
        builder: panel,
      );
    } else {
      result = await AppDialog.show<WorkforceAttendanceFilter>(
        context,
        (c) => AppDialog(title: l.workforceFilters, child: panel(c)),
      );
    }
    if (result != null && !bloc.isClosed) {
      bloc.add(WorkforceAttendanceFilterChanged(result));
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<WorkforceAttendanceBloc, WorkforceAttendanceViewState>(
    builder: (context, state) {
      final l = context.l10n, bloc = context.read<WorkforceAttendanceBloc>();
      final current = state.date, today = state.today, filter = state.filter;
      final data = state.data;
      final countsSum = data == null
          ? 0
          : data.counts.values.fold<int>(0, (sum, value) => sum + value);
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
        filters: AppCollectionToolbar(
          search: AppSearchField(
            controller: search,
            hint: l.workforceSearch,
            onChanged: (value) => update(query: value),
          ),
          filterButton: AppFilterButton(
            label: l.workforceFilters,
            activeCount: _activeCount(filter),
            onPressed: () => _openFilters(context, state, bloc),
          ),
          sort: AppSortControl<WorkforceAttendanceSort>(
            value: filter.sort,
            label: l.workforceSort,
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
          resultCount: data == null
              ? null
              : AppResultCount(filtered: data.total, total: countsSum),
          activeFilters: _activeChips(context, bloc, _available, filter).isEmpty
              ? null
              : AppActiveFilters(
                  filters: _activeChips(context, bloc, _available, filter),
                  onClearAll: () => bloc.add(
                    WorkforceAttendanceFilterChanged(
                      WorkforceAttendanceFilter(
                        search: '',
                        pageSize: filter.pageSize,
                        sort: filter.sort,
                      ),
                    ),
                  ),
                ),
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
            if (data != null) ...[
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
            if (state.loading && data == null)
              const AppCollectionSkeleton()
            else if (state.failure != null && data == null)
              AppErrorState(
                message: l.attendanceUnavailableTitle,
                onRetry: () => bloc.add(const WorkforceAttendanceRefreshed()),
              )
            else if (data != null) ...[
              if (state.failure != null)
                AppAlert(
                  message: l.attendanceUnavailableTitle,
                  status: AppStatus.warning,
                ),
              if (data.items.isEmpty)
                _hasFilters(filter)
                    ? AppCollectionEmptyState.noResults(
                        title: l.workforceNoResultsTitle,
                        message: l.workforceNoResultsNote,
                        icon: Icons.groups_outlined,
                        onClearFilters: () {
                          search.clear();
                          bloc.add(
                            const WorkforceAttendanceFilterChanged(
                              WorkforceAttendanceFilter(search: ''),
                            ),
                          );
                        },
                      )
                    : AppCollectionEmptyState.noData(
                        title: l.workforceEmptyTitle,
                        message: l.workforceEmptyNote,
                        icon: Icons.groups_outlined,
                      )
              else
                LayoutBuilder(
                  builder: (context, c) {
                    final size = AppBreakpoints.classify(c.maxWidth);
                    final compact =
                        size == AppSize.compact || size == AppSize.medium;
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

                    if (compact) {
                      return Column(
                        children: [
                          for (final item in data.items)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: AppMobileRecordCard(
                                title: item.employeeName,
                                subtitle: item.employeeCode,
                                status: itemStatus(item),
                                statusLabel: itemLabel(context, item),
                                onTap: item.attendanceDayId == null
                                    ? null
                                    : () => open(item),
                                metrics: [
                                  (
                                    label: l.workforceDepartment,
                                    value: item.department ?? '—',
                                  ),
                                  (
                                    label: l.workforceShift,
                                    value: item.shiftName ?? '—',
                                  ),
                                  if (item.hasPendingCorrection)
                                    (
                                      label: l.status,
                                      value: l.workforcePendingCorrection,
                                    ),
                                ],
                              ),
                            ),
                        ],
                      );
                    }
                    return AppCollectionSurface(
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
                              onSelectChanged: item.attendanceDayId == null
                                  ? null
                                  : (_) => open(item),
                              cells: [
                                DataCell(Text(item.employeeName)),
                                DataCell(Text(item.department ?? '—')),
                                DataCell(Text(item.shiftName ?? '—')),
                                DataCell(
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppStatusBadge(
                                        label: itemLabel(context, item),
                                        status: itemStatus(item),
                                      ),
                                      if (item.hasPendingCorrection)
                                        Text(
                                          l.workforcePendingCorrection,
                                          style: AppTypography.of(
                                            context,
                                          ).caption,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: AppSpacing.lg),
              AppPagination(
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
