import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_reference_field.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team_repository.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';
import 'package:modular_erp/modules/services/work_executions/presentation/bloc/service_work_execution_blocs.dart';
import 'package:modular_erp/modules/services/work_executions/presentation/widgets/work_execution_editors.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/shared/transactions/application/attachment_picker.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';

class ServiceWorkExecutionFormPage extends StatefulWidget {
  const ServiceWorkExecutionFormPage({
    super.key,
    this.executionId,
    this.teamRepository,
    this.workforce,
  });
  final String? executionId;
  final ServiceTeamRepository? teamRepository;
  final WorkforceDirectory? workforce;

  @override
  State<ServiceWorkExecutionFormPage> createState() =>
      _ServiceWorkExecutionFormPageState();
}

class _ServiceWorkExecutionFormPageState
    extends State<ServiceWorkExecutionFormPage> {
  Future<List<AppSelectOption<String>>>? _teams;
  Future<List<AppSelectOption<String>>>? _employees;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOptions());
  }

  void _loadOptions() {
    if (!mounted) return;
    final account = context.read<AuthBloc>().state.context;
    if (account == null) return;
    final teams = widget.teamRepository;
    final workforce = widget.workforce;
    final noSelection = context.l10n.noSelection;
    setState(() {
      _teams = teams == null
          ? Future.value(const [])
          : teams.searchReferences(account, limit: 100).then((result) {
              if (result is Success<List<ServiceTeamRef>>) {
                return [
                  AppSelectOption('', noSelection),
                  for (final ref in result.value)
                    AppSelectOption(ref.id, ref.displayName),
                ];
              }
              return [AppSelectOption('', noSelection)];
            });
      _employees = workforce == null
          ? Future.value(const [])
          : workforce
                .searchAssignable(limit: 200)
                .then(
                  (refs) => [
                    AppSelectOption('', noSelection),
                    for (final ref in refs.where((r) => r.isActive))
                      AppSelectOption(ref.id, ref.name),
                  ],
                );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocConsumer<
      ServiceWorkExecutionFormCubit,
      ServiceWorkExecutionFormState
    >(
      listenWhen: (p, c) => c.saved && !p.saved,
      listener: (context, state) {
        if (state.savedId == null) return;
        AppFeedback.showMessage(
          context,
          message: (l) => widget.executionId == null
              ? l.servicesWorkExecutionCreated
              : l.servicesWorkExecutionUpdated,
        );
        context.go(ServicesRoutes.workExecution(state.savedId!));
      },
      builder: (context, state) {
        final cubit = context.read<ServiceWorkExecutionFormCubit>();
        final d = state.draft;
        final source = state.sourceContext;
        final editable = true;

        Future<void> reset() async {
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: (l) => l.servicesWorkExecutionResetConfirmTitle,
            message: (l) => l.servicesWorkExecutionResetConfirmMessage,
            confirmLabel: (l) => l.servicesWorkExecutionResetForm,
          );
          if (!confirmed) return;
          cubit.resetForm();
        }

        final notFound = state.failure == 'servicesWorkExecutionNotFound';
        return AppFormPage(
          title: widget.executionId == null
              ? l.servicesWorkExecutionFormNew
              : l.servicesWorkExecutionFormEdit,
          actions: [
            AppTextButton(
              label: l.cancel,
              onPressed: state.saving
                  ? null
                  : () => context.go(ServicesRoutes.workExecutions),
            ),
            if (widget.executionId == null)
              AppTextButton(
                label: l.servicesWorkExecutionResetForm,
                onPressed: state.saving ? null : reset,
              ),
            AppPrimaryButton(
              label: widget.executionId == null
                  ? l.servicesWorkExecutionCreate
                  : l.servicesWorkExecutionSaveChanges,
              loading: state.saving,
              onPressed: state.saving ? null : cubit.save,
            ),
          ],
          error: state.failure == null || notFound
              ? null
              : (serviceWorkExecutionFailureMessage(state.failure, l) ??
                    l.servicesWorkExecutionStorageError),
          loading: state.loading,
          child: notFound
              ? AppErrorState(
                  message: l.servicesWorkExecutionNotFound,
                  onRetry: () => context.go(ServicesRoutes.workExecutions),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppFormSection(
                      title: l.servicesWorkExecutionSectionContext,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ServiceReferenceField<
                            ServiceWorkEligibleInspectionRef
                          >(
                            label: l.servicesWorkExecutionSourceInspection,
                            valueLabel: source?.inspectionNumber,
                            valueSubtitle: source == null
                                ? null
                                : [
                                    source.customerName,
                                    source.enquiryNumber,
                                  ].where((s) => s.isNotEmpty).join(' · '),
                            hint: l.servicesWorkExecutionSelectInspection,
                            errorText:
                                state.failure ==
                                    'servicesWorkExecutionInspectionRequired'
                                ? l.servicesWorkExecutionInspectionRequired
                                : null,
                            enabled:
                                !state.saving && widget.executionId == null,
                            onPick: () => _pickInspection(context, cubit),
                            onClear: source == null
                                ? null
                                : cubit.clearInspection,
                          ),
                          if (source != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            AppFormGrid(
                              children: [
                                AppGeneratedValueField(
                                  label: l.servicesWorkExecutionNo,
                                  value: state.savedId,
                                  generatedFallback:
                                      l.servicesJobAssignmentGenerated,
                                  identifier: true,
                                ),
                                AppGeneratedValueField(
                                  label: l.servicesWorkExecutionDate,
                                  generatedFallback:
                                      l.servicesJobAssignmentGenerated,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (source != null) ...[
                      const SizedBox(height: AppSpacing.xl),
                      AppReadOnlyContextSection(
                        title: l.servicesWorkExecutionSectionReferences,
                        fields: [
                          AppDetailField(
                            label: l.servicesWorkExecutionInspection,
                            value: source.inspectionNumber,
                            identifier: true,
                          ),
                          AppDetailField(
                            label: l.servicesWorkExecutionJobAssignment,
                            value: source.assignmentNumber,
                            identifier: true,
                          ),
                          AppDetailField(
                            label: l.servicesWorkExecutionEnquiry,
                            value: source.enquiryNumber,
                            identifier: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppReadOnlyContextSection(
                        title: l.servicesWorkExecutionSectionCustomer,
                        fields: [
                          AppDetailField(
                            label: l.servicesWorkExecutionCustomer,
                            value: source.customerName,
                          ),
                          if (source.customerMobile != null)
                            AppDetailField(
                              label: l.servicesEnquiryCustomerMobile,
                              value: source.customerMobile!,
                              identifier: true,
                            ),
                          if (source.partySnapshot.tenantName != null)
                            AppDetailField(
                              label: l.servicesWorkExecutionTenant,
                              value: source.partySnapshot.tenantName!,
                            ),
                          if (source.partySnapshot.buildingName != null)
                            AppDetailField(
                              label: l.servicesWorkExecutionBuilding,
                              value: source.partySnapshot.buildingName!,
                            ),
                          if (source.partySnapshot.unitNumber != null)
                            AppDetailField(
                              label: l.servicesWorkExecutionUnit,
                              value: source.partySnapshot.unitNumber!,
                            ),
                          AppDetailField(
                            label: l.servicesWorkExecutionComplaint,
                            value: source.complaintTypeName,
                          ),
                          AppDetailField(
                            label: l.servicesWorkExecutionPriority,
                            value: source.priorityName,
                          ),
                          AppDetailField(
                            label: l.servicesWorkExecutionMaterialReceived,
                            value: serviceMaterialReceivedLabel(
                              source.materialReceived,
                              l,
                            ),
                          ),
                          AppDetailField(
                            label: l.servicesWorkExecutionRootCause,
                            value: source.rootCauseName ?? '',
                          ),
                          AppDetailField(
                            label: l.servicesWorkExecutionChargeResponsibility,
                            value: source.chargeResponsibilityName ?? '',
                          ),
                          AppDetailField(
                            label: l.servicesWorkExecutionTechnician,
                            value: source.technicianName ?? '',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppReadOnlyContextSection(
                        title: l.servicesWorkExecutionSectionInspection,
                        fields: [
                          AppDetailField(
                            label: l.servicesWorkExecutionChecklist,
                            value: source.checklistItems
                                .map((c) => c.workType)
                                .join(', '),
                          ),
                          AppDetailField(
                            label: l.servicesWorkExecutionInspectedPoints,
                            value: source.inspectedPoints
                                .map((p) => p.description)
                                .join(', '),
                          ),
                          AppDetailField(
                            label: l.servicesWorkExecutionMaterialRequirements,
                            value: source.materialRequirements
                                .map((m) => m.code)
                                .join(', '),
                          ),
                          AppDetailField(
                            label:
                                l.servicesWorkExecutionLinkedMaterialRequests,
                            value: source.linkedMaterialRequests
                                .map(
                                  (r) =>
                                      '${r.requestNumber} (${serviceWorkMaterialRequestStatusLabel(r.status, l)}, ${l.servicesWorkExecutionMaterialRequestItems('${r.itemCount}')})',
                                )
                                .join(', '),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    AppFormSection(
                      title: l.servicesWorkExecutionSectionOrderReferences,
                      child: AppFormGrid(
                        children: [
                          AppTextField(
                            key: const ValueKey('we-job-order'),
                            label: l.servicesWorkExecutionJobOrderReference,
                            initialValue: d.jobOrderReference,
                            enabled: !state.saving,
                            onChanged: cubit.setJobOrderReference,
                          ),
                          AppTextField(
                            key: const ValueKey('we-quotation'),
                            label: l.servicesWorkExecutionQuotationReference,
                            initialValue: d.quotationReference,
                            enabled: !state.saving,
                            onChanged: cubit.setQuotationReference,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppFormSection(
                      title: l.servicesWorkExecutionSectionWork,
                      action: AppSecondaryButton(
                        label: l.servicesWorkExecutionAddLine,
                        icon: Icons.add,
                        size: AppButtonSize.small,
                        onPressed: state.saving ? null : cubit.addLine,
                      ),
                      child: FutureBuilder<List<AppSelectOption<String>>>(
                        future: _teams,
                        builder: (context, teamSnapshot) =>
                            FutureBuilder<List<AppSelectOption<String>>>(
                              future: _employees,
                              builder: (context, employeeSnapshot) =>
                                  WorkExecutionLinesEditor(
                                    lines: d.workLines,
                                    enabled: editable && !state.saving,
                                    onAdd: cubit.addLine,
                                    onRemove: cubit.removeLine,
                                    onWorkChanged: cubit.updateWork,
                                    onDescriptionChanged:
                                        cubit.updateDescription,
                                    onTeamChanged: (id, value) => value.isEmpty
                                        ? cubit.clearLineTeam(id)
                                        : cubit.selectLineTeam(id, value),
                                    onEmployeeChanged: (id, value) =>
                                        value.isEmpty
                                        ? cubit.clearLineEmployee(id)
                                        : cubit.selectLineEmployee(id, value),
                                    teamOptions: teamSnapshot.data ?? const [],
                                    employeeOptions:
                                        employeeSnapshot.data ?? const [],
                                    workErrorFor: (id) =>
                                        state.failure ==
                                            'servicesWorkExecutionWorkRequired'
                                        ? l.servicesWorkExecutionWorkRequired
                                        : null,
                                  ),
                            ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppFormSection(
                      title: l.servicesWorkExecutionSectionMaterials,
                      action: AppSecondaryButton(
                        label: l.servicesWorkExecutionAddMaterial,
                        icon: Icons.add,
                        size: AppButtonSize.small,
                        onPressed: state.saving ? null : cubit.addMaterial,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if ((source?.materialRequestLines ?? []).isNotEmpty)
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: AppTextButton(
                                label: l
                                    .servicesWorkExecutionAddFromMaterialRequest,
                                onPressed: () => _pickMaterialRequestLine(
                                  context,
                                  cubit,
                                  source!.materialRequestLines,
                                ),
                              ),
                            ),
                          WorkExecutionMaterialsEditor(
                            materials: d.materialsUsed,
                            enabled: editable && !state.saving,
                            onAdd: cubit.addMaterial,
                            onRemove: cubit.removeMaterial,
                            onCodeChanged: cubit.updateMaterialCode,
                            onDescriptionChanged:
                                cubit.updateMaterialDescription,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppFormSection(
                      title: l.servicesWorkExecutionSectionPhotos,
                      action: AppSecondaryButton(
                        label: l.servicesWorkExecutionAddPhoto,
                        icon: Icons.add,
                        size: AppButtonSize.small,
                        onPressed: state.saving ? null : cubit.addPhotoEntry,
                      ),
                      child: WorkExecutionPhotosEditor(
                        entries: d.afterWorkPhotoEntries,
                        enabled: editable && !state.saving,
                        onAdd: cubit.addPhotoEntry,
                        onRemove: cubit.removePhotoEntry,
                        onDescriptionChanged: cubit.updatePhotoDescription,
                        onAddPhotos: (id) => _pickPhotos(context, cubit, id),
                        onRemoveAttachment: cubit.removePhotoAttachment,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _pickInspection(
    BuildContext context,
    ServiceWorkExecutionFormCubit cubit,
  ) async {
    final l = context.l10n;
    final result =
        await showServiceReferencePicker<ServiceWorkEligibleInspectionRef>(
          context,
          title: l.servicesWorkExecutionSelectInspection,
          search: cubit.searchInspections,
          labelOf: (i) => i.inspectionNumber,
          idOf: (i) => i.id,
          subtitleOf: (i) => [
            i.customerName,
            i.assignmentNumber,
            i.enquiryNumber,
          ].where((s) => s.isNotEmpty).join(' · '),
          selectedId: cubit.state.draft.sourceInspectionId,
          searchHint: l.servicesWorkExecutionSearch,
          emptyText: l.servicesWorkExecutionInspectionNotEligible,
        );
    if (cubit.isClosed) return;
    if (result is ServiceReferenceSelected<ServiceWorkEligibleInspectionRef>) {
      await cubit.selectInspection(result.value);
    }
  }

  Future<void> _pickMaterialRequestLine(
    BuildContext context,
    ServiceWorkExecutionFormCubit cubit,
    List<ServiceWorkMaterialRequestLineRef> lines,
  ) async {
    final l = context.l10n;
    final picked =
        await showServiceReferencePicker<ServiceWorkMaterialRequestLineRef>(
          context,
          title: l.servicesWorkExecutionAddFromMaterialRequest,
          search: (query) async => lines
              .where(
                (line) =>
                    line.code.toLowerCase().contains(query.toLowerCase()) ||
                    line.description.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    line.requestNumber.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList(),
          labelOf: (line) => '${line.code} · ${line.description}',
          idOf: (line) => line.id,
          subtitleOf: (line) => line.requestNumber,
          searchHint: l.servicesWorkExecutionSearch,
          emptyText: l.servicesWorkExecutionNoLinkedRequests,
        );
    if (cubit.isClosed) return;
    if (picked is ServiceReferenceSelected<ServiceWorkMaterialRequestLineRef>) {
      cubit.addMaterialFromRequest(picked.value);
    }
  }

  Future<void> _pickPhotos(
    BuildContext context,
    ServiceWorkExecutionFormCubit cubit,
    String entryId,
  ) async {
    final account = context.read<AuthBloc>().state.context;
    if (account == null) return;
    final entry = cubit.state.draft.afterWorkPhotoEntries
        .where((p) => p.id == entryId)
        .firstOrNull;
    if (entry == null) return;
    List<PickedAttachment> picked;
    try {
      picked = await attachmentPicker.pickImages();
    } catch (_) {
      if (context.mounted) {
        AppFeedback.showMessage(
          context,
          message: (l) => l.servicesWorkExecutionStorageError,
        );
      }
      return;
    }
    if (picked.isEmpty || !context.mounted) return;
    var count = entry.attachments.length;
    final refs = <AttachmentRef>[];
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
          ownerId: entryId,
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
    if (!cubit.isClosed) cubit.addPhotoAttachments(entryId, refs);
  }
}
