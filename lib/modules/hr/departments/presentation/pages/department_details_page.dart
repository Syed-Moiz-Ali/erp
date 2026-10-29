import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/shared/presentation/configuration_layouts.dart';
import 'package:modular_erp/modules/hr/departments/domain/department.dart';
import 'package:modular_erp/modules/hr/departments/presentation/bloc/department_details_bloc.dart';

class DepartmentDetailsPage extends StatelessWidget {
  const DepartmentDetailsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<DepartmentDetailsBloc, DepartmentDetailsState>(
        listener: (c, s) {
          if (s.statusSaved) {
            AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
          }
        },
        builder: (context, s) {
          final l = context.l10n, bloc = context.read<DepartmentDetailsBloc>();
          return ConfigurationDetailsLayout<Department>(
            title: l.cfgDepartments,
            state: s,
            manage: bloc.context.user.permissions.contains(
              AppPermission.departmentManage,
            ),
            onRetry: () => bloc.add(const RecordDetailsStarted()),
            onEdit: () => context.push(AppRoutes.departmentsEdit(bloc.id)),
            onActive: (v) => bloc.add(RecordDetailsStatusRequested(v)),
            content: (record) => AppFormSection(
              title: l.cfgDepartments,
              child: AppDetailsGrid(
                fields: [
                  AppDetailField(label: l.cfgName, value: record.name),
                  AppDetailField(
                    label: l.cfgCode,
                    value: record.id,
                    identifier: true,
                  ),
                ],
              ),
            ),
          );
        },
      );
}
