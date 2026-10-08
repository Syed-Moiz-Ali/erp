import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/components/headers/app_headers.dart';
import 'package:modular_erp/design_system/components/specialized/app_workspace.dart';
import 'package:modular_erp/design_system/components/status/app_status_badge.dart';
import 'package:modular_erp/design_system/theme/app_colors.dart';
import 'package:modular_erp/design_system/theme/app_dimensions.dart';
import 'package:modular_erp/design_system/theme/app_radius.dart';
import 'package:modular_erp/design_system/theme/app_spacing.dart';
import 'package:modular_erp/design_system/theme/app_typography.dart';

/// UI-7 access-management presentation primitives.
///
/// These widgets present an already-resolved permission editor state. They do
/// **not** compute authorization: scope options, denied reasons and the
/// Manage→View dependency are supplied by the access subsystem, and the UI
/// never widens what the server/repository allows.

// ===========================================================================
// Access summary
// ===========================================================================

/// Compact "enabled access" summary shown before the permission matrix. Only
/// render entries that are unambiguously derivable from the grant set; omit a
/// "broadest data scope" aggregate when scopes differ.
class AppAccessSummary extends StatelessWidget {
  const AppAccessSummary({super.key, required this.metrics, this.title});

  final List<AppSummaryMetric> metrics;
  final String? title;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();
    final typography = AppTypography.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          Text(title!, style: typography.cardTitle),
          const SizedBox(height: AppSpacing.md),
        ],
        AppSummaryStrip(metrics: metrics),
      ],
    );
  }
}

// ===========================================================================
// Scope selector
// ===========================================================================

class AppScopeOption<T> {
  const AppScopeOption({required this.value, required this.label});
  final T value;
  final String label;
}

/// Scope selector for scoped View permissions only (SELF / ASSIGNED / TEAM /
/// ALL). Action and configuration permissions pass no options and therefore
/// never display a fake independent scope.
class AppScopeSelector<T> extends StatelessWidget {
  const AppScopeSelector({
    super.key,
    required this.options,
    required this.value,
    this.onChanged,
    this.label,
    this.enabled = true,
  });

