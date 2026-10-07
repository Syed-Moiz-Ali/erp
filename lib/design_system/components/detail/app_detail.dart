import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/components/avatars/app_avatar.dart';
import 'package:modular_erp/design_system/components/cards/app_cards.dart';
import 'package:modular_erp/design_system/components/empty_states/app_empty_state.dart';
import 'package:modular_erp/design_system/components/headers/app_headers.dart';
import 'package:modular_erp/design_system/components/layout/app_page.dart';
import 'package:modular_erp/design_system/components/navigation/app_action_menu.dart';
import 'package:modular_erp/design_system/components/status/app_status_badge.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/design_system/theme/app_colors.dart';
import 'package:modular_erp/design_system/theme/app_dimensions.dart';
import 'package:modular_erp/design_system/theme/app_radius.dart';
import 'package:modular_erp/design_system/theme/app_spacing.dart';
import 'package:modular_erp/design_system/theme/app_typography.dart';
import 'package:modular_erp/l10n/l10n.dart';

/// UI-6 shared detail foundation.
///
/// These primitives give every read/detail/operational surface one visual
/// language: a strong record header, a consistent read-only information
/// presentation (never disabled inputs), related-record links, timeline,
/// evidence galleries and secondary audit metadata.
///
/// They are deliberately domain-neutral. Domain views build on top of them.

// ===========================================================================
// Values / empty convention
// ===========================================================================

/// The single empty-value convention for detail pages. Every information grid
/// and read-only field renders a blank/`null` value through this helper so the
/// product never alternates between `null`, `N/A`, `-` and blank.
abstract final class AppDetailValue {
  static String of(BuildContext context, String? value) {
    if (value == null) return context.l10n.notProvided;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return context.l10n.notProvided;
    return value;
  }
}

/// Renders an identifier (email, phone, transaction/business code) so that it
/// stays directionally readable (LTR) even inside an RTL layout.
class AppIdentifierText extends StatelessWidget {
  const AppIdentifierText(
    this.value, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  final String value;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    final ltr = Directionality.of(context) == TextDirection.rtl;
    final text = Text(
      value,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: ltr ? TextAlign.left : TextAlign.start,
    );
    if (!ltr) return text;
    return Directionality(textDirection: TextDirection.ltr, child: text);
  }
}

// ===========================================================================
// Detail page + record header
// ===========================================================================

/// Standard detail page shell. Wraps the global [AppPage] (single 1200px
/// content width, centered, shell-owned padding) and lays out sections with a
/// uniform vertical rhythm.
class AppDetailPage extends StatelessWidget {
  const AppDetailPage({
    super.key,
    required this.header,
    required this.children,
    this.filters,
    this.animateEntrance = true,
    this.scrollPhysics,
  });

  final Widget header;
  final List<Widget> children;
  final Widget? filters;
  final bool animateEntrance;
  final ScrollPhysics? scrollPhysics;

  @override
  Widget build(BuildContext context) => AppPage(
    header: header,
    filters: filters,
    animateEntrance: animateEntrance,
    scrollPhysics: scrollPhysics,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.xxl),
          children[i],
        ],
      ],
    ),
  );
}

/// The record header: breadcrumb context, strong record identity, status near
/// the identity, an optional compact metadata row, and a disciplined action
/// hierarchy (one primary, one/two secondary, destructive, More menu).
class AppDetailHeader extends StatelessWidget {
  const AppDetailHeader({
    super.key,
    required this.title,
    this.businessId,
    this.description,
    this.leading,
    this.status,
    this.breadcrumbs,
    this.metadata = const [],
    this.primaryAction,
    this.secondaryActions = const [],
    this.destructiveAction,
    this.overflowActions = const [],
  });

  final String title;
  final String? businessId;
  final String? description;
  final Widget? leading;
  final Widget? status;
  final Widget? breadcrumbs;
  final List<AppMetadataItem> metadata;
  final Widget? primaryAction;
  final List<Widget> secondaryActions;
  final Widget? destructiveAction;
  final List<AppDetailAction> overflowActions;

