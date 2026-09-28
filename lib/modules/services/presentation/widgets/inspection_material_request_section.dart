import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request_repository.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

/// Inspection detail integration: lists the Material Requests recorded against
/// this Inspection and offers "Create material request" when the Inspection is
/// completed and the viewer can create.
class InspectionMaterialRequestSection extends StatelessWidget {
  const InspectionMaterialRequestSection({
    super.key,
    required this.repository,
    required this.inspectionId,
    required this.inspectionCompleted,
    required this.waitingRequirementCount,
  });
  final ServiceMaterialRequestRepository repository;
  final String inspectionId;
  final bool inspectionCompleted;
  final int waitingRequirementCount;

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    bool can(AppPermission p) => permissions?.contains(p) ?? false;
    final canCreate = can(AppPermission.serviceMaterialRequestCreate);
    final canView =
        can(AppPermission.serviceMaterialRequestViewAssigned) ||
        can(AppPermission.serviceMaterialRequestViewTeam) ||
        can(AppPermission.serviceMaterialRequestViewAll);
    if (!canCreate && !canView) return const SizedBox.shrink();
    final account = context.read<AuthBloc>().state.context;
    if (account == null) return const SizedBox.shrink();

    return StreamBuilder<Result<List<ServiceMaterialRequestRef>>>(
      stream: repository.watchRequestsForInspection(account, inspectionId),
      builder: (context, snapshot) {
        final l = context.l10n;
        final refs = switch (snapshot.data) {
          Success<List<ServiceMaterialRequestRef>>(:final value) => value,
          _ => const <ServiceMaterialRequestRef>[],
        };
        final children = <Widget>[
          if (refs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(l.servicesMaterialRequestNoneForInspection),
            )
          else
            for (final ref in refs)
              AppSettingsRow(
                title: ref.requestNumber,
                description: [
                  serviceMaterialRequestStatusLabel(ref.status, l),
                  '${l.servicesMaterialRequestTotalQuantity}: ${formatMaterialQuantity(ref.totalQuantity)}',
                ].join(' · '),
                icon: Icons.request_quote_outlined,
                onPressed: () =>
                    context.go(ServicesRoutes.materialRequest(ref.id)),
              ),
          if (canCreate && inspectionCompleted)
            AppSettingsRow(
              title: l.servicesMaterialRequestCreateFromInspection,
              description: waitingRequirementCount > 0
                  ? l.servicesMaterialRequestEmptyMessage
                  : l.servicesMaterialRequestNoneForInspection,
              icon: Icons.add,
              onPressed: () => context.go(
                '${ServicesRoutes.materialRequestsNew}?inspectionId=${Uri.encodeQueryComponent(inspectionId)}',
              ),
            ),
        ];
        return AppSettingsSection(
          title: l.servicesMaterialRequestSectionForInspection,
          children: children,
        );
      },
    );
  }
}