  final List<AppScopeOption<T>> options;
  final T value;
  final ValueChanged<T>? onChanged;
  final String? label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    final typography = AppTypography.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (label != null) ...[
          Text(label!, style: typography.caption),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final option in options)
                ChoiceChip(
                  label: Text(option.label),
                  selected: option.value == value,
                  onSelected: enabled && onChanged != null
                      ? (_) => onChanged!(option.value)
                      : null,
                  visualDensity: VisualDensity.compact,
                  labelStyle: typography.caption.copyWith(
                    fontWeight: option.value == value
                        ? AppTypography.weightSemibold
                        : FontWeight.w500,
                    color: option.value == value
                        ? AppColors.brandPrimary
                        : AppColors.textSecondary,
                  ),
                  selectedColor: AppColors.brandSubtle,
                  backgroundColor: AppColors.surface,
                  showCheckmark: false,
                  side: BorderSide(
                    color: option.value == value
                        ? AppColors.brandPrimary
                        : AppColors.borderDefault,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// Permission matrix
// ===========================================================================

/// A single permission row. When [scopeOptions] is empty the permission has no
/// independent scope (action/configuration); a note about the active View
/// scope should instead be communicated once (see [AppPermissionGroup]).
class AppPermissionRowPresentation {
  const AppPermissionRowPresentation({
    required this.label,
    this.description,
    this.enabled = false,
    this.canToggle = true,
    this.onToggle,
    this.scopeLabel,
    this.scopeOptions = const [],
    this.scopeValue,
    this.onScopeChanged,
    this.badgeLabel,
    this.badgeStatus = AppStatus.info,
    this.requirementMessage,
    this.deniedReason,
    this.technicalKey,
  });

  final String label;
  final String? description;
  final bool enabled;
  final bool canToggle;
  final ValueChanged<bool>? onToggle;
  final String? scopeLabel;
  final List<AppScopeOption<String>> scopeOptions;
  final String? scopeValue;
  final ValueChanged<String>? onScopeChanged;
  final String? badgeLabel;
  final AppStatus badgeStatus;
  final String? requirementMessage;
  final String? deniedReason;
  final String? technicalKey;

  bool get hasScope => scopeOptions.isNotEmpty;
}

/// A submodule section inside a module group (for example `Attendance` inside
/// `Human Resources`). Purely presentational: it only controls how already
/// resolved rows are labelled and ordered.
class AppPermissionSubgroupPresentation {
  const AppPermissionSubgroupPresentation({
    required this.title,
    this.rows = const [],
  });

  final String title;
  final List<AppPermissionRowPresentation> rows;
}

/// A module → submodule permission group. Collapsible on demand while keeping
/// an unsaved-changes indicator visible in the collapsed header. Rows may be
/// supplied flat or grouped into [subgroups].
class AppPermissionGroupPresentation {
  const AppPermissionGroupPresentation({
    required this.id,
    required this.title,
    this.rows = const [],
    this.subgroups = const [],
    this.description,
    this.initiallyExpanded = true,
    this.dirtyCount = 0,
    this.trailing,
  });

  final String id;
  final String title;
  final String? description;
  final List<AppPermissionRowPresentation> rows;
  final List<AppPermissionSubgroupPresentation> subgroups;
  final bool initiallyExpanded;
  final int dirtyCount;

  /// Optional header action (for example a quick-assignment menu). It stays
  /// presentation-only and never bypasses the supplied callbacks.
  final Widget? trailing;

  /// Every row regardless of grouping, used for search matching.
  List<AppPermissionRowPresentation> get allRows => [
    ...rows,
    for (final subgroup in subgroups) ...subgroup.rows,
  ];

  bool get hasRows => allRows.isNotEmpty;
}

class AppPermissionGroup extends StatefulWidget {
  const AppPermissionGroup({
    super.key,
    required this.group,
    this.dense = false,
  });

  final AppPermissionGroupPresentation group;
  final bool dense;

  @override
  State<AppPermissionGroup> createState() => _AppPermissionGroupState();
}

class _AppPermissionGroupState extends State<AppPermissionGroup> {
  late bool _expanded = widget.group.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: _expanded,
            label: widget.group.title,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(AppRadius.card),
                bottom: Radius.circular(_expanded ? 0 : AppRadius.card),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.group.title, style: typography.cardTitle),
                          if (widget.group.description != null) ...[
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              widget.group.description!,
                              style: typography.caption,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.group.dirtyCount > 0)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: AppSpacing.sm,
                        ),
                        child: AppStatusBadge(
                          label: widget.group.dirtyCount.toString(),
                          status: AppStatus.warning,
                          isPill: true,
                        ),
                      ),
                    if (widget.group.trailing != null) ...[
                      widget.group.trailing!,
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: AppDimensions.iconMd,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(height: 1),
                  if (widget.group.subgroups.isNotEmpty) ...[
                    for (final subgroup in widget.group.subgroups)
                      if (subgroup.rows.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            top: AppSpacing.sm,
                          ),
                          child: AppSectionHeader(title: subgroup.title),
                        ),
                        for (final row in subgroup.rows)
                          _PermissionRowView(row: row, dense: widget.dense),
                      ],
                  ] else
                    for (final row in widget.group.rows)
                      _PermissionRowView(row: row, dense: widget.dense),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PermissionRowView extends StatelessWidget {
  const _PermissionRowView({required this.row, required this.dense});
  final AppPermissionRowPresentation row;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    final enabled = row.canToggle && row.onToggle != null;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: dense ? AppSpacing.xs : AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xxs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(row.label, style: typography.label),
                        if (row.badgeLabel != null)
                          AppStatusBadge(
                            label: row.badgeLabel!,
                            status: row.badgeStatus,
                            isPill: true,
                          ),
                      ],
                    ),
                    if (row.description != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(row.description!, style: typography.caption),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Semantics(
                toggled: row.enabled,
                enabled: enabled,
                label: row.label,
                child: ExcludeSemantics(
                  child: Switch.adaptive(
                    value: row.enabled,
                    onChanged: enabled ? row.onToggle : null,
                  ),
                ),
              ),
            ],
          ),
          if (row.hasScope && row.enabled) ...[
            const SizedBox(height: AppSpacing.sm),
            AppScopeSelector<String>(
              label: row.scopeLabel,
              options: row.scopeOptions,
              value: row.scopeValue ?? row.scopeOptions.first.value,
              onChanged: row.canToggle ? row.onScopeChanged : null,
            ),
          ],
          if (row.requirementMessage != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _NoteLine(
              icon: Icons.link_off,
              message: row.requirementMessage!,
              color: AppColors.warning,
            ),
          ],
          if (row.deniedReason != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _NoteLine(
              icon: Icons.info_outline,
              message: row.deniedReason!,
              color: AppColors.textTertiary,
            ),
          ],
          if (row.technicalKey != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              row.technicalKey!,
              style: typography.code.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoteLine extends StatelessWidget {
  const _NoteLine({
    required this.icon,
    required this.message,
    required this.color,
  });
  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: AppDimensions.iconSm, color: color),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Text(
          message,
          style: AppTypography.of(
            context,
          ).caption.copyWith(color: AppColors.textSecondary),
        ),
      ),
    ],
  );
}

