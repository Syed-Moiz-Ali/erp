import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/employee_shifts/presentation/bloc/employee_shift_details_bloc.dart';
import 'package:modular_erp/modules/hr/employee_shifts/presentation/employee_shift_configuration_repository.dart';
import 'package:modular_erp/shared/presentation/configuration_layouts.dart';

class EmployeeShiftDetailsPage extends StatelessWidget {
  const EmployeeShiftDetailsPage({super.key});

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<EmployeeShiftDetailsBloc, EmployeeShiftDetailsState>(
    listener: (c, s) {
      if (s.statusSaved) {
        AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
      }
    },
    builder: (context, s) {
      final l = context.l10n, bloc = context.read<EmployeeShiftDetailsBloc>();
      return ConfigurationDetailsLayout<EmployeeShiftRecord>(
        title: l.cfgEmployeeShifts,
        state: s,
        manage: bloc.context.user.permissions.contains(
          AppPermission.shiftManage,
        ),
        showAssigned: false,
        allowActivate: false,
        onRetry: () => bloc.add(const RecordDetailsStarted()),
        onEdit: () => context.push(AppRoutes.employeeShiftsEdit(bloc.id)),
        onActive: (v) => bloc.add(RecordDetailsStatusRequested(v)),
        content: (record) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppFormSection(
              title: l.cfgEmployeeShiftAssignment,
              child: AppDetailsGrid(
                fields: [
                  AppDetailField(
                    label: l.cfgEmployeeShiftEmployee,
                    value: [
                      record.employeeName,
                      if (record.employeeCode.trim().isNotEmpty)
                        record.employeeCode,
                    ].join(' · '),
                  ),
                  AppDetailField(
                    label: l.cfgEmployeeShiftShift,
                    value: record.shiftName,
                  ),
                  AppDetailField(
                    label: l.cfgEmployeeShiftFrom,
                    value: record.fromDate,
                  ),
                  AppDetailField(
                    label: l.cfgEmployeeShiftTo,
                    value: record.toDate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppFormSection(
              title: l.cfgSchedule,
              child: AppDetailsGrid(
                fields: [
                  AppDetailField(label: l.cfgStart, value: record.startTime),
                  AppDetailField(label: l.cfgEnd, value: record.endTime),
                  AppDetailField(
                    label: l.cfgEarlyPunch,
                    value: '${record.earlyPunchInMinutes} ${l.cfgMinutes}',
                  ),
                  AppDetailField(
                    label: l.cfgEmployeeShiftLateGrace,
                    value: '${record.lateGraceMinutes} ${l.cfgMinutes}',
                  ),
                  AppDetailField(
                    label: l.cfgBranchTimeZone,
                    value: record.timeZoneId ?? l.noSelection,
                  ),
                  AppDetailField(
                    label: l.cfgEmployeeShiftPunchInOpensAt,
                    value: record.punchInOpensAt ?? l.noSelection,
                  ),
                  AppDetailField(
                    label: l.cfgEmployeeShiftCrossesMidnight,
                    value: record.crossesMidnight ? l.reportYes : l.reportNo,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