  @override
  Widget build(BuildContext context) {
    final hasActions =
        primaryAction != null ||
        secondaryActions.isNotEmpty ||
        destructiveAction != null ||
        overflowActions.isNotEmpty;
    final identity = AppRecordIdentity(
      title: title,
      businessId: businessId,
      description: description,
      leading: leading,
      status: status,
    );
    final actions = hasActions
        ? AppDetailActions(
            primary: primaryAction,
            secondary: secondaryActions,
            destructive: destructiveAction,
            overflow: overflowActions,
          )
        : null;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            AppBreakpoints.classify(constraints.maxWidth) == AppSize.compact;
        final top = compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  identity,
                  if (actions != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    actions,
                  ],
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: identity),
                  if (actions != null) ...[
                    const SizedBox(width: AppSpacing.lg),
                    Flexible(
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: actions,
                      ),
                    ),
                  ],
                ],
              );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (breadcrumbs != null) ...[
              breadcrumbs!,
              const SizedBox(height: AppSpacing.md),
            ],
            top,
            if (metadata.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              AppMetadataRow(items: metadata),
            ],
          ],
        );
      },
    );
  }
}

/// Strong record identity: optional avatar/leading, the title, the human
/// business identifier and primary descriptive text, with the status adjacent
/// to the title.
class AppRecordIdentity extends StatelessWidget {
  const AppRecordIdentity({
    super.key,
    required this.title,
    this.businessId,
    this.description,
    this.leading,
    this.status,
  });

