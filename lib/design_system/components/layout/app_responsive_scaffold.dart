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
  });
  final Widget child;
  final List<ErpModule> modules;
  final String route;
  final ValueChanged<String> onNavigate;
  @override
  Widget build(BuildContext context) {
    final size = AppBreakpoints.of(context);
    final index = modules.indexWhere((m) => m.route == route);
    final selected = index < 0 ? 0 : index;
    final desktop = size == AppSize.expanded || size == AppSize.large;
    final content = Scaffold(
      appBar: AppBar(
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
          size == AppSize.compact && modules.length >= 2 && modules.length <= 5
          ? AppBottomNavigation(
              modules: modules,
              index: selected,
              onSelected: (i) => onNavigate(modules[i].route),
            )
          : null,
      drawer:
          size == AppSize.compact && (modules.length > 5 || modules.length < 2)
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
              onNavigate: onNavigate,
            ),
          if (size == AppSize.medium && modules.length >= 2)
            SafeArea(
              child: AppNavigationRail(
                modules: modules,
                index: selected,
                onSelected: (i) => onNavigate(modules[i].route),
              ),
            ),
          Expanded(child: content),
        ],
      ),
    );
  }
}
