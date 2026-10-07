import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master.dart';
import 'package:modular_erp/modules/services/configuration/presentation/bloc/service_master_blocs.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

const String _emDash = '\u2014';

String serviceMasterTitle(AppLocalizations l, ServiceMasterKind kind) =>
    switch (kind) {
      ServiceMasterKind.serviceType => l.servicesServiceTypesTitle,
      ServiceMasterKind.complaintType => l.servicesComplaintTypesTitle,
      ServiceMasterKind.priority => l.servicesPrioritiesTitle,
      ServiceMasterKind.ticketType => l.servicesTicketTypesTitle,
      ServiceMasterKind.rootCause => l.servicesRootCausesTitle,
      ServiceMasterKind.chargeResponsibility =>
        l.servicesChargeResponsibilitiesTitle,
      ServiceMasterKind.materialRequestPurpose =>
        l.servicesMaterialRequestPurposesTitle,
    };

AppPermission serviceMasterManagePermission(ServiceMasterKind kind) =>
    switch (kind) {
      ServiceMasterKind.serviceType => AppPermission.serviceTypeManage,
      ServiceMasterKind.complaintType => AppPermission.complaintTypeManage,
      ServiceMasterKind.priority => AppPermission.servicePriorityManage,
      ServiceMasterKind.ticketType => AppPermission.serviceTicketTypeManage,
      ServiceMasterKind.rootCause => AppPermission.serviceRootCauseManage,
      ServiceMasterKind.chargeResponsibility =>
        AppPermission.serviceChargeResponsibilityManage,
      ServiceMasterKind.materialRequestPurpose =>
        AppPermission.serviceMaterialRequestPurposeManage,
    };

String _newRoute(ServiceMasterKind kind) => switch (kind) {
  ServiceMasterKind.serviceType => ServicesRoutes.serviceTypesNew,
  ServiceMasterKind.complaintType => ServicesRoutes.complaintTypesNew,
  ServiceMasterKind.priority => ServicesRoutes.prioritiesNew,
  ServiceMasterKind.ticketType => ServicesRoutes.ticketTypesNew,
  ServiceMasterKind.rootCause => ServicesRoutes.rootCausesNew,
  ServiceMasterKind.chargeResponsibility =>
    ServicesRoutes.chargeResponsibilitiesNew,
  ServiceMasterKind.materialRequestPurpose =>
    ServicesRoutes.materialRequestPurposesNew,
};

String _editRoute(ServiceMasterKind kind, String id) => switch (kind) {
  ServiceMasterKind.serviceType => ServicesRoutes.serviceTypeEdit(id),
  ServiceMasterKind.complaintType => ServicesRoutes.complaintTypeEdit(id),
  ServiceMasterKind.priority => ServicesRoutes.priorityEdit(id),
  ServiceMasterKind.ticketType => ServicesRoutes.ticketTypeEdit(id),
  ServiceMasterKind.rootCause => ServicesRoutes.rootCauseEdit(id),
  ServiceMasterKind.chargeResponsibility =>
    ServicesRoutes.chargeResponsibilityEdit(id),
  ServiceMasterKind.materialRequestPurpose =>
    ServicesRoutes.materialRequestPurposeEdit(id),
};

/// Read-only detail route for users who may view but not manage.
String _detailRoute(ServiceMasterKind kind, String id) => switch (kind) {
  ServiceMasterKind.serviceType => ServicesRoutes.serviceType(id),
  ServiceMasterKind.complaintType => ServicesRoutes.complaintType(id),
  ServiceMasterKind.priority => ServicesRoutes.priority(id),
  ServiceMasterKind.ticketType => ServicesRoutes.ticketType(id),
  ServiceMasterKind.rootCause => ServicesRoutes.rootCause(id),
  ServiceMasterKind.chargeResponsibility => ServicesRoutes.chargeResponsibility(
    id,
  ),
  ServiceMasterKind.materialRequestPurpose =>
    ServicesRoutes.materialRequestPurpose(id),
};

