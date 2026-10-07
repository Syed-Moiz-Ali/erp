import 'package:modular_erp/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'preview_cubit.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';

class DesignSystemPreviewPage extends StatelessWidget {
  const DesignSystemPreviewPage({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocProvider(create: (_) => PreviewCubit(), child: const _Preview());
}

class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreviewCubit, PreviewState>(
      builder: (context, state) {
        final cubit = context.read<PreviewCubit>();
        final locale = Localizations.localeOf(context);
        final theme = state.themeMode == PreviewThemeMode.dark
            ? AppTheme.dark(locale: locale)
            : AppTheme.light(locale: locale);
        return Theme(
          data: theme,
          child: Builder(
            builder: (context) => ColoredBox(
              color: theme.scaffoldBackgroundColor,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(state.textScale.factor),
                ),
                child: _PreviewBody(state: state, cubit: cubit),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PreviewBody extends StatelessWidget {
  const _PreviewBody({required this.state, required this.cubit});

  final PreviewState state;
  final PreviewCubit cubit;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final typography = AppTypography.of(context);
    final numberFormatter = AppNumberFormatter(locale);
    final dateFormatter = AppDateFormatter(locale);
    final l10n = context.l10n;

    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPageHeader(
            title: l10n.designSystem,
            subtitle: l10n.designSystemSubtitle,
            status: AppStatusBadge(
              label: l10n.internalPreview,
              status: AppStatus.info,
              showDot: true,
            ),
            actions: [
              AppSecondaryButton(
                label: l10n.openDialog,
                size: AppButtonSize.small,
                onPressed: () => AppConfirmationDialog.show(
                  context,
                  title: (l10n) => l10n.reviewChanges,
                  message: (l10n) => l10n.confirmationPreview,
                  confirmLabel: (l10n) => l10n.looksGood,
                ),
              ),
              AppDestructiveButton(
                label: l10n.delete,
                size: AppButtonSize.small,
                onPressed: () => AppConfirmationDialog.show(
                  context,
                  title: (l10n) => l10n.delete,
                  message: (l10n) => l10n.reviewChanges,
                  confirmLabel: (l10n) => l10n.delete,
                  destructive: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // 0. Theme / text-scale / direction controls
          AppFormSection(
            title: l10n.designSystemControlStates,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ControlRow(
                  label: l10n.designSystemThemeMode,
                  children: [
                    AppFilterChip(
                      label: l10n.designSystemLightMode,
                      selected: state.themeMode == PreviewThemeMode.light,
                      onSelected: (_) => cubit.theme(PreviewThemeMode.light),
                    ),
                    AppFilterChip(
                      label: l10n.designSystemDarkMode,
                      selected: state.themeMode == PreviewThemeMode.dark,
                      onSelected: (_) => cubit.theme(PreviewThemeMode.dark),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _ControlRow(
                  label: l10n.designSystemTextScale,
                  children: [
                    for (final scale in PreviewTextScale.values)
                      AppFilterChip(
                        label: switch (scale) {
                          PreviewTextScale.system =>
                            l10n.designSystemScaleDefault,
                          PreviewTextScale.moderate =>
                            l10n.designSystemScaleModerate,
                          PreviewTextScale.large => l10n.designSystemScaleLarge,
                        },
                        selected: state.textScale == scale,
                        onSelected: (_) => cubit.scale(scale),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _ControlRow(
                  label: l10n.designSystemDirection,
                  children: const [AppLanguageSelector()],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          AppNotice(
            title: l10n.designLanguage,
            message: l10n.consistencyNotice,
            status: AppStatus.info,
            icon: Icons.auto_awesome_outlined,
          ),
          const SizedBox(height: AppSpacing.xxl),

          AppResponsiveGrid(
            children: [
              AppMetricCard(
                label: l10n.designLanguage,
                value: l10n.oneSystem,
                detail: l10n.sharedAcrossModules,
                icon: Icons.palette_outlined,
                trend: numberFormatter.percentage(0.125),
              ),
              AppMetricCard(
                label: l10n.dataStrategy,
                value: l10n.localFirst,
                detail: l10n.repositorySourceOfTruth,
                icon: Icons.storage_outlined,
              ),
              AppMetricCard(
                label: l10n.layout,
                value: l10n.adaptive,
                detail: l10n.adaptiveDetail,
                icon: Icons.devices_outlined,
                trend: numberFormatter.percentage(-0.034),
                trendPositive: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Buttons
          AppFormSection(
            title: l10n.actions,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppPrimaryButton(
                      label: l10n.primaryAction,
                      size: AppButtonSize.small,
                      onPressed: () {},
                    ),
                    AppPrimaryButton(
                      label: l10n.primaryAction,
                      size: AppButtonSize.medium,
                      icon: Icons.add,
                      onPressed: () {},
                    ),
                    AppPrimaryButton(
                      label: l10n.primaryAction,
                      size: AppButtonSize.large,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppPrimaryButton(
                      label: l10n.save,
                      icon: Icons.check,
                      onPressed: () => AppFeedback.showMessage(
                        context,
                        message: (l10n) => l10n.previewActionComplete,
                      ),
                    ),
                    AppSecondaryButton(
                      label: l10n.secondaryAction,
                      onPressed: () {},
                    ),
                    AppDestructiveButton(
                      label: l10n.delete,
                      icon: Icons.delete_outline,
                      onPressed: () {},
                    ),
                    AppTextButton(label: l10n.textAction, onPressed: () {}),
                    AppIconButton(
                      icon: Icons.more_horiz,
                      tooltip: l10n.moreOptions,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppPrimaryButton(label: l10n.disabled),
                    AppSecondaryButton(label: l10n.disabled),
                    AppDestructiveButton(label: l10n.disabled),
                    AppPrimaryButton(
                      label: l10n.saving,
                      loading: true,
                      onPressed: () {},
                    ),
                    AppSecondaryButton(
                      label: l10n.loading,
                      loading: true,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Inputs
          AppFormSection(
            title: l10n.formControls,
            subtitle: l10n.formControlsSubtitle,
            child: Form(
              child: AppResponsiveGrid(
                minItemWidth: 300,
                children: [
                  AppTextField(
                    label: l10n.fullName,
                    hint: l10n.enterName,
                    prefixIcon: Icons.person_outline,
                  ),
                  const AppPasswordField(),
                  const AppSearchField(),
                  AppDropdown<PreviewLocation>(
                    label: l10n.workLocation,
                    value: state.location,
                    items: [
                      DropdownMenuItem(
                        value: PreviewLocation.office,
                        child: Text(PreviewLocation.office.label(context.l10n)),
                      ),
                      DropdownMenuItem(
                        value: PreviewLocation.remote,
                        child: Text(PreviewLocation.remote.label(context.l10n)),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) cubit.location(v);
                    },
                  ),
                  AppSelectField<PreviewLocation>(
                    label: l10n.workLocation,
                    value: state.location,
                    options: [
                      for (final item in PreviewLocation.values)
                        AppSelectOption(item, item.label(context.l10n)),
                    ],
                    onChanged: (v) {
                      if (v != null) cubit.location(v);
                    },
                  ),
                  AppSwitchField(
                    label: l10n.active,
                    description: l10n.activeOnly,
                    value: state.activeOnly,
                    onChanged: cubit.filter,
                  ),
                  AppDateField(
                    label: l10n.effectiveDate,
                    value: state.date,
                    onChanged: cubit.date,
                  ),
                  AppTimeField(
                    label: l10n.startTime,
                    value: state.timeMinutes == null
                        ? null
                        : TimeOfDay(
                            hour: state.timeMinutes! ~/ 60,
                            minute: state.timeMinutes! % 60,
                          ),
                    onChanged: (v) => cubit.time(v.hour * 60 + v.minute),
                  ),
                  AppTextField(
                    label: l10n.validationExample,
                    errorText: l10n.fieldRequired,
                  ),
                  AppTextField(
                    label: l10n.cfgShifts,
                    maxLines: 2,
                    enabled: false,
                    initialValue: l10n.cfgShiftIntro,
                  ),
                  AppReadOnlyField(
                    label: l10n.designSystemReadOnly,
                    value: l10n.repositorySourceOfTruth,
                    icon: Icons.lock_outline,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Selection controls
          AppFormSection(
            title: l10n.designSystemSelectionControls,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCheckboxField(
                  label: l10n.active,
                  description: l10n.activeOnly,
                  value: state.activeOnly,
                  onChanged: cubit.filter,
                ),
                const SizedBox(height: AppSpacing.md),
                AppCheckboxField(
                  label: l10n.disabled,
                  value: false,
                  onChanged: null,
                  enabled: false,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppRadioGroup<PreviewLocation>(
                  value: state.location,
                  options: [
                    for (final item in PreviewLocation.values)
                      AppRadioOption(item, item.label(context.l10n)),
                  ],
                  onChanged: cubit.location,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppSwitchField(
                  label: l10n.active,
                  value: true,
                  onChanged: (_) {},
                ),
                const SizedBox(height: AppSpacing.sm),
                AppSwitchField(
                  label: l10n.disabled,
                  value: false,
                  onChanged: null,
                  enabled: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Chips & status
          AppFormSection(
            title: l10n.designSystemChips,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final status in AppStatus.values)
                      AppStatusBadge(
                        label: status.name,
                        status: status,
                        showDot: true,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppSelectionChip(
                      label: l10n.activeOnly,
                      selected: state.activeOnly,
                      onSelected: cubit.filter,
                    ),
                    AppSelectionChip(
                      label: l10n.filter,
                      selected: true,
                      onSelected: (_) {},
                    ),
                    AppMetadataChip(
                      label: l10n.overview,
                      icon: Icons.tag_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Cards
          AppFormSection(
            title: l10n.overview,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppResponsiveGrid(
                  minItemWidth: 260,
                  children: [
                    AppCard(
                      variant: AppCardVariant.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.workspace, style: typography.cardTitle),
                          const SizedBox(height: AppSpacing.xs),
                          Text(l10n.internal, style: typography.caption),
                        ],
                      ),
                    ),
                    AppCard(
                      variant: AppCardVariant.interactive,
                      onTap: () {},
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.reports, style: typography.cardTitle),
                          const SizedBox(height: AppSpacing.xs),
                          Text(l10n.overview, style: typography.caption),
                        ],
                      ),
                    ),
                    AppCard(
                      variant: AppCardVariant.subtle,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.settings, style: typography.cardTitle),
                          const SizedBox(height: AppSpacing.xs),
                          Text(l10n.erpWorkspace, style: typography.caption),
                        ],
                      ),
                    ),
                    AppCard(
                      variant: AppCardVariant.bordered,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.requests, style: typography.cardTitle),
                          const SizedBox(height: AppSpacing.xs),
                          Text(l10n.pending, style: typography.caption),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppInfoCard(
                  title: l10n.informationCard,
                  message: l10n.informationCardMessage,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Table + mobile card
          AppFormSection(
            title: l10n.filtersAndTable,
            subtitle: l10n.illustrativeRecords,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFilterBar(
                  children: [
                    AppFilterChip(
                      label: l10n.activeOnly,
                      selected: state.activeOnly,
                      onSelected: cubit.filter,
                    ),
                    AppTextButton(
                      label: l10n.clearFilters,
                      onPressed: () => cubit.filter(false),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppDataTable(
                  columns: [
                    DataColumn(label: Text(l10n.employee)),
                    DataColumn(label: Text(l10n.location)),
                    DataColumn(label: Text(l10n.status)),
                  ],
                  rows: [
                    DataRow(
                      cells: [
                        DataCell(Text(l10n.sampleAlex)),
                        DataCell(
                          Text(PreviewLocation.office.label(context.l10n)),
                        ),
                        DataCell(
                          AppStatusBadge(
                            label: PreviewRecordStatus.active.label(
                              context.l10n,
                            ),
                            status: AppStatus.success,
                            showDot: true,
                          ),
                        ),
                      ],
                    ),
                    if (!state.activeOnly)
                      DataRow(
                        cells: [
                          DataCell(Text(l10n.sampleSam)),
                          DataCell(
                            Text(PreviewLocation.remote.label(context.l10n)),
                          ),
                          DataCell(
                            AppStatusBadge(
                              label: PreviewRecordStatus.draft.label(
                                context.l10n,
                              ),
                              status: AppStatus.neutral,
                              showDot: true,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                AppTablePagination(
                  page: 0,
                  pageSize: 10,
                  total: state.activeOnly ? 1 : 2,
                  onPageChanged: (_) {},
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppSectionHeader(
                  title: l10n.layout,
                  subtitle: l10n.adaptiveDetail,
                ),
                const SizedBox(height: AppSpacing.md),
                AppMobileRecordCard(
                  title: l10n.sampleAlex,
                  subtitle: PreviewLocation.office.label(context.l10n),
                  leading: AppAvatar(name: l10n.sampleAlex),
                  status: AppStatus.success,
                  statusLabel: PreviewRecordStatus.active.label(context.l10n),
                  metrics: [
                    (
                      label: l10n.location,
                      value: PreviewLocation.office.label(context.l10n),
                    ),
                    (
                      label: l10n.date,
                      value: dateFormatter.date(DateTime(2026, 9, 18)),
                    ),
                  ],
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Foundations: spacing / radius / border / elevation / surfaces
          AppFormSection(
            title: l10n.designSystemFoundations,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FoundationsLabel(l10n.designSystemSpacingScale, typography),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    for (final value in _spacingValues)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: value,
                            height: 24,
                            color: AppColors.brandPrimary,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(value.toInt().toString()),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _FoundationsLabel(l10n.designSystemRadiusScale, typography),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    for (final radius in _radiusValues)
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkSurfaceMuted
                              : AppColors.surfaceMuted,
                          border: Border.all(
                            color: AppColors.brandPrimary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(radius),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _FoundationsLabel(l10n.designSystemBorderScale, typography),
                const SizedBox(height: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BorderSample(AppBorders.subtle),
                    const SizedBox(height: AppSpacing.sm),
                    _BorderSample(AppBorders.thin),
                    const SizedBox(height: AppSpacing.sm),
                    _BorderSample(AppBorders.strong),
                    const SizedBox(height: AppSpacing.sm),
                    _BorderSample(AppBorders.focused),
                    const SizedBox(height: AppSpacing.sm),
                    _BorderSample(AppBorders.error),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _FoundationsLabel(l10n.designSystemElevation, typography),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.lg,
                  runSpacing: AppSpacing.lg,
                  children: const [
                    _ElevationSample(AppElevation.none),
                    _ElevationSample(AppElevation.subtle),
                    _ElevationSample(AppElevation.overlayShadow),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _FoundationsLabel(
                  l10n.designSystemSurfaceHierarchy,
                  typography,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final surface in _surfaceValues)
                      Container(
                        width: 96,
                        height: 56,
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(
                            AppRadius.radiusMd,
                          ),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Text colors
          AppFormSection(
            title: l10n.designSystemTextColors,
            child: Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.lg,
              children: [
                for (final entry in <String, TextStyle>{
                  l10n.colorTextPrimary: typography.body,
                  l10n.colorTextSecondary: typography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  l10n.colorTextTertiary: typography.body.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  l10n.disabled: typography.body.copyWith(
                    color: AppColors.textDisabled,
                  ),
                  l10n.colorDanger: typography.body.copyWith(
                    color: AppColors.textDanger,
                  ),
                  l10n.colorSuccess: typography.body.copyWith(
                    color: AppColors.textSuccess,
                  ),
                  l10n.colorWarning: typography.body.copyWith(
                    color: AppColors.textWarning,
                  ),
                }.entries)
                  SizedBox(
                    width: 160,
                    child: Text(
                      l10n.labeledValue(entry.key, l10n.colorBrand),
                      style: entry.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Tooltips & menus
          AppFormSection(
            title: l10n.designSystemTooltip,
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppIconButton(
                  icon: Icons.edit_outlined,
                  tooltip: l10n.edit,
                  onPressed: () {},
                ),
                AppIconButton(
                  icon: Icons.info_outline,
                  tooltip: l10n.designSystemTooltipHint,
                  onPressed: () {},
                ),
                PopupMenuButton<int>(
                  tooltip: l10n.designSystemMenu,
                  onSelected: (_) {},
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 0,
                      child: Text(l10n.designSystemMenuAction),
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Text(
                        l10n.designSystemMenuDanger,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ),
                  ],
                  child: AppSecondaryButton(
                    label: l10n.designSystemMenu,
                    onPressed: null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Skeletons
          AppFormSection(
            title: l10n.designSystemSkeletons,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppLoadingState(),
                const SizedBox(height: AppSpacing.xl),
                AppTableSkeleton(),
                const SizedBox(height: AppSpacing.xl),
                AppDetailSkeleton(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // States
          AppFormSection(
            title: l10n.designSystemErrorStates,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppInlineError(
                  message: l10n.retryWhenConnected,
                  onRetry: () {},
                ),
                const SizedBox(height: AppSpacing.xl),
                AppCard(
                  child: AppEmptyState(
                    title: l10n.noRecordsYet,
                    message: l10n.noRecordsMessage,
                    actionLabel: l10n.add,
                    onAction: () {},
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(child: AppPermissionDeniedState(onGoBack: () {})),
                const SizedBox(height: AppSpacing.lg),
                AppCard(child: AppNotFoundState(onGoBack: () {})),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: AppErrorState(
                    message: l10n.retryWhenConnected,
                    onRetry: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Configuration controls
          AppFormSection(
            title: l10n.cfgConfiguration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppNumberField(
                  label: l10n.cfgRadius,
                  initialValue: 150,
                  suffix: l10n.cfgMeters,
                  onChanged: (_) {},
                ),
                const SizedBox(height: AppSpacing.xl),
                AppWeekdaySelector(value: state.days, onChanged: cubit.days),
                const SizedBox(height: AppSpacing.xl),
                const AppLocationPreview(
                  latitude: 17.385044,
                  longitude: 78.486671,
                  radius: 150,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppSettingsTile(
                  title: l10n.cfgShifts,
                  description: l10n.cfgShiftIntro,
                  icon: Icons.schedule_outlined,
                  count: numberFormatter.integer(4),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Typography
          AppFormSection(
            title: l10n.typography,
            subtitle: l10n.typographySubtitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in <String, TextStyle>{
                  l10n.typographyDisplay: typography.display,
                  l10n.typographyPageTitle: typography.pageTitle,
                  l10n.typographySectionTitle: typography.sectionTitle,
                  l10n.typographyCardTitle: typography.cardTitle,
                  l10n.typographyBodyLarge: typography.bodyLarge,
                  l10n.typographyBody: typography.body,
                  l10n.typographyBodySmall: typography.bodySmall,
                  l10n.typographyLabel: typography.label,
                  l10n.typographyLabelSmall: typography.labelSmall,
                  l10n.typographyFormLabel: typography.formLabel,
                  l10n.typographyInputValue: typography.inputValue,
                  l10n.typographyTableHeader: typography.tableHeader,
                  l10n.typographyTableCell: typography.tableCell,
                  l10n.typographyStatus: typography.status,
                  l10n.typographyCaption: typography.caption,
                  l10n.periodLabel: typography.overline,
                }.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text(
                      l10n.typographySample(entry.key),
                      style: entry.value,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Semantic palette
          AppFormSection(
            title: l10n.semanticPalette,
            child: Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.lg,
              children: [
                for (final entry in <String, Color>{
                  l10n.colorBrand: AppColors.brandPrimary,
                  l10n.colorSurface: AppColors.surface,
                  l10n.colorBackground: AppColors.background,
                  l10n.colorBorder: AppColors.borderDefault,
                  l10n.colorTextPrimary: AppColors.textPrimary,
                  l10n.colorTextSecondary: AppColors.textSecondary,
                  l10n.colorTextTertiary: AppColors.textTertiary,
                  l10n.colorSuccess: AppColors.success,
                  l10n.colorWarning: AppColors.warning,
                  l10n.colorDanger: AppColors.danger,
                  l10n.colorInfo: AppColors.info,
                }.entries)
                  SizedBox(
                    width: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: entry.value,
                            border: Border.all(color: AppColors.borderDefault),
                            borderRadius: BorderRadius.circular(
                              AppRadius.radiusSm,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(entry.key, style: typography.caption),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Dialogs & sheets
          AppFormSection(
            title: l10n.dialogsAndSheets,
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                AppSecondaryButton(
                  label: l10n.previewDialog,
                  onPressed: () => AppDialog.show<void>(
                    context,
                    (dialogContext) => AppDialog(
                      title: dialogContext.l10n.sharedDialog,
                      actions: [
                        AppPrimaryButton(
                          label: dialogContext.l10n.close,
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                      child: Text(dialogContext.l10n.sharedDialogMessage),
                    ),
                  ),
                ),
                AppSecondaryButton(
                  label: l10n.previewBottomSheet,
                  onPressed: () => AppBottomSheet.show<void>(
                    context,
                    builder: (sheetContext) => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSectionHeader(
                          title: sheetContext.l10n.quickDetails,
                          subtitle: sheetContext.l10n.quickDetailsSubtitle,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AppPrimaryButton(
                          label: sheetContext.l10n.done,
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          AppDetailsSection(
            title: l10n.foundationDetails,
            details: {
              l10n.architecture: l10n.featureFirst,
              l10n.theme: l10n.lightSemanticTokens,
              l10n.persistence: l10n.persistenceDetail,
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(l10n.internalPreviewPhase, style: typography.caption),
        ],
      ),
    );
  }
}

const _spacingValues = <double>[
  AppSpacing.xs,
  AppSpacing.sm,
  AppSpacing.md,
  AppSpacing.lg,
  AppSpacing.xl,
  AppSpacing.xxl,
  AppSpacing.section,
  AppSpacing.wide,
];

const _radiusValues = <double>[
  AppRadius.radiusXs,
  AppRadius.radiusSm,
  AppRadius.radiusMd,
  AppRadius.radiusLg,
  AppRadius.radiusXl,
  AppRadius.radius2Xl,
];

const _surfaceValues = <Color>[
  AppColors.background,
  AppColors.surface,
  AppColors.surfaceSubtle,
  AppColors.surfaceMuted,
  AppColors.surfaceSelected,
];

class _ControlRow extends StatelessWidget {
  const _ControlRow({required this.label, required this.children});
  final String label;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      SizedBox(
        width: 140,
        child: Text(label, style: AppTypography.of(context).labelMedium),
      ),
      ...children,
    ],
  );
}

class _FoundationsLabel extends StatelessWidget {
  const _FoundationsLabel(this.label, this.typography);
  final String label;
  final AppTypography typography;
  @override
  Widget build(BuildContext context) =>
      Text(label, style: typography.labelMedium);
}

class _BorderSample extends StatelessWidget {
  const _BorderSample(this.side);
  final BorderSide side;
  @override
  Widget build(BuildContext context) => Container(
    height: 28,
    decoration: BoxDecoration(
      border: Border.fromBorderSide(side),
      borderRadius: BorderRadius.circular(AppRadius.radiusSm),
    ),
  );
}

class _ElevationSample extends StatelessWidget {
  const _ElevationSample(this.shadows);
  final List<BoxShadow> shadows;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 96,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
        ),
        boxShadow: shadows,
      ),
    );
  }
}
