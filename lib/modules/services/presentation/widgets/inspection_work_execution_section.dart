import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution_repository.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

/// Inspection detail integration: shows the active Work Execution for this
/// Inspection and offers "Create work execution" when the Inspection is
/// completed, no active execution exists and the viewer can create.
class InspectionWorkExecutionSection extends StatelessWidget {
  const InspectionWorkExecutionSection({
    super.key,
    required this.repository,
    required this.inspectionId,
    required this.inspectionCompleted,
  });
  final ServiceWorkExecutionRepository repository;
  final String inspectionId;
  final bool inspectionCompleted;

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    bool can(AppPermission p) => permissions?.contains(p) ?? false;
    final canCreate = can(AppPermission.serviceWorkExecutionCreate);
    final canView =
        can(AppPermission.serviceWorkExecutionViewAssigned) ||
        can(AppPermission.serviceWorkExecutionViewTeam) ||
        can(AppPermission.serviceWorkExecutionViewAll);
    if (!canCreate && !canView) return const SizedBox.shrink();
    final account = context.read<AuthBloc>().state.context;
    if (account == null) return const SizedBox.shrink();

    return StreamBuilder<Result<ServiceWorkExecutionRef?>>(
      stream: repository.watchExecutionForInspection(account, inspectionId),
      builder: (context, snapshot) {
        final l = context.l10n;
        final ref = switch (snapshot.data) {
          Success<ServiceWorkExecutionRef?>(:final value) => value,
          _ => null,
        };
        final children = <Widget>[];
        if (ref != null) {
          children.add(
            AppSettingsRow(
              title: ref.executionNumber,
              description: serviceWorkExecutionStatusLabel(ref.status, l),
              icon: Icons.engineering_outlined,
              onPressed: () {
                if (canView) {
                  context.go(ServicesRoutes.workExecution(ref.id));
                }
              },
            ),
          );
        } else if (inspectionCompleted && canCreate) {
          children.add(
            AppSettingsRow(
              title: l.servicesInspectionCreateWorkExecution,
              icon: Icons.add,
              onPressed: () => context.go(
                '${ServicesRoutes.workExecutionsNew}?inspectionId=${Uri.encodeQueryComponent(inspectionId)}',
              ),
            ),
          );
        } else {
          children.add(
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(l.servicesInspectionNoWorkExecution),
            ),
          );
        }
        return AppSettingsSection(
          title: l.servicesInspectionWorkExecutionSection,
          children: children,
        );
      },
    );
  }
}