  final String title;
  final String? businessId;
  final String? description;
  final Widget? leading;
  final Widget? status;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSpacing.lg),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: typography.pageTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (status != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    status!,
                  ],
                ],
              ),
              if (businessId != null && businessId!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                AppIdentifierText(businessId!, style: typography.code),
              ],
              if (description != null && description!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description!,
                  style: typography.bodySecondary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Status rendered adjacent to record identity. Always text-bearing (never
/// color-only) and announced as a coherent phrase.
class AppDetailStatus extends StatelessWidget {
  const AppDetailStatus({
    super.key,
    required this.label,
    this.status = AppStatus.neutral,
    this.icon,
    this.showDot = false,
  });

  final String label;
  final AppStatus status;
  final IconData? icon;
  final bool showDot;

  @override
  Widget build(BuildContext context) => AppStatusBadge(
    label: label,
    status: status,
    icon: icon,
    showDot: showDot,
    isPill: true,
  );
}

/// One item in the header/overflow action hierarchy.
class AppDetailAction {
  const AppDetailAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool destructive;
}

/// Action hierarchy for the record header. Primary first, then secondary,
/// then destructive, and everything else behind a More menu (UI-6 §13).
class AppDetailActions extends StatelessWidget {
  const AppDetailActions({
    super.key,
    this.primary,
    this.secondary = const [],
    this.destructive,
    this.overflow = const [],
  });

  final Widget? primary;
  final List<Widget> secondary;
  final Widget? destructive;
  final List<AppDetailAction> overflow;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.end,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [
      if (primary != null) primary!,
      ...secondary,
      if (destructive != null) destructive!,
      if (overflow.isNotEmpty)
        AppActionMenu(
          tooltip: context.l10n.moreActionsLabel,
          actions: [
            for (final action in overflow)
              AppMenuAction(
                label: (_) => action.label,
                onPressed: action.onPressed ?? () {},
              ),
          ],
        ),
    ],
  );
}

// ===========================================================================
// Information presentation
// ===========================================================================

/// A single read-only information value.
class AppInfoItem {
  const AppInfoItem({
    required this.label,
    this.value,
    this.identifier = false,
    this.multiline = false,
  });

  final String label;
  final String? value;
  final bool identifier;
  final bool multiline;
}

/// Responsive read-only information grid.
///
/// Mobile: one column. Tablet: two columns. Desktop: up to four columns
/// depending on available width. It is never a disabled input and always
/// applies the single empty-value convention.
class AppInfoGrid extends StatelessWidget {
  const AppInfoGrid({super.key, required this.items, this.maxColumns = 4});

  final List<AppInfoItem> items;
  final int maxColumns;

  int _columns(double width) {
    final size = AppBreakpoints.classify(width);
    final desired = switch (size) {
      AppSize.compact => 1,
      AppSize.medium => 2,
      AppSize.expanded => width >= 1100 ? 3 : 2,
      AppSize.large => 4,
    };
    return desired > maxColumns ? maxColumns : desired;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columns(constraints.maxWidth);
        final width =
            (constraints.maxWidth - AppSpacing.lg * (columns - 1)) / columns;
        return Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: _AppInfoItemView(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _AppInfoItemView extends StatelessWidget {
  const _AppInfoItemView({required this.item});
  final AppInfoItem item;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    final value = AppDetailValue.of(context, item.value);
    final valueWidget = item.identifier
        ? AppIdentifierText(
            value,
            style: typography.body,
            maxLines: item.multiline ? 4 : 1,
            overflow: TextOverflow.ellipsis,
          )
        : Text(
            value,
            style: typography.body,
            maxLines: item.multiline ? null : 3,
            overflow: item.multiline ? null : TextOverflow.ellipsis,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.label, style: typography.metadata),
        const SizedBox(height: AppSpacing.xs),
        valueWidget,
      ],
    );
  }
}

/// A meaningful business section on a detail page. [surface] controls the
/// container so pages can mix plain sections, subtle bordered panels and
/// small cards without nested-card syndrome (UI-6 §22).
enum AppInfoSectionSurface { plain, bordered, panel }

class AppInfoSection extends StatelessWidget {
  const AppInfoSection({
    super.key,
    required this.title,
    this.subtitle,
    this.count,
    this.action,
    this.fields = const [],
    this.child,
    this.surface = AppInfoSectionSurface.plain,
  });

  final String title;
  final String? subtitle;
  final int? count;
  final Widget? action;
  final List<AppInfoItem> fields;
  final Widget? child;
  final AppInfoSectionSurface surface;

  @override
  Widget build(BuildContext context) {
    final body = fields.isNotEmpty
        ? AppInfoGrid(items: fields)
        : child ?? const SizedBox.shrink();
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: count == null ? title : ('$title ($count)'),
          subtitle: subtitle,
          action: action,
        ),
        const SizedBox(height: AppSpacing.lg),
        body,
      ],
    );
    return switch (surface) {
      AppInfoSectionSurface.plain => content,
      AppInfoSectionSurface.panel => AppCard(child: content),
      AppInfoSectionSurface.bordered => AppDetailPanel(child: content),
    };
  }
}

/// Subtle bordered detail surface used by context banners, audit blocks and
/// operational panels. Uses UI-1 tokens only.
class AppDetailPanel extends StatelessWidget {
  const AppDetailPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.accent,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final AppStatus? accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = accent == null
        ? null
        : (isDark ? accent!.darkColor : accent!.color);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderDefault,
        ),
      ),
      child: accentColor == null
          ? Padding(padding: padding, child: child)
          : IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 3, color: accentColor),
                  Expanded(
                    child: Padding(padding: padding, child: child),
                  ),
                ],
              ),
            ),
    );
  }
}

// ===========================================================================
// Metadata row
// ===========================================================================

class AppMetadataItem {
  const AppMetadataItem({required this.label, this.value, this.icon});
  final String label;
  final String? value;
  final IconData? icon;
}

