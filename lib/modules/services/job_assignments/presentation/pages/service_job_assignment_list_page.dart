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
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/modules/services/job_assignments/presentation/bloc/service_job_assignment_blocs.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class ServiceJobAssignmentListPage extends StatelessWidget {
  const ServiceJobAssignmentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    bool can(AppPermission p) => permissions?.contains(p) ?? false;
    final canCreate = can(AppPermission.serviceJobAssignmentCreate);
    final canEdit = can(AppPermission.serviceJobAssignmentEdit);
    final canCancel = can(AppPermission.serviceJobAssignmentCancel);
    return BlocBuilder<
      ServiceJobAssignmentListCubit,
      ServiceJobAssignmentListState
    >(
      builder: (context, state) {
        final l = context.l10n;
        final cubit = context.read<ServiceJobAssignmentListCubit>();
        final numbers = AppNumberFormatter(Localizations.localeOf(context));
        final dates = AppDateFormatter(Localizations.localeOf(context));
        final items =
            state.page?.items ?? const <ServiceJobAssignmentListItem>[];
        final page = state.page;
        final compact = AppBreakpoints.of(context) == AppSize.compact;

        Future<void> cancel(ServiceJobAssignmentListItem item) async {
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: (l) => l.servicesJobAssignmentCancelConfirmTitle,
            message: (l) => l.servicesJobAssignmentCancelConfirmMessage,
            confirmLabel: (l) => l.servicesJobAssignmentCancel,
          );
          if (!confirmed || !context.mounted) return;
          final result = await cubit.cancel(item.id);
          if (!context.mounted) return;
          AppFeedback.showMessage(
            context,
            message: (l) => result is Success
                ? l.servicesJobAssignmentCancelled
                : l.servicesJobAssignmentStorageError,
          );
        }

        List<AppMenuAction> actions(ServiceJobAssignmentListItem item) => [
          AppMenuAction(
            label: (l) => l.viewDetails,
            onPressed: () => context.go(ServicesRoutes.assignment(item.id)),
          ),
          if (canEdit && item.status.isActive)
            AppMenuAction(
              label: (l) => l.servicesJobAssignmentEdit,
              onPressed: () =>
                  context.go(ServicesRoutes.assignmentEdit(item.id)),
            ),
          if (canCancel && item.status.isActive)
            AppMenuAction(
              label: (l) => l.servicesJobAssignmentCancel,
              onPressed: () => cancel(item),
            ),
        ];

        Widget body;
        if (state.loading && page == null) {
          body = const AppConfigurationSkeleton();
        } else if (state.failure != null && page == null) {
          body = AppErrorState(
            message: l.servicesJobAssignmentStorageError,
            onRetry: cubit.start,
          );
        } else if (items.isEmpty) {
          final empty = (page?.total ?? 0) == 0;
          body = AppEmptyState(
            title: empty
                ? l.servicesJobAssignmentEmpty
                : l.servicesJobAssignmentNoResults,
            message: empty
                ? l.servicesJobAssignmentEmptyMessage
                : l.servicesJobAssignmentNoResults,
            actionLabel: empty && canCreate ? l.servicesJobAssignmentAdd : null,
            onAction: () => context.go(ServicesRoutes.assignmentsNew),
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
                    title: item.assignmentNumber,
                    subtitle: item.customerName,
                    tertiary: [
                      item.enquiryNumber,
                      item.siteSummary,
                    ].where((s) => s.isNotEmpty).join(' · '),
                    leading: AppAvatar(name: item.customerName),
                    status: serviceJobAssignmentStatus(item.status),
                    statusLabel: serviceJobAssignmentStatusLabel(
                      item.status,
                      l,
                    ),
                    onTap: () => context.go(ServicesRoutes.assignment(item.id)),
                    metrics: [
                      (
                        label: l.servicesJobAssignmentColumnVisitDate,
                        value: dates.date(item.scheduledVisitDate),
                      ),
                      if (item.assignedSummary.isNotEmpty)
                        (
                          label: l.servicesJobAssignmentColumnAssignedTo,
                          value: item.assignedSummary,
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
              DataColumn(label: Text(l.servicesJobAssignmentColumnAssignment)),
              DataColumn(label: Text(l.servicesJobAssignmentColumnEnquiry)),
              DataColumn(
                label: Text(l.servicesJobAssignmentColumnCustomerSite),
              ),
              DataColumn(label: Text(l.servicesJobAssignmentColumnVisitDate)),
              DataColumn(label: Text(l.servicesJobAssignmentColumnAssignedTo)),
              DataColumn(label: Text(l.servicesJobAssignmentColumnPriority)),
              DataColumn(label: Text(l.servicesJobAssignmentColumnStatus)),
              DataColumn(label: Text(l.servicesJobAssignmentColumnCreated)),
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
                      context.go(ServicesRoutes.assignment(item.id)),
                  cells: [
                    DataCell(
                      Text(
                        item.assignmentNumber,
                        textDirection: TextDirection.ltr,
                        style: AppTypography.of(context).label,
                      ),
                    ),
                    DataCell(
                      Text(
                        item.enquiryNumber,
                        textDirection: TextDirection.ltr,
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
                    DataCell(Text(dates.date(item.scheduledVisitDate))),
                    DataCell(Text(item.assignedSummary)),
                    DataCell(
                      AppStatusBadge(
                        label: item.priorityName,
                        status: servicePriorityStatus(item.priorityRank),
                        isPill: true,
                      ),
                    ),
                    DataCell(
                      AppStatusBadge(
                        label: serviceJobAssignmentStatusLabel(item.status, l),
                        status: serviceJobAssignmentStatus(item.status),
                        isPill: true,
                      ),
                    ),
                    DataCell(Text(dates.date(item.createdAt))),
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
            title: l.servicesJobAssignmentsTitle,
            subtitle: page == null
                ? null
                : l.servicesJobAssignmentCount(
                    numbers.integer(page.filtered),
                    numbers.integer(page.total),
                  ),
            actions: [
              if (canCreate)
                AppPrimaryButton(
                  label: l.servicesJobAssignmentAdd,
                  icon: Icons.add,
                  onPressed: () => context.go(ServicesRoutes.assignmentsNew),
                ),
            ],
          ),
          filters: AppToolbar(
            search: AppSearchField(
              hint: l.servicesJobAssignmentSearch,
              onChanged: cubit.search,
            ),
            actions: [
              AppSecondaryButton(
                label: state.filter.activeCount == 0
                    ? l.servicesJobAssignmentFilterTitle
                    : '${l.servicesJobAssignmentFilterTitle} (${numbers.integer(state.filter.activeCount)})',
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
                  message: l.servicesJobAssignmentStorageError,
                  status: AppStatus.warning,
                ),
              body,
            ],
          ),
        );
      },
    );
  }

  Future<void> _openFilters(
    BuildContext context,
    ServiceJobAssignmentListState state,
  ) async {
    var draft = state.filter;
    final l = context.l10n;
    Widget panel(BuildContext c) => StatefulBuilder(
      builder: (c, set) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(title: l.servicesJobAssignmentFilterTitle),
          const SizedBox(height: AppSpacing.xl),
          AppDropdown<ServiceJobAssignmentStatus?>(
            label: l.servicesJobAssignmentFilterStatus,
            value: draft.status,
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(l.servicesJobAssignmentAllStatuses),
              ),
              DropdownMenuItem(
                value: ServiceJobAssignmentStatus.active,
                child: Text(l.servicesJobAssignmentStatusActive),
              ),
              DropdownMenuItem(
                value: ServiceJobAssignmentStatus.cancelled,
                child: Text(l.servicesJobAssignmentStatusCancelled),
              ),
            ],
            onChanged: (v) => set(
              () => draft = v == null
                  ? draft.copyWith(clearStatus: true)
                  : draft.copyWith(status: v),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSelectField<String>(
            label: l.servicesJobAssignmentFilterPriority,
            value: draft.priorityId,
            onChanged: (v) => set(
              () => draft = v == null || v.isEmpty
                  ? draft.copyWith(clearPriority: true)
                  : draft.copyWith(priorityId: v),
            ),
            options: [
              AppSelectOption('', l.servicesJobAssignmentAllStatuses),
              for (final ServiceMasterRecord p in state.priorities)
                AppSelectOption(p.id, p.name),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppDateField(
            label: l.servicesJobAssignmentFilterVisitFrom,
            value: draft.visitFrom,
            onChanged: (v) => set(() => draft = draft.copyWith(visitFrom: v)),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppDateField(
            label: l.servicesJobAssignmentFilterVisitTo,
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
                    set(() => draft = const ServiceJobAssignmentFilter()),
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
        ? AppBottomSheet.show<ServiceJobAssignmentFilter>(
            context,
            builder: panel,
          )
        : AppDialog.show<ServiceJobAssignmentFilter>(
            context,
            (c) => AppDialog(
              title: l.servicesJobAssignmentFilterTitle,
              child: panel(c),
            ),
          );
    final result = await pending;
    if (context.mounted && result != null) {
      context.read<ServiceJobAssignmentListCubit>().applyFilter(result);
    }
  }
}
