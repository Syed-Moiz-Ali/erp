import '../../../l10n/l10n.dart';
import 'package:flutter/material.dart';
import '../../../app/module_registry/module_registry.dart';
import '../../theme/app_breakpoints.dart';
import '../navigation/app_navigation.dart';
import '../avatars/app_avatar.dart';
import '../inputs/app_language_selector.dart';

class AppResponsiveScaffold extends StatelessWidget {
  const AppResponsiveScaffold({
    super.key,
    required this.child,
    required this.modules,
    required this.route,
    required this.onNavigate,
    this.topBar,
    this.bottomModules,
    this.bottomSelectedRoute,
    this.collapsed = false,
    this.companyName,
    this.onCompanyPressed,
    this.onToggleSidebar,
  });
  final Widget child;
  final List<ErpModule> modules;
  final String route;
  final ValueChanged<String> onNavigate;
  final PreferredSizeWidget? topBar;
  final List<ErpModule>? bottomModules;
  final String? bottomSelectedRoute, companyName;
  final bool collapsed;
  final VoidCallback? onCompanyPressed, onToggleSidebar;
  @override
  Widget build(BuildContext context) {
    final size = AppBreakpoints.of(context);
    int selectedIndex(List<ErpModule> items, String path) {
      final matches = items.where((m) => m.owns(path)).toList()
        ..sort((a, b) => b.route.length.compareTo(a.route.length));
      return matches.isEmpty ? -1 : items.indexOf(matches.first);
    }

    final index = selectedIndex(modules, route);
    final bottomItems = bottomModules ?? modules;
    final bottomIndex = selectedIndex(
      bottomItems,
      bottomSelectedRoute ?? route,
    );
    final selected = index < 0 ? 0 : index;
    final desktop = size == AppSize.expanded || size == AppSize.large;
    final content = Scaffold(
      appBar:
          topBar ??
          AppBar(
            title: Text(context.l10n.workspace),
            actions: [
              const AppLanguageSelector(),
              Padding(
                padding: EdgeInsetsDirectional.only(end: 24),
                child: AppAvatar(name: context.l10n.designPreview),
              ),
            ],
          ),
      body: child,
      bottomNavigationBar:
          size == AppSize.compact &&
              bottomItems.isNotEmpty &&
              bottomItems.length <= 5
          ? AppBottomNavigation(
              modules: bottomItems,
              index: bottomIndex < 0 ? 0 : bottomIndex,
              onSelected: (i) => onNavigate(bottomItems[i].route),
            )
          : null,
      drawer: topBar == null && size == AppSize.compact && modules.length > 5
          ? Drawer(
              child: AppSidebar(
                modules: modules,
                selectedRoute: route,
                onNavigate: (r) {
                  Navigator.pop(context);
                  onNavigate(r);
                },
              ),
            )
          : null,
    );
    return Material(
      child: Row(
        children: [
          if (desktop)
            AppSidebar(
              modules: modules,
              selectedRoute: route,
              collapsed: collapsed,
              large: size == AppSize.large,
              companyName: companyName,
              onCompanyPressed: onCompanyPressed,
              onToggle: onToggleSidebar,
              onNavigate: onNavigate,
            ),
          if (size == AppSize.medium && modules.isNotEmpty)
            SafeArea(
              child: AppNavigationRail(
                modules: modules,
                index: index < 0 ? null : selected,
                companyName: companyName,
                onCompanyPressed: onCompanyPressed,
                onSelected: (i) => onNavigate(modules[i].route),
              ),
            ),
          Expanded(child: content),
        ],
      ),
    );
  }
}
