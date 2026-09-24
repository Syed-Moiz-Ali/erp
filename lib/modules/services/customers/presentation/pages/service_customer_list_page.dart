import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer.dart';
import 'package:modular_erp/modules/services/customers/presentation/bloc/service_customer_blocs.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class ServiceCustomerListPage extends StatelessWidget {
  const ServiceCustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    final canCreate =
        permissions?.contains(AppPermission.serviceCustomerCreate) ?? false;
    final canEdit =
        permissions?.contains(AppPermission.serviceCustomerEdit) ?? false;
    final canDeactivate =
        permissions?.contains(AppPermission.serviceCustomerDeactivate) ?? false;
    return BlocBuilder<ServiceCustomerListCubit, ServiceCustomerListState>(
      builder: (context, state) {
        final l = context.l10n;
        final cubit = context.read<ServiceCustomerListCubit>();
        final numbers = AppNumberFormatter(Localizations.localeOf(context));
        final dates = AppDateFormatter(Localizations.localeOf(context));
        final items = state.page?.items ?? const <ServiceCustomerListItem>[];
        final page = state.page;
        final compact = AppBreakpoints.of(context) == AppSize.compact;

        Future<void> toggle(ServiceCustomerListItem item, bool active) async {
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: (l) => active
                ? l.servicesCustomerActivate
                : l.servicesCustomerDeactivate,
            message: (l) => item.name,
            confirmLabel: (l) =>
                active ? l.confirm : l.servicesCustomerDeactivate,
          );
          if (!confirmed || !context.mounted) return;
          final result = await cubit.setActive(item.id, active);
          if (context.mounted) {
            AppFeedback.showMessage(
              context,
              message: (l) => result is Success
                  ? l.servicesCustomerSaved
                  : l.servicesCustomerStorageError,
            );
          }
        }

        List<AppMenuAction> actions(ServiceCustomerListItem item) => [
          AppMenuAction(
            label: (l) => l.viewDetails,
            onPressed: () => context.go(ServicesRoutes.customer(item.id)),
          ),
          if (canEdit)
            AppMenuAction(
              label: (l) => l.servicesCustomerEdit,
              onPressed: () => context.go(ServicesRoutes.customerEdit(item.id)),
            ),
          if (canDeactivate)
            AppMenuAction(
              label: (l) => item.status == ConfigurationStatus.active
                  ? l.servicesCustomerDeactivate
                  : l.servicesCustomerActivate,
              onPressed: () =>
                  toggle(item, item.status != ConfigurationStatus.active),
            ),
        ];

        Widget body;
        if (state.loading && page == null) {
          body = const AppConfigurationSkeleton();
        } else if (state.failure != null && page == null) {
          body = AppErrorState(
            message: l.servicesCustomerStorageError,
            onRetry: cubit.start,
          );
        } else if (items.isEmpty) {
          final empty = (page?.total ?? 0) == 0;
          body = AppEmptyState(
            title: empty
                ? l.servicesCustomerEmpty
                : l.servicesCustomerNoResults,
            message: empty
                ? l.servicesCustomerEmptyMessage
                : l.servicesCustomerNoResults,
            actionLabel: empty && canCreate ? l.servicesCustomerAdd : null,
            onAction: () => context.go(ServicesRoutes.customersNew),
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
                    title: item.name,
                    subtitle: item.customerCode,
                    tertiary: item.mobile,
                    leading: AppAvatar(name: item.name),
                    status: serviceStatus(item.status),
                    statusLabel: serviceStatusLabel(item.status, l),
                    onTap: () => context.go(ServicesRoutes.customer(item.id)),
                    metrics: [
                      (
                        label: l.servicesCustomerSites,
                        value: numbers.integer(item.siteCount),
                      ),
                      (
                        label: l.servicesCustomerLastUpdated,
                        value: dates.date(item.updatedAt),
                      ),
                    ],
                    trailing: canEdit || canDeactivate
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
              DataColumn(label: Text(l.servicesCustomerName)),
              DataColumn(label: Text(l.servicesCustomerMobile)),
              DataColumn(label: Text(l.servicesCustomerSites)),
              DataColumn(label: Text(l.servicesCustomerLastUpdated)),
              DataColumn(label: Text(l.status)),
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
                      context.go(ServicesRoutes.customer(item.id)),
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          AppAvatar(name: item.name, radius: 16),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: AppTypography.of(context).label,
                              ),
                              Text(
                                item.customerCode,
                                textDirection: TextDirection.ltr,
                                style: AppTypography.of(context).caption,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(item.mobile, textDirection: TextDirection.ltr),
                    ),
                    DataCell(Text(numbers.integer(item.siteCount))),
                    DataCell(Text(dates.date(item.updatedAt))),
                    DataCell(
                      AppStatusBadge(
                        label: serviceStatusLabel(item.status, l),
                        status: serviceStatus(item.status),
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
          maxWidth: AppDimensions.wideContent,
          header: AppPageHeader(
            title: l.servicesCustomersTitle,
            subtitle: page == null
                ? null
                : l.servicesCustomerCount(
                    numbers.integer(page.filtered),
                    numbers.integer(page.total),
                  ),
            actions: [
              if (canCreate)
                AppPrimaryButton(
                  label: l.servicesCustomerAdd,
                  icon: Icons.add,
                  onPressed: () => context.go(ServicesRoutes.customersNew),
                ),
            ],
          ),
          filters: AppToolbar(
            search: AppSearchField(
              hint: l.servicesCustomerSearch,
              onChanged: cubit.search,
            ),
            filters: [
              AppFilterBar(
                children: [
                  AppFilterChip(
                    label: l.servicesCustomerAllStatuses,
                    selected: state.status == null,
                    onSelected: (_) => cubit.setStatus(null),
                  ),
                  AppFilterChip(
                    label: l.active,
                    selected: state.status == ConfigurationStatus.active,
                    onSelected: (_) =>
                        cubit.setStatus(ConfigurationStatus.active),
                  ),
                  AppFilterChip(
                    label: l.inactive,
                    selected: state.status == ConfigurationStatus.inactive,
                    onSelected: (_) =>
                        cubit.setStatus(ConfigurationStatus.inactive),
                  ),
                ],
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.loading && page != null)
                const LinearProgressIndicator(minHeight: 2),
              if (state.failure != null && page != null)
                AppAlert(
                  message: l.servicesCustomerStorageError,
                  status: AppStatus.warning,
                ),
              body,
            ],
          ),
        );
      },
    );
  }
}

AppStatus customerStatus(ServiceCustomerListItem item) =>
    item.status == ConfigurationStatus.active
    ? AppStatus.success
    : AppStatus.neutral;

String customerStatusLabel(ServiceCustomerListItem item, AppLocalizations l) =>
    item.status == ConfigurationStatus.active ? l.active : l.inactive;
