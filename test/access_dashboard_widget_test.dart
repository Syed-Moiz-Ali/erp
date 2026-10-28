import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/backend_access_policy.dart';
import 'package:modular_erp/design_system/theme/app_theme.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/platform/workspace/dashboard/presentation/no_dashboard_data_page.dart';

class _MockAuthBloc extends Mock implements AuthBloc {}

PermissionSet _permissions(Set<String> keys) => PermissionSet({
  for (final key in keys) ...?BackendAccessPolicy.keyPermissions[key],
});

AuthContext _context(Set<String> keys) {
  final user = UserAccount(
    id: 'user-1',
    displayName: 'Test User',
    email: 'test@example.com',
    companyId: 'company-1',
    permissions: _permissions(keys),
    status: AccountStatus.active,
  );
  return AuthContext(
    user: user,
    company: const CompanyContext(
      id: 'company-1',
      name: 'Company',
      code: 'C',
      timezone: 'Asia/Dubai',
      defaultLocale: 'en',
      enabledModules: {'employees', 'attendance', 'settings'},
    ),
  );
}

Widget _wrap(Set<String> keys) {
  final bloc = _MockAuthBloc();
  when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
  when<AuthState>(() => bloc.state).thenReturn(
    AuthState(
      AuthStatus.authenticated,
      context: _context(keys),
      permissionsLoaded: true,
    ),
  );
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light(locale: const Locale('en')),
    home: BlocProvider<AuthBloc>.value(
      value: bloc,
      child: const NoDashboardDataPage(),
    ),
  );
}

void main() {
  testWidgets('zero permissions shows no-data and no-permissions states', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap({}));
    await tester.pumpAndSettle();

    expect(find.text('No dashboard data source yet'), findsWidgets);
    expect(find.text('No permissions assigned'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('dashboard-quick-link-hr.employees')),
      findsNothing,
    );
  });

  testWidgets('quick links only include screens with a view key', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap({'hr.employees.view'}));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('dashboard-quick-link-hr.employees')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('dashboard-quick-link-company.branches')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('dashboard-quick-link-access.users')),
      findsNothing,
    );
    expect(find.text('Employees'), findsWidgets);
  });

  testWidgets('admin set renders every visible module quick link', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap({
        'hr.employees.view',
        'hr.attendance.shifts.view',
        'company.branches.view',
        'company.access.users.view',
      }),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('dashboard-quick-link-hr.employees')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('dashboard-quick-link-hr.attendance.shifts')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('dashboard-quick-link-company.branches')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('dashboard-quick-link-access.users')),
      findsOneWidget,
    );
    expect(find.text('Human resources'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Manage access'), findsOneWidget);
  });

  testWidgets('unknown backend key does not create a quick link', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap({'unknown.live.key'}));
    await tester.pumpAndSettle();

    expect(find.text('No permissions assigned'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('dashboard-quick-link-hr.employees')),
      findsNothing,
    );
  });
}
