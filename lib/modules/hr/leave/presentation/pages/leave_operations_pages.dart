import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_repository.dart';
import 'package:modular_erp/modules/hr/leave/presentation/bloc/leave_operations_blocs.dart';
import 'package:modular_erp/modules/hr/leave/presentation/leave_localization.dart';
import 'package:modular_erp/modules/hr/leave/presentation/widgets/leave_operations_widgets.dart';

class TeamLeavePage extends StatelessWidget {
  const TeamLeavePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const LeaveOperationsPage(company: false);
}

class AllLeavePage extends StatelessWidget {
  const AllLeavePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const LeaveOperationsPage(company: true);
}

enum _LeaveViewMode { requests, today, upcoming }

class LeaveOperationsPage extends StatefulWidget {
  const LeaveOperationsPage({super.key, required this.company});
  final bool company;
  @override
  State<LeaveOperationsPage> createState() => _LeaveOperationsPageState();
}

class _LeaveOperationsPageState extends State<LeaveOperationsPage> {
  _LeaveViewMode _mode = _LeaveViewMode.requests;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bloc = context.read<LeaveOperationsBloc>();
    final p = PermissionChecker(bloc.context.user.permissions);
    final canApprove =
        p.can(AppPermission.leaveApproveTeam) ||
        p.can(AppPermission.leaveApproveAll);
    final canBalances = p.canAny([
      AppPermission.leaveBalanceViewTeam,
      AppPermission.leaveBalanceViewAll,
    ]);
    return AppPage(
      header: AppPageHeader(
        title: widget.company ? l.leaveAllNav : l.leaveTeam,
        subtitle: widget.company ? l.leaveAllSubtitle : l.leaveTeamSubtitle,
        actions: [
          AppSecondaryButton(
            icon: Icons.calendar_month_outlined,
            label: l.leaveCalendarNav,
            onPressed: () => context.push(AppRoutes.leaveCalendar),
          ),
          if (canApprove)
            AppSecondaryButton(
              icon: Icons.fact_check_outlined,
              label: l.leaveApprovals,
              onPressed: () => context.push(AppRoutes.leaveApprovals),
            ),
          if (canBalances)
            AppSecondaryButton(
              icon: Icons.account_balance_wallet_outlined,
              label: l.leaveBalancesNav,
              onPressed: () => context.push(AppRoutes.leaveBalances),
            ),
        ],
      ),
      child: BlocBuilder<LeaveOperationsBloc, LeaveOperationsState>(
        builder: (c, s) {
          if (s.loading) return const AppLoadingState();
          if (s.failure != null) {
            return AppErrorState(
              message: configurationFailure(s.failure!, c.l10n),
              onRetry: () => bloc.add(const LeaveOperationsStarted()),
            );
          }
          final data = s.data;
          if (data == null) {
            return AppEmptyState(
              title: l.leaveRequestsEmpty,
              message: l.leaveRequestsEmpty,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LeaveSummaryMetrics(
                summary: data.summary,
                showTeamMembers: !widget.company,
              ),
              const SizedBox(height: AppSpacing.xl),
              _FilterBar(
                company: widget.company,
                filter: s.filter,
                onChanged: (f) => bloc.add(LeaveOperationsFilterChanged(f)),
              ),
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: SegmentedButton<_LeaveViewMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: _LeaveViewMode.requests,
                      label: Text(l.leaveTeamRequests),
                    ),
                    ButtonSegment(
                      value: _LeaveViewMode.today,
                      label: Text(l.viewToday),
                    ),
                    ButtonSegment(
                      value: _LeaveViewMode.upcoming,
                      label: Text(l.viewUpcoming),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (selection) =>
                      setState(() => _mode = selection.first),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              switch (_mode) {
                _LeaveViewMode.requests => LeaveRequestTable(
                  rows: data.requests,
                  canReview: canApprove,
                ),
                _LeaveViewMode.today => LeaveTodaySection(items: data.today),
                _LeaveViewMode.upcoming => LeaveUpcomingSection(
                  items: data.upcoming,
                ),
              },
            ],
          );
        },
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.company,
    required this.filter,
    required this.onChanged,
  });
  final bool company;
  final LeaveRequestFilter filter;
  final ValueChanged<LeaveRequestFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bloc = context.read<LeaveOperationsBloc>();
    final today = bloc.repository.companyToday(bloc.context);
    final active = _activeFilterCount(filter);
    final compact = AppBreakpoints.of(context) == AppSize.compact;
    if (compact) {
      return Row(
        children: [
          Expanded(
            child: AppTextField(
              label: l.leaveSearchOrFilter,
              hint: l.leaveSearchEmployee,
              initialValue: filter.search,
              prefixIcon: Icons.search_rounded,
              onChanged: (v) => onChanged(filter.copyWith(search: v)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppSecondaryButton(
            icon: Icons.tune,
            label: active > 0 ? '${l.filters} ($active)' : l.filters,
            onPressed: () => _openSheet(context, bloc, today),
          ),
        ],
      );
    }
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 240,
                child: AppTextField(
                  label: l.leaveSearchEmployee,
                  hint: l.leaveSearchEmployee,
                  initialValue: filter.search,
                  prefixIcon: Icons.search_rounded,
                  onChanged: (v) => onChanged(filter.copyWith(search: v)),
                ),
              ),
              SizedBox(
                width: 180,
                child: AppSelectField<String>(
                  label: l.periodLabel,
                  value: _periodKey(filter, today),
                  options: [
                    AppSelectOption('all', l.leavePeriodAll),
                    AppSelectOption('today', l.leavePeriodToday),
                    AppSelectOption('week', l.leavePeriodThisWeek),
                    AppSelectOption('month', l.leavePeriodThisMonth),
                    AppSelectOption('next30', l.leavePeriodNext30),
                  ],
                  onChanged: (v) =>
                      onChanged(_applyPeriodFilter(v ?? 'all', filter, today)),
                ),
              ),
              SizedBox(
                width: 180,
                child: AppSelectField<String>(
                  label: l.leaveStatusField,
                  value: filter.status?.name ?? '',
                  options: [
                    AppSelectOption('', l.leaveAllStatuses),
                    for (final status in LeaveRequestStatus.values)
                      AppSelectOption(
                        status.name,
                        leaveRequestStatusLabel(status, l),
                      ),
                  ],
                  onChanged: (v) => onChanged(
                    v == null || v.isEmpty
                        ? filter.copyWith(clearStatus: true)
                        : filter.copyWith(
                            status: LeaveRequestStatus.values.byName(v),
                          ),
                  ),
                ),
              ),
              SizedBox(
                width: 180,
                child: _LeaveTypeSelect(filter: filter, onChanged: onChanged),
              ),
              if (company)
                SizedBox(
                  width: 180,
                  child: _DepartmentSelect(
                    filter: filter,
                    onChanged: onChanged,
                  ),
                ),
              if (active > 0)
                AppTextButton(
                  icon: Icons.restart_alt,
                  label: l.resetFilters,
                  onPressed: () => onChanged(_clearAll(filter)),
                ),
            ],
          ),
          if (active > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final chip in _activeChips(context, filter, today))
                  AppFilterChip(
                    label: chip.label,
                    selected: true,
                    onSelected: (_) => onChanged(chip.clear(filter)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openSheet(
    BuildContext context,
    LeaveOperationsBloc bloc,
    DateTime today,
  ) async {
    final result = await showModalBottomSheet<LeaveRequestFilter>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _FilterSheet(
        repository: bloc.repository,
        authContext: bloc.context,
        company: company,
        initial: filter,
        today: today,
      ),
    );
    if (result != null) onChanged(result);
  }
}

class _LeaveTypeSelect extends StatelessWidget {
  const _LeaveTypeSelect({required this.filter, required this.onChanged});
  final LeaveRequestFilter filter;
  final ValueChanged<LeaveRequestFilter> onChanged;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bloc = context.read<LeaveOperationsBloc>();
    return StreamBuilder<Result<List<LeaveType>>>(
      stream: bloc.repository.watchLeaveTypes(bloc.context),
      builder: (c, snapshot) {
        final types = snapshot.data is Success<List<LeaveType>>
            ? (snapshot.data as Success<List<LeaveType>>).value
            : const <LeaveType>[];
        return AppSelectField<String>(
          label: l.leaveType,
          value: filter.leaveTypeId ?? '',
          options: [
            AppSelectOption('', l.leaveAllTypes),
            for (final type in types) AppSelectOption(type.id, type.name),
          ],
          onChanged: (v) => onChanged(
            v == null || v.isEmpty
                ? filter.copyWith(clearLeaveType: true)
                : filter.copyWith(leaveTypeId: v),
          ),
        );
      },
    );
  }
}

