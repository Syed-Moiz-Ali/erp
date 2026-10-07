import 'package:flutter/material.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/design_system/theme/app_colors.dart';
import 'package:modular_erp/design_system/theme/app_typography.dart';
import 'package:modular_erp/design_system/theme/app_spacing.dart';
import 'package:modular_erp/design_system/theme/app_radius.dart';
import 'package:modular_erp/design_system/theme/app_dimensions.dart';
import 'package:modular_erp/design_system/theme/app_motion.dart';
import 'package:modular_erp/design_system/components/buttons/app_buttons.dart';
import 'package:modular_erp/design_system/components/layout/app_auth_layout.dart';

/// Canonical desktop navigation order. Sections always render in this order,
/// independent of the per-destination `order` that only sorts items *within* a
/// section. Dashboard leads, modules follow, account utilities sit at the base.
const List<NavigationSection> _sectionOrder = [
  NavigationSection.dashboard,
  NavigationSection.hr,
  NavigationSection.services,
  NavigationSection.settings,
  NavigationSection.account,
];

/// One configured navigation row. Shared by the desktop sidebar, the tablet
/// rail, the compact bottom navigation and the mobile "More" sheet so the
/// selected/hover/focus/tooltip behavior is identical everywhere.
class AppSidebarItem extends StatelessWidget {
  const AppSidebarItem({
    super.key,
    required this.item,
    required this.selected,
    required this.onPressed,
    this.collapsed = false,
  });
  final ErpModule item;
  final bool selected, collapsed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = item.name(context.l10n);
    final scheme = Theme.of(context).colorScheme;
    final typography = AppTypography.of(context);
    final foreground = selected ? scheme.primary : scheme.onSurfaceVariant;
    final row = Padding(
      padding: EdgeInsetsDirectional.only(
        start: collapsed ? AppSpacing.sm : AppSpacing.md,
        end: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: collapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          if (selected && !collapsed) ...[
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(AppRadius.radiusFull),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Icon(
            selected ? item.selectedIcon ?? item.icon : item.icon,
            size: AppDimensions.iconControl,
            color: foreground,
          ),
          if (!collapsed) ...[
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.bodySmall.copyWith(
                  color: foreground,
                  fontWeight: selected
                      ? AppTypography.weightSemibold
                      : AppTypography.weightMedium,
                ),
              ),
            ),
          ],
        ],
      ),
    );
    final interactive = Semantics(
      selected: selected,
      button: true,
      label: label,
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.control),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.control),
          hoverColor: scheme.primary.withValues(alpha: .06),
          focusColor: scheme.primary.withValues(alpha: .10),
          child: SizedBox(height: AppDimensions.navigationTarget, child: row),
        ),
      ),
    );
    return collapsed
        ? Tooltip(message: label, child: interactive)
        : interactive;
  }
}

/// Alias matching the shell component vocabulary. The implementation is the
/// single shared [AppSidebarItem]; the two names describe the same control.
typedef AppNavigationItem = AppSidebarItem;

/// A labelled block of navigation items. Small semantic overline label, then
/// compact rows with centralized spacing. Groups with no visible items are
/// never constructed by the shell, so an inaccessible module disappears.
class AppNavigationGroup extends StatelessWidget {
  const AppNavigationGroup({
    super.key,
    required this.label,
    required this.children,
    this.collapsed = false,
    this.showLabel = true,
  });
  final String label;
  final List<Widget> children;
  final bool collapsed, showLabel;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final typography = AppTypography.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLabel && !collapsed) ...[
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.md,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.overline,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        for (final child in children)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: child,
          ),
      ],
    );
  }
}

/// Product identity row at the top of the sidebar. Uses the existing Bitlogix
/// product branding (never an invented name) and the semantic type scale.
class AppProductMark extends StatelessWidget {
  const AppProductMark({super.key, this.collapsed = false});
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [AppColors.brandSecondary, AppColors.brandPrimary],
        ),
        borderRadius: BorderRadius.circular(AppRadius.radiusMd),
      ),
      child: Center(
        child: BitlogixMark(
          size: 20,
          accent: Colors.white,
          highlight: const Color(0xFFE6D2E2),
        ),
      ),
    );
    if (collapsed) {
      return Tooltip(message: context.l10n.appName, child: mark);
    }
    return Row(
      children: [
        mark,
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            context.l10n.appName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.of(context).cardTitle,
          ),
        ),
      ],
    );
  }
}

/// Company context control. Deterministic initials avatar (no stock imagery)
/// plus the active company name. When only one company is accessible there is
/// no dropdown affordance — tapping simply shows the company information.
class AppCompanySwitcher extends StatelessWidget {
  const AppCompanySwitcher({
    super.key,
    required this.name,
    this.collapsed = false,
    this.onPressed,
    this.switchable = false,
  });
  final String name;
  final bool collapsed;
  final VoidCallback? onPressed;
  final bool switchable;

