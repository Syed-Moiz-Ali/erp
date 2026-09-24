import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_scope.dart';

/// Visual risk hint for high-impact permissions.
enum PermissionRisk { standard, elevated }

/// Typed permission definition owned by a business module.
///
/// Identity is the stable namespaced [key] (for example `hr.leave.records.view`)
/// and never a translated string. A definition may expose several scopes; each
/// scope maps to the existing [AppPermission] that runtime authorization already
/// evaluates, so scope support is additive metadata rather than a parallel
/// authorization system.
class PermissionDefinition {
  const PermissionDefinition({
    required this.key,
    required this.moduleId,
    required this.submoduleId,
    required this.nameKey,
    required this.descriptionKey,
    required this.permissions,
    this.requiresEmployeeLink = false,
    this.delegable = true,
    this.platformOnly = false,
    this.risk = PermissionRisk.standard,
    this.order = 0,
    this.featureFlag,
  });
  final String key;
  final String moduleId;
  final String submoduleId;

  /// Company module-enablement flag that must be enabled for this permission.
  /// Defaults to the submodule id. HR configuration uses the `settings` flag.
  final String? featureFlag;
  String get requiredFeature => featureFlag ?? submoduleId;

  /// Localization keys resolved against the composed `AppLocalizations`.
  final String nameKey, descriptionKey;

  /// Scope → underlying runtime permission. Action permissions use
  /// `{PermissionScope.none: ...}`; scoped permissions map each supported scope.
  final Map<PermissionScope, AppPermission> permissions;

  final bool requiresEmployeeLink, delegable, platformOnly;
  final PermissionRisk risk;
  final int order;

  Iterable<PermissionScope> get supportedScopes => permissions.keys;

  AppPermission? permissionFor(PermissionScope scope) => permissions[scope];

  PermissionScope? scopeOf(AppPermission permission) {
    for (final entry in permissions.entries) {
      if (entry.value == permission) return entry.key;
    }
    return null;
  }
}
