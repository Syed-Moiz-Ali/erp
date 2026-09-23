import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/models/configuration_record.dart';
import '../../../../core/security/app_permission.dart';
import '../../../../design_system/design_system.dart';
import '../../../../design_system/theme/app_breakpoints.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/presentation/configuration_localization.dart';
import '../../../work_locations/domain/work_location.dart';
import '../../../work_locations/domain/work_location_repository.dart';
import '../../domain/leave_holiday_csv.dart';
import '../../domain/leave_models.dart';
import '../bloc/leave_holiday_blocs.dart';
import '../leave_localization.dart';

class HolidayManagementPage extends StatelessWidget {
  const HolidayManagementPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cubit = context.read<HolidayManagementCubit>();
    final canManage = PermissionChecker(
      cubit.context.user.permissions,
    ).can(AppPermission.holidayManage);
    return BlocBuilder<HolidayManagementCubit, HolidayManagementState>(
      builder: (c, s) {
        final today = cubit.repository.companyToday(cubit.context);
        final active = s.holidays
            .where((h) => h.status == ConfigurationStatus.active)
            .toList();
        final next =
            active.where((h) => !(h.endDate ?? h.date).isBefore(today)).toList()
              ..sort((a, b) => a.date.compareTo(b.date));
        return AppPage(
          header: AppPageHeader(
            title: l.holidayCalendarTitle,
            subtitle: l.holidayCalendarSubtitle,
            actions: [
              if (canManage)
                AppPrimaryButton(
                  icon: Icons.add_rounded,
                  label: l.addHoliday,
                  onPressed: () => context.push(AppRoutes.holidaysNew),
                ),
              if (canManage)
                _MoreMenu(
                  onCopy: () => _copyPrevious(c, cubit),
                  onImport: () => context.push(AppRoutes.holidaysImport),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _YearBar(
                year: s.year,
                canManage: canManage,
                onYear: cubit.setYear,
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                children: [
                  AppMetricCard(
                    label: l.activeHolidays,
                    value: '${active.length}',
                    variant: AppMetricVariant.secondary,
                  ),
                  if (next.isNotEmpty)
                    AppMetricCard(
                      label: l.nextHoliday,
                      value: next.first.name,
                      detail: configurationDate(c, next.first.date),
                      variant: AppMetricVariant.secondary,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              if (s.loading)
                const AppLoadingState()
              else if (s.failure != null)
                AppErrorState(
                  message: configurationFailure(s.failure!, l),
                  onRetry: cubit.load,
                )
              else if (s.holidays.isEmpty)
                _SetUpYear(
                  canManage: canManage,
                  onCopy: () => _copyPrevious(c, cubit),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact =
                        AppBreakpoints.classify(constraints.maxWidth) ==
                        AppSize.compact;
                    return compact
                        ? _cards(c, s.holidays, canManage, cubit)
                        : _table(c, s.holidays, canManage, cubit);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _table(
    BuildContext context,
    List<Holiday> holidays,
    bool canManage,
    HolidayManagementCubit cubit,
  ) {
    final l = context.l10n;
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: AppDataTable(
          columns: [
            DataColumn(label: Text(l.holiday)),
            DataColumn(label: Text(l.holidayDate)),
            DataColumn(label: Text(l.holidayTypeField)),
            DataColumn(label: Text(l.applyTo)),
            DataColumn(label: Text(l.holidayOptional)),
            DataColumn(label: Text(l.leaveStatusField)),
            DataColumn(label: Text(l.cfgActions)),
          ],
          rows: [
            for (final holiday in holidays)
              DataRow(
                onSelectChanged: (_) =>
                    context.push(AppRoutes.holidaysDetails(holiday.id)),
                cells: [
                  DataCell(
                    Text(
                      holiday.name,
                      style: AppTypography.of(
                        context,
                      ).body.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(Text(_dateLabel(context, holiday))),
                  DataCell(Text(holidayTypeLabel(holiday.type, l))),
                  DataCell(Text(_scopeLabel(holiday, l))),
                  DataCell(
                    Text(holiday.isOptional ? l.cfgActive : l.cfgInactive),
                  ),
                  DataCell(
                    AppStatusBadge(
                      label: configurationStatusLabel(holiday.status, l),
                      status: holiday.status == ConfigurationStatus.active
                          ? AppStatus.success
                          : AppStatus.neutral,
                    ),
                  ),
                  DataCell(
                    AppActionMenu(
                      tooltip: l.cfgActions,
                      actions: [
                        AppMenuAction(
                          label: (l) => l.cfgView,
                          onPressed: () => context.push(
                            AppRoutes.holidaysDetails(holiday.id),
                          ),
                        ),
                        if (canManage)
                          AppMenuAction(
                            label: (l) => l.cfgEdit,
                            onPressed: () => context.push(
                              AppRoutes.holidaysEdit(holiday.id),
                            ),
                          ),
                        if (canManage)
                          AppMenuAction(
                            label: (l) =>
                                holiday.status == ConfigurationStatus.active
                                ? l.cfgDeactivate
                                : l.cfgActivate,
                            onPressed: () => cubit.setStatus(
                              holiday.id,
                              holiday.status != ConfigurationStatus.active,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _cards(
    BuildContext context,
    List<Holiday> holidays,
    bool canManage,
    HolidayManagementCubit cubit,
  ) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final holiday in holidays)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              variant: AppCardVariant.interactive,
              onTap: () => context.push(AppRoutes.holidaysDetails(holiday.id)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          holiday.name,
                          style: AppTypography.of(context).cardTitle,
                        ),
                      ),
                      AppStatusBadge(
                        label: holidayTypeLabel(holiday.type, l),
                        status: holiday.isOptional
                            ? AppStatus.info
                            : AppStatus.brand,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _dateLabel(context, holiday),
                    style: AppTypography.of(
                      context,
                    ).bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  Text(
                    _scopeLabel(holiday, l),
                    style: AppTypography.of(
                      context,
                    ).caption.copyWith(color: AppColors.textMuted),
                  ),
                  if (canManage) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      alignment: WrapAlignment.end,
                      children: [
                        AppSecondaryButton(
                          label: l.cfgEdit,
                          size: AppButtonSize.small,
                          onPressed: () =>
                              context.push(AppRoutes.holidaysEdit(holiday.id)),
                        ),
                        AppSecondaryButton(
                          label: holiday.status == ConfigurationStatus.active
                              ? l.cfgDeactivate
                              : l.cfgActivate,
                          size: AppButtonSize.small,
                          onPressed: () => cubit.setStatus(
                            holiday.id,
                            holiday.status != ConfigurationStatus.active,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _dateLabel(BuildContext context, Holiday holiday) {
    final from = configurationDate(context, holiday.date);
    if (holiday.endDate == null) return from;
    return '$from – ${configurationDate(context, holiday.endDate!)}';
  }

  String _scopeLabel(Holiday holiday, AppLocalizations l) =>
      holiday.scope == HolidayScope.companyWide
      ? l.holidayScopeCompanyWide
      : '${l.holidayScopeSpecific} (${holiday.workLocationIds.length})';

  Future<void> _copyPrevious(
    BuildContext context,
    HolidayManagementCubit cubit,
  ) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: (l) => l.copyPreviousYear,
      message: (l) => l.holidayCopyNote,
      confirmLabel: (l) => l.copyPreviousYear,
    );
    if (!confirmed || !context.mounted) return;
    final result = await cubit.copyPreviousYear();
    if (!context.mounted) return;
    if (result is Failed<int>) {
      AppFeedback.showMessage(
        context,
        message: (l) => configurationFailure(result.failure, l),
      );
    } else {
      AppFeedback.showMessage(context, message: (l) => l.cfgSaved);
    }
  }
}

class _YearBar extends StatelessWidget {
  const _YearBar({
    required this.year,
    required this.canManage,
    required this.onYear,
  });
  final int year;
  final bool canManage;
  final ValueChanged<int> onYear;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cubit = context.read<HolidayManagementCubit>();
    final current = cubit.repository.leaveYearFor(
      cubit.repository.companyToday(cubit.context),
    );
    final years = [for (var y = current - 2; y <= current + 3; y++) y];
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: AppSelectField<int>(
              label: l.holidayYearLabel,
              value: year,
              enabled: canManage,
              options: [
                for (final value in years) AppSelectOption(value, '$value'),
              ],
              onChanged: (value) {
                if (value != null) onYear(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SetUpYear extends StatelessWidget {
  const _SetUpYear({required this.canManage, required this.onCopy});
  final bool canManage;
  final VoidCallback onCopy;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.noHolidaysConfigured, style: AppTypography.of(context).body),
          if (canManage) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppPrimaryButton(
                  label: l.addHoliday,
                  onPressed: () => context.push(AppRoutes.holidaysNew),
                ),
                AppSecondaryButton(
                  label: l.copyPreviousYear,
                  onPressed: onCopy,
                ),
                AppSecondaryButton(
                  label: l.importHolidays,
                  onPressed: () => context.push(AppRoutes.holidaysImport),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MoreMenu extends StatelessWidget {
  const _MoreMenu({required this.onCopy, required this.onImport});
  final VoidCallback onCopy;
  final VoidCallback onImport;
  @override
  Widget build(BuildContext context) => AppActionMenu(
    tooltip: context.l10n.shellMore,
    actions: [
      AppMenuAction(label: (l) => l.copyPreviousYear, onPressed: onCopy),
      AppMenuAction(label: (l) => l.importHolidays, onPressed: onImport),
    ],
  );
}

class HolidayFormPage extends StatefulWidget {
  const HolidayFormPage({super.key, this.workLocations, this.id});
  final WorkLocationRepository? workLocations;
  final String? id;
  @override
  State<HolidayFormPage> createState() => _HolidayFormPageState();
}

class _HolidayFormPageState extends State<HolidayFormPage> {
  HolidayDraft _draft = const HolidayDraft();
  final _locationSearch = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  Failure? _failure;

  bool get _editing => widget.id != null;
  bool get _multiDay => _draft.endDate != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _locationSearch.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final cubit = context.read<HolidayManagementCubit>();
    if (!_editing) {
      setState(() => _loading = false);
      return;
    }
    final result = await cubit.repository
        .watchHolidays(cubit.context, includeInactive: true)
        .first;
    if (!mounted) return;
    final match = result is Success<List<Holiday>>
        ? result.value.where((h) => h.id == widget.id).firstOrNull
        : null;
    setState(() {
      _draft = match == null
          ? const HolidayDraft()
          : HolidayDraft.fromHoliday(match);
      _loading = false;
      _failure = match == null ? const Failure(code: 'notFound') : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppPage(
      maxWidth: 880,
      header: AppPageHeader(title: _editing ? l.editHoliday : l.addHoliday),
      child: _loading
          ? const AppLoadingState()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_failure != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: AppErrorState(
                      message: configurationFailure(_failure!, l),
                    ),
                  ),
                AppCard(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppFormSection(
                        title: l.holidayBasicInfo,
                        child: AppFormGrid(
                          children: [
                            AppTextField(
                              label: l.holiday,
                              initialValue: _draft.name,
                              enabled: !_saving,
                              onChanged: (v) => setState(
                                () => _draft = _draft.copyWith(name: v),
                              ),
                            ),
                            AppSelectField<HolidayType>(
                              label: l.holidayTypeField,
                              value: _draft.type,
                              enabled: !_saving,
                              options: [
                                for (final type in HolidayType.values)
                                  AppSelectOption(
                                    type,
                                    holidayTypeLabel(type, l),
                                  ),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setState(
                                    () => _draft = _draft.copyWith(type: v),
                                  );
                                }
                              },
                            ),
                            AppDateField(
                              label: l.holidayDate,
                              value: _draft.date,
                              enabled: !_saving,
                              onChanged: (v) => setState(
                                () => _draft = _draft.copyWith(date: v),
                              ),
                            ),
                            if (_multiDay)
                              AppDateField(
                                label: l.holidayEndDate,
                                value: _draft.endDate,
                                enabled: !_saving,
                                onChanged: (v) => setState(
                                  () => _draft = _draft.copyWith(endDate: v),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppSwitchField(
                        label: l.holidayMultiDay,
                        value: _multiDay,
                        onChanged: _saving
                            ? null
                            : (v) => setState(
                                () => _draft = _draft.copyWith(
                                  endDate: v ? (_draft.date) : null,
                                ),
                              ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppFormSection(
                        title: l.holidayApplicability,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppSelectField<HolidayScope>(
                              label: l.applyTo,
                              value: _draft.scope,
                              enabled: !_saving,
                              options: [
                                for (final scope in HolidayScope.values)
                                  AppSelectOption(
                                    scope,
                                    holidayScopeLabel(scope, l),
                                  ),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setState(
                                    () => _draft = _draft.copyWith(scope: v),
                                  );
                                }
                              },
                            ),
                            if (_draft.scope ==
                                HolidayScope.specificWorkLocations) ...[
                              const SizedBox(height: AppSpacing.md),
                              AppTextField(
                                label: l.holidaySearchLocations,
                                controller: _locationSearch,
                                prefixIcon: Icons.search_rounded,
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _LocationPicker(
                                repository: widget.workLocations,
                                search: _locationSearch.text,
                                selected: _draft.workLocationIds,
                                enabled: !_saving,
                                onToggle: (id, selected) => setState(() {
                                  final next = {..._draft.workLocationIds};
                                  if (selected) {
                                    next.add(id);
                                  } else {
                                    next.remove(id);
                                  }
                                  _draft = _draft.copyWith(
                                    workLocationIds: next,
                                  );
                                }),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppFormSection(
                        title: l.holidayOptionality,
                        child: AppSwitchField(
                          label: l.holidayOptional,
                          value: _draft.isOptional,
                          onChanged: _saving
                              ? null
                              : (v) => setState(
                                  () => _draft = _draft.copyWith(isOptional: v),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppFormSection(
                        title: l.cfgDescription,
                        child: AppTextField(
                          label: l.cfgDescription,
                          initialValue: _draft.description,
                          maxLines: 3,
                          enabled: !_saving,
                          onChanged: (v) => setState(
                            () => _draft = _draft.copyWith(description: v),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppFormSection(
                        title: l.cfgStatus,
                        child: AppSwitchField(
                          label: l.cfgActive,
                          value: _draft.status == ConfigurationStatus.active,
                          onChanged: _saving
                              ? null
                              : (v) => setState(
                                  () => _draft = _draft.copyWith(
                                    status: v
                                        ? ConfigurationStatus.active
                                        : ConfigurationStatus.inactive,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppSecondaryButton(
                      label: l.cancel,
                      onPressed: _saving
                          ? null
                          : () => context.go(AppRoutes.holidays),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    AppPrimaryButton(
                      label: l.save,
                      loading: _saving,
                      onPressed: _saving ? null : _save,
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Future<void> _save() async {
    final cubit = context.read<HolidayManagementCubit>();
    final normalized = _draft.normalized();
    final errors = normalized.validate();
    if (errors.isNotEmpty) {
      setState(() => _failure = Failure(code: errors.values.first));
      return;
    }
    setState(() {
      _saving = true;
      _failure = null;
    });
    final result = await cubit.repository.saveHoliday(
      cubit.context,
      normalized,
      id: widget.id,
    );
    if (!mounted) return;
    if (result is Failed<Holiday>) {
      setState(() {
        _saving = false;
        _failure = result.failure;
      });
      return;
    }
    AppFeedback.showMessage(context, message: (l) => l.cfgSaved);
    context.go(AppRoutes.holidays);
  }
}

class _LocationPicker extends StatelessWidget {
  const _LocationPicker({
    required this.repository,
    required this.search,
    required this.selected,
    required this.enabled,
    required this.onToggle,
  });
  final WorkLocationRepository? repository;
  final String search;
  final Set<String> selected;
  final bool enabled;
  final void Function(String id, bool selected) onToggle;
  @override
  Widget build(BuildContext context) {
    final repository = this.repository;
    if (repository == null) {
      return Text(context.l10n.cfgStorageError);
    }
    return StreamBuilder<Result<ConfigurationPageData<WorkLocation>>>(
      stream: repository.watchList(
        context.read<HolidayManagementCubit>().context,
        pageSize: 100,
      ),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final items = data is Success<ConfigurationPageData<WorkLocation>>
            ? data.value.items
            : const <ConfigurationItem<WorkLocation>>[];
        final query = search.trim().toLowerCase();
        final filtered = query.isEmpty
            ? items
            : items
                  .where((i) => i.record.name.toLowerCase().contains(query))
                  .toList();
        if (filtered.isEmpty) {
          return Text(
            context.l10n.cfgEmpty,
            style: AppTypography.of(context).bodySmall,
          );
        }
        return SizedBox(
          height: 220,
          child: ListView(
            children: [
              for (final item in filtered)
                CheckboxListTile(
                  value: selected.contains(item.record.id),
                  onChanged: enabled
                      ? (v) => onToggle(item.record.id, v ?? false)
                      : null,
                  title: Text(item.record.name),
                  dense: true,
                ),
            ],
          ),
        );
      },
    );
  }
}

class HolidayDetailsPage extends StatelessWidget {
  const HolidayDetailsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cubit = context.read<HolidayManagementCubit>();
    final id = GoRouterState.of(context).pathParameters['id'];
    return BlocBuilder<HolidayManagementCubit, HolidayManagementState>(
      builder: (c, s) {
        final holiday = s.holidays.where((h) => h.id == id).firstOrNull;
        if (holiday == null) {
          return AppPage(
            child: AppEmptyState(title: l.cfgNotFound, message: l.cfgNotFound),
          );
        }
        final canManage = PermissionChecker(
          cubit.context.user.permissions,
        ).can(AppPermission.holidayManage);
        return AppPage(
          header: AppPageHeader(
            title: holiday.name,
            subtitle: l.holiday,
            actions: [
              if (canManage)
                AppSecondaryButton(
                  label: l.cfgEdit,
                  icon: Icons.edit_outlined,
                  onPressed: () =>
                      context.push(AppRoutes.holidaysEdit(holiday.id)),
                ),
              if (canManage)
                AppSecondaryButton(
                  label: holiday.status == ConfigurationStatus.active
                      ? l.cfgDeactivate
                      : l.cfgActivate,
                  onPressed: () => cubit.setStatus(
                    holiday.id,
                    holiday.status != ConfigurationStatus.active,
                  ),
                ),
            ],
          ),
          child: AppFormSection(
            title: l.holiday,
            child: AppDetailsGrid(
              fields: [
                AppDetailField(
                  label: l.holidayDate,
                  value: configurationDate(c, holiday.date),
                ),
                if (holiday.endDate != null)
                  AppDetailField(
                    label: l.holidayEndDate,
                    value: configurationDate(c, holiday.endDate!),
                  ),
                AppDetailField(
                  label: l.holidayTypeField,
                  value: holidayTypeLabel(holiday.type, l),
                ),
                AppDetailField(
                  label: l.applyTo,
                  value: holiday.scope == HolidayScope.companyWide
                      ? l.holidayScopeCompanyWide
                      : '${l.holidayScopeSpecific} (${holiday.workLocationIds.length})',
                ),
                AppDetailField(
                  label: l.holidayOptional,
                  value: holiday.isOptional ? l.cfgActive : l.cfgInactive,
                ),
                AppDetailField(
                  label: l.holidaySourceField,
                  value: holidaySourceLabel(holiday.source, l),
                ),
                if (holiday.description.isNotEmpty)
                  AppDetailField(
                    label: l.cfgDescription,
                    value: holiday.description,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HolidayImportPage extends StatefulWidget {
  const HolidayImportPage({super.key});
  @override
  State<HolidayImportPage> createState() => _HolidayImportPageState();
}

class _HolidayImportPageState extends State<HolidayImportPage> {
  final _controller = TextEditingController();
  List<HolidayImportRow> _rows = const [];
  bool _importing = false;
  HolidayImportResult? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppPage(
      maxWidth: 880,
      header: AppPageHeader(
        title: l.importHolidays,
        subtitle: l.holidayImportHint,
        actions: [
          AppSecondaryButton(
            label: l.cancel,
            onPressed: _importing ? null : () => context.go(AppRoutes.holidays),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: l.holidayImportPaste,
                  controller: _controller,
                  maxLines: 8,
                  enabled: !_importing,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    AppSecondaryButton(
                      label: l.holidayImportPreview,
                      onPressed: _importing
                          ? null
                          : () => setState(() {
                              _rows = parseHolidayCsv(_controller.text);
                              _result = null;
                            }),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    AppPrimaryButton(
                      label: l.holidayImportConfirm,
                      loading: _importing,
                      onPressed: _rows.isEmpty || _importing ? null : _import,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: AppInlineStats(
                stats: [
                  (
                    label: l.holidayImportImported,
                    value: '${_result!.imported}',
                  ),
                  (label: l.holidayImportSkipped, value: '${_result!.skipped}'),
                ],
              ),
            ),
          ],
          if (_rows.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: AppDataTable(
                  columns: [
                    DataColumn(label: Text(l.holiday)),
                    DataColumn(label: Text(l.holidayDate)),
                    DataColumn(label: Text(l.holidayTypeField)),
                    DataColumn(label: Text(l.leaveStatusField)),
                  ],
                  rows: [
                    for (final row in _rows)
                      DataRow(
                        cells: [
                          DataCell(Text(row.draft.name)),
                          DataCell(
                            Text(
                              row.draft.date == null
                                  ? '—'
                                  : configurationDate(context, row.draft.date!),
                            ),
                          ),
                          DataCell(Text(holidayTypeLabel(row.draft.type, l))),
                          DataCell(
                            AppStatusBadge(
                              label: row.isValid ? l.cfgActive : l.cfgInactive,
                              status: row.isValid
                                  ? AppStatus.success
                                  : AppStatus.danger,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _import() async {
    final cubit = context.read<HolidayManagementCubit>();
    setState(() => _importing = true);
    final result = await cubit.import(_rows);
    if (!mounted) return;
    setState(() {
      _importing = false;
      _result = result is Success<HolidayImportResult> ? result.value : null;
    });
    if (result is Failed<HolidayImportResult>) {
      AppFeedback.showMessage(
        context,
        message: (l) => configurationFailure(result.failure, l),
      );
    }
  }
}
