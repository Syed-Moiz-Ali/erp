import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/inspections/presentation/bloc/service_inspection_blocs.dart';
import 'package:modular_erp/modules/services/inspections/presentation/widgets/inspection_editors.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_reference_field.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/shared/transactions/application/attachment_picker.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class ServiceInspectionFormPage extends StatelessWidget {
  const ServiceInspectionFormPage({super.key, this.inspectionId});
  final String? inspectionId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServiceInspectionFormCubit, ServiceInspectionFormState>(
      listenWhen: (p, c) => c.saved && !p.saved,
      listener: (context, state) {
        if (state.savedId == null) return;
        AppFeedback.showMessage(
          context,
          message: (l) => inspectionId == null
              ? l.servicesInspectionCreated
              : l.servicesInspectionUpdated,
        );
        context.go(ServicesRoutes.inspection(state.savedId!));
      },
      builder: (context, state) {
        final l = context.l10n;
        final cubit = context.read<ServiceInspectionFormCubit>();
        final d = state.draft;
        final source = state.sourceContext;
        String? workTypeError(String id) {
          if (state.failure != 'servicesInspectionWorkTypeRequired') {
            return null;
          }
          final item = d.checklistItems.where((x) => x.id == id).firstOrNull;
          return item != null && item.workType.trim().isEmpty
              ? l.servicesInspectionWorkTypeRequired
              : null;
        }

        final notFound = state.failure == 'servicesInspectionNotFound';
        return AppFormPage(
          title: inspectionId == null
              ? l.servicesInspectionFormNew
              : l.servicesInspectionFormEdit,
          actions: [
            AppTextButton(
              label: l.cancel,
              onPressed: state.saving
                  ? null
                  : () => context.go(ServicesRoutes.inspections),
            ),
            AppPrimaryButton(
              label: inspectionId == null ? l.servicesInspectionCreate : l.save,
              loading: state.saving,
              onPressed: state.saving ? null : cubit.save,
            ),
          ],
          error: state.failure == null || notFound
              ? null
              : (serviceInspectionFailureMessage(state.failure, l) ??
                    l.servicesInspectionStorageError),
          loading: state.loading,
          child: notFound
              ? AppErrorState(
                  message: l.servicesInspectionNotFound,
                  onRetry: () => context.go(ServicesRoutes.inspections),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppFormSection(
                      title: l.servicesInspectionSectionContext,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ServiceReferenceField<
                            ServiceAssignableJobAssignmentRef
                          >(
                            label: l.servicesInspectionJobAssignment,
                            valueLabel: source?.assignmentNumber,
                            valueSubtitle: source == null
                                ? null
                                : [
                                    source.customerName,
                                    source.enquiryNumber,
                                  ].where((s) => s.isNotEmpty).join(' · '),
                            hint: l.servicesInspectionSelectAssignment,
                            errorText:
                                state.failure ==
                                    'servicesInspectionAssignmentRequired'
                                ? l.servicesInspectionAssignmentRequired
                                : null,
                            enabled: !state.saving && inspectionId == null,
                            onPick: () => _pickAssignment(context, cubit),
                            onClear: source == null
                                ? null
                                : cubit.clearAssignment,
                          ),
                          if (source != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            AppFormGrid(
                              children: [
                                AppGeneratedValueField(
                                  label: l.servicesInspectionNo,
                                  value: state.savedId,
                                  generatedFallback:
                                      l.servicesJobAssignmentGenerated,
                                  identifier: true,
                                ),
                                AppGeneratedValueField(
                                  label: l.servicesInspectionDate,
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
                        title: l.servicesInspectionSectionCustomerService,
                        fields: [
                          AppDetailField(
                            label: l.servicesEnquiryCustomerName,
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
                              label: l.servicesEnquiryTenant,
                              value: source.partySnapshot.tenantName!,
                            ),
                          if (source.partySnapshot.buildingName != null)
                            AppDetailField(
                              label: l.servicesEnquiryBuilding,
                              value: source.partySnapshot.buildingName!,
                            ),
                          if (source.partySnapshot.unitNumber != null)
                            AppDetailField(
                              label: l.servicesEnquiryUnit,
                              value: source.partySnapshot.unitNumber!,
                            ),
                          AppDetailField(
                            label: l.servicesEnquiryComplaintType,
                            value: source.complaintTypeName,
                          ),
                          AppDetailField(
                            label: l.servicesEnquiryPriority,
                            value: source.priorityName,
                          ),
                          AppDetailField(
                            label: l.servicesJobAssignmentMaterialReceived,
                            value: serviceMaterialReceivedLabel(
                              source.materialReceived,
                              l,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    AppFormSection(
                      title: l.servicesInspectionSectionVisit,
                      child: AppFormGrid(
                        children: [
                          AppDateField(
                            label: l.servicesInspectionVisitDate,
                            value: d.visitDate,
                            errorText:
                                state.failure ==
                                    'servicesInspectionVisitDateRequired'
                                ? l.servicesInspectionVisitDateRequired
                                : null,
                            onChanged: cubit.setVisitDate,
                          ),
                          AppTimeField(
                            label: l.servicesInspectionVisitTime,
                            value: d.visitMinutes == null
                                ? null
                                : TimeOfDay(
                                    hour: d.visitMinutes! ~/ 60,
                                    minute: d.visitMinutes! % 60,
                                  ),
                            errorText:
                                state.failure ==
                                    'servicesInspectionVisitTimeRequired'
                                ? l.servicesInspectionVisitTimeRequired
                                : null,
                            onChanged: (t) =>
                                cubit.setVisitMinutes(t.hour * 60 + t.minute),
                          ),
                          ServiceReferenceField<ServiceInspectionTechnicianRef>(
                            label: l.servicesInspectionTechnician,
                            valueLabel: source?.eligibleTechnicians
                                .where((t) => t.id == d.technicianEmployeeId)
                                .firstOrNull
                                ?.name,
                            hint: l.servicesInspectionTechnicianOptional,
                            enabled: !state.saving && source != null,
                            onPick: () => _pickTechnician(context, cubit),
                            onClear: d.technicianEmployeeId == null
                                ? null
                                : cubit.clearTechnician,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppFormSection(
                      title: l.servicesInspectionSectionAssessment,
                      child: AppFormGrid(
                        children: [
                          AppSelectField<String>(
                            label: l.servicesInspectionRootCause,
                            value: d.rootCauseId,
                            enabled: !state.saving,
                            onChanged: (v) => v == null || v.isEmpty
                                ? cubit.clearRootCause()
                                : cubit.selectRootCause(v),
                            options: [
                              AppSelectOption(
                                '',
                                l.servicesInspectionTechnicianOptional,
                              ),
                              for (final m in state.rootCauses)
                                AppSelectOption(m.id, m.name),
                            ],
                          ),
                          AppSelectField<String>(
                            label: l.servicesInspectionChargeResponsibility,
                            value: d.chargeResponsibilityId,
                            enabled: !state.saving,
                            onChanged: (v) => v == null || v.isEmpty
                                ? cubit.clearChargeResponsibility()
                                : cubit.selectChargeResponsibility(v),
                            options: [
                              AppSelectOption(
                                '',
                                l.servicesInspectionTechnicianOptional,
                              ),
                              for (final m in state.chargeResponsibilities)
                                AppSelectOption(m.id, m.name),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppFormSection(
                      title: l.servicesInspectionSectionChecklist,
                      action: AppSecondaryButton(
                        label: l.servicesInspectionAddChecklist,
                        icon: Icons.add,
                        size: AppButtonSize.small,
                        onPressed: state.saving ? null : cubit.addChecklistItem,
                      ),
                      child: InspectionChecklistEditor(
                        items: d.checklistItems,
                        enabled: !state.saving,
                        workTypeErrorFor: workTypeError,
                        onAdd: cubit.addChecklistItem,
                        onRemove: cubit.removeChecklistItem,
                        onWorkTypeChanged: cubit.updateWorkType,
                        onDescriptionChanged: cubit.updateDescriptionForWork,
                        onAddPhotos: (id) => _pickPhotos(context, cubit, id),
                        onRemoveAttachment: cubit.removeChecklistAttachment,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppFormSection(
                      title: l.servicesInspectionSectionPoints,
                      action: AppSecondaryButton(
                        label: l.servicesInspectionAddPoint,
                        icon: Icons.add,
                        size: AppButtonSize.small,
                        onPressed: state.saving ? null : cubit.addPoint,
                      ),
                      child: InspectionPointsEditor(
                        points: d.inspectedPoints,
                        enabled: !state.saving,
                        onAdd: cubit.addPoint,
                        onRemove: cubit.removePoint,
                        onChanged: cubit.updatePointDescription,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppFormSection(
                      title: l.servicesInspectionSectionMaterials,
                      action: AppSecondaryButton(
                        label: l.servicesInspectionAddMaterial,
                        icon: Icons.add,
                        size: AppButtonSize.small,
                        onPressed: state.saving ? null : cubit.addMaterial,
                      ),
                      child: InspectionMaterialsEditor(
                        materials: d.materialRequirements,
                        enabled: !state.saving,
                        onAdd: cubit.addMaterial,
                        onRemove: cubit.removeMaterial,
                        onCodeChanged: cubit.updateMaterialCode,
                        onDescriptionChanged: cubit.updateMaterialDescription,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _pickAssignment(
    BuildContext context,
    ServiceInspectionFormCubit cubit,
  ) async {
    final l = context.l10n;
    final result =
        await showServiceReferencePicker<ServiceAssignableJobAssignmentRef>(
          context,
          title: l.servicesInspectionSelectAssignment,
          search: cubit.searchAssignments,
          labelOf: (a) => a.assignmentNumber,
          idOf: (a) => a.id,
          subtitleOf: (a) => [
            a.customerName,
            a.enquiryNumber,
          ].where((s) => s.isNotEmpty).join(' · '),
          selectedId: cubit.state.draft.sourceJobAssignmentId,
          searchHint: l.servicesInspectionSearch,
          emptyText: l.servicesInspectionAssignmentInvalid,
        );
    if (cubit.isClosed) return;
    if (result is ServiceReferenceSelected<ServiceAssignableJobAssignmentRef>) {
      await cubit.selectAssignment(result.value);
    }
  }

  Future<void> _pickTechnician(
    BuildContext context,
    ServiceInspectionFormCubit cubit,
  ) async {
    final source = cubit.state.sourceContext;
    if (source == null) return;
    final l = context.l10n;
    final result =
        await showServiceReferencePicker<ServiceInspectionTechnicianRef>(
          context,
          title: l.servicesInspectionTechnician,
          search: (q) async => source.eligibleTechnicians
              .where(
                (t) =>
                    t.name.toLowerCase().contains(q.toLowerCase()) ||
                    t.employeeCode.toLowerCase().contains(q.toLowerCase()),
              )
              .toList(),
          labelOf: (t) => t.name,
          idOf: (t) => t.id,
          subtitleOf: (t) => t.employeeCode,
          selectedId: cubit.state.draft.technicianEmployeeId,
          emptyText: l.servicesInspectionTechnicianInvalid,
        );
    if (cubit.isClosed) return;
    if (result is ServiceReferenceSelected<ServiceInspectionTechnicianRef>) {
      cubit.selectTechnician(result.value.id);
    }
  }

  Future<void> _pickPhotos(
    BuildContext context,
    ServiceInspectionFormCubit cubit,
    String itemId,
  ) async {
    final account = context.read<AuthBloc>().state.context;
    if (account == null) return;
    final item = cubit.state.draft.checklistItems
        .where((c) => c.id == itemId)
        .firstOrNull;
    if (item == null) return;
    List<PickedAttachment> picked;
    try {
      picked = await attachmentPicker.pickImages();
    } catch (_) {
      if (context.mounted) {
        AppFeedback.showMessage(
          context,
          message: (l) => l.servicesInspectionStorageError,
        );
      }
      return;
    }
    if (picked.isEmpty || !context.mounted) return;
    var count = item.attachments.length;
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
          ownerType: 'serviceInspectionChecklistItem',
          ownerId: itemId,
          category: AttachmentCategory.beforeWorkPhoto,
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
    if (!cubit.isClosed) cubit.addChecklistAttachments(itemId, refs);
  }
}
