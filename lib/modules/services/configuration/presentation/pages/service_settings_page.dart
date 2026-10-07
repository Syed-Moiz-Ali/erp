import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

/// Services settings landing: compact grouped navigation over the actual
/// implemented service masters. Items are filtered by the View permission the
/// current user holds — a Root-Cause-View-only user sees the hub and only the
/// Root Causes item. Create/Edit remains Manage-gated on the destination pages.
class ServiceSettingsPage extends StatelessWidget {
  const ServiceSettingsPage({super.key});

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
    return AppPage(
      header: AppPageHeader(
        title: l.servicesSettingsTitle,
        subtitle: l.servicesSettingsSubtitle,
      ),
      child: AppSettingsHub(
        emptyMessage: l.noRecords,
        groups: [
          AppSettingsGroup(
            title: l.servicesGroupGeneral,
            items: [
              if (can(AppPermission.serviceTypeView))
                AppSettingsItem(
                  title: l.servicesServiceTypesTitle,
                  description: l.servicesPermServiceTypesViewDesc,
                  icon: Icons.category_outlined,
                  onPressed: () => context.go(ServicesRoutes.serviceTypes),
                ),
              if (can(AppPermission.complaintTypeView))
                AppSettingsItem(
                  title: l.servicesComplaintTypesTitle,
                  description: l.servicesPermComplaintTypesViewDesc,
                  icon: Icons.report_problem_outlined,
                  onPressed: () =>
                      context.go(ServicesRoutes.complaintTypes),
                ),
              if (can(AppPermission.servicePriorityView))
                AppSettingsItem(
                  title: l.servicesPrioritiesTitle,
                  description: l.servicesPermPrioritiesViewDesc,
                  icon: Icons.sort_outlined,
                  onPressed: () => context.go(ServicesRoutes.priorities),
                ),
              if (can(AppPermission.serviceTicketTypeView))
                AppSettingsItem(
                  title: l.servicesTicketTypesTitle,
                  description: l.servicesPermTicketTypesViewDesc,
                  icon: Icons.confirmation_number_outlined,
                  onPressed: () => context.go(ServicesRoutes.ticketTypes),
                ),
            ],
          ),
          AppSettingsGroup(
            title: l.servicesGroupInspection,
            items: [
              if (can(AppPermission.serviceRootCauseView))
                AppSettingsItem(
                  title: l.servicesRootCausesTitle,
                  description: l.servicesPermRootCausesViewDesc,
                  icon: Icons.troubleshoot_outlined,
                  onPressed: () => context.go(ServicesRoutes.rootCauses),
                ),
              if (can(AppPermission.serviceChargeResponsibilityView))
                AppSettingsItem(
                  title: l.servicesChargeResponsibilitiesTitle,
                  description:
                      l.servicesPermChargeResponsibilitiesViewDesc,
                  icon: Icons.gavel_outlined,
                  onPressed: () =>
                      context.go(ServicesRoutes.chargeResponsibilities),
                ),
            ],
          ),
          AppSettingsGroup(
            title: l.servicesGroupMaterials,
            items: [
              if (can(AppPermission.serviceMaterialRequestPurposeView))
                AppSettingsItem(
                  title: l.servicesMaterialRequestPurposesTitle,
                  description:
                      l.servicesPermMaterialRequestPurposesViewDesc,
                  icon: Icons.request_quote_outlined,
                  onPressed: () =>
                      context.go(ServicesRoutes.materialRequestPurposes),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
