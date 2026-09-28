import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_workflow_section.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';
import 'package:modular_erp/modules/services/work_executions/presentation/bloc/service_work_execution_blocs.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow_repository.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/shared/transactions/application/attachment_picker.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';

import '../../../presentation/widgets/service_attachment_strip.dart';

class ServiceWorkExecutionDetailPage extends StatelessWidget {
  const ServiceWorkExecutionDetailPage({
    super.key,
    required this.executionId,
    this.workflow,
  });
  final String executionId;
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
    final canEdit = can(AppPermission.serviceWorkExecutionEdit);
    final canPerform = can(AppPermission.serviceWorkExecutionPerform);
    final canComplete = can(AppPermission.serviceWorkExecutionComplete);
    final canCancel = can(AppPermission.serviceWorkExecutionCancel);
    return BlocBuilder<
      ServiceWorkExecutionDetailCubit,
      ServiceWorkExecutionDetailState
    >(
      builder: (context, state) {
        final l = context.l10n;
        final view = state.view;
        if (state.loading && view == null) {
          return const AppPage(child: AppConfigurationSkeleton());
        }
        if (view == null) {
          return AppPage(
            header: AppPageHeader(title: l.servicesWorkExecutionsTitle),
            child: AppEmptyState(
              title: l.servicesWorkExecutionNotFound,
              message: l.servicesWorkExecutionEmptyMessage,
            ),
          );
        }
        final execution = view.execution;
        final dates = AppDateFormatter(Localizations.localeOf(context));
        final times = AppTimeFormatter(Localizations.localeOf(context));
        final cubit = context.read<ServiceWorkExecutionDetailCubit>();
        final open = execution.isEditable;
        final perform = canPerform && open;

        Future<void> complete() async {
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: (l) => l.servicesWorkExecutionCompleteConfirmTitle,
            message: (l) => l.servicesWorkExecutionCompleteConfirmMessage,
            confirmLabel: (l) => l.servicesWorkExecutionComplete,
          );
          if (!confirmed || !context.mounted) return;
          final result = await cubit.complete();
          if (!context.mounted) return;
          AppFeedback.showMessage(
            context,
            message: (l) => result is Success
                ? l.servicesWorkExecutionCompleted
                : serviceWorkExecutionFailureMessage(
                        (result as Failed<ServiceWorkExecution>).failure.code,
                        l,
                      ) ??
                      l.servicesWorkExecutionStorageError,
          );
        }

        Future<void> cancel() async {
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: (l) => l.servicesWorkExecutionCancelConfirmTitle,
            message: (l) => l.servicesWorkExecutionCancelConfirmMessage,
            confirmLabel: (l) => l.servicesWorkExecutionCancel,
          );
          if (!confirmed || !context.mounted) return;
          final result = await cubit.cancel();
          if (!context.mounted) return;
          AppFeedback.showMessage(
            context,
            message: (l) => result is Success
                ? l.servicesWorkExecutionCancelled
                : l.servicesWorkExecutionStorageError,
          );
        }

