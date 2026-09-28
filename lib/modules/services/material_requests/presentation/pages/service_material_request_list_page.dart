import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request.dart';
import 'package:modular_erp/modules/services/material_requests/presentation/bloc/service_material_request_blocs.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class ServiceMaterialRequestListPage extends StatelessWidget {
  const ServiceMaterialRequestListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    bool can(AppPermission p) => permissions?.contains(p) ?? false;
    final canCreate = can(AppPermission.serviceMaterialRequestCreate);
    final canEdit = can(AppPermission.serviceMaterialRequestEdit);
    final canCancel = can(AppPermission.serviceMaterialRequestCancel);
    return BlocBuilder<
      ServiceMaterialRequestListCubit,
      ServiceMaterialRequestListState
    >(
      builder: (context, state) {
        final l = context.l10n;
        final cubit = context.read<ServiceMaterialRequestListCubit>();
        final numbers = AppNumberFormatter(Localizations.localeOf(context));
        final dates = AppDateFormatter(Localizations.localeOf(context));
        final items =
            state.page?.items ?? const <ServiceMaterialRequestListItem>[];
        final page = state.page;
        final compact = AppBreakpoints.of(context) == AppSize.compact;

        Future<void> cancel(ServiceMaterialRequestListItem item) async {
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: (l) => l.servicesMaterialRequestCancelConfirmTitle,
            message: (l) => l.servicesMaterialRequestCancelConfirmMessage,
            confirmLabel: (l) => l.servicesMaterialRequestCancel,
          );
          if (!confirmed || !context.mounted) return;
          final result = await cubit.cancel(item.id);
          if (!context.mounted) return;
          AppFeedback.showMessage(
            context,
            message: (l) => result is Success
                ? l.servicesMaterialRequestCancelled
                : l.servicesMaterialRequestStorageError,
          );
        }

        List<AppMenuAction> actions(ServiceMaterialRequestListItem item) => [
          AppMenuAction(
            label: (l) => l.viewDetails,
            onPressed: () =>
                context.go(ServicesRoutes.materialRequest(item.id)),
          ),
          if (canEdit && item.status.isOpen)
            AppMenuAction(
              label: (l) => l.servicesMaterialRequestEdit,
              onPressed: () =>
                  context.go(ServicesRoutes.materialRequestEdit(item.id)),
            ),
          if (canCancel && item.status.isOpen)
            AppMenuAction(
              label: (l) => l.servicesMaterialRequestCancel,
              onPressed: () => cancel(item),
            ),
        ];

        Widget body;
        if (state.loading && page == null) {
          body = const AppConfigurationSkeleton();
        } else if (state.failure != null && page == null) {
          body = AppErrorState(
            message: l.servicesMaterialRequestStorageError,
            onRetry: cubit.start,
          );
        } else if (items.isEmpty) {
          final empty = (page?.total ?? 0) == 0;
          body = AppEmptyState(
            title: empty
                ? l.servicesMaterialRequestEmpty
                : l.servicesMaterialRequestNoResults,
            message: empty
                ? l.servicesMaterialRequestEmptyMessage
                : l.servicesMaterialRequestNoResults,
            actionLabel: empty && canCreate
                ? l.servicesMaterialRequestAdd
                : null,
            onAction: () => context.go(ServicesRoutes.materialRequestsNew),
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
                    title: item.requestNumber,
                    subtitle: item.customerName,
                    tertiary: item.siteSummary,
                    leading: AppAvatar(name: item.customerName),
                    status: serviceMaterialRequestStatus(item.status),
                    statusLabel: serviceMaterialRequestStatusLabel(
                      item.status,
                      l,
                    ),
                    onTap: () =>
                        context.go(ServicesRoutes.materialRequest(item.id)),
                    metrics: [
                      (
                        label: l.servicesMaterialRequestColumnInspection,
                        value: item.inspectionNumber,
                      ),
                      (
                        label: l.servicesMaterialRequestColumnTotalQty,
                        value: formatMaterialQuantity(item.totalQuantity),
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
              DataColumn(label: Text(l.servicesMaterialRequestColumnRequest)),
              DataColumn(label: Text(l.servicesMaterialRequestColumnDate)),
              DataColumn(
                label: Text(l.servicesMaterialRequestColumnInspection),
              ),
              DataColumn(
                label: Text(l.servicesMaterialRequestColumnCustomerSite),
              ),
              DataColumn(label: Text(l.servicesMaterialRequestColumnPurpose)),
              DataColumn(label: Text(l.servicesMaterialRequestColumnItems)),
              DataColumn(label: Text(l.servicesMaterialRequestColumnTotalQty)),
              DataColumn(label: Text(l.servicesMaterialRequestColumnStatus)),
              DataColumn(
                label: Text(l.servicesMaterialRequestColumnPreparedBy),
              ),
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
                      context.go(ServicesRoutes.materialRequest(item.id)),
                  cells: [
                    DataCell(
                      Text(
                        item.requestNumber,
                        textDirection: TextDirection.ltr,
                        style: AppTypography.of(context).label,
                      ),
                    ),
                    DataCell(Text(dates.date(item.requestDate))),
                    DataCell(Text(item.inspectionNumber)),
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
                    DataCell(Text(item.purposeName ?? '')),
                    DataCell(Text(numbers.integer(item.itemCount))),
                    DataCell(Text(formatMaterialQuantity(item.totalQuantity))),
                    DataCell(
                      AppStatusBadge(
                        label: serviceMaterialRequestStatusLabel(
                          item.status,
                          l,
                        ),
                        status: serviceMaterialRequestStatus(item.status),
                        isPill: true,
                      ),
                    ),
                    DataCell(
                      Text(
                        item.preparedByUserId,
                        textDirection: TextDirection.ltr,
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
            title: l.servicesMaterialRequestsTitle,
            subtitle: page == null
                ? null
                : l.servicesMaterialRequestCount(
                    numbers.integer(page.filtered),
                    numbers.integer(page.total),
                  ),
            actions: [
              if (canCreate)
                AppPrimaryButton(
                  label: l.servicesMaterialRequestAdd,
                  icon: Icons.add,
                  onPressed: () =>
                      context.go(ServicesRoutes.materialRequestsNew),
                ),
            ],
          ),
          filters: AppToolbar(
            search: AppSearchField(
              hint: l.servicesMaterialRequestSearch,
              onChanged: cubit.search,
            ),
            actions: [
              AppSecondaryButton(
                label: state.filter.activeCount == 0
                    ? l.servicesMaterialRequestFilterTitle
                    : '${l.servicesMaterialRequestFilterTitle} (${numbers.integer(state.filter.activeCount)})',
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
                  message: l.servicesMaterialRequestStorageError,
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
    ServiceMaterialRequestListState state,
  ) async {
    var draft = state.filter;
    final l = context.l10n;
    Widget panel(BuildContext c) => StatefulBuilder(
      builder: (c, set) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(title: l.servicesMaterialRequestFilterTitle),
          const SizedBox(height: AppSpacing.xl),
          AppSelectField<ServiceMaterialRequestStatus?>(
            label: l.servicesMaterialRequestFilterStatus,
            value: draft.status,
            options: [
              AppSelectOption(null, l.servicesMaterialRequestAllStatuses),
              for (final s in ServiceMaterialRequestStatus.values)
                AppSelectOption(s, serviceMaterialRequestStatusLabel(s, l)),
            ],
            onChanged: (v) => set(
              () => draft = v == null
                  ? draft.copyWith(clearStatus: true)
                  : draft.copyWith(status: v),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSelectField<String>(
            label: l.servicesMaterialRequestFilterPurpose,
            value: draft.purposeId ?? '',
            options: [
              AppSelectOption('', l.servicesMaterialRequestAllStatuses),
              for (final o in state.purposes) AppSelectOption(o.id, o.name),
            ],
            onChanged: (v) => set(
              () => draft = v == null || v.isEmpty
                  ? draft.copyWith(clearPurpose: true)
                  : draft.copyWith(purposeId: v),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppDateField(
            label: l.servicesMaterialRequestFilterFrom,
            value: draft.dateFrom,
            onChanged: (v) => set(() => draft = draft.copyWith(dateFrom: v)),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppDateField(
            label: l.servicesMaterialRequestFilterTo,
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
                    set(() => draft = const ServiceMaterialRequestFilter()),
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
        ? AppBottomSheet.show<ServiceMaterialRequestFilter>(
            context,
            builder: panel,
          )
        : AppDialog.show<ServiceMaterialRequestFilter>(
            context,
            (c) => AppDialog(
              title: l.servicesMaterialRequestFilterTitle,
              child: panel(c),
            ),
          );
    final result = await pending;
    if (context.mounted && result != null) {
      context.read<ServiceMaterialRequestListCubit>().applyFilter(result);
    }
  }
}
