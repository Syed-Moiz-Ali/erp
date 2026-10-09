import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/generated/app_localizations.dart';
import 'package:modular_erp/modules/hr/departments/data/datasources/dio_department_remote_data_source.dart';
import 'package:modular_erp/modules/hr/departments/data/repositories/remote_department_repository.dart';
import 'package:modular_erp/modules/hr/departments/domain/department.dart';
import 'package:modular_erp/modules/hr/departments/presentation/bloc/department_form_bloc.dart';
import 'package:modular_erp/modules/hr/departments/presentation/bloc/department_list_bloc.dart';
import 'package:modular_erp/modules/hr/departments/presentation/pages/department_form_page.dart';
import 'package:modular_erp/modules/hr/departments/presentation/pages/department_list_page.dart';
import 'package:modular_erp/platform/auth/data/repositories/disabled_auth_repository.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/shared/navigation/form_navigation_guard.dart';

import 'support/api_test_harness.dart';
import 'support/department_test_doubles.dart';
import 'support/memory_session_storage.dart';

/// Full-chain Department presentation test.
///
/// Real `DepartmentListPage`/`DepartmentFormPage` → `Department` BLoC →
/// `RemoteDepartmentRepository` → `DioDepartmentRemoteDataSource` → shared
/// `ApiClient` → mocked HTTP transport → updated UI.
void main() {
  late FakeDioAdapter adapter;
  late RemoteDepartmentRepository repository;
  final context = departmentAuthContext();
  int createCalls = 0;
  late AuthBloc authBloc;

  RemoteDepartmentRepository build() {
    final client = ApiClient(
      baseUrl: 'https://api.example.com',
      storage: MemorySessionStorage(),
      dio: Dio()..httpClientAdapter = adapter,
    );
    return RemoteDepartmentRepository(DioDepartmentRemoteDataSource(client));
  }

  setUp(() {
    createCalls = 0;
    authBloc = AuthBloc(const DisabledAuthRepository());
    adapter = FakeDioAdapter((_) => jsonResponse(envelope(data: null), 200));
    repository = build();
  });

  tearDown(() async {
    await authBloc.close();
    await repository.dispose();
  });

  Widget app() => BlocProvider<AuthBloc>.value(
    value: authBloc,
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => Material(child: child ?? const SizedBox()),
      routerConfig: GoRouter(
        initialLocation: AppRoutes.departments,
        routes: [
          GoRoute(
            path: AppRoutes.departments,
            builder: (c, s) => BlocProvider(
              create: (_) =>
                  DepartmentListBloc(repository, context)
                    ..add(const RecordListStarted()),
              child: const Scaffold(body: DepartmentListPage()),
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (c, s) => BlocProvider(
                  create: (_) =>
                      DepartmentFormBloc(repository, context, id: null)
                        ..add(const RecordFormInitialized<DepartmentDraft>()),
                  child: Scaffold(
                    body: DepartmentFormPage(guard: FormNavigationGuard()),
                  ),
                ),
              ),
              GoRoute(
                path: ':id',
                builder: (_, __) => const Scaffold(body: Text('DETAILS')),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (_, __) => const Scaffold(body: Text('DASHBOARD')),
          ),
        ],
      ),
    ),
  );

  Future<void> pump(WidgetTester tester) async {
    // Let the real (mocked) network future complete outside the fake clock.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 120)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('list renders departments fetched over mocked HTTP', (
    tester,
  ) async {
    adapter.handler = (options) {
      if (options.uri.path == '/api/departments') {
        return jsonResponse(
          envelope(
            data: {
              'items': [
                {
                  'departmentId': 2,
                  'departmentName': 'accounts',
                  'employeeCount': 1,
                },
                {
                  'departmentId': 3,
                  'departmentName': 'Developer',
                  'employeeCount': 0,
                },
              ],
              'page': 1,
              'pageSize': 10,
              'totalItems': 2,
              'totalPages': 1,
            },
          ),
          200,
        );
      }
      return jsonResponse(envelope(data: null), 200);
    };

    await tester.pumpWidget(app());
    await pump(tester);
    expect(find.text('accounts'), findsOneWidget);
    expect(find.text('Developer'), findsOneWidget);
  });

  testWidgets('empty list shows the empty state', (tester) async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        data: {
          'items': <dynamic>[],
          'page': 1,
          'pageSize': 10,
          'totalItems': 0,
          'totalPages': 0,
        },
      ),
      200,
    );

    await tester.pumpWidget(app());
    await pump(tester);
    expect(find.text('No configuration records yet'), findsOneWidget);
  });

  testWidgets('server failure shows an error with retry', (tester) async {
    adapter.handler = (_) => jsonResponse(
      envelope(success: false, errors: [errorEntry('SERVER_ERROR')]),
      500,
    );

    await tester.pumpWidget(app());
    await pump(tester);
    expect(
      find.text('Unable to read or save local configuration. Please retry.'),
      findsOneWidget,
    );
  });

  testWidgets('create posts to the backend and navigates to details', (
    tester,
  ) async {
    adapter.handler = (options) {
      if (options.method == 'POST' && options.uri.path == '/api/departments') {
        createCalls++;
        return jsonResponse(
          envelope(
            data: {
              'departmentId': 10,
              'departmentName': 'Finance',
              'employeeCount': 0,
            },
          ),
          201,
        );
      }
      if (options.uri.path == '/api/departments') {
        return jsonResponse(
          envelope(
            data: {
              'items': <dynamic>[],
              'page': 1,
              'pageSize': 10,
              'totalItems': 0,
              'totalPages': 0,
            },
          ),
          200,
        );
      }
      return jsonResponse(envelope(data: null), 200);
    };

    await tester.pumpWidget(app());
    await pump(tester);

    await tester.tap(find.widgetWithText(AppPrimaryButton, 'Create record'));
    await pump(tester);
    await tester.enterText(find.byType(TextField).first, 'Finance');
    await tester.tap(find.widgetWithText(AppPrimaryButton, 'Save'));
    await pump(tester);

    expect(createCalls, 1);
    expect(find.text('DETAILS'), findsOneWidget);
  });
}
