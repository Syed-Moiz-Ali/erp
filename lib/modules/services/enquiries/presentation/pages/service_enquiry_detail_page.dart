import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/enquiries/presentation/bloc/service_enquiry_blocs.dart';
import 'package:modular_erp/modules/services/enquiries/presentation/widgets/enquiry_detail_editor.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment_repository.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/presentation/widgets/enquiry_job_assignment_section.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class ServiceEnquiryDetailPage extends StatelessWidget {
  const ServiceEnquiryDetailPage({
    super.key,
    required this.enquiryId,
    this.jobAssignments,
  });
  final String enquiryId;
  final ServiceJobAssignmentRepository? jobAssignments;

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    bool can(AppPermission p) => permissions?.contains(p) ?? false;
    final canEdit = can(AppPermission.serviceEnquiryEdit);
    final canCancel = can(AppPermission.serviceEnquiryCancel);
    return BlocBuilder<ServiceEnquiryDetailCubit, ServiceEnquiryDetailState>(
      builder: (context, state) {
        final l = context.l10n;
        final detail = state.detail;
        if (state.loading && detail == null) {
          return const AppPage(child: AppConfigurationSkeleton());
        }
        if (detail == null) {
          return AppPage(
            header: AppPageHeader(title: l.servicesEnquiriesTitle),
            child: AppEmptyState(
              title: l.servicesEnquiryNotFound,
              message: l.servicesEnquiryEmptyMessage,
            ),
          );
        }
        final e = detail.enquiry;
        final snapshot = e.partySnapshot;
        final dates = AppDateFormatter(Localizations.localeOf(context));

        Future<void> cancel() async {
          final controller = TextEditingController();
          final confirmed = await AppDialog.show<bool>(
            context,
            (c) => AppDialog(
              title: c.l10n.servicesEnquiryCancelConfirmTitle,
              actions: [
                AppTextButton(
                  label: c.l10n.cancel,
                  onPressed: () => Navigator.pop(c, false),
                ),
                AppPrimaryButton(
                  label: c.l10n.servicesEnquiryCancel,
                  onPressed: () => Navigator.pop(c, true),
                ),
              ],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(c.l10n.servicesEnquiryCancelConfirmMessage),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: controller,
                    label: c.l10n.servicesEnquiryCancelReason,
                    hint: c.l10n.servicesEnquiryCancelReasonHint,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          );
          if (confirmed != true || !context.mounted) return;
          final result = await context.read<ServiceEnquiryDetailCubit>().cancel(
            reason: controller.text,
          );
          if (!context.mounted) return;
          AppFeedback.showMessage(
            context,
            message: (l) => result is Success
                ? l.servicesEnquiryCancelled
                : l.servicesEnquiryStorageError,
          );
        }

        return AppPage(
          header: AppPageHeader(
            title: e.enquiryNumber,
            subtitle: snapshot.customerName,
            actions: [
              if (canEdit && e.isOpen)
                AppSecondaryButton(
                  label: l.servicesEnquiryEdit,
                  icon: Icons.edit_outlined,
                  onPressed: () => context.go(ServicesRoutes.enquiryEdit(e.id)),
                ),
              if (canCancel && e.isOpen)
                AppSecondaryButton(
                  label: l.servicesEnquiryCancel,
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
                      label: serviceEnquiryStatusLabel(e.status, l),
                      status: serviceEnquiryStatus(e.status),
                      isPill: true,
                    ),
                    AppStatusBadge(
                      label: detail.priorityName,
                      status: servicePriorityStatus(detail.priorityRank),
                      isPill: true,
                    ),
                    AppStatusBadge(
                      label: e.enquiryNumber,
                      status: AppStatus.neutral,
                      isPill: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesEnquiryDetailCustomerSection,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.servicesEnquiryCustomerName,
                      value: snapshot.customerName ?? '',
                    ),
                    if (snapshot.customerCode != null)
                      AppDetailField(
                        label: l.servicesEnquiryCustomerCode,
                        value: snapshot.customerCode!,
                        identifier: true,
                      ),
                    if (snapshot.customerMobile != null)
                      AppDetailField(
                        label: l.servicesEnquiryCustomerMobile,
                        value: snapshot.customerMobile!,
                        identifier: true,
                      ),
                    if (snapshot.siteName != null)
                      AppDetailField(
                        label: l.servicesEnquirySite,
                        value: snapshot.siteName!,
                      ),
                    if (snapshot.tenantName != null)
                      AppDetailField(
                        label: l.servicesEnquiryTenant,
                        value: snapshot.tenantName!,
                      ),
                    if (snapshot.buildingName != null)
                      AppDetailField(
                        label: l.servicesEnquiryBuilding,
                        value: snapshot.buildingName!,
                      ),
                    if (snapshot.unitNumber != null)
                      AppDetailField(
                        label: l.servicesEnquiryUnit,
                        value: snapshot.unitNumber!,
                      ),
                    if (snapshot.addressSummary != null)
                      AppDetailField(
                        label: l.servicesEnquiryAddress,
                        value: snapshot.addressSummary!,
                      ),
                    if (snapshot.siteContactName != null)
                      AppDetailField(
                        label: l.servicesEnquiryContact,
                        value: snapshot.siteContactName!,
                      ),
                    if (snapshot.siteContactMobile != null)
                      AppDetailField(
                        label: l.servicesEnquiryCustomerMobile,
                        value: snapshot.siteContactMobile!,
                        identifier: true,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesEnquiryDetailServiceSection,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.servicesEnquiryServiceType,
                      value: detail.serviceTypeName,
                    ),
                    AppDetailField(
                      label: l.servicesEnquiryComplaintType,
                      value: detail.complaintTypeName,
                    ),
                    AppDetailField(
                      label: l.servicesEnquiryPriority,
                      value: detail.priorityName,
                    ),
                    AppDetailField(
                      label: l.servicesEnquiryTicketType,
                      value: detail.ticketTypeName,
                    ),
                    AppDetailField(
                      label: l.servicesEnquiryMaterialReceived,
                      value: serviceMaterialReceivedLabel(
                        e.materialReceived,
                        l,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesEnquiryDetailsSection,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (e.details.isEmpty)
                      Text(l.servicesEnquiryNoDetails)
                    else
                      for (var i = 0; i < e.details.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppSpacing.lg),
                        _DetailLineView(index: i + 1, line: e.details[i]),
                      ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (jobAssignments != null) ...[
                EnquiryJobAssignmentSection(
                  repository: jobAssignments!,
                  enquiryId: e.id,
                  enquiryStatus: e.status,
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
              AppFormSection(
                title: l.servicesEnquiryDetailRecord,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.servicesEnquiryCreatedAt,
                      value: dates.date(e.createdAt),
                    ),
                    AppDetailField(
                      label: l.servicesEnquiryUpdatedAt,
                      value: dates.date(e.updatedAt),
                    ),
                    AppDetailField(
                      label: l.servicesEnquiryCreatedBy,
                      value: e.createdByUserId,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesEnquiryUpdatedBy,
                      value: e.updatedByUserId,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesEnquiryVersion,
                      value: '${e.version}',
                    ),
                    if (e.cancelledAt != null)
                      AppDetailField(
                        label: l.servicesEnquiryCancelledAt,
                        value: dates.date(e.cancelledAt!),
                      ),
                    if (e.cancelReason != null)
                      AppDetailField(
                        label: l.servicesEnquiryCancelReason,
                        value: e.cancelReason!,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppSettingsSection(
                title: l.servicesEnquiryDetailActivity,
                children: [
                  if (state.activity.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(l.servicesEnquiryNoActivity),
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
}

class _DetailLineView extends StatelessWidget {
  const _DetailLineView({required this.index, required this.line});
  final int index;
  final ServiceEnquiryDetailLine line;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      variant: AppCardVariant.subtle,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.servicesEnquiryDetailLine('$index'),
                  style: AppTypography.of(context).label,
                ),
              ),
              AppStatusBadge(
                label: serviceEnquiryDetailStatusLabel(line.status, l),
                status: line.status.isOpen ? AppStatus.info : AppStatus.neutral,
                isPill: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(line.description, style: AppTypography.of(context).body),
          if (line.attachments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l.servicesEnquiryPhotos,
              style: AppTypography.of(
                context,
              ).caption.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final attachment in line.attachments)
                  AttachmentThumbnail(attachment: attachment),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