class ServiceMasterListPage extends StatelessWidget {
  const ServiceMasterListPage({super.key, required this.kind});
  final ServiceMasterKind kind;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final permissions = context
        .read<AuthBloc>()
        .state
        .context
        ?.user
        .permissions;
    final canManage =
        permissions?.contains(serviceMasterManagePermission(kind)) ?? false;
    return BlocBuilder<ServiceMasterListCubit, ServiceMasterListState>(
      builder: (context, state) {
        final items = state.page?.items ?? const <ServiceMasterRecord>[];
        return AppPage(
          header: AppPageHeader(
            title: serviceMasterTitle(l, kind),
            actions: [
              if (canManage)
                AppPrimaryButton(
                  label: l.servicesAddMaster,
                  icon: Icons.add,
                  onPressed: () => context.go(_newRoute(kind)),
                ),
            ],
          ),
          filters: AppCollectionToolbar(
            search: AppSearchField(
              hint: l.servicesMasterSearch,
              onChanged: (v) =>
                  context.read<ServiceMasterListCubit>().search(v),
            ),
            resultCount: AppResultCount(
              filtered: state.page?.filtered ?? 0,
              total: state.page?.total,
            ),
          ),
          child: Builder(
            builder: (context) {
              final searching = state.query.trim().isNotEmpty;
              Widget body;
              if (state.loading && state.page == null) {
                body = const AppCollectionSkeleton();
              } else if (state.failure != null && state.page == null) {
                body = AppErrorState(
                  message: l.servicesMasterStorageError,
                  onRetry: () => context.read<ServiceMasterListCubit>().start(),
                );
              } else if (items.isEmpty) {
                final empty = (state.page?.total ?? 0) == 0 && !searching;
                body = empty
                    ? AppCollectionEmptyState.noData(
                        title: l.servicesMasterEmpty,
                        message: l.servicesSettingsSubtitle,
                        actionLabel: canManage ? l.servicesAddMaster : null,
                        onAction: () => context.go(_newRoute(kind)),
                      )
                    : AppCollectionEmptyState.noResults(
                        title: l.servicesMasterNoResults,
                        message: l.servicesMasterNoResults,
                        onClearFilters: () =>
                            context.read<ServiceMasterListCubit>().search(''),
                      );
              } else if (AppBreakpoints.of(context) == AppSize.compact) {
                body = Column(
                  children: [
                    for (final item in items)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          bottom: AppSpacing.md,
                        ),
                        child: AppMobileRecordCard(
                          title: item.name,
                          subtitle: item.code,
                          status: item.status == ConfigurationStatus.active
                              ? AppStatus.success
                              : AppStatus.neutral,
                          statusLabel: item.status == ConfigurationStatus.active
                              ? l.active
                              : l.inactive,
                          metrics: [
                            if (item.isDefault)
                              (label: l.servicesMasterDefault, value: l.yes),
                          ],
                          onTap: () => context.go(
                            canManage
                                ? _editRoute(kind, item.id)
                                : _detailRoute(kind, item.id),
                          ),
                        ),
                      ),
                  ],
                );
              } else {
                body = AppCollectionSurface(
                  child: AppDataTable(
                    columns: [
                      DataColumn(label: Text(l.servicesMasterName)),
                      DataColumn(label: Text(l.servicesMasterCode)),
                      DataColumn(label: Text(l.servicesMasterSortOrder)),
                      DataColumn(label: Text(l.servicesMasterDefault)),
                      DataColumn(label: Text(l.status)),
                      DataColumn(
                        label: Semantics(
                          label: l.actions,
                          child: const Icon(Icons.more_horiz),
                        ),
                      ),
                    ],
                    rows: [
                      for (final item in items)
                        DataRow(
                          onSelectChanged: (_) => context.go(
                            canManage
                                ? _editRoute(kind, item.id)
                                : _detailRoute(kind, item.id),
                          ),
                          cells: [
                            DataCell(
                              Text(
                                item.name,
                                style: AppTypography.of(context).label,
                              ),
                            ),
                            DataCell(
                              Text(
                                item.code,
                                textDirection: TextDirection.ltr,
                                style: AppTypography.of(context).code,
                              ),
                            ),
                            DataCell(
                              Text(
                                item.sortOrder.toString(),
                                style: AppTypography.of(context).tableCell,
                              ),
                            ),
                            DataCell(
                              item.isDefault
                                  ? AppStatusBadge(
                                      label: l.servicesMasterDefault,
                                      status: AppStatus.brand,
                                      isPill: true,
                                    )
                                  : const Text(_emDash),
                            ),
                            DataCell(
                              AppStatusBadge(
                                label: item.status == ConfigurationStatus.active
                                    ? l.active
                                    : l.inactive,
                                status:
                                    item.status == ConfigurationStatus.active
                                    ? AppStatus.success
                                    : AppStatus.neutral,
                                isPill: true,
                              ),
                            ),
                            DataCell(
                              AppActionMenu(
                                tooltip: l.actions,
                                actions: [
                                  AppMenuAction(
                                    label: (l) => canManage
                                        ? l.servicesEditMaster
                                        : l.servicesViewMaster,
                                    onPressed: () => context.go(
                                      canManage
                                          ? _editRoute(kind, item.id)
                                          : _detailRoute(kind, item.id),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              }
              return body;
            },
          ),
        );
      },
    );
  }
}
