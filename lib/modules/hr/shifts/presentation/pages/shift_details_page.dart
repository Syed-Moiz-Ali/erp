import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/app_config.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/shared/presentation/configuration_layouts.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';
import 'package:modular_erp/modules/hr/shifts/presentation/bloc/shift_details_bloc.dart';

class ShiftDetailsPage extends StatelessWidget {
  const ShiftDetailsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<ShiftDetailsBloc, ShiftDetailsState>(
        listener: (c, s) {
          if (s.statusSaved) {
            AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
          }
        },
        builder: (context, s) {
          final l = context.l10n, bloc = context.read<ShiftDetailsBloc>();
          // Working days and break rules are local-only concepts; hide them in
          // backend mode where the API does not expose them.
          final backend = AppConfig.realApiEnabled;
          return ConfigurationDetailsLayout<Shift>(
            title: l.cfgShifts,
            state: s,
            manage: bloc.context.user.permissions.contains(
              AppPermission.shiftManage,
            ),
            onRetry: () => bloc.add(const RecordDetailsStarted()),
            onEdit: () => context.push(AppRoutes.shiftsEdit(bloc.id)),
            onActive: (v) => bloc.add(RecordDetailsStatusRequested(v)),
            content: (record) => AppFormSection(
              title: l.cfgSchedule,
              child: AppDetailsGrid(
                fields: [
                  if (!backend)
                    AppDetailField(
                      label: l.cfgCode,
                      value: record.code ?? l.noSelection,
                      identifier: true,
                    ),
                  AppDetailField(
                    label: l.cfgStart,
                    value: configurationTime(context, record.startTime),
                  ),
                  AppDetailField(
                    label: l.cfgEnd,
                    value: configurationTime(context, record.endTime),
                  ),
                  AppDetailField(
                    label: l.cfgEarlyPunch,
                    value: configurationDuration(
                      context,
                      record.earlyPunchInMinutes,
                    ),
                  ),
                  if (!backend)
                    AppDetailField(
                      label: l.cfgDays,
                      value: workingDaysSummary(record.workingDays, l),
                    ),
                  AppDetailField(
                    label: l.cfgDuration,
                    value: configurationDuration(
                      context,
                      record.durationMinutes,
                    ),
                  ),
                  if (!backend)
                    AppDetailField(
                      label: l.cfgExpectedWork,
                      value: configurationDuration(
                        context,
                        record.expectedWorkMinutes,
                      ),
                    ),
                  AppDetailField(
                    label: l.cfgGrace,
                    value: configurationDuration(
                      context,
                      record.gracePeriodMinutes,
                    ),
                  ),
                  if (!backend)
                    AppDetailField(
                      label: l.cfgBreakMode,
                      value: shiftBreakLabel(record.breakMode, l),
                    ),
                  if (!backend && record.defaultBreakMinutes != null)
                    AppDetailField(
                      label: l.cfgBreakMinutes,
                      value: configurationDuration(
                        context,
                        record.defaultBreakMinutes!,
                      ),
                    ),
                  if (!backend && record.minimumWorkMinutes != null)
                    AppDetailField(
                      label: l.cfgMinimumWork,
                      value: configurationDuration(
                        context,
                        record.minimumWorkMinutes!,
                      ),
                    ),
                  if (record.isOvernight)
                    AppDetailField(label: l.cfgSchedule, value: l.cfgOvernight),
                ],
              ),
            ),
          );
        },
      );
}
