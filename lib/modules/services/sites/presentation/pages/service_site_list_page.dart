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
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/sites/domain/service_site.dart';
import 'package:modular_erp/modules/services/sites/presentation/bloc/service_site_blocs.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class ServiceSiteListPage extends StatelessWidget {
  const ServiceSiteListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    final canCreate =
        permissions?.contains(AppPermission.serviceSiteCreate) ?? false;
    final canEdit =
        permissions?.contains(AppPermission.serviceSiteEdit) ?? false;
    final canDeactivate =
        permissions?.contains(AppPermission.serviceSiteDeactivate) ?? false;
    return BlocBuilder<ServiceSiteListCubit, ServiceSiteListState>(
      builder: (context, state) {
        final l = context.l10n;
        final cubit = context.read<ServiceSiteListCubit>();
        final numbers = AppNumberFormatter(Localizations.localeOf(context));
        final items = state.page?.items ?? const <ServiceSiteListItem>[];
        final page = state.page;
        final compact = AppBreakpoints.of(context) == AppSize.compact;

        String buildingUnit(ServiceSiteListItem item) => [
          item.buildingName,
          item.unitNumber,
        ].whereType<String>().where((s) => s.isNotEmpty).join(' / ');

        Future<void> toggle(ServiceSiteListItem item, bool active) async {
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: (l) =>
                active ? l.servicesSiteActivate : l.servicesSiteDeactivate,
            message: (l) => item.siteName,
            confirmLabel: (l) => active ? l.confirm : l.servicesSiteDeactivate,
          );
          if (!confirmed || !context.mounted) return;
          final result = await cubit.setActive(item.id, active);
          if (context.mounted) {
            AppFeedback.showMessage(
              context,
              message: (l) => result is Success
                  ? l.servicesSiteSaved
                  : l.servicesSiteStorageError,
            );
          }
        }

        List<AppMenuAction> actions(ServiceSiteListItem item) => [
          AppMenuAction(
            label: (l) => l.viewDetails,
            onPressed: () => context.go(ServicesRoutes.site(item.id)),
          ),
          if (canEdit)
            AppMenuAction(
              label: (l) => l.servicesSiteEdit,
              onPressed: () => context.go(ServicesRoutes.siteEdit(item.id)),
            ),
          if (canDeactivate)
            AppMenuAction(
              label: (l) => item.status == ConfigurationStatus.active
                  ? l.servicesSiteDeactivate
                  : l.servicesSiteActivate,
              onPressed: () =>
                  toggle(item, item.status != ConfigurationStatus.active),
            ),
        ];

        Widget body;
        if (state.loading && page == null) {
          body = const AppConfigurationSkeleton();
        } else if (state.failure != null && page == null) {
          body = AppErrorState(
            message: l.servicesSiteStorageError,
            onRetry: cubit.start,
          );
        } else if (items.isEmpty) {
          final empty = (page?.total ?? 0) == 0;
          body = AppEmptyState(
            title: empty ? l.servicesSiteEmpty : l.servicesSiteNoResults,
            message: empty
                ? l.servicesSiteEmptyMessage
                : l.servicesSiteNoResults,
            actionLabel: empty && canCreate ? l.servicesSiteAdd : null,
            onAction: () => context.go(ServicesRoutes.sitesNew),
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
                    title: item.siteName,
                    subtitle: item.customerName,
                    tertiary: [
                      item.siteCode,
                      item.city,
                    ].where((s) => s.isNotEmpty).join(' · '),
                    leading: AppAvatar(name: item.siteName),
                    status: serviceStatus(item.status),
                    statusLabel: serviceStatusLabel(item.status, l),
                    onTap: () => context.go(ServicesRoutes.site(item.id)),
                    metrics: [
                      if (buildingUnit(item).isNotEmpty)
                        (
                          label: l.servicesSiteBuildingUnit,
                          value: buildingUnit(item),
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
              DataColumn(label: Text(l.servicesSiteName)),
              DataColumn(label: Text(l.servicesSiteCustomer)),
              DataColumn(label: Text(l.servicesSiteBuildingUnit)),
              DataColumn(label: Text(l.servicesSiteCity)),
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
                      context.go(ServicesRoutes.site(item.id)),
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          AppAvatar(name: item.siteName, radius: 16),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.siteName,
                                style: AppTypography.of(context).label,
                              ),
                              Text(
                                item.siteCode,
                                textDirection: TextDirection.ltr,
                                style: AppTypography.of(context).caption,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(item.customerName)),
                    DataCell(Text(buildingUnit(item))),
                    DataCell(Text(item.city)),
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
            title: l.servicesSitesTitle,
            subtitle: page == null
                ? null
                : l.servicesSiteCount(
                    numbers.integer(page.filtered),
                    numbers.integer(page.total),
                  ),
            actions: [
              if (canCreate)
                AppPrimaryButton(
                  label: l.servicesSiteAdd,
                  icon: Icons.add,
                  onPressed: () => context.go(ServicesRoutes.sitesNew),
                ),
            ],
          ),
          filters: AppToolbar(
            search: AppSearchField(
              hint: l.servicesSiteSearch,
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
                  message: l.servicesSiteStorageError,
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
