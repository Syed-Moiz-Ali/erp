import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/shared/presentation/configuration_layouts.dart';
import 'package:modular_erp/modules/hr/departments/domain/department.dart';
import 'package:modular_erp/modules/hr/departments/presentation/bloc/department_list_bloc.dart';

class DepartmentListPage extends StatelessWidget {
  const DepartmentListPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<DepartmentListBloc, DepartmentListState>(
        listener: (c, s) {
          if (s.statusSaved) {
            AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
          }
        },
        builder: (c, s) {
          final bloc = c.read<DepartmentListBloc>();
          return ConfigurationListLayout<Department>(
            title: c.l10n.cfgDepartments,
            subtitle: c.l10n.cfgDepartmentIntro,
            state: s,
            manage: bloc.context.user.permissions.contains(
              AppPermission.departmentManage,
            ),
            onSearch: (v) => bloc.add(RecordSearchChanged(v)),
            onStatus: (v) => bloc.add(RecordFilterChanged(v)),
            onPage: (v) => bloc.add(RecordPageChanged(v)),
            onCreate: () => c.go(AppRoutes.departmentsNew),
            onRetry: () => bloc.add(const RecordListStarted()),
            detailRoute: AppRoutes.departmentsDetails,
            editRoute: AppRoutes.departmentsEdit,
            summary: (c, record) => record.id,
            summaryLabel: c.l10n.cfgCode,
            onActive: (id, active) =>
                bloc.add(RecordStatusRequested(id, active)),
          );
        },
      );
}
