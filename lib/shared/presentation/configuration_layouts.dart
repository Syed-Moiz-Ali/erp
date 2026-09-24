import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'configuration_localization.dart';
import 'package:modular_erp/shared/workflows/record_list_bloc.dart';
import 'package:modular_erp/shared/workflows/record_details_bloc.dart';

Widget configurationBadge(BuildContext c, ConfigurationStatus status) =>
    AppStatusBadge(
      label: configurationStatusLabel(status, c.l10n),
      status: status == ConfigurationStatus.active
          ? AppStatus.success
          : AppStatus.neutral,
    );

Future<bool> confirmConfigurationStatus(
  BuildContext c,
  bool active,
  int count,
) => AppConfirmationDialog.show(
  c,
  title: (l) => active ? l.cfgActivate : l.cfgDeactivate,
  message: (l) => [
    active ? l.cfgActivateMessage : l.cfgDeactivateMessage,
    l.cfgAssigned,
    configurationNumber(c, count),
  ].join(' '),
  confirmLabel: (l) => active ? l.cfgActivate : l.cfgDeactivate,
);

/// Modern 2026 Enterprise Configuration List Layout with Curved Cards & Hairline Dividers
class ConfigurationListLayout<T extends ConfigurationRecord>
    extends StatelessWidget {
  const ConfigurationListLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.state,
    required this.manage,
    required this.onSearch,
    required this.onStatus,
    required this.onPage,
    required this.onCreate,
    required this.onRetry,
    required this.detailRoute,
    required this.editRoute,
    required this.summary,
    required this.onActive,
    this.summaryLabel,
    this.summaryWidth = 200,
    this.extraColumns = const [],
    this.extraCells,
    this.mobileDetails,
  });

  final String title, subtitle;
  final String? summaryLabel;
  final double summaryWidth;
  final List<DataColumn> extraColumns;
  final List<DataCell> Function(BuildContext, T)? extraCells;
  final String Function(BuildContext, T)? mobileDetails;
  final RecordListState<T> state;
  final bool manage;
  final ValueChanged<String> onSearch;
  final ValueChanged<ConfigurationStatus?> onStatus;
  final ValueChanged<int> onPage;
  final VoidCallback onCreate, onRetry;
  final String Function(String) detailRoute, editRoute;
  final String Function(BuildContext, T) summary;
  final void Function(String, bool) onActive;

  @override
  Widget build(BuildContext c) {
    final l = c.l10n, data = state.data;

    Widget actions(ConfigurationItem<T> item) => AppActionMenu(
      tooltip: l.cfgActions,
      enabled: !state.busy,
      actions: [
        AppMenuAction(
          label: (l) => l.cfgView,
          onPressed: () => c.push(detailRoute(item.record.id)),
        ),
        if (manage)
          AppMenuAction(
            label: (l) => l.cfgEdit,
            onPressed: () => c.push(editRoute(item.record.id)),
          ),
        if (manage)
          AppMenuAction(
            label: (l) => item.record.status == ConfigurationStatus.active
                ? l.cfgDeactivate
                : l.cfgActivate,
            onPressed: () async {
              final active = item.record.status != ConfigurationStatus.active;
              if (await confirmConfigurationStatus(
                    c,
                    active,
                    item.assignedEmployees,
                  ) &&
                  c.mounted) {
                onActive(item.record.id, active);
              }
            },
          ),
      ],
    );

    return AppPage(
      header: AppPageHeader(
        title: title,
        subtitle: subtitle,
        actions: [
          if (manage)
            AppPrimaryButton(
              icon: Icons.add_rounded,
              label: l.cfgNew,
              onPressed: onCreate,
            ),
        ],
      ),
      filters: Column(
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            // radius: 14.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: l.search,
                  hint: l.searchRecords,
                  initialValue: state.query,
                  onChanged: onSearch,
                  prefixIcon: Icons.search_rounded,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final status in <ConfigurationStatus?>[
                      null,
                      ...ConfigurationStatus.values,
                    ])
                      AppFilterChip(
                        label: status == null
                            ? l.cfgAll
                            : configurationStatusLabel(status, l),
                        selected: state.status == status,
                        onSelected: (_) => onStatus(status),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.failure != null)
            AppErrorState(
              message: configurationFailure(state.failure!, l),
              onRetry: onRetry,
            ),
          if (state.loading)
            const AppConfigurationSkeleton()
          else if (data != null && data.filtered == 0)
            AppEmptyState(
              title: data.total == 0 ? l.cfgEmpty : l.cfgNoResults,
              message: data.total == 0
                  ? l.cfgEmptyMessage
                  : l.cfgNoResultsMessage,
            )
          else if (data != null)
            LayoutBuilder(
              builder: (c, constraints) {
                // Mobile compact cards
                if (AppBreakpoints.classify(constraints.maxWidth) ==
                    AppSize.compact) {
                  return Column(
                    children: [
                      for (final item in data.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppCard(
                            // radius: 14.0,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.record.name,
                                        style: AppTypography.of(c).cardTitle
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                      ),
                                    ),
                                    actions(item),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  summary(c, item.record),
                                  style: AppTypography.of(c).bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (mobileDetails != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    mobileDetails!(c, item.record),
                                    style: AppTypography.of(c).caption.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    configurationBadge(c, item.record.status),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceSubtle,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.radiusXs,
                                        ),
                                        border: Border.all(
                                          color: AppColors.borderSubtle,
                                        ),
                                      ),
                                      child: Text(
                                        [
                                          l.cfgAssigned,
                                          configurationNumber(
                                            c,
                                            item.assignedEmployees,
                                          ),
                                        ].join(': '),
                                        style: AppTypography.of(c).caption
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                }

                // Desktop Elegant Data Table wrapped inside a Curved Card
                return AppCard(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    child: AppDataTable(
                      columns: [
                        DataColumn(label: Text(l.cfgName)),
                        DataColumn(
                          label: Text(summaryLabel ?? l.cfgDescription),
                        ),
                        ...extraColumns,
                        DataColumn(label: Text(l.cfgStatus)),
                        DataColumn(label: Text(l.cfgAssigned)),
                        DataColumn(label: Text(l.cfgActions)),
                      ],
                      rows: [
                        for (final item in data.items)
                          DataRow(
                            onSelectChanged: (_) =>
                                c.push(detailRoute(item.record.id)),
                            cells: [
                              DataCell(
                                Text(
                                  item.record.name,
                                  style: AppTypography.of(c).body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: summaryWidth,
                                  child: Text(
                                    summary(c, item.record),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.of(c).bodySmall
                                        .copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ),
                              ),
                              ...?(extraCells?.call(c, item.record)),
                              DataCell(
                                configurationBadge(c, item.record.status),
                              ),
                              DataCell(
                                Text(
                                  configurationNumber(
                                    c,
                                    item.assignedEmployees,
                                  ),
                                  style: const TextStyle(
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                              DataCell(actions(item)),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          if (data != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AppTablePagination(
                page: state.page,
                pageSize: 10,
                total: data.filtered,
                onPageChanged: onPage,
              ),
            ),
        ],
      ),
    );
  }
}

class ConfigurationDetailsLayout<T extends ConfigurationRecord>
    extends StatelessWidget {
  const ConfigurationDetailsLayout({
    super.key,
    required this.title,
    required this.state,
    required this.manage,
    required this.onRetry,
    required this.onEdit,
    required this.onActive,
    required this.content,
  });
  final String title;
  final RecordDetailsState<T> state;
  final bool manage;
  final VoidCallback onRetry, onEdit;
  final ValueChanged<bool> onActive;
  final Widget Function(T) content;
  @override
  Widget build(BuildContext c) {
    final l = c.l10n, item = state.detail;
    if (state.loading) return const AppPage(child: AppLoadingState());
    if (item == null) {
      return AppPage(
        child: state.failure == null
            ? AppEmptyState(title: l.cfgNotFound, message: l.cfgNotFoundMessage)
            : AppErrorState(
                message: configurationFailure(state.failure!, l),
                onRetry: onRetry,
              ),
      );
    }
    return AppPage(
      header: AppPageHeader(
        title: item.record.name,
        subtitle: title,
        actions: [
          if (manage)
            AppSecondaryButton(
              label: l.cfgEdit,
              icon: Icons.edit_outlined,
              onPressed: state.busy ? null : onEdit,
            ),
          if (manage)
            AppSecondaryButton(
              label: item.record.status == ConfigurationStatus.active
                  ? l.cfgDeactivate
                  : l.cfgActivate,
              onPressed: state.busy
                  ? null
                  : () async {
                      final active =
                          item.record.status != ConfigurationStatus.active;
                      if (await confirmConfigurationStatus(
                            c,
                            active,
                            item.assignedEmployees,
                          ) &&
                          c.mounted) {
                        onActive(active);
                      }
                    },
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.failure != null)
            AppErrorState(
              message: configurationFailure(state.failure!, l),
              onRetry: onRetry,
            ),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.md,
            children: [
              configurationBadge(c, item.record.status),
              Text(
                [
                  l.cfgAssigned,
                  configurationNumber(c, item.assignedEmployees),
                ].join(': '),
              ),
              if (item.record.syncStatus == RecordSyncStatus.pending)
                AppStatusBadge(label: l.cfgPending, status: AppStatus.warning),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          content(item.record),
          const SizedBox(height: AppSpacing.xxl),
          AppInfoCard(title: l.cfgConfiguration, message: l.cfgFoundationNote),
        ],
      ),
    );
  }
}

class ConfigurationFormLayout extends StatelessWidget {
  const ConfigurationFormLayout({
    super.key,
    required this.title,
    required this.loading,
    required this.ready,
    required this.saving,
    required this.content,
    required this.onSave,
    required this.onCancel,
    required this.onRetry,
    this.failure,
  });

  final String title;
  final bool loading, saving, ready;
  final Failure? failure;
  final Widget content;
  final VoidCallback onSave, onCancel, onRetry;

  @override
  Widget build(BuildContext c) => AppPage(
    header: AppPageHeader(title: title),
    child: loading
        ? const AppConfigurationSkeleton()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (failure != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AppErrorState(
                    message: configurationFailure(failure!, c.l10n),
                    onRetry: onRetry,
                  ),
                ),
              if (ready) ...[
                AppCard(
                  // radius: 18.0,
                  padding: const EdgeInsets.all(28.0),
                  child: content,
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppSecondaryButton(
                      label: c.l10n.cancel,
                      onPressed: saving ? null : onCancel,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    AppPrimaryButton(
                      label: c.l10n.save,
                      loading: saving,
                      onPressed: saving ? null : onSave,
                    ),
                  ],
                ),
              ],
            ],
          ),
  );
}
