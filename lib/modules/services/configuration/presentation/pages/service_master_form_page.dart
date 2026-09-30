import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master.dart';
import 'package:modular_erp/modules/services/configuration/presentation/bloc/service_master_blocs.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';

/// Singular display name for a master kind, used to compose mode-aware titles
/// ("Add priority" / "Edit service type").
String serviceMasterSingular(AppLocalizations l, ServiceMasterKind kind) =>
    switch (kind) {
      ServiceMasterKind.serviceType => l.servicesServiceTypeSingular,
      ServiceMasterKind.complaintType => l.servicesComplaintTypeSingular,
      ServiceMasterKind.priority => l.servicesPrioritySingular,
      ServiceMasterKind.ticketType => l.servicesTicketTypeSingular,
      ServiceMasterKind.rootCause => l.servicesRootCauseSingular,
      ServiceMasterKind.chargeResponsibility =>
        l.servicesChargeResponsibilitySingular,
      ServiceMasterKind.materialRequestPurpose =>
        l.servicesMaterialRequestPurposeSingular,
    };

/// Short, subtle context line shown under the mode-aware form title.
String serviceMasterSubtitle(AppLocalizations l, ServiceMasterKind kind) =>
    switch (kind) {
      ServiceMasterKind.serviceType => l.servicesServiceTypeSubtitle,
      ServiceMasterKind.complaintType => l.servicesComplaintTypeSubtitle,
      ServiceMasterKind.priority => l.servicesPrioritySubtitle,
      ServiceMasterKind.ticketType => l.servicesTicketTypeSubtitle,
      ServiceMasterKind.rootCause => l.servicesRootCauseSubtitle,
      ServiceMasterKind.chargeResponsibility =>
        l.servicesChargeResponsibilitySubtitle,
      ServiceMasterKind.materialRequestPurpose =>
        l.servicesMaterialRequestPurposeSubtitle,
    };

/// One standardized master form composition shared by every Services master
/// (Service Types, Complaint Types, Priorities, Ticket Types, Root Causes,
/// Charge Responsibilities, Material Request Purposes). Create and Edit reuse
/// the same view, state model and validation.
class ServiceMasterFormPage extends StatelessWidget {
  const ServiceMasterFormPage({
    super.key,
    required this.kind,
    this.id,
    this.readOnly = false,
  });
  final ServiceMasterKind kind;
  final String? id;

