import 'dart:convert';
import 'package:modular_erp/core/storage/secure_session_storage.dart';

class MemorySessionStorage implements SessionStorage {
  String? value;
  bool failRead = false, failWrite = false, failClear = false;
  int saves = 0, clears = 0;
  @override
  Future<String?> readSession() async {
    if (failRead) throw StateError('read');
    return value;
  }

  @override
  Future<void> saveSession(String serializedSession) async {
    if (failWrite) throw StateError('write');
    saves++;
    value = serializedSession;
  }

  @override
  Future<void> clearSession() async {
    if (failClear) throw StateError('clear');
    clears++;
    value = null;
  }

  @override
  Future<String?> readAccessToken() async => value == null
      ? null
      : (jsonDecode(value!) as Map<String, dynamic>)['accessToken'] as String?;
  @override
  Future<String?> readRefreshToken() async => value == null
      ? null
      : (jsonDecode(value!) as Map<String, dynamic>)['refreshToken'] as String?;
}
