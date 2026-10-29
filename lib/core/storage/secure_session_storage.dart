import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SessionStorage {
  Future<String?> readSession();
  Future<void> saveSession(String serializedSession);
  Future<void> clearSession();
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<DateTime?> readAccessTokenExpiresAt();
  Future<DateTime?> readRefreshTokenExpiresAt();

  /// Whether a refresh token is present (used to decide if a refresh is
  /// possible before hitting the server).
  Future<bool> hasRefreshToken();
}

/// One secure envelope prevents partial token/metadata writes.
class SecureSessionStorage implements SessionStorage {
  SecureSessionStorage(this.storage);
  final FlutterSecureStorage storage;
  static const sessionKey = 'session.envelope.v1';
  @override
  Future<String?> readSession() => storage.read(key: sessionKey);
  @override
  Future<void> saveSession(String serializedSession) =>
      storage.write(key: sessionKey, value: serializedSession);
  @override
  Future<void> clearSession() async {
    await storage.delete(key: sessionKey);
    // Remove Phase 0 keys if they exist on an upgraded installation.
    await storage.delete(key: 'session.access');
    await storage.delete(key: 'session.refresh');
  }

  Future<Map<String, dynamic>?> _envelope() async {
    final raw = await readSession();
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  static DateTime? _parseDate(dynamic value) =>
      value is String ? DateTime.tryParse(value) : null;

  @override
  Future<String?> readAccessToken() async {
    final json = await _envelope();
    if (json == null) return null;
    final expires = _parseDate(json['expiresAt']);
    if (expires == null || !expires.isAfter(DateTime.now().toUtc())) {
      return null;
    }
    return json['accessToken'] as String?;
  }

  /// The refresh token lifetime is independent of the access token; it is only
  /// gated by its own expiry (when present). Older envelopes without a refresh
  /// expiry are returned as-is and validated by the server on use.
  @override
  Future<String?> readRefreshToken() async {
    final json = await _envelope();
    if (json == null) return null;
    final expires = _parseDate(json['refreshTokenExpiresAt']);
    if (expires != null && !expires.isAfter(DateTime.now().toUtc())) {
      return null;
    }
    return json['refreshToken'] as String?;
  }

  @override
  Future<DateTime?> readAccessTokenExpiresAt() async =>
      _parseDate((await _envelope())?['expiresAt']);

  @override
  Future<DateTime?> readRefreshTokenExpiresAt() async =>
      _parseDate((await _envelope())?['refreshTokenExpiresAt']);

  @override
  Future<bool> hasRefreshToken() async =>
      (await readRefreshToken())?.isNotEmpty ?? false;
}
