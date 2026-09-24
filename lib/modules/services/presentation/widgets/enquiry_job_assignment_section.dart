import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment_repository.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

/// Enquiry detail integration: shows the active Job Assignment and the
/// Create/View action, driven entirely by permissions and Enquiry status.
class EnquiryJobAssignmentSection extends StatelessWidget {
  const EnquiryJobAssignmentSection({
    super.key,
    required this.repository,
    required this.enquiryId,
    required this.enquiryStatus,
  });
  final ServiceJobAssignmentRepository repository;
  final String enquiryId;
  final ServiceEnquiryStatus enquiryStatus;

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    bool can(AppPermission p) => permissions?.contains(p) ?? false;
    final canCreate = can(AppPermission.serviceJobAssignmentCreate);
    final canView =
        can(AppPermission.serviceJobAssignmentViewAssigned) ||
        can(AppPermission.serviceJobAssignmentViewTeam) ||
        can(AppPermission.serviceJobAssignmentViewAll);
    if (!canCreate && !canView) return const SizedBox.shrink();
    final account = context.read<AuthBloc>().state.context;
    if (account == null) return const SizedBox.shrink();

    return StreamBuilder<Result<ServiceJobAssignmentRef?>>(
      stream: repository.watchAssignmentForEnquiry(account, enquiryId),
      builder: (context, snapshot) {
        final l = context.l10n;
        final ref = switch (snapshot.data) {
          Success<ServiceJobAssignmentRef?>(:final value) => value,
          _ => null,
        };
        final dates = AppDateFormatter(Localizations.localeOf(context));
        final children = <Widget>[];
        if (ref != null) {
          children.add(
            AppSettingsRow(
              title: ref.assignmentNumber,
              description: [
                ref.customerName,
                if (ref.assignedSummary.isNotEmpty) ref.assignedSummary,
                dates.date(ref.scheduledVisitDate),
              ].where((s) => s.isNotEmpty).join(' · '),
              icon: Icons.assignment_ind_outlined,
              onPressed: () {
                if (canView) {
                  context.go(ServicesRoutes.assignment(ref.id));
                }
              },
            ),
          );
        } else if (enquiryStatus.isOpen && canCreate) {
          children.add(
            AppSettingsRow(
              title: l.servicesEnquiryCreateAssignment,
              icon: Icons.add,
              onPressed: () => context.go(
                '${ServicesRoutes.assignmentsNew}?enquiryId=${Uri.encodeQueryComponent(enquiryId)}',
              ),
            ),
          );
        } else {
          children.add(
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(l.servicesOverviewNoAssignments),
            ),
          );
        }
        return AppSettingsSection(
          title: l.servicesEnquiryAssignmentSection,
          children: children,
        );
      },
    );
  }
}
