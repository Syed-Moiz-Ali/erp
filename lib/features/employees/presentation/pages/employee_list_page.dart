import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/security/app_permission.dart';
import '../../../../core/localization/app_formatters.dart';
import '../../../../design_system/design_system.dart';
import '../../../../design_system/theme/app_breakpoints.dart';
import '../../../../l10n/l10n.dart';
import '../../../../app/router/app_routes.dart';
import '../../domain/employee.dart';
import '../bloc/employee_list_bloc.dart';
import '../employee_localization.dart';

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({super.key});
  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  final search = TextEditingController();
  @override
  void initState() {
    super.initState();
    search.text = context.read<EmployeeListBloc>().state.query;
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> filters(BuildContext context, EmployeeListState state) async {
    var draft = state.filter;
    final refs = state.references;
    Widget panel(BuildContext c) => StatefulBuilder(
      builder: (c, set) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSectionHeader(title: c.l10n.empFilters),
          const SizedBox(height: AppSpacing.xl),
          AppDropdown<EmploymentStatus>(
            key: ValueKey(draft.status),
            label: c.l10n.status,
            value: draft.status,
            items: [
              DropdownMenuItem(value: null, child: Text(c.l10n.empAll)),
              for (final value in EmploymentStatus.values)
                DropdownMenuItem(
                  value: value,
                  child: Text(
                    value == EmploymentStatus.active
                        ? c.l10n.empActive
                        : c.l10n.empInactive,
                  ),
                ),
            ],
            onChanged: (v) => set(() => draft = draft.copyWith(status: v)),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final field in [
            (
              label: c.l10n.empDepartment,
              options: refs?.departments ?? <WorkforceReference>[],
              value: draft.departmentId,
              index: 0,
            ),
            (
              label: c.l10n.empDesignation,
              options: refs?.designations ?? <WorkforceReference>[],
              value: draft.designationId,
              index: 1,
            ),
            (
              label: c.l10n.empManager,
              options: refs?.managers ?? <WorkforceReference>[],
              value: draft.managerId,
              index: 2,
            ),
          ]) ...[
            AppSelectField<String>(
              label: field.label,
              value: field.value,
              options: field.options
                  .map((r) => AppSelectOption(r.id, r.name))
                  .toList(),
              onChanged: (v) => set(
                () => draft = field.index == 0
                    ? draft.copyWith(departmentId: v)
                    : field.index == 1
                    ? draft.copyWith(designationId: v)
                    : draft.copyWith(managerId: v),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          AppDropdown<EmploymentType>(
            key: ValueKey(draft.employmentType),
            label: c.l10n.empType,
            value: draft.employmentType,
            items: [
              DropdownMenuItem(value: null, child: Text(c.l10n.empAll)),
              for (final value in EmploymentType.values)
                DropdownMenuItem(
                  value: value,
                  child: Text(employmentTypeLabel(value, c.l10n)),
                ),
            ],
            onChanged: (v) =>
                set(() => draft = draft.copyWith(employmentType: v)),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              AppTextButton(
                label: c.l10n.empReset,
                onPressed: () => set(() => draft = const EmployeeFilter()),
              ),
              AppPrimaryButton(
                label: c.l10n.empApply,
                onPressed: () => Navigator.pop(c, draft),
              ),
            ],
          ),
        ],
      ),
    );
    final compact = AppBreakpoints.of(context) == AppSize.compact;
    final pending = compact
        ? AppBottomSheet.show<EmployeeFilter>(context, builder: panel)
        : AppDialog.show<EmployeeFilter>(
            context,
            (c) => AppDialog(title: c.l10n.empFilters, child: panel(c)),
          );
    final result = await pending;
    if (context.mounted && result != null) {
      context.read<EmployeeListBloc>().add(EmployeeFilterChanged(result));
    }
  }

  List<AppMenuAction> actions(BuildContext context, Employee e) {
    final bloc = context.read<EmployeeListBloc>(),
        can = PermissionChecker(bloc.context.user.permissions).can;
    return [
      AppMenuAction(
        label: (l) => l.empView,
        onPressed: () => context.push(AppRoutes.employeeDetails(e.id)),
      ),
      if (can(AppPermission.employeeUpdate))
        AppMenuAction(
          label: (l) => l.empEdit,
          onPressed: () => context.push(AppRoutes.employeeEdit(e.id)),
        ),
      if (can(AppPermission.employeeDeactivate))
        AppMenuAction(
          label: (l) => e.status == EmploymentStatus.active
              ? l.empDeactivate
              : l.empActivate,
          onPressed: () async {
            if (await AppConfirmationDialog.show(
                  context,
                  title: (l) => l.empStatusConfirm,
                  message: (l) => l.empStatusMessage,
                  confirmLabel: (l) => e.status == EmploymentStatus.active
                      ? l.empDeactivate
                      : l.empActivate,
                ) &&
                context.mounted) {
              bloc.add(
                EmployeeStatusRequested(
                  e.id,
                  e.status != EmploymentStatus.active,
                ),
              );
            }
          },
        ),
    ];
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<EmployeeListBloc, EmployeeListState>(
    listenWhen: (a, b) =>
        b.statusSaved || b.failure != null && a.failure != b.failure,
    listener: (c, s) {
      if (s.statusSaved) {
        AppFeedback.showMessage(c, message: (l) => l.empStatusSaved);
      }
    },
    builder: (context, state) {
      final l = context.l10n,
          bloc = context.read<EmployeeListBloc>(),
          numbers = AppNumberFormatter(Localizations.localeOf(context));
      final compact = AppBreakpoints.of(context) == AppSize.compact,
          can = PermissionChecker(bloc.context.user.permissions).can;
      final rows = state.data?.employees ?? <Employee>[];
      Widget body;
      if (state.loading && state.data == null) {
        body = const AppEmployeeSkeleton();
      } else if (state.failure != null && state.data == null) {
        body = AppErrorState(
          message: employeeFailure(state.failure!, l),
          onRetry: () => bloc.add(const EmployeeListStarted()),
        );
      } else if (rows.isEmpty) {
        body = AppEmptyState(
          title: (state.data?.total ?? 0) == 0 ? l.empEmpty : l.empNoResults,
          message: (state.data?.total ?? 0) == 0
              ? l.empEmptyMessage
              : l.empNoResultsMessage,
          actionLabel:
              (state.data?.total ?? 0) == 0 && can(AppPermission.employeeCreate)
              ? l.empAdd
              : null,
          onAction: () => context.push(AppRoutes.employeeNew),
        );
      } else if (compact) {
        body = Column(
          children: [
            for (final e in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      AppAvatar(name: e.displayName),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              context.push(AppRoutes.employeeDetails(e.id)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.displayName,
                                style: AppTypography.of(context).label,
                              ),
                              Text(
                                e.employeeCode,
                                textDirection: TextDirection.ltr,
                                style: AppTypography.of(context).caption,
                              ),
                              Text(
                                [
                                  referenceLabel(
                                    state.references?.designations,
                                    e.designationId,
                                    l,
                                  ),
                                  referenceLabel(
                                    state.references?.departments,
                                    e.departmentId,
                                    l,
                                  ),
                                ].join(' · '),
                                style: AppTypography.of(context).caption,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              employeeBadge(e, l),
                            ],
                          ),
                        ),
                      ),
                      AppActionMenu(
                        tooltip: l.empActions,
                        enabled: !state.busy,
                        actions: actions(context, e),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      } else {
        final expanded =
            AppBreakpoints.of(context) == AppSize.expanded ||
            AppBreakpoints.of(context) == AppSize.large;
        body = AppCard(
          padding: EdgeInsets.zero,
          child: AppDataTable(
            sortColumnIndex: state.sort == EmployeeSort.code
                ? 1
                : state.sort == EmployeeSort.newestJoined ||
                      state.sort == EmployeeSort.oldestJoined
                ? expanded
                      ? 6
                      : null
                : 0,
            sortAscending:
                state.sort != EmployeeSort.nameDescending &&
                state.sort != EmployeeSort.newestJoined,
            columns: [
              DataColumn(
                label: Text(l.fullName),
                onSort: (_, asc) => bloc.add(
                  EmployeeSortChanged(
                    asc
                        ? EmployeeSort.nameAscending
                        : EmployeeSort.nameDescending,
                  ),
                ),
              ),
              DataColumn(
                label: Text(l.empCode),
                onSort: (_, __) =>
                    bloc.add(const EmployeeSortChanged(EmployeeSort.code)),
              ),
              DataColumn(label: Text(l.empDepartment)),
              if (expanded) ...[
                DataColumn(label: Text(l.empDesignation)),
                DataColumn(label: Text(l.empManager)),
                DataColumn(label: Text(l.empType)),
                DataColumn(
                  label: Text(l.empJoined),
                  onSort: (_, asc) => bloc.add(
                    EmployeeSortChanged(
                      asc
                          ? EmployeeSort.oldestJoined
                          : EmployeeSort.newestJoined,
                    ),
                  ),
                ),
              ],
              DataColumn(label: Text(l.status)),
              DataColumn(
                label: Semantics(
                  label: l.empActions,
                  child: const Icon(Icons.more_horiz),
                ),
              ),
            ],
            rows: [
              for (final e in rows)
                DataRow(
                  onSelectChanged: (_) =>
                      context.push(AppRoutes.employeeDetails(e.id)),
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          AppAvatar(name: e.displayName, radius: 16),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.displayName,
                                style: AppTypography.of(context).label,
                              ),
                              Text(
                                e.email,
                                textDirection: TextDirection.ltr,
                                style: AppTypography.of(context).caption,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(e.employeeCode, textDirection: TextDirection.ltr),
                    ),
                    DataCell(
                      Text(
                        referenceLabel(
                          state.references?.departments,
                          e.departmentId,
                          l,
                        ),
                      ),
                    ),
                    if (expanded) ...[
                      DataCell(
                        Text(
                          referenceLabel(
                            state.references?.designations,
                            e.designationId,
                            l,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          referenceLabel(
                            state.references?.managerLabels,
                            e.managerId,
                            l,
                          ),
                        ),
                      ),
                      DataCell(Text(employmentTypeLabel(e.employmentType, l))),
                      DataCell(
                        Text(
                          AppDateFormatter(
                            Localizations.localeOf(context),
                          ).date(e.joiningDate),
                        ),
                      ),
                    ],
                    DataCell(employeeBadge(e, l)),
                    DataCell(
                      AppActionMenu(
                        tooltip: l.empActions,
                        enabled: !state.busy,
                        actions: actions(context, e),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      }
      return AppPage(
        maxWidth: AppDimensions.wideContent,
        header: AppPageHeader(
          title: l.shellEmployees,
          subtitle: state.data == null
              ? null
              : l.empCount(
                  numbers.integer(state.data!.filtered),
                  numbers.integer(state.data!.total),
                ),
          actions: [
            if (can(AppPermission.employeeCreate))
              AppPrimaryButton(
                label: l.empAdd,
                icon: Icons.add,
                onPressed: () => context.push(AppRoutes.employeeNew),
              ),
          ],
        ),
        filters: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppToolbar(
              search: AppSearchField(
                controller: search,
                onChanged: (v) => bloc.add(EmployeeSearchChanged(v)),
              ),
              actions: [
                AppSecondaryButton(
                  label: l.empFilterCount(
                    numbers.integer(state.filter.activeCount),
                  ),
                  icon: Icons.tune,
                  onPressed: () => filters(context, state),
                ),
                if (state.filter.activeCount > 0)
                  AppTextButton(
                    label: l.empClear,
                    onPressed: () =>
                        bloc.add(const EmployeeFilterChanged(EmployeeFilter())),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: SizedBox(
                width: compact ? double.infinity : 260,
                child: AppDropdown<EmployeeSort>(
                  label: l.empSort,
                  value: state.sort,
                  items: [
                    for (final value in EmployeeSort.values)
                      DropdownMenuItem(
                        value: value,
                        child: Text(employeeSortLabel(value, l)),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) bloc.add(EmployeeSortChanged(v));
                  },
                ),
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.loading || state.busy)
              const LinearProgressIndicator(minHeight: 2),
            if (state.failure != null && state.data != null)
              AppAlert(
                message: employeeFailure(state.failure!, l),
                status: AppStatus.warning,
              ),
            body,
            const SizedBox(height: AppSpacing.lg),
            if (state.data != null)
              AppTablePagination(
                page: state.page,
                pageSize: 10,
                total: state.data!.filtered,
                onPageChanged: (p) => bloc.add(EmployeePageChanged(p)),
              ),
          ],
        ),
      );
    },
  );
}

AppStatusBadge employeeBadge(Employee e, AppLocalizations l) => AppStatusBadge(
  label: e.status == EmploymentStatus.active ? l.empActive : l.empInactive,
  status: e.status == EmploymentStatus.active
      ? AppStatus.success
      : AppStatus.neutral,
);

class AppEmployeeSkeleton extends StatelessWidget {
  const AppEmployeeSkeleton({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < 4; i++)
        const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: AppCard(child: AppSkeleton(height: 48)),
        ),
    ],
  );
}
