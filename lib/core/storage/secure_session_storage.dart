import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SessionStorage {
  Future<String?> readSession();
  Future<void> saveSession(String serializedSession);
  Future<void> clearSession();
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
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

  Future<String?> _token(String key) async {
    final raw = await readSession();
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final expires = DateTime.parse(json['expiresAt'] as String);
      if (!expires.isAfter(DateTime.now().toUtc())) return null;
      return json[key] as String?;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  @override
  Future<String?> readAccessToken() => _token('accessToken');
  @override
  Future<String?> readRefreshToken() => _token('refreshToken');
}
