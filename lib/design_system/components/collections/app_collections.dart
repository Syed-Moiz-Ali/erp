import 'package:flutter/material.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/design_system/components/buttons/app_buttons.dart';
import 'package:modular_erp/design_system/components/cards/app_cards.dart';
import 'package:modular_erp/design_system/components/empty_states/app_empty_state.dart';
import 'package:modular_erp/design_system/components/skeletons/app_skeleton.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/design_system/theme/app_colors.dart';
import 'package:modular_erp/design_system/theme/app_dimensions.dart';
import 'package:modular_erp/design_system/theme/app_radius.dart';
import 'package:modular_erp/design_system/theme/app_spacing.dart';
import 'package:modular_erp/design_system/theme/app_typography.dart';
import 'package:modular_erp/l10n/l10n.dart';

/// Standardized collection toolbar.
///
/// One control order for every list — Search → Filters → Sort → secondary
/// controls → result count — so operational screens feel predictable. Search is
/// meaningfully sized on desktop (never stretched across the whole page) and
/// expands to full width on compact/tablet layouts.
class AppCollectionToolbar extends StatelessWidget {
  const AppCollectionToolbar({
    super.key,
    this.search,
    this.filterButton,
    this.sort,
    this.secondary = const [],
    this.resultCount,
    this.activeFilters,
    this.searchMaxWidth = 420,
  });

  final Widget? search;
  final Widget? filterButton;
  final Widget? sort;

  /// Extra contextual controls placed after Filters/Sort.
  final List<Widget> secondary;
  final Widget? resultCount;
  final Widget? activeFilters;
  final double searchMaxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = AppBreakpoints.classify(constraints.maxWidth);
        final controls = <Widget>[
          if (filterButton != null) filterButton!,
          if (sort != null) sort!,
          ...secondary,
        ];
        // Stack controls on compact and tablet widths; only expanded canvases
        // lay the toolbar out as a single row.
        if (size == AppSize.compact || size == AppSize.medium) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (search != null) search!,
              if (controls.isNotEmpty || resultCount != null) ...[
                if (search != null) const SizedBox(height: AppSpacing.md),
                if (controls.isNotEmpty)
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: controls,
                  ),
                if (resultCount != null) ...[
                  if (controls.isNotEmpty)
                    const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: resultCount!,
                  ),
                ],
              ],
              if (activeFilters != null) ...[
                const SizedBox(height: AppSpacing.md),
                activeFilters!,
              ],
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (search != null) ...[
                  Flexible(
                    flex: 5,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: searchMaxWidth),
                      child: search!,
                    ),
                  ),
                  if (controls.isNotEmpty || resultCount != null)
                    const SizedBox(width: AppSpacing.lg),
                ],
                ...controls.expand(
                  (w) => [w, const SizedBox(width: AppSpacing.sm)],
                ),
                const Spacer(),
                if (resultCount != null) resultCount!,
              ],
            ),
            if (activeFilters != null) ...[
              const SizedBox(height: AppSpacing.md),
              activeFilters!,
            ],
          ],
        );
      },
    );
  }
}

/// Result-count text rendered beside the collection controls (never a giant
/// badge next to the page title).
class AppResultCount extends StatelessWidget {
  const AppResultCount({
    super.key,
    required this.filtered,
    this.total,
    this.label,
  });

  final int filtered;
  final int? total;

