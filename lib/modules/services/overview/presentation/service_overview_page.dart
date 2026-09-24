import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/overview/presentation/bloc/service_overview_cubit.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
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
        final summary = state.enquirySummary;
        final assignmentSummary = state.assignmentSummary;
        final metrics = <Widget>[
          if (summary != null) ...[
            AppMetricCard(
              label: l.servicesOverviewEnquiriesOpen,
              value: numbers.integer(summary.openCount),
              icon: Icons.support_agent_outlined,
              onTap: can(AppPermission.serviceEnquiryView)
                  ? () => context.go(ServicesRoutes.enquiries)
                  : null,
            ),
            AppMetricCard(
              label: l.servicesOverviewEnquiriesToday,
              value: numbers.integer(summary.todayCount),
              icon: Icons.today_outlined,
            ),
            AppMetricCard(
              label: l.servicesOverviewEnquiriesHigh,
              value: numbers.integer(summary.highUrgentOpenCount),
              icon: Icons.priority_high_outlined,
              status: summary.highUrgentOpenCount > 0
                  ? AppStatus.warning
                  : AppStatus.neutral,
            ),
          ],
          if (assignmentSummary != null) ...[
            AppMetricCard(
              label: l.servicesOverviewAssignmentsScheduled,
              value: numbers.integer(assignmentSummary.activeCount),
              icon: Icons.assignment_ind_outlined,
              onTap: () => context.go(ServicesRoutes.assignments),
            ),
            AppMetricCard(
              label: l.servicesOverviewAssignmentsToday,
              value: numbers.integer(assignmentSummary.todayCount),
              icon: Icons.today_outlined,
            ),
            AppMetricCard(
              label: l.servicesOverviewAssignmentsUpcoming,
              value: numbers.integer(assignmentSummary.upcomingCount),
              icon: Icons.event_outlined,
            ),
          ],
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
          header: AppPageHeader(
            title: l.servicesPermModuleServices,
            subtitle: l.servicesOverviewSubtitle,
            actions: [
              if (can(AppPermission.serviceEnquiryCreate))
                AppPrimaryButton(
                  label: l.servicesOverviewNewEnquiry,
                  icon: Icons.add,
                  onPressed: () => context.go(ServicesRoutes.enquiriesNew),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (metrics.isNotEmpty) ...[
                AppDashboardGrid(children: metrics),
                const SizedBox(height: AppSpacing.xxl),
              ],
              if (summary != null) ...[
                AppSettingsSection(
                  title: l.servicesOverviewRecentEnquiries,
                  children: [
                    if (state.recentEnquiries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(l.servicesOverviewNoEnquiries),
                      )
                    else
                      for (final item in state.recentEnquiries)
                        AppSettingsRow(
                          title: item.enquiryNumber,
                          description: [
                            item.customerName,
                            if (item.siteName.isNotEmpty) item.siteName,
                          ].join(' · '),
                          icon: Icons.support_agent_outlined,
                          trailing: serviceEnquiryStatusLabel(item.status, l),
                          onPressed: () =>
                              context.go(ServicesRoutes.enquiry(item.id)),
                        ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
              if (assignmentSummary != null) ...[
                AppSettingsSection(
                  title: l.servicesOverviewRecentAssignments,
                  children: [
                    if (state.upcomingAssignments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(l.servicesOverviewNoAssignments),
                      )
                    else
                      for (final item in state.upcomingAssignments)
                        AppSettingsRow(
                          title: item.assignmentNumber,
                          description: [
                            item.customerName,
                            if (item.assignedSummary.isNotEmpty)
                              item.assignedSummary,
                          ].join(' · '),
                          icon: Icons.assignment_ind_outlined,
                          trailing: serviceJobAssignmentStatusLabel(
                            item.status,
                            l,
                          ),
                          onPressed: () =>
                              context.go(ServicesRoutes.assignment(item.id)),
                        ),
                  ],
                ),
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
