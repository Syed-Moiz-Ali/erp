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
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/employees/presentation/employee_localization.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_repository.dart';
import 'package:modular_erp/modules/hr/leave/presentation/bloc/leave_configuration_blocs.dart';
import 'package:modular_erp/modules/hr/leave/presentation/leave_localization.dart';

class LeavePolicyListPage extends StatelessWidget {
  const LeavePolicyListPage({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<LeavePolicyListBloc, LeavePolicyListState>(
        listener: (c, s) {
          if (s.statusSaved) {
            AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
          }
        },
        builder: (c, s) {
          final bloc = c.read<LeavePolicyListBloc>();
          return ConfigurationListLayout<LeavePolicy>(
            title: c.l10n.leavePoliciesNav,
            subtitle: c.l10n.leavePolicyIntro,
            state: s,
            manage: bloc.context.user.permissions.contains(
              AppPermission.leavePolicyManage,
            ),
            onSearch: (v) => bloc.add(RecordSearchChanged(v)),
            onStatus: (v) => bloc.add(RecordFilterChanged(v)),
            onPage: (v) => bloc.add(RecordPageChanged(v)),
            onCreate: () => c.go(AppRoutes.leavePoliciesNew),
            onRetry: () => bloc.add(const RecordListStarted()),
            detailRoute: AppRoutes.leavePoliciesDetails,
            editRoute: AppRoutes.leavePoliciesEdit,
            summary: (c, record) => leavePolicySummary(record, c.l10n),
            summaryLabel: c.l10n.leavePolicyEntitlement,
            extraColumns: [
              DataColumn(label: Text(c.l10n.leavePolicyMinDays)),
              DataColumn(label: Text(c.l10n.leavePolicyAdvanceNotice)),
            ],
            extraCells: (c, record) => [
              DataCell(Text(leaveDaysCount(c, record.minimumRequestDays))),
              DataCell(Text(leaveDaysCount(c, record.advanceNoticeDays))),
            ],
            mobileDetails: (c, record) => [
              leaveDaysCount(c, record.minimumRequestDays),
              leaveDaysCount(c, record.advanceNoticeDays),
            ].join(' · '),
            onActive: (id, active) =>
                bloc.add(RecordStatusRequested(id, active)),
          );
        },
      );
}

class LeavePolicyFormPage extends StatelessWidget {
  const LeavePolicyFormPage({
    super.key,
    required this.guard,
    required this.repository,
  });
  final FormNavigationGuard guard;
  final LeaveRepository repository;
  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<LeavePolicyFormBloc, LeavePolicyFormState>(
    listener: (c, s) {
      if (s.savedId != null) {
        guard.dirty = false;
        guard.saving = false;
        AppFeedback.showMessage(c, message: (l) => l.cfgSaved);
        c.go(AppRoutes.leavePoliciesDetails(s.savedId!));
      }
    },
    builder: (c, s) {
      final l = c.l10n, bloc = c.read<LeavePolicyFormBloc>(), d = s.draft;
      void change(LeavePolicyDraft Function(LeavePolicyDraft) update) =>
          bloc.add(RecordDraftChanged<LeavePolicyDraft>(update));
      void toggleEmployment(EmploymentType type, bool selected) => change((d) {
        final next = {...d.applicableEmploymentTypes};
        if (selected) {
          next.add(type);
        } else {
          next.remove(type);
        }
        return d.copyWith(applicableEmploymentTypes: next);
      });
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
            l.leavePoliciesNav,
            bloc.id == null ? l.cfgNew : l.cfgEdit,
          ].join(' · '),
          loading: s.loading,
          ready: s.ready,
          saving: s.saving,
          failure: s.failure,
          onSave: () {
            if (c.mounted) {
              bloc.add(const RecordSubmitted<LeavePolicyDraft>());
            }
          },
          onCancel: () => c.go(AppRoutes.leavePolicies),
          onRetry: () => bloc.add(
            s.validationRequested
                ? const RecordSubmitted<LeavePolicyDraft>()
                : const RecordFormInitialized<LeavePolicyDraft>(),
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
                    StreamBuilder<Result<List<LeaveType>>>(
                      stream: repository.watchLeaveTypes(bloc.context),
                      builder: (c, snapshot) {
                        final types = snapshot.data is Success<List<LeaveType>>
                            ? (snapshot.data as Success<List<LeaveType>>).value
                            : const <LeaveType>[];
                        return AppSelectField<String>(
                          label: l.leavePolicyLeaveType,
                          value: d.leaveTypeId.isEmpty ? null : d.leaveTypeId,
                          enabled: !s.saving,
                          errorText: error('leaveTypeId'),
                          options: [
                            for (final type in types)
                              AppSelectOption(type.id, type.name),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              change((d) => d.copyWith(leaveTypeId: v));
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.leavePolicyEntitlement,
                child: AppFormGrid(
                  children: [
                    AppNumberField(
                      label: l.leavePolicyEntitlement,
                      initialValue: d.annualEntitlementDays,
                      enabled: !s.saving,
                      errorText: error('annualEntitlementDays'),
                      suffix: l.days,
                      onChanged: (v) => change(
                        (d) => d.copyWith(annualEntitlementDays: v.value ?? 0),
                      ),
                    ),
                    AppNumberField(
                      label: l.leavePolicyMinDays,
                      initialValue: d.minimumRequestDays,
                      enabled: !s.saving,
                      errorText: error('minimumRequestDays'),
                      suffix: l.days,
                      onChanged: (v) => change(
                        (d) => d.copyWith(minimumRequestDays: v.value ?? 0),
                      ),
                    ),
                    AppNumberField(
                      label: l.leavePolicyMaxConsecutive,
                      initialValue: d.maximumConsecutiveDays,
                      enabled: !s.saving,
                      integerOnly: true,
                      suffix: l.days,
                      onChanged: (v) => change(
                        (d) => d.copyWith(
                          maximumConsecutiveDays: v.optionalInteger,
                        ),
                      ),
                    ),
                    AppNumberField(
                      label: l.leavePolicyAdvanceNotice,
                      initialValue: d.advanceNoticeDays,
                      enabled: !s.saving,
                      integerOnly: true,
                      errorText: error('advanceNoticeDays'),
                      suffix: l.days,
                      onChanged: (v) => change(
                        (d) => d.copyWith(advanceNoticeDays: v.integer),
                      ),
                    ),
                    AppNumberField(
                      label: l.leavePolicyPastWindow,
                      initialValue: d.pastRequestWindowDays,
                      enabled: !s.saving,
                      integerOnly: true,
                      suffix: l.days,
                      onChanged: (v) => change(
                        (d) => d.copyWith(pastRequestWindowDays: v.integer),
                      ),
                    ),
                    AppNumberField(
                      label: l.leavePolicyCarryLimit,
                      initialValue: d.carryForwardLimitDays,
                      enabled: !s.saving,
                      suffix: l.days,
                      onChanged: (v) => change(
                        (d) => d.copyWith(carryForwardLimitDays: v.optional),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.leavePolicy,
                child: AppFormGrid(
                  children: [
                    AppSwitchField(
                      label: l.leaveAllowsHalfDay,
                      value: d.allowHalfDay,
                      onChanged: s.saving
                          ? null
                          : (v) => change((d) => d.copyWith(allowHalfDay: v)),
                    ),
                    AppSwitchField(
                      label: l.leavePolicyAllowPast,
                      value: d.allowPastRequest,
                      onChanged: s.saving
                          ? null
                          : (v) =>
                                change((d) => d.copyWith(allowPastRequest: v)),
                    ),
                    AppSwitchField(
                      label: l.leavePolicyNegative,
                      value: d.allowNegativeBalance,
                      onChanged: s.saving
                          ? null
                          : (v) => change(
                              (d) => d.copyWith(allowNegativeBalance: v),
                            ),
                    ),
                    AppSwitchField(
                      label: l.leavePolicyCarryForward,
                      value: d.carryForwardEnabled,
                      onChanged: s.saving
                          ? null
                          : (v) => change(
                              (d) => d.copyWith(carryForwardEnabled: v),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.leavePolicyEmployment,
                child: AppFormGrid(
                  children: [
                    for (final type in EmploymentType.values)
                      AppSwitchField(
                        label: employmentTypeLabel(type, l),
                        value: d.applicableEmploymentTypes.contains(type),
                        onChanged: s.saving
                            ? null
                            : (v) => toggleEmployment(type, v),
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

class LeavePolicyDetailsPage extends StatelessWidget {
  const LeavePolicyDetailsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<LeavePolicyDetailsBloc, LeavePolicyDetailsState>(
        listener: (c, s) {
          if (s.statusSaved) {
            AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
          }
        },
        builder: (context, s) {
          final l = context.l10n, bloc = context.read<LeavePolicyDetailsBloc>();
          return ConfigurationDetailsLayout<LeavePolicy>(
            title: l.leavePoliciesNav,
            state: s,
            manage: bloc.context.user.permissions.contains(
              AppPermission.leavePolicyManage,
            ),
            onRetry: () => bloc.add(const RecordDetailsStarted()),
            onEdit: () => context.push(AppRoutes.leavePoliciesEdit(bloc.id)),
            onActive: (v) => bloc.add(RecordDetailsStatusRequested(v)),
            content: (record) => AppFormSection(
              title: l.leavePolicy,
              child: AppDetailsGrid(
                fields: [
                  AppDetailField(
                    label: l.cfgCode,
                    value: record.code,
                    identifier: true,
                  ),
                  AppDetailField(
                    label: l.leavePolicyEntitlement,
                    value: '${record.annualEntitlementDays} ${l.days}',
                  ),
                  AppDetailField(
                    label: l.leavePolicyMinDays,
                    value: '${record.minimumRequestDays} ${l.days}',
                  ),
                  if (record.maximumConsecutiveDays != null)
                    AppDetailField(
                      label: l.leavePolicyMaxConsecutive,
                      value: '${record.maximumConsecutiveDays} ${l.days}',
                    ),
                  AppDetailField(
                    label: l.leavePolicyAdvanceNotice,
                    value: '${record.advanceNoticeDays} ${l.days}',
                  ),
                  AppDetailField(
                    label: l.leavePolicyAllowPast,
                    value: record.allowPastRequest
                        ? l.cfgActive
                        : l.cfgInactive,
                  ),
                  AppDetailField(
                    label: l.leavePolicyNegative,
                    value: record.allowNegativeBalance
                        ? l.cfgActive
                        : l.cfgInactive,
                  ),
                  AppDetailField(
                    label: l.leavePolicyCarryForward,
                    value: record.carryForwardEnabled
                        ? '${record.carryForwardLimitDays ?? 0} ${l.days}'
                        : l.cfgInactive,
                  ),
                  AppDetailField(
                    label: l.leaveAllowsHalfDay,
                    value: record.allowHalfDay ? l.cfgActive : l.cfgInactive,
                  ),
                ],
              ),
            ),
          );
        },
      );
}
