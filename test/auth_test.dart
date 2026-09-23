import 'package:modular_erp/app/module_registry/navigation_resolver.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:modular_erp/app/router/app_router.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/storage/secure_session_storage.dart';
import 'package:modular_erp/core/validation/app_validation.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/data/dto/auth_session_dto.dart';
import 'package:modular_erp/platform/auth/data/repositories/demo_auth_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/password_bloc.dart';
import 'support/memory_session_storage.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

Matcher status(AuthStatus expected) =>
    isA<AuthState>().having((s) => s.status, 'status', expected);
void main() {
  late MemorySessionStorage storage;
  late DemoAuthSource source;
  late DemoAuthRepository repository;
  String? redirect(AuthState auth, Uri uri) => authRedirect(
    auth,
    uri,
    navigation: NavigationResolver(createErpRegistry(repository)),
  );
  setUp(() {
    storage = MemorySessionStorage();
    source = DemoAuthSource();
    repository = DemoAuthRepository(storage, source: source);
  });
  tearDown(() => repository.dispose());
  blocTest<AuthBloc, AuthState>(
    'bootstrap without session becomes unauthenticated',
    build: () => AuthBloc(repository),
    act: (bloc) => bloc.add(const AuthBootstrapRequested()),
    expect: () => [
      status(AuthStatus.bootstrapping),
      status(AuthStatus.unauthenticated),
    ],
  );
  blocTest<AuthBloc, AuthState>(
    'bootstrap restores valid secure context with no tokens in state',
    setUp: () async {
      await repository.login(AuthIdentifier.parse('hr@erp.demo')!, 'Hr@123');
    },
    build: () => AuthBloc(repository),
    act: (bloc) => bloc.add(const AuthBootstrapRequested()),
    expect: () => [
      status(AuthStatus.bootstrapping),
      isA<AuthState>().having((s) => s.context!.user.role, 'role', AppRole.hr),
    ],
    verify: (bloc) {
      expect(bloc.state.context!.company.enabledModules, {
        'dashboard',
        'employees',
        'attendance',
        'leave',
        'reports',
        'settings',
      });
    },
  );
  blocTest<AuthBloc, AuthState>(
    'correct login authenticates',
    build: () => AuthBloc(repository),
    act: (bloc) =>
        bloc.add(const AuthLoginRequested('employee@erp.demo', 'Employee@123')),
    expect: () => [
      status(AuthStatus.authenticating),
      status(AuthStatus.authenticated),
    ],
    verify: (_) {
      expect(storage.saves, 1);
      expect(storage.value, isNot(contains('Employee@123')));
    },
  );
  blocTest<AuthBloc, AuthState>(
    'incorrect credentials remain unauthenticated with safe typed failure',
    build: () => AuthBloc(repository),
    act: (bloc) => bloc.add(const AuthLoginRequested('hr@erp.demo', 'wrong')),
    expect: () => [
      status(AuthStatus.authenticating),
      isA<AuthState>().having(
        (s) => s.failure?.kind,
        'failure',
        FailureKind.invalidCredentials,
      ),
    ],
    verify: (_) => expect(storage.value, isNull),
  );
  blocTest<AuthBloc, AuthState>(
    'logout clears secure session before unauthenticated',
    setUp: () async {
      await repository.login(AuthIdentifier.parse('hr@erp.demo')!, 'Hr@123');
    },
    build: () => AuthBloc(repository),
    act: (bloc) async {
      bloc.add(const AuthBootstrapRequested());
      await bloc.stream.firstWhere((s) => s.isAuthenticated);
      bloc.add(const AuthLogoutRequested());
    },
    expect: () => [
      status(AuthStatus.bootstrapping),
      status(AuthStatus.authenticated),
      isA<AuthState>().having((s) => s.loggingOut, 'loggingOut', true),
      status(AuthStatus.unauthenticated),
    ],
    verify: (_) {
      expect(storage.value, isNull);
      expect(storage.clears, 1);
    },
  );
  blocTest<AuthBloc, AuthState>(
    'corrupt session is cleared during bootstrap',
    setUp: () {
      storage.value = '{broken';
    },
    build: () => AuthBloc(repository),
    act: (bloc) => bloc.add(const AuthBootstrapRequested()),
    expect: () => [
      status(AuthStatus.bootstrapping),
      status(AuthStatus.unauthenticated),
    ],
    verify: (_) {
      expect(storage.value, isNull);
      expect(storage.clears, 1);
    },
  );
  blocTest<AuthBloc, AuthState>(
    'secure write failure does not authenticate',
    setUp: () {
      storage.failWrite = true;
    },
    build: () => AuthBloc(repository),
    act: (bloc) => bloc.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123')),
    expect: () => [
      status(AuthStatus.authenticating),
      isA<AuthState>().having(
        (s) => s.failure?.kind,
        'failure',
        FailureKind.sessionStorage,
      ),
    ],
  );
  blocTest<AuthBloc, AuthState>(
    'logout storage failure keeps context and allows retry',
    setUp: () async {
      await repository.login(AuthIdentifier.parse('hr@erp.demo')!, 'Hr@123');
      storage.failClear = true;
    },
    build: () => AuthBloc(repository),
    act: (bloc) async {
      bloc.add(const AuthBootstrapRequested());
      await bloc.stream.firstWhere((s) => s.isAuthenticated);
      bloc.add(const AuthLogoutRequested());
    },
    expect: () => [
      status(AuthStatus.bootstrapping),
      status(AuthStatus.authenticated),
      isA<AuthState>().having((s) => s.loggingOut, 'pending', true),
      isA<AuthState>().having(
        (s) =>
            s.isAuthenticated && s.failure?.kind == FailureKind.sessionStorage,
        'retryable authenticated state',
        true,
      ),
    ],
  );
  blocTest<AuthBloc, AuthState>(
    'forced expiry revokes access and removes secure tokens',
    setUp: () async {
      await repository.login(AuthIdentifier.parse('hr@erp.demo')!, 'Hr@123');
    },
    build: () => AuthBloc(repository),
    act: (bloc) async {
      bloc.add(const AuthBootstrapRequested());
      await bloc.stream.firstWhere((s) => s.isAuthenticated);
      bloc.add(const AuthSessionExpired());
    },
    expect: () => [
      status(AuthStatus.bootstrapping),
      status(AuthStatus.authenticated),
      isA<AuthState>().having(
        (s) => s.failure?.kind,
        'expired',
        FailureKind.sessionExpired,
      ),
    ],
    verify: (_) => expect(storage.value, isNull),
  );
  blocTest<AuthBloc, AuthState>(
    'resume session check fails closed when secure context is corrupt',
    setUp: () async {
      await repository.login(AuthIdentifier.parse('hr@erp.demo')!, 'Hr@123');
    },
    build: () => AuthBloc(repository),
    act: (bloc) async {
      bloc.add(const AuthBootstrapRequested());
      await bloc.stream.firstWhere((s) => s.isAuthenticated);
      storage.value = '{corrupt';
      bloc.add(const AuthSessionCheckRequested());
    },
    expect: () => [
      status(AuthStatus.bootstrapping),
      status(AuthStatus.authenticated),
      status(AuthStatus.unauthenticated),
    ],
    verify: (_) => expect(storage.value, isNull),
  );
  test('identifiers normalize email and gracefully accept formatted phone', () {
    expect(AuthIdentifier.parse(' HR@ERP.DEMO ')!.value, 'hr@erp.demo');
    expect(AuthIdentifier.parse('+1 (555) 000-1003')!.value, '+15550001003');
    expect(AuthIdentifier.parse('not a phone'), isNull);
    expect(AuthIdentifier.parse('+12'), isNull);
    expect(AppValidation.identifier(''), ValidationIssue.identifierRequired);
    expect(AppValidation.newPassword('كلمةمرور١٢٣', 'Old@1234'), isNull);
    expect(
      AppValidation.newPassword('weak', 'Old@1234'),
      ValidationIssue.passwordWeak,
    );
    expect(
      AppValidation.confirmPassword('different', 'New@1234'),
      ValidationIssue.passwordMismatch,
    );
  });
  test(
    'five demo roles support email and phone with unique relationships',
    () async {
      for (final account in source.accounts) {
        final result = await repository.login(
          AuthIdentifier.parse(account.context.user.phone!)!,
          account.password,
        );
        expect(result, isA<Success<AuthContext>>());
        expect(
          (result as Success<AuthContext>).value.user.id,
          account.context.user.id,
        );
        expect(
          account.context.employeeReference?.userAccountId,
          account.context.employeeReference == null
              ? null
              : account.context.user.id,
        );
      }
      expect(source.accounts.map((a) => a.context.user.id).toSet().length, 5);
    },
  );
  test('permissions use explicit grants and differ by demo role', () {
    expect(
      PermissionChecker(
        demoPermissions(AppRole.employee),
      ).can(AppPermission.employeeCreate),
      false,
    );
    expect(
      PermissionChecker(
        demoPermissions(AppRole.hr),
      ).can(AppPermission.employeeCreate),
      true,
    );
    expect(
      PermissionChecker(
        demoPermissions(AppRole.manager),
      ).can(AppPermission.employeeViewTeam),
      true,
    );
    expect(
      PermissionChecker(demoPermissions(AppRole.superAdmin)).canAll([
        AppPermission.companyManage,
        AppPermission.userManage,
        AppPermission.roleManage,
      ]),
      true,
    );
    expect(
      () => demoPermissions(
        AppRole.employee,
      ).values.add(AppPermission.roleManage),
      throwsUnsupportedError,
    );
    expect(
      PermissionChecker(PermissionSet([])).can(AppPermission.employeeCreate),
      false,
    );
  });
  test(
    'DTO roundtrip separates employment and fails closed on unknown grants',
    () async {
      await repository.login(AuthIdentifier.parse('hr@erp.demo')!, 'Hr@123');
      final json = jsonDecode(storage.value!) as Map<String, dynamic>;
      (json['user']['permissions'] as List).add('futurePermission');
      final session = AuthSessionMapper.decode(AuthSessionDto.fromJson(json));
      expect(
        session.context.user.permissions.length,
        demoPermissions(AppRole.hr).length,
      );
      expect(session.toString(), isNot(contains(session.accessToken)));
      expect(AuthSessionMapper.encode(session).toJson()['employee'], isNotNull);
      json['user']['companyId'] = 'other-company';
      expect(
        () => AuthSessionMapper.decode(AuthSessionDto.fromJson(json)),
        throwsFormatException,
      );
    },
  );
  test(
    'expired envelope is cleared and never restores authentication',
    () async {
      await repository.login(AuthIdentifier.parse('hr@erp.demo')!, 'Hr@123');
      final json = jsonDecode(storage.value!) as Map<String, dynamic>;
      json['expiresAt'] = DateTime.utc(2000).toIso8601String();
      storage.value = jsonEncode(json);
      final second = DemoAuthRepository(storage, source: source);
      expect(
        (await second.restoreSession() as Success<AuthContext?>).value,
        isNull,
      );
      expect(storage.value, isNull);
      await second.dispose();
    },
  );
  test('fresh repository restores a saved secure session', () async {
    await repository.login(
      AuthIdentifier.parse('manager@erp.demo')!,
      'Manager@123',
    );
    final second = DemoAuthRepository(storage, source: DemoAuthSource());
    final result = await second.restoreSession() as Success<AuthContext?>;
    expect(result.value!.user.role, AppRole.manager);
    await second.dispose();
  });
  test(
    'disabled demo configuration never authenticates or restores fixtures',
    () async {
      await repository.login(AuthIdentifier.parse('hr@erp.demo')!, 'Hr@123');
      final disabled = DemoAuthRepository(storage);
      expect(
        (await disabled.restoreSession() as Success<AuthContext?>).value,
        isNull,
      );
      expect(
        (await disabled.login(AuthIdentifier.parse('hr@erp.demo')!, 'Hr@123')
                as Failed<AuthContext>)
            .failure
            .kind,
        FailureKind.demoDisabled,
      );
      await disabled.dispose();
    },
  );
  test(
    'demo change password updates in-memory source and never persists password',
    () async {
      await repository.login(
        AuthIdentifier.parse('employee@erp.demo')!,
        'Employee@123',
      );
      expect(
        await repository.changePassword('wrong', 'Better@123'),
        isA<Failed<void>>(),
      );
      expect(
        await repository.changePassword('Employee@123', 'Better@123'),
        isA<Success<void>>(),
      );
      expect(
        await repository.login(
          AuthIdentifier.parse('employee@erp.demo')!,
          'Employee@123',
        ),
        isA<Failed<AuthContext>>(),
      );
      expect(
        await repository.login(
          AuthIdentifier.parse('employee@erp.demo')!,
          'Better@123',
        ),
        isA<Success<AuthContext>>(),
      );
      expect(storage.value, isNot(contains('Better@123')));
    },
  );
  blocTest<PasswordBloc, PasswordState>(
    'reset workflow succeeds without claiming delivery',
    build: () => PasswordBloc(repository),
    act: (bloc) => bloc.add(const PasswordResetRequested('unknown@erp.demo')),
    expect: () => [
      isA<PasswordState>().having(
        (s) => s.status,
        'pending',
        PasswordStatus.submitting,
      ),
      isA<PasswordState>().having(
        (s) => s.status,
        'success',
        PasswordStatus.success,
      ),
    ],
  );
  test(
    'router guards public/protected/bootstrap paths and reject external targets',
    () {
      const guest = AuthState(AuthStatus.unauthenticated);
      final member = AuthState(
        AuthStatus.authenticated,
        context: source.accounts.first.context,
      );
      expect(redirect(guest, Uri.parse('/app')), '/login?from=%2Fapp');
      expect(redirect(member, Uri.parse('/login')), '/app/hr');
      expect(
        redirect(const AuthState(AuthStatus.bootstrapping), Uri.parse('/app')),
        '/bootstrap?from=%2Fapp',
      );
      expect(redirect(guest, Uri.parse('/login')), isNull);
      expect(
        redirect(guest, Uri.parse('/bootstrap?from=/forgot-password')),
        '/forgot-password',
      );
      expect(redirect(member, Uri.parse('/app')), '/app/hr');
      expect(
        redirect(member, Uri.parse('/login?from=https://bad.example')),
        '/app/hr',
      );
      expect(
        redirect(member, Uri.parse('/login?from=/app/change-password')),
        '/app/change-password',
      );
      expect(
        redirect(guest, Uri.parse('/bootstrap?from=/app/change-password')),
        '/login?from=%2Fapp%2Fchange-password',
      );
    },
  );
  test('duplicate submission performs one repository operation', () async {
    final mock = MockAuthRepository();
    final gate = Completer<Result<AuthContext>>();
    when(() => mock.sessionChanges).thenAnswer((_) => const Stream.empty());
    registerFallbackValue(AuthIdentifier.parse('hr@erp.demo')!);
    when(() => mock.login(any(), any())).thenAnswer((_) => gate.future);
    final bloc = AuthBloc(mock);
    bloc.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    bloc.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await bloc.stream.firstWhere((s) => s.status == AuthStatus.authenticating);
    gate.complete(Success(source.accounts.first.context));
    await bloc.stream.firstWhere((s) => s.isAuthenticated);
    verify(() => mock.login(any(), any())).called(1);
    await bloc.close();
  });
  test(
    'secure adapter writes one envelope and purges old keys; no expired token attached',
    () async {
      final plugin = MockSecureStorage();
      final adapter = SecureSessionStorage(plugin);
      final envelope = jsonEncode({
        'accessToken': 'redacted-access',
        'refreshToken': 'redacted-refresh',
        'expiresAt': DateTime.utc(2000).toIso8601String(),
      });
      when(
        () =>
            plugin.write(key: SecureSessionStorage.sessionKey, value: envelope),
      ).thenAnswer((_) async {});
      when(
        () => plugin.read(key: SecureSessionStorage.sessionKey),
      ).thenAnswer((_) async => envelope);
      for (final key in [
        SecureSessionStorage.sessionKey,
        'session.access',
        'session.refresh',
      ]) {
        when(() => plugin.delete(key: key)).thenAnswer((_) async {});
      }
      await adapter.saveSession(envelope);
      expect(await adapter.readAccessToken(), isNull);
      await adapter.clearSession();
      verify(
        () =>
            plugin.write(key: SecureSessionStorage.sessionKey, value: envelope),
      ).called(1);
      verify(
        () => plugin.delete(key: SecureSessionStorage.sessionKey),
      ).called(1);
    },
  );
}
