import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/enquiries/presentation/bloc/service_enquiry_blocs.dart';
import 'package:modular_erp/modules/services/enquiries/presentation/widgets/enquiry_detail_editor.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_reference_field.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/shared/transactions/application/attachment_picker.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';

class ServiceEnquiryFormPage extends StatelessWidget {
  const ServiceEnquiryFormPage({super.key, this.enquiryId});
  final String? enquiryId;

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    bool can(AppPermission p) => permissions?.contains(p) ?? false;
    final canCreateCustomer = can(AppPermission.serviceCustomerCreate);
    final canCreateSite = can(AppPermission.serviceSiteCreate);
    return BlocConsumer<ServiceEnquiryFormCubit, ServiceEnquiryFormState>(
      listenWhen: (p, c) => c.saved && !p.saved,
      listener: (context, state) {
        if (state.savedId == null) return;
        AppFeedback.showMessage(
          context,
          message: (l) => enquiryId == null
              ? l.servicesEnquiryCreated
              : l.servicesEnquiryUpdated,
        );
        context.go(ServicesRoutes.enquiry(state.savedId!));
      },
      builder: (context, state) {
        final l = context.l10n;
        final cubit = context.read<ServiceEnquiryFormCubit>();
        final d = state.draft;
        String? fieldError(String field) =>
            serviceEnquiryFieldForFailure(state.failure) == field
            ? serviceEnquiryFailureMessage(state.failure, l)
            : null;
        String? descriptionErrorFor(String detailId) {
          if (state.failure != 'servicesEnquiryDetailDescriptionRequired') {
            return null;
          }
          final line = state.details.where((x) => x.id == detailId).firstOrNull;
          return line != null && line.description.trim().isEmpty
              ? l.servicesEnquiryDetailDescriptionRequired
              : null;
        }

        return AppPage(
          header: AppPageHeader(
            title: enquiryId == null
                ? l.servicesEnquiryFormNew
                : l.servicesEnquiryFormEdit,
            actions: [
              AppTextButton(
                label: l.cancel,
                onPressed: state.saving
                    ? null
                    : () => context.go(ServicesRoutes.enquiries),
              ),
              AppPrimaryButton(
                label: enquiryId == null ? l.servicesEnquiryCreate : l.save,
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
                      serviceEnquiryFailureMessage(state.failure, l) ??
                      l.servicesEnquiryStorageError,
                  status: AppStatus.danger,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              AppFormSection(
                title: l.servicesEnquirySectionCustomerLocation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppFormGrid(
                      children: [
                        ServiceReferenceField<ServiceCustomerRef>(
                          label: l.servicesEnquiryCustomerName,
                          valueLabel: state.customerRef?.displayName,
                          valueSubtitle: state.customerRef == null
                              ? null
                              : [
                                  state.customerRef!.customerCode,
                                  if ((state.customerRef!.mobile ?? '')
                                      .isNotEmpty)
                                    state.customerRef!.mobile!,
                                ].join(' · '),
                          hint: l.servicesEnquirySelectCustomer,
                          errorText: fieldError('customer'),
                          enabled: !state.saving,
                          onPick: () =>
                              _pickCustomer(context, cubit, canCreateCustomer),
                          onClear: cubit.clearCustomer,
                        ),
                        ServiceReferenceField<ServiceEnquirySiteRef>(
                          label: l.servicesEnquirySite,
                          valueLabel: state.siteRef?.siteName,
                          valueSubtitle: state.siteRef == null
                              ? null
                              : [
                                  if ((state.siteRef!.buildingName ?? '')
                                      .isNotEmpty)
                                    state.siteRef!.buildingName!,
                                  if ((state.siteRef!.unitNumber ?? '')
                                      .isNotEmpty)
                                    state.siteRef!.unitNumber!,
                                ].join(' / '),
                          hint: l.servicesEnquirySelectSite,
                          errorText: fieldError('site'),
                          enabled: !state.saving && d.customerId != null,
                          onPick: () =>
                              _pickSite(context, cubit, canCreateSite),
                          onClear: cubit.clearSite,
                        ),
                      ],
                    ),
                    if (state.siteRef != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _SitePreview(ref: state.siteRef!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppFormSection(
                title: l.servicesEnquirySectionService,
                child: AppFormGrid(
                  children: [
                    AppSelectField<String>(
                      label: l.servicesEnquiryServiceType,
                      value: d.serviceTypeId,
                      enabled: !state.saving && !state.referencesLoading,
                      errorText: fieldError('serviceType'),
                      onChanged: (v) {
                        if (v != null) cubit.selectServiceType(v);
                      },
                      options: [
                        for (final s in state.serviceTypes)
                          AppSelectOption(s.id, s.name),
                      ],
                    ),
                    AppSelectField<String>(
                      label: l.servicesEnquiryComplaintType,
                      value: d.complaintTypeId,
                      enabled:
                          !state.saving &&
                          !state.referencesLoading &&
                          d.serviceTypeId != null,
                      errorText: fieldError('complaintType'),
                      hint: d.serviceTypeId == null
                          ? l.servicesEnquiryServiceTypeRequired
                          : null,
                      onChanged: (v) {
                        if (v != null) cubit.selectComplaintType(v);
                      },
                      options: [
                        for (final c in state.complaintTypesForSelection)
                          AppSelectOption(c.id, c.name),
                      ],
                    ),
                    AppSelectField<String>(
                      label: l.servicesEnquiryPriority,
                      value: d.priorityId,
                      enabled: !state.saving && !state.referencesLoading,
                      errorText: fieldError('priority'),
                      onChanged: (v) {
                        if (v != null) cubit.selectPriority(v);
                      },
                      options: [
                        for (final p in state.priorities)
                          AppSelectOption(p.id, p.name),
                      ],
                    ),
                    AppSelectField<String>(
                      label: l.servicesEnquiryTicketType,
                      value: d.ticketTypeId,
                      enabled: !state.saving && !state.referencesLoading,
                      errorText: fieldError('ticketType'),
                      onChanged: (v) {
                        if (v != null) cubit.selectTicketType(v);
                      },
                      options: [
                        for (final t in state.ticketTypes)
                          AppSelectOption(t.id, t.name),
                      ],
                    ),
                    AppSelectField<MaterialReceived>(
                      label: l.servicesEnquiryMaterialReceived,
                      value: d.materialReceived,
                      enabled: !state.saving,
                      onChanged: (v) {
                        if (v != null) cubit.selectMaterialReceived(v);
                      },
                      options: [
                        AppSelectOption(
                          MaterialReceived.no,
                          l.servicesEnquiryMaterialReceivedNo,
                        ),
                        AppSelectOption(
                          MaterialReceived.yes,
                          l.servicesEnquiryMaterialReceivedYes,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppFormSection(
                title: l.servicesEnquiryDetailsSection,
                child: EnquiryDetailEditor(
                  details: state.details,
                  enabled: !state.saving,
                  descriptionErrorFor: descriptionErrorFor,
                  onAdd: cubit.addDetail,
                  onRemove: cubit.removeDetail,
                  onDescriptionChanged: cubit.updateDetailDescription,
                  onStatusChanged: cubit.updateDetailStatus,
                  onAddPhotos: (detailId) =>
                      _pickPhotos(context, cubit, detailId),
                  onRemoveAttachment: cubit.removeDetailAttachment,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickPhotos(
    BuildContext context,
    ServiceEnquiryFormCubit cubit,
    String detailId,
  ) async {
    final account = context.read<AuthBloc>().state.context;
    if (account == null) return;
    final line = cubit.state.details.where((d) => d.id == detailId).firstOrNull;
    if (line == null) return;
    List<PickedAttachment> picked;
    try {
      picked = await attachmentPicker.pickImages();
    } catch (_) {
      if (context.mounted) {
        AppFeedback.showMessage(
          context,
          message: (l) => l.servicesEnquiryAttachmentFailure,
        );
      }
      return;
    }
    if (picked.isEmpty || !context.mounted) return;
    var count = line.attachments.length;
    final refs = <AttachmentRef>[];
    String? failureCode;
    for (final file in picked) {
      final code = AttachmentValidation.validate(
        mimeType: file.mimeType,
        sizeBytes: file.sizeBytes,
        existingCount: count,
      );
      if (code != null) {
        failureCode = code;
        continue;
      }
      count++;
      final now = DateTime.now();
      refs.add(
        AttachmentRef(
          id: const Uuid().v4(),
          companyId: account.company.id,
          ownerType: 'serviceEnquiryDetail',
          ownerId: detailId,
          category: AttachmentCategory.problemPhoto,
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
    if (!cubit.isClosed) cubit.addDetailAttachments(detailId, refs);
    if (!context.mounted) return;
    if (failureCode != null) {
      AppFeedback.showMessage(
        context,
        message: (l) =>
            serviceEnquiryFailureMessage(failureCode, l) ??
            l.servicesEnquiryAttachmentFailure,
      );
    }
  }

  Future<void> _pickCustomer(
    BuildContext context,
    ServiceEnquiryFormCubit cubit,
    bool canCreate,
  ) async {
    final l = context.l10n;
    final result = await showServiceReferencePicker<ServiceCustomerRef>(
      context,
      title: l.servicesEnquirySelectCustomer,
      search: cubit.searchCustomers,
      labelOf: (c) => c.displayName,
      idOf: (c) => c.id,
      subtitleOf: (c) => [
        c.customerCode,
        if ((c.mobile ?? '').isNotEmpty) c.mobile!,
      ].join(' · '),
      selectedId: cubit.state.customerRef?.id,
      searchHint: l.servicesCustomerSearch,
      emptyText: l.servicesEnquiryCustomerNotFound,
      createLabel: canCreate ? l.servicesEnquiryCreateCustomer : null,
    );
    if (cubit.isClosed) return;
    switch (result) {
      case ServiceReferenceSelected<ServiceCustomerRef>(:final value):
        cubit.selectCustomer(value);
      case ServiceReferenceCreateRequested<ServiceCustomerRef>():
        if (!context.mounted) return;
        final id = await context.push<String>(
          '${ServicesRoutes.customersNew}?select=1',
        );
        if (id != null && !cubit.isClosed) await cubit.selectCustomerById(id);
      case null:
        break;
    }
  }

  Future<void> _pickSite(
    BuildContext context,
    ServiceEnquiryFormCubit cubit,
    bool canCreate,
  ) async {
    final customerId = cubit.state.draft.customerId;
    if (customerId == null) return;
    final l = context.l10n;
    final result = await showServiceReferencePicker<ServiceEnquirySiteRef>(
      context,
      title: l.servicesEnquirySelectSite,
      search: cubit.searchSites,
      labelOf: (s) => s.siteName,
      idOf: (s) => s.id,
      subtitleOf: (s) => [
        s.siteCode,
        if ((s.buildingName ?? '').isNotEmpty) s.buildingName!,
        if ((s.unitNumber ?? '').isNotEmpty) s.unitNumber!,
      ].join(' · '),
      selectedId: cubit.state.siteRef?.id,
      searchHint: l.servicesSiteSearch,
      emptyText: l.servicesEnquiryNoSitesForCustomer,
      createLabel: canCreate ? l.servicesEnquiryCreateSite : null,
    );
    if (cubit.isClosed) return;
    switch (result) {
      case ServiceReferenceSelected<ServiceEnquirySiteRef>(:final value):
        cubit.selectSite(value);
      case ServiceReferenceCreateRequested<ServiceEnquirySiteRef>():
        if (!context.mounted) return;
        final id = await context.push<String>(
          '${ServicesRoutes.sitesNew}?select=1&customerId=${Uri.encodeQueryComponent(customerId)}',
        );
        if (id != null && !cubit.isClosed) await cubit.selectSiteById(id);
      case null:
        break;
    }
  }
}

class _SitePreview extends StatelessWidget {
  const _SitePreview({required this.ref});
  final ServiceEnquirySiteRef ref;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final rows = <({String label, String value})>[
      if ((ref.tenantName ?? '').isNotEmpty)
        (label: l.servicesEnquiryTenant, value: ref.tenantName!),
      if ((ref.buildingName ?? '').isNotEmpty)
        (label: l.servicesEnquiryBuilding, value: ref.buildingName!),
      if ((ref.unitNumber ?? '').isNotEmpty)
        (label: l.servicesEnquiryUnit, value: ref.unitNumber!),
      if ((ref.addressSummary ?? '').isNotEmpty)
        (label: l.servicesEnquiryAddress, value: ref.addressSummary!),
      if ((ref.contactName ?? '').isNotEmpty)
        (label: l.servicesEnquiryContact, value: ref.contactName!),
      if ((ref.contactMobile ?? '').isNotEmpty)
        (label: l.servicesEnquiryCustomerMobile, value: ref.contactMobile!),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return AppCard(
      variant: AppCardVariant.subtle,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.servicesEnquirySite,
            style: AppTypography.of(
              context,
            ).caption.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final row in rows)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      row.label,
                      style: AppTypography.of(context).caption,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.value,
                      style: AppTypography.of(context).bodySmall,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
