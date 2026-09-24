import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

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
      child: AppSettingsSection(
        title: l.servicesSetupTitle,
        children: [
          if (can(AppPermission.serviceTypeView))
            AppSettingsRow(
              title: l.servicesServiceTypesTitle,
              description: l.servicesPermServiceTypesViewDesc,
              icon: Icons.category_outlined,
              onPressed: () => context.go(ServicesRoutes.serviceTypes),
            ),
          if (can(AppPermission.complaintTypeView))
            AppSettingsRow(
              title: l.servicesComplaintTypesTitle,
              description: l.servicesPermComplaintTypesViewDesc,
              icon: Icons.report_problem_outlined,
              onPressed: () => context.go(ServicesRoutes.complaintTypes),
            ),
          if (can(AppPermission.servicePriorityView))
            AppSettingsRow(
              title: l.servicesPrioritiesTitle,
              description: l.servicesPermPrioritiesViewDesc,
              icon: Icons.sort_outlined,
              onPressed: () => context.go(ServicesRoutes.priorities),
            ),
          if (can(AppPermission.serviceTicketTypeView))
            AppSettingsRow(
              title: l.servicesTicketTypesTitle,
              description: l.servicesPermTicketTypesViewDesc,
              icon: Icons.confirmation_number_outlined,
              onPressed: () => context.go(ServicesRoutes.ticketTypes),
            ),
        ],
      ),
    );
  }
}
