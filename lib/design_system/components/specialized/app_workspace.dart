import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/components/cards/app_cards.dart';
import 'package:modular_erp/design_system/components/headers/app_headers.dart';
import 'package:modular_erp/design_system/components/layout/app_page.dart';
import 'package:modular_erp/design_system/components/status/app_status_badge.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/design_system/theme/app_colors.dart';
import 'package:modular_erp/design_system/theme/app_radius.dart';
import 'package:modular_erp/design_system/theme/app_spacing.dart';
import 'package:modular_erp/design_system/theme/app_typography.dart';

/// UI-7 shared specialized-workspace foundation.
///
/// Reports, calendars, access and settings hubs reuse these primitives so a
/// specialized workspace still reads as the same ERP: one page header, compact
/// summary language, one report toolbar and one semantic legend. Nothing here
/// owns business meaning — callers pass already-resolved presentation data.

// ===========================================================================
// Workspace header
// ===========================================================================

/// Specialized page header. Delegates the title/subtitle/actions to the shared
/// [AppPageHeader] (so there is never a duplicate title card) and optionally
/// renders a compact [AppSummaryStrip] directly beneath it, at a fixed rhythm.
class AppWorkspaceHeader extends StatelessWidget {
  const AppWorkspaceHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.breadcrumbs,
    this.status,
    this.overflowActions = const [],
    this.compactActionsInline = false,
    this.summary,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? breadcrumbs;
  final Widget? status;
  final List<AppPageOverflowAction> overflowActions;
  final bool compactActionsInline;
  final Widget? summary;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppPageHeader(
        title: title,
        subtitle: subtitle,
        actions: actions,
        breadcrumbs: breadcrumbs,
        status: status,
        overflowActions: overflowActions,
        compactActionsInline: compactActionsInline,
      ),
      if (summary != null) ...[
        const SizedBox(height: AppSpacing.xxl),
        summary!,
      ],
    ],
  );
}

// ===========================================================================
// Workspace section
// ===========================================================================

enum AppWorkspaceSurface { plain, card, bordered }

/// A titled block inside a specialized workspace. Uses the shared section
/// header and offers plain / card / bordered surfaces so pages avoid
/// nested-card syndrome while keeping one vertical rhythm.
class AppWorkspaceSection extends StatelessWidget {
  const AppWorkspaceSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
    this.surface = AppWorkspaceSurface.plain,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;
  final AppWorkspaceSurface surface;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: title, subtitle: subtitle, action: action),
        const SizedBox(height: AppSpacing.lg),
        child,
      ],
    );
    return switch (surface) {
      AppWorkspaceSurface.plain => content,
      AppWorkspaceSurface.card => AppCard(child: content),
      AppWorkspaceSurface.bordered => _BorderedSurface(child: content),
    };
  }
}

class _BorderedSurface extends StatelessWidget {
  const _BorderedSurface({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderDefault,
        ),
      ),
      child: child,
    );
  }
}

// ===========================================================================
// Summary / metrics
// ===========================================================================

/// One compact summary metric. Purely presentational: callers pass a final,
/// localized label and an already-formatted value.
class AppSummaryMetric {
  const AppSummaryMetric({
    required this.label,
    required this.value,
    this.detail,
    this.icon,
    this.status = AppStatus.neutral,
  });

  final String label;
  final String value;
  final String? detail;
  final IconData? icon;
  final AppStatus status;
}

/// Compact report metric tile (label above a tabular value). Deliberately
/// lighter than a dashboard KPI card.
class AppReportMetric extends StatelessWidget {
  const AppReportMetric({
    super.key,
    required this.label,
    required this.value,
    this.detail,
    this.icon,
    this.status = AppStatus.neutral,
  });

  final String label;
  final String value;
  final String? detail;
  final IconData? icon;
  final AppStatus status;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = status == AppStatus.neutral
        ? null
        : (isDark ? status.darkColor : status.color);
    final semantic = [label, value, if (detail != null) detail!].join(', ');
    return Semantics(
      label: semantic,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: accent ?? AppColors.textTertiary),
                  const SizedBox(width: AppSpacing.xs),
                ],
                if (accent != null) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.metricLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.metricValue,
            ),
            if (detail != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                detail!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: typography.metricSupporting,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A compact responsive strip of [AppSummaryMetric]s on one bordered surface.
/// Two columns on mobile, more on wider canvases; never a wall of giant cards.
class AppSummaryStrip extends StatelessWidget {
  const AppSummaryStrip({super.key, required this.metrics});

  final List<AppSummaryMetric> metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: AppResponsiveGrid(
        minItemWidth: 150,
        maxColumns: metrics.length > 4 ? 4 : metrics.length,
        children: [
          for (final metric in metrics)
            AppReportMetric(
              label: metric.label,
              value: metric.value,
              detail: metric.detail,
              icon: metric.icon,
              status: metric.status,
            ),
        ],
      ),
    );
  }
}

/// Convenience conversion from [AppSummaryMetric] to the report metric widget.
AppReportMetric reportMetricOf(AppSummaryMetric metric) => AppReportMetric(
  label: metric.label,
  value: metric.value,
  detail: metric.detail,
  icon: metric.icon,
  status: metric.status,
);

// ===========================================================================
// Report toolbar
// ===========================================================================

/// Specialized report filter surface. Unlike the cramped list toolbar, it
/// groups a leading context (scope/period), structured filters and secondary
/// actions on one calm bordered surface that wraps cleanly on mobile.
class AppReportToolbar extends StatelessWidget {
  const AppReportToolbar({
    super.key,
    this.leading,
    this.filters = const [],
    this.actions = const [],
  });

  final Widget? leading;
  final List<Widget> filters;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    if (leading == null && filters.isEmpty && actions.isEmpty) {
      return const SizedBox.shrink();
    }
    return _BorderedSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            DefaultTextStyle.merge(
              style: AppTypography.of(context).caption,
              child: leading!,
            ),
            if (filters.isNotEmpty || actions.isNotEmpty)
              const SizedBox(height: AppSpacing.md),
          ],
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [...filters, ...actions],
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Legend
// ===========================================================================

class AppLegendItem {
  const AppLegendItem(this.label, this.color);
  final String label;
  final Color color;
}

/// Compact semantic legend used by calendars, reports and maps. Colour is
/// always paired with a text label so meaning is never colour-only.
class AppLegend extends StatelessWidget {
  const AppLegend({super.key, required this.items});

  final List<AppLegendItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.xs,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(item.label, style: AppTypography.of(context).caption),
            ],
          ),
      ],
    );
  }
}

/// Helper for a summary metric's responsive column count (kept internal to the
/// presentation layer; layout is width-driven, never hard-coded per screen).
AppSize workspaceSizeOf(BuildContext context) => AppBreakpoints.of(context);
