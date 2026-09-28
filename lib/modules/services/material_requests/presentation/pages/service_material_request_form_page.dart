import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request.dart';
import 'package:modular_erp/modules/services/material_requests/presentation/bloc/service_material_request_blocs.dart';
import 'package:modular_erp/modules/services/material_requests/presentation/widgets/material_request_editors.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_reference_field.dart';
import 'package:modular_erp/modules/services/services_localization.dart';

class ServiceMaterialRequestFormPage extends StatelessWidget {
  const ServiceMaterialRequestFormPage({super.key, this.requestId});
  final String? requestId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      ServiceMaterialRequestFormCubit,
      ServiceMaterialRequestFormState
    >(
      listenWhen: (p, c) => c.saved && !p.saved,
      listener: (context, state) {
        if (state.savedId == null) return;
        AppFeedback.showMessage(
          context,
          message: (l) => requestId == null
              ? l.servicesMaterialRequestCreated
              : l.servicesMaterialRequestUpdated,
        );
        context.go(ServicesRoutes.materialRequest(state.savedId!));
      },
      builder: (context, state) {
        final l = context.l10n;
        final cubit = context.read<ServiceMaterialRequestFormCubit>();
        final d = state.draft;
        final source = state.sourceContext;
        String? quantityError(String id) {
          if (state.failure != 'servicesMaterialRequestQuantityRequired') {
            return null;
          }
          final line = d.lines.where((x) => x.id == id).firstOrNull;
          return line != null &&
                  parseMaterialRequestQuantity(line.quantity) == null
              ? l.servicesMaterialRequestQuantityRequired
              : null;
        }

        Future<void> reset() async {
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: (l) => l.servicesMaterialRequestResetConfirmTitle,
            message: (l) => l.servicesMaterialRequestResetConfirmMessage,
            confirmLabel: (l) => l.servicesMaterialRequestResetForm,
          );
          if (!confirmed) return;
          cubit.resetForm();
        }

        return AppPage(
          header: AppPageHeader(
            title: requestId == null
                ? l.servicesMaterialRequestFormNew
                : l.servicesMaterialRequestFormEdit,
            actions: [
              AppTextButton(
                label: l.cancel,
                onPressed: state.saving
                    ? null
                    : () => context.go(ServicesRoutes.materialRequests),
              ),
              if (requestId == null)
                AppTextButton(
                  label: l.servicesMaterialRequestResetForm,
                  onPressed: state.saving ? null : reset,
                ),
              AppPrimaryButton(
                label: requestId == null
                    ? l.servicesMaterialRequestCreate
                    : l.servicesMaterialRequestSaveChanges,
                loading: state.saving,
                onPressed: cubit.save,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.failure != null) ...[
                AppAlert(
                  message:
                      serviceMaterialRequestFailureMessage(state.failure, l) ??
                      l.servicesMaterialRequestStorageError,
                  status: AppStatus.danger,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              AppFormSection(
                title: l.servicesMaterialRequestSectionRequest,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ServiceReferenceField<ServiceEligibleInspectionRef>(
                      label: l.servicesMaterialRequestSourceInspection,
                      valueLabel: source?.inspectionNumber,
                      valueSubtitle: source == null
                          ? null
                          : [
                              source.customerName,
                              source.enquiryNumber,
                            ].where((s) => s.isNotEmpty).join(' · '),
                      hint: l.servicesMaterialRequestSelectInspection,
                      errorText:
                          state.failure ==
                              'servicesMaterialRequestInspectionRequired'
                          ? l.servicesMaterialRequestInspectionRequired
                          : null,
                      enabled: !state.saving && requestId == null,
                      onPick: () => _pickInspection(context, cubit),
                      onClear: source == null ? null : cubit.clearInspection,
                    ),
                    if (source != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      AppFormGrid(
                        children: [
                          AppDetailField(
                            label: l.servicesMaterialRequestNo,
                            value:
                                state.savedId ??
                                l.servicesJobAssignmentGenerated,
                            identifier: true,
                          ),
                          AppDetailField(
                            label: l.servicesMaterialRequestDate,
                            value: l.servicesJobAssignmentGenerated,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (source != null) ...[
                const SizedBox(height: AppSpacing.xl),
                AppFormSection(
                  title: l.servicesMaterialRequestSectionContext,
                  child: AppDetailsGrid(
                    fields: [
                      AppDetailField(
                        label: l.servicesMaterialRequestInspection,
                        value: source.inspectionNumber,
                        identifier: true,
                      ),
                      AppDetailField(
                        label: l.servicesMaterialRequestJobAssignment,
                        value: source.assignmentNumber,
                        identifier: true,
                      ),
                      AppDetailField(
                        label: l.servicesMaterialRequestEnquiry,
                        value: source.enquiryNumber,
                        identifier: true,
                      ),
                      AppDetailField(
                        label: l.servicesMaterialRequestCustomer,
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
                          label: l.servicesMaterialRequestTenant,
                          value: source.partySnapshot.tenantName!,
                        ),
                      if (source.partySnapshot.buildingName != null)
                        AppDetailField(
                          label: l.servicesMaterialRequestBuilding,
                          value: source.partySnapshot.buildingName!,
                        ),
                      if (source.partySnapshot.unitNumber != null)
                        AppDetailField(
                          label: l.servicesMaterialRequestUnit,
                          value: source.partySnapshot.unitNumber!,
                        ),
                      AppDetailField(
                        label: l.servicesMaterialRequestMaterialReceived,
                        value: serviceMaterialReceivedLabel(
                          source.materialReceived,
                          l,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppFormSection(
                title: l.servicesMaterialRequestSectionInformation,
                child: AppFormGrid(
                  children: [
                    AppTextField(
                      key: const ValueKey('mr-job-order'),
                      label: l.servicesMaterialRequestJobOrderReference,
                      initialValue: d.jobOrderReference,
                      enabled: !state.saving,
                      onChanged: cubit.setJobOrderReference,
                    ),
                    AppSelectField<String>(
                      label: l.servicesMaterialRequestPurpose,
                      value: d.purposeId ?? '',
                      enabled: !state.saving,
                      onChanged: (v) => v == null || v.isEmpty
                          ? cubit.clearPurpose()
                          : cubit.selectPurpose(v),
                      options: [
                        AppSelectOption('', l.noSelection),
                        for (final m in state.purposes)
                          AppSelectOption(m.id, m.name),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppFormSection(
                title: l.servicesMaterialRequestSectionMaterials,
                child: MaterialRequestLinesEditor(
                  lines: d.lines,
                  enabled: !state.saving,
                  quantityErrorFor: quantityError,
                  onAdd: cubit.addLine,
                  onRemove: cubit.removeLine,
                  onCodeChanged: cubit.updateCode,
                  onDescriptionChanged: cubit.updateDescription,
                  onBatchChanged: cubit.updateBatchNumber,
                  onQuantityChanged: cubit.updateQuantity,
                  onRemarkChanged: cubit.updateRemark,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppFormSection(
                title: l.servicesMaterialRequestSectionAcknowledgement,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      key: const ValueKey('mr-acknowledge'),
                      label: l.servicesMaterialRequestAcknowledge,
                      initialValue: d.acknowledgement,
                      enabled: !state.saving,
                      onChanged: cubit.setAcknowledgement,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      key: const ValueKey('mr-received-by'),
                      label: l.servicesMaterialRequestReceivedBy,
                      initialValue: d.receivedBy,
                      enabled: !state.saving,
                      onChanged: cubit.setReceivedBy,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      key: const ValueKey('mr-remarks'),
                      label: l.servicesMaterialRequestRemarks,
                      initialValue: d.remarks,
                      enabled: !state.saving,
                      maxLines: 2,
                      onChanged: cubit.setRemarks,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppFormSection(
                title: l.servicesMaterialRequestSectionSummary,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.servicesMaterialRequestTotalQuantity,
                      value: formatMaterialQuantity(state.totalQuantity),
                    ),
                    AppDetailField(
                      label: l.servicesMaterialRequestColumnItems,
                      value: l.servicesMaterialRequestItemCount(
                        '${d.lines.length}',
                      ),
                    ),
                  ],
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
    ServiceMaterialRequestFormCubit cubit,
  ) async {
    final l = context.l10n;
    final result =
        await showServiceReferencePicker<ServiceEligibleInspectionRef>(
          context,
          title: l.servicesMaterialRequestSelectInspection,
          search: cubit.searchInspections,
          labelOf: (i) => i.inspectionNumber,
          idOf: (i) => i.id,
          subtitleOf: (i) => [
            i.customerName,
            i.assignmentNumber,
            i.enquiryNumber,
          ].where((s) => s.isNotEmpty).join(' · '),
          selectedId: cubit.state.draft.sourceInspectionId,
          searchHint: l.servicesMaterialRequestSearch,
          emptyText: l.servicesMaterialRequestInspectionInvalid,
        );
    if (cubit.isClosed) return;
    if (result is ServiceReferenceSelected<ServiceEligibleInspectionRef>) {
      await cubit.selectInspection(result.value);
    }
  }
}
