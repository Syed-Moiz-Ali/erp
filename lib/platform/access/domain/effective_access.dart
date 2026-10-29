import 'package:modular_erp/core/security/app_permission.dart';

/// Effective backend access resolved from `GET /api/me/permissions`.
///
/// [permissions] is the runtime authorization set and [enabledModules] is a
/// client-side derivation (the backend exposes no module-entitlement endpoint).
class EffectiveAccess {
  const EffectiveAccess({
    required this.permissions,
    required this.enabledModules,
    this.permissionKeys = const [],
    this.unknownKeys = const [],
  });

  final PermissionSet permissions;
  final Set<String> enabledModules;

  /// Raw backend keys, retained for diagnostics only.
  final List<String> permissionKeys;

  /// Keys the client does not understand. They are ignored (fail closed) and
  /// reported so a backend/client catalog drift is observable.
  final List<String> unknownKeys;

  static final empty = EffectiveAccess(
    permissions: PermissionSet(const <AppPermission>[]),
    enabledModules: const <String>{},
  );
}
