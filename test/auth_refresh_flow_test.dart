import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/session_endpoint.dart';
import 'package:modular_erp/core/api/token_refresh_coordinator.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/data/datasources/remote/dio_auth_remote_data_source.dart';
import 'package:modular_erp/platform/auth/data/repositories/remote_auth_repository.dart';

import 'support/api_test_harness.dart';
import 'support/auth_test_doubles.dart';
import 'support/memory_session_storage.dart';

void main() {
  late MemorySessionStorage storage;
  late TokenRefreshCoordinator coordinator;
  late SessionEndpoint endpoint;
  late DioAuthRemoteDataSource dataSource;
  late RemoteAuthRepository repository;
  late ApiClient client;
  late FakeDioAdapter adapter;
  int refreshCalls = 0;
  int protectedCalls = 0;

  void setUpHarness({required bool rejectRotatedToken}) {
    refreshCalls = 0;
    protectedCalls = 0;
    storage = MemorySessionStorage();
    coordinator = TokenRefreshCoordinator();
    endpoint = SessionEndpoint();
    adapter = FakeDioAdapter((options) {
      final path = options.uri.path;
      if (path.endsWith('/api/auth/login')) {
        return jsonResponse(
          envelope(data: sampleLoginResponse(access: 'access-1').toJson()),
          200,
        );
      }
      if (path.endsWith('/api/auth/refresh')) {
        refreshCalls++;
        return jsonResponse(
          envelope(
            data: sampleLoginResponse(
              access: 'access-2',
              refresh: 'refresh-2',
            ).toJson(),
          ),
          200,
        );
      }
      // Protected endpoint: reject the first-generation token.
      protectedCalls++;
      final auth = options.headers['Authorization'];
      final rejected = auth == 'Bearer access-1' || rejectRotatedToken;
      if (rejected) {
        return jsonResponse(
          envelope(
            success: false,
            errors: [errorEntry('AUTH_TOKEN_EXPIRED', message: 'expired')],
          ),
          401,
        );
      }
      return jsonResponse(envelope(data: {'ok': true}), 200);
    });
    client = ApiClient(
      baseUrl: 'https://api.example.com',
      storage: storage,
      refreshCoordinator: coordinator,
      sessionEndpoint: endpoint,
      dio: Dio()..httpClientAdapter = adapter,
    );
    dataSource = DioAuthRemoteDataSource(client);
    repository = RemoteAuthRepository(
      dataSource: dataSource,
      storage: storage,
      sessionEndpoint: endpoint,
    );
    coordinator.refresher = repository;
  }

  AuthIdentifier loginId() => AuthIdentifier.parse('Admin')!;

  tearDown(() async {
    await repository.dispose();
    await endpoint.dispose();
    client.close();
  });

  test(
    'five simultaneous protected requests trigger exactly one refresh',
    () async {
      setUpHarness(rejectRotatedToken: false);
      final login = await repository.login(loginId(), 'secret');
      expect(login, isA<Success>());

      final results = await Future.wait([
        for (var i = 0; i < 5; i++)
          client.get<Object?>('/api/departments', fromJson: (json) => json),
      ]);

      expect(refreshCalls, 1);
      expect(results.whereType<Success<Object?>>().length, 5);
      expect(protectedCalls, 10); // five rejected + five retried
      // The rotated tokens were persisted.
      final envelopeJson = jsonDecode(storage.value!) as Map<String, dynamic>;
      expect(envelopeJson['accessToken'], 'access-2');
      expect(envelopeJson['refreshToken'], 'refresh-2');
    },
  );

  test('a repeated 401 after one retry is not retried again', () async {
    setUpHarness(rejectRotatedToken: true);
    await repository.login(loginId(), 'secret');

    final result = await client.get<Object?>(
      '/api/departments',
      fromJson: (json) => json,
    );

    expect(result, isA<Failed<Object?>>());
    expect((result as Failed).failure.kind, FailureKind.sessionExpired);
    expect(refreshCalls, 1);
    expect(protectedCalls, 2); // original + one retry only
  });
}
