import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';
import '../../../app/module_registry/module_registry.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_motion.dart';
import '../buttons/app_buttons.dart';
import '../layout/app_auth_layout.dart';

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
    final button = Semantics(
      selected: selected,
      button: true,
      label: label,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(0, AppDimensions.navigationTarget),
          ),
          padding: WidgetStatePropertyAll(
            EdgeInsetsDirectional.only(
              start: collapsed ? AppSpacing.sm : AppSpacing.md,
              end: AppSpacing.md,
              top: AppSpacing.sm,
              bottom: AppSpacing.sm,
            ),
          ),
          foregroundColor: WidgetStatePropertyAll(
            selected ? AppColors.brandPrimary : AppColors.textSecondary,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.focused)
                ? AppColors.brandPrimary.withValues(alpha: .08)
                : selected
                ? AppColors.brandSubtle
                : Colors.transparent,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: collapsed
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(
              selected ? item.selectedIcon ?? item.icon : item.icon,
              size: 18,
            ),
            if (!collapsed) ...[
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.of(context).bodySmall.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppColors.brandPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    final itemWithIndicator = selected
        ? Stack(
            children: [
              button,
              PositionedDirectional(
                start: 0,
                top: AppSpacing.sm,
                bottom: AppSpacing.sm,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary,
                    borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                  ),
                ),
              ),
            ],
          )
        : button;
    return collapsed
        ? Tooltip(message: label, child: itemWithIndicator)
        : itemWithIndicator;
  }
}

class AppCompanyArea extends StatelessWidget {
  const AppCompanyArea({
    super.key,
    required this.name,
    this.collapsed = false,
    this.onPressed,
  });
  final String name;
  final bool collapsed;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: collapsed ? name : context.l10n.shellCompanyInformation,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          mainAxisAlignment: collapsed
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [AppColors.brandSecondary, AppColors.brandPrimary],
                ),
                borderRadius: BorderRadius.circular(AppRadius.radiusMd + 1),
              ),
              child: Center(
                child: BitlogixMark(
                  size: 21,
                  accent: Colors.white,
                  highlight: const Color(0xFFE6D2E2),
                ),
              ),
            ),
            if (!collapsed) ...[
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.brandName,
                      style: AppTypography.of(context).bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      name,
                      style: AppTypography.of(context).caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

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
  });
  final List<ErpModule> modules;
  final String selectedRoute;
  final ValueChanged<String> onNavigate;
  final bool collapsed, large;
  final String? companyName;
  final VoidCallback? onCompanyPressed, onToggle;
  @override
  Widget build(BuildContext context) {
    final matches = modules.where((m) => m.owns(selectedRoute)).toList()
      ..sort((a, b) => b.route.length.compareTo(a.route.length));
    final selectedId = matches.firstOrNull?.id;
    final main = modules
        .where(
          (m) =>
              m.navigationGroup != NavigationGroup.account &&
              m.navigationGroup != NavigationGroup.administration,
        )
        .toList();
    final account = modules.where((m) => !main.contains(m)).toList();
    final groups = <NavigationGroup, List<ErpModule>>{};
    for (final item in main) {
      groups.putIfAbsent(item.navigationGroup, () => []).add(item);
    }
    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppMotion.fast,
      width: collapsed
          ? AppDimensions.sidebarCollapsed
          : large
          ? AppDimensions.sidebarLarge
          : AppDimensions.sidebar,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: BorderDirectional(end: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: [
              AppCompanyArea(
                name: companyName ?? context.l10n.erpWorkspace,
                collapsed: collapsed,
                onPressed: onCompanyPressed,
              ),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final group in groups.entries) ...[
                      if (!collapsed && group.value.length > 1)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: AppSpacing.md,
                            end: AppSpacing.md,
                            top: AppSpacing.md,
                            bottom: AppSpacing.sm,
                          ),
                          child: Text(
                            group.key.label(context.l10n),
                            style: AppTypography.of(context).caption.copyWith(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      for (final item in group.value)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: AppSidebarItem(
                            item: item,
                            selected: item.id == selectedId,
                            collapsed: collapsed,
                            onPressed: () => onNavigate(item.route),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              if (account.isNotEmpty) ...[
                const Divider(),
                for (final item in account)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: AppSidebarItem(
                      item: item,
                      selected: item.id == selectedId,
                      collapsed: collapsed,
                      onPressed: () => onNavigate(item.route),
                    ),
                  ),
              ],
              if (onToggle != null)
                Builder(
                  builder: (context) {
                    final isRtl =
                        Directionality.of(context) == TextDirection.rtl;
                    final expandIcon = isRtl
                        ? Icons.chevron_left
                        : Icons.chevron_right;
                    final collapseIcon = isRtl
                        ? Icons.chevron_right
                        : Icons.chevron_left;
                    return Align(
                      alignment: collapsed
                          ? Alignment.center
                          : AlignmentDirectional.centerEnd,
                      child: AppIconButton(
                        icon: collapsed ? expandIcon : collapseIcon,
                        tooltip: collapsed
                            ? context.l10n.shellExpandSidebar
                            : context.l10n.shellCollapseSidebar,
                        onPressed: onToggle,
                      ),
                    );
                  },
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

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
  Widget build(BuildContext context) => Container(
    width: AppDimensions.rail,
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: BorderDirectional(end: BorderSide(color: AppColors.border)),
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
              backgroundColor: AppColors.surface,
              labelType: NavigationRailLabelType.none,
              indicatorColor: AppColors.brand.withValues(alpha: .10),
              groupAlignment: -1,
              scrollable: true,
              leading: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: AppCompanyArea(
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
                        child: Icon(m.icon, size: AppSpacing.xl),
                      ),
                      selectedIcon: Tooltip(
                        message: m.name(context.l10n),
                        child: Icon(
                          m.selectedIcon ?? m.icon,
                          color: AppColors.brand,
                          size: AppSpacing.xl,
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
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(top: BorderSide(color: AppColors.border)),
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
                              color: AppColors.brandPrimary,
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
                                ? AppColors.brandPrimary
                                : AppColors.textSecondary,
                            size: 22,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            modules[i].name(context.l10n),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.of(context).caption.copyWith(
                              fontSize: 11,
                              color: i == index
                                  ? AppColors.brandPrimary
                                  : AppColors.textSecondary,
                              fontWeight: i == index
                                  ? FontWeight.w700
                                  : FontWeight.w500,
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
