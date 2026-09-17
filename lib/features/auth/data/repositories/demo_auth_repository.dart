import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/storage/secure_session_storage.dart';
import '../../domain/entities/auth_context.dart';
import '../../../../core/auth/auth_identifier.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/demo_auth_source.dart';
import '../dto/auth_session_dto.dart';

class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository(this.storage, {this.source, DateTime Function()? now})
    : _now = now ?? DateTime.now;
  final SessionStorage storage;
  final DemoAuthSource? source;
  final DateTime Function() _now;
  final _changes = StreamController<AuthContext?>.broadcast();
  AuthSession? _session;
  Timer? _expiry;
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
  void _accept(AuthSession session) {
    _session = session;
    _expiry?.cancel();
    _expiry = Timer(session.expiresAt.difference(_now().toUtc()), () {
      _session = null;
      _changes.add(
        null,
      ); // Revoke UI access immediately, even if deletion fails.
      unawaited(_serial(_clearExpired));
    });
  }

  Future<void> _clearExpired() async {
    try {
      await storage.clearSession();
    } catch (_) {
      /* Expired envelope remains unusable. */
    }
  }

  @override
  Future<Result<AuthContext?>> restoreSession() => _serial(_restoreSession);
  Future<Result<AuthContext?>> _restoreSession() async {
    try {
      final raw = await storage.readSession();
      if (raw == null) return const Success(null);
      AuthSession session;
      try {
        session = AuthSessionMapper.decode(
          AuthSessionDto.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        );
        final account = source?.findUser(session.context.user.id);
        if (account == null ||
            session.context.user.status != AccountStatus.active ||
            !session.expiresAt.isAfter(_now().toUtc()) ||
            session.context.company.id != account.context.company.id ||
            !session.accessToken.startsWith('demo-access-') ||
            !session.refreshToken.startsWith('demo-refresh-')) {
          throw const FormatException('Unusable session');
        }
      } catch (_) {
        await storage.clearSession();
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
    if (source == null) {
      return const Failed(
        Failure(code: 'demo_disabled', kind: FailureKind.demoDisabled),
      );
    }
    final account = source!.authenticate(identifier, password);
    if (account == null) {
      return const Failed(
        Failure(
          code: 'invalid_credentials',
          kind: FailureKind.invalidCredentials,
        ),
      );
    }
    final session = AuthSession(
      accessToken: 'demo-access-${const Uuid().v4()}',
      refreshToken: 'demo-refresh-${const Uuid().v4()}',
      expiresAt: _now().toUtc().add(const Duration(hours: 8)),
      context: account.context,
    );
    try {
      await storage.saveSession(
        jsonEncode(AuthSessionMapper.encode(session).toJson()),
      );
      _accept(session);
      return Success(session.context);
    } catch (_) {
      return const Failed(
        Failure(code: 'session_save', kind: FailureKind.sessionStorage),
      );
    }
  }

  @override
  Future<Result<void>> logout() => _serial(_logout);
  Future<Result<void>> _logout() async {
    try {
      await storage.clearSession();
      _expiry?.cancel();
      _session = null;
      return const Success(null);
    } catch (_) {
      return const Failed(
        Failure(code: 'session_clear', kind: FailureKind.sessionStorage),
      );
    }
  }

  @override
  Future<Result<void>> requestPasswordReset(AuthIdentifier identifier) async =>
      source == null
      ? const Failed(
          Failure(code: 'demo_disabled', kind: FailureKind.demoDisabled),
        )
      : const Success(null);
  @override
  Future<Result<void>> changePassword(
    String currentPassword,
    String newPassword,
  ) => _serial(() => _changePassword(currentPassword, newPassword));
  Future<Result<void>> _changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final session = _session;
    if (session == null || !session.expiresAt.isAfter(_now().toUtc())) {
      return const Failed(
        Failure(code: 'session_expired', kind: FailureKind.sessionExpired),
      );
    }
    if (newPassword.length < 8 ||
        !RegExp(r'[A-Za-z]').hasMatch(newPassword) ||
        !RegExp(r'[0-9]').hasMatch(newPassword)) {
      return const Failed(
        Failure(code: 'password_policy', kind: FailureKind.passwordPolicy),
      );
    }
    if (source?.changePassword(
          session.context.user.id,
          currentPassword,
          newPassword,
        ) !=
        true) {
      return const Failed(
        Failure(code: 'current_password', kind: FailureKind.currentPassword),
      );
    }
    return const Success(null);
  }

  @override
  Future<void> dispose() async {
    _expiry?.cancel();
    if (_operations != null) await _operations;
    await _changes.close();
  }
}