  String get _initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '•' : trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final typography = AppTypography.of(context);
    final avatar = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.radiusSm),
      ),
      child: Center(
        child: Text(
          _initial,
          style: typography.labelSmall.copyWith(
            color: scheme.primary,
            fontWeight: AppTypography.weightBold,
          ),
        ),
      ),
    );
    return Tooltip(
      message: collapsed ? name : context.l10n.shellCompanyInformation,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.control),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.control),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                avatar,
                if (!collapsed) ...[
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.label,
                    ),
                  ),
                  if (switchable)
                    Icon(
                      Icons.expand_more,
                      size: AppDimensions.iconSm,
                      color: scheme.onSurfaceVariant,
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Backwards-compatible alias for the company context control.
typedef AppCompanyArea = AppCompanySwitcher;

/// Top sidebar zone: product mark plus company context. Kept together so the
/// brand/company region stays usable while the navigation list scrolls.
class AppSidebarHeader extends StatelessWidget {
  const AppSidebarHeader({
    super.key,
    required this.companyName,
    this.collapsed = false,
    this.onCompanyPressed,
    this.switchable = false,
  });
  final String companyName;
  final bool collapsed;
  final VoidCallback? onCompanyPressed;
  final bool switchable;

  @override
  Widget build(BuildContext context) {
    final name = companyName.trim().isEmpty
        ? context.l10n.erpWorkspace
        : companyName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            top: AppSpacing.md,
            bottom: AppSpacing.sm,
            start: collapsed ? 0 : AppSpacing.sm,
            end: collapsed ? 0 : AppSpacing.sm,
          ),
          child: AppProductMark(collapsed: collapsed),
        ),
        AppCompanySwitcher(
          name: name,
          collapsed: collapsed,
          onPressed: onCompanyPressed,
          switchable: switchable,
        ),
      ],
    );
  }
}

/// Desktop primary sidebar. Four deliberate zones: product/company header,
/// Dashboard, grouped module navigation, and a lower account/utility footer.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.modules,
    required this.selectedRoute,
    required this.onNavigate,
    this.collapsed = false,
    this.large = false,
    this.companyName,
    this.onCompanyPressed,
    this.onToggle,
    this.switchableCompany = false,
  });
  final List<ErpModule> modules;
  final String selectedRoute;
  final ValueChanged<String> onNavigate;
  final bool collapsed, large;
  final String? companyName;
  final VoidCallback? onCompanyPressed, onToggle;
  final bool switchableCompany;

  String? _selectedId() {
    final matches = modules.where((m) => m.owns(selectedRoute)).toList()
      ..sort((a, b) => b.route.length.compareTo(a.route.length));
    return matches.firstOrNull?.id;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selectedId = _selectedId();
    final bySection = <NavigationSection, List<ErpModule>>{};
    for (final item in modules) {
      bySection.putIfAbsent(item.section, () => []).add(item);
    }
    final dashboard =
        bySection[NavigationSection.dashboard] ?? const <ErpModule>[];
    final account = bySection[NavigationSection.account] ?? const <ErpModule>[];

    Widget itemWidget(ErpModule item) => AppSidebarItem(
      item: item,
      selected: item.id == selectedId,
      collapsed: collapsed,
      onPressed: () => onNavigate(item.route),
    );

    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppMotion.fast,
      curve: AppMotion.curveStandard,
      width: collapsed ? AppDimensions.sidebarCollapsed : AppDimensions.sidebar,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: BorderDirectional(
          end: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSidebarHeader(
                companyName: companyName ?? context.l10n.erpWorkspace,
                collapsed: collapsed,
                onCompanyPressed: onCompanyPressed,
                switchable: switchableCompany,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final group in _sectionOrder)
                      if (group == NavigationSection.dashboard)
                        for (final item in dashboard)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            child: itemWidget(item),
                          )
                      else if (group != NavigationSection.account)
                        AppNavigationGroup(
                          label: group.label(context.l10n),
                          collapsed: collapsed,
                          children: (bySection[group] ?? const <ErpModule>[])
                              .map(itemWidget)
                              .toList(),
                        ),
                  ],
                ),
              ),
              if (account.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Divider(color: scheme.outlineVariant),
                for (final item in account)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: itemWidget(item),
                  ),
              ],
              if (onToggle != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Align(
                    alignment: collapsed
                        ? Alignment.center
                        : AlignmentDirectional.centerEnd,
                    child: AppIconButton(
                      icon: _collapseIcon(context, collapsed),
                      tooltip: collapsed
                          ? context.l10n.shellExpandSidebar
                          : context.l10n.shellCollapseSidebar,
                      onPressed: onToggle,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _collapseIcon(BuildContext context, bool collapsed) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  if (collapsed) {
    return isRtl ? Icons.chevron_left : Icons.chevron_right;
  }
  return isRtl ? Icons.chevron_right : Icons.chevron_left;
}

/// Purpose-built compact/mobile navigation content: company context, Dashboard,
/// grouped module navigation and account access in one scrollable sheet. Used
/// by the mobile "More" surface; never a squeezed desktop sidebar.
class AppMobileNavigation extends StatelessWidget {
  const AppMobileNavigation({
    super.key,
    required this.modules,
    required this.selectedRoute,
    required this.onNavigate,
    this.companyName,
    this.onCompanyPressed,
    this.switchableCompany = false,
  });
  final List<ErpModule> modules;
  final String selectedRoute;
  final ValueChanged<String> onNavigate;
  final String? companyName;
  final VoidCallback? onCompanyPressed;
  final bool switchableCompany;

  @override
  Widget build(BuildContext context) {
    final selectedId =
        (modules.where((m) => m.owns(selectedRoute)).toList()
              ..sort((a, b) => b.route.length.compareTo(a.route.length)))
            .firstOrNull
            ?.id;
    final bySection = <NavigationSection, List<ErpModule>>{};
    for (final item in modules) {
      bySection.putIfAbsent(item.section, () => []).add(item);
    }
    Widget itemWidget(ErpModule item) => AppSidebarItem(
      item: item,
      selected: item.id == selectedId,
      onPressed: () => onNavigate(item.route),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSidebarHeader(
          companyName: companyName ?? context.l10n.erpWorkspace,
          onCompanyPressed: onCompanyPressed,
          switchable: switchableCompany,
        ),
        for (final group in _sectionOrder)
          if (group == NavigationSection.dashboard)
            for (final item
                in bySection[NavigationSection.dashboard] ??
                    const <ErpModule>[])
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: itemWidget(item),
              )
          else
            AppNavigationGroup(
              label: group.label(context.l10n),
              children: (bySection[group] ?? const <ErpModule>[])
                  .map(itemWidget)
                  .toList(),
            ),
      ],
    );
  }
}

