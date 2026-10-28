import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/token_refresher.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:modular_erp/platform/auth/data/dto/auth_remote_dtos.dart';
import 'package:modular_erp/platform/auth/data/repositories/remote_auth_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

import 'support/memory_session_storage.dart';

Map<String, dynamic> load(String name) =>
    jsonDecode(File('test/fixtures/auth/$name').readAsStringSync())
        as Map<String, dynamic>;

LoginResponseDto dto(String name) =>
    LoginResponseDto.fromJson((load(name)['data'] as Map).cast());

class FixtureAuthDataSource implements AuthRemoteDataSource {
  int loginCalls = 0;
  int refreshCalls = 0;
  LoginRequestDto? lastLogin;
  RefreshRequestDto? lastRefresh;

  @override
  Future<Result<LoginResponseDto>> login(LoginRequestDto request) async {
    loginCalls++;
    lastLogin = request;
    return Success(dto('login_success.json'));
  }

  @override
  Future<Result<LoginResponseDto>> refresh(RefreshRequestDto request) async {
    refreshCalls++;
    lastRefresh = request;
    return Success(dto('refresh_success.json'));
  }

  @override
  Future<Result<void>> logout(LogoutRequestDto request) async =>
      const Success(null);
}

void main() {
  late FixtureAuthDataSource dataSource;
  late MemorySessionStorage storage;
  late RemoteAuthRepository repository;

  setUp(() {
    dataSource = FixtureAuthDataSource();
    storage = MemorySessionStorage();
    repository = RemoteAuthRepository(
      dataSource: dataSource,
      storage: storage,
      now: () => DateTime.utc(2026, 10, 28, 5),
    );
  });

  tearDown(() => repository.dispose());

  test(
    'login persists the fixture session with stable integer identities',
    () async {
      final result = await repository.login(
        AuthIdentifier.parse('qa.admin')!,
        'sanitized-password',
      );
      expect(result, isA<Success<AuthContext>>());
      final context = (result as Success<AuthContext>).value;
      expect(dataSource.lastLogin!.loginId, 'qa.admin');
      expect(context.user.id, '8');
      expect(context.user.loginId, 'qa.admin');
      expect(context.user.email, isNull);
      expect(context.company.id, '1');
      expect(context.employeeReference?.id, '1');
      expect(context.branches, hasLength(2));

      final stored = jsonDecode(storage.value!) as Map<String, dynamic>;
      expect(stored['accessToken'], 'SANITIZED_ACCESS_TOKEN');
      expect(stored['refreshToken'], 'SANITIZED_REFRESH_TOKEN');
      expect(storage.value, isNot(contains('sanitized-password')));
    },
  );

  test('restore keeps loginId, absent email and branches', () async {
    await repository.login(
      AuthIdentifier.parse('qa.admin')!,
      'sanitized-password',
    );
    await repository.dispose();

    repository = RemoteAuthRepository(
      dataSource: dataSource,
      storage: storage,
      now: () => DateTime.utc(2026, 10, 28, 5),
    );
    final result = await repository.restoreSession();
    final context = (result as Success<AuthContext?>).value!;
    expect(context.user.loginId, 'qa.admin');
    expect(context.user.email, isNull);
    expect(context.branches.map((b) => b.name), ['Company A', 'Branch B']);
  });

  test('refresh rotates and persists the fixture token pair', () async {
    await repository.login(
      AuthIdentifier.parse('qa.admin')!,
      'sanitized-password',
    );
    final outcome = await repository.refresh();
    expect(outcome, TokenRefreshOutcome.refreshed);
    expect(dataSource.refreshCalls, 1);
    expect(dataSource.lastRefresh!.refreshToken, 'SANITIZED_REFRESH_TOKEN');

    final stored = jsonDecode(storage.value!) as Map<String, dynamic>;
    expect(stored['accessToken'], 'SANITIZED_ROTATED_ACCESS_TOKEN');
    expect(stored['refreshToken'], 'SANITIZED_ROTATED_REFRESH_TOKEN');
  });
}
