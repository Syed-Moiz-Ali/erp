import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/result.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/navigation/form_navigation_guard.dart';
import '../../../../shared/presentation/configuration_form_binding.dart';
import '../../../../shared/presentation/configuration_layouts.dart';
import '../../../../shared/presentation/configuration_localization.dart';
import '../../domain/attendance_policy.dart';
import '../bloc/attendance_policy_form_bloc.dart';

class AttendancePolicyFormPage extends StatelessWidget {
  const AttendancePolicyFormPage({super.key, required this.guard});
  final FormNavigationGuard guard;
  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<AttendancePolicyFormBloc, AttendancePolicyFormState>(
    listener: (c, s) {
      if (s.savedId != null) {
        guard.dirty = false;
        guard.saving = false;
        AppFeedback.showMessage(c, message: (l) => l.cfgSaved);
        c.go(AppRoutes.attendancePoliciesDetails(s.savedId!));
      }
    },
    builder: (c, s) {
      final l = c.l10n, bloc = c.read<AttendancePolicyFormBloc>(), d = s.draft;
      void change(
        AttendancePolicyDraft Function(AttendancePolicyDraft) update,
      ) => bloc.add(RecordDraftChanged<AttendancePolicyDraft>(update));
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
            l.cfgPolicies,
            bloc.id == null ? l.cfgNew : l.cfgEdit,
          ].join(' · '),
          loading: s.loading,
          saving: s.saving,
          failure: s.failure,
          onSave: () =>
              bloc.add(const RecordSubmitted<AttendancePolicyDraft>()),
          onCancel: () => c.go(AppRoutes.attendancePolicies),
          onRetry: () =>
              bloc.add(const RecordFormInitialized<AttendancePolicyDraft>()),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppFormSection(
                title: l.cfgGeneralRules,
                child: Column(
                  children: [
                    AppFormGrid(
                      children: [
                        AppTextField(
                          label: l.cfgName,
                          initialValue: d.name,
                          enabled: !s.saving,
                          errorText: error('name'),
                          onChanged: (v) => change((d) => d.copyWith(name: v)),
                        ),
                        AppTextField(
                          label: l.cfgDescription,
                          initialValue: d.description,
                          enabled: !s.saving,
                          errorText: error('description'),
                          onChanged: (v) =>
                              change((d) => d.copyWith(description: v)),
                        ),
                      ],
                    ),
                    AppSwitchField(
                      label: l.cfgRemote,
                      value: d.allowRemoteAttendance,
                      onChanged: s.saving
                          ? null
                          : (v) => change(
                              (d) => d.copyWith(allowRemoteAttendance: v),
                            ),
                    ),
                    AppSwitchField(
                      label: l.cfgCorrections,
                      value: d.allowEmployeeCorrectionRequest,
                      onChanged: s.saving
                          ? null
                          : (v) => change(
                              (d) =>
                                  d.copyWith(allowEmployeeCorrectionRequest: v),
                            ),
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
                    AppSwitchField(
                      label: l.cfgRequireLocation,
                      value: d.requireLocation,
                      onChanged: s.saving
                          ? null
                          : (v) =>
                                change((d) => d.copyWith(requireLocation: v)),
                    ),
                    if (error('requireLocation') != null)
                      Text(error('requireLocation')!),
                    if (d.requireLocation) ...[
                      AppSwitchField(
                        label: l.cfgOutside,
                        value: d.allowOutsideLocation,
                        onChanged: s.saving
                            ? null
                            : (v) => change(
                                (d) => d.copyWith(allowOutsideLocation: v),
                              ),
                      ),
                      AppSwitchField(
                        label: l.cfgLocationIn,
                        value: d.requireLocationOnPunchIn,
                        onChanged: s.saving
                            ? null
                            : (v) => change(
                                (d) => d.copyWith(requireLocationOnPunchIn: v),
                              ),
                      ),
                      AppSwitchField(
                        label: l.cfgLocationOut,
                        value: d.requireLocationOnPunchOut,
                        onChanged: s.saving
                            ? null
                            : (v) => change(
                                (d) => d.copyWith(requireLocationOnPunchOut: v),
                              ),
                      ),
                      AppSwitchField(
                        label: l.cfgRequireAccuracy,
                        value: d.requireLocationAccuracy,
                        onChanged: s.saving
                            ? null
                            : (v) => change(
                                (d) => d.copyWith(requireLocationAccuracy: v),
                              ),
                      ),
                      if (d.requireLocationAccuracy)
                        AppNumberField(
                          label: l.cfgAccuracy,
                          initialValue: d.maximumAcceptedAccuracyMeters,
                          enabled: !s.saving,
                          integerOnly: false,
                          errorText: error('maximumAcceptedAccuracyMeters'),
                          suffix: l.cfgMeters,
                          onChanged: (v) => change(
                            (d) => d.copyWith(
                              maximumAcceptedAccuracyMeters: v.optional,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.cfgBreakRules,
                child: Column(
                  children: [
                    AppSwitchField(
                      label: l.cfgTrackBreaks,
                      value: d.trackBreaks,
                      onChanged: s.saving
                          ? null
                          : (v) => change((d) => d.copyWith(trackBreaks: v)),
                    ),
                    if (d.trackBreaks) ...[
                      AppSwitchField(
                        label: l.cfgMultipleBreaks,
                        value: d.allowMultipleBreaks,
                        onChanged: s.saving
                            ? null
                            : (v) => change(
                                (d) => d.copyWith(allowMultipleBreaks: v),
                              ),
                      ),
                      AppSwitchField(
                        label: l.cfgOutDuringBreak,
                        value: d.allowPunchOutDuringBreak,
                        onChanged: s.saving
                            ? null
                            : (v) => change(
                                (d) => d.copyWith(allowPunchOutDuringBreak: v),
                              ),
                      ),
                      if (d.requireLocation)
                        AppSwitchField(
                          label: l.cfgLocationBreak,
                          value: d.requireLocationOnBreak,
                          onChanged: s.saving
                              ? null
                              : (v) => change(
                                  (d) => d.copyWith(requireLocationOnBreak: v),
                                ),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.cfgTimingRules,
                child: Column(
                  children: [
                    AppSwitchField(
                      label: l.cfgEarlyIn,
                      value: d.allowEarlyPunchIn,
                      onChanged: s.saving
                          ? null
                          : (v) =>
                                change((d) => d.copyWith(allowEarlyPunchIn: v)),
                    ),
                    if (d.allowEarlyPunchIn)
                      AppNumberField(
                        label: l.cfgEarlyLimit,
                        initialValue: d.earlyPunchInLimitMinutes,
                        enabled: !s.saving,
                        integerOnly: true,
                        errorText: error('earlyPunchInLimitMinutes'),
                        suffix: l.cfgMinutes,
                        onChanged: (v) => change(
                          (d) => d.copyWith(
                            earlyPunchInLimitMinutes: v.optionalInteger,
                          ),
                        ),
                      ),
                    AppSwitchField(
                      label: l.cfgLateIn,
                      value: d.allowLatePunchIn,
                      onChanged: s.saving
                          ? null
                          : (v) =>
                                change((d) => d.copyWith(allowLatePunchIn: v)),
                    ),
                    AppSwitchField(
                      label: l.cfgEarlyOut,
                      value: d.allowEarlyPunchOut,
                      onChanged: s.saving
                          ? null
                          : (v) => change(
                              (d) => d.copyWith(allowEarlyPunchOut: v),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.cfgOfflineRules,
                child: AppSelectField<OfflineAttendanceMode>(
                  label: l.cfgOfflineMode,
                  value: d.offlineMode,
                  enabled: !s.saving,
                  options: [
                    for (final value in OfflineAttendanceMode.values)
                      AppSelectOption(value, offlineModeLabel(value, l)),
                  ],
                  onChanged: (v) {
                    if (v != null) change((d) => d.copyWith(offlineMode: v));
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
