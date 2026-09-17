import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/errors/result.dart';
import '../../core/models/configuration_record.dart';
import '../../design_system/design_system.dart';
import '../../design_system/theme/app_breakpoints.dart';
import '../../l10n/l10n.dart';
import 'configuration_localization.dart';
import '../workflows/record_list_bloc.dart';
import '../workflows/record_details_bloc.dart';

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

/// Pure presentation composition; each feature supplies typed content and actions.
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
  });
  final String title, subtitle;
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
      tooltip: l.empActions,
      enabled: !state.busy,
      actions: [
        AppMenuAction(
          label: (l) => l.empView,
          onPressed: () => c.go(detailRoute(item.record.id)),
        ),
        if (manage)
          AppMenuAction(
            label: (l) => l.empEdit,
            onPressed: () => c.go(editRoute(item.record.id)),
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
                  c.mounted)
                onActive(item.record.id, active);
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
              label: l.cfgNew,
              icon: Icons.add,
              onPressed: onCreate,
            ),
        ],
      ),
      filters: Column(
        children: [
          AppSearchField(onChanged: onSearch),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.failure != null)
            AppErrorState(
              message: configurationFailure(state.failure!, l),
              onRetry: onRetry,
            ),
          if (state.loading)
            const AppLoadingState()
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
                if (AppBreakpoints.classify(constraints.maxWidth) ==
                    AppSize.compact)
                  return Column(
                    children: [
                      for (final item in data.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppTextButton(
                                        label: item.record.name,
                                        onPressed: () =>
                                            c.go(detailRoute(item.record.id)),
                                      ),
                                    ),
                                    actions(item),
                                  ],
                                ),
                                Text(summary(c, item.record)),
                                const SizedBox(height: AppSpacing.md),
                                Wrap(
                                  spacing: AppSpacing.md,
                                  runSpacing: AppSpacing.sm,
                                  children: [
                                    configurationBadge(c, item.record.status),
                                    Text(
                                      [
                                        l.cfgAssigned,
                                        configurationNumber(
                                          c,
                                          item.assignedEmployees,
                                        ),
                                      ].join(': '),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                return AppCard(
                  padding: EdgeInsets.zero,
                  child: AppDataTable(
                    columns: [
                      DataColumn(label: Text(l.cfgName)),
                      DataColumn(label: Text(l.cfgDescription)),
                      DataColumn(label: Text(l.cfgStatus)),
                      DataColumn(label: Text(l.cfgAssigned)),
                      DataColumn(label: Text(l.empActions)),
                    ],
                    rows: [
                      for (final item in data.items)
                        DataRow(
                          onSelectChanged: (_) =>
                              c.go(detailRoute(item.record.id)),
                          cells: [
                            DataCell(Text(item.record.name)),
                            DataCell(
                              SizedBox(
                                width: 240,
                                child: Text(
                                  summary(c, item.record),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(configurationBadge(c, item.record.status)),
                            DataCell(
                              Text(
                                configurationNumber(c, item.assignedEmployees),
                              ),
                            ),
                            DataCell(actions(item)),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          if (data != null)
            AppTablePagination(
              page: state.page,
              pageSize: 10,
              total: data.filtered,
              onPageChanged: onPage,
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
    if (item == null)
      return AppPage(
        child: state.failure == null
            ? AppEmptyState(title: l.cfgNotFound, message: l.cfgNotFoundMessage)
            : AppErrorState(
                message: configurationFailure(state.failure!, l),
                onRetry: onRetry,
              ),
      );
    return AppPage(
      header: AppPageHeader(
        title: item.record.name,
        subtitle: title,
        actions: [
          if (manage)
            AppSecondaryButton(
              label: l.empEdit,
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
                          c.mounted)
                        onActive(active);
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
                AppStatusBadge(label: l.empPending, status: AppStatus.warning),
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
    required this.saving,
    required this.content,
    required this.onSave,
    required this.onCancel,
    required this.onRetry,
    this.failure,
  });
  final String title;
  final bool loading, saving;
  final Failure? failure;
  final Widget content;
  final VoidCallback onSave, onCancel, onRetry;
  @override
  Widget build(BuildContext c) => AppPage(
    maxWidth: 820,
    header: AppPageHeader(title: title),
    child: loading
        ? const AppLoadingState()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (failure != null)
                AppErrorState(
                  message: configurationFailure(failure!, c.l10n),
                  onRetry: onRetry,
                ),
              if (failure?.code != 'denied' && failure?.code != 'notFound') ...[
                content,
                const SizedBox(height: AppSpacing.xxl),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    AppPrimaryButton(
                      label: c.l10n.save,
                      onPressed: saving ? null : onSave,
                    ),
                    AppSecondaryButton(
                      label: c.l10n.cancel,
                      onPressed: saving ? null : onCancel,
                    ),
                  ],
                ),
              ],
            ],
          ),
  );
}
