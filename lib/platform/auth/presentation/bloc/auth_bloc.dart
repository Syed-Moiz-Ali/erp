import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/api/access_endpoint.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/platform/access/application/user_grants_controller.dart';
import 'package:modular_erp/platform/access/domain/effective_access.dart';
import 'package:modular_erp/platform/access/domain/effective_access_source.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class AuthBootstrapRequested extends AuthEvent {
  const AuthBootstrapRequested();
}

final class AuthSessionCheckRequested extends AuthEvent {
  const AuthSessionCheckRequested();
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested(this.identifier, this.password);
  final String identifier, password;
  @override
  String toString() => 'AuthLoginRequested([redacted])';
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}

final class AuthSessionUpdated extends AuthEvent {
  const AuthSessionUpdated(this.context);
  final AuthContext context;
}

/// Internal: the current user's grants changed and effective permissions must
/// be refreshed without a re-login.
final class AuthPermissionsRefreshed extends AuthEvent {
  const AuthPermissionsRefreshed(this.permissions);
  final PermissionSet permissions;
}

/// Reload the effective access from the backend (resume, manual retry, or a
/// permission-related 403).
final class AuthPermissionsReloadRequested extends AuthEvent {
  const AuthPermissionsReloadRequested();
}

final class AuthAccessDenied extends AuthEvent {
  const AuthAccessDenied(this.code);
  final String code;
}

enum AuthStatus {
  initial,
  bootstrapping,
  unauthenticated,
  authenticating,
  authenticated,
}

class AuthState {
  const AuthState(
    this.status, {
    this.context,
    this.failure,
    this.permissionsFailure,
    this.permissionsLoaded = false,
    this.loggingOut = false,
  });
  final AuthStatus status;
  final AuthContext? context;
  final Failure? failure;

  /// Backend permission load failed. Access is empty (fail closed) and the UI
  /// must offer a retry. Kept separate from one-shot action failures.
  final Failure? permissionsFailure;
  final bool permissionsLoaded;
  final bool loggingOut;
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && context != null;
  bool get isInitializing =>
      status == AuthStatus.initial || status == AuthStatus.bootstrapping;
  bool get hasPermissions =>
      context?.user.permissions.values.isNotEmpty ?? false;
}