  /// When true the page renders master detail only: fields are disabled and no
  /// Save action is offered. Used by the `/:id` detail route so a View-only user
  /// never receives an editable form.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final listRoute = switch (kind) {
      ServiceMasterKind.serviceType => ServicesRoutes.serviceTypes,
      ServiceMasterKind.complaintType => ServicesRoutes.complaintTypes,
      ServiceMasterKind.priority => ServicesRoutes.priorities,
      ServiceMasterKind.ticketType => ServicesRoutes.ticketTypes,
      ServiceMasterKind.rootCause => ServicesRoutes.rootCauses,
      ServiceMasterKind.chargeResponsibility =>
        ServicesRoutes.chargeResponsibilities,
      ServiceMasterKind.materialRequestPurpose =>
        ServicesRoutes.materialRequestPurposes,
    };
    return BlocConsumer<ServiceMasterFormCubit, ServiceMasterFormState>(
      listenWhen: (p, c) =>
          (c.saved && !p.saved) ||
          (c.failure != null && c.failure != p.failure),
      listener: (context, state) {
        if (state.saved) {
          AppFeedback.showMessage(
            context,
            message: (l) => l.servicesMasterSaved,
          );
          context.go(listRoute);
        } else if (state.failure != null) {
          AppFeedback.showMessage(
            context,
            message: (l) => l.servicesMasterStorageError,
          );
        }
      },
      builder: (context, state) {
        final d = state.draft;
        final cubit = context.read<ServiceMasterFormCubit>();
        final isPriority = kind == ServiceMasterKind.priority;
        final title = readOnly
            ? serviceMasterSingular(l, kind)
            : id == null
            ? l.servicesMasterAddName(serviceMasterSingular(l, kind))
            : l.servicesMasterEditName(serviceMasterSingular(l, kind));

        final codeError = state.failure == 'servicesMasterCodeRequired'
            ? l.servicesMasterCodeRequired
            : null;
        final nameError = state.failure == 'servicesMasterNameRequired'
            ? l.servicesMasterNameRequired
            : null;
        final notFound = state.failure == 'servicesMasterNotFound';
        final topError = switch (state.failure) {
          null ||
          'servicesMasterCodeRequired' ||
          'servicesMasterNameRequired' ||
          'servicesMasterNotFound' => null,
          'servicesMasterDuplicateCode' => l.servicesMasterDuplicateCode,
          'servicesMasterDuplicateName' => l.servicesMasterDuplicateName,
          _ => l.servicesMasterStorageError,
        };

        final actions = [
          AppTextButton(
            label: readOnly ? l.close : l.cancel,
            onPressed: state.saving ? null : () => context.go(listRoute),
          ),
          if (!readOnly)
            AppPrimaryButton(
              label: l.save,
              loading: state.saving,
              onPressed: state.saving ? null : cubit.save,
            ),
        ];

        if (notFound) {
          return AppFormPage(
            title: title,
            subtitle: serviceMasterSubtitle(l, kind),
            actions: actions,
            child: AppErrorState(
              message: l.servicesMasterNotFound,
              onRetry: () => context.go(listRoute),
            ),
          );
        }

        return AppFormPage(
          title: title,
          subtitle: serviceMasterSubtitle(l, kind),
          actions: actions,
          error: topError,
          loading: state.loading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppFormSection(
                title: l.servicesMasterBasicInformation,
                child: AppFormGrid(
                  spans: [
                    AppFormSpan.half,
                    AppFormSpan.half,
                    if (kind == ServiceMasterKind.complaintType &&
                        state.serviceTypes.isNotEmpty)
                      AppFormSpan.half,
                    AppFormSpan.full,
                  ],
                  children: [
                    AppTextField(
                      label: l.servicesMasterCode,
                      helperText: l.servicesMasterCodeHelper,
                      initialValue: d.code,
                      enabled: !state.saving && !readOnly,
                      required: true,
                      errorText: codeError,
                      onChanged: (v) => cubit.change(d.copyWith(code: v)),
                    ),
                    AppTextField(
                      label: l.servicesMasterName,
                      initialValue: d.name,
                      enabled: !state.saving && !readOnly,
                      required: true,
                      errorText: nameError,
                      onChanged: (v) => cubit.change(d.copyWith(name: v)),
                    ),
                    if (kind == ServiceMasterKind.complaintType &&
                        state.serviceTypes.isNotEmpty)
                      AppSelectField<String>(
                        label: l.servicesMasterServiceType,
                        value: d.serviceTypeId ?? '',
                        onChanged: (v) => cubit.change(
                          d.copyWith(
                            serviceTypeId: (v == null || v.isEmpty) ? null : v,
                            clearServiceType: v == null || v.isEmpty,
                          ),
                        ),
                        options: [
                          AppSelectOption('', l.servicesMasterGeneric),
                          for (final type in state.serviceTypes)
                            AppSelectOption(type.id, type.name),
                        ],
                      ),
                    AppTextField(
                      label: l.servicesMasterDescription,
                      initialValue: d.description,
                      enabled: !state.saving && !readOnly,
                      maxLines: 4,
                      minLines: 3,
                      onChanged: (v) =>
                          cubit.change(d.copyWith(description: v)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppFormSection(
                title: l.servicesMasterOrderingBehavior,
                subtitle: l.servicesMasterOrderingSubtitle,
                child: AppFormGrid(
                  spans: isPriority
                      ? [AppFormSpan.quarter, AppFormSpan.quarter]
                      : [AppFormSpan.quarter],
                  children: [
                    AppTextField(
                      label: l.servicesMasterSortOrder,
                      helperText: l.servicesMasterSortOrderHelper,
                      initialValue: d.sortOrder,
                      enabled: !state.saving && !readOnly,
                      keyboardType: TextInputType.number,
                      onChanged: (v) => cubit.change(d.copyWith(sortOrder: v)),
                    ),
                    if (isPriority)
                      AppTextField(
                        label: l.servicesMasterRank,
                        initialValue: d.rank,
                        enabled: !state.saving && !readOnly,
                        keyboardType: TextInputType.number,
                        onChanged: (v) => cubit.change(d.copyWith(rank: v)),
                      ),
                  ],
                ),
              ),
              if (isPriority) ...[
                const SizedBox(height: AppSpacing.lg),
                AppBooleanSettingRow(
                  label: l.servicesMasterDefaultPriorityLabel,
                  description: l.servicesMasterDefaultPriorityDescription,
                  value: d.isDefault,
                  enabled: !state.saving && !readOnly,
                  onChanged: (v) => cubit.change(d.copyWith(isDefault: v)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