class _DepartmentSelect extends StatelessWidget {
  const _DepartmentSelect({required this.filter, required this.onChanged});
  final LeaveRequestFilter filter;
  final ValueChanged<LeaveRequestFilter> onChanged;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bloc = context.read<LeaveOperationsBloc>();
    return StreamBuilder<Result<List<LeaveDepartmentOption>>>(
      stream: bloc.repository.watchDepartments(bloc.context),
      builder: (c, snapshot) {
        final departments =
            snapshot.data is Success<List<LeaveDepartmentOption>>
            ? (snapshot.data as Success<List<LeaveDepartmentOption>>).value
            : const <LeaveDepartmentOption>[];
        return AppSelectField<String>(
          label: l.leaveDepartment,
          value: filter.departmentId ?? '',
          options: [
            AppSelectOption('', l.leaveAllPeriods),
            for (final department in departments)
              AppSelectOption(department.id, department.name),
          ],
          onChanged: (v) => onChanged(
            v == null || v.isEmpty
                ? filter.copyWith(clearDepartment: true)
                : filter.copyWith(departmentId: v),
          ),
        );
      },
    );
  }
}

class _FilterChipData {
  const _FilterChipData({required this.label, required this.clear});
  final String label;
  final LeaveRequestFilter Function(LeaveRequestFilter) clear;
}