/// One application-level Bloc. Tokens stay in the repository, never in state.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this.repository, {
    this.grants,
    this.effectiveAccess,
    this.accessEndpoint,
  }) : super(const AuthState(AuthStatus.initial)) {
    // A single sequential event bucket prevents restore/login/logout races.
    on<AuthEvent>(
      _handle,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
    _subscription = repository.sessionChanges.listen((context) {
      add(
        context == null
            ? const AuthSessionExpired()
            : AuthSessionUpdated(context),
      );
    });
    _accessSub = accessEndpoint?.onPermissionDenied.listen(
      (code) => add(AuthAccessDenied(code)),
    );
  }
  final AuthRepository repository;

  /// Demo-mode grants source. Backend mode must pass [effectiveAccess] and
  /// never uses local grants for authorization.
  final UserGrantsController? grants;

  /// Backend effective-access loader. When present, local [grants] are ignored.
  final EffectiveAccessSource? effectiveAccess;
  final AccessEndpoint? accessEndpoint;
  late final StreamSubscription<AuthContext?> _subscription;
  StreamSubscription<String>? _accessSub;
  StreamSubscription<PermissionSet>? _grantsSub;
  String? _grantsKey;
  bool _loginQueued = false;
  bool _reloadQueued = false;

  bool get _backendMode => effectiveAccess != null;

  Future<void> _persistAccess(
    PermissionSet permissions, {
    Set<String>? enabledModules,
  }) async {
    final repo = repository;
    if (repo is SessionAccessSink) {
      await (repo as SessionAccessSink).applyEffectiveAccess(
        permissions,
        enabledModules: enabledModules,
      );
    } else if (repo is SessionPermissionSink) {
      await (repo as SessionPermissionSink).applyEffectivePermissions(
        permissions,
      );
    }
  }

  Future<({AuthContext context, Failure? failure, bool loaded})>
  _resolveAccess(AuthContext context) async {
    final source = effectiveAccess;
    if (source != null) {
      try {
        final result = await source.load(context);
        switch (result) {
          case Success<EffectiveAccess>(:final value):
            await _persistAccess(
              value.permissions,
              enabledModules: value.enabledModules,
            );
            return (
              context: context.copyWith(
                user: context.user.copyWith(permissions: value.permissions),
                company: context.company.copyWith(
                  enabledModules: value.enabledModules,
                ),
              ),
              failure: null,
              loaded: true,
            );
          case Failed<EffectiveAccess>(:final failure):
            return (
              context: _withoutAccess(context),
              failure: failure,
              loaded: false,
            );
        }
      } catch (_) {
        return (
          context: _withoutAccess(context),
          failure: const Failure(
            code: 'permissions_unavailable',
            kind: FailureKind.unknown,
            retryable: true,
          ),
          loaded: false,
        );
      }
    }
    final controller = grants;
    if (controller == null) {
      return (context: context, failure: null, loaded: true);
    }
    try {
      final permissions = await controller.permissionsFor(context);
      await _persistAccess(permissions);
      return (
        context: context.copyWith(
          user: context.user.copyWith(permissions: permissions),
        ),
        failure: null,
        loaded: true,
      );
    } catch (_) {
      // Demo/local grants keep the repository-provided set on read failure.
      return (context: context, failure: null, loaded: true);
    }
  }

  AuthContext _withoutAccess(AuthContext context) => context.copyWith(
    user: context.user.copyWith(
      permissions: PermissionSet(const <AppPermission>[]),
    ),
    company: context.company.copyWith(enabledModules: const <String>{}),
  );

  void _watchGrants(AuthContext context) {
    if (_backendMode) return;
    final controller = grants;
    if (controller == null) return;
    final key = '${context.company.id}:${context.user.id}';
    if (_grantsKey == key) return;
    _grantsKey = key;
    unawaited(_grantsSub?.cancel());
    _grantsSub = controller.watch(context).listen((permissions) {
      final current = state.context;
      if (current == null ||
          current.company.id != context.company.id ||
          current.user.id != context.user.id) {
        return;
      }
      add(AuthPermissionsRefreshed(permissions));
    });
  }

  void _stopGrants() {
    _grantsKey = null;
    unawaited(_grantsSub?.cancel());
    _grantsSub = null;
  }

  Future<void> _emitAuthenticated(
    Emitter<AuthState> emit,
    AuthContext context,
  ) async {
    final resolved = await _resolveAccess(context);
    emit(
      AuthState(
        AuthStatus.authenticated,
        context: resolved.context,
        permissionsFailure: resolved.failure,
        permissionsLoaded: resolved.loaded,
      ),
    );
    _watchGrants(resolved.context);
  }

  Future<void> _reloadPermissions(Emitter<AuthState> emit) async {
    final current = state.context;
    if (current == null || _reloadQueued) return;
    _reloadQueued = true;
    try {
      final resolved = await _resolveAccess(current);
      emit(
        AuthState(
          AuthStatus.authenticated,
          context: resolved.context,
          permissionsFailure: resolved.failure,
          permissionsLoaded: resolved.loaded,
        ),
      );
      _watchGrants(resolved.context);
    } finally {
      _reloadQueued = false;
    }
  }

  @override
  void add(AuthEvent event) {
    if (event is AuthLoginRequested) {
      if (_loginQueued || state.isAuthenticated) return;
      _loginQueued = true;
    }
    super.add(event);
  }

  Future<void> _handle(AuthEvent event, Emitter<AuthState> emit) async {
    switch (event) {
      case AuthBootstrapRequested():
        if (!state.isInitializing) return;
        emit(const AuthState(AuthStatus.bootstrapping));
        final result = await repository.restoreSession();
        switch (result) {
          case Success<AuthContext?>(:final value):
            if (value == null) {
              emit(const AuthState(AuthStatus.unauthenticated));
            } else {
              await _emitAuthenticated(emit, value);
            }
          case Failed<AuthContext?>(:final failure):
            emit(AuthState(AuthStatus.unauthenticated, failure: failure));
        }
      case AuthSessionCheckRequested():
        if (!state.isAuthenticated) return;
        final result = await repository.checkSession();
        switch (result) {
          case Success<AuthContext?>(:final value):
            if (value == null) {
              _stopGrants();
              emit(
                const AuthState(
                  AuthStatus.unauthenticated,
                  failure: Failure(
                    code: 'session_expired',
                    kind: FailureKind.sessionExpired,
                  ),
                ),
              );
            } else {
              await _emitAuthenticated(emit, value);
            }
          case Failed<AuthContext?>(:final failure):
            _stopGrants();
            emit(AuthState(AuthStatus.unauthenticated, failure: failure));
        }
      case AuthLoginRequested(:final identifier, :final password):
        try {
          if (state.isAuthenticated) return;
          final parsed = AuthIdentifier.parse(identifier);
          if (parsed == null || password.isEmpty) {
            emit(
              const AuthState(
                AuthStatus.unauthenticated,
                failure: Failure(
                  code: 'invalid_input',
                  kind: FailureKind.invalidData,
                ),
              ),
            );
            return;
          }
          emit(const AuthState(AuthStatus.authenticating));
          final result = await repository.login(parsed, password);
          switch (result) {
            case Success<AuthContext>(:final value):
              await _emitAuthenticated(emit, value);
            case Failed<AuthContext>(:final failure):
              emit(AuthState(AuthStatus.unauthenticated, failure: failure));
          }
        } finally {
          _loginQueued = false;
        }
      case AuthLogoutRequested():
        if (!state.isAuthenticated || state.loggingOut) return;
        final context = state.context!;
        emit(
          AuthState(
            AuthStatus.authenticated,
            context: context,
            loggingOut: true,
          ),
        );
        final result = await repository.logout();
        _stopGrants();
        switch (result) {
          case Success<void>():
            emit(const AuthState(AuthStatus.unauthenticated));
          case Failed<void>(:final failure):
            emit(
              AuthState(
                AuthStatus.authenticated,
                context: context,
                failure: failure,
              ),
            );
        }
      case AuthSessionExpired():
        _stopGrants();
        emit(
          const AuthState(
            AuthStatus.unauthenticated,
            failure: Failure(
              code: 'session_expired',
              kind: FailureKind.sessionExpired,
            ),
          ),
        );
        // Forced invalidation also purges otherwise-unexpired secure tokens.
        await repository.logout();
      case AuthSessionUpdated(:final context):
        await _emitAuthenticated(emit, context);
      case AuthPermissionsReloadRequested():
        await _reloadPermissions(emit);
      case AuthAccessDenied(:final code):
        final current = state.context;
        if (current == null) return;
        emit(
          AuthState(
            AuthStatus.authenticated,
            context: current,
            failure: Failure(code: code, kind: FailureKind.forbidden),
            permissionsFailure: state.permissionsFailure,
            permissionsLoaded: state.permissionsLoaded,
          ),
        );
        add(const AuthPermissionsReloadRequested());
      case AuthPermissionsRefreshed(:final permissions):
        final current = state.context;
        if (current == null) return;
        await _persistAccess(permissions);
        emit(
          AuthState(
            AuthStatus.authenticated,
            context: current.copyWith(
              user: current.user.copyWith(permissions: permissions),
            ),
            permissionsLoaded: true,
          ),
        );
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await _accessSub?.cancel();
    await _grantsSub?.cancel();
    await super.close();
  }
}
