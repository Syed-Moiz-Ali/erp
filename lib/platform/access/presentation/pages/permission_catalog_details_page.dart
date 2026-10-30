import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/access/presentation/bloc/permission_catalog_details_bloc.dart';
import 'package:modular_erp/platform/access/presentation/permission_master_configuration_repository.dart';
import 'package:modular_erp/shared/presentation/configuration_layouts.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';

class PermissionCatalogDetailsPage extends StatelessWidget {
  const PermissionCatalogDetailsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<PermissionCatalogDetailsBloc, PermissionCatalogDetailsState>(
        listener: (c, s) {
          if (s.statusSaved) {
            AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
          }
        },
        builder: (context, s) {
          final l = context.l10n,
              bloc = context.read<PermissionCatalogDetailsBloc>();
          return ConfigurationDetailsLayout<PermissionMasterRecord>(
            title: l.permissionCatalogTitle,
            state: s,
            manage: bloc.context.user.permissions.contains(
              AppPermission.accessPermissionsManage,
            ),
            showAssigned: false,
            onRetry: () => bloc.add(const RecordDetailsStarted()),
            onEdit: () =>
                context.push(AppRoutes.permissionCatalogEdit(bloc.id)),
            onActive: (v) => bloc.add(RecordDetailsStatusRequested(v)),
            content: (record) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFormSection(
                  title: l.cfgGeneralRules,
                  child: AppDetailsGrid(
                    fields: [
                      AppDetailField(label: l.cfgName, value: record.name),
                      AppDetailField(
                        label: l.permissionCatalogKey,
                        value: record.key,
                        identifier: true,
                      ),
                      AppDetailField(
                        label: l.cfgDescription,
                        value: record.description ?? l.noSelection,
                      ),
                      AppDetailField(
                        label: l.cfgStatus,
                        value: configurationStatusLabel(record.status, l),
                      ),
                    ],
                  ),
                ),
                if (record.createdOn != null || record.modifiedOn != null) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  AppFormSection(
                    title: l.permissionCatalogMetadata,
                    child: AppDetailsGrid(
                      fields: [
                        if (record.createdOn != null)
                          AppDetailField(
                            label: l.permissionCatalogCreated,
                            value: configurationDate(
                              context,
                              record.createdOn!,
                            ),
                            identifier: true,
                          ),
                        if (record.modifiedOn != null)
                          AppDetailField(
                            label: l.permissionCatalogModified,
                            value: configurationDate(
                              context,
                              record.modifiedOn!,
                            ),
                            identifier: true,
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