/// Grouped permission matrix with a presentation-only search filter. Empty
/// groups are hidden and a distinct no-match state is shown.
class AppPermissionMatrix extends StatelessWidget {
  const AppPermissionMatrix({
    super.key,
    required this.groups,
    this.searchQuery = '',
    this.emptyMessage,
    this.dense = false,
  });

  final List<AppPermissionGroupPresentation> groups;
  final String searchQuery;
  final String? emptyMessage;
  final bool dense;

  bool _matches(AppPermissionRowPresentation row, String query) =>
      row.label.toLowerCase().contains(query) ||
      (row.description ?? '').toLowerCase().contains(query) ||
      (row.technicalKey ?? '').toLowerCase().contains(query);

  @override
  Widget build(BuildContext context) {
    final query = searchQuery.trim().toLowerCase();
    final filtered = <AppPermissionGroupPresentation>[
      for (final group in groups)
        if (group.hasRows)
          if (query.isEmpty)
            group
          else if (_matchesGroup(group, query))
            AppPermissionGroupPresentation(
              id: group.id,
              title: group.title,
              description: group.description,
              initiallyExpanded: true,
              dirtyCount: group.dirtyCount,
              trailing: group.trailing,
              rows: [
                for (final row in group.rows)
                  if (_matches(row, query)) row,
              ],
              subgroups: [
                for (final subgroup in group.subgroups)
                  AppPermissionSubgroupPresentation(
                    title: subgroup.title,
                    rows: [
                      for (final row in subgroup.rows)
                        if (_matches(row, query)) row,
                    ],
                  ),
              ],
            ),
    ];
    final visible = [
      for (final g in filtered)
        if (g.hasRows) g,
    ];
    if (visible.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(
          child: Text(
            emptyMessage ?? '',
            style: AppTypography.of(
              context,
            ).bodySmall.copyWith(color: AppColors.textTertiary),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          AppPermissionGroup(group: visible[i], dense: dense),
        ],
      ],
    );
  }

  bool _matchesGroup(AppPermissionGroupPresentation group, String query) =>
      group.title.toLowerCase().contains(query) ||
      group.allRows.any((row) => _matches(row, query));
}

// ===========================================================================
// Module enablement
// ===========================================================================

/// Company module enablement row. Deliberately distinct from permission rows:
/// enabling a module for a company does **not** grant a user access to it.
/// When [onChanged] is null the row renders read-only, reflecting actual state.
class AppModuleToggleRow extends StatelessWidget {
  const AppModuleToggleRow({
    super.key,
    required this.title,
    required this.enabled,
    this.description,
    this.onChanged,
    this.icon,
    this.statusLabel,
    this.note,
  });

  final String title;
  final bool enabled;
  final String? description;
  final ValueChanged<bool>? onChanged;
  final IconData? icon;
  final String? statusLabel;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final interactive = onChanged != null;
    final semantic = [title, if (description != null) description!].join('. ');
    return Semantics(
      toggled: enabled,
      enabled: interactive,
      label: semantic,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (enabled ? AppColors.brandPrimary : AppColors.neutral)
                      .withValues(alpha: isDark ? .2 : .1),
                  borderRadius: BorderRadius.circular(AppRadius.radiusMd),
                ),
                child: Icon(
                  icon,
                  size: AppDimensions.iconMd,
                  color: enabled
                      ? AppColors.brandPrimary
                      : AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: typography.label),
                  if (description != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(description!, style: typography.caption),
                  ],
                  if (note != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      note!,
                      style: typography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (statusLabel != null) ...[
              const SizedBox(width: AppSpacing.md),
              AppStatusBadge(
                label: statusLabel!,
                status: enabled ? AppStatus.success : AppStatus.neutral,
                isPill: true,
              ),
            ],
            const SizedBox(width: AppSpacing.sm),
            ExcludeSemantics(
              child: Switch.adaptive(value: enabled, onChanged: onChanged),
            ),
          ],
        ),
      ),
    );
  }
}
