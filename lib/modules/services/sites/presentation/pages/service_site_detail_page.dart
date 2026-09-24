import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/sites/presentation/bloc/service_site_blocs.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class ServiceSiteDetailPage extends StatelessWidget {
  const ServiceSiteDetailPage({super.key, required this.siteId});
  final String siteId;

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    final canEdit =
        permissions?.contains(AppPermission.serviceSiteEdit) ?? false;
    final canDeactivate =
        permissions?.contains(AppPermission.serviceSiteDeactivate) ?? false;
    return BlocBuilder<ServiceSiteDetailCubit, ServiceSiteDetailState>(
      builder: (context, state) {
        final l = context.l10n;
        final site = state.site;
        if (state.loading && site == null) {
          return const AppPage(child: AppConfigurationSkeleton());
        }
        if (site == null) {
          return AppPage(
            header: AppPageHeader(title: l.servicesSitesTitle),
            child: AppEmptyState(
              title: l.servicesSiteNotFound,
              message: l.servicesSiteEmptyMessage,
            ),
          );
        }
        Future<void> toggle() async {
          final active = site.status != ConfigurationStatus.active;
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: (l) =>
                active ? l.servicesSiteActivate : l.servicesSiteDeactivate,
            message: (l) => site.siteName,
            confirmLabel: (l) => active ? l.confirm : l.servicesSiteDeactivate,
          );
          if (!confirmed || !context.mounted) return;
          final result = await context.read<ServiceSiteDetailCubit>().setActive(
            active,
          );
          if (context.mounted) {
            AppFeedback.showMessage(
              context,
              message: (l) => result is Success
                  ? l.servicesSiteSaved
                  : l.servicesSiteStorageError,
            );
          }
        }

        final address = [
          site.addressLine1,
          site.addressLine2,
          site.area,
          site.city,
          site.state,
          site.postalCode,
          site.countryCode,
        ].whereType<String>().where((s) => s.isNotEmpty).join(', ');

        return AppPage(
          maxWidth: AppDimensions.wideContent,
          header: AppPageHeader(
            title: site.siteName,
            subtitle: site.siteCode,
            actions: [
              if (canEdit)
                AppSecondaryButton(
                  label: l.edit,
                  icon: Icons.edit_outlined,
                  onPressed: () => context.go(ServicesRoutes.siteEdit(site.id)),
                ),
              if (canDeactivate)
                AppSecondaryButton(
                  label: site.status == ConfigurationStatus.active
                      ? l.servicesSiteDeactivate
                      : l.servicesSiteActivate,
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
                    AppAvatar(name: site.siteName, radius: 28),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            site.siteName,
                            style: AppTypography.of(context).sectionTitle,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          AppStatusBadge(
                            label: serviceStatusLabel(site.status, l),
                            status: serviceStatus(site.status),
                            isPill: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppSettingsSection(
                title: l.servicesSiteCustomer,
                children: [
                  AppSettingsRow(
                    title: state.customer?.name ?? site.customerId,
                    description: state.customer?.customerCode,
                    icon: Icons.business_outlined,
                    onPressed: () =>
                        context.go(ServicesRoutes.customer(site.customerId)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesSiteIdentity,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.servicesSiteCode,
                      value: site.siteCode,
                      identifier: true,
                    ),
                    if (site.tenantName != null)
                      AppDetailField(
                        label: l.servicesSiteTenant,
                        value: site.tenantName!,
                      ),
                    if (site.buildingName != null)
                      AppDetailField(
                        label: l.servicesSiteBuilding,
                        value: site.buildingName!,
                      ),
                    if (site.unitNumber != null)
                      AppDetailField(
                        label: l.servicesSiteUnit,
                        value: site.unitNumber!,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesSiteAddressSection,
                child: AppDetailsGrid(
                  fields: [
                    if (address.isNotEmpty)
                      AppDetailField(
                        label: l.servicesSiteAddress,
                        value: address,
                      ),
                    if (site.latitude != null && site.longitude != null)
                      AppDetailField(
                        label: l.servicesSiteLocation,
                        value: '${site.latitude}, ${site.longitude}',
                        identifier: true,
                      ),
                  ],
                ),
              ),
              if (site.contactName != null ||
                  site.contactMobile != null ||
                  site.contactEmail != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                AppFormSection(
                  title: l.servicesSiteContact,
                  child: AppDetailsGrid(
                    fields: [
                      if (site.contactName != null)
                        AppDetailField(
                          label: l.servicesSiteContactName,
                          value: site.contactName!,
                        ),
                      if (site.contactMobile != null)
                        AppDetailField(
                          label: l.servicesSiteContactMobile,
                          value: site.contactMobile!,
                          identifier: true,
                        ),
                      if (site.contactEmail != null)
                        AppDetailField(
                          label: l.servicesSiteContactEmail,
                          value: site.contactEmail!,
                          identifier: true,
                        ),
                    ],
                  ),
                ),
              ],
              if (site.notes != null && site.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxl),
                AppFormSection(
                  title: l.servicesSiteNotes,
                  child: AppDetailsGrid(
                    fields: [
                      AppDetailField(
                        label: l.servicesSiteNotes,
                        value: site.notes!,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
