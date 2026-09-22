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
import '../../../work_locations/domain/work_location.dart';
import '../../../work_locations/domain/work_location_repository.dart';
import '../../domain/leave_models.dart';
import '../bloc/leave_configuration_blocs.dart';
import '../leave_localization.dart';

class HolidayListPage extends StatelessWidget {
  const HolidayListPage({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<HolidayListBloc, HolidayListState>(
        listener: (c, s) {
          if (s.statusSaved) {
            AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
          }
        },
        builder: (c, s) {
          final bloc = c.read<HolidayListBloc>();
          return ConfigurationListLayout<Holiday>(
            title: c.l10n.holidaysNav,
            subtitle: c.l10n.holidayIntro,
            state: s,
            manage: bloc.context.user.permissions.contains(
              AppPermission.holidayManage,
            ),
            onSearch: (v) => bloc.add(RecordSearchChanged(v)),
            onStatus: (v) => bloc.add(RecordFilterChanged(v)),
            onPage: (v) => bloc.add(RecordPageChanged(v)),
            onCreate: () => c.go(AppRoutes.holidaysNew),
            onRetry: () => bloc.add(const RecordListStarted()),
            detailRoute: AppRoutes.holidaysDetails,
            editRoute: AppRoutes.holidaysEdit,
            summary: (c, record) => holidaySummary(record, c.l10n),
            summaryLabel: c.l10n.holidayTypeField,
            extraColumns: [
              DataColumn(label: Text(c.l10n.holidayDate)),
              DataColumn(label: Text(c.l10n.holidayScopeField)),
            ],
            extraCells: (c, record) => [
              DataCell(Text(configurationDate(c, record.date))),
              DataCell(Text(holidayScopeLabel(record.scope, c.l10n))),
            ],
            mobileDetails: (c, record) => configurationDate(c, record.date),
            onActive: (id, active) =>
                bloc.add(RecordStatusRequested(id, active)),
          );
        },
      );
}

class HolidayFormPage extends StatelessWidget {
  const HolidayFormPage({
    super.key,
    required this.guard,
    required this.workLocations,
  });
  final FormNavigationGuard guard;
  final WorkLocationRepository? workLocations;
  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<HolidayFormBloc, HolidayFormState>(
    listener: (c, s) {
      if (s.savedId != null) {
        guard.dirty = false;
        guard.saving = false;
        AppFeedback.showMessage(c, message: (l) => l.cfgSaved);
        c.go(AppRoutes.holidaysDetails(s.savedId!));
      }
    },
    builder: (c, s) {
      final l = c.l10n, bloc = c.read<HolidayFormBloc>(), d = s.draft;
      void change(HolidayDraft Function(HolidayDraft) update) =>
          bloc.add(RecordDraftChanged<HolidayDraft>(update));
      void toggleLocation(String id, bool selected) => change((d) {
        final next = {...d.workLocationIds};
        if (selected) {
          next.add(id);
        } else {
          next.remove(id);
        }
        return d.copyWith(workLocationIds: next);
      });
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
            l.holidaysNav,
            bloc.id == null ? l.cfgNew : l.cfgEdit,
          ].join(' · '),
          loading: s.loading,
          ready: s.ready,
          saving: s.saving,
          failure: s.failure,
          onSave: () {
            if (c.mounted) {
              bloc.add(const RecordSubmitted<HolidayDraft>());
            }
          },
          onCancel: () => c.go(AppRoutes.holidays),
          onRetry: () => bloc.add(
            s.validationRequested
                ? const RecordSubmitted<HolidayDraft>()
                : const RecordFormInitialized<HolidayDraft>(),
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
                    AppSelectField<HolidayType>(
                      label: l.holidayTypeField,
                      value: d.type,
                      enabled: !s.saving,
                      options: [
                        for (final value in HolidayType.values)
                          AppSelectOption(value, holidayTypeLabel(value, l)),
                      ],
                      onChanged: (v) {
                        if (v != null) change((d) => d.copyWith(type: v));
                      },
                    ),
                    AppDateField(
                      label: l.holidayDate,
                      value: d.date,
                      enabled: !s.saving,
                      errorText: error('date'),
                      onChanged: (v) => change((d) => d.copyWith(date: v)),
                    ),
                    AppDateField(
                      label: l.holidayEndDate,
                      value: d.endDate,
                      enabled: !s.saving,
                      errorText: error('endDate'),
                      onChanged: (v) => change((d) => d.copyWith(endDate: v)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.holidayScopeField,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppSelectField<HolidayScope>(
                      label: l.holidayScopeField,
                      value: d.scope,
                      enabled: !s.saving,
                      options: [
                        for (final value in HolidayScope.values)
                          AppSelectOption(value, holidayScopeLabel(value, l)),
                      ],
                      onChanged: (v) {
                        if (v != null) change((d) => d.copyWith(scope: v));
                      },
                    ),
                    if (d.scope == HolidayScope.specificWorkLocations) ...[
                      const SizedBox(height: AppSpacing.lg),
                      if (workLocations == null)
                        Text(l.cfgStorageError)
                      else
                        StreamBuilder<Result<dynamic>>(
                          stream: workLocations!.watchList(bloc.context),
                          builder: (c, snapshot) {
                            final data = snapshot.data;
                            final items = data is Success<dynamic>
                                ? (data.value.items as List)
                                : const [];
                            if (items.isEmpty) {
                              return Text(l.cfgEmpty);
                            }
                            return Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                for (final item in items)
                                  AppFilterChip(
                                    label: (item.record as WorkLocation).name,
                                    selected: d.workLocationIds.contains(
                                      (item.record as WorkLocation).id,
                                    ),
                                    onSelected: (selected) {
                                      if (!s.saving) {
                                        toggleLocation(
                                          (item.record as WorkLocation).id,
                                          selected,
                                        );
                                      }
                                    },
                                  ),
                              ],
                            );
                          },
                        ),
                      if (error('workLocationIds') != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: Text(
                            error('workLocationIds')!,
                            style: TextStyle(
                              color: AppColors.danger,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.cfgDescription,
                child: AppTextField(
                  label: l.cfgDescription,
                  initialValue: d.description,
                  enabled: !s.saving,
                  maxLines: 3,
                  onChanged: (v) => change((d) => d.copyWith(description: v)),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.cfgStatus,
                child: AppFormGrid(
                  children: [
                    AppSwitchField(
                      label: l.holidayOptional,
                      value: d.isOptional,
                      onChanged: s.saving
                          ? null
                          : (v) => change((d) => d.copyWith(isOptional: v)),
                    ),
                    AppSwitchField(
                      label: l.cfgActive,
                      value: d.status == ConfigurationStatus.active,
                      onChanged: s.saving
                          ? null
                          : (v) => change(
                              (d) => d.copyWith(
                                status: v
                                    ? ConfigurationStatus.active
                                    : ConfigurationStatus.inactive,
                              ),
                            ),
                    ),
                  ],
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

class HolidayDetailsPage extends StatelessWidget {
  const HolidayDetailsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<HolidayDetailsBloc, HolidayDetailsState>(
        listener: (c, s) {
          if (s.statusSaved) {
            AppFeedback.showMessage(c, message: (l) => l.cfgStatusSaved);
          }
        },
        builder: (context, s) {
          final l = context.l10n, bloc = context.read<HolidayDetailsBloc>();
          return ConfigurationDetailsLayout<Holiday>(
            title: l.holidaysNav,
            state: s,
            manage: bloc.context.user.permissions.contains(
              AppPermission.holidayManage,
            ),
            onRetry: () => bloc.add(const RecordDetailsStarted()),
            onEdit: () => context.push(AppRoutes.holidaysEdit(bloc.id)),
            onActive: (v) => bloc.add(RecordDetailsStatusRequested(v)),
            content: (record) => AppFormSection(
              title: l.holiday,
              child: AppDetailsGrid(
                fields: [
                  AppDetailField(
                    label: l.holidayDate,
                    value: configurationDate(context, record.date),
                  ),
                  if (record.endDate != null)
                    AppDetailField(
                      label: l.holidayEndDate,
                      value: configurationDate(context, record.endDate!),
                    ),
                  AppDetailField(
                    label: l.holidayTypeField,
                    value: holidayTypeLabel(record.type, l),
                  ),
                  AppDetailField(
                    label: l.holidayScopeField,
                    value: holidayScopeLabel(record.scope, l),
                  ),
                  AppDetailField(
                    label: l.holidayOptional,
                    value: record.isOptional ? l.cfgActive : l.cfgInactive,
                  ),
                  if (record.description.isNotEmpty)
                    AppDetailField(
                      label: l.cfgDescription,
                      value: record.description,
                    ),
                ],
              ),
            ),
          );
        },
      );
}
