import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/api_redaction.dart';
import 'package:modular_erp/core/api/session_endpoint.dart';
import 'package:modular_erp/core/api/token_refresh_coordinator.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/platform/auth/data/datasources/remote/dio_auth_remote_data_source.dart';
import 'package:modular_erp/platform/auth/data/repositories/remote_auth_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

import 'support/api_test_harness.dart';
import 'support/auth_test_doubles.dart';
import 'support/memory_session_storage.dart';

void main() {
  group('sensitive value redaction', () {
    test('the domain session never renders tokens', () {
      final session = AuthSession(
        accessToken: 'super-secret-access',
        refreshToken: 'super-secret-refresh',
        expiresAt: DateTime.utc(2030),
        context: AuthContext(
          user: UserAccount(
            id: '1',
            displayName: 'A',
            email: 'a',
            companyId: '1',
            permissions: PermissionSet(const []),
            status: AccountStatus.active,
          ),
          company: const CompanyContext(
            id: '1',
            name: 'C',
            code: 'C',
            timezone: 'UTC',
            defaultLocale: 'en',
            enabledModules: {},
          ),
        ),
      );
      expect(session.toString(), isNot(contains('super-secret')));
    });

    test('the login event never renders the password or identifier', () {
      const event = AuthLoginRequested('AdminUser', 'p@ssw0rd!');
      expect(event.toString(), isNot(contains('p@ssw0rd!')));
      expect(event.toString(), isNot(contains('AdminUser')));
    });

    test('redaction masks authorization and token material', () {
      final safe = ApiRedaction.headers({
        'Authorization': 'Bearer secret-token',
        'Accept': 'application/json',
      });
      expect(safe['Authorization'], isNot(contains('secret-token')));
      expect(safe['Accept'], 'application/json');
      expect(
        ApiRedaction.token('secret-token'),
        isNot(contains('secret-token')),
      );
    });
  });

  group('transport security', () {
    late FakeDioAdapter adapter;
    late MemorySessionStorage storage;
    late ApiClient client;
    late DioAuthRemoteDataSource dataSource;
    late RemoteAuthRepository repository;
    late SessionEndpoint endpoint;
    late TokenRefreshCoordinator coordinator;

    setUp(() {
      adapter = FakeDioAdapter(
        (_) =>
            jsonResponse(envelope(data: sampleLoginResponse().toJson()), 200),
      );
      storage = MemorySessionStorage();
      endpoint = SessionEndpoint();
      coordinator = TokenRefreshCoordinator();
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
    });

    tearDown(() async {
      await repository.dispose();
      await endpoint.dispose();
      client.close();
    });

    test('login never sends an Authorization header', () async {
      await repository.login(AuthIdentifier.parse('Admin')!, 'secret');
      expect(adapter.last.headers['Authorization'], isNull);
      expect(adapter.last.uri.path, endsWith('/api/auth/login'));
    });

    test('a login failure carries no credential material', () async {
      adapter.handler = (_) => jsonResponse(
        envelope(
          success: false,
          errors: [
            errorEntry(
              'AUTH_INVALID_CREDENTIALS',
              message: 'Invalid login ID or password.',
            ),
          ],
        ),
        401,
      );
      final result = await repository.login(
        AuthIdentifier.parse('Admin')!,
        'topsecret',
      );
      final failure = (result as Failed).failure;
      expect(failure.toString(), isNot(contains('topsecret')));
      expect(failure.serverMessage, isNot(contains('topsecret')));
    });

    test('authorization is never sent to an untrusted origin', () async {
      await repository.login(AuthIdentifier.parse('Admin')!, 'secret');
      await client.get<Object?>(
        'https://evil.example.com/steal',
        fromJson: (json) => json,
      );
      expect(adapter.last.headers['Authorization'], isNull);
    });
  });
}
