import '../../core/security/app_permission.dart';
import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';

enum NavigationGroup { workspace, internal }

extension NavigationGroupLocalization on NavigationGroup {
  String label(AppLocalizations l10n) => switch (this) {
    NavigationGroup.workspace => l10n.workspace,
    NavigationGroup.internal => l10n.internal,
  };
}

class ErpModule {
  const ErpModule({
    required this.id,
    required this.name,
    required this.icon,
    required this.route,
    this.requiredPermissions = const {},
    this.navigationGroup = NavigationGroup.workspace,
    this.order = 0,
    this.enabled = true,
  });
  final String id, route;
  final String Function(AppLocalizations) name;
  final NavigationGroup navigationGroup;
  final IconData icon;
  final Set<AppPermission> requiredPermissions;
  final int order;
  final bool enabled;
}

class ModuleRegistry {
  ModuleRegistry(List<ErpModule> modules)
    : _modules = List.unmodifiable(modules) {
    if (modules.map((m) => m.id).toSet().length != modules.length ||
        modules.map((m) => m.route).toSet().length != modules.length) {
      throw ArgumentError('Module IDs and routes must be unique');
    }
  }
  final List<ErpModule> _modules;
  List<ErpModule> visible(Set<AppPermission> permissions) =>
      _modules
          .where(
            (m) => m.enabled && permissions.containsAll(m.requiredPermissions),
          )
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
}
