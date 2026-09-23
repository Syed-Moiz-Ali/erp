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
import 'package:modular_erp/modules/hr/work_locations/presentation/bloc/work_location_details_bloc.dart';

class WorkLocationDetailsPage extends StatelessWidget {
  const WorkLocationDetailsPage({super.key});
  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<WorkLocationDetailsBloc, WorkLocationDetailsState>(
    listener: (c, s) {
      if (s.statusSaved) {
        AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
      }
    },
    builder: (context, s) {
      final l = context.l10n, bloc = context.read<WorkLocationDetailsBloc>();
      return ConfigurationDetailsLayout<WorkLocation>(
        title: l.cfgLocations,
        state: s,
        manage: bloc.context.user.permissions.contains(
          AppPermission.workLocationManage,
        ),
        onRetry: () => bloc.add(const RecordDetailsStarted()),
        onEdit: () => context.push(AppRoutes.workLocationsEdit(bloc.id)),
        onActive: (v) => bloc.add(RecordDetailsStatusRequested(v)),
        content: (record) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppFormSection(
              title: l.cfgAddress,
              child: AppDetailsGrid(
                fields: [
                  AppDetailField(
                    label: l.cfgCode,
                    value: record.code ?? l.noSelection,
                    identifier: true,
                  ),
                  AppDetailField(label: l.cfgAddress, value: record.address),
                  AppDetailField(
                    label: l.cfgValidationMode,
                    value: validationModeLabel(record.validationMode, l),
                  ),
                  if (record.maximumAccuracyMeters != null)
                    AppDetailField(
                      label: l.cfgAccuracy,
                      value: [
                        configurationNumber(
                          context,
                          record.maximumAccuracyMeters!,
                        ),
                        l.cfgMeters,
                      ].join(' '),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppLocationPreview(
              latitude: record.latitude,
              longitude: record.longitude,
              radius: record.allowedRadiusMeters,
              address: record.address,
            ),
          ],
        ),
      );
    },
  );
}