List<_FilterChipData> _activeChips(
  BuildContext context,
  LeaveRequestFilter filter,
  DateTime today,
) {
  final l = context.l10n;
  return [
    if (filter.status != null)
      _FilterChipData(
        label: leaveRequestStatusLabel(filter.status!, l),
        clear: (f) => f.copyWith(clearStatus: true),
      ),
    if (filter.leaveTypeId != null)
      _FilterChipData(
        label: l.leaveType,
        clear: (f) => f.copyWith(clearLeaveType: true),
      ),
    if (filter.departmentId != null)
      _FilterChipData(
        label: l.leaveDepartment,
        clear: (f) => f.copyWith(clearDepartment: true),
      ),
    if (filter.from != null || filter.to != null)
      _FilterChipData(
        label: _periodKeyLabel(_periodKey(filter, today), l),
        clear: (f) => f.copyWith(clearFrom: true, clearTo: true),
      ),
    if (filter.search.trim().isNotEmpty)
      _FilterChipData(
        label: filter.search.trim(),
        clear: (f) => f.copyWith(search: ''),
      ),
  ];
}

int _activeFilterCount(LeaveRequestFilter filter) {
  var count = 0;
  if (filter.status != null) count++;
  if (filter.leaveTypeId != null) count++;
  if (filter.departmentId != null) count++;
  if (filter.from != null || filter.to != null) count++;
  if (filter.search.trim().isNotEmpty) count++;
  return count;
}

String _periodKey(LeaveRequestFilter filter, DateTime today) {
  if (filter.from == null && filter.to == null) return 'all';
  for (final key in ['today', 'week', 'month', 'next30']) {
    final preset = _applyPeriodFilter(key, const LeaveRequestFilter(), today);
    if (filter.from == preset.from && filter.to == preset.to) return key;
  }
  return 'all';
}

String _periodKeyLabel(String key, AppLocalizations l) => switch (key) {
  'today' => l.leavePeriodToday,
  'week' => l.leavePeriodThisWeek,
  'month' => l.leavePeriodThisMonth,
  'next30' => l.leavePeriodNext30,
  _ => l.leavePeriodAll,
};

LeaveRequestFilter _applyPeriodFilter(
  String key,
  LeaveRequestFilter f,
  DateTime today,
) {
  switch (key) {
    case 'today':
      return f.copyWith(from: today, to: today);
    case 'week':
      return f.copyWith(
        from: today.subtract(Duration(days: today.weekday - 1)),
        to: today.add(Duration(days: 7 - today.weekday)),
      );
    case 'month':
      return f.copyWith(
        from: DateTime.utc(today.year, today.month, 1),
        to: DateTime.utc(today.year, today.month + 1, 0),
      );
    case 'next30':
      return f.copyWith(from: today, to: today.add(const Duration(days: 30)));
    default:
      return f.copyWith(clearFrom: true, clearTo: true);
  }
}

