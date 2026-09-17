import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/security/app_permission.dart';
import '../../l10n/l10n.dart';

enum NavigationGroup {
  workspace,
  internal,
  general,
  people,
  workforce,
  insights,
  administration,
  account,
  services,
  finance,
}

extension NavigationGroupLocalization on NavigationGroup {
  String label(AppLocalizations l10n) => switch (this) {
    NavigationGroup.workspace => l10n.workspace,
    NavigationGroup.internal => l10n.internal,
    NavigationGroup.general => l10n.shellGeneral,
    NavigationGroup.people => l10n.shellPeople,
    NavigationGroup.workforce => l10n.shellWorkforce,
    NavigationGroup.insights => l10n.shellInsights,
    NavigationGroup.administration => l10n.shellAdministration,
    NavigationGroup.account => l10n.shellAccount,
    NavigationGroup.services => l10n.shellServices,
    NavigationGroup.finance => l10n.shellFinance,
  };
}

/// A navigation destination. All layouts receive the same resolved descriptors.
class ErpModule {
  const ErpModule({
    required this.id,
    required this.name,
    required this.icon,
    required this.route,
    String? moduleId,
    this.selectedIcon,
    this.requiredPermissions = const {},
    this.anyPermissions = const {},
    this.navigationGroup = NavigationGroup.workspace,
    this.order = 0,
    this.enabled = true,
    this.mobilePriority,
    this.mobileVisible = true,
    this.desktopVisible = true,
    this.routeAliases = const {},
  }) : _moduleId = moduleId;
  final String id, route;
  final String? _moduleId;
  String get moduleId => _moduleId ?? id;
  final LocalizedText name;
  final NavigationGroup navigationGroup;
  final IconData icon;
  final IconData? selectedIcon;
  final Set<AppPermission> requiredPermissions, anyPermissions;
  final Set<String> routeAliases;
  final int order;
  final int? mobilePriority;
  final bool enabled, mobileVisible, desktopVisible;
  bool owns(String path) => [
    route,
    ...routeAliases,
  ].any((root) => path == root || path.startsWith('$root/'));
}

/// Typed Flutter route registrations, never generated screens or JSON plugins.
class RegisteredDestination {
  RegisteredDestination({
    required this.navigation,
    required List<RouteBase> routes,
  }) : routes = List.unmodifiable(routes);
  final ErpModule navigation;
  final List<RouteBase> routes;
}

class AppModule {
  AppModule({
    required this.id,
    required List<RegisteredDestination> destinations,
    this.enabled = true,
    this.alwaysAvailable = false,
  }) : destinations = List.unmodifiable(destinations);
  final String id;
  final bool enabled;

  /// Only account utilities are independent of company module subscriptions.
  final bool alwaysAvailable;
  final List<RegisteredDestination> destinations;
}

class ModuleRegistry {
  /// Retained Phase 0 descriptor-only preview registration.
  ModuleRegistry(List<ErpModule> items)
    : modules = const [],
      _items = List.unmodifiable(items) {
    _validate();
  }
  ModuleRegistry.fromModules(List<AppModule> modules)
    : modules = List.unmodifiable(modules),
      _items = List.unmodifiable(
        modules.expand((m) => m.destinations.map((d) => d.navigation)),
      ) {
    _validate();
    if (modules.map((m) => m.id).toSet().length != modules.length) {
      throw ArgumentError('Module IDs must be unique');
    }
    for (final module in modules) {
      for (final destination in module.destinations) {
        if (destination.navigation.moduleId != module.id ||
            destination.routes.isEmpty) {
          throw ArgumentError('Invalid module registration');
        }
        if (!destination.navigation.route.startsWith('/app/')) {
          throw ArgumentError(
            'Module destinations must belong to the authenticated app',
          );
        }
        void validateRoute(RouteBase route, String parent) {
          switch (route) {
            case GoRoute():
              if (parent.isEmpty && !route.path.startsWith('/')) {
                throw ArgumentError('Branch roots must be absolute');
              }
              final path = route.path.startsWith('/')
                  ? route.path
                  : '$parent/${route.path}';
              if (!destination.navigation.owns(path)) {
                throw ArgumentError(
                  'Registered routes must belong to their guarded destination',
                );
              }
              for (final child in route.routes) {
                validateRoute(child, path);
              }
            case ShellRouteBase():
              for (final child in route.routes) {
                validateRoute(child, parent);
              }
          }
        }

        for (final route in destination.routes) {
          validateRoute(route, '');
        }
      }
    }
  }
  final List<AppModule> modules;
  final List<ErpModule> _items;
  List<ErpModule> get destinations => _items;
  List<RegisteredDestination> get registrations =>
      List.unmodifiable(modules.expand((m) => m.destinations));
  void _validate() {
    if (_items.map((m) => m.id).toSet().length != _items.length ||
        _items.map((m) => m.route).toSet().length != _items.length) {
      throw ArgumentError('Destination IDs and routes must be unique');
    }
    final roots = _items.expand((m) => [m.route, ...m.routeAliases]).toList();
    if (roots.toSet().length != roots.length ||
        roots.any((p) => !p.startsWith('/') || p.endsWith('/') && p != '/')) {
      throw ArgumentError('Route ownership must be unique and absolute');
    }
  }

  AppModule? module(String id) {
    for (final m in modules) {
      if (m.id == id) return m;
    }
    return null;
  }

  ErpModule? ownerOf(String path) {
    final candidates = _items.where((m) => m.owns(path)).toList()
      ..sort((a, b) => b.route.length.compareTo(a.route.length));
    return candidates.firstOrNull;
  }

  List<ErpModule> visible(Set<AppPermission> permissions) =>
      _items
          .where(
            (m) =>
                m.enabled &&
                permissions.containsAll(m.requiredPermissions) &&
                (m.anyPermissions.isEmpty ||
                    m.anyPermissions.any(permissions.contains)),
          )
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
}
