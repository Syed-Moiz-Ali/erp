import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/material_requests/application/service_material_request_print.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request.dart';
import 'package:modular_erp/modules/services/material_requests/presentation/bloc/service_material_request_blocs.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_workflow_section.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow_repository.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class ServiceMaterialRequestDetailPage extends StatelessWidget {
  const ServiceMaterialRequestDetailPage({
    super.key,
    required this.requestId,
    this.workflow,
  });
  final String requestId;
  final ServiceWorkflowRepository? workflow;

  @override
  Widget build(BuildContext context) {
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    bool can(AppPermission p) => permissions?.contains(p) ?? false;
    final canEdit = can(AppPermission.serviceMaterialRequestEdit);
    final canCancel = can(AppPermission.serviceMaterialRequestCancel);
    final canPrint = can(AppPermission.serviceMaterialRequestPrint);
    return BlocBuilder<
      ServiceMaterialRequestDetailCubit,
      ServiceMaterialRequestDetailState
    >(
      builder: (context, state) {
        final l = context.l10n;
        final view = state.view;
        if (state.loading && view == null) {
          return const AppPage(child: AppConfigurationSkeleton());
        }
        if (view == null) {
          return AppPage(
            header: AppPageHeader(title: l.servicesMaterialRequestsTitle),
            child: AppEmptyState(
              title: l.servicesMaterialRequestNotFound,
              message: l.servicesMaterialRequestEmptyMessage,
            ),
          );
        }
        final request = view.request;
        final dates = AppDateFormatter(Localizations.localeOf(context));
        final cubit = context.read<ServiceMaterialRequestDetailCubit>();

        Future<void> cancel() async {
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: (l) => l.servicesMaterialRequestCancelConfirmTitle,
            message: (l) => l.servicesMaterialRequestCancelConfirmMessage,
            confirmLabel: (l) => l.servicesMaterialRequestCancel,
          );
          if (!confirmed || !context.mounted) return;
          final result = await cubit.cancel();
          if (!context.mounted) return;
          AppFeedback.showMessage(
            context,
            message: (l) => result is Success
                ? l.servicesMaterialRequestCancelled
                : l.servicesMaterialRequestStorageError,
          );
        }

        Future<void> print() async {
          final account = context.read<AuthBloc>().state.context;
          if (account == null) return;
          final printer = MaterialRequestPrintService(
            cubit.repository,
            const PlatformMaterialRequestFileSaver(),
          );
          final result = await printer.print(
            account,
            request.id,
            locale: Localizations.localeOf(context),
            companyName: account.company.name,
            l10n: l,
          );
          if (!context.mounted) return;
          AppFeedback.showMessage(
            context,
            message: (l) => result is Success
                ? l.servicesMaterialRequestPrinted
                : l.servicesMaterialRequestPrintFailed,
          );
        }

        return AppPage(
          header: AppPageHeader(
            title: request.requestNumber,
            subtitle: view.customerName,
            actions: [
              if (canEdit && request.isOpen)
                AppSecondaryButton(
                  label: l.servicesMaterialRequestEdit,
                  icon: Icons.edit_outlined,
                  onPressed: () => context.go(
                    ServicesRoutes.materialRequestEdit(request.id),
                  ),
                ),
              if (canPrint)
                AppSecondaryButton(
                  label: l.servicesMaterialRequestPrint,
                  icon: Icons.print_outlined,
                  onPressed: print,
                ),
              if (canCancel && request.isOpen)
                AppSecondaryButton(
                  label: l.servicesMaterialRequestCancel,
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
                      label: serviceMaterialRequestStatusLabel(
                        request.status,
                        l,
                      ),
                      status: serviceMaterialRequestStatus(request.status),
                      isPill: true,
                    ),
                    AppStatusBadge(
                      label: dates.date(request.requestDate),
                      icon: Icons.event_outlined,
                      status: AppStatus.neutral,
                      isPill: true,
                    ),
                    if ((view.purposeName ?? '').isNotEmpty)
                      AppStatusBadge(
                        label: view.purposeName!,
                        icon: Icons.request_quote_outlined,
                        status: AppStatus.neutral,
                        isPill: true,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (workflow != null) ...[
                ServiceWorkflowSection(
                  repository: workflow!,
                  enquiryId: request.sourceEnquiryId,
                  focus: ServiceWorkflowStage.materialRequest,
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
              AppFormSection(
                title: l.servicesMaterialRequestDetailContext,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.servicesMaterialRequestInspection,
                      value: view.inspectionNumber,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesMaterialRequestJobAssignment,
                      value: view.assignmentNumber,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesMaterialRequestEnquiry,
                      value: view.enquiryNumber,
                      identifier: true,
                    ),
                    if ((request.jobOrderReference ?? '').isNotEmpty)
                      AppDetailField(
                        label: l.servicesMaterialRequestJobOrderReference,
                        value: request.jobOrderReference!,
                        identifier: true,
                      ),
                    AppDetailField(
                      label: l.servicesMaterialRequestCustomer,
                      value: view.customerName,
                    ),
                    if (view.customerMobile != null)
                      AppDetailField(
                        label: l.servicesEnquiryCustomerMobile,
                        value: view.customerMobile!,
                        identifier: true,
                      ),
                    if (view.partySnapshot.tenantName != null)
                      AppDetailField(
                        label: l.servicesMaterialRequestTenant,
                        value: view.partySnapshot.tenantName!,
                      ),
                    if (view.partySnapshot.buildingName != null)
                      AppDetailField(
                        label: l.servicesMaterialRequestBuilding,
                        value: view.partySnapshot.buildingName!,
                      ),
                    if (view.partySnapshot.unitNumber != null)
                      AppDetailField(
                        label: l.servicesMaterialRequestUnit,
                        value: view.partySnapshot.unitNumber!,
                      ),
                    AppDetailField(
                      label: l.servicesMaterialRequestMaterialReceived,
                      value: serviceMaterialReceivedLabel(
                        view.materialReceived,
                        l,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesMaterialRequestDetailMaterials,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (request.lines.isEmpty)
                      Text(l.servicesMaterialRequestNoMaterials)
                    else
                      AppDataTable(
                        columns: [
                          DataColumn(
                            label: Text(l.servicesMaterialRequestColumnItems),
                          ),
                          DataColumn(
                            label: Text(l.servicesMaterialRequestCode),
                          ),
                          DataColumn(
                            label: Text(l.servicesMaterialRequestDescription),
                          ),
                          DataColumn(
                            label: Text(l.servicesMaterialRequestBatchNumber),
                          ),
                          DataColumn(
                            label: Text(l.servicesMaterialRequestQuantity),
                          ),
                          DataColumn(
                            label: Text(l.servicesMaterialRequestRemark),
                          ),
                        ],
                        rows: [
                          for (var i = 0; i < request.lines.length; i++)
                            DataRow(
                              cells: [
                                DataCell(Text((i + 1).toString())),
                                DataCell(Text(request.lines[i].code)),
                                DataCell(Text(request.lines[i].description)),
                                DataCell(
                                  Text(request.lines[i].batchNumber ?? ''),
                                ),
                                DataCell(
                                  Text(
                                    formatMaterialQuantity(
                                      request.lines[i].quantity,
                                    ),
                                  ),
                                ),
                                DataCell(Text(request.lines[i].remark ?? '')),
                              ],
                            ),
                        ],
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    AppDetailsGrid(
                      fields: [
                        AppDetailField(
                          label: l.servicesMaterialRequestTotalQuantity,
                          value: formatMaterialQuantity(request.totalQuantity),
                        ),
                        AppDetailField(
                          label: l.servicesMaterialRequestColumnItems,
                          value: l.servicesMaterialRequestItemCount(
                            '${request.itemCount}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesMaterialRequestDetailAcknowledgement,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.servicesMaterialRequestAcknowledge,
                      value: request.acknowledgement ?? '',
                    ),
                    AppDetailField(
                      label: l.servicesMaterialRequestReceivedBy,
                      value: request.receivedBy ?? '',
                    ),
                    AppDetailField(
                      label: l.servicesMaterialRequestRemarks,
                      value: request.remarks ?? '',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.servicesMaterialRequestDetailAudit,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.servicesMaterialRequestDate,
                      value: dates.date(request.requestDate),
                    ),
                    AppDetailField(
                      label: l.servicesMaterialRequestPreparedBy,
                      value: request.createdByUserId,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesMaterialRequestCreatedAt,
                      value: dates.date(request.createdAt),
                    ),
                    AppDetailField(
                      label: l.servicesMaterialRequestUpdatedBy,
                      value: request.updatedByUserId,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.servicesMaterialRequestUpdatedAt,
                      value: dates.date(request.updatedAt),
                    ),
                    AppDetailField(
                      label: l.servicesMaterialRequestVersion,
                      value: '${request.version}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppSettingsSection(
                title: l.servicesMaterialRequestDetailActivity,
                children: [
                  if (state.activity.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(l.servicesMaterialRequestNoActivity),
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