  /// Optional pre-localized label; when omitted the shared generic wording is
  /// used so every list reads consistently.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final numbers = AppNumberFormatter(Localizations.localeOf(context));
    final filteredText = numbers.integer(filtered);
    final text =
        label ??
        (total != null && total != filtered
            ? context.l10n.resultsCountFiltered(
                filteredText,
                numbers.integer(total!),
              )
            : context.l10n.resultsCount(filteredText));
    return Semantics(
      liveRegion: true,
      label: text,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.of(
          context,
        ).caption.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

/// Single standardized "Filters" control with an active-filter count.
class AppFilterButton extends StatelessWidget {
  const AppFilterButton({
    super.key,
    required this.activeCount,
    required this.onPressed,
    this.label,
  });

  final int activeCount;
  final VoidCallback? onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final base = label ?? context.l10n.filters;
    final numbers = AppNumberFormatter(Localizations.localeOf(context));
    return AppSecondaryButton(
      label: activeCount == 0
          ? base
          : '$base (${numbers.integer(activeCount)})',
      icon: Icons.tune,
      onPressed: onPressed,
    );
  }
}

/// One removable active filter.
class AppActiveFilter {
  const AppActiveFilter({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;
}

/// Row of removable active-filter chips with an optional "Clear all" action.
class AppActiveFilters extends StatelessWidget {
  const AppActiveFilters({super.key, required this.filters, this.onClearAll});

  final List<AppActiveFilter> filters;
  final VoidCallback? onClearAll;

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final filter in filters) _ActiveFilterChip(filter: filter),
        if (onClearAll != null && filters.length > 1)
          AppTextButton(
            label: context.l10n.clearAll,
            size: AppButtonSize.small,
            onPressed: onClearAll,
          ),
      ],
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.filter});

  final AppActiveFilter filter;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    return Semantics(
      button: true,
      label: context.l10n.removeFilter(filter.label),
      child: Material(
        color: AppColors.brandSubtle,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: InkWell(
          onTap: filter.onRemove,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          child: Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(color: AppColors.brandBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    filter.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.caption.copyWith(
                      color: AppColors.brandPrimary,
                      fontWeight: AppTypography.weightMedium,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.close,
                  size: 14,
                  color: AppColors.brandPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact, standardized sort selector. Only render where the underlying query
/// layer actually supports sorting.
class AppSortControl<T> extends StatelessWidget {
  const AppSortControl({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.width = 220,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final double width;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    return SizedBox(
      width: width,
      child: Semantics(
        label: label ?? context.l10n.sortLabel,
        child: Container(
          height: AppDimensions.inputHeight,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppRadius.field),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.sort,
                size: AppDimensions.iconSm,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    isExpanded: true,
                    isDense: true,
                    borderRadius: BorderRadius.circular(AppRadius.radiusMd),
                    icon: const Icon(Icons.expand_more, size: 18),
                    style: typography.inputValue,
                    items: items,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One coherent collection surface around desktop tables: neutral surface,
/// border, rounding and the shared table foundation — never one card per row.
class AppCollectionSurface extends StatelessWidget {
  const AppCollectionSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      AppCard(padding: EdgeInsets.zero, child: child);
}

/// Standard pagination: previous / page information / next. Uses real
/// pagination metadata so range and page counts are accurate.
class AppPagination extends StatelessWidget {
  const AppPagination({
    super.key,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.onPageChanged,
  });

  final int page, pageSize, total;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final numbers = AppNumberFormatter(Localizations.localeOf(context));
    final pages = total == 0 ? 0 : (total - 1) ~/ pageSize + 1;
    if (total == 0) return const SizedBox.shrink();
    return Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.paginationSummary(
              numbers.integer(page * pageSize + 1),
              numbers.integer(((page + 1) * pageSize).clamp(0, total)),
              numbers.integer(total),
            ),
            style: AppTypography.of(
              context,
            ).caption.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Text(
          context.l10n.pageOf(
            numbers.integer(page + 1),
            numbers.integer(pages),
          ),
          style: AppTypography.of(
            context,
          ).caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.md),
        AppIconButton(
          icon: isRtl ? Icons.chevron_right : Icons.chevron_left,
          tooltip: context.l10n.previousPage,
          onPressed: page > 0 ? () => onPageChanged(page - 1) : null,
        ),
        const SizedBox(width: AppSpacing.xs),
        AppIconButton(
          icon: isRtl ? Icons.chevron_left : Icons.chevron_right,
          tooltip: context.l10n.nextPage,
          onPressed: (page + 1) * pageSize < total
              ? () => onPageChanged(page + 1)
              : null,
        ),
      ],
    );
  }
}

/// Geometry-aware collection loading state: table-row skeletons on desktop and
/// record-card skeletons on compact layouts, so loading resembles the eventual
/// content instead of a lone centered spinner.
class AppCollectionSkeleton extends StatelessWidget {
  const AppCollectionSkeleton({
    super.key,
    this.rows = 6,
    this.columns = 4,
    this.mobile,
  });

  final int rows;
  final int columns;

  /// Force the mobile card presentation; otherwise chosen from the viewport.
  final bool? mobile;

  @override
  Widget build(BuildContext context) {
    final useMobile = mobile ?? AppBreakpoints.of(context) == AppSize.compact;
    if (useMobile) {
      return Column(
        children: [
          for (var i = 0; i < rows; i++)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(child: AppSkeleton(height: 64)),
            ),
        ],
      );
    }
    return AppCollectionSurface(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppTableSkeleton(rows: rows, columns: columns),
      ),
    );
  }
}

/// Distinct collection empty states: no data (with an optional permitted CTA)
/// vs. no results for the current search/filters (with clear filters), so a
/// failed query never masquerades as an empty result set.
class AppCollectionEmptyState extends StatelessWidget {
  const AppCollectionEmptyState.noData({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.inbox_outlined,
  }) : _showClear = false,
       onClearFilters = null;

  const AppCollectionEmptyState.noResults({
    super.key,
    required this.title,
    required this.message,
    this.onClearFilters,
    this.icon = Icons.search_off_outlined,
  }) : _showClear = true,
       actionLabel = null,
       onAction = null;

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onClearFilters;
  final bool _showClear;

  @override
  Widget build(BuildContext context) {
    final clear = _showClear ? onClearFilters : null;
    return SizedBox(
      width: double.infinity,
      child: AppEmptyState(
        title: title,
        message: message,
        icon: icon,
        actionLabel: clear != null
            ? context.l10n.clearFilters
            : (actionLabel != null && onAction != null ? actionLabel : null),
        onAction: clear ?? onAction,
      ),
    );
  }
}
