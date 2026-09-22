import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/models/configuration_record.dart';
import '../../../../core/security/app_permission.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/navigation/form_navigation_guard.dart';
import '../../../../shared/presentation/configuration_form_binding.dart';
import '../../../../shared/presentation/configuration_layouts.dart';
import '../../../../shared/presentation/configuration_localization.dart';
import '../../domain/leave_models.dart';
import '../bloc/leave_configuration_blocs.dart';
import '../leave_localization.dart';

class LeaveTypeListPage extends StatelessWidget {
  const LeaveTypeListPage({super.key});
  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<LeaveTypeListBloc, LeaveTypeListState>(
    listener: (c, s) {
      if (s.statusSaved) {
        AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
      }
    },
    builder: (c, s) {
      final bloc = c.read<LeaveTypeListBloc>();
      return ConfigurationListLayout<LeaveType>(
        title: c.l10n.leaveTypesNav,
        subtitle: c.l10n.leaveTypeIntro,
        state: s,
        manage: bloc.context.user.permissions.contains(
          AppPermission.leaveTypeManage,
        ),
        onSearch: (v) => bloc.add(RecordSearchChanged(v)),
        onStatus: (v) => bloc.add(RecordFilterChanged(v)),
        onPage: (v) => bloc.add(RecordPageChanged(v)),
        onCreate: () => c.go(AppRoutes.leaveTypesNew),
        onRetry: () => bloc.add(const RecordListStarted()),
        detailRoute: AppRoutes.leaveTypesDetails,
        editRoute: AppRoutes.leaveTypesEdit,
        summary: (c, record) => leaveTypeSummary(record, c.l10n),
        summaryLabel: c.l10n.leaveCompensation,
        extraColumns: [
          DataColumn(label: Text(c.l10n.leaveAllowsHalfDay)),
          DataColumn(label: Text(c.l10n.leaveRequiresReason)),
        ],
        extraCells: (c, record) => [
          DataCell(
            Text(record.allowsHalfDay ? c.l10n.cfgActive : c.l10n.cfgInactive),
          ),
          DataCell(
            Text(record.requiresReason ? c.l10n.cfgActive : c.l10n.cfgInactive),
          ),
        ],
        mobileDetails: (c, record) => [
          record.allowsHalfDay ? c.l10n.leaveAllowsHalfDay : '',
          record.requiresReason ? c.l10n.leaveRequiresReason : '',
        ].where((e) => e.isNotEmpty).join(' · '),
        onActive: (id, active) => bloc.add(RecordStatusRequested(id, active)),
      );
    },
  );
}

