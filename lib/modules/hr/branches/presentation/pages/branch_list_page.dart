import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/shared/presentation/configuration_layouts.dart';
import 'package:modular_erp/modules/hr/branches/presentation/branch_configuration_repository.dart';
import 'package:modular_erp/modules/hr/branches/presentation/bloc/branch_list_bloc.dart';

class BranchListPage extends StatelessWidget {
  const BranchListPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<BranchListBloc, BranchListState>(
        listener: (c, s) {
          if (s.statusSaved) {
            AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
          }
        },
        builder: (c, s) {
          final bloc = c.read<BranchListBloc>();
          final l = c.l10n;
          return ConfigurationListLayout<BranchRecord>(
            title: l.cfgBranches,
            subtitle: l.cfgBranchIntro,
            state: s,
            manage: bloc.context.user.permissions.contains(
              AppPermission.companyBranchManage,
            ),
            onSearch: (v) => bloc.add(RecordSearchChanged(v)),
            onStatus: (v) => bloc.add(RecordFilterChanged(v)),
            onPage: (v) => bloc.add(RecordPageChanged(v)),
            onCreate: () => c.go(AppRoutes.branchesNew),
            onRetry: () => bloc.add(const RecordListStarted()),
            detailRoute: AppRoutes.branchesDetails,
            editRoute: AppRoutes.branchesEdit,
            summary: (c, record) => [
              if (record.branchCode != null) record.branchCode!,
              record.timeZoneId,
            ].where((value) => value.trim().isNotEmpty).join(' · '),
            summaryLabel: l.cfgBranchTimeZone,
            extraColumns: [DataColumn(label: Text(l.cfgBranchDivision))],
            extraCells: (c, record) => [
              DataCell(Text(record.divisionName ?? l.noSelection)),
            ],
            mobileDetails: (c, record) => record.divisionName ?? l.noSelection,
            onActive: (id, active) =>
                bloc.add(RecordStatusRequested(id, active)),
          );
        },
      );
}
