import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/auth_context.dart';
import '../../../../core/auth/auth_identifier.dart';
import '../../domain/repositories/auth_repository.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class AuthBootstrapRequested extends AuthEvent {
  const AuthBootstrapRequested();
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
  AuthBloc(this.repository) : super(const AuthState(AuthStatus.initial)) {
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
  late final StreamSubscription<AuthContext?> _subscription;
  bool _loginQueued = false;
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
            emit(
              value == null
                  ? const AuthState(AuthStatus.unauthenticated)
                  : AuthState(AuthStatus.authenticated, context: value),
            );
          case Failed<AuthContext?>(:final failure):
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
              emit(AuthState(AuthStatus.authenticated, context: value));
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
        emit(
          const AuthState(
            AuthStatus.unauthenticated,
            failure: Failure(
              code: 'session_expired',
              kind: FailureKind.sessionExpired,
            ),
          ),
        );
      case AuthSessionUpdated(:final context):
        emit(AuthState(AuthStatus.authenticated, context: context));
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