/// Tablet navigation rail (compact icons + tooltips) for medium widths.
class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({
    super.key,
    required this.modules,
    required this.index,
    required this.onSelected,
    this.companyName,
    this.onCompanyPressed,
  });
  final List<ErpModule> modules;
  final int? index;
  final ValueChanged<int> onSelected;
  final String? companyName;
  final VoidCallback? onCompanyPressed;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: AppDimensions.rail,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: BorderDirectional(
          end: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        child: modules.length < 2
            ? ListView(
                children: [
                  for (var i = 0; i < modules.length; i++)
                    AppSidebarItem(
                      item: modules[i],
                      selected: index == i,
                      collapsed: true,
                      onPressed: () => onSelected(i),
                    ),
                ],
              )
            : NavigationRail(
                minWidth: AppDimensions.rail,
                selectedIndex: index,
                onDestinationSelected: onSelected,
                backgroundColor: scheme.surface,
                labelType: NavigationRailLabelType.none,
                indicatorColor: scheme.primaryContainer,
                groupAlignment: -1,
                scrollable: true,
                leading: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: AppCompanySwitcher(
                    name: companyName ?? context.l10n.erpWorkspace,
                    collapsed: true,
                    onPressed: onCompanyPressed,
                  ),
                ),
                destinations: modules
                    .map(
                      (m) => NavigationRailDestination(
                        icon: Tooltip(
                          message: m.name(context.l10n),
                          child: Icon(m.icon, size: AppDimensions.iconControl),
                        ),
                        selectedIcon: Tooltip(
                          message: m.name(context.l10n),
                          child: Icon(
                            m.selectedIcon ?? m.icon,
                            color: scheme.primary,
                            size: AppDimensions.iconControl,
                          ),
                        ),
                        label: Text(m.name(context.l10n)),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}

/// Compact bottom navigation. Deliberate, already-established ERP mobile
/// pattern: a small set of primary destinations plus More for the rest.
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.modules,
    required this.index,
    required this.onSelected,
  });
  final List<ErpModule> modules;
  final int index;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final typography = AppTypography.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              for (var i = 0; i < modules.length; i++)
                Expanded(
                  child: Semantics(
                    label: modules[i].name(context.l10n),
                    selected: i == index,
                    button: true,
                    child: InkWell(
                      onTap: () => onSelected(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                          horizontal: AppSpacing.xs,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: AppMotion.fast,
                              width: i == index ? 16 : 0,
                              height: 3,
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.xs + 1,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.radiusFull,
                                ),
                              ),
                            ),
                            Icon(
                              i == index
                                  ? modules[i].selectedIcon ?? modules[i].icon
                                  : modules[i].icon,
                              color: i == index
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                              size: AppDimensions.iconLg,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              modules[i].name(context.l10n),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: typography.caption.copyWith(
                                color: i == index
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                                fontWeight: i == index
                                    ? AppTypography.weightSemibold
                                    : AppTypography.weightMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
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
