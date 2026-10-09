import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/shared/navigation/form_navigation_guard.dart';
import 'package:modular_erp/shared/presentation/configuration_form_binding.dart';
import 'package:modular_erp/shared/presentation/configuration_layouts.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';
import 'package:modular_erp/modules/hr/departments/domain/department.dart';
import 'package:modular_erp/modules/hr/departments/presentation/bloc/department_form_bloc.dart';

class DepartmentFormPage extends StatelessWidget {
  const DepartmentFormPage({super.key, required this.guard});
  final FormNavigationGuard guard;

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<DepartmentFormBloc, DepartmentFormState>(
        listener: (c, s) {
          if (s.savedId != null) {
            guard.dirty = false;
            guard.saving = false;
            AppFeedback.showMessage(c, message: (l) => l.cfgSaved);
            c.go(
              c.read<DepartmentFormBloc>().context.user.permissions.contains(
                    AppPermission.departmentView,
                  )
                  ? AppRoutes.departmentsDetails(s.savedId!)
                  : AppRoutes.dashboard,
            );
          }
        },
        builder: (c, s) {
          final l = c.l10n, bloc = c.read<DepartmentFormBloc>(), d = s.draft;
          void change(DepartmentDraft Function(DepartmentDraft) update) =>
              bloc.add(RecordDraftChanged<DepartmentDraft>(update));
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
                l.cfgDepartments,
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
                    )) {
                  return;
                }
                if (c.mounted) {
                  bloc.add(const RecordSubmitted<DepartmentDraft>());
                }
              },
              onCancel: () => c.go(
                bloc.context.user.permissions.contains(
                      AppPermission.departmentView,
                    )
                    ? AppRoutes.departments
                    : AppRoutes.dashboard,
              ),
              onRetry: () => bloc.add(
                s.validationRequested
                    ? const RecordSubmitted<DepartmentDraft>()
                    : const RecordFormInitialized<DepartmentDraft>(),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppFormSection(
                    title: l.cfgGeneralRules,
                    child: AppFormGrid(
                      children: [
                        AppTextField(
                          label: l.cfgName,
                          initialValue: d.name,
                          enabled: !s.saving,
                          errorText: error('name'),
                          onChanged: (v) => change((d) => d.copyWith(name: v)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppFormSection(
                    title: l.cfgStatus,
                    child: AppBooleanSettingRow(
                      label: l.cfgActive,
                      value: d.status == ConfigurationStatus.active,
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
