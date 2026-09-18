import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/security/app_permission.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/presentation/configuration_layouts.dart';
import '../../../../shared/presentation/configuration_localization.dart';
import '../../domain/work_location.dart';
import '../bloc/work_location_list_bloc.dart';

class WorkLocationListPage extends StatelessWidget {
  const WorkLocationListPage({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<WorkLocationListBloc, WorkLocationListState>(
        listener: (c, s) {
          if (s.statusSaved) {
            AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
          }
        },
        builder: (c, s) {
          final bloc = c.read<WorkLocationListBloc>();
          return ConfigurationListLayout<WorkLocation>(
            title: c.l10n.cfgLocations,
            subtitle: c.l10n.cfgLocationIntro,
            state: s,
            manage: bloc.context.user.permissions.contains(
              AppPermission.workLocationManage,
            ),
            onSearch: (v) => bloc.add(RecordSearchChanged(v)),
            onStatus: (v) => bloc.add(RecordFilterChanged(v)),
            onPage: (v) => bloc.add(RecordPageChanged(v)),
            onCreate: () => c.go(AppRoutes.workLocationsNew),
            onRetry: () => bloc.add(const RecordListStarted()),
            detailRoute: AppRoutes.workLocationsDetails,
            editRoute: AppRoutes.workLocationsEdit,
            summary: (c, record) => record.address,
            summaryLabel: c.l10n.cfgAddress,
            extraColumns: [DataColumn(label: Text(c.l10n.cfgRadius))],
            extraCells: (c, record) => [
              DataCell(
                Text(
                  [
                    configurationNumber(c, record.allowedRadiusMeters),
                    c.l10n.cfgMeters,
                  ].join(' '),
                ),
              ),
            ],
            mobileDetails: (c, record) => [
              configurationNumber(c, record.allowedRadiusMeters),
              c.l10n.cfgMeters,
            ].join(' '),
            onActive: (id, active) =>
                bloc.add(RecordStatusRequested(id, active)),
          );
        },
      );
}
