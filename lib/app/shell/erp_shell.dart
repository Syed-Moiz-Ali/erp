import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../module_registry/module_registry.dart';
import '../../design_system/components/layout/app_responsive_scaffold.dart';

class ErpShell extends StatelessWidget {
  const ErpShell({
    super.key,
    required this.registry,
    required this.route,
    required this.child,
  });
  final ModuleRegistry registry;
  final String route;
  final Widget child;
  @override
  Widget build(BuildContext context) => AppResponsiveScaffold(
    modules: registry.visible(const {}),
    route: route,
    onNavigate: (r) => context.go(r),
    child: child,
  );
}
