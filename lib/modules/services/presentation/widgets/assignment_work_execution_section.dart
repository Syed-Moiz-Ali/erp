import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution_repository.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

/// Job Assignment detail integration: shows the downstream Work Execution
/// (reached through the Inspection lineage) when accessible.
class AssignmentWorkExecutionSection extends StatelessWidget {
  const AssignmentWorkExecutionSection({
    super.key,
    required this.repository,
    required this.jobAssignmentId,
  });
  final ServiceWorkExecutionRepository repository;
  final String jobAssignmentId;

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    bool can(AppPermission p) => permissions?.contains(p) ?? false;
    final canView =
        can(AppPermission.serviceWorkExecutionViewAssigned) ||
        can(AppPermission.serviceWorkExecutionViewTeam) ||
        can(AppPermission.serviceWorkExecutionViewAll);
    if (!canView) return const SizedBox.shrink();
    final account = context.read<AuthBloc>().state.context;
    if (account == null) return const SizedBox.shrink();

    return StreamBuilder<Result<ServiceWorkExecutionRef?>>(
      stream: repository.watchExecutionForAssignment(account, jobAssignmentId),
      builder: (context, snapshot) {
        final l = context.l10n;
        final ref = switch (snapshot.data) {
          Success<ServiceWorkExecutionRef?>(:final value) => value,
          _ => null,
        };
        final dates = AppDateFormatter(Localizations.localeOf(context));
        return AppSettingsSection(
          title: l.servicesAssignmentWorkExecutionSection,
          children: [
            if (ref == null)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(l.servicesInspectionNoWorkExecution),
              )
            else
              AppSettingsRow(
                title: ref.executionNumber,
                description: [
                  serviceWorkExecutionStatusLabel(ref.status, l),
                  dates.date(ref.executionDate),
                ].join(' · '),
                icon: Icons.engineering_outlined,
                onPressed: () =>
                    context.go(ServicesRoutes.workExecution(ref.id)),
              ),
          ],
        );
      },
    );
  }
}
