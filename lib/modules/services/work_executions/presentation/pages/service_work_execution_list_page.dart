import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';
import 'package:modular_erp/modules/services/work_executions/presentation/bloc/service_work_execution_blocs.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class ServiceWorkExecutionListPage extends StatelessWidget {
  const ServiceWorkExecutionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    bool can(AppPermission p) => permissions?.contains(p) ?? false;
    final canCreate = can(AppPermission.serviceWorkExecutionCreate);
    final canCancel = can(AppPermission.serviceWorkExecutionCancel);
    return BlocBuilder<
      ServiceWorkExecutionListCubit,
      ServiceWorkExecutionListState
    >(
      builder: (context, state) {
        final l = context.l10n;
        final cubit = context.read<ServiceWorkExecutionListCubit>();
        final numbers = AppNumberFormatter(Localizations.localeOf(context));
        final items =
            state.page?.items ?? const <ServiceWorkExecutionListItem>[];
        final page = state.page;
        final compact = AppBreakpoints.of(context) == AppSize.compact;
        final time = AppTimeFormatter(Localizations.localeOf(context));

        Future<void> cancel(ServiceWorkExecutionListItem item) async {
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: (l) => l.servicesWorkExecutionCancelConfirmTitle,
            message: (l) => l.servicesWorkExecutionCancelConfirmMessage,
            confirmLabel: (l) => l.servicesWorkExecutionCancel,
          );
          if (!confirmed || !context.mounted) return;
          final result = await cubit.cancel(item.id);
          if (!context.mounted) return;
          AppFeedback.showMessage(
            context,
            message: (l) => result is Success
                ? l.servicesWorkExecutionCancelled
                : l.servicesWorkExecutionStorageError,
          );
        }

        String stateLabel(
          ServiceWorkExecutionListItem item,
          AppLocalizations l,
        ) {
          if (item.status.isCompleted) {
            return l.servicesWorkExecutionLineStateFinished;
          }
          if (item.startedAtUtc != null) {
            return l.servicesWorkExecutionLineStateInProgress;
          }
          return l.servicesWorkExecutionLineStateNotStarted;
        }

        List<AppMenuAction> actions(ServiceWorkExecutionListItem item) => [
          AppMenuAction(
            label: (l) => l.viewDetails,
            onPressed: () => context.go(ServicesRoutes.workExecution(item.id)),
          ),
          if (canCancel && !item.status.isCompleted && !item.status.isCancelled)
            AppMenuAction(
              label: (l) => l.servicesWorkExecutionCancel,
              onPressed: () => cancel(item),
            ),
        ];

        Widget body;
        if (state.loading && page == null) {
          body = const AppCollectionSkeleton();
        } else if (state.failure != null && page == null) {
          body = AppErrorState(
            message: l.servicesWorkExecutionStorageError,
            onRetry: cubit.start,
          );
        } else if (items.isEmpty) {
          final empty = (page?.total ?? 0) == 0;
          body = empty
              ? AppCollectionEmptyState.noData(
                  title: l.servicesWorkExecutionEmpty,
                  message: l.servicesWorkExecutionEmptyMessage,
                  actionLabel: canCreate ? l.servicesWorkExecutionAdd : null,
                  onAction: () => context.go(ServicesRoutes.workExecutionsNew),
                )
              : AppCollectionEmptyState.noResults(
                  title: l.servicesWorkExecutionNoResults,
                  message: l.servicesWorkExecutionNoResults,
                  onClearFilters: cubit.clearFilters,
                );
        } else if (compact) {
          body = Column(
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: AppSpacing.md,
                  ),
                  child: AppMobileRecordCard(
                    title: item.executionNumber,
                    subtitle: item.customerName,
                    tertiary: item.siteSummary,
                    leading: AppAvatar(name: item.customerName),
                    status: serviceWorkExecutionStatus(item.status),
                    statusLabel: serviceWorkExecutionStatusLabel(
                      item.status,
                      l,
                    ),
                    onTap: () =>
                        context.go(ServicesRoutes.workExecution(item.id)),
                    metrics: [
                      (
                        label: l.servicesWorkExecutionColumnInspection,
                        value: item.inspectionNumber,
                      ),
                      (
                        label: l.servicesWorkExecutionColumnAssignedTo,
                        value: item.assignedSummary,
                      ),
                    ],
                    trailing: canCancel
                        ? AppActionMenu(
                            tooltip: l.actions,
                            actions: actions(item),
                          )
                        : null,
                  ),
                ),
            ],
          );
        } else {
          body = AppCollectionSurface(
            child: AppDataTable(
              columns: [
                DataColumn(label: Text(l.servicesWorkExecutionColumnExecution)),
                DataColumn(
                  label: Text(l.servicesWorkExecutionColumnCustomerSite),
                ),
                DataColumn(
                  label: Text(l.servicesWorkExecutionColumnAssignedTo),
                ),
                DataColumn(label: Text(l.servicesWorkExecutionColumnState)),
                DataColumn(label: Text(l.servicesWorkExecutionColumnStarted)),
                DataColumn(label: Text(l.servicesWorkExecutionColumnStatus)),
                DataColumn(
                  label: Semantics(
                    label: l.actions,
                    child: const Icon(Icons.more_horiz),
                  ),
                ),
              ],
              rows: [
                for (final item in items)
                  DataRow(
                    onSelectChanged: (_) =>
                        context.go(ServicesRoutes.workExecution(item.id)),
                    cells: [
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (item.startedAtUtc != null &&
                                    !item.status.isCompleted)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsetsDirectional.only(
                                      end: AppSpacing.sm,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                Text(
                                  item.executionNumber,
                                  textDirection: TextDirection.ltr,
                                  style: AppTypography.of(context).label,
                                ),
                              ],
                            ),
                            Text(
                              item.inspectionNumber,
                              textDirection: TextDirection.ltr,
                              style: AppTypography.of(context).caption,
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.customerName),
                            if (item.siteSummary.isNotEmpty)
                              Text(
                                item.siteSummary,
                                style: AppTypography.of(context).caption,
                              ),
                          ],
                        ),
                      ),
                      DataCell(Text(item.assignedSummary)),
                      DataCell(Text(stateLabel(item, l))),
                      DataCell(
                        Text(
                          [
                            if (item.startedAtUtc != null)
                              time.time(item.startedAtUtc!),
                            if (item.endedAtUtc != null)
                              time.time(item.endedAtUtc!),
                          ].join(' → '),
                        ),
                      ),
                      DataCell(
                        AppStatusBadge(
                          label: serviceWorkExecutionStatusLabel(
                            item.status,
                            l,
                          ),
                          status: serviceWorkExecutionStatus(item.status),
                          isPill: true,
                        ),
                      ),
                      DataCell(
                        AppActionMenu(
                          tooltip: l.actions,
                          actions: actions(item),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        }

        return AppPage(
          header: AppPageHeader(
            title: l.servicesWorkExecutionsTitle,
            subtitle: page == null
                ? null
                : l.servicesWorkExecutionCount(
                    numbers.integer(page.filtered),
                    numbers.integer(page.total),
                  ),
            actions: [
              if (canCreate)
                AppPrimaryButton(
                  label: l.servicesWorkExecutionAdd,
                  icon: Icons.add,
                  onPressed: () => context.go(ServicesRoutes.workExecutionsNew),
                ),
            ],
          ),
          filters: AppCollectionToolbar(
            search: AppSearchField(
              hint: l.servicesWorkExecutionSearch,
              onChanged: cubit.search,
            ),
            filterButton: AppFilterButton(
              label: l.servicesWorkExecutionFilterTitle,
              activeCount: state.filter.activeCount,
              onPressed: () => _openFilters(context, state),
            ),
            resultCount: AppResultCount(
              filtered: page?.filtered ?? 0,
              total: page?.total,
            ),
            activeFilters: AppActiveFilters(
              filters: _activeFilterChips(context, state, cubit, l),
              onClearAll: cubit.clearFilters,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.loading && page != null)
                const LinearProgressIndicator(minHeight: 2),
              if (state.failure != null && page != null)
                AppAlert(
                  message: l.servicesWorkExecutionStorageError,
                  status: AppStatus.warning,
                ),
              body,
            ],
          ),
        );
      },
    );
  }

  List<AppActiveFilter> _activeFilterChips(
    BuildContext context,
    ServiceWorkExecutionListState state,
    ServiceWorkExecutionListCubit cubit,
    AppLocalizations l,
  ) {
    final f = state.filter;
    final dates = AppDateFormatter(Localizations.localeOf(context));
    final chips = <AppActiveFilter>[];
    void add(String label, ServiceWorkExecutionFilter next) => chips.add(
      AppActiveFilter(label: label, onRemove: () => cubit.applyFilter(next)),
    );
    if (f.status != null) {
      add(
        '${l.servicesWorkExecutionFilterStatus}: ${serviceWorkExecutionStatusLabel(f.status!, l)}',
        f.copyWith(clearStatus: true),
      );
    }
    if (f.dateFrom != null) {
      add(
        '${l.servicesWorkExecutionFilterFrom}: ${dates.date(f.dateFrom!)}',
        f.copyWith(clearDateFrom: true),
      );
    }
    if (f.dateTo != null) {
      add(
        '${l.servicesWorkExecutionFilterTo}: ${dates.date(f.dateTo!)}',
        f.copyWith(clearDateTo: true),
      );
    }
    return chips;
  }

  Future<void> _openFilters(
    BuildContext context,
    ServiceWorkExecutionListState state,
  ) async {
    var draft = state.filter;
    final l = context.l10n;
    Widget panel(BuildContext c) => StatefulBuilder(
      builder: (c, set) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(title: l.servicesWorkExecutionFilterTitle),
          const SizedBox(height: AppSpacing.xl),
          AppSelectField<ServiceWorkExecutionStatus?>(
            label: l.servicesWorkExecutionFilterStatus,
            value: draft.status,
            options: [
              AppSelectOption(null, l.servicesWorkExecutionAllStatuses),
              for (final s in ServiceWorkExecutionStatus.values)
                AppSelectOption(s, serviceWorkExecutionStatusLabel(s, l)),
            ],
            onChanged: (v) => set(
              () => draft = v == null
                  ? draft.copyWith(clearStatus: true)
                  : draft.copyWith(status: v),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppDateField(
            label: l.servicesWorkExecutionFilterFrom,
            value: draft.dateFrom,
            onChanged: (v) => set(() => draft = draft.copyWith(dateFrom: v)),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppDateField(
            label: l.servicesWorkExecutionFilterTo,
            value: draft.dateTo,
            onChanged: (v) => set(() => draft = draft.copyWith(dateTo: v)),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              AppTextButton(
                label: l.resetFilters,
                onPressed: () =>
                    set(() => draft = const ServiceWorkExecutionFilter()),
              ),
              AppPrimaryButton(
                label: l.confirm,
                onPressed: () => Navigator.pop(c, draft),
              ),
            ],
          ),
        ],
      ),
    );
    final pending = AppBreakpoints.of(context) == AppSize.compact
        ? AppBottomSheet.show<ServiceWorkExecutionFilter>(
            context,
            builder: panel,
          )
        : AppDialog.show<ServiceWorkExecutionFilter>(
            context,
            (c) => AppDialog(
              title: l.servicesWorkExecutionFilterTitle,
              child: panel(c),
            ),
          );
    final result = await pending;
    if (context.mounted && result != null) {
      context.read<ServiceWorkExecutionListCubit>().applyFilter(result);
    }
  }
}