/// Compact horizontal metadata strip (e.g. date · priority · technician).
class AppMetadataRow extends StatelessWidget {
  const AppMetadataRow({super.key, required this.items});
  final List<AppMetadataItem> items;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark
        ? AppColors.darkTextTertiary
        : AppColors.textTertiary;
    return Wrap(
      spacing: AppSpacing.xl,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (item.icon != null) ...[
                Icon(item.icon, size: AppDimensions.iconSm, color: labelColor),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(item.label, style: typography.metadata),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  AppDetailValue.of(context, item.value),
                  style: typography.bodySmall,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// ===========================================================================
// Context banner
// ===========================================================================

/// Compact context block placed directly below the header. Shows only the most
/// useful context for the screen (not the whole record).
class AppContextBanner extends StatelessWidget {
  const AppContextBanner({
    super.key,
    this.title,
    this.icon,
    required this.items,
    this.trailing,
  });

  final String? title;
  final IconData? icon;
  final List<AppInfoItem> items;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    return AppDetailPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || trailing != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: AppDimensions.iconSm, color: muted),
                  const SizedBox(width: AppSpacing.sm),
                ],
                if (title != null)
                  Expanded(child: Text(title!, style: typography.label))
                else
                  const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
            if (items.isNotEmpty) const SizedBox(height: AppSpacing.lg),
          ],
          AppInfoGrid(items: items),
        ],
      ),
    );
  }
}

// ===========================================================================
// Related record links
// ===========================================================================

/// A compact related-record link. Business IDs are clickable only when the
/// caller passes [onTap] (i.e. only when the permission/scope model allows the
/// destination). Without [onTap] it renders as a plain label so no link or
/// destination is exposed beyond granted access.
class AppRelatedRecordLink extends StatelessWidget {
  const AppRelatedRecordLink({
    super.key,
    required this.label,
    this.value,
    this.onTap,
  });

  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final linkColor = isDark ? AppColors.darkBrand : AppColors.textLink;
    final enabled = onTap != null;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: typography.metadata),
              const SizedBox(height: AppSpacing.xxs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: AppIdentifierText(
                      AppDetailValue.of(context, value),
                      style: enabled
                          ? typography.label.copyWith(color: linkColor)
                          : typography.label,
                    ),
                  ),
                  if (enabled) ...[
                    const SizedBox(width: AppSpacing.xxs),
                    Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.north_west
                          : Icons.north_east,
                      size: AppDimensions.iconXs,
                      color: linkColor,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
    if (!enabled) return content;
    final semanticText = '$label ${AppDetailValue.of(context, value)}';
    return Semantics(
      button: true,
      label: semanticText,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radiusSm),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: AppSpacing.xxs,
          ),
          child: content,
        ),
      ),
    );
  }
}

// ===========================================================================
// Activity timeline
// ===========================================================================

/// A single structured business activity event.
class AppActivityEntry {
  const AppActivityEntry({
    required this.id,
    required this.title,
    required this.time,
    this.icon = Icons.circle_outlined,
    this.actor,
    this.detail,
    this.metadata = const [],
    this.status = AppStatus.neutral,
  });

  final String id;
  final String title;
  final String time;
  final IconData icon;
  final String? actor;
  final String? detail;
  final List<String> metadata;
  final AppStatus status;
}

/// Compact activity timeline fed exclusively by structured business events.
/// Empty timelines render a compact inline empty state, never a blank panel.
class AppActivityTimeline extends StatelessWidget {
  const AppActivityTimeline({
    super.key,
    required this.items,
    this.emptyMessage,
    this.maxItems = 20,
  });

  final List<AppActivityEntry> items;
  final String? emptyMessage;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AppEmptySection(
        message: emptyMessage ?? context.l10n.noActivityYet,
        icon: Icons.history,
      );
    }
    final shown = items.length > maxItems ? items.sublist(0, maxItems) : items;
    final typography = AppTypography.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? AppColors.darkBorder : AppColors.border;
    final muted = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < shown.length; i++)
          Padding(
            key: ValueKey(shown[i].id),
            padding: EdgeInsets.only(
              bottom: i == shown.length - 1 ? 0 : AppSpacing.lg,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(
                      shown[i].icon,
                      size: AppDimensions.iconSm,
                      color: shown[i].status.color,
                    ),
                    if (i != shown.length - 1)
                      Container(
                        width: 1,
                        height: AppSpacing.xxl,
                        margin: const EdgeInsets.only(top: AppSpacing.xs),
                        color: lineColor,
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.xxs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(shown[i].title, style: typography.label),
                          Text(shown[i].time, style: typography.caption),
                          if (shown[i].actor != null &&
                              shown[i].actor!.isNotEmpty)
                            Text(shown[i].actor!, style: typography.caption),
                        ],
                      ),
                      if (shown[i].detail != null &&
                          shown[i].detail!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(shown[i].detail!, style: typography.bodySmall),
                      ],
                      if (shown[i].metadata.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          shown[i].metadata.join(' · '),
                          style: typography.metadata.copyWith(color: muted),
                        ),
                      ],
                    ],
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
// Evidence / attachments
// ===========================================================================

