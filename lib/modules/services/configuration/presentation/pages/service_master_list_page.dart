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

String serviceMasterTitle(AppLocalizations l, ServiceMasterKind kind) =>
    switch (kind) {
      ServiceMasterKind.serviceType => l.servicesServiceTypesTitle,
      ServiceMasterKind.complaintType => l.servicesComplaintTypesTitle,
      ServiceMasterKind.priority => l.servicesPrioritiesTitle,
      ServiceMasterKind.ticketType => l.servicesTicketTypesTitle,
    };

AppPermission serviceMasterManagePermission(ServiceMasterKind kind) =>
    switch (kind) {
      ServiceMasterKind.serviceType => AppPermission.serviceTypeManage,
      ServiceMasterKind.complaintType => AppPermission.complaintTypeManage,
      ServiceMasterKind.priority => AppPermission.servicePriorityManage,
      ServiceMasterKind.ticketType => AppPermission.serviceTicketTypeManage,
    };

String _newRoute(ServiceMasterKind kind) => switch (kind) {
  ServiceMasterKind.serviceType => ServicesRoutes.serviceTypesNew,
  ServiceMasterKind.complaintType => ServicesRoutes.complaintTypesNew,
  ServiceMasterKind.priority => ServicesRoutes.prioritiesNew,
  ServiceMasterKind.ticketType => ServicesRoutes.ticketTypesNew,
};

String _editRoute(ServiceMasterKind kind, String id) => switch (kind) {
  ServiceMasterKind.serviceType => ServicesRoutes.serviceTypeEdit(id),
  ServiceMasterKind.complaintType => ServicesRoutes.complaintTypeEdit(id),
  ServiceMasterKind.priority => ServicesRoutes.priorityEdit(id),
  ServiceMasterKind.ticketType => ServicesRoutes.ticketTypeEdit(id),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 320,
                child: AppSearchField(
                  hint: l.servicesMasterSearch,
                  onChanged: (v) =>
                      context.read<ServiceMasterListCubit>().search(v),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (state.loading && state.page == null)
                const AppConfigurationSkeleton()
              else if (state.failure != null)
                AppErrorState(
                  message: l.servicesMasterStorageError,
                  onRetry: () => context.read<ServiceMasterListCubit>().start(),
                )
              else if (items.isEmpty)
                AppEmptyState(
                  title: l.servicesMasterEmpty,
                  message: l.servicesSettingsSubtitle,
                )
              else if (AppBreakpoints.of(context) == AppSize.compact)
                Column(
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
                          onTap: () => context.go(_editRoute(kind, item.id)),
                        ),
                      ),
                  ],
                )
              else
                AppDataTable(
                  columns: [
                    DataColumn(label: Text(l.servicesMasterCode)),
                    DataColumn(label: Text(l.servicesMasterName)),
                    DataColumn(label: Text(l.status)),
                    DataColumn(label: Text(l.actions)),
                  ],
                  rows: [
                    for (final item in items)
                      DataRow(
                        cells: [
                          DataCell(Text(item.code)),
                          DataCell(Text(item.name)),
                          DataCell(
                            AppStatusBadge(
                              label: item.status == ConfigurationStatus.active
                                  ? l.active
                                  : l.inactive,
                              status: item.status == ConfigurationStatus.active
                                  ? AppStatus.success
                                  : AppStatus.neutral,
                              isPill: true,
                            ),
                          ),
                          DataCell(
                            AppTextButton(
                              label: l.servicesEditMaster,
                              onPressed: () =>
                                  context.go(_editRoute(kind, item.id)),
                            ),
                          ),
                        ],
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
