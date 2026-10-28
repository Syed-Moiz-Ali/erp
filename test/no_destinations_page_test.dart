import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/app/shell/pages/route_status_pages.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/theme/app_theme.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'support/demo/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'support/demo/demo_scenario_grants.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class _MockAuthBloc extends Mock implements AuthBloc {}

AuthContext _context(Set<AppPermission> permissions) {
  final base = DemoAuthSource()
      .findByScenario(DemoScenario.companyAdmin)!
      .context;
  return base.copyWith(
    user: base.user.copyWith(permissions: PermissionSet(permissions)),
  );
}

Widget _wrap(AuthState state) {
  final bloc = _MockAuthBloc();
  when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
  when<AuthState>(() => bloc.state).thenReturn(state);
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light(locale: const Locale('en')),
    home: BlocProvider<AuthBloc>.value(
      value: bloc,
      child: const NoDestinationsPage(),
    ),
  );
}

void main() {
  testWidgets('shows a clear empty state when signed in without permissions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        AuthState(
          AuthStatus.authenticated,
          context: _context(const {}),
          permissionsLoaded: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No permissions assigned'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('shows a retryable error when permissions could not load', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        AuthState(
          AuthStatus.authenticated,
          context: _context(const {}),
          permissionsFailure: const Failure(
            code: 'offline',
            kind: FailureKind.offline,
            retryable: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Could not load permissions'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('shows the destination empty state when permissions exist', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        AuthState(
          AuthStatus.authenticated,
          context: _context({AppPermission.employeeViewAll}),
          permissionsLoaded: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No available destinations'), findsOneWidget);
  });
}

