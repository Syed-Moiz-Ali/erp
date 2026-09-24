import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer.dart';
import 'package:modular_erp/modules/services/customers/presentation/bloc/service_customer_blocs.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry_repository.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/presentation/widgets/recent_enquiries_section.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class ServiceCustomerDetailPage extends StatelessWidget {
  const ServiceCustomerDetailPage({
    super.key,
    required this.customerId,
    this.enquiries,
  });
  final String customerId;
  final ServiceEnquiryRepository? enquiries;

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    final canEdit =
        permissions?.contains(AppPermission.serviceCustomerEdit) ?? false;
    final canDeactivate =
        permissions?.contains(AppPermission.serviceCustomerDeactivate) ?? false;
    final canAddSite =
        permissions?.contains(AppPermission.serviceSiteCreate) ?? false;
    return BlocConsumer<ServiceCustomerDetailCubit, ServiceCustomerDetailState>(
      listenWhen: (p, c) => c.failure != null && c.failure != p.failure,
      listener: (context, state) => AppFeedback.showMessage(
        context,
        message: (l) => l.servicesCustomerStorageError,
      ),
      builder: (context, state) {
        final l = context.l10n;
        final customer = state.customer;
        if (state.loading && customer == null) {
          return const AppPage(child: AppConfigurationSkeleton());
        }
        if (customer == null) {
          return AppPage(
            header: AppPageHeader(title: l.servicesCustomersTitle),
            child: AppEmptyState(
              title: l.servicesCustomerNotFound,
              message: l.servicesCustomerEmptyMessage,
            ),
          );
        }
        final dates = AppDateFormatter(Localizations.localeOf(context));
        Future<void> toggle() async {
          final active = customer.status != ConfigurationStatus.active;
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: (l) => active
                ? l.servicesCustomerActivate
                : l.servicesCustomerDeactivate,
            message: (l) => customer.name,
            confirmLabel: (l) =>
                active ? l.confirm : l.servicesCustomerDeactivate,
          );
          if (!confirmed || !context.mounted) return;
          final result = await context
              .read<ServiceCustomerDetailCubit>()
              .setActive(active);
          if (context.mounted) {
            AppFeedback.showMessage(
              context,
              message: (l) => result is Success
                  ? l.servicesCustomerSaved
                  : l.servicesCustomerStorageError,
            );
          }
        }

        return AppPage(
          header: AppPageHeader(
            title: customer.name,
            subtitle: customer.customerCode,
            actions: [
              if (canEdit)
                AppSecondaryButton(
                  label: l.edit,
                  icon: Icons.edit_outlined,
                  onPressed: () =>
                      context.go(ServicesRoutes.customerEdit(customer.id)),
                ),
              if (canDeactivate)
                AppSecondaryButton(
                  label: customer.status == ConfigurationStatus.active
                      ? l.servicesCustomerDeactivate
                      : l.servicesCustomerActivate,
                  onPressed: toggle,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Row(
                  children: [
                    AppAvatar(name: customer.name, radius: 28),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: AppTypography.of(context).sectionTitle,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.xs,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              AppStatusBadge(
                                label: serviceStatusLabel(customer.status, l),
                                status: serviceStatus(customer.status),
                                isPill: true,
                              ),
                              AppStatusBadge(
                                label:
                                    customer.kind ==
                                        ServiceCustomerKind.organization
                                    ? l.servicesCustomerKindOrganization
                                    : l.servicesCustomerKindIndividual,
                                status: AppStatus.info,
                                isPill: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesCustomerContactSection,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.servicesCustomerCode,
                      value: customer.customerCode,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesCustomerMobile,
                      value: customer.mobile,
                      identifier: true,
                    ),
                    if (customer.alternateMobile != null)
                      AppDetailField(
                        label: l.servicesCustomerAlternateMobile,
                        value: customer.alternateMobile!,
                        identifier: true,
                      ),
                    if (customer.email != null)
                      AppDetailField(
                        label: l.servicesCustomerEmail,
                        value: customer.email!,
                        identifier: true,
                      ),
                    AppDetailField(
                      label: l.servicesCustomerLastUpdated,
                      value: dates.date(customer.updatedAt),
                    ),
                    if (customer.notes != null && customer.notes!.isNotEmpty)
                      AppDetailField(
                        label: l.servicesCustomerNotes,
                        value: customer.notes!,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppSettingsSection(
                title: l.servicesCustomerSites,
                children: [
                  if (state.sites.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(l.servicesCustomerNoSites),
                    )
                  else
                    for (final site in state.sites)
                      AppSettingsRow(
                        title: site.siteName,
                        description: [
                          site.siteCode,
                          site.city,
                        ].where((s) => s.isNotEmpty).join(' · '),
                        icon: Icons.location_on_outlined,
                        onPressed: () =>
                            context.go(ServicesRoutes.site(site.id)),
                      ),
                  if (canAddSite)
                    AppSettingsRow(
                      title: l.servicesSiteAdd,
                      icon: Icons.add,
                      onPressed: () => context.go(
                        '${ServicesRoutes.sitesNew}?customerId=${customer.id}',
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppSettingsSection(
                title: l.servicesCustomerActivity,
                children: [
                  if (state.activity.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(l.servicesCustomerNoActivity),
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
              if (enquiries != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                ServiceRecentEnquiriesSection(
                  repository: enquiries!,
                  title: l.servicesEnquiryRecentForCustomer,
                  emptyText: l.servicesEnquiryNoneForCustomer,
                  customerId: customer.id,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
