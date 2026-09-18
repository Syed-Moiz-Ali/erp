import '../../../l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../design_system/design_system.dart';
import 'preview_cubit.dart';
import '../../../core/localization/app_formatters.dart';
import '../../../core/validation/app_validation.dart';

class DesignSystemPreviewPage extends StatelessWidget {
  const DesignSystemPreviewPage({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocProvider(create: (_) => PreviewCubit(), child: _Preview());
}

class _Preview extends StatelessWidget {
  const _Preview();
  @override
  Widget build(BuildContext context) => BlocBuilder<PreviewCubit, PreviewState>(
    builder: (context, state) {
      final cubit = context.read<PreviewCubit>();
      final locale = Localizations.localeOf(context);
      final typography = AppTypography.of(context);
      final numberFormatter = AppNumberFormatter(locale);
      final dateFormatter = AppDateFormatter(locale);
      final timeFormatter = AppTimeFormatter(locale);

      return AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Page Header & Primary Actions
            AppPageHeader(
              title: context.l10n.designSystem,
              subtitle: context.l10n.designSystemSubtitle,
              actions: [
                AppStatusBadge(
                  label: context.l10n.internalPreview,
                  status: AppStatus.info,
                  showDot: true,
                ),
                AppSecondaryButton(
                  label: context.l10n.openDialog,
                  size: AppButtonSize.small,
                  onPressed: () => AppConfirmationDialog.show(
                    context,
                    title: (l10n) => l10n.reviewChanges,
                    message: (l10n) => l10n.confirmationPreview,
                    confirmLabel: (l10n) => l10n.looksGood,
                  ),
                ),
                AppDestructiveButton(
                  label: context.l10n.delete,
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

            // 2. Enterprise Notice Banner
            AppNotice(
              title: context.l10n.designLanguage,
              message: context.l10n.consistencyNotice,
              status: AppStatus.info,
              icon: Icons.auto_awesome_outlined,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // 3. Metric Cards with Context & Trends
            AppResponsiveGrid(
              children: [
                AppMetricCard(
                  label: context.l10n.designLanguage,
                  value: context.l10n.oneSystem,
                  detail: context.l10n.sharedAcrossModules,
                  icon: Icons.palette_outlined,
                  trend: numberFormatter.percentage(0.125),
                ),
                AppMetricCard(
                  label: context.l10n.dataStrategy,
                  value: context.l10n.localFirst,
                  detail: context.l10n.repositorySourceOfTruth,
                  icon: Icons.storage_outlined,
                ),
                AppMetricCard(
                  label: context.l10n.layout,
                  value: context.l10n.adaptive,
                  detail: context.l10n.adaptiveDetail,
                  icon: Icons.devices_outlined,
                  trend: numberFormatter.percentage(-0.034),
                  trendPositive: false,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // 4. Button Matrix: Variants, Sizes & States
            AppFormSection(
              title: context.l10n.actions,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Button Sizes
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppPrimaryButton(
                        label: context.l10n.primaryAction,
                        size: AppButtonSize.small,
                        onPressed: () {},
                      ),
                      AppPrimaryButton(
                        label: context.l10n.primaryAction,
                        size: AppButtonSize.medium,
                        icon: Icons.add,
                        onPressed: () {},
                      ),
                      AppPrimaryButton(
                        label: context.l10n.primaryAction,
                        size: AppButtonSize.large,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Button Variants
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppPrimaryButton(
                        label: context.l10n.save,
                        icon: Icons.check,
                        onPressed: () => AppFeedback.showMessage(
                          context,
                          message: (l10n) => l10n.previewActionComplete,
                        ),
                      ),
                      AppSecondaryButton(
                        label: context.l10n.secondaryAction,
                        onPressed: () {},
                      ),
                      AppDestructiveButton(
                        label: context.l10n.delete,
                        icon: Icons.delete_outline,
                        onPressed: () {},
                      ),
                      AppTextButton(
                        label: context.l10n.textAction,
                        onPressed: () {},
                      ),
                      AppIconButton(
                        icon: Icons.more_horiz,
                        tooltip: context.l10n.moreOptions,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Button States: Disabled & Loading
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppPrimaryButton(label: context.l10n.disabled),
                      AppSecondaryButton(label: context.l10n.disabled),
                      AppDestructiveButton(label: context.l10n.disabled),
                      AppPrimaryButton(
                        label: context.l10n.saving,
                        loading: true,
                        onPressed: () {},
                      ),
                      AppSecondaryButton(
                        label: context.l10n.loading,
                        loading: true,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // 5. Form Controls & Inputs Matrix
            AppFormSection(
              title: context.l10n.formControls,
              subtitle: context.l10n.formControlsSubtitle,
              child: Form(
                child: AppResponsiveGrid(
                  minItemWidth: 300,
                  children: [
                    AppTextField(
                      label: context.l10n.fullName,
                      hint: context.l10n.enterName,
                      prefixIcon: Icons.person_outline,
                    ),
                    const AppPasswordField(),
                    const AppSearchField(),
                    AppDropdown<PreviewLocation>(
                      label: context.l10n.workLocation,
                      value: state.location,
                      items: [
                        DropdownMenuItem(
                          value: PreviewLocation.office,
                          child: Text(
                            PreviewLocation.office.label(context.l10n),
                          ),
                        ),
                        DropdownMenuItem(
                          value: PreviewLocation.remote,
                          child: Text(
                            PreviewLocation.remote.label(context.l10n),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) cubit.location(v);
                      },
                    ),
                    AppSelectField<PreviewLocation>(
                      label: context.l10n.workLocation,
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
                      label: context.l10n.active,
                      value: state.activeOnly,
                      onChanged: cubit.filter,
                    ),
                    AppDateField(
                      label: context.l10n.effectiveDate,
                      value: state.date,
                      onChanged: cubit.date,
                    ),
                    AppTimeField(
                      label: context.l10n.startTime,
                      value: state.timeMinutes == null
                          ? null
                          : TimeOfDay(
                              hour: state.timeMinutes! ~/ 60,
                              minute: state.timeMinutes! % 60,
                            ),
                      onChanged: (v) => cubit.time(v.hour * 60 + v.minute),
                    ),
                    AppTextField(
                      label: context.l10n.validationExample,
                      validator: (value) =>
                          AppValidation.required(value)?.message(context.l10n),
                    ),
                    AppTextField(
                      label: context.l10n.cfgShifts,
                      maxLines: 2,
                      enabled: false,
                      initialValue: context.l10n.cfgShiftIntro,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // 6. Card Variants & Information Cards
            AppFormSection(
              title: context.l10n.overview,
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
                            Text(
                              context.l10n.workspace,
                              style: typography.cardTitle,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              context.l10n.internal,
                              style: typography.caption,
                            ),
                          ],
                        ),
                      ),
                      AppCard(
                        variant: AppCardVariant.interactive,
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.reports,
                              style: typography.cardTitle,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              context.l10n.overview,
                              style: typography.caption,
                            ),
                          ],
                        ),
                      ),
                      AppCard(
                        variant: AppCardVariant.subtle,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.settings,
                              style: typography.cardTitle,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              context.l10n.erpWorkspace,
                              style: typography.caption,
                            ),
                          ],
                        ),
                      ),
                      AppCard(
                        variant: AppCardVariant.bordered,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.requests,
                              style: typography.cardTitle,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              context.l10n.pending,
                              style: typography.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppInfoCard(
                    title: context.l10n.informationCard,
                    message: context.l10n.informationCardMessage,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // 7. Status Badges Matrix (with dots, icons, and tints)
            AppFormSection(
              title: context.l10n.statusAndFeedback,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges with Indicator Dots
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppStatusBadge(
                        label: PreviewRecordStatus.active.label(context.l10n),
                        status: AppStatus.success,
                        showDot: true,
                      ),
                      AppStatusBadge(
                        label: context.l10n.pending,
                        status: AppStatus.warning,
                        showDot: true,
                      ),
                      AppStatusBadge(
                        label: context.l10n.rejected,
                        status: AppStatus.danger,
                        showDot: true,
                      ),
                      AppStatusBadge(
                        label: context.l10n.scheduled,
                        status: AppStatus.info,
                        showDot: true,
                      ),
                      AppStatusBadge(
                        label: PreviewRecordStatus.draft.label(context.l10n),
                        status: AppStatus.neutral,
                        showDot: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Badges with Icons & Avatars
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppStatusBadge(
                        label: context.l10n.approved,
                        status: AppStatus.success,
                        icon: Icons.check,
                      ),
                      AppStatusBadge(
                        label: context.l10n.warning,
                        status: AppStatus.warning,
                        icon: Icons.warning_amber_rounded,
                      ),
                      AppStatusBadge(
                        label: context.l10n.failed,
                        status: AppStatus.danger,
                        icon: Icons.close,
                      ),
                      AppStatusBadge(
                        label: context.l10n.synced,
                        status: AppStatus.info,
                        icon: Icons.sync,
                      ),
                      AppAvatar(name: context.l10n.sampleAlex),
                      AppAvatar(name: context.l10n.sampleSam),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // 8. Alerts & Inline Feedback
            AppFormSection(
              title: context.l10n.colorInfo,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppAlert(
                    message: context.l10n.localChangesAvailable,
                    status: AppStatus.success,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppAlert(
                    message: context.l10n.recordsNeedAttention,
                    status: AppStatus.warning,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppAlert(
                    message: context.l10n.actionFailed,
                    status: AppStatus.danger,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const AppLoadingState(),
                  const SizedBox(height: AppSpacing.md),
                  const AppSkeleton(width: 280, height: 20),
                  const SizedBox(height: AppSpacing.sm),
                  const AppSkeleton(width: 180, height: 16),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // 9. Responsive Data Table & Mobile Record Card
            AppFormSection(
              title: context.l10n.filtersAndTable,
              subtitle: context.l10n.illustrativeRecords,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppFilterBar(
                    children: [
                      AppFilterChip(
                        label: context.l10n.activeOnly,
                        selected: state.activeOnly,
                        onSelected: cubit.filter,
                      ),
                      AppTextButton(
                        label: context.l10n.clearFilters,
                        onPressed: () => cubit.filter(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Desktop Data Table
                  AppDataTable(
                    columns: [
                      DataColumn(label: Text(context.l10n.employee)),
                      DataColumn(label: Text(context.l10n.location)),
                      DataColumn(label: Text(context.l10n.status)),
                    ],
                    rows: [
                      DataRow(
                        cells: [
                          DataCell(Text(context.l10n.sampleAlex)),
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
                            DataCell(Text(context.l10n.sampleSam)),
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

                  // Mobile Record Card Showcase (Responsive alternative)
                  AppSectionHeader(
                    title: context.l10n.layout,
                    subtitle: context.l10n.adaptiveDetail,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppMobileRecordCard(
                    title: context.l10n.sampleAlex,
                    subtitle: PreviewLocation.office.label(context.l10n),
                    leading: AppAvatar(name: context.l10n.sampleAlex),
                    status: AppStatus.success,
                    statusLabel: PreviewRecordStatus.active.label(context.l10n),
                    metrics: [
                      (
                        label: context.l10n.location,
                        value: PreviewLocation.office.label(context.l10n),
                      ),
                      (
                        label: context.l10n.date,
                        value: dateFormatter.date(DateTime(2026, 9, 18)),
                      ),
                    ],
                    onTap: () {},
                  ),
                  if (!state.activeOnly) ...[
                    const SizedBox(height: AppSpacing.sm),
                    AppMobileRecordCard(
                      title: context.l10n.sampleSam,
                      subtitle: PreviewLocation.remote.label(context.l10n),
                      leading: AppAvatar(name: context.l10n.sampleSam),
                      status: AppStatus.neutral,
                      statusLabel: PreviewRecordStatus.draft.label(
                        context.l10n,
                      ),
                      metrics: [
                        (
                          label: context.l10n.location,
                          value: PreviewLocation.remote.label(context.l10n),
                        ),
                        (
                          label: context.l10n.date,
                          value: dateFormatter.date(DateTime(2026, 9, 18)),
                        ),
                      ],
                      onTap: () {},
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // 10. Empty & Error States
            AppCard(
              child: AppEmptyState(
                title: context.l10n.noRecordsYet,
                message: context.l10n.noRecordsMessage,
                actionLabel: context.l10n.add,
                onAction: () {},
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppCard(
              child: AppErrorState(
                message: context.l10n.retryWhenConnected,
                onRetry: () {},
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // 11. Configuration Components
            AppFormSection(
              title: context.l10n.cfgConfiguration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppNumberField(
                    label: context.l10n.cfgRadius,
                    initialValue: 150,
                    suffix: context.l10n.cfgMeters,
                    onChanged: (_) => {},
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
                    title: context.l10n.cfgShifts,
                    description: context.l10n.cfgShiftIntro,
                    icon: Icons.schedule_outlined,
                    count: numberFormatter.integer(4),
                    onPressed: () => {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // 12. Language & Formatting Section
            AppFormSection(
              title: context.l10n.language,
              subtitle: context.l10n.languageSubtitle,
              child: const AppLanguageSelector(),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppDetailsSection(
              title: context.l10n.formattingTitle,
              details: {
                context.l10n.date: dateFormatter.date(DateTime(2026, 9, 18)),
                context.l10n.month: dateFormatter.month(DateTime(2026, 9, 18)),
                context.l10n.time: timeFormatter.timeOfDay(
                  const TimeOfDay(hour: 9, minute: 15),
                ),
                context.l10n.duration: timeFormatter.duration(
                  const Duration(hours: 8, minutes: 32),
                  context.l10n,
                ),
                context.l10n.number: numberFormatter.integer(12345),
                context.l10n.percentage: numberFormatter.percentage(.925),
              },
            ),
            const SizedBox(height: AppSpacing.xxl),

            // 13. Typography Scale Matrix
            AppFormSection(
              title: context.l10n.typography,
              subtitle: context.l10n.typographySubtitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final entry in <String, TextStyle>{
                    context.l10n.typographyDisplay: typography.display,
                    context.l10n.typographyPageTitle: typography.pageTitle,
                    context.l10n.typographySectionTitle:
                        typography.sectionTitle,
                    context.l10n.typographyCardTitle: typography.cardTitle,
                    context.l10n.typographyBodyLarge: typography.bodyLarge,
                    context.l10n.typographyBody: typography.body,
                    context.l10n.typographyBodySmall: typography.bodySmall,
                    context.l10n.typographyLabel: typography.label,
                    context.l10n.typographyCaption: typography.caption,
                  }.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Text(
                        context.l10n.typographySample(entry.key),
                        style: entry.value,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // 14. Semantic Color Palette Swatches
            AppFormSection(
              title: context.l10n.semanticPalette,
              child: Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                children: [
                  for (final entry in <String, Color>{
                    context.l10n.colorBrand: AppColors.brandPrimary,
                    context.l10n.colorSurface: AppColors.surface,
                    context.l10n.colorBackground: AppColors.surfaceSubtle,
                    context.l10n.colorBorder: AppColors.borderDefault,
                    context.l10n.colorTextPrimary: AppColors.textPrimary,
                    context.l10n.colorTextSecondary: AppColors.textSecondary,
                    context.l10n.colorTextMuted: AppColors.textMuted,
                    context.l10n.success: AppColors.success,
                    context.l10n.warning: AppColors.warning,
                    context.l10n.colorDanger: AppColors.danger,
                    context.l10n.colorInfo: AppColors.info,
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
                              border: Border.all(
                                color: AppColors.borderDefault,
                              ),
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

            // 15. Dialogs & Bottom Sheets
            AppFormSection(
              title: context.l10n.dialogsAndSheets,
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  AppSecondaryButton(
                    label: context.l10n.previewDialog,
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
                    label: context.l10n.previewBottomSheet,
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

            // 16. Foundation Architectural Details
            AppDetailsSection(
              title: context.l10n.foundationDetails,
              details: {
                context.l10n.architecture: context.l10n.featureFirst,
                context.l10n.theme: context.l10n.lightSemanticTokens,
                context.l10n.persistence: context.l10n.persistenceDetail,
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(context.l10n.internalPreviewPhase, style: typography.caption),
          ],
        ),
      );
    },
  );
}
