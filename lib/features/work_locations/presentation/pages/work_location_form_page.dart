import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/models/configuration_record.dart';
import '../../../../core/security/app_permission.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/navigation/form_navigation_guard.dart';
import '../../../../shared/presentation/configuration_form_binding.dart';
import '../../../../shared/presentation/configuration_layouts.dart';
import '../../../../shared/presentation/configuration_localization.dart';
import '../../domain/work_location.dart';
import '../bloc/work_location_form_bloc.dart';

class WorkLocationFormPage extends StatelessWidget {
  const WorkLocationFormPage({super.key, required this.guard});
  final FormNavigationGuard guard;
  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<WorkLocationFormBloc, WorkLocationFormState>(
    listener: (c, s) {
      if (s.savedId != null) {
        guard.dirty = false;
        guard.saving = false;
        AppFeedback.showMessage(c, message: (l) => l.cfgSaved);
        c.go(
          c.read<WorkLocationFormBloc>().context.user.permissions.contains(
                AppPermission.workLocationView,
              )
              ? AppRoutes.workLocationsDetails(s.savedId!)
              : AppRoutes.dashboard,
        );
      }
    },
    builder: (c, s) {
      final l = c.l10n, bloc = c.read<WorkLocationFormBloc>(), d = s.draft;
      void change(WorkLocationDraft Function(WorkLocationDraft) update) =>
          bloc.add(RecordDraftChanged<WorkLocationDraft>(update));
      String? error(String field) => s.fieldErrors[field] == null
          ? null
          : configurationFailure(Failure(code: s.fieldErrors[field]!), l);
      return ConfigurationFormBinding(
        guard: guard,
        account: bloc.context,
        dirty: s.dirty,
        saving: s.saving,
        child: ConfigurationFormLayout(
          title: [
            l.cfgLocations,
            bloc.id == null ? l.cfgNew : l.cfgEdit,
          ].join(' · '),
          loading: s.loading,
          ready: s.ready,
          saving: s.saving,
          failure: s.failure,
          onSave: () async {
            if (bloc.id != null &&
                s.original.status == ConfigurationStatus.active &&
                d.status == ConfigurationStatus.inactive &&
                !await confirmConfigurationStatus(
                  c,
                  false,
                  s.assignedEmployees,
                )) {
              return;
            }
            if (c.mounted) bloc.add(const RecordSubmitted<WorkLocationDraft>());
          },
          onCancel: () => c.go(
            bloc.context.user.permissions.contains(
                  AppPermission.workLocationView,
                )
                ? AppRoutes.workLocations
                : AppRoutes.dashboard,
          ),
          onRetry: () => bloc.add(
            s.validationRequested
                ? const RecordSubmitted<WorkLocationDraft>()
                : const RecordFormInitialized<WorkLocationDraft>(),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppFormSection(
                title: l.cfgGeneralRules,
                child: AppFormGrid(
                  children: [
                    AppTextField(
                      label: l.cfgName,
                      initialValue: d.name,
                      enabled: !s.saving,
                      errorText: error('name'),
                      onChanged: (v) => change((d) => d.copyWith(name: v)),
                    ),
                    AppTextField(
                      label: l.cfgCode,
                      initialValue: d.code,
                      enabled: !s.saving,
                      errorText: error('code'),
                      onChanged: (v) => change((d) => d.copyWith(code: v)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.cfgAddress,
                child: AppFormGrid(
                  children: [
                    AppTextField(
                      label: l.cfgAddress1,
                      initialValue: d.addressLine1,
                      enabled: !s.saving,
                      errorText: error('addressLine1'),
                      onChanged: (v) =>
                          change((d) => d.copyWith(addressLine1: v)),
                    ),
                    AppTextField(
                      label: l.cfgAddress2,
                      initialValue: d.addressLine2,
                      enabled: !s.saving,
                      errorText: error('addressLine2'),
                      onChanged: (v) =>
                          change((d) => d.copyWith(addressLine2: v)),
                    ),
                    AppTextField(
                      label: l.cfgCity,
                      initialValue: d.city,
                      enabled: !s.saving,
                      errorText: error('city'),
                      onChanged: (v) => change((d) => d.copyWith(city: v)),
                    ),
                    AppTextField(
                      label: l.cfgState,
                      initialValue: d.stateRegion,
                      enabled: !s.saving,
                      errorText: error('stateRegion'),
                      onChanged: (v) =>
                          change((d) => d.copyWith(stateRegion: v)),
                    ),
                    AppTextField(
                      label: l.cfgPostal,
                      initialValue: d.postalCode,
                      enabled: !s.saving,
                      errorText: error('postalCode'),
                      onChanged: (v) =>
                          change((d) => d.copyWith(postalCode: v)),
                    ),
                    AppTextField(
                      label: l.cfgCountry,
                      initialValue: d.countryCode,
                      enabled: !s.saving,
                      errorText: error('countryCode'),
                      onChanged: (v) =>
                          change((d) => d.copyWith(countryCode: v)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.cfgLocationRules,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppSecondaryButton(
                      label: s.locating ? l.cfgLocating : l.cfgCurrentLocation,
                      icon: Icons.my_location,
                      onPressed: s.locating || s.saving
                          ? null
                          : () => bloc.add(const CaptureCurrentLocation()),
                    ),
                    if (s.locationFailure != null) ...[
                      AppErrorState(
                        message: configurationFailure(s.locationFailure!, l),
                        onRetry: () => bloc.add(const CaptureCurrentLocation()),
                      ),
                      AppTextButton(
                        label: l.cfgOpenSettings,
                        onPressed: () => bloc.add(const OpenLocationSettings()),
                      ),
                    ],
                    if (s.capturedAccuracy != null) ...[
                      AppDetailField(
                        label: l.cfgCapturedAccuracy,
                        value: [
                          configurationNumber(c, s.capturedAccuracy!),
                          l.cfgMeters,
                        ].join(' '),
                      ),
                      if (s.capturedAccuracy! > (d.maximumAccuracyMeters ?? 50))
                        AppInfoCard(
                          title: l.cfgAccuracy,
                          message: l.cfgPoorAccuracy,
                        ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    AppFormGrid(
                      children: [
                        AppNumberField(
                          key: ValueKey(s.captureVersion),
                          label: l.cfgLatitude,
                          initialValue: d.latitude,
                          enabled: !s.saving,
                          integerOnly: false,
                          errorText: error('latitude'),
                          onChanged: (v) =>
                              change((d) => d.copyWith(latitude: v.optional)),
                        ),
                        AppNumberField(
                          key: ValueKey(s.captureVersion),
                          label: l.cfgLongitude,
                          initialValue: d.longitude,
                          enabled: !s.saving,
                          integerOnly: false,
                          errorText: error('longitude'),
                          onChanged: (v) =>
                              change((d) => d.copyWith(longitude: v.optional)),
                        ),
                        AppNumberField(
                          label: l.cfgRadius,
                          initialValue: d.allowedRadiusMeters,
                          enabled: !s.saving,
                          integerOnly: false,
                          errorText: error('allowedRadiusMeters'),
                          suffix: l.cfgMeters,
                          onChanged: (v) => change(
                            (d) => d.copyWith(allowedRadiusMeters: v.optional),
                          ),
                        ),
                        AppNumberField(
                          label: l.cfgAccuracy,
                          initialValue: d.maximumAccuracyMeters,
                          enabled: !s.saving,
                          integerOnly: false,
                          errorText: error('maximumAccuracyMeters'),
                          suffix: l.cfgMeters,
                          onChanged: (v) => change(
                            (d) =>
                                d.copyWith(maximumAccuracyMeters: v.optional),
                          ),
                        ),
                        AppSelectField<LocationValidationMode>(
                          label: l.cfgValidationMode,
                          value: d.validationMode,
                          enabled: !s.saving,
                          options: [
                            for (final value in LocationValidationMode.values)
                              AppSelectOption(
                                value,
                                validationModeLabel(value, l),
                              ),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              change((d) => d.copyWith(validationMode: v));
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppLocationPreview(
                latitude: d.latitude,
                longitude: d.longitude,
                radius: d.allowedRadiusMeters,
                address: [
                  d.addressLine1,
                  d.city,
                  d.countryCode,
                ].where((v) => v.isNotEmpty).join(', '),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.cfgStatus,
                child: AppSwitchField(
                  label: l.cfgActive,
                  value: d.status == ConfigurationStatus.active,
                  onChanged: s.saving
                      ? null
                      : (value) => change(
                          (d) => d.copyWith(
                            status: value
                                ? ConfigurationStatus.active
                                : ConfigurationStatus.inactive,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      );
    },
  );
}
