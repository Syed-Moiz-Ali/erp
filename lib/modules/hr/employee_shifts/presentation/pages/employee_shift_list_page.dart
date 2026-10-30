import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/employee_shifts/presentation/bloc/employee_shift_list_bloc.dart';
import 'package:modular_erp/modules/hr/employee_shifts/presentation/employee_shift_configuration_repository.dart';
import 'package:modular_erp/shared/presentation/configuration_layouts.dart';

class EmployeeShiftListPage extends StatelessWidget {
  const EmployeeShiftListPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<EmployeeShiftListBloc, EmployeeShiftListState>(
        listener: (c, s) {
          if (s.statusSaved) {
            AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
          }
        },
        builder: (c, s) {
          final bloc = c.read<EmployeeShiftListBloc>();
          final l = c.l10n;
          return ConfigurationListLayout<EmployeeShiftRecord>(
            title: l.cfgEmployeeShifts,
            subtitle: l.cfgEmployeeShiftsIntro,
            state: s,
            manage: bloc.context.user.permissions.contains(
              AppPermission.shiftManage,
            ),
            onSearch: (v) => bloc.add(RecordSearchChanged(v)),
            onStatus: (v) => bloc.add(RecordFilterChanged(v)),
            onPage: (v) => bloc.add(RecordPageChanged(v)),
            onCreate: () => c.go(AppRoutes.employeeShiftsNew),
            onRetry: () => bloc.add(const RecordListStarted()),
            detailRoute: AppRoutes.employeeShiftsDetails,
            editRoute: AppRoutes.employeeShiftsEdit,
            summaryLabel: l.cfgEmployeeShiftDateRange,
            summary: (c, record) => '${record.fromDate} – ${record.toDate}',
            extraColumns: [DataColumn(label: Text(l.cfgEmployeeShiftShift))],
            extraCells: (c, record) => [DataCell(Text(record.shiftName))],
            mobileDetails: (c, record) => [
              if (record.employeeCode.trim().isNotEmpty) record.employeeCode,
              '${record.fromDate} – ${record.toDate}',
            ].join(' · '),
            showAssigned: false,
            allowActivate: false,
            onActive: (id, active) =>
                bloc.add(RecordStatusRequested(id, active)),
          );
        },
      );
}
