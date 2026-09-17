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
      return AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppPageHeader(
              title: context.l10n.designSystem,
              subtitle: context.l10n.designSystemSubtitle,
              actions: [
                AppStatusBadge(
                  label: context.l10n.internalPreview,
                  status: AppStatus.info,
                ),
                AppSecondaryButton(
                  label: context.l10n.openDialog,
                  onPressed: () => AppConfirmationDialog.show(
                    context,
                    title: (l10n) => l10n.reviewChanges,
                    message: (l10n) => l10n.confirmationPreview,
                    confirmLabel: (l10n) => l10n.looksGood,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xxl),
            AppAlert(message: context.l10n.consistencyNotice),
            SizedBox(height: AppSpacing.xxl),
            AppResponsiveGrid(
              children: [
                AppMetricCard(
                  label: context.l10n.designLanguage,
                  value: context.l10n.oneSystem,
                  detail: context.l10n.sharedAcrossModules,
                  icon: Icons.palette_outlined,
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
                ),
              ],
            ),
            SizedBox(height: AppSpacing.section),
            AppFormSection(
              title: context.l10n.language,
              subtitle: context.l10n.languageSubtitle,
              child: const AppLanguageSelector(),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppDetailsSection(
              title: context.l10n.formattingTitle,
              details: {
                context.l10n.date: AppDateFormatter(
                  Localizations.localeOf(context),
                ).date(DateTime(2026, 9, 17)),
                context.l10n.month: AppDateFormatter(
                  Localizations.localeOf(context),
                ).month(DateTime(2026, 9, 17)),
                context.l10n.time: AppTimeFormatter(
                  Localizations.localeOf(context),
                ).timeOfDay(const TimeOfDay(hour: 9, minute: 15)),
                context.l10n.duration: AppTimeFormatter(
                  Localizations.localeOf(context),
                ).duration(const Duration(hours: 8, minutes: 32), context.l10n),
                context.l10n.number: AppNumberFormatter(
                  Localizations.localeOf(context),
                ).integer(12345),
                context.l10n.percentage: AppNumberFormatter(
                  Localizations.localeOf(context),
                ).percentage(.925),
                context.l10n.currency: AppNumberFormatter(
                  Localizations.localeOf(context),
                ).currency(1234.5, currencyCode: 'USD'),
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppFormSection(
              title: context.l10n.typography,
              subtitle: context.l10n.typographySubtitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final entry in <String, TextStyle>{
                    context.l10n.typographyDisplay: AppTypography.of(
                      context,
                    ).display,
                    context.l10n.typographyPageTitle: AppTypography.of(
                      context,
                    ).pageTitle,
                    context.l10n.typographySectionTitle: AppTypography.of(
                      context,
                    ).sectionTitle,
                    context.l10n.typographyCardTitle: AppTypography.of(
                      context,
                    ).cardTitle,
                    context.l10n.typographyBodyLarge: AppTypography.of(
                      context,
                    ).bodyLarge,
                    context.l10n.typographyBody: AppTypography.of(context).body,
                    context.l10n.typographyBodySmall: AppTypography.of(
                      context,
                    ).bodySmall,
                    context.l10n.typographyLabel: AppTypography.of(
                      context,
                    ).label,
                    context.l10n.typographyCaption: AppTypography.of(
                      context,
                    ).caption,
                  }.entries)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        context.l10n.typographySample(entry.key),
                        style: entry.value,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
            AppFormSection(
              title: context.l10n.semanticPalette,
              child: Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                children: [
                  for (final entry in <String, Color>{
                    context.l10n.colorBrand: AppColors.brand,
                    context.l10n.colorSurface: AppColors.surface,
                    context.l10n.colorBackground: AppColors.background,
                    context.l10n.colorBorder: AppColors.border,
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
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(
                                AppRadius.control,
                              ),
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            entry.key,
                            style: AppTypography.of(context).caption,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
            AppFormSection(
              title: context.l10n.actions,
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppPrimaryButton(
                    label: context.l10n.primaryAction,
                    icon: Icons.add,
                    onPressed: () => AppFeedback.showMessage(
                      context,
                      message: (l10n) => l10n.previewActionComplete,
                    ),
                  ),
                  AppSecondaryButton(
                    label: context.l10n.secondaryAction,
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
                  AppPrimaryButton(label: context.l10n.disabled),
                  AppPrimaryButton(label: context.l10n.saving, loading: true),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
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
                    ),
                    AppPasswordField(),
                    AppSearchField(),
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
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
            AppInfoCard(
              title: context.l10n.informationCard,
              message: context.l10n.informationCardMessage,
            ),
            SizedBox(height: AppSpacing.xxl),
            AppFormSection(
              title: context.l10n.statusAndFeedback,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppStatusBadge(
                        label: PreviewRecordStatus.active.label(context.l10n),
                        status: AppStatus.success,
                      ),
                      AppStatusBadge(
                        label: context.l10n.pending,
                        status: AppStatus.warning,
                      ),
                      AppStatusBadge(
                        label: context.l10n.rejected,
                        status: AppStatus.danger,
                      ),
                      AppStatusBadge(
                        label: context.l10n.scheduled,
                        status: AppStatus.info,
                      ),
                      AppStatusBadge(
                        label: PreviewRecordStatus.draft.label(context.l10n),
                      ),
                      AppAvatar(name: context.l10n.sampleAlex),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg),
                  AppAlert(
                    message: context.l10n.localChangesAvailable,
                    status: AppStatus.success,
                  ),
                  SizedBox(height: AppSpacing.md),
                  AppAlert(
                    message: context.l10n.recordsNeedAttention,
                    status: AppStatus.warning,
                  ),
                  SizedBox(height: AppSpacing.md),
                  AppAlert(
                    message: context.l10n.actionFailed,
                    status: AppStatus.danger,
                  ),
                  AppLoadingState(),
                  AppSkeleton(width: 220),
                  SizedBox(height: AppSpacing.sm),
                  AppSkeleton(width: 160),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
            AppCard(
              child: AppEmptyState(
                title: context.l10n.noRecordsYet,
                message: context.l10n.noRecordsMessage,
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
            AppCard(
              child: AppErrorState(
                message: context.l10n.retryWhenConnected,
                onRetry: () {},
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
            AppFormSection(
              title: context.l10n.filtersAndTable,
              subtitle: context.l10n.illustrativeRecords,
              child: Column(
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
                  SizedBox(height: AppSpacing.lg),
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
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
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
                          SizedBox(height: AppSpacing.xxl),
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
            SizedBox(height: AppSpacing.xxl),
            AppDetailsSection(
              title: context.l10n.foundationDetails,
              details: {
                context.l10n.architecture: context.l10n.featureFirst,
                context.l10n.theme: context.l10n.lightSemanticTokens,
                context.l10n.persistence: context.l10n.persistenceDetail,
              },
            ),
            SizedBox(height: AppSpacing.xxl),
            Text(
              context.l10n.internalPreviewPhase,
              style: AppTypography.of(context).caption,
            ),
          ],
        ),
      );
    },
  );
}
