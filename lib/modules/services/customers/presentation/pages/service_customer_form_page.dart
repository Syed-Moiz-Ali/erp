import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer.dart';
import 'package:modular_erp/modules/services/customers/presentation/bloc/service_customer_blocs.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';

class ServiceCustomerFormPage extends StatelessWidget {
  const ServiceCustomerFormPage({
    super.key,
    this.customerId,
    this.returnSelection = false,
  });
  final String? customerId;

  /// When true the page was opened in-context from another form (for example the
  /// Service Enquiry form) and pops the created id instead of leaving the flow.
  final bool returnSelection;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocConsumer<ServiceCustomerFormCubit, ServiceCustomerFormState>(
      listenWhen: (p, c) => c.saved && !p.saved,
      listener: (context, state) {
        AppFeedback.showMessage(
          context,
          message: (l) => l.servicesCustomerSaved,
        );
        if (returnSelection) {
          context.pop(state.savedId);
        } else {
          context.go(ServicesRoutes.customers);
        }
      },
      builder: (context, state) {
        final d = state.draft;
        final cubit = context.read<ServiceCustomerFormCubit>();
        void change(ServiceCustomerDraft next) => cubit.change(next);
        String? fieldError(String field) =>
            serviceFieldForFailure(state.failure) == field
            ? serviceFailureMessage(state.failure, l)
            : null;
        return AppPage(
          header: AppPageHeader(
            title: customerId == null
                ? l.servicesCustomerAdd
                : l.servicesCustomerEdit,
            actions: [
              AppTextButton(
                label: l.cancel,
                onPressed: state.saving
                    ? null
                    : () => context.go(ServicesRoutes.customers),
              ),
              AppPrimaryButton(
                label: l.save,
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
                      serviceFailureMessage(state.failure, l) ??
                      l.servicesCustomerStorageError,
                  status: AppStatus.danger,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              AppFormSection(
                title: l.servicesCustomerName,
                child: AppFormGrid(
                  children: [
                    AppTextField(
                      label: l.servicesCustomerName,
                      initialValue: d.name,
                      enabled: !state.saving,
                      errorText: fieldError('name'),
                      onChanged: (v) => change(d.copyWith(name: v)),
                    ),
                    AppSelectField<ServiceCustomerKind>(
                      label: l.servicesCustomerKind,
                      value: d.kind,
                      onChanged: (v) => change(
                        d.copyWith(kind: v ?? ServiceCustomerKind.individual),
                      ),
                      options: [
                        AppSelectOption(
                          ServiceCustomerKind.individual,
                          l.servicesCustomerKindIndividual,
                        ),
                        AppSelectOption(
                          ServiceCustomerKind.organization,
                          l.servicesCustomerKindOrganization,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppFormSection(
                title: l.servicesCustomerContactSection,
                child: AppFormGrid(
                  children: [
                    AppTextField(
                      label: l.servicesCustomerMobile,
                      initialValue: d.mobile,
                      enabled: !state.saving,
                      keyboardType: TextInputType.phone,
                      errorText: fieldError('mobile'),
                      onChanged: (v) => change(d.copyWith(mobile: v)),
                    ),
                    AppTextField(
                      label: l.servicesCustomerAlternateMobile,
                      initialValue: d.alternateMobile,
                      enabled: !state.saving,
                      keyboardType: TextInputType.phone,
                      onChanged: (v) => change(d.copyWith(alternateMobile: v)),
                    ),
                    AppTextField(
                      label: l.servicesCustomerEmail,
                      initialValue: d.email,
                      enabled: !state.saving,
                      keyboardType: TextInputType.emailAddress,
                      errorText: fieldError('email'),
                      onChanged: (v) => change(d.copyWith(email: v)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppFormSection(
                title: l.servicesCustomerNotes,
                child: AppTextField(
                  label: l.servicesCustomerNotes,
                  initialValue: d.notes,
                  enabled: !state.saving,
                  maxLines: 3,
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
