import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/access/presentation/bloc/permission_catalog_list_bloc.dart';
import 'package:modular_erp/platform/access/presentation/permission_master_configuration_repository.dart';
import 'package:modular_erp/shared/presentation/configuration_layouts.dart';

class PermissionCatalogListPage extends StatelessWidget {
  const PermissionCatalogListPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<PermissionCatalogListBloc, PermissionCatalogListState>(
        listener: (c, s) {
          if (s.statusSaved) {
            AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
          }
        },
        builder: (c, s) {
          final bloc = c.read<PermissionCatalogListBloc>();
          final l = c.l10n;
          return ConfigurationListLayout<PermissionMasterRecord>(
            title: l.permissionCatalogTitle,
            subtitle: l.permissionCatalogSubtitle,
            state: s,
            manage: bloc.context.user.permissions.contains(
              AppPermission.accessPermissionsManage,
            ),
            showAssigned: false,
            onSearch: (v) => bloc.add(RecordSearchChanged(v)),
            onStatus: (v) => bloc.add(RecordFilterChanged(v)),
            onPage: (v) => bloc.add(RecordPageChanged(v)),
            onCreate: () => c.go(AppRoutes.permissionCatalogNew),
            onRetry: () => bloc.add(const RecordListStarted()),
            detailRoute: AppRoutes.permissionCatalogDetails,
            editRoute: AppRoutes.permissionCatalogEdit,
            summaryLabel: l.permissionCatalogKey,
            summary: (c, record) => record.key,
            extraColumns: [DataColumn(label: Text(l.cfgDescription))],
            extraCells: (c, record) => [
              DataCell(
                Text(
                  record.description ?? l.noSelection,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            mobileDetails: (c, record) => record.description ?? l.noSelection,
            onActive: (id, active) =>
                bloc.add(RecordStatusRequested(id, active)),
          );
        },
      );
}
