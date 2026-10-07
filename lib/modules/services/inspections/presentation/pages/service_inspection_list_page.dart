import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/inspections/presentation/bloc/service_inspection_blocs.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class ServiceInspectionListPage extends StatelessWidget {
  const ServiceInspectionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    bool can(AppPermission p) => permissions?.contains(p) ?? false;
    final canCreate = can(AppPermission.serviceInspectionCreate);
    final canEdit = can(AppPermission.serviceInspectionEdit);
    final canCancel = can(AppPermission.serviceInspectionCancel);
    return BlocBuilder<ServiceInspectionListCubit, ServiceInspectionListState>(
      builder: (context, state) {
        final l = context.l10n;
        final cubit = context.read<ServiceInspectionListCubit>();
        final numbers = AppNumberFormatter(Localizations.localeOf(context));
        final dates = AppDateFormatter(Localizations.localeOf(context));
        final items = state.page?.items ?? const <ServiceInspectionListItem>[];
        final page = state.page;
        final compact = AppBreakpoints.of(context) == AppSize.compact;
        final times = AppTimeFormatter(Localizations.localeOf(context));

        String visitLabel(ServiceInspectionListItem item) => [
          dates.date(item.visitDate),
          if (item.visitMinutes != null) _time(times, item.visitMinutes!),
        ].join(' · ');

        Future<void> cancel(ServiceInspectionListItem item) async {
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: (l) => l.servicesInspectionCancelConfirmTitle,
            message: (l) => l.servicesInspectionCancelConfirmMessage,
            confirmLabel: (l) => l.servicesInspectionCancel,
          );
          if (!confirmed || !context.mounted) return;
          final result = await cubit.cancel(item.id);
          if (!context.mounted) return;
          AppFeedback.showMessage(
            context,
            message: (l) => result is Success
                ? l.servicesInspectionCancelled
                : l.servicesInspectionStorageError,
          );
        }

        List<AppMenuAction> actions(ServiceInspectionListItem item) => [
          AppMenuAction(
            label: (l) => l.viewDetails,
            onPressed: () => context.go(ServicesRoutes.inspection(item.id)),
          ),
          if (canEdit && item.status.isPending)
            AppMenuAction(
              label: (l) => l.servicesInspectionEdit,
              onPressed: () =>
                  context.go(ServicesRoutes.inspectionEdit(item.id)),
            ),
          if (canCancel && item.status.isPending)
            AppMenuAction(
              label: (l) => l.servicesInspectionCancel,
              onPressed: () => cancel(item),
            ),
        ];

        Widget body;
        if (state.loading && page == null) {
          body = const AppCollectionSkeleton();
        } else if (state.failure != null && page == null) {
          body = AppErrorState(
            message: l.servicesInspectionStorageError,
            onRetry: cubit.start,
          );
        } else if (items.isEmpty) {
          final empty = (page?.total ?? 0) == 0;
          body = empty
              ? AppCollectionEmptyState.noData(
                  title: l.servicesInspectionEmpty,
                  message: l.servicesInspectionEmptyMessage,
                  actionLabel: canCreate ? l.servicesInspectionAdd : null,
                  onAction: () => context.go(ServicesRoutes.inspectionsNew),
                )
              : AppCollectionEmptyState.noResults(
                  title: l.servicesInspectionNoResults,
                  message: l.servicesInspectionNoResults,
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
                    title: item.inspectionNumber,
                    subtitle: item.customerName,
                    tertiary: item.siteSummary,
                    leading: AppAvatar(name: item.customerName),
                    status: serviceInspectionStatus(item.status),
                    statusLabel: serviceInspectionStatusLabel(item.status, l),
                    onTap: () => context.go(ServicesRoutes.inspection(item.id)),
                    metrics: [
                      (
                        label: l.servicesInspectionColumnVisit,
                        value: visitLabel(item),
                      ),
                      if ((item.technicianName ?? '').isNotEmpty)
                        (
                          label: l.servicesInspectionColumnTechnician,
                          value: item.technicianName!,
                        ),
                    ],
                    trailing: canEdit || canCancel
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
                DataColumn(label: Text(l.servicesInspectionColumnInspection)),
                DataColumn(label: Text(l.servicesInspectionColumnAssignment)),
                DataColumn(label: Text(l.servicesInspectionColumnVisit)),
                DataColumn(label: Text(l.servicesInspectionColumnTechnician)),
                DataColumn(label: Text(l.servicesInspectionColumnStatus)),
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
                        context.go(ServicesRoutes.inspection(item.id)),
                    cells: [
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.inspectionNumber,
                              textDirection: TextDirection.ltr,
                              style: AppTypography.of(context).label,
                            ),
                            Text(
                              item.siteSummary.isEmpty
                                  ? item.customerName
                                  : '${item.customerName} · ${item.siteSummary}',
                              style: AppTypography.of(context).caption,
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(item.assignmentNumber)),
                      DataCell(Text(visitLabel(item))),
                      DataCell(Text(item.technicianName ?? '')),
                      DataCell(
                        AppStatusBadge(
                          label: serviceInspectionStatusLabel(item.status, l),
                          status: serviceInspectionStatus(item.status),
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
            title: l.servicesInspectionsTitle,
            subtitle: page == null
                ? null
                : l.servicesInspectionCount(
                    numbers.integer(page.filtered),
                    numbers.integer(page.total),
                  ),
            actions: [
              if (canCreate)
                AppPrimaryButton(
                  label: l.servicesInspectionAdd,
                  icon: Icons.add,
                  onPressed: () => context.go(ServicesRoutes.inspectionsNew),
                ),
            ],
          ),
          filters: AppCollectionToolbar(
            search: AppSearchField(
              hint: l.servicesInspectionSearch,
              onChanged: cubit.search,
            ),
            filterButton: AppFilterButton(
              label: l.servicesInspectionFilterTitle,
              activeCount: state.filter.activeCount,
              onPressed: () => _openFilters(context, state),
            ),
            resultCount: AppResultCount(
              filtered: page?.filtered ?? 0,
              total: page?.total,
            ),
            activeFilters: AppActiveFilters(
              filters: _activeFilterChips(context, state, cubit, l, dates),
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
                  message: l.servicesInspectionStorageError,
                  status: AppStatus.warning,
                ),
              body,
            ],
          ),
        );
      },
    );
  }

  String _time(AppTimeFormatter formatter, int minutes) => formatter.time(
    DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60),
    use24Hour: true,
  );

  List<AppActiveFilter> _activeFilterChips(
    BuildContext context,
    ServiceInspectionListState state,
    ServiceInspectionListCubit cubit,
    AppLocalizations l,
    AppDateFormatter dates,
  ) {
    final f = state.filter;
    String nameOf(List<ServiceMasterRecord> list, String? id) {
      for (final m in list) {
        if (m.id == id) return m.name;
      }
      return '';
    }

    final chips = <AppActiveFilter>[];
    void add(String label, ServiceInspectionFilter next) => chips.add(
      AppActiveFilter(label: label, onRemove: () => cubit.applyFilter(next)),
    );
    if (f.status != null) {
      add(
        '${l.servicesInspectionFilterStatus}: ${serviceInspectionStatusLabel(f.status!, l)}',
        f.copyWith(clearStatus: true),
      );
    }
    if (f.priorityId != null) {
      add(
        '${l.servicesInspectionFilterPriority}: ${nameOf(state.priorities, f.priorityId)}',
        f.copyWith(clearPriority: true),
      );
    }
    if (f.rootCauseId != null) {
      add(
        '${l.servicesInspectionFilterRootCause}: ${nameOf(state.rootCauses, f.rootCauseId)}',
        f.copyWith(clearRootCause: true),
      );
    }
    if (f.visitFrom != null) {
      add(
        '${l.servicesInspectionFilterVisitFrom}: ${dates.date(f.visitFrom!)}',
        f.copyWith(clearVisitFrom: true),
      );
    }
    if (f.visitTo != null) {
      add(
        '${l.servicesInspectionFilterVisitTo}: ${dates.date(f.visitTo!)}',
        f.copyWith(clearVisitTo: true),
      );
    }
    return chips;
  }

  Future<void> _openFilters(
    BuildContext context,
    ServiceInspectionListState state,
  ) async {
    var draft = state.filter;
    final l = context.l10n;
    Widget panel(BuildContext c) => StatefulBuilder(
      builder: (c, set) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(title: l.servicesInspectionFilterTitle),
          const SizedBox(height: AppSpacing.xl),
          AppDropdown<ServiceInspectionStatus?>(
            label: l.servicesInspectionFilterStatus,
            value: draft.status,
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(l.servicesInspectionAllStatuses),
              ),
              for (final s in ServiceInspectionStatus.values)
                DropdownMenuItem(
                  value: s,
                  child: Text(serviceInspectionStatusLabel(s, l)),
                ),
            ],
            onChanged: (v) => set(
              () => draft = v == null
                  ? draft.copyWith(clearStatus: true)
                  : draft.copyWith(status: v),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _master(
            l.servicesInspectionFilterPriority,
            state.priorities,
            draft.priorityId,
            (v) => set(
              () => draft = v == null || v.isEmpty
                  ? draft.copyWith(clearPriority: true)
                  : draft.copyWith(priorityId: v),
            ),
            l,
          ),
          const SizedBox(height: AppSpacing.lg),
          _master(
            l.servicesInspectionFilterRootCause,
            state.rootCauses,
            draft.rootCauseId,
            (v) => set(
              () => draft = v == null || v.isEmpty
                  ? draft.copyWith(clearRootCause: true)
                  : draft.copyWith(rootCauseId: v),
            ),
            l,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppDateField(
            label: l.servicesInspectionFilterVisitFrom,
            value: draft.visitFrom,
            onChanged: (v) => set(() => draft = draft.copyWith(visitFrom: v)),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppDateField(
            label: l.servicesInspectionFilterVisitTo,
            value: draft.visitTo,
            onChanged: (v) => set(() => draft = draft.copyWith(visitTo: v)),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              AppTextButton(
                label: l.resetFilters,
                onPressed: () =>
                    set(() => draft = const ServiceInspectionFilter()),
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
        ? AppBottomSheet.show<ServiceInspectionFilter>(context, builder: panel)
        : AppDialog.show<ServiceInspectionFilter>(
            context,
            (c) => AppDialog(
              title: l.servicesInspectionFilterTitle,
              child: panel(c),
            ),
          );
    final result = await pending;
    if (context.mounted && result != null) {
      context.read<ServiceInspectionListCubit>().applyFilter(result);
    }
  }

  Widget _master(
    String label,
    List<ServiceMasterRecord> options,
    String? value,
    ValueChanged<String?> onChanged,
    AppLocalizations l,
  ) => AppSelectField<String>(
    label: label,
    value: value,
    onChanged: onChanged,
    options: [
      AppSelectOption('', l.servicesInspectionAllStatuses),
      for (final o in options) AppSelectOption(o.id, o.name),
    ],
  );
}
