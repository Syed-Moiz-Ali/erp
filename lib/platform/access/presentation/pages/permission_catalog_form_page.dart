import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/access/presentation/bloc/permission_catalog_form_bloc.dart';
import 'package:modular_erp/platform/access/presentation/permission_master_configuration_repository.dart';
import 'package:modular_erp/shared/navigation/form_navigation_guard.dart';
import 'package:modular_erp/shared/presentation/configuration_form_binding.dart';
import 'package:modular_erp/shared/presentation/configuration_layouts.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';

class PermissionCatalogFormPage extends StatelessWidget {
  const PermissionCatalogFormPage({super.key, required this.guard});

  final FormNavigationGuard guard;

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<PermissionCatalogFormBloc, PermissionCatalogFormState>(
        listener: (c, s) {
          if (s.savedId != null) {
            guard.dirty = false;
            guard.saving = false;
            AppFeedback.showMessage(c, message: (l) => l.cfgSaved);
            final canView = c
                .read<PermissionCatalogFormBloc>()
                .context
                .user
                .permissions
                .contains(AppPermission.accessUsersView);
            c.go(
              canView
                  ? AppRoutes.permissionCatalogDetails(s.savedId!)
                  : AppRoutes.dashboard,
            );
          }
        },
        builder: (c, s) {
          final l = c.l10n,
              bloc = c.read<PermissionCatalogFormBloc>(),
              d = s.draft;
          void change(
            PermissionMasterDraft Function(PermissionMasterDraft) update,
          ) => bloc.add(RecordDraftChanged<PermissionMasterDraft>(update));
          String? error(String field) => s.fieldErrors[field] == null
              ? null
              : configurationFailure(Failure(code: s.fieldErrors[field]!), l);
          return ConfigurationFormBinding(
            guard: guard,
            account: bloc.context,
            dirty: s.dirty,
            saving: s.saving,
            child: ConfigurationFormLayout(
              title: [
                l.permissionCatalogTitle,
                bloc.id == null ? l.cfgNew : l.cfgEdit,
              ].join(' · '),
              loading: s.loading,
              ready: s.ready,
              saving: s.saving,
              failure: s.failure,
              onSave: () async {
                if (bloc.id != null &&
                    s.original.status == ConfigurationStatus.active &&
                    d.status == ConfigurationStatus.inactive &&
                    !await confirmConfigurationStatus(
                      c,
                      false,
                      s.assignedEmployees,
                      showAssigned: false,
                    )) {
                  return;
                }
                if (c.mounted) {
                  bloc.add(const RecordSubmitted<PermissionMasterDraft>());
                }
              },
              onCancel: () => c.go(
                bloc.context.user.permissions.contains(
                      AppPermission.accessUsersView,
                    )
                    ? AppRoutes.permissionCatalog
                    : AppRoutes.dashboard,
              ),
              onRetry: () => bloc.add(
                s.validationRequested
                    ? const RecordSubmitted<PermissionMasterDraft>()
                    : const RecordFormInitialized<PermissionMasterDraft>(),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppFormSection(
                    title: l.cfgGeneralRules,
                    child: AppFormGrid(
                      spans: const [
                        AppFormSpan.half,
                        AppFormSpan.half,
                        AppFormSpan.full,
                      ],
                      children: [
                        AppTextField(
                          label: l.cfgName,
                          initialValue: d.name,
                          enabled: !s.saving,
                          required: true,
                          errorText: error('permissionName'),
                          onChanged: (v) => change((d) => d.copyWith(name: v)),
                        ),
                        AppTextField(
                          label: l.permissionCatalogKey,
                          initialValue: d.key,
                          enabled: !s.saving,
                          required: true,
                          helperText: l.permissionCatalogKeyHelper,
                          errorText: error('permissionKey'),
                          onChanged: (v) => change((d) => d.copyWith(key: v)),
                        ),
                        AppTextField(
                          label: l.cfgDescription,
                          initialValue: d.description,
                          enabled: !s.saving,
                          maxLines: 3,
                          errorText: error('description'),
                          onChanged: (v) => change(
                            (d) => v.isEmpty
                                ? d.copyWith(clearDescription: true)
                                : d.copyWith(description: v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppFormSection(
                    title: l.cfgStatus,
                    child: AppBooleanSettingRow(
                      label: l.cfgActive,
                      value: d.status != ConfigurationStatus.inactive,
                      onChanged: s.saving
                          ? null
                          : (value) => change(
                              (d) => d.copyWith(
                                status: value
                                    ? ConfigurationStatus.active
                                    : ConfigurationStatus.inactive,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          );
        },
      );
}
