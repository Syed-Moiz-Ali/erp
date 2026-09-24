import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/overview/presentation/bloc/service_overview_cubit.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class ServiceOverviewPage extends StatelessWidget {
  const ServiceOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    bool can(AppPermission p) => permissions?.contains(p) ?? false;
    final numbers = AppNumberFormatter(Localizations.localeOf(context));
    return BlocBuilder<ServiceOverviewCubit, ServiceOverviewState>(
      builder: (context, state) {
        if (state.loading) {
          return const AppPage(child: AppConfigurationSkeleton());
        }
        final metrics = <Widget>[
          if (state.customers != null)
            AppMetricCard(
              label: l.servicesSummaryCustomers,
              value: numbers.integer(state.customers!),
              icon: Icons.business_outlined,
            ),
          if (state.activeSites != null)
            AppMetricCard(
              label: l.servicesSummarySites,
              value: numbers.integer(state.activeSites!),
              icon: Icons.location_on_outlined,
            ),
          if (state.teams != null)
            AppMetricCard(
              label: l.servicesSummaryTeams,
              value: numbers.integer(state.teams!),
              icon: Icons.groups_outlined,
            ),
        ];
        return AppPage(
          maxWidth: AppDimensions.wideContent,
          header: AppPageHeader(
            title: l.servicesPermModuleServices,
            subtitle: l.servicesOverviewSubtitle,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (metrics.isNotEmpty) ...[
                AppDashboardGrid(children: metrics),
                const SizedBox(height: AppSpacing.xxl),
              ],
              AppSettingsSection(
                title: l.servicesDirectoryTitle,
                children: [
                  if (can(AppPermission.serviceCustomerView))
                    AppSettingsRow(
                      title: l.servicesNavCustomers,
                      description: l.servicesPermCustomersViewDesc,
                      icon: Icons.business_outlined,
                      onPressed: () => context.go(ServicesRoutes.customers),
                    ),
                  if (can(AppPermission.serviceSiteView))
                    AppSettingsRow(
                      title: l.servicesNavSites,
                      description: l.servicesPermSitesViewDesc,
                      icon: Icons.location_on_outlined,
                      onPressed: () => context.go(ServicesRoutes.sites),
                    ),
                  if (can(AppPermission.serviceTeamView))
                    AppSettingsRow(
                      title: l.servicesNavTeams,
                      description: l.servicesPermTeamsViewDesc,
                      icon: Icons.groups_outlined,
                      onPressed: () => context.go(ServicesRoutes.teams),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (can(AppPermission.serviceTypeView) ||
                  can(AppPermission.servicePriorityView))
                AppSettingsSection(
                  title: l.servicesSetupTitle,
                  children: [
                    if (state.serviceTypes != null)
                      AppSettingsRow(
                        title: l.servicesSetupServiceTypes,
                        icon: Icons.category_outlined,
                        trailing: state.serviceTypes! > 0
                            ? l.servicesSetupReady
                            : l.servicesSetupMissing,
                        onPressed: () =>
                            context.go(ServicesRoutes.serviceTypes),
                      ),
                    if (state.priorities != null)
                      AppSettingsRow(
                        title: l.servicesSetupPriorities,
                        icon: Icons.sort_outlined,
                        trailing: state.priorities! > 0
                            ? l.servicesSetupReady
                            : l.servicesSetupMissing,
                        onPressed: () => context.go(ServicesRoutes.priorities),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
