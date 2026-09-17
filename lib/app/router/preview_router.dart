import '../../l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../module_registry/module_registry.dart';
import '../shell/erp_shell.dart';
import '../../features/design_system_preview/presentation/design_system_preview_page.dart';
import '../../features/workspace/presentation/workspace_page.dart';
import '../../design_system/components/empty_states/app_empty_state.dart';

final moduleRegistry = ModuleRegistry([
  ErpModule(
    id: 'workspace',
    name: (l10n) => l10n.overview,
    icon: Icons.grid_view_outlined,
    route: '/',
    order: 0,
  ),
  ErpModule(
    id: 'design-system',
    name: (l10n) => l10n.designSystem,
    icon: Icons.palette_outlined,
    route: '/design-system',
    navigationGroup: NavigationGroup.internal,
    order: 100,
  ),
]);
GoRouter createPreviewRouter() => GoRouter(
  initialLocation: '/design-system',
  errorBuilder: (context, state) => Scaffold(
    body: AppErrorState(
      message: context.l10n.pageNotFound,
      onRetry: () => context.go('/'),
    ),
  ),
  routes: [
    ShellRoute(
      builder: (context, state, child) => ErpShell(
        registry: moduleRegistry,
        route: state.uri.path,
        child: child,
      ),
      routes: [
        GoRoute(path: '/', builder: (context, state) => WorkspacePage()),
        GoRoute(
          path: '/design-system',
          builder: (context, state) => DesignSystemPreviewPage(),
        ),
      ],
    ),
  ],
);
