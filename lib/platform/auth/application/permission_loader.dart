import 'dart:async';

import 'package:modular_erp/core/api/access_endpoint.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/platform/access/domain/effective_access.dart';
import 'package:modular_erp/platform/access/domain/effective_access_source.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';

/// Loads backend effective access and applies it to the stored session.
///
/// Runs only for backend sessions (registered by DI in backend mode). It never
/// reads local/demo grants. Triggers:
///
/// * every authenticated session context (login, token refresh, restore);
/// * app resume via [refresh];
/// * `403 ACCESS_DENIED` through [AccessEndpoint].
///
/// Failure is fail-closed: permissions become empty and only the always-enabled
/// modules remain, so the existing unauthorized/empty shell states are shown.
class BackendPermissionLoader {
  BackendPermissionLoader({
    required AuthRepository repository,
    required EffectiveAccessSource source,
    required AccessEndpoint accessEndpoint,
    required Stream<AuthContext?> contexts,
    required AuthContext? Function() currentContext,
    Set<String> alwaysEnabledModules = const <String>{'settings'},
  }) : _repository = repository,
       _source = source,
       _accessEndpoint = accessEndpoint,
       _contexts = contexts,
       _currentContext = currentContext,
       _alwaysEnabledModules = alwaysEnabledModules;

  final AuthRepository _repository;
  final EffectiveAccessSource _source;
  final AccessEndpoint _accessEndpoint;
  final Stream<AuthContext?> _contexts;
  final AuthContext? Function() _currentContext;

  /// Modules that stay available to every signed-in user. Dashboard and account
  /// are always available at the module level; the settings hub is enabled here
  /// so its permission-gated rows remain reachable.
  final Set<String> _alwaysEnabledModules;

  StreamSubscription<AuthContext?>? _contextSub;
  StreamSubscription<String>? _deniedSub;
  bool _started = false;
  bool _loading = false;
  bool _queued = false;
  bool _queuedForce = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    _contextSub = _contexts.listen(_onContext);
    _deniedSub = _accessEndpoint.onPermissionDenied.listen((_) {
      unawaited(refresh());
    });
    final current = _currentContext();
    if (current != null) await _load(current, force: true);
  }

  /// Reloads effective access for the current session (app resume/manual retry).
  Future<void> refresh() async {
    final current = _currentContext();
    if (current != null) await _load(current, force: true);
  }

  void _onContext(AuthContext? context) {
    if (context == null) return;
    unawaited(_load(context));
  }

  Future<void> _load(AuthContext context, {bool force = false}) async {
    if (_loading) {
      _queued = true;
      _queuedForce = _queuedForce || force;
      return;
    }
    _loading = true;
    try {
      final result = await _source.load(context);
      final current = _currentContext();
      if (current == null || current.user.id != context.user.id) return;

      final PermissionSet permissions;
      final Set<String> modules;
      switch (result) {
        case Success<EffectiveAccess>(:final value):
          permissions = value.permissions;
          modules = {...value.enabledModules, ..._alwaysEnabledModules};
        case Failed<EffectiveAccess>():
          permissions = PermissionSet(const <AppPermission>[]);
          modules = {..._alwaysEnabledModules};
      }
      if (!force && _isCurrent(current, permissions, modules)) return;
      await _apply(permissions, modules);
    } catch (_) {
      // Fail closed: no permissions, only always-enabled modules.
      final current = _currentContext();
      if (current == null) return;
      final permissions = PermissionSet(const <AppPermission>[]);
      final modules = {..._alwaysEnabledModules};
      if (_isCurrent(current, permissions, modules)) return;
      await _apply(permissions, modules);
    } finally {
      _loading = false;
      if (_queued) {
        _queued = false;
        final forceNext = _queuedForce;
        _queuedForce = false;
        final current = _currentContext();
        if (current != null) unawaited(_load(current, force: forceNext));
      }
    }
  }

  Future<void> _apply(
    PermissionSet permissions,
    Set<String> modules,
  ) async {
    final repository = _repository;
    if (repository is! SessionAccessSink) return;
    await (repository as SessionAccessSink).applyEffectiveAccess(
      permissions,
      enabledModules: modules,
    );
  }

  bool _isCurrent(
    AuthContext context,
    PermissionSet permissions,
    Set<String> modules,
  ) =>
      _samePermissions(context.user.permissions, permissions) &&
      _sameSet(context.company.enabledModules, modules);

  static bool _sameSet(Set<String> left, Set<String> right) =>
      left.length == right.length && left.every(right.contains);

  static bool _samePermissions(PermissionSet left, PermissionSet right) {
    if (!_sameSet(
      left.values.map((value) => value.name).toSet(),
      right.values.map((value) => value.name).toSet(),
    )) {
      return false;
    }
    if (left.scopes.length != right.scopes.length) return false;
    for (final entry in left.scopes.entries) {
      if (right.scopes[entry.key] != entry.value) return false;
    }
    return true;
  }

  Future<void> dispose() async {
    await _contextSub?.cancel();
    await _deniedSub?.cancel();
    _contextSub = null;
    _deniedSub = null;
  }
}
