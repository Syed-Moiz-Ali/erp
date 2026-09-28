import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/sites/domain/service_site.dart';
import 'package:modular_erp/modules/services/sites/presentation/bloc/service_site_blocs.dart';

class ServiceSiteFormPage extends StatelessWidget {
  const ServiceSiteFormPage({
    super.key,
    this.siteId,
    this.preselectedCustomerId,
    this.returnSelection = false,
  });
  final String? siteId;
  final String? preselectedCustomerId;

  /// When true the page pops the created id instead of leaving the flow, so an
  /// in-context caller (Service Enquiry form) can preselect the new site.
  final bool returnSelection;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocConsumer<ServiceSiteFormCubit, ServiceSiteFormState>(
      listenWhen: (p, c) => c.saved && !p.saved,
      listener: (context, state) {
        AppFeedback.showMessage(context, message: (l) => l.servicesSiteSaved);
        if (returnSelection) {
          context.pop(state.savedId);
        } else {
          context.go(ServicesRoutes.sites);
        }
      },
      builder: (context, state) {
        final d = state.draft;
        final cubit = context.read<ServiceSiteFormCubit>();
        void change(ServiceSiteDraft next) => cubit.change(next);
        String? fieldError(String field) =>
            serviceFieldForFailure(state.failure) == field
            ? serviceFailureMessage(state.failure, l)
            : null;
        final notFound = state.failure == 'servicesSiteNotFound';
        return AppFormPage(
          title: siteId == null ? l.servicesSiteAdd : l.servicesSiteEdit,
          actions: [
            AppTextButton(
              label: l.cancel,
              onPressed: state.saving
                  ? null
                  : () => context.go(ServicesRoutes.sites),
            ),
            AppPrimaryButton(
              label: l.save,
              loading: state.saving,
              onPressed: state.saving ? null : cubit.save,
            ),
          ],
          error: state.failure == null || notFound
              ? null
              : (serviceFailureMessage(state.failure, l) ??
                    l.servicesSiteStorageError),
          loading: state.loading,
          child: notFound
              ? AppErrorState(
                  message: l.servicesSiteNotFound,
                  onRetry: () => context.go(ServicesRoutes.sites),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppFormSection(
                      title: l.servicesSiteInformationSection,
                      child: AppFormGrid(
                        children: [
                          AppTextField(
                            label: l.servicesSiteName,
                            initialValue: d.siteName,
                            enabled: !state.saving,
                            required: true,
                            errorText: fieldError('siteName'),
                            onChanged: (v) => change(d.copyWith(siteName: v)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppFormSection(
                      title: l.servicesSiteCustomerRelationship,
                      child: AppFormGrid(
                        spans: [AppFormSpan.half],
                        children: [
                          AppSelectField<String>(
                            label: l.servicesSiteCustomer,
                            value: d.customerId,
                            enabled: !state.saving,
                            required: true,
                            errorText: fieldError('customer'),
                            onChanged: (v) => change(d.copyWith(customerId: v)),
                            options: [
                              for (final c in state.customers)
                                AppSelectOption(
                                  c.id,
                                  '${c.displayName} · ${c.customerCode}',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppFormSection(
                      title: l.servicesSiteTenantSection,
                      child: AppFormGrid(
                        spans: [
                          AppFormSpan.third,
                          AppFormSpan.third,
                          AppFormSpan.third,
                        ],
                        children: [
                          AppTextField(
                            label: l.servicesSiteTenant,
                            initialValue: d.tenantName,
                            enabled: !state.saving,
                            onChanged: (v) => change(d.copyWith(tenantName: v)),
                          ),
                          AppTextField(
                            label: l.servicesSiteBuilding,
                            initialValue: d.buildingName,
                            enabled: !state.saving,
                            onChanged: (v) =>
                                change(d.copyWith(buildingName: v)),
                          ),
                          AppTextField(
                            label: l.servicesSiteUnit,
                            initialValue: d.unitNumber,
                            enabled: !state.saving,
                            onChanged: (v) => change(d.copyWith(unitNumber: v)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppFormSection(
                      title: l.servicesSiteContact,
                      child: AppFormGrid(
                        spans: [
                          AppFormSpan.third,
                          AppFormSpan.third,
                          AppFormSpan.third,
                        ],
                        children: [
                          AppTextField(
                            label: l.servicesSiteContactName,
                            initialValue: d.contactName,
                            enabled: !state.saving,
                            onChanged: (v) =>
                                change(d.copyWith(contactName: v)),
                          ),
                          AppTextField(
                            label: l.servicesSiteContactMobile,
                            initialValue: d.contactMobile,
                            enabled: !state.saving,
                            keyboardType: TextInputType.phone,
                            autofillHints: const [
                              AutofillHints.telephoneNumber,
                            ],
                            onChanged: (v) =>
                                change(d.copyWith(contactMobile: v)),
                          ),
                          AppTextField(
                            label: l.servicesSiteContactEmail,
                            initialValue: d.contactEmail,
                            enabled: !state.saving,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            onChanged: (v) =>
                                change(d.copyWith(contactEmail: v)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppFormSection(
                      title: l.servicesSiteAddressSection,
                      child: AppFormGrid(
                        children: [
                          AppTextField(
                            label: l.servicesSiteAddress1,
                            initialValue: d.addressLine1,
                            enabled: !state.saving,
                            onChanged: (v) =>
                                change(d.copyWith(addressLine1: v)),
                          ),
                          AppTextField(
                            label: l.servicesSiteAddress2,
                            initialValue: d.addressLine2,
                            enabled: !state.saving,
                            onChanged: (v) =>
                                change(d.copyWith(addressLine2: v)),
                          ),
                          AppTextField(
                            label: l.servicesSiteArea,
                            initialValue: d.area,
                            enabled: !state.saving,
                            onChanged: (v) => change(d.copyWith(area: v)),
                          ),
                          AppTextField(
                            label: l.servicesSiteCity,
                            initialValue: d.city,
                            enabled: !state.saving,
                            onChanged: (v) => change(d.copyWith(city: v)),
                          ),
                          AppTextField(
                            label: l.servicesSiteState,
                            initialValue: d.state,
                            enabled: !state.saving,
                            onChanged: (v) => change(d.copyWith(state: v)),
                          ),
                          AppTextField(
                            label: l.servicesSitePostalCode,
                            initialValue: d.postalCode,
                            enabled: !state.saving,
                            onChanged: (v) => change(d.copyWith(postalCode: v)),
                          ),
                          AppTextField(
                            label: l.servicesSiteCountry,
                            initialValue: d.countryCode,
                            enabled: !state.saving,
                            onChanged: (v) =>
                                change(d.copyWith(countryCode: v)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppFormSection(
                      title: l.servicesSiteCoordinates,
                      child: AppFormGrid(
                        spans: [AppFormSpan.quarter, AppFormSpan.quarter],
                        children: [
                          AppTextField(
                            label: l.servicesSiteLatitude,
                            initialValue: d.latitude,
                            enabled: !state.saving,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            onChanged: (v) => change(d.copyWith(latitude: v)),
                          ),
                          AppTextField(
                            label: l.servicesSiteLongitude,
                            initialValue: d.longitude,
                            enabled: !state.saving,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            onChanged: (v) => change(d.copyWith(longitude: v)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppFormSection(
                      title: l.servicesSiteNotes,
                      child: AppTextField(
                        label: l.servicesSiteNotes,
                        initialValue: d.notes,
                        enabled: !state.saving,
                        maxLines: 4,
                        minLines: 3,
                        onChanged: (v) => change(d.copyWith(notes: v)),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
