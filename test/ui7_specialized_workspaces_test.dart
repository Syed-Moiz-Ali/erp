import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/configuration/presentation/pages/service_settings_page.dart';
import 'support/demo/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'support/demo/demo_scenario_grants.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class _MockAuthBloc extends Mock implements AuthBloc {}

AuthContext _contextWith(Set<AppPermission> permissions) {
  final base = DemoAuthSource()
      .findByScenario(DemoScenario.companyAdmin)!
      .context;
  return base.copyWith(
    user: base.user.copyWith(permissions: PermissionSet(permissions)),
  );
}

Widget _wrap(
  Widget child, {
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppTheme.light(locale: locale),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: SafeArea(child: SingleChildScrollView(child: child)),
      ),
    ),
  ),
);

Widget _serviceSettingsHost(
  Set<AppPermission> permissions, {
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) {
  final bloc = _MockAuthBloc();
  when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
  when<AuthState>(() => bloc.state).thenReturn(
    AuthState(AuthStatus.authenticated, context: _contextWith(permissions)),
  );
  return _wrap(
    BlocProvider<AuthBloc>.value(
      value: bloc,
      child: const ServiceSettingsPage(),
    ),
    locale: locale,
    textScale: textScale,
  );
}

void main() {
  group('settings hub', () {
    testWidgets('hides empty groups and renders navigable items', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppSettingsHub(
            groups: [
              AppSettingsGroup(
                title: 'Attendance',
                items: [
                  AppSettingsItem(
                    title: 'Shifts',
                    icon: Icons.schedule_outlined,
                    onPressed: () => tapped = true,
                  ),
                ],
              ),
              AppSettingsGroup(title: 'Leave', items: const []),
            ],
          ),
        ),
      );
      expect(find.text('Attendance'), findsOneWidget);
      expect(find.text('Shifts'), findsOneWidget);
      expect(find.text('Leave'), findsNothing);
      await tester.tap(find.text('Shifts'));
      expect(tapped, isTrue);
    });

    testWidgets('Root cause view only exposes only the Root causes item', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _serviceSettingsHost({AppPermission.serviceRootCauseView}),
      );
      await tester.pumpAndSettle();
      expect(find.text('Root causes'), findsOneWidget);
      expect(find.text('Charge responsibility'), findsNothing);
      expect(find.text('Service types'), findsNothing);
      expect(find.text('General'), findsNothing);
      expect(find.text('Materials'), findsNothing);
      expect(find.text('Inspection'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Charge responsibility view only shows the Inspection group', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _serviceSettingsHost({AppPermission.serviceChargeResponsibilityView}),
      );
      await tester.pumpAndSettle();
      expect(find.text('Charge responsibility'), findsOneWidget);
      expect(find.text('Root causes'), findsNothing);
      expect(find.text('Inspection'), findsOneWidget);
      expect(find.text('Material request purposes'), findsNothing);
    });

    testWidgets('General group renders when a general permission is held', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _serviceSettingsHost({
          AppPermission.serviceTypeView,
          AppPermission.servicePriorityView,
        }),
      );
      await tester.pumpAndSettle();
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Service types'), findsOneWidget);
      expect(find.text('Priorities'), findsOneWidget);
      expect(find.text('Complaint types'), findsNothing);
    });

    testWidgets('Arabic RTL settings hub renders without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _serviceSettingsHost({
          AppPermission.serviceRootCauseView,
          AppPermission.serviceChargeResponsibilityView,
        }, locale: const Locale('ar')),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(ServiceSettingsPage));
      expect(Directionality.of(context), TextDirection.rtl);
      expect(tester.takeException(), isNull);
    });

    for (final width in const [390.0, 768.0, 1280.0]) {
      testWidgets('settings hub renders at ${width.toInt()}px', (tester) async {
        tester.view.physicalSize = Size(width, 2600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          _serviceSettingsHost({
            AppPermission.serviceRootCauseView,
            AppPermission.serviceTypeView,
            AppPermission.serviceMaterialRequestPurposeView,
          }),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('permission matrix presentation', () {
    List<AppPermissionGroupPresentation> groups() => [
      AppPermissionGroupPresentation(
        id: 'hr',
        title: 'Human Resources',
        subgroups: [
          AppPermissionSubgroupPresentation(
            title: 'Attendance',
            rows: [
              AppPermissionRowPresentation(
                label: 'View attendance records',
                description: 'See attendance records in the selected scope.',
                enabled: true,
                scopeLabel: 'Scope',
                scopeOptions: const [
                  AppScopeOption(value: 'assigned', label: 'Assigned to me'),
                  AppScopeOption(value: 'team', label: 'Team (my team)'),
                ],
                scopeValue: 'assigned',
                onScopeChanged: (_) {},
              ),
              AppPermissionRowPresentation(
                label: 'Review corrections',
                description: 'Approve or reject attendance corrections.',
                enabled: true,
                requirementMessage:
                    'This access requires a linked active employee record.',
              ),
            ],
          ),
        ],
      ),
      const AppPermissionGroupPresentation(id: 'empty', title: 'Empty module'),
    ];

    testWidgets('renders module → submodule → rows and hides empty groups', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(AppPermissionMatrix(groups: groups(), emptyMessage: 'None')),
      );
      expect(find.text('Human Resources'), findsOneWidget);
      expect(find.text('Attendance'), findsOneWidget);
      expect(find.text('View attendance records'), findsOneWidget);
      expect(find.text('Review corrections'), findsOneWidget);
      expect(find.text('Empty module'), findsNothing);
    });

    testWidgets('scoped view shows a scope selector and actions do not', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(AppPermissionMatrix(groups: groups(), emptyMessage: 'None')),
      );
      expect(find.byType(ChoiceChip), findsNWidgets(2));
      expect(find.text('Assigned to me'), findsOneWidget);
      expect(find.text('Team (my team)'), findsOneWidget);
    });

    testWidgets('employee-link requirement is communicated', (tester) async {
      await tester.pumpWidget(
        _wrap(AppPermissionMatrix(groups: groups(), emptyMessage: 'None')),
      );
      expect(
        find.text('This access requires a linked active employee record.'),
        findsOneWidget,
      );
    });

    testWidgets('search filters rows and shows a no-match state', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          AppPermissionMatrix(
            groups: groups(),
            searchQuery: 'corrections',
            emptyMessage: 'No permissions match',
          ),
        ),
      );
      expect(find.text('Review corrections'), findsOneWidget);
      expect(find.text('View attendance records'), findsNothing);

      await tester.pumpWidget(
        _wrap(
          AppPermissionMatrix(
            groups: groups(),
            searchQuery: 'zzz',
            emptyMessage: 'No permissions match',
          ),
        ),
      );
      expect(find.text('No permissions match'), findsOneWidget);
    });

    testWidgets('manage→view dependency renders as Included and locked', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          AppPermissionMatrix(
            groups: [
              AppPermissionGroupPresentation(
                id: 'services',
                title: 'Services',
                rows: [
                  AppPermissionRowPresentation(
                    label: 'View priorities',
                    enabled: true,
                    canToggle: false,
                    badgeLabel: 'Included',
                  ),
                  AppPermissionRowPresentation(
                    label: 'Manage priorities',
                    enabled: true,
                    onToggle: (_) {},
                  ),
                ],
              ),
            ],
            emptyMessage: 'None',
          ),
        ),
      );
      expect(find.text('Included'), findsOneWidget);
      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches, hasLength(2));
      expect(switches.first.onChanged, isNull);
      expect(switches.last.onChanged, isNotNull);
    });

    testWidgets('scope selector reports the selected option', (tester) async {
      String? selected;
      await tester.pumpWidget(
        _wrap(
          AppScopeSelector<String>(
            label: 'Scope',
            value: 'assigned',
            onChanged: (value) => selected = value,
            options: const [
              AppScopeOption(value: 'assigned', label: 'Assigned to me'),
              AppScopeOption(value: 'team', label: 'Team (my team)'),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Team (my team)'));
      expect(selected, 'team');
    });

    testWidgets('access summary renders compact metrics', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppAccessSummary(
            title: 'Access summary',
            metrics: const [
              AppSummaryMetric(label: 'Granted permissions', value: '12'),
              AppSummaryMetric(label: 'Module access', value: '2'),
              AppSummaryMetric(
                label: 'Linked employee',
                value: 'EMP-0042',
                status: AppStatus.success,
              ),
            ],
          ),
        ),
      );
      expect(find.text('Access summary'), findsOneWidget);
      expect(find.text('Granted permissions'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('EMP-0042'), findsOneWidget);
    });
  });

  group('module enablement', () {
    testWidgets('toggle row reflects state and blocks interaction when null', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          AppModuleToggleRow(
            title: 'Human Resources',
            description: 'Employees, attendance, leave and workforce.',
            enabled: true,
            statusLabel: 'Enabled',
          ),
        ),
      );
      final row = tester.widget<Switch>(find.byType(Switch));
      expect(row.value, isTrue);
      expect(row.onChanged, isNull);
      expect(find.text('Enabled'), findsOneWidget);
    });

    testWidgets('toggle row reports changes when interactive', (tester) async {
      bool? next;
      await tester.pumpWidget(
        _wrap(
          AppModuleToggleRow(
            title: 'Services',
            enabled: false,
            onChanged: (value) => next = value,
          ),
        ),
      );
      await tester.tap(find.byType(Switch));
      expect(next, isTrue);
    });
  });

}
