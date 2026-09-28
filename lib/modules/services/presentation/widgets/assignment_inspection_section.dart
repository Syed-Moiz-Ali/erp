import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection_repository.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

/// Job Assignment detail integration: shows the Inspection and the
/// Create/View action, driven by permissions and the assignment state.
class AssignmentInspectionSection extends StatelessWidget {
  const AssignmentInspectionSection({
    super.key,
    required this.repository,
    required this.jobAssignmentId,
    required this.assignmentActive,
  });
  final ServiceInspectionRepository repository;
  final String jobAssignmentId;
  final bool assignmentActive;

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    bool can(AppPermission p) => permissions?.contains(p) ?? false;
    final canCreate = can(AppPermission.serviceInspectionCreate);
    final canView =
        can(AppPermission.serviceInspectionViewAssigned) ||
        can(AppPermission.serviceInspectionViewTeam) ||
        can(AppPermission.serviceInspectionViewAll);
    if (!canCreate && !canView) return const SizedBox.shrink();
    final account = context.read<AuthBloc>().state.context;
    if (account == null) return const SizedBox.shrink();

    return StreamBuilder<Result<ServiceInspectionRef?>>(
      stream: repository.watchInspectionForAssignment(account, jobAssignmentId),
      builder: (context, snapshot) {
        final l = context.l10n;
        final ref = switch (snapshot.data) {
          Success<ServiceInspectionRef?>(:final value) => value,
          _ => null,
        };
        final dates = AppDateFormatter(Localizations.localeOf(context));
        final children = <Widget>[];
        if (ref != null) {
          children.add(
            AppSettingsRow(
              title: ref.inspectionNumber,
              description: [
                serviceInspectionStatusLabel(ref.status, l),
                if (ref.technicianName != null) ref.technicianName!,
                dates.date(ref.visitDate),
              ].where((s) => s.isNotEmpty).join(' · '),
              icon: Icons.fact_check_outlined,
              onPressed: () {
                if (canView) {
                  context.go(ServicesRoutes.inspection(ref.id));
                }
              },
            ),
          );
        } else if (assignmentActive && canCreate) {
          children.add(
            AppSettingsRow(
              title: l.servicesAssignmentCreateInspection,
              icon: Icons.add,
              onPressed: () => context.go(
                '${ServicesRoutes.inspectionsNew}?assignmentId=${Uri.encodeQueryComponent(jobAssignmentId)}',
              ),
            ),
          );
        } else {
          children.add(
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(l.servicesOverviewNoInspections),
            ),
          );
        }
        return AppSettingsSection(
          title: l.servicesAssignmentInspectionSection,
          children: children,
        );
      },
    );
  }
}
