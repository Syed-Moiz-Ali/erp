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
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/enquiries/presentation/bloc/service_enquiry_blocs.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class ServiceEnquiryListPage extends StatelessWidget {
  const ServiceEnquiryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    bool can(AppPermission p) => permissions?.contains(p) ?? false;
    final canView = can(AppPermission.serviceEnquiryView);
    final canCreate = can(AppPermission.serviceEnquiryCreate);
    final canEdit = can(AppPermission.serviceEnquiryEdit);
    final canCancel = can(AppPermission.serviceEnquiryCancel);
    return BlocBuilder<ServiceEnquiryListCubit, ServiceEnquiryListState>(
      builder: (context, state) {
        final l = context.l10n;
        final cubit = context.read<ServiceEnquiryListCubit>();
        final numbers = AppNumberFormatter(Localizations.localeOf(context));
        final dates = AppDateFormatter(Localizations.localeOf(context));
        final items = state.page?.items ?? const <ServiceEnquiryListItem>[];
        final page = state.page;
        final compact = AppBreakpoints.of(context) == AppSize.compact;

        List<AppMenuAction> actions(ServiceEnquiryListItem item) => [
          AppMenuAction(
            label: (l) => l.viewDetails,
            onPressed: () => context.go(ServicesRoutes.enquiry(item.id)),
          ),
          if (canEdit && item.status.isOpen)
            AppMenuAction(
              label: (l) => l.servicesEnquiryEdit,
              onPressed: () => context.go(ServicesRoutes.enquiryEdit(item.id)),
            ),
          if (canCancel && item.status.isOpen)
            AppMenuAction(
              label: (l) => l.servicesEnquiryCancel,
              onPressed: () => _confirmCancel(context, cubit, item, l),
            ),
        ];

        Widget body;
        if (!canView) {
          body = AppEmptyState(
            title: l.servicesEnquiriesTitle,
            message: l.servicesEnquiryEmptyMessage,
            actionLabel: canCreate ? l.servicesEnquiryAdd : null,
            onAction: () => context.go(ServicesRoutes.enquiriesNew),
          );
        } else if (state.loading && page == null) {
          body = const AppConfigurationSkeleton();
        } else if (state.failure != null && page == null) {
          body = AppErrorState(
            message: l.servicesEnquiryStorageError,
            onRetry: cubit.start,
          );
        } else if (items.isEmpty) {
          final empty =
              (page?.total ?? 0) == 0 && state.filter.activeCount == 0;
          body = AppEmptyState(
            title: empty ? l.servicesEnquiryEmpty : l.servicesEnquiryNoResults,
            message: empty
                ? l.servicesEnquiryEmptyMessage
                : l.servicesEnquiryNoResults,
            actionLabel: empty && canCreate ? l.servicesEnquiryAdd : null,
            onAction: () => context.go(ServicesRoutes.enquiriesNew),
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
                    title: item.enquiryNumber,
                    subtitle: item.customerName,
                    tertiary: item.siteName,
                    leading: AppAvatar(name: item.customerName),
                    status: serviceEnquiryStatus(item.status),
                    statusLabel: serviceEnquiryStatusLabel(item.status, l),
                    onTap: () => context.go(ServicesRoutes.enquiry(item.id)),
                    metrics: [
                      (
                        label: l.servicesEnquiryColumnPriority,
                        value: item.priorityName,
                      ),
                      (
                        label: l.servicesEnquiryColumnCreated,
                        value: dates.date(item.createdAt),
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
              DataColumn(label: Text(l.servicesEnquiryColumnEnquiry)),
              DataColumn(label: Text(l.servicesEnquiryColumnCustomer)),
              DataColumn(label: Text(l.servicesEnquiryColumnSite)),
              DataColumn(label: Text(l.servicesEnquiryColumnService)),
              DataColumn(label: Text(l.servicesEnquiryColumnPriority)),
              DataColumn(label: Text(l.servicesEnquiryColumnTicket)),
              DataColumn(label: Text(l.servicesEnquiryColumnStatus)),
              DataColumn(label: Text(l.servicesEnquiryColumnCreated)),
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
                      context.go(ServicesRoutes.enquiry(item.id)),
                  cells: [
                    DataCell(
                      Text(
                        item.enquiryNumber,
                        textDirection: TextDirection.ltr,
                        style: AppTypography.of(context).label,
                      ),
                    ),
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.customerName),
                          if (item.customerMobile != null)
                            Text(
                              item.customerMobile!,
                              textDirection: TextDirection.ltr,
                              style: AppTypography.of(context).caption,
                            ),
                        ],
                      ),
                    ),
                    DataCell(Text(item.siteName)),
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.serviceTypeName),
                          Text(
                            item.complaintTypeName,
                            style: AppTypography.of(context).caption,
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      AppStatusBadge(
                        label: item.priorityName,
                        status: servicePriorityStatus(item.priorityRank),
                        isPill: true,
                      ),
                    ),
                    DataCell(Text(item.ticketTypeName)),
                    DataCell(
                      AppStatusBadge(
                        label: serviceEnquiryStatusLabel(item.status, l),
                        status: serviceEnquiryStatus(item.status),
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
            title: l.servicesEnquiriesTitle,
            subtitle: page == null
                ? null
                : l.servicesEnquiryCount(
                    numbers.integer(page.filtered),
                    numbers.integer(page.total),
                  ),
            actions: [
              if (canCreate)
                AppPrimaryButton(
                  label: l.servicesEnquiryAdd,
                  icon: Icons.add,
                  onPressed: () => context.go(ServicesRoutes.enquiriesNew),
                ),
            ],
          ),
          filters: canView
              ? AppToolbar(
                  search: AppSearchField(
                    hint: l.servicesEnquirySearch,
                    onChanged: cubit.search,
                  ),
                  actions: [
                    AppSecondaryButton(
                      label: state.filter.activeCount == 0
                          ? l.servicesEnquiryFilterTitle
                          : '${l.servicesEnquiryFilterTitle} (${numbers.integer(state.filter.activeCount)})',
                      icon: Icons.tune,
                      onPressed: () => _openFilters(context, state),
                    ),
                    if (state.filter.activeCount > 0)
                      AppTextButton(
                        label: l.clear,
                        onPressed: cubit.clearFilters,
                      ),
                  ],
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (canView && state.loading && page != null)
                const LinearProgressIndicator(minHeight: 2),
              if (canView && state.failure != null && page != null)
                AppAlert(
                  message: l.servicesEnquiryStorageError,
                  status: AppStatus.warning,
                ),
              body,
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    ServiceEnquiryListCubit cubit,
    ServiceEnquiryListItem item,
    AppLocalizations l,
  ) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: (l) => l.servicesEnquiryCancelConfirmTitle,
      message: (l) => l.servicesEnquiryCancelConfirmMessage,
      confirmLabel: (l) => l.servicesEnquiryCancel,
    );
    if (!confirmed || !context.mounted) return;
    final result = await cubit.cancel(item.id);
    if (!context.mounted) return;
    AppFeedback.showMessage(
      context,
      message: (l) => result is Success
          ? l.servicesEnquiryCancelled
          : l.servicesEnquiryStorageError,
    );
  }

  Future<void> _openFilters(
    BuildContext context,
    ServiceEnquiryListState state,
  ) async {
    var draft = state.filter;
    final l = context.l10n;
    Widget panel(BuildContext c) => StatefulBuilder(
      builder: (c, set) {
        final complaintOptions = [
          for (final ct in state.complaintTypes)
            if (ct.serviceTypeId == null ||
                ct.serviceTypeId == draft.serviceTypeId)
              ct,
        ];
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSectionHeader(title: l.servicesEnquiryFilterTitle),
            const SizedBox(height: AppSpacing.xl),
            AppDropdown<ServiceEnquiryStatus?>(
              label: l.servicesEnquiryFilterStatus,
              value: draft.status,
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l.servicesEnquiryAllStatuses),
                ),
                DropdownMenuItem(
                  value: ServiceEnquiryStatus.open,
                  child: Text(l.servicesEnquiryStatusOpen),
                ),
                DropdownMenuItem(
                  value: ServiceEnquiryStatus.assigned,
                  child: Text(l.servicesEnquiryStatusAssigned),
                ),
                DropdownMenuItem(
                  value: ServiceEnquiryStatus.cancelled,
                  child: Text(l.servicesEnquiryStatusCancelled),
                ),
              ],
              onChanged: (v) => set(
                () => draft = v == null
                    ? draft.copyWith(clearStatus: true)
                    : draft.copyWith(status: v),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _masterFilter(
              l.servicesEnquiryFilterServiceType,
              state.serviceTypes,
              draft.serviceTypeId,
              (v) => set(
                () => draft = v == null
                    ? draft.copyWith(
                        clearServiceType: true,
                        clearComplaintType: true,
                      )
                    : draft.copyWith(
                        serviceTypeId: v,
                        clearComplaintType: true,
                      ),
              ),
              l,
            ),
            const SizedBox(height: AppSpacing.lg),
            _masterFilter(
              l.servicesEnquiryFilterComplaintType,
              complaintOptions,
              draft.complaintTypeId,
              (v) => set(
                () => draft = v == null
                    ? draft.copyWith(clearComplaintType: true)
                    : draft.copyWith(complaintTypeId: v),
              ),
              l,
            ),
            const SizedBox(height: AppSpacing.lg),
            _masterFilter(
              l.servicesEnquiryFilterPriority,
              state.priorities,
              draft.priorityId,
              (v) => set(
                () => draft = v == null
                    ? draft.copyWith(clearPriority: true)
                    : draft.copyWith(priorityId: v),
              ),
              l,
            ),
            const SizedBox(height: AppSpacing.lg),
            _masterFilter(
              l.servicesEnquiryFilterTicketType,
              state.ticketTypes,
              draft.ticketTypeId,
              (v) => set(
                () => draft = v == null
                    ? draft.copyWith(clearTicketType: true)
                    : draft.copyWith(ticketTypeId: v),
              ),
              l,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppDateField(
              label: l.servicesEnquiryFilterCreatedFrom,
              value: draft.createdFrom,
              onChanged: (v) =>
                  set(() => draft = draft.copyWith(createdFrom: v)),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppDateField(
              label: l.servicesEnquiryFilterCreatedTo,
              value: draft.createdTo,
              onChanged: (v) => set(() => draft = draft.copyWith(createdTo: v)),
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                AppTextButton(
                  label: l.resetFilters,
                  onPressed: () =>
                      set(() => draft = const ServiceEnquiryFilter()),
                ),
                AppPrimaryButton(
                  label: l.confirm,
                  onPressed: () => Navigator.pop(c, draft),
                ),
              ],
            ),
          ],
        );
      },
    );
    final pending = AppBreakpoints.of(context) == AppSize.compact
        ? AppBottomSheet.show<ServiceEnquiryFilter>(context, builder: panel)
        : AppDialog.show<ServiceEnquiryFilter>(
            context,
            (c) =>
                AppDialog(title: l.servicesEnquiryFilterTitle, child: panel(c)),
          );
    final result = await pending;
    if (context.mounted && result != null) {
      context.read<ServiceEnquiryListCubit>().applyFilter(result);
    }
  }

  Widget _masterFilter(
    String label,
    List<ServiceMasterRecord> options,
    String? value,
    ValueChanged<String?> onChanged,
    AppLocalizations l,
  ) => AppSelectField<String>(
    label: label,
    value: value,
    onChanged: (v) => onChanged(v == null || v.isEmpty ? null : v),
    options: [
      AppSelectOption('', l.servicesEnquiryAllStatuses),
      for (final option in options) AppSelectOption(option.id, option.name),
    ],
  );
}