LeaveRequestFilter _clearAll(LeaveRequestFilter f) => f.copyWith(
  search: '',
  clearStatus: true,
  clearLeaveType: true,
  clearDepartment: true,
  clearFrom: true,
  clearTo: true,
);

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.repository,
    required this.authContext,
    required this.company,
    required this.initial,
    required this.today,
  });
  final LeaveRepository repository;
  final AuthContext authContext;
  final bool company;
  final LeaveRequestFilter initial;
  final DateTime today;
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late LeaveRequestFilter _draft = widget.initial;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.filters, style: AppTypography.of(context).sectionTitle),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.leaveSearchEmployee,
              initialValue: _draft.search,
              prefixIcon: Icons.search_rounded,
              onChanged: (v) => _draft = _draft.copyWith(search: v),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSelectField<String>(
              label: l.periodLabel,
              value: _periodKey(_draft, widget.today),
              options: [
                AppSelectOption('all', l.leavePeriodAll),
                AppSelectOption('today', l.leavePeriodToday),
                AppSelectOption('week', l.leavePeriodThisWeek),
                AppSelectOption('month', l.leavePeriodThisMonth),
                AppSelectOption('next30', l.leavePeriodNext30),
              ],
              onChanged: (v) =>
                  _draft = _applyPeriodFilter(v ?? 'all', _draft, widget.today),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSelectField<String>(
              label: l.leaveStatusField,
              value: _draft.status?.name ?? '',
              options: [
                AppSelectOption('', l.leaveAllStatuses),
                for (final status in LeaveRequestStatus.values)
                  AppSelectOption(
                    status.name,
                    leaveRequestStatusLabel(status, l),
                  ),
              ],
              onChanged: (v) => _draft = v == null || v.isEmpty
                  ? _draft.copyWith(clearStatus: true)
                  : _draft.copyWith(
                      status: LeaveRequestStatus.values.byName(v),
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            StreamBuilder<Result<List<LeaveType>>>(
              stream: widget.repository.watchLeaveTypes(widget.authContext),
              builder: (c, snapshot) {
                final types = snapshot.data is Success<List<LeaveType>>
                    ? (snapshot.data as Success<List<LeaveType>>).value
                    : const <LeaveType>[];
                return AppSelectField<String>(
                  label: l.leaveType,
                  value: _draft.leaveTypeId ?? '',
                  options: [
                    AppSelectOption('', l.leaveAllTypes),
                    for (final type in types)
                      AppSelectOption(type.id, type.name),
                  ],
                  onChanged: (v) => _draft = v == null || v.isEmpty
                      ? _draft.copyWith(clearLeaveType: true)
                      : _draft.copyWith(leaveTypeId: v),
                );
              },
            ),
            if (widget.company) ...[
              const SizedBox(height: AppSpacing.md),
              StreamBuilder<Result<List<LeaveDepartmentOption>>>(
                stream: widget.repository.watchDepartments(widget.authContext),
                builder: (c, snapshot) {
                  final departments =
                      snapshot.data is Success<List<LeaveDepartmentOption>>
                      ? (snapshot.data as Success<List<LeaveDepartmentOption>>)
                            .value
                      : const <LeaveDepartmentOption>[];
                  return AppSelectField<String>(
                    label: l.leaveDepartment,
                    value: _draft.departmentId ?? '',
                    options: [
                      AppSelectOption('', l.leaveAllPeriods),
                      for (final department in departments)
                        AppSelectOption(department.id, department.name),
                    ],
                    onChanged: (v) => _draft = v == null || v.isEmpty
                        ? _draft.copyWith(clearDepartment: true)
                        : _draft.copyWith(departmentId: v),
                  );
                },
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                AppSecondaryButton(
                  label: l.resetFilters,
                  onPressed: () =>
                      setState(() => _draft = const LeaveRequestFilter()),
                ),
                const Spacer(),
                AppSecondaryButton(
                  label: l.cancel,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppPrimaryButton(
                  label: l.leaveApply,
                  onPressed: () => Navigator.pop(context, _draft),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
