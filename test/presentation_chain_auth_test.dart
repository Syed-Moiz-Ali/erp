import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/module_registry/navigation_resolver.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/app/router/app_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/session_endpoint.dart';
import 'package:modular_erp/core/api/token_refresh_coordinator.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/locale_cubit.dart';
import 'package:modular_erp/core/preferences/app_preferences_repository.dart';
import 'package:modular_erp/l10n/generated/app_localizations.dart';
import 'package:modular_erp/platform/auth/data/datasources/remote/dio_auth_remote_data_source.dart';
import 'package:modular_erp/platform/auth/data/repositories/remote_auth_repository.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/platform/auth/presentation/pages/login_page.dart';

import 'support/api_test_harness.dart';
import 'support/auth_test_doubles.dart';
import 'support/memory_preferences.dart';
import 'support/memory_session_storage.dart';

/// Full-chain authentication presentation test.
///
/// Real `LoginPage` → `AuthBloc` → `RemoteAuthRepository` →
/// `DioAuthRemoteDataSource` → shared `ApiClient` → mocked HTTP transport →
/// authenticated state. Navigation is asserted through the real router guard
/// (`authRedirect`) which the app uses to reach the Dashboard.
void main() {
  late FakeDioAdapter adapter;
  late MemorySessionStorage storage;
  late ApiClient client;
  late RemoteAuthRepository repository;
  late SessionEndpoint endpoint;
  late TokenRefreshCoordinator coordinator;
  late AuthBloc auth;
  late LocaleCubit locale;
  int loginRequests = 0;
  int logoutRequests = 0;

  setUp(() async {
    loginRequests = 0;
    logoutRequests = 0;
    locale = LocaleCubit(
      LocalAppPreferencesRepository(MemoryPreferences(code: 'en')),
    );
    await locale.restore(const [Locale('en')]);
    adapter = FakeDioAdapter((options) {
      if (options.uri.path.endsWith('/api/auth/logout')) {
        logoutRequests++;
        return jsonResponse(envelope(data: null), 200);
      }
      if (options.uri.path.endsWith('/api/auth/login')) {
        loginRequests++;
        final body =
            jsonDecode(adapter.lastBody ?? '{}') as Map<String, dynamic>;
        if (body['password'] == 'wrong') {
          return jsonResponse(
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
        }
        return jsonResponse(
          envelope(data: sampleLoginResponse(access: 'access-1').toJson()),
          200,
        );
      }
      return jsonResponse(envelope(data: null), 200);
    });
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
    repository = RemoteAuthRepository(
      dataSource: DioAuthRemoteDataSource(client),
      storage: storage,
      sessionEndpoint: endpoint,
    );
    coordinator.refresher = repository;
    auth = AuthBloc(repository);
  });

  tearDown(() async {
    await auth.close();
    await locale.close();
    await repository.dispose();
    await endpoint.dispose();
    client.close();
  });

  Widget app() => MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: auth),
      BlocProvider<LocaleCubit>.value(value: locale),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const LoginPage(),
    ),
  );

  Future<void> submit(
    WidgetTester tester,
    String identifier,
    String password,
  ) async {
    await tester.enterText(
      find.byKey(const ValueKey('login-identifier')),
      identifier,
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      password,
    );
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    // Allow the real network future (mocked transport) to complete.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 120)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  String? landingFor() => authRedirect(
    auth.state,
    Uri.parse(AppRoutes.app),
    navigation: NavigationResolver(createErpRegistry(repository)),
  );

  testWidgets('login authenticates and the guard lands on the dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pump();
    expect(find.byKey(const ValueKey('login-identifier')), findsOneWidget);

    await submit(tester, 'Admin', 'secret');

    expect(auth.state.isAuthenticated, isTrue);
    expect(auth.state.context!.user.id, '5');
    expect(auth.state.context!.company.id, '3');
    expect(loginRequests, 1);
    expect(landingFor(), AppRoutes.dashboard);
  });

  testWidgets(
    'invalid credentials keep the login screen and surface a failure',
    (tester) async {
      await tester.pumpWidget(app());
      await tester.pump();

      await submit(tester, 'Admin', 'wrong');

      expect(auth.state.isAuthenticated, isFalse);
      expect(auth.state.failure?.kind, FailureKind.invalidCredentials);
      expect(find.byKey(const ValueKey('login-identifier')), findsOneWidget);
    },
  );

  testWidgets('duplicate submits issue a single login request', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();

    await tester.enterText(
      find.byKey(const ValueKey('login-identifier')),
      'Admin',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'secret',
    );
    final submitButton = find.byKey(const ValueKey('login-submit'));
    await tester.tap(submitButton);
    await tester.tap(submitButton, warnIfMissed: false);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 120)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(auth.state.isAuthenticated, isTrue);
    expect(loginRequests, 1);
  });

  test('full chain logout clears the session and calls the backend', () async {
    final bloc = AuthBloc(repository);
    addTearDown(bloc.close);
    bloc.add(const AuthLoginRequested('Admin', 'secret'));
    await bloc.stream.firstWhere((s) => s.isAuthenticated);
    expect(storage.value, isNotNull);

    bloc.add(const AuthLogoutRequested());
    await bloc.stream.firstWhere((s) => s.status == AuthStatus.unauthenticated);

    expect(storage.value, isNull);
    expect(logoutRequests, 1);
  });
}
