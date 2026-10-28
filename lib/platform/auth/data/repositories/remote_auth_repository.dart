import 'dart:async';
import 'dart:convert';

import 'package:modular_erp/core/api/api_error_codes.dart';
import 'package:modular_erp/core/api/session_endpoint.dart';
import 'package:modular_erp/core/api/token_refresher.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/storage/secure_session_storage.dart';
import 'package:modular_erp/platform/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:modular_erp/platform/auth/data/dto/auth_remote_dtos.dart';
import 'package:modular_erp/platform/auth/data/dto/auth_session_dto.dart';
import 'package:modular_erp/platform/auth/data/mappers/remote_auth_mapper.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';

/// Production authentication repository backed by the MassERP API.
///
/// Implements [AuthRepository], [SessionPermissionSink] (so effective
/// permissions persist back into the stored session) and [TokenRefresher] (so
/// the shared networking layer can rotate tokens through the single-flight
/// coordinator).
///
/// A monotonically increasing [_generation] fences in-flight refreshes: login,
/// logout and forced invalidation advance it, and any refresh that resolves
/// afterwards is discarded so a late response can never restore a session that
/// the user (or the server) already ended.
class RemoteAuthRepository
    implements AuthRepository, SessionAccessSink, TokenRefresher {
  RemoteAuthRepository({
    required AuthRemoteDataSource dataSource,
    required SessionStorage storage,
    SessionEndpoint? sessionEndpoint,
    DateTime Function()? now,
  }) : _dataSource = dataSource,
       _storage = storage,
       _now = now ?? DateTime.now {
    _sessionSubscription = sessionEndpoint?.onSessionEnding.listen((_) {
      unawaited(_serial(_invalidateFromServer));
    });
  }

  final AuthRemoteDataSource _dataSource;
  final SessionStorage _storage;
  final DateTime Function() _now;
  final _changes = StreamController<AuthContext?>.broadcast();
  StreamSubscription<String>? _sessionSubscription;
  AuthSession? _session;
  Timer? _expiry;
  bool _disposed = false;
  int _generation = 0;
  Future<void>? _operations;

  Future<T> _serial<T>(Future<T> Function() operation) {
    final pending = (_operations ?? Future<void>.value()).then(
      (_) => operation(),
    );
    _operations = pending.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return pending;
  }

  @override
  Stream<AuthContext?> get sessionChanges => _changes.stream;

  // --- Session lifecycle -----------------------------------------------------

  void _accept(AuthSession session) {
    if (_disposed) return;
    _session = session;
    _expiry?.cancel();
    final delay = session.expiresAt.difference(_now().toUtc());
    _expiry = Timer(delay.isNegative ? Duration.zero : delay, () {
      unawaited(_serial(_onAccessExpired));
    });
  }

  void _emit(AuthContext? context) {
    if (!_disposed) _changes.add(context);
  }

  Future<void> _persist(AuthSession session) => _storage.saveSession(
    jsonEncode(AuthSessionMapper.encode(session).toJson()),
  );

  Future<void> _safeClear() async {
    try {
      await _storage.clearSession();
    } catch (_) {
      /* The stored envelope is unusable regardless. */
    }
  }

  bool _refreshWindowOpen(AuthSession session) {
    final refreshExpiry = session.refreshTokenExpiresAt;
    if (refreshExpiry == null) return true;
    return refreshExpiry.isAfter(_now().toUtc());
  }

  Future<void> _onAccessExpired() async {
    final session = _session;
    if (session == null || _disposed) return;
    if (_refreshWindowOpen(session)) {
      final outcome = await _refresh();
      if (outcome == TokenRefreshOutcome.refreshed) return;
      if (outcome == TokenRefreshOutcome.unavailable) {
        _scheduleRetry();
        return;
      }
    }
    await _invalidate();
  }

  void _scheduleRetry() {
    _expiry?.cancel();
    _expiry = Timer(const Duration(seconds: 60), () {
      unawaited(_serial(_onAccessExpired));
    });
  }

  Future<void> _invalidate() async {
    _generation++;
    _expiry?.cancel();
    final hadSession = _session != null;
    _session = null;
    await _safeClear();
    if (hadSession) _emit(null);
  }

  Future<void> _invalidateFromServer() async {
    if (_session == null) return;
    await _invalidate();
  }

  @override
  Future<Result<AuthContext?>> restoreSession() => _serial(_restoreSession);

  @override
  Future<Result<AuthContext?>> checkSession() => restoreSession();

  Future<Result<AuthContext?>> _restoreSession() async {
    _expiry?.cancel();
    try {
      final raw = await _storage.readSession();
      if (raw == null) {
        _session = null;
        return const Success(null);
      }
      AuthSession session;
      try {
        session = AuthSessionMapper.decode(
          AuthSessionDto.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        );
      } catch (_) {
        await _safeClear();
        _session = null;
        return const Success(null);
      }
      if (!_refreshWindowOpen(session)) {
        await _safeClear();
        _session = null;
        return const Success(null);
      }
      _accept(session);
      return Success(session.context);
    } catch (_) {
      return const Failed(
        Failure(code: 'session_restore', kind: FailureKind.sessionStorage),
      );
    }
  }

  @override
  Future<Result<AuthContext>> login(
    AuthIdentifier identifier,
    String password,
  ) => _serial(() => _login(identifier, password));

  Future<Result<AuthContext>> _login(
    AuthIdentifier identifier,
    String password,
  ) async {
    // Supersede any in-flight refresh from a previous session.
    _generation++;
    final result = await _dataSource.login(
      LoginRequestDto(loginId: identifier.value, password: password),
    );
    switch (result) {
      case Success<LoginResponseDto>(:final value):
        final session = RemoteAuthMapper.fromLogin(value);
        try {
          await _persist(session);
        } catch (_) {
          return const Failed(
            Failure(code: 'session_save', kind: FailureKind.sessionStorage),
          );
        }
        _accept(session);
        return Success(session.context);
      case Failed<LoginResponseDto>(:final failure):
        return Failed(failure);
    }
  }

  @override
  Future<Result<void>> logout() => _serial(_logout);

  Future<Result<void>> _logout() async {
    final refreshToken = _session?.refreshToken;
    // Supersede any in-flight refresh immediately, before any await, so a late
    // rotation cannot restore the session being ended.
    _generation++;
    // Clear local access first so a network problem cannot restore it.
    try {
      await _storage.clearSession();
    } catch (_) {
      return const Failed(
        Failure(code: 'session_clear', kind: FailureKind.sessionStorage),
      );
    }
    _expiry?.cancel();
    _session = null;
    if (refreshToken != null) {
      try {
        await _dataSource.logout(LogoutRequestDto(refreshToken: refreshToken));
      } catch (_) {
        /* Best-effort: local access is already gone. */
      }
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> requestPasswordReset(AuthIdentifier identifier) async =>
      const Failed(Failure(code: 'unsupported', kind: FailureKind.request));

  @override
  Future<Result<void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async =>
      const Failed(Failure(code: 'unsupported', kind: FailureKind.request));

  // --- Token refresh (TokenRefresher) ---------------------------------------

  @override
  Future<TokenRefreshOutcome> refresh() => _refresh();

  Future<TokenRefreshOutcome> _refresh() async {
    final session = _session;
    if (_disposed || session == null) return TokenRefreshOutcome.invalidated;
    final generation = _generation;
    final result = await _dataSource.refresh(
      RefreshRequestDto(refreshToken: session.refreshToken),
    );
    if (_disposed || generation != _generation) {
      // Session replaced or ended while refreshing: discard the late result.
      return TokenRefreshOutcome.invalidated;
    }
    switch (result) {
      case Success<LoginResponseDto>(:final value):
        final rotated = RemoteAuthMapper.fromLogin(value);
        try {
          await _persist(rotated);
        } catch (_) {
          // The server already rotated the refresh token; without persisting the
          // new pair the old one is unusable, so end the session cleanly rather
          // than leaving an inconsistent authenticated state.
          await _invalidate();
          return TokenRefreshOutcome.invalidated;
        }
        _accept(rotated);
        _emit(rotated.context);
        return TokenRefreshOutcome.refreshed;
      case Failed<LoginResponseDto>(:final failure):
        if (ApiErrorCodes.sessionEndingCodes.contains(failure.code)) {
          await _invalidate();
          return TokenRefreshOutcome.invalidated;
        }
        return TokenRefreshOutcome.unavailable;
    }
  }

  // --- Effective access (SessionAccessSink) ---------------------------------

  @override
  Future<void> applyEffectivePermissions(PermissionSet permissions) =>
      applyEffectiveAccess(permissions);

  @override
  Future<void> applyEffectiveAccess(
    PermissionSet permissions, {
    Set<String>? enabledModules,
  }) => _serial(() async {
    final current = _session;
    if (current == null || _disposed) return;
    final user = current.context.user.copyWith(permissions: permissions);
    final company = enabledModules == null
        ? current.context.company
        : current.context.company.copyWith(enabledModules: enabledModules);
    if (user.permissions == current.context.user.permissions &&
        company == current.context.company) {
      return;
    }
    final updated = AuthSession(
      accessToken: current.accessToken,
      refreshToken: current.refreshToken,
      expiresAt: current.expiresAt,
      refreshTokenExpiresAt: current.refreshTokenExpiresAt,
      tokenType: current.tokenType,
      context: current.context.copyWith(user: user, company: company),
    );
    try {
      await _persist(updated);
    } catch (_) {
      /* Session remains usable in memory for this process. */
    }
    _accept(updated);
    _emit(updated.context);
  });

  @override
  Future<void> dispose() async {
    _disposed = true;
    await _sessionSubscription?.cancel();
    _expiry?.cancel();
    if (_operations != null) await _operations;
    await _changes.close();
  }
}
