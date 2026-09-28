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
          body = const AppConfigurationSkeleton();
        } else if (state.failure != null && page == null) {
          body = AppErrorState(
            message: l.servicesInspectionStorageError,
            onRetry: cubit.start,
          );
        } else if (items.isEmpty) {
          final empty = (page?.total ?? 0) == 0;
          body = AppEmptyState(
            title: empty
                ? l.servicesInspectionEmpty
                : l.servicesInspectionNoResults,
            message: empty
                ? l.servicesInspectionEmptyMessage
                : l.servicesInspectionNoResults,
            actionLabel: empty && canCreate ? l.servicesInspectionAdd : null,
            onAction: () => context.go(ServicesRoutes.inspectionsNew),
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
          body = AppDataTable(
            columns: [
              DataColumn(label: Text(l.servicesInspectionColumnInspection)),
              DataColumn(label: Text(l.servicesInspectionColumnAssignment)),
              DataColumn(label: Text(l.servicesInspectionColumnCustomerSite)),
              DataColumn(label: Text(l.servicesInspectionColumnVisit)),
              DataColumn(label: Text(l.servicesInspectionColumnTechnician)),
              DataColumn(label: Text(l.servicesInspectionColumnRootCause)),
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
                      Text(
                        item.inspectionNumber,
                        textDirection: TextDirection.ltr,
                        style: AppTypography.of(context).label,
                      ),
                    ),
                    DataCell(Text(item.assignmentNumber)),
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
                    DataCell(Text(visitLabel(item))),
                    DataCell(Text(item.technicianName ?? '')),
                    DataCell(Text(item.rootCauseName ?? '')),
                    DataCell(
                      AppStatusBadge(
                        label: serviceInspectionStatusLabel(item.status, l),
                        status: serviceInspectionStatus(item.status),
                        isPill: true,
                      ),
                    ),
                    DataCell(
                      AppActionMenu(tooltip: l.actions, actions: actions(item)),
                    ),
                  ],
                ),
            ],
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
          filters: AppToolbar(
            search: AppSearchField(
              hint: l.servicesInspectionSearch,
              onChanged: cubit.search,
            ),
            actions: [
              AppSecondaryButton(
                label: state.filter.activeCount == 0
                    ? l.servicesInspectionFilterTitle
                    : '${l.servicesInspectionFilterTitle} (${numbers.integer(state.filter.activeCount)})',
                icon: Icons.tune,
                onPressed: () => _openFilters(context, state),
              ),
              if (state.filter.activeCount > 0)
                AppTextButton(label: l.clear, onPressed: cubit.clearFilters),
            ],
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
