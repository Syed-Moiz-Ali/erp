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
import '../../domain/shift.dart';
import '../bloc/shift_form_bloc.dart';
import '../../../../core/utils/local_time.dart';

class ShiftFormPage extends StatelessWidget {
  const ShiftFormPage({super.key, required this.guard});
  final FormNavigationGuard guard;
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<ShiftFormBloc, ShiftFormState>(
        listener: (c, s) {
          if (s.savedId != null) {
            guard.dirty = false;
            guard.saving = false;
            AppFeedback.showMessage(c, message: (l) => l.cfgSaved);
            c.go(AppRoutes.shiftsDetails(s.savedId!));
          }
        },
        builder: (c, s) {
          final l = c.l10n, bloc = c.read<ShiftFormBloc>(), d = s.draft;
          void change(ShiftDraft Function(ShiftDraft) update) =>
              bloc.add(RecordDraftChanged<ShiftDraft>(update));
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
                l.cfgShifts,
                bloc.id == null ? l.cfgNew : l.cfgEdit,
              ].join(' · '),
              loading: s.loading,
              saving: s.saving,
              failure: s.failure,
              onSave: () => bloc.add(const RecordSubmitted<ShiftDraft>()),
              onCancel: () => c.go(AppRoutes.shifts),
              onRetry: () =>
                  bloc.add(const RecordFormInitialized<ShiftDraft>()),
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
                    title: l.cfgSchedule,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppFormGrid(
                          children: [
                            AppTimeField(
                              label: l.cfgStart,
                              value: d.startTime == null
                                  ? null
                                  : TimeOfDay(
                                      hour: d.startTime!.hour,
                                      minute: d.startTime!.minute,
                                    ),
                              enabled: !s.saving,
                              errorText: error('startTime'),
                              onChanged: (v) => change(
                                (d) => d.copyWith(
                                  startTime: LocalTime(
                                    hour: v.hour,
                                    minute: v.minute,
                                  ),
                                ),
                              ),
                            ),
                            AppTimeField(
                              label: l.cfgEnd,
                              value: d.endTime == null
                                  ? null
                                  : TimeOfDay(
                                      hour: d.endTime!.hour,
                                      minute: d.endTime!.minute,
                                    ),
                              enabled: !s.saving,
                              errorText: error('endTime'),
                              onChanged: (v) => change(
                                (d) => d.copyWith(
                                  endTime: LocalTime(
                                    hour: v.hour,
                                    minute: v.minute,
                                  ),
                                ),
                              ),
                            ),
                            AppNumberField(
                              label: l.cfgGrace,
                              initialValue: d.gracePeriodMinutes,
                              enabled: !s.saving,
                              integerOnly: true,
                              errorText: error('gracePeriodMinutes'),
                              suffix: l.cfgMinutes,
                              onChanged: (v) => change(
                                (d) =>
                                    d.copyWith(gracePeriodMinutes: v.integer),
                              ),
                            ),
                            AppNumberField(
                              label: l.cfgMinimumWork,
                              initialValue: d.minimumWorkMinutes,
                              enabled: !s.saving,
                              integerOnly: true,
                              errorText: error('minimumWorkMinutes'),
                              suffix: l.cfgMinutes,
                              onChanged: (v) => change(
                                (d) => d.copyWith(
                                  minimumWorkMinutes: v.optionalInteger,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppWeekdaySelector(
                          value: d.workingDays,
                          enabled: !s.saving,
                          errorText: error('workingDays'),
                          onChanged: (v) =>
                              change((d) => d.copyWith(workingDays: v)),
                        ),
                        if (d.startTime != null &&
                            d.endTime != null &&
                            d.startTime != d.endTime)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xl),
                            child: AppDetailsGrid(
                              fields: [
                                AppDetailField(
                                  label: l.cfgDuration,
                                  value: configurationDuration(
                                    c,
                                    (d.endTime!.minutes -
                                            d.startTime!.minutes +
                                            1440) %
                                        1440,
                                  ),
                                ),
                                if (d.endTime!.minutes < d.startTime!.minutes)
                                  AppDetailField(
                                    label: l.cfgSchedule,
                                    value: l.cfgOvernight,
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppFormSection(
                    title: l.cfgBreakRules,
                    child: AppFormGrid(
                      children: [
                        AppSelectField<ShiftBreakMode>(
                          label: l.cfgBreakMode,
                          value: d.breakMode,
                          enabled: !s.saving,
                          options: [
                            for (final value in ShiftBreakMode.values)
                              AppSelectOption(value, shiftBreakLabel(value, l)),
                          ],
                          onChanged: (v) {
                            if (v != null)
                              change((d) => d.copyWith(breakMode: v));
                          },
                        ),
                        if (d.breakMode == ShiftBreakMode.fixedBreak)
                          AppNumberField(
                            label: l.cfgBreakMinutes,
                            initialValue: d.defaultBreakMinutes,
                            enabled: !s.saving,
                            integerOnly: true,
                            errorText: error('defaultBreakMinutes'),
                            suffix: l.cfgMinutes,
                            onChanged: (v) => change(
                              (d) => d.copyWith(
                                defaultBreakMinutes: v.optionalInteger,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
