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
import 'package:modular_erp/modules/services/teams/domain/service_team.dart';
import 'package:modular_erp/modules/services/teams/presentation/bloc/service_team_blocs.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class ServiceTeamListPage extends StatelessWidget {
  const ServiceTeamListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    final canManage =
        permissions?.contains(AppPermission.serviceTeamManage) ?? false;
    return BlocBuilder<ServiceTeamListCubit, ServiceTeamListState>(
      builder: (context, state) {
        final l = context.l10n;
        final cubit = context.read<ServiceTeamListCubit>();
        final numbers = AppNumberFormatter(Localizations.localeOf(context));
        final items = state.page?.items ?? const <ServiceTeamListItem>[];
        final page = state.page;
        final compact = AppBreakpoints.of(context) == AppSize.compact;

        Future<void> toggle(ServiceTeamListItem item, bool active) async {
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: (l) =>
                active ? l.servicesTeamActivate : l.servicesTeamDeactivate,
            message: (l) => item.name,
            confirmLabel: (l) => active ? l.confirm : l.servicesTeamDeactivate,
          );
          if (!confirmed || !context.mounted) return;
          final result = await cubit.setActive(item.id, active);
          if (context.mounted) {
            AppFeedback.showMessage(
              context,
              message: (l) => result is Success
                  ? l.servicesTeamSaved
                  : l.servicesTeamStorageError,
            );
          }
        }

        List<AppMenuAction> actions(ServiceTeamListItem item) => [
          AppMenuAction(
            label: (l) => l.viewDetails,
            onPressed: () => context.go(ServicesRoutes.team(item.id)),
          ),
          if (canManage)
            AppMenuAction(
              label: (l) => l.servicesTeamEdit,
              onPressed: () => context.go(ServicesRoutes.teamEdit(item.id)),
            ),
          if (canManage)
            AppMenuAction(
              label: (l) => item.status == ConfigurationStatus.active
                  ? l.servicesTeamDeactivate
                  : l.servicesTeamActivate,
              onPressed: () =>
                  toggle(item, item.status != ConfigurationStatus.active),
            ),
        ];

        Widget body;
        if (state.loading && page == null) {
          body = const AppConfigurationSkeleton();
        } else if (state.failure != null && page == null) {
          body = AppErrorState(
            message: l.servicesTeamStorageError,
            onRetry: cubit.start,
          );
        } else if (items.isEmpty) {
          final empty = (page?.total ?? 0) == 0;
          body = AppEmptyState(
            title: empty ? l.servicesTeamEmpty : l.servicesTeamNoResults,
            message: empty
                ? l.servicesTeamEmptyMessage
                : l.servicesTeamNoResults,
            actionLabel: empty && canManage ? l.servicesTeamAdd : null,
            onAction: () => context.go(ServicesRoutes.teamsNew),
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
                    subtitle: item.teamCode,
                    tertiary: item.leadName ?? l.servicesTeamLeadNone,
                    leading: AppAvatar(name: item.name),
                    status: serviceStatus(item.status),
                    statusLabel: serviceStatusLabel(item.status, l),
                    onTap: () => context.go(ServicesRoutes.team(item.id)),
                    metrics: [
                      (
                        label: l.servicesTeamMembers,
                        value: numbers.integer(item.memberCount),
                      ),
                    ],
                    trailing: canManage
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
              DataColumn(label: Text(l.servicesTeamName)),
              DataColumn(label: Text(l.servicesTeamLead)),
              DataColumn(label: Text(l.servicesTeamMembers)),
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
                      context.go(ServicesRoutes.team(item.id)),
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
                                item.teamCode,
                                textDirection: TextDirection.ltr,
                                style: AppTypography.of(context).caption,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(item.leadName ?? l.servicesTeamLeadNone)),
                    DataCell(Text(numbers.integer(item.memberCount))),
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
            title: l.servicesTeamsTitle,
            subtitle: page == null
                ? null
                : l.servicesTeamCount(
                    numbers.integer(page.filtered),
                    numbers.integer(page.total),
                  ),
            actions: [
              if (canManage)
                AppPrimaryButton(
                  label: l.servicesTeamAdd,
                  icon: Icons.add,
                  onPressed: () => context.go(ServicesRoutes.teamsNew),
                ),
            ],
          ),
          filters: AppToolbar(
            search: AppSearchField(
              hint: l.servicesTeamSearch,
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
                  message: l.servicesTeamStorageError,
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
