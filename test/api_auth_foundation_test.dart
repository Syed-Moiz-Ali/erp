import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/api_redaction.dart';
import 'package:modular_erp/core/api/token_refresh_coordinator.dart';
import 'package:modular_erp/core/api/token_refresher.dart';

import 'support/api_test_harness.dart';
import 'support/memory_session_storage.dart';

String envelopeWithToken(
  String access, {
  Duration accessLifetime = const Duration(hours: 1),
}) => jsonEncode({
  'accessToken': access,
  'refreshToken': 'refresh-1',
  'expiresAt': DateTime.now().toUtc().add(accessLifetime).toIso8601String(),
  'refreshTokenExpiresAt': DateTime.now()
      .toUtc()
      .add(const Duration(days: 30))
      .toIso8601String(),
});

void main() {
  late FakeDioAdapter adapter;
  late MemorySessionStorage storage;

  setUp(() {
    adapter = FakeDioAdapter(
      (_) => jsonResponse(envelope(data: {'v': 1}), 200),
    );
    storage = MemorySessionStorage();
  });

  group('authorization header', () {
    test('attaches a bearer token to protected requests', () async {
      storage.value = envelopeWithToken('access-1');
      final client = buildClient(adapter: adapter, storage: storage);
      await client.get<Object?>('/api/departments', fromJson: (json) => json);
      expect(adapter.last.headers['Authorization'], 'Bearer access-1');
    });

    test('omits the token for public requests', () async {
      storage.value = envelopeWithToken('access-1');
      final client = buildClient(adapter: adapter, storage: storage);
      await client.get<Object?>(
        '/api/auth/login',
        requiresAuth: false,
        fromJson: (json) => json,
      );
      expect(adapter.last.headers['Authorization'], isNull);
    });

    test('omits the token when none is stored', () async {
      final client = buildClient(adapter: adapter, storage: storage);
      await client.get<Object?>('/api/departments', fromJson: (json) => json);
      expect(adapter.last.headers['Authorization'], isNull);
    });

    test('never leaks the token to an untrusted origin', () async {
      storage.value = envelopeWithToken('access-1');
      final client = buildClient(adapter: adapter, storage: storage);
      await client.get<Object?>(
        'https://evil.example.com/steal',
        fromJson: (json) => json,
      );
      expect(adapter.last.headers['Authorization'], isNull);
      expect(adapter.last.uri.host, 'evil.example.com');
    });
  });

  group('proactive refresh', () {
    test(
      'refreshes before a near-expiry request and uses the new token',
      () async {
        storage.value = envelopeWithToken(
          'old-token',
          accessLifetime: const Duration(seconds: 30),
        );
        final refresher = FakeTokenRefresher(
          TokenRefreshOutcome.refreshed,
          onRefresh: () async {
            storage.value = envelopeWithToken('new-token');
          },
        );
        final coordinator = TokenRefreshCoordinator(refresher: refresher);
        final client = buildClient(
          adapter: adapter,
          storage: storage,
          coordinator: coordinator,
        );
        await client.get<Object?>('/api/departments', fromJson: (json) => json);
        expect(refresher.calls, 1);
        expect(adapter.last.headers['Authorization'], 'Bearer new-token');
      },
    );

    test('does not refresh when no refresher is wired', () async {
      storage.value = envelopeWithToken(
        'old-token',
        accessLifetime: const Duration(seconds: 30),
      );
      final client = buildClient(adapter: adapter, storage: storage);
      await client.get<Object?>('/api/departments', fromJson: (json) => json);
      expect(adapter.last.headers['Authorization'], 'Bearer old-token');
    });
  });

  group('redaction', () {
    test('masks authorization and cookie headers', () {
      final safe = ApiRedaction.headers({
        'Authorization': 'Bearer secret',
        'Cookie': 'session=abc',
        'Accept': 'application/json',
      });
      expect(safe['Authorization'], ApiRedaction.mask);
      expect(safe['Cookie'], ApiRedaction.mask);
      expect(safe['Accept'], 'application/json');
    });

    test('masks token and authorization values', () {
      expect(ApiRedaction.token('abcdef'), ApiRedaction.mask);
      expect(ApiRedaction.token(null), '');
      expect(ApiRedaction.authorization('Bearer abc'), ApiRedaction.mask);
    });
  });
}
