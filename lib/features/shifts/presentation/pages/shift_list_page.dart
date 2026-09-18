import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/security/app_permission.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/presentation/configuration_layouts.dart';
import '../../../../shared/presentation/configuration_localization.dart';
import '../../domain/shift.dart';
import '../bloc/shift_list_bloc.dart';

class ShiftListPage extends StatelessWidget {
  const ShiftListPage({super.key});
  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<ShiftListBloc, ShiftListState>(
    listener: (c, s) {
      if (s.statusSaved) {
        AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
      }
    },
    builder: (c, s) {
      final bloc = c.read<ShiftListBloc>();
      return ConfigurationListLayout<Shift>(
        title: c.l10n.cfgShifts,
        subtitle: c.l10n.cfgShiftIntro,
        state: s,
        manage: bloc.context.user.permissions.contains(
          AppPermission.shiftManage,
        ),
        onSearch: (v) => bloc.add(RecordSearchChanged(v)),
        onStatus: (v) => bloc.add(RecordFilterChanged(v)),
        onPage: (v) => bloc.add(RecordPageChanged(v)),
        onCreate: () => c.go(AppRoutes.shiftsNew),
        onRetry: () => bloc.add(const RecordListStarted()),
        detailRoute: AppRoutes.shiftsDetails,
        editRoute: AppRoutes.shiftsEdit,
        summary: (c, record) => shiftSummary(c, record),
        summaryLabel: c.l10n.cfgSchedule,
        extraColumns: [
          DataColumn(label: Text(c.l10n.cfgDays)),
          DataColumn(label: Text(c.l10n.cfgExpectedWork)),
          DataColumn(label: Text(c.l10n.cfgGrace)),
        ],
        extraCells: (c, record) => [
          DataCell(
            SizedBox(
              width: 170,
              child: Text(
                workingDaysSummary(record.workingDays, c.l10n),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          DataCell(Text(configurationDuration(c, record.expectedWorkMinutes))),
          DataCell(Text(configurationDuration(c, record.gracePeriodMinutes))),
        ],
        mobileDetails: (c, record) => [
          workingDaysSummary(record.workingDays, c.l10n),
          configurationDuration(c, record.expectedWorkMinutes),
        ].join(' · '),
        onActive: (id, active) => bloc.add(RecordStatusRequested(id, active)),
      );
    },
  );
}
