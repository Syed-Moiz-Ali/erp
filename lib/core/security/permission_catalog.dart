import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_definition.dart';
import 'package:modular_erp/core/security/permission_scope.dart';

/// A submodule groups the meaningful actions of a module (for example
/// `Attendance` inside `HR`). The Access UI renders one section per submodule.
class PermissionSubmodule {
  const PermissionSubmodule({
    required this.id,
    required this.nameKey,
    required this.definitions,
    this.order = 0,
  });
  final String id, nameKey;
  final List<PermissionDefinition> definitions;
  final int order;
}

/// A business module's permission contribution.
class PermissionModule {
  const PermissionModule({
    required this.id,
    required this.nameKey,
    required this.submodules,
    this.order = 0,
  });
  final String id, nameKey;
  final List<PermissionSubmodule> submodules;
  final int order;

  Iterable<PermissionDefinition> get definitions =>
      submodules.expand((s) => s.definitions);
}

/// The composed permission catalog. Modules contribute definitions; the global
/// Access UI is generated from this catalog and never hardcodes checkboxes.
class PermissionCatalog {
  const PermissionCatalog(this.modules);
  final List<PermissionModule> modules;

  List<PermissionModule> get orderedModules =>
      [...modules]..sort((a, b) => a.order.compareTo(b.order));

  Iterable<PermissionDefinition> get definitions =>
      modules.expand((m) => m.definitions);

  PermissionDefinition? byKey(String key) {
    for (final definition in definitions) {
      if (definition.key == key) return definition;
    }
    return null;
  }

  PermissionDefinition? forPermission(AppPermission permission) {
    for (final definition in definitions) {
      if (definition.permissions.containsValue(permission)) {
        return definition;
      }
    }
    return null;
  }

  PermissionScope? scopeOf(AppPermission permission) =>
      forPermission(permission)?.scopeOf(permission);

  AppPermission? permissionFor(String key, PermissionScope scope) =>
      byKey(key)?.permissionFor(scope);

  /// Reverse-maps a runtime permission set to explicit `(key, scope)` grants.
  List<({String key, PermissionScope scope})> grantsFor(
    Iterable<AppPermission> permissions,
  ) {
    final result = <({String key, PermissionScope scope})>[];
    for (final permission in permissions) {
      final definition = forPermission(permission);
      final scope = definition?.scopeOf(permission);
      if (definition != null && scope != null) {
        result.add((key: definition.key, scope: scope));
      }
    }
    return result;
  }

  /// Expands explicit grants back to the runtime permission set.
  Set<AppPermission> permissionsFor(
    Iterable<({String key, PermissionScope scope})> grants,
  ) {
    final result = <AppPermission>{};
    for (final grant in grants) {
      final permission = permissionFor(grant.key, grant.scope);
      if (permission != null) result.add(permission);
    }
    return result;
  }

  /// Case-insensitive search across keys and localization keys.
  List<PermissionDefinition> search(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return const [];
    return [
      for (final definition in definitions)
        if (definition.key.toLowerCase().contains(needle) ||
            definition.nameKey.toLowerCase().contains(needle) ||
            definition.submoduleId.toLowerCase().contains(needle))
          definition,
    ];
  }
}