class AppEvidenceItem {
  const AppEvidenceItem({
    required this.id,
    this.description,
    this.imageUrl,
    this.thumbnail,
    this.fileType,
    this.onOpen,
  });

  final String id;
  final String? description;
  final String? imageUrl;
  final Widget? thumbnail;
  final String? fileType;
  final VoidCallback? onOpen;
}

/// Polished read-only evidence gallery. Responsive thumbnail grid (mobile two
/// columns, more on wider canvases) with a compact empty state, no eager
/// full-resolution decode.
class AppEvidenceGallery extends StatelessWidget {
  const AppEvidenceGallery({
    super.key,
    required this.items,
    this.emptyMessage,
    this.imageWidth = 320,
  });

  final List<AppEvidenceItem> items;
  final String? emptyMessage;

  /// Decode hint passed to [Image.network] so thumbnails never decode at full
  /// resolution.
  final int imageWidth;

  int _columns(double width) => switch (AppBreakpoints.classify(width)) {
    AppSize.compact => 2,
    AppSize.medium => 3,
    AppSize.expanded => 4,
    AppSize.large => 4,
  };

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AppEmptySection(
        message: emptyMessage ?? context.l10n.noEvidenceYet,
        icon: Icons.photo_library_outlined,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columns(constraints.maxWidth);
        final width =
            (constraints.maxWidth - AppSpacing.md * (columns - 1)) / columns;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: _AppEvidenceTile(item: item, imageWidth: imageWidth),
              ),
          ],
        );
      },
    );
  }
}

class _AppEvidenceTile extends StatelessWidget {
  const _AppEvidenceTile({required this.item, required this.imageWidth});
  final AppEvidenceItem item;
  final int imageWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typography = AppTypography.of(context);
    final tile = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.radiusSm),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceMuted
                    : AppColors.surfaceSubtle,
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.borderDefault,
                ),
                borderRadius: BorderRadius.circular(AppRadius.radiusSm),
              ),
              child:
                  item.thumbnail ??
                  (item.imageUrl != null
                      ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          cacheWidth: imageWidth,
                          errorBuilder: (context, _, _) => _fallback(isDark),
                        )
                      : _fallback(isDark)),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          item.description?.trim().isNotEmpty == true
              ? item.description!
              : context.l10n.noAttachmentDescription,
          style: typography.caption,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
    if (item.onOpen == null) return tile;
    final semanticText =
        '${context.l10n.openAttachmentLabel}: ${item.description ?? item.id}';
    return Semantics(
      button: true,
      label: semanticText,
      child: InkWell(
        onTap: item.onOpen,
        borderRadius: BorderRadius.circular(AppRadius.radiusSm),
        child: tile,
      ),
    );
  }

  Widget _fallback(bool isDark) => Center(
    child: Icon(
      Icons.image_outlined,
      size: AppDimensions.iconLg,
      color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
    ),
  );
}

/// Full-size attachment preview surface (used inside a dialog). Resolution is
/// still bounded by the widget's constraints.
class AppAttachmentPreview extends StatelessWidget {
  const AppAttachmentPreview({
    super.key,
    required this.imageUrl,
    this.description,
    this.imageWidth = 1024,
  });

