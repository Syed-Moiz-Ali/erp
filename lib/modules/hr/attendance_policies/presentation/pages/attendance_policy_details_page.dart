import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/shared/presentation/configuration_layouts.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy.dart';
import 'package:modular_erp/modules/hr/attendance_policies/presentation/bloc/attendance_policy_details_bloc.dart';

class AttendancePolicyDetailsPage extends StatelessWidget {
  const AttendancePolicyDetailsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<AttendancePolicyDetailsBloc, AttendancePolicyDetailsState>(
        listener: (c, s) {
          if (s.statusSaved) {
            AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
          }
        },
        builder: (context, s) {
          final l = context.l10n,
              bloc = context.read<AttendancePolicyDetailsBloc>();
          return ConfigurationDetailsLayout<AttendancePolicy>(
            title: l.cfgPolicies,
            state: s,
            manage: bloc.context.user.permissions.contains(
              AppPermission.attendancePolicyManage,
            ),
            onRetry: () => bloc.add(const RecordDetailsStarted()),
            onEdit: () =>
                context.push(AppRoutes.attendancePoliciesEdit(bloc.id)),
            onActive: (v) => bloc.add(RecordDetailsStatusRequested(v)),
            content: (record) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFormSection(
                  title: l.cfgGeneralRules,
                  child: AppDetailsGrid(
                    fields: [
                      AppDetailField(
                        label: l.cfgDescription,
                        value: record.description.isEmpty
                            ? l.noSelection
                            : record.description,
                      ),
                      AppDetailField(
                        label: l.cfgCorrections,
                        value: record.allowEmployeeCorrectionRequest
                            ? l.cfgYes
                            : l.cfgNo,
                      ),
                      AppDetailField(
                        label: l.cfgRemote,
                        value: record.allowRemoteAttendance
                            ? l.cfgYes
                            : l.cfgNo,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppFormSection(
                  title: l.cfgLocationRules,
                  child: AppDetailsGrid(
                    fields: [
                      AppDetailField(
                        label: l.cfgLocationRules,
                        value: policyLocationSummary(record, l),
                      ),
                      if (record.maximumAcceptedAccuracyMeters != null)
                        AppDetailField(
                          label: l.cfgAccuracy,
                          value: [
                            configurationNumber(
                              context,
                              record.maximumAcceptedAccuracyMeters!,
                            ),
                            l.cfgMeters,
                          ].join(' '),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppFormSection(
                  title: l.cfgBreakRules,
                  child: Text(policyBreakSummary(record, l)),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppFormSection(
                  title: l.cfgTimingRules,
                  child: AppDetailsGrid(
                    fields: [
                      AppDetailField(
                        label: l.cfgEarlyIn,
                        value: record.allowEarlyPunchIn ? l.cfgYes : l.cfgNo,
                      ),
                      if (record.earlyPunchInLimitMinutes != null)
                        AppDetailField(
                          label: l.cfgEarlyLimit,
                          value: configurationDuration(
                            context,
                            record.earlyPunchInLimitMinutes!,
                          ),
                        ),
                      AppDetailField(
                        label: l.cfgLateIn,
                        value: record.allowLatePunchIn ? l.cfgYes : l.cfgNo,
                      ),
                      AppDetailField(
                        label: l.cfgEarlyOut,
                        value: record.allowEarlyPunchOut ? l.cfgYes : l.cfgNo,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppFormSection(
                  title: l.cfgOfflineRules,
                  child: Text(offlineModeLabel(record.offlineMode, l)),
                ),
              ],
            ),
          );
        },
      );
}