class LeaveTypeFormPage extends StatelessWidget {
  const LeaveTypeFormPage({super.key, required this.guard});
  final FormNavigationGuard guard;
  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<LeaveTypeFormBloc, LeaveTypeFormState>(
    listener: (c, s) {
      if (s.savedId != null) {
        guard.dirty = false;
        guard.saving = false;
        AppFeedback.showMessage(c, message: (l) => l.cfgSaved);
        c.go(AppRoutes.leaveTypesDetails(s.savedId!));
      }
    },
    builder: (c, s) {
      final l = c.l10n, bloc = c.read<LeaveTypeFormBloc>(), d = s.draft;
      void change(LeaveTypeDraft Function(LeaveTypeDraft) update) =>
          bloc.add(RecordDraftChanged<LeaveTypeDraft>(update));
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
            l.leaveTypesNav,
            bloc.id == null ? l.cfgNew : l.cfgEdit,
          ].join(' · '),
          loading: s.loading,
          ready: s.ready,
          saving: s.saving,
          failure: s.failure,
          onSave: () {
            if (c.mounted) {
              bloc.add(const RecordSubmitted<LeaveTypeDraft>());
            }
          },
          onCancel: () => c.go(AppRoutes.leaveTypes),
          onRetry: () => bloc.add(
            s.validationRequested
                ? const RecordSubmitted<LeaveTypeDraft>()
                : const RecordFormInitialized<LeaveTypeDraft>(),
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
                    AppTextField(
                      label: l.cfgCode,
                      initialValue: d.code,
                      enabled: !s.saving,
                      errorText: error('code'),
                      onChanged: (v) => change((d) => d.copyWith(code: v)),
                    ),
                    AppSelectField<LeaveCompensationType>(
                      label: l.leaveCompensation,
                      value: d.compensation,
                      enabled: !s.saving,
                      options: [
                        for (final value in LeaveCompensationType.values)
                          AppSelectOption(
                            value,
                            leaveCompensationLabel(value, l),
                          ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          change((d) => d.copyWith(compensation: v));
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.cfgDescription,
                child: AppTextField(
                  label: l.cfgDescription,
                  initialValue: d.description,
                  enabled: !s.saving,
                  maxLines: 3,
                  onChanged: (v) => change((d) => d.copyWith(description: v)),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.cfgGeneralRules,
                child: AppFormGrid(
                  children: [
                    AppSwitchField(
                      label: l.leaveRequiresApproval,
                      value: d.requiresApproval,
                      onChanged: s.saving
                          ? null
                          : (v) =>
                                change((d) => d.copyWith(requiresApproval: v)),
                    ),
                    AppSwitchField(
                      label: l.leaveAllowsHalfDay,
                      value: d.allowsHalfDay,
                      onChanged: s.saving
                          ? null
                          : (v) => change((d) => d.copyWith(allowsHalfDay: v)),
                    ),
                    AppSwitchField(
                      label: l.leaveRequiresReason,
                      value: d.requiresReason,
                      onChanged: s.saving
                          ? null
                          : (v) => change((d) => d.copyWith(requiresReason: v)),
                    ),
                    AppSwitchField(
                      label: l.leaveRequiresAttachment,
                      value: d.requiresAttachment,
                      onChanged: s.saving
                          ? null
                          : (v) => change(
                              (d) => d.copyWith(requiresAttachment: v),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.cfgStatus,
                child: AppSwitchField(
                  label: l.cfgActive,
                  value: d.status == ConfigurationStatus.active,
                  onChanged: s.saving
                      ? null
                      : (v) => change(
                          (d) => d.copyWith(
                            status: v
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

class LeaveTypeDetailsPage extends StatelessWidget {
  const LeaveTypeDetailsPage({super.key});
  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<LeaveTypeDetailsBloc, LeaveTypeDetailsState>(
    listener: (c, s) {
      if (s.statusSaved) {
        AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
      }
    },
    builder: (context, s) {
      final l = context.l10n, bloc = context.read<LeaveTypeDetailsBloc>();
      return ConfigurationDetailsLayout<LeaveType>(
        title: l.leaveTypesNav,
        state: s,
        manage: bloc.context.user.permissions.contains(
          AppPermission.leaveTypeManage,
        ),
        onRetry: () => bloc.add(const RecordDetailsStarted()),
        onEdit: () => context.push(AppRoutes.leaveTypesEdit(bloc.id)),
        onActive: (v) => bloc.add(RecordDetailsStatusRequested(v)),
        content: (record) => AppFormSection(
          title: l.cfgGeneralRules,
          child: AppDetailsGrid(
            fields: [
              AppDetailField(
                label: l.cfgCode,
                value: record.code,
                identifier: true,
              ),
              AppDetailField(
                label: l.leaveCompensation,
                value: leaveCompensationLabel(record.compensation, l),
              ),
              if (record.description.isNotEmpty)
                AppDetailField(
                  label: l.cfgDescription,
                  value: record.description,
                ),
              AppDetailField(
                label: l.leaveRequiresApproval,
                value: record.requiresApproval ? l.cfgActive : l.cfgInactive,
              ),
              AppDetailField(
                label: l.leaveAllowsHalfDay,
                value: record.allowsHalfDay ? l.cfgActive : l.cfgInactive,
              ),
              AppDetailField(
                label: l.leaveRequiresReason,
                value: record.requiresReason ? l.cfgActive : l.cfgInactive,
              ),
              AppDetailField(
                label: l.leaveRequiresAttachment,
                value: record.requiresAttachment ? l.cfgActive : l.cfgInactive,
              ),
            ],
          ),
        ),
      );
    },
  );
}
