import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/shared/presentation/configuration_layouts.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location.dart';
import 'package:modular_erp/modules/hr/work_locations/presentation/bloc/work_location_list_bloc.dart';

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