        return AppPage(
          header: AppPageHeader(
            title: execution.executionNumber,
            subtitle: view.customerName,
            actions: [
              if (canEdit && open)
                AppSecondaryButton(
                  label: l.servicesWorkExecutionEdit,
                  icon: Icons.edit_outlined,
                  onPressed: () => context.go(
                    ServicesRoutes.workExecutionEdit(execution.id),
                  ),
                ),
              if (canComplete && open)
                AppPrimaryButton(
                  label: l.servicesWorkExecutionComplete,
                  icon: Icons.task_alt_outlined,
                  onPressed: execution.allLinesComplete ? complete : null,
                ),
              if (canCancel && !execution.isCompleted && !execution.isCancelled)
                AppSecondaryButton(
                  label: l.servicesWorkExecutionCancel,
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
                      label: serviceWorkExecutionStatusLabel(
                        execution.status,
                        l,
                      ),
                      status: serviceWorkExecutionStatus(execution.status),
                      isPill: true,
                    ),
                    AppStatusBadge(
                      label: dates.date(execution.executionDate),
                      icon: Icons.event_outlined,
                      status: AppStatus.neutral,
                      isPill: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (workflow != null) ...[
                ServiceWorkflowSection(
                  repository: workflow!,
                  enquiryId: execution.sourceEnquiryId,
                  focus: ServiceWorkflowStage.workExecution,
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
              AppFormSection(
                title: l.servicesWorkExecutionDetailReferences,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.servicesWorkExecutionInspection,
                      value: view.inspectionNumber,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesWorkExecutionJobAssignment,
                      value: view.assignmentNumber,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesWorkExecutionEnquiry,
                      value: view.enquiryNumber,
                      identifier: true,
                    ),
                    if ((execution.jobOrderReference ?? '').isNotEmpty)
                      AppDetailField(
                        label: l.servicesWorkExecutionJobOrderReference,
                        value: execution.jobOrderReference!,
                        identifier: true,
                      ),
                    if ((execution.quotationReference ?? '').isNotEmpty)
                      AppDetailField(
                        label: l.servicesWorkExecutionQuotationReference,
                        value: execution.quotationReference!,
                        identifier: true,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesWorkExecutionDetailContext,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.servicesWorkExecutionCustomer,
                      value: view.customerName,
                    ),
                    if (view.customerMobile != null)
                      AppDetailField(
                        label: l.servicesEnquiryCustomerMobile,
                        value: view.customerMobile!,
                        identifier: true,
                      ),
                    if (view.partySnapshot.tenantName != null)
                      AppDetailField(
                        label: l.servicesWorkExecutionTenant,
                        value: view.partySnapshot.tenantName!,
                      ),
                    if (view.partySnapshot.buildingName != null)
                      AppDetailField(
                        label: l.servicesWorkExecutionBuilding,
                        value: view.partySnapshot.buildingName!,
                      ),
                    if (view.partySnapshot.unitNumber != null)
                      AppDetailField(
                        label: l.servicesWorkExecutionUnit,
                        value: view.partySnapshot.unitNumber!,
                      ),
                    AppDetailField(
                      label: l.servicesWorkExecutionComplaint,
                      value: view.complaintTypeName,
                    ),
                    AppDetailField(
                      label: l.servicesWorkExecutionPriority,
                      value: view.priorityName,
                    ),
                    AppDetailField(
                      label: l.servicesWorkExecutionMaterialReceived,
                      value: serviceMaterialReceivedLabel(
                        view.materialReceived,
                        l,
                      ),
                    ),
                    AppDetailField(
                      label: l.servicesWorkExecutionRootCause,
                      value: view.rootCauseName ?? '',
                    ),
                    AppDetailField(
                      label: l.servicesWorkExecutionChargeResponsibility,
                      value: view.chargeResponsibilityName ?? '',
                    ),
                    AppDetailField(
                      label: l.servicesWorkExecutionTechnician,
                      value: view.technicianName ?? '',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesWorkExecutionDetailWork,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (execution.workLines.isEmpty)
                      Text(l.servicesWorkExecutionNoLines)
                    else
                      for (var i = 0; i < execution.workLines.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppSpacing.lg),
                        _WorkLineCard(
                          index: i,
                          line: execution.workLines[i],
                          times: times,
                          perform: perform,
                          onStart: () => _run(
                            context,
                            () => cubit.startLine(execution.workLines[i].id),
                            l.servicesWorkExecutionWorkStarted,
                          ),
                          onEnd: () => _run(
                            context,
                            () => cubit.endLine(execution.workLines[i].id),
                            l.servicesWorkExecutionWorkEnded,
                          ),
                        ),
                      ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesWorkExecutionDetailMaterials,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (execution.materialsUsed.isEmpty)
                      Text(l.servicesWorkExecutionNoMaterials)
                    else
                      for (var i = 0; i < execution.materialsUsed.length; i++)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            bottom: AppSpacing.md,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined, size: 20),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      execution.materialsUsed[i].code,
                                      style: AppTypography.of(context).label,
                                    ),
                                    Text(
                                      execution.materialsUsed[i].description,
                                      style: AppTypography.of(context).caption,
                                    ),
                                  ],
                                ),
                              ),
                              if (perform)
                                AppIconButton(
                                  icon: Icons.delete_outline,
                                  tooltip:
                                      l.servicesWorkExecutionRemoveMaterial,
                                  onPressed: () => _run(
                                    context,
                                    () => cubit.removeMaterialUsed(
                                      execution.materialsUsed[i].id,
                                    ),
                                    l.servicesWorkExecutionMaterialRemoved,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    if (perform) ...[
                      const SizedBox(height: AppSpacing.md),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: AppSecondaryButton(
                          label: l.servicesWorkExecutionAddMaterial,
                          icon: Icons.add,
                          onPressed: () => _addMaterial(context, cubit),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesWorkExecutionDetailPhotos,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l.servicesWorkExecutionBeforeWorkPhotos,
                      style: AppTypography.of(
                        context,
                      ).caption.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _BeforePhotos(items: view.checklistItems),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l.servicesWorkExecutionAfterWorkPhotos,
                      style: AppTypography.of(
                        context,
                      ).caption.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (execution.afterWorkPhotoEntries.isEmpty)
                      Text(l.servicesWorkExecutionNoPhotos)
                    else
                      for (final entry in execution.afterWorkPhotoEntries)
                        _PhotoEntryCard(
                          entry: entry,
                          perform: perform,
                          onRemove: () => _run(
                            context,
                            () => cubit.removePhotoEntry(entry.id),
                            l.servicesWorkExecutionPhotoRemoved,
                          ),
                        ),
                    if (perform) ...[
                      const SizedBox(height: AppSpacing.md),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: AppSecondaryButton(
                          label: l.servicesWorkExecutionAddPhoto,
                          icon: Icons.add,
                          onPressed: () => _addPhoto(context, cubit),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesWorkExecutionDetailAudit,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.servicesWorkExecutionDate,
                      value: dates.date(execution.executionDate),
                    ),
                    AppDetailField(
                      label: l.servicesWorkExecutionPreparedBy,
                      value: execution.createdByUserId,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesWorkExecutionCreatedAt,
                      value: dates.date(execution.createdAt),
                    ),
                    AppDetailField(
                      label: l.servicesWorkExecutionUpdatedBy,
                      value: execution.updatedByUserId,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesWorkExecutionUpdatedAt,
                      value: dates.date(execution.updatedAt),
                    ),
                    AppDetailField(
                      label: l.servicesWorkExecutionVersion,
                      value: '${execution.version}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppSettingsSection(
                title: l.servicesWorkExecutionDetailActivity,
                children: [
                  if (state.activity.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(l.servicesWorkExecutionNoActivity),
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

  Future<void> _run(
    BuildContext context,
    Future<Result<ServiceWorkExecution>> Function() action,
    String successMessage,
  ) async {
    final result = await action();
    if (!context.mounted) return;
    AppFeedback.showMessage(
      context,
      message: (l) => result is Success
          ? successMessage
          : serviceWorkExecutionFailureMessage(
                  (result as Failed<ServiceWorkExecution>).failure.code,
                  l,
                ) ??
                l.servicesWorkExecutionStorageError,
    );
  }

  Future<void> _addMaterial(
    BuildContext context,
    ServiceWorkExecutionDetailCubit cubit,
  ) async {
    final draft = await showDialog<({String code, String description})>(
      context: context,
      builder: (_) => const _AddMaterialDialog(),
    );
    if (draft == null || !context.mounted) return;
    await _run(
      context,
      () => cubit.addMaterialUsed(
        code: draft.code,
        description: draft.description,
      ),
      context.l10n.servicesWorkExecutionMaterialAdded,
    );
  }

  Future<void> _addPhoto(
    BuildContext context,
    ServiceWorkExecutionDetailCubit cubit,
  ) async {
    final description = await showDialog<String>(
      context: context,
      builder: (_) => const _AddPhotoDialog(),
    );
    if (description == null || !context.mounted) return;
    final account = context.read<AuthBloc>().state.context;
    if (account == null) return;
    List<PickedAttachment> picked;
    try {
      picked = await attachmentPicker.pickImages();
    } catch (_) {
      return;
    }
    final refs = <AttachmentRef>[];
    var count = 0;
    for (final file in picked) {
      final code = AttachmentValidation.validate(
        mimeType: file.mimeType,
        sizeBytes: file.sizeBytes,
        existingCount: count,
      );
      if (code != null) continue;
      count++;
      final now = DateTime.now();
      refs.add(
        AttachmentRef(
          id: const Uuid().v4(),
          companyId: account.company.id,
          ownerType: 'serviceWorkExecutionPhotoEntry',
          ownerId: '',
          category: AttachmentCategory.afterWorkPhoto,
          fileName: file.fileName,
          displayName: file.fileName,
          mimeType: file.mimeType,
          sizeBytes: file.sizeBytes,
          uploadStatus: AttachmentUploadStatus.localOnly,
          syncStatus: 'pending',
          createdByUserId: account.user.id,
          createdAt: now,
          updatedAt: now,
          localPath: file.path,
        ),
      );
    }
    if (!context.mounted) return;
    await _run(
      context,
      () => cubit.addPhotoEntry(description: description, attachments: refs),
      context.l10n.servicesWorkExecutionPhotoAdded,
    );
  }
}

class _WorkLineCard extends StatelessWidget {
  const _WorkLineCard({
    required this.index,
    required this.line,
    required this.times,
    required this.perform,
    required this.onStart,
    required this.onEnd,
  });
  final int index;
  final ServiceWorkExecutionLine line;
  final AppTimeFormatter times;
  final bool perform;
  final VoidCallback onStart;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = line.state;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.servicesWorkExecutionLineTitle('${index + 1}'),
                  style: AppTypography.of(context).label,
                ),
              ),
              AppStatusBadge(
                label: serviceWorkLineStateLabel(state, l),
                status: serviceWorkLineStateStatus(state),
                isPill: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppDetailsGrid(
            fields: [
              AppDetailField(
                label: l.servicesWorkExecutionWork,
                value: line.work,
              ),
              if (line.description.isNotEmpty)
                AppDetailField(
                  label: l.servicesWorkExecutionDescription,
                  value: line.description,
                ),
              AppDetailField(
                label: l.servicesWorkExecutionStartTime,
                value: line.startedAtUtc == null
                    ? ''
                    : times.time(line.startedAtUtc!),
              ),
              AppDetailField(
                label: l.servicesWorkExecutionEndTime,
                value: line.endedAtUtc == null
                    ? ''
                    : times.time(line.endedAtUtc!),
              ),
            ],
          ),
          if (perform && !line.isFinished) ...[
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppSecondaryButton(
                label: line.isStarted
                    ? l.servicesWorkExecutionEndWork
                    : l.servicesWorkExecutionStartWork,
                icon: line.isStarted ? Icons.stop : Icons.play_arrow,
                onPressed: line.isStarted ? onEnd : onStart,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PhotoEntryCard extends StatelessWidget {
  const _PhotoEntryCard({
    required this.entry,
    required this.perform,
    required this.onRemove,
  });
  final ServiceWorkExecutionPhotoEntry entry;
  final bool perform;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.description,
                    style: AppTypography.of(context).label,
                  ),
                ),
                if (perform)
                  AppIconButton(
                    icon: Icons.delete_outline,
                    tooltip: l.servicesWorkExecutionRemovePhoto,
                    onPressed: onRemove,
                  ),
              ],
            ),
            if (entry.attachments.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final a in entry.attachments)
                    AttachmentThumbnail(attachment: a),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BeforePhotos extends StatelessWidget {
  const _BeforePhotos({required this.items});
  final List<ServiceInspectionChecklistItem> items;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final attachments = [for (final item in items) ...item.attachments];
    if (attachments.isEmpty) {
      return Text(l.servicesWorkExecutionNoPhotos);
    }
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final a in attachments) AttachmentThumbnail(attachment: a),
      ],
    );
  }
}

class _AddMaterialDialog extends StatefulWidget {
  const _AddMaterialDialog();

  @override
  State<_AddMaterialDialog> createState() => _AddMaterialDialogState();
}

class _AddMaterialDialogState extends State<_AddMaterialDialog> {
  final _code = TextEditingController();
  final _description = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppDialog(
      title: l.servicesWorkExecutionAddMaterial,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            key: const ValueKey('we-add-material-code'),
            label: l.servicesWorkExecutionCode,
            initialValue: _code.text,
            onChanged: (v) => _code.text = v,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            key: const ValueKey('we-add-material-description'),
            label: l.servicesWorkExecutionDescription,
            initialValue: _description.text,
            onChanged: (v) => _description.text = v,
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            alignment: WrapAlignment.end,
            children: [
              AppTextButton(
                label: l.cancel,
                onPressed: () => Navigator.pop(context),
              ),
              AppPrimaryButton(
                label: l.save,
                onPressed: () {
                  if (_code.text.trim().isEmpty ||
                      _description.text.trim().isEmpty) {
                    return;
                  }
                  Navigator.pop(context, (
                    code: _code.text.trim(),
                    description: _description.text.trim(),
                  ));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddPhotoDialog extends StatefulWidget {
  const _AddPhotoDialog();

  @override
  State<_AddPhotoDialog> createState() => _AddPhotoDialogState();
}

class _AddPhotoDialogState extends State<_AddPhotoDialog> {
  final _description = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppDialog(
      title: l.servicesWorkExecutionAddPhoto,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            key: const ValueKey('we-add-photo-description'),
            label: l.servicesWorkExecutionPhotoDescription,
            initialValue: _description.text,
            onChanged: (v) => _description.text = v,
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            alignment: WrapAlignment.end,
            children: [
              AppTextButton(
                label: l.cancel,
                onPressed: () => Navigator.pop(context),
              ),
              AppPrimaryButton(
                label: l.save,
                onPressed: () {
                  if (_description.text.trim().isEmpty) return;
                  Navigator.pop(context, _description.text.trim());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
