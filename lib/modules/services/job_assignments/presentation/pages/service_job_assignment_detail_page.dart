import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/modules/services/job_assignments/presentation/bloc/service_job_assignment_blocs.dart';
import 'package:modular_erp/modules/services/job_assignments/presentation/widgets/job_assignment_widgets.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class ServiceJobAssignmentDetailPage extends StatelessWidget {
  const ServiceJobAssignmentDetailPage({super.key, required this.assignmentId});
  final String assignmentId;

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    bool can(AppPermission p) => permissions?.contains(p) ?? false;
    final canEdit = can(AppPermission.serviceJobAssignmentEdit);
    final canCancel = can(AppPermission.serviceJobAssignmentCancel);
    return BlocBuilder<
      ServiceJobAssignmentDetailCubit,
      ServiceJobAssignmentDetailState
    >(
      builder: (context, state) {
        final l = context.l10n;
        final view = state.view;
        if (state.loading && view == null) {
          return const AppPage(child: AppConfigurationSkeleton());
        }
        if (view == null) {
          return AppPage(
            header: AppPageHeader(title: l.servicesJobAssignmentsTitle),
            child: AppEmptyState(
              title: l.servicesJobAssignmentNotFound,
              message: l.servicesJobAssignmentEmptyMessage,
            ),
          );
        }
        final a = view.assignment;
        final snapshot = view.partySnapshot;
        final dates = AppDateFormatter(Localizations.localeOf(context));

        Future<void> cancel() async {
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: (l) => l.servicesJobAssignmentCancelConfirmTitle,
            message: (l) => l.servicesJobAssignmentCancelConfirmMessage,
            confirmLabel: (l) => l.servicesJobAssignmentCancel,
          );
          if (!confirmed || !context.mounted) return;
          final result = await context
              .read<ServiceJobAssignmentDetailCubit>()
              .cancel();
          if (!context.mounted) return;
          AppFeedback.showMessage(
            context,
            message: (l) => result is Success
                ? l.servicesJobAssignmentCancelled
                : l.servicesJobAssignmentStorageError,
          );
        }

        return AppPage(
          header: AppPageHeader(
            title: a.assignmentNumber,
            subtitle: view.customerName,
            actions: [
              if (canEdit && a.isActive)
                AppSecondaryButton(
                  label: l.servicesJobAssignmentEdit,
                  icon: Icons.edit_outlined,
                  onPressed: () =>
                      context.go(ServicesRoutes.assignmentEdit(a.id)),
                ),
              if (canCancel && a.isActive)
                AppSecondaryButton(
                  label: l.servicesJobAssignmentCancel,
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
                      label: serviceJobAssignmentStatusLabel(a.status, l),
                      status: serviceJobAssignmentStatus(a.status),
                      isPill: true,
                    ),
                    AppStatusBadge(
                      label: dates.date(a.scheduledVisitDate),
                      icon: Icons.event_outlined,
                      status: AppStatus.neutral,
                      isPill: true,
                    ),
                    AppStatusBadge(
                      label: view.priorityName,
                      status: servicePriorityStatus(view.priorityRank),
                      isPill: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesJobAssignmentDetailContext,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.servicesJobAssignmentEnquiry,
                      value: view.enquiryNumber,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesEnquiryCustomerName,
                      value: view.customerName,
                    ),
                    if (view.customerMobile != null)
                      AppDetailField(
                        label: l.servicesEnquiryCustomerMobile,
                        value: view.customerMobile!,
                        identifier: true,
                      ),
                    AppDetailField(
                      label: l.servicesEnquiryComplaintType,
                      value: view.complaintTypeName,
                    ),
                    AppDetailField(
                      label: l.servicesEnquiryPriority,
                      value: view.priorityName,
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
                    AppDetailField(
                      label: l.servicesJobAssignmentMaterialReceived,
                      value: serviceMaterialReceivedLabel(
                        view.materialReceived,
                        l,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SourceEnquiryIssues(details: view.enquiryDetails),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesJobAssignmentDetailWork,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < view.lines.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.lg),
                      _WorkItemView(index: i + 1, line: view.lines[i]),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesJobAssignmentDetailAudit,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.servicesJobAssignmentDate,
                      value: dates.date(a.assignmentDate),
                    ),
                    AppDetailField(
                      label: l.servicesJobAssignmentCreatedAt,
                      value: dates.date(a.createdAt),
                    ),
                    AppDetailField(
                      label: l.servicesJobAssignmentUpdatedAt,
                      value: dates.date(a.updatedAt),
                    ),
                    AppDetailField(
                      label: l.servicesJobAssignmentCreatedBy,
                      value: a.createdByUserId,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesJobAssignmentUpdatedBy,
                      value: a.updatedByUserId,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesJobAssignmentVersion,
                      value: '${a.version}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppSettingsSection(
                title: l.servicesJobAssignmentDetailActivity,
                children: [
                  if (state.activity.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(l.servicesJobAssignmentNoActivity),
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

class _WorkItemView extends StatelessWidget {
  const _WorkItemView({required this.index, required this.line});
  final int index;
  final ServiceJobAssignmentLineView line;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final item = line.line;
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
                  l.servicesJobAssignmentLineTitle('$index'),
                  style: AppTypography.of(context).label,
                ),
              ),
              AppStatusBadge(
                label: l.servicesJobAssignmentLineStatusPending,
                status: AppStatus.info,
                isPill: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(item.work, style: AppTypography.of(context).body),
          const SizedBox(height: AppSpacing.md),
          AppDetailsGrid(
            fields: [
              AppDetailField(
                label: l.servicesJobAssignmentTechnician,
                value: line.employeeName ?? '',
              ),
              AppDetailField(
                label: l.servicesJobAssignmentServiceTeam,
                value: line.teamName ?? '',
              ),
              if (item.descriptionForWork.isNotEmpty)
                AppDetailField(
                  label: l.servicesJobAssignmentDescriptionForWork,
                  value: item.descriptionForWork,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