  final String imageUrl;
  final String? description;
  final int imageWidth;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.radiusMd),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            cacheWidth: imageWidth,
            errorBuilder: (context, _, _) => const SizedBox(
              height: 160,
              child: Center(child: Icon(Icons.broken_image_outlined)),
            ),
          ),
        ),
        if (description != null && description!.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(description!, style: typography.bodySmall),
        ],
      ],
    );
  }
}

// ===========================================================================
// Operational action panel
// ===========================================================================

class AppOperationalFact {
  const AppOperationalFact({
    required this.label,
    this.value,
    this.status = AppStatus.neutral,
  });
  final String label;
  final String? value;
  final AppStatus status;
}

/// One clear operational action area for action-heavy records: current state,
/// key facts, a primary operational action and secondary/destructive actions.
class AppOperationalActionPanel extends StatelessWidget {
  const AppOperationalActionPanel({
    super.key,
    required this.title,
    this.statusLabel,
    this.status = AppStatus.neutral,
    this.facts = const [],
    this.primaryAction,
    this.secondaryActions = const [],
    this.destructiveAction,
    this.accent,
  });

  final String title;
  final String? statusLabel;
  final AppStatus status;
  final List<AppOperationalFact> facts;
  final Widget? primaryAction;
  final List<Widget> secondaryActions;
  final Widget? destructiveAction;
  final AppStatus? accent;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    return AppDetailPanel(
      accent: accent ?? (status == AppStatus.neutral ? null : status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: typography.cardTitle)),
              if (statusLabel != null)
                AppDetailStatus(label: statusLabel!, status: status),
            ],
          ),
          if (facts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            AppInfoGrid(
              items: [
                for (final fact in facts)
                  AppInfoItem(label: fact.label, value: fact.value),
              ],
              maxColumns: 3,
            ),
          ],
          if (primaryAction != null ||
              secondaryActions.isNotEmpty ||
              destructiveAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (primaryAction != null) primaryAction!,
                ...secondaryActions,
                if (destructiveAction != null) destructiveAction!,
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ===========================================================================
// Audit metadata
// ===========================================================================

/// Secondary audit metadata (created/updated by and at). Rendered compactly at
/// the bottom of a detail page, never a hero.
class AppAuditMetadata extends StatelessWidget {
  const AppAuditMetadata({
    super.key,
    this.title,
    this.items = const [],
    this.child,
  });

  final String? title;
  final List<AppInfoItem> items;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if ((items.isEmpty) && child == null) return const SizedBox.shrink();
    final typography = AppTypography.of(context);
    return AppDetailPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? context.l10n.recordInformation,
            style: typography.label,
          ),
          const SizedBox(height: AppSpacing.md),
          if (child != null) child! else AppInfoGrid(items: items),
        ],
      ),
    );
  }
}

// ===========================================================================
// Empty / error
// ===========================================================================

/// Compact inline empty state for a section. Deliberately small: it never
/// allocates a giant blank panel.
class AppEmptySection extends StatelessWidget {
  const AppEmptySection({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          Icon(icon, size: AppDimensions.iconMd, color: muted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTypography.of(context).bodySmall.copyWith(color: muted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Detail-scoped error state. Reuses the shared error treatment but keeps a
/// retry affordance.
class AppDetailErrorState extends StatelessWidget {
  const AppDetailErrorState({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) =>
      AppErrorState(message: message, onRetry: onRetry);
}

// ===========================================================================
// Convenience factories
// ===========================================================================

/// Builds an identity header for a person/employee record.
class AppPersonIdentity extends StatelessWidget {
  const AppPersonIdentity({super.key, required this.name, this.radius = 24});
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) => AppAvatar(name: name, radius: radius);
}

/// A neutral icon avatar for non-person records (site, team, document).
class AppRecordGlyph extends StatelessWidget {
  const AppRecordGlyph({
    super.key,
    required this.icon,
    this.status = AppStatus.brand,
    this.size = 44,
  });

  final IconData icon;
  final AppStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? status.darkColor : status.color;
    final bg = isDark ? color.withValues(alpha: .16) : status.subtleColor;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.radiusMd),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Icon(icon, size: size * .5, color: color),
    );
  }
}
