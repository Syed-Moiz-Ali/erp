import '../../../l10n/l10n.dart';
import 'package:flutter/material.dart';
import '../../../app/module_registry/module_registry.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.modules,
    required this.selectedRoute,
    required this.onNavigate,
  });
  final List<ErpModule> modules;
  final String selectedRoute;
  final ValueChanged<String> onNavigate;
  @override
  Widget build(BuildContext context) => Container(
    width: 248,
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: BorderDirectional(end: BorderSide(color: AppColors.border)),
    ),
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.layers_outlined, color: AppColors.brand),
                  SizedBox(width: 12),
                  Text(
                    context.l10n.brandName,
                    style: AppTypography.of(context).sectionTitle,
                  ),
                ],
              ),
            ),
            Divider(),
            SizedBox(height: 16),
            for (final group
                in modules.map((m) => m.navigationGroup).toSet()) ...[
              Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  group.label(context.l10n),
                  style: AppTypography.of(context).caption,
                ),
              ),
              for (final module in modules.where(
                (m) => m.navigationGroup == group,
              ))
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    selected: selectedRoute == module.route,
                    selectedColor: AppColors.brand,
                    selectedTileColor: AppColors.brand.withValues(alpha: .08),
                    leading: Icon(module.icon, size: 20),
                    title: Text(module.name(context.l10n)),
                    onTap: () => onNavigate(module.route),
                  ),
                ),
            ],
            Spacer(),
            Divider(),
            Text(
              context.l10n.erpWorkspace,
              style: AppTypography.of(context).label,
            ),
            Text(
              context.l10n.foundationPhase,
              style: AppTypography.of(context).caption,
            ),
          ],
        ),
      ),
    ),
  );
}

class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({
    super.key,
    required this.modules,
    required this.index,
    required this.onSelected,
  });
  final List<ErpModule> modules;
  final int index;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) => NavigationRail(
    selectedIndex: index,
    onDestinationSelected: onSelected,
    labelType: NavigationRailLabelType.all,
    destinations: modules
        .map(
          (m) => NavigationRailDestination(
            icon: Icon(m.icon),
            label: Text(m.name(context.l10n)),
          ),
        )
        .toList(),
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
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: index,
    onDestinationSelected: onSelected,
    destinations: modules
        .map(
          (m) => NavigationDestination(
            icon: Icon(m.icon),
            label: m.name(context.l10n),
          ),
        )
        .toList(),
  );
}
