import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/platform/access/application/user_grants_controller.dart';
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
    this.loggingOut = false,
  });
  final AuthStatus status;
  final AuthContext? context;
  final Failure? failure;
  final bool loggingOut;
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && context != null;
  bool get isInitializing =>
      status == AuthStatus.initial || status == AuthStatus.bootstrapping;
}

/// One application-level Bloc. Tokens stay in the repository, never in state.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this.repository, {this.grants})
    : super(const AuthState(AuthStatus.initial)) {
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
  }
  final AuthRepository repository;

  /// Optional grants source. When present, effective permissions come from
  /// persisted grants and refresh live (Phase 0.6). When absent (unit tests),
  /// the repository-provided permission set is used unchanged.
  final UserGrantsController? grants;
  late final StreamSubscription<AuthContext?> _subscription;
  StreamSubscription<PermissionSet>? _grantsSub;
  String? _grantsKey;
  bool _loginQueued = false;

  Future<void> _persistPermissions(PermissionSet permissions) async {
    final repo = repository;
    if (repo is SessionPermissionSink) {
      await (repo as SessionPermissionSink).applyEffectivePermissions(
        permissions,
      );
    }
  }

  Future<AuthContext> _applyGrants(AuthContext context) async {
    final controller = grants;
    if (controller == null) return context;
    try {
      final permissions = await controller.permissionsFor(context);
      await _persistPermissions(permissions);
      return context.copyWith(
        user: context.user.copyWith(permissions: permissions),
      );
    } catch (_) {
      return context;
    }
  }

  void _watchGrants(AuthContext context) {
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
    final effective = await _applyGrants(context);
    emit(AuthState(AuthStatus.authenticated, context: effective));
    _watchGrants(effective);
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
      case AuthPermissionsRefreshed(:final permissions):
        final current = state.context;
        if (current == null) return;
        await _persistPermissions(permissions);
        emit(
          AuthState(
            AuthStatus.authenticated,
            context: current.copyWith(
              user: current.user.copyWith(permissions: permissions),
            ),
          ),
        );
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await _grantsSub?.cancel();
    await super.close();
  }
}
