import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/security/app_permission.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/presentation/configuration_layouts.dart';
import '../../../../shared/presentation/configuration_localization.dart';
import '../../domain/attendance_policy.dart';
import '../bloc/attendance_policy_list_bloc.dart';

class AttendancePolicyListPage extends StatelessWidget {
  const AttendancePolicyListPage({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<AttendancePolicyListBloc, AttendancePolicyListState>(
        listener: (c, s) {
          if (s.statusSaved) {
            AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
          }
        },
        builder: (c, s) {
          final bloc = c.read<AttendancePolicyListBloc>();
          return ConfigurationListLayout<AttendancePolicy>(
            title: c.l10n.cfgPolicies,
            subtitle: c.l10n.cfgPolicyIntro,
            state: s,
            manage: bloc.context.user.permissions.contains(
              AppPermission.attendancePolicyManage,
            ),
            onSearch: (v) => bloc.add(RecordSearchChanged(v)),
            onStatus: (v) => bloc.add(RecordFilterChanged(v)),
            onPage: (v) => bloc.add(RecordPageChanged(v)),
            onCreate: () => c.go(AppRoutes.attendancePoliciesNew),
            onRetry: () => bloc.add(const RecordListStarted()),
            detailRoute: AppRoutes.attendancePoliciesDetails,
            editRoute: AppRoutes.attendancePoliciesEdit,
            summary: (c, record) => record.requireLocation
                ? c.l10n.cfgRequireLocation
                : c.l10n.cfgNoLocation,
            summaryLabel: c.l10n.cfgLocationRules,
            extraColumns: [
              DataColumn(label: Text(c.l10n.cfgBreakRules)),
              DataColumn(label: Text(c.l10n.cfgOfflineMode)),
            ],
            extraCells: (c, record) => [
              DataCell(
                Text(
                  record.trackBreaks
                      ? c.l10n.cfgTrackBreaks
                      : c.l10n.cfgNoBreak,
                ),
              ),
              DataCell(
                SizedBox(
                  width: 160,
                  child: Text(
                    offlineModeLabel(record.offlineMode, c.l10n),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            mobileDetails: (c, record) => [
              record.trackBreaks ? c.l10n.cfgTrackBreaks : c.l10n.cfgNoBreak,
              offlineModeLabel(record.offlineMode, c.l10n),
            ].join(' · '),
            onActive: (id, active) =>
                bloc.add(RecordStatusRequested(id, active)),
          );
        },
      );
}
