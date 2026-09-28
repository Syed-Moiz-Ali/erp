import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/enquiries/presentation/widgets/enquiry_detail_editor.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/inspections/presentation/bloc/service_inspection_blocs.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request_repository.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/presentation/widgets/inspection_material_request_section.dart';
import 'package:modular_erp/modules/services/presentation/widgets/inspection_work_execution_section.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_workflow_section.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution_repository.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow_repository.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class ServiceInspectionDetailPage extends StatelessWidget {
  const ServiceInspectionDetailPage({
    super.key,
    required this.inspectionId,
    this.materialRequests,
    this.workExecutions,
    this.workflow,
  });
  final String inspectionId;
  final ServiceMaterialRequestRepository? materialRequests;
  final ServiceWorkExecutionRepository? workExecutions;
  final ServiceWorkflowRepository? workflow;

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    bool can(AppPermission p) => permissions?.contains(p) ?? false;
    final canEdit = can(AppPermission.serviceInspectionEdit);
    final canComplete = can(AppPermission.serviceInspectionComplete);
    final canCancel = can(AppPermission.serviceInspectionCancel);
    return BlocBuilder<
      ServiceInspectionDetailCubit,
      ServiceInspectionDetailState
    >(
      builder: (context, state) {
        final l = context.l10n;
        final view = state.view;
        if (state.loading && view == null) {
          return const AppPage(child: AppConfigurationSkeleton());
        }
        if (view == null) {
          return AppPage(
            header: AppPageHeader(title: l.servicesInspectionsTitle),
            child: AppEmptyState(
              title: l.servicesInspectionNotFound,
              message: l.servicesInspectionEmptyMessage,
            ),
          );
        }
        final i = view.inspection;
        final dates = AppDateFormatter(Localizations.localeOf(context));
        final times = AppTimeFormatter(Localizations.localeOf(context));
        String? timeLabel() => i.visitMinutes == null
            ? null
            : times.time(
                DateTime(
                  2000,
                  1,
                  1,
                  i.visitMinutes! ~/ 60,
                  i.visitMinutes! % 60,
                ),
                use24Hour: true,
              );

        Future<void> complete() async {
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: (l) => l.servicesInspectionCompleteConfirmTitle,
            message: (l) => l.servicesInspectionCompleteConfirmMessage,
            confirmLabel: (l) => l.servicesInspectionComplete,
          );
          if (!confirmed || !context.mounted) return;
          final result = await context
              .read<ServiceInspectionDetailCubit>()
              .complete();
          if (!context.mounted) return;
          AppFeedback.showMessage(
            context,
            message: (l) => result is Success
                ? l.servicesInspectionCompleted
                : serviceInspectionFailureMessage(
                        result is Failed<ServiceInspection>
                            ? result.failure.code
                            : null,
                        l,
                      ) ??
                      l.servicesInspectionStorageError,
          );
        }

        Future<void> cancel() async {
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: (l) => l.servicesInspectionCancelConfirmTitle,
            message: (l) => l.servicesInspectionCancelConfirmMessage,
            confirmLabel: (l) => l.servicesInspectionCancel,
          );
          if (!confirmed || !context.mounted) return;
          final result = await context
              .read<ServiceInspectionDetailCubit>()
              .cancel();
          if (!context.mounted) return;
          AppFeedback.showMessage(
            context,
            message: (l) => result is Success
                ? l.servicesInspectionCancelled
                : l.servicesInspectionStorageError,
          );
        }

        return AppPage(
          header: AppPageHeader(
            title: i.inspectionNumber,
            subtitle: view.customerName,
            actions: [
              if (canEdit && i.isPending)
                AppSecondaryButton(
                  label: l.servicesInspectionEdit,
                  icon: Icons.edit_outlined,
                  onPressed: () =>
                      context.go(ServicesRoutes.inspectionEdit(i.id)),
                ),
              if (canComplete && i.isPending)
                AppPrimaryButton(
                  label: l.servicesInspectionComplete,
                  onPressed: complete,
                ),
              if (canCancel && i.isPending)
                AppSecondaryButton(
                  label: l.servicesInspectionCancel,
                  onPressed: cancel,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppStatusBadge(
                      label: serviceInspectionStatusLabel(i.status, l),
                      status: serviceInspectionStatus(i.status),
                      isPill: true,
                    ),
                    AppStatusBadge(
                      label: [
                        dates.date(i.visitDate),
                        if (timeLabel() != null) timeLabel()!,
                      ].join(' · '),
                      icon: Icons.event_outlined,
                      status: AppStatus.neutral,
                      isPill: true,
                    ),
                    if (view.technicianName != null)
                      AppStatusBadge(
                        label: view.technicianName!,
                        icon: Icons.person_outline,
                        status: AppStatus.neutral,
                        isPill: true,
                      ),
                    if (view.priorityName.isNotEmpty)
                      AppStatusBadge(
                        label: view.priorityName,
                        status: servicePriorityStatus(view.priorityRank),
                        isPill: true,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (workflow != null) ...[
                ServiceWorkflowSection(
                  repository: workflow!,
                  enquiryId: i.sourceEnquiryId,
                  focus: ServiceWorkflowStage.inspection,
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
              AppFormSection(
                title: l.servicesInspectionDetailContext,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.servicesInspectionColumnAssignment,
                      value: view.assignmentNumber,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesInspectionColumnEnquiry,
                      value: view.enquiryNumber,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesEnquiryCustomerName,
                      value: view.customerName,
                    ),
                    if (view.customerMobile != null)
                      AppDetailField(
                        label: l.servicesEnquiryCustomerMobile,
                        value: view.customerMobile!,
                        identifier: true,
                      ),
                    AppDetailField(
                      label: l.servicesEnquiryComplaintType,
                      value: view.complaintTypeName,
                    ),
                    AppDetailField(
                      label: l.servicesEnquiryPriority,
                      value: view.priorityName,
                    ),
                    if (view.partySnapshot.tenantName != null)
                      AppDetailField(
                        label: l.servicesEnquiryTenant,
                        value: view.partySnapshot.tenantName!,
                      ),
                    if (view.partySnapshot.buildingName != null)
                      AppDetailField(
                        label: l.servicesEnquiryBuilding,
                        value: view.partySnapshot.buildingName!,
                      ),
                    if (view.partySnapshot.unitNumber != null)
                      AppDetailField(
                        label: l.servicesEnquiryUnit,
                        value: view.partySnapshot.unitNumber!,
                      ),
                    AppDetailField(
                      label: l.servicesJobAssignmentMaterialReceived,
                      value: serviceMaterialReceivedLabel(
                        view.materialReceived,
                        l,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesInspectionDetailAssessment,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.servicesInspectionRootCause,
                      value: view.rootCauseName ?? '',
                    ),
                    AppDetailField(
                      label: l.servicesInspectionChargeResponsibility,
                      value: view.chargeResponsibilityName ?? '',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesInspectionDetailChecklist,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (i.checklistItems.isEmpty)
                      Text(l.servicesInspectionNoChecklist)
                    else
                      for (var k = 0; k < i.checklistItems.length; k++) ...[
                        if (k > 0) const SizedBox(height: AppSpacing.lg),
                        _ChecklistView(index: k + 1, item: i.checklistItems[k]),
                      ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesInspectionDetailPoints,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (i.inspectedPoints.isEmpty)
                      Text(l.servicesInspectionNoPoints)
                    else
                      for (var k = 0; k < i.inspectedPoints.length; k++)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            bottom: AppSpacing.sm,
                          ),
                          child: Text(
                            [
                              (k + 1).toString(),
                              i.inspectedPoints[k].description,
                            ].join('. '),
                            style: AppTypography.of(context).body,
                          ),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesInspectionDetailMaterials,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (i.materialRequirements.isEmpty)
                      Text(l.servicesInspectionNoMaterials)
                    else
                      for (final m in i.materialRequirements)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            bottom: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  [m.code, m.description].join(' · '),
                                  style: AppTypography.of(context).body,
                                ),
                              ),
                              AppStatusBadge(
                                label: serviceInspectionMaterialStatusLabel(
                                  m.status,
                                  l,
                                ),
                                status: AppStatus.warning,
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (materialRequests != null) ...[
                InspectionMaterialRequestSection(
                  repository: materialRequests!,
                  inspectionId: i.id,
                  inspectionCompleted: i.isCompleted,
                  waitingRequirementCount: i.materialRequirements
                      .where((m) => m.status.isWaiting)
                      .length,
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
              if (workExecutions != null) ...[
                InspectionWorkExecutionSection(
                  repository: workExecutions!,
                  inspectionId: i.id,
                  inspectionCompleted: i.isCompleted,
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
              AppFormSection(
                title: l.servicesInspectionDetailAudit,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.servicesInspectionDate,
                      value: dates.date(i.inspectionDate),
                    ),
                    AppDetailField(
                      label: l.servicesInspectionCreatedAt,
                      value: dates.date(i.createdAt),
                    ),
                    AppDetailField(
                      label: l.servicesInspectionUpdatedAt,
                      value: dates.date(i.updatedAt),
                    ),
                    AppDetailField(
                      label: l.servicesInspectionCreatedBy,
                      value: i.createdByUserId,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesInspectionUpdatedBy,
                      value: i.updatedByUserId,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesInspectionVersion,
                      value: '${i.version}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppSettingsSection(
                title: l.servicesInspectionDetailActivity,
                children: [
                  if (state.activity.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(l.servicesInspectionNoActivity),
                    )
                  else
                    for (final event in state.activity.take(20))
                      AppActivityItem(
                        icon: Icons.history,
                        title: serviceActivityLabel(event, l),
                        description: serviceActivityEntityLabel(event, l),
                        timestamp: dates.date(event.occurredAt),
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

class _ChecklistView extends StatelessWidget {
  const _ChecklistView({required this.index, required this.item});
  final int index;
  final ServiceInspectionChecklistItem item;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      variant: AppCardVariant.subtle,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.servicesInspectionChecklistItemTitle('$index'),
                  style: AppTypography.of(context).label,
                ),
              ),
              AppStatusBadge(
                label: serviceInspectionChecklistStatusLabel(item.status, l),
                status: AppStatus.info,
                isPill: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(item.workType, style: AppTypography.of(context).body),
          if (item.descriptionForWork.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: AppSpacing.xs),
              child: Text(
                item.descriptionForWork,
                style: AppTypography.of(context).caption,
              ),
            ),
          if (item.attachments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final a in item.attachments)
                  AttachmentThumbnail(attachment: a),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
