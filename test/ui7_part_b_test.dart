import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/demo/demo_configuration_seed.dart';
import 'package:modular_erp/modules/hr/demo/demo_workforce_seed.dart';
import 'package:modular_erp/modules/hr/employees/data/employee_seed.dart';
import 'package:modular_erp/modules/hr/leave/data/local_leave_repository.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/presentation/bloc/leave_blocs.dart';
import 'package:modular_erp/modules/hr/leave/presentation/bloc/leave_holiday_blocs.dart';
import 'package:modular_erp/modules/hr/leave/presentation/pages/holiday_pages.dart';
import 'package:modular_erp/modules/hr/leave/presentation/pages/leave_calendar_page.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'attendance_test.dart' show FakeClock, MockAuth;
import 'employee_test.dart' show employeeContext;

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
      child: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  ),
);

void main() {
  final today = DateTime.utc(2026, 10, 6);

  group('AppCalendar (UI-7 foundation)', () {
    testWidgets('renders weekdays, holiday overlay and event overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          AppCalendar(
            month: DateTime.utc(2026, 10),
            weekdays: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            today: today,
            selectedDay: today,
            maxEventsPerCell: 2,
            eventsForDay: (day) => day.month == 10 && day.day == 6
                ? List.generate(
                    3,
                    (i) => AppCalendarEvent(id: '$i', title: 'Event $i'),
                  )
                : const [],
            holidayForDay: (day) => day.month == 10 && day.day == 6
                ? 'Company Holiday'
                : (day.month == 9 && day.day == 30
                      ? 'Prev Month Holiday'
                      : null),
          ),
        ),
      );
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Company Holiday'), findsOneWidget);
      // Two events fit, the third collapses into an overflow count.
      expect(find.text('+1'), findsOneWidget);
      // Leading outside-month day renders and can carry holiday context.
      expect(find.text('Prev Month Holiday'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('day cells are tappable and report the selected date', (
      tester,
    ) async {
      DateTime? selected;
      await tester.pumpWidget(
        _wrap(
          AppCalendar(
            month: DateTime.utc(2026, 10),
            weekdays: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            onSelectDay: (day) => selected = day,
            today: today,
          ),
        ),
      );
      await tester.tap(find.byType(InkWell).first);
      expect(selected, isNotNull);
      expect(selected!.month, anyOf(9, 10));
      expect(tester.takeException(), isNull);
    });

    testWidgets('header navigates months and jumps to today', (tester) async {
      var previous = 0, next = 0, todayTaps = 0;
      await tester.pumpWidget(
        _wrap(
          AppCalendarHeader(
            label: 'October 2026',
            todayLabel: 'Today',
            previousTooltip: 'Previous',
            nextTooltip: 'Next',
            onPrevious: () => previous++,
            onNext: () => next++,
            onToday: () => todayTaps++,
          ),
        ),
      );
      await tester.tap(find.byTooltip('Previous'));
      await tester.tap(find.byTooltip('Next'));
      await tester.tap(find.text('Today'));
      expect(previous, 1);
      expect(next, 1);
      expect(todayTaps, 1);
    });

    testWidgets('empty day renders no chips and no overflow', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppCalendar(
            month: DateTime.utc(2026, 10),
            weekdays: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          ),
        ),
      );
      expect(find.textContaining('+'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('report specialized primitives', () {
    testWidgets('summary strip renders compact metrics', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppSummaryStrip(
            metrics: const [
              AppSummaryMetric(label: 'Recorded workdays', value: '42'),
              AppSummaryMetric(label: 'Late records', value: '3'),
              AppSummaryMetric(label: 'Worked time', value: '312h'),
            ],
          ),
        ),
      );
      expect(find.text('Recorded workdays'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Late records'), findsOneWidget);
    });

    testWidgets('report toolbar lays out filters and actions', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppReportToolbar(
            leading: const Text('My team'),
            filters: [
              AppFilterChip(
                label: 'Employee',
                selected: false,
                onSelected: (_) {},
              ),
            ],
            actions: [AppTextButton(label: 'Export', onPressed: () {})],
          ),
        ),
      );
      expect(find.text('My team'), findsOneWidget);
      expect(find.text('Employee'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
    });

    testWidgets('report metric announces label and value semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrap(const AppReportMetric(label: 'Present days', value: '18')),
      );
      expect(find.bySemanticsLabel('Present days, 18'), findsOneWidget);
      handle.dispose();
    });
  });

  group('leave calendar workspace', () {
    late AppDatabase db;
    late MockAuth auth;
    late LocalLeaveRepository repository;
    late AuthContext hr;
    final clock = FakeClock(DateTime.utc(2026, 9, 22, 12));

    setUp(() async {
      hr = employeeContext(DemoScenario.hr);
      db = AppDatabase(NativeDatabase.memory());
      await seedEmployees(db);
      await seedAttendanceConfiguration(db);
      await seedDemoWorkforce(db, enabled: true, clock: clock);
      auth = MockAuth();
      when(() => auth.checkSession()).thenAnswer((_) async => Success(hr));
      repository = LocalLeaveRepository(db, auth, clock, demoEnabled: true);
    });
    tearDown(() async => db.close());

    Future<LeaveCalendarCubit> mountCalendar(
      WidgetTester tester, {
      Locale locale = const Locale('en'),
      double textScale = 1.0,
      Size surface = const Size(1440, 1400),
    }) async {
      tester.view.physicalSize = surface;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final cubit = LeaveCalendarCubit(repository, hr);
      await cubit.load(
        from: DateTime.utc(2026, 9, 1),
        to: DateTime.utc(2026, 9, 30),
      );
      addTearDown(cubit.close);
      await tester.pumpWidget(
        _wrap(
          BlocProvider<LeaveCalendarCubit>.value(
            value: cubit,
            child: const LeaveCalendarPage(),
          ),
          locale: locale,
          textScale: textScale,
        ),
      );
      await tester.pumpAndSettle();
      return cubit;
    }

    testWidgets('renders the month workspace with legend and agenda', (
      tester,
    ) async {
      await mountCalendar(tester);
      final l = AppLocalizations.of(
        tester.element(find.byType(LeaveCalendarPage)),
      );
      expect(find.text(l.leaveAndHolidayCalendar), findsOneWidget);
      final monthLabel = MaterialLocalizations.of(
        tester.element(find.byType(LeaveCalendarPage)),
      ).formatMonthYear(DateTime.utc(2026, 9));
      expect(find.text(monthLabel), findsOneWidget);
      expect(find.text(l.leaveCalendarLegendLeave), findsWidgets);
      expect(find.text(l.leaveCalendarLegendHoliday), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('month navigation loads the next period', (tester) async {
      final cubit = await mountCalendar(tester);
      final element = tester.element(find.byType(LeaveCalendarPage));
      final nextTooltip = MaterialLocalizations.of(element).nextMonthTooltip;
      await tester.tap(find.byTooltip(nextTooltip));
      await tester.pumpAndSettle();
      final monthLabel = MaterialLocalizations.of(
        tester.element(find.byType(LeaveCalendarPage)),
      ).formatMonthYear(DateTime.utc(2026, 10));
      expect(cubit.state.from, DateTime.utc(2026, 10, 1));
      expect(find.text(monthLabel), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Arabic RTL calendar renders without overflow', (tester) async {
      await mountCalendar(tester, locale: const Locale('ar'), textScale: 1.3);
      final context = tester.element(find.byType(LeaveCalendarPage));
      expect(Directionality.of(context), TextDirection.rtl);
      expect(tester.takeException(), isNull);
    });

    for (final width in const [390.0, 768.0, 1280.0, 1920.0]) {
      testWidgets('calendar renders at ${width.toInt()}px', (tester) async {
        await mountCalendar(tester, surface: Size(width, 1600));
        expect(tester.takeException(), isNull);
      });
    }

    test('calendar data is scoped to the active company', () async {
      final other = hr.copyWith(
        company: hr.company.copyWith(id: 'other-company', name: 'Other'),
      );
      final from = DateTime.utc(2026, 1, 1);
      final to = DateTime.utc(2026, 12, 31);
      final own = await repository.calendar(hr, from, to);
      expect(own, isA<Success<List<LeaveCalendarEntry>>>());
      expect((own as Success<List<LeaveCalendarEntry>>).value, isNotEmpty);
      final otherResult = await repository.calendar(other, from, to);
      expect((otherResult as Success<List<LeaveCalendarEntry>>).value, isEmpty);
    });

    test('a fresh cubit never leaks a previous company period', () async {
      final other = hr.copyWith(
        company: hr.company.copyWith(id: 'other-company', name: 'Other'),
      );
      final ownCubit = LeaveCalendarCubit(repository, hr);
      await ownCubit.load(
        from: DateTime.utc(2026, 9, 1),
        to: DateTime.utc(2026, 9, 30),
      );
      expect(ownCubit.state.loading, isFalse);
      await ownCubit.close();

      final otherCubit = LeaveCalendarCubit(repository, other);
      await otherCubit.load(
        from: DateTime.utc(2026, 9, 1),
        to: DateTime.utc(2026, 9, 30),
      );
      expect(otherCubit.state.entries, isEmpty);
      await otherCubit.close();
    });
  });

  group('holiday management workspace', () {
    late AppDatabase db;
    late MockAuth auth;
    late LocalLeaveRepository repository;
    late AuthContext hr;
    final clock = FakeClock(DateTime.utc(2026, 9, 22, 12));

    setUp(() async {
      hr = employeeContext(DemoScenario.hr);
      db = AppDatabase(NativeDatabase.memory());
      await seedEmployees(db);
      await seedAttendanceConfiguration(db);
      await seedDemoWorkforce(db, enabled: true, clock: clock);
      auth = MockAuth();
      when(() => auth.checkSession()).thenAnswer((_) async => Success(hr));
      repository = LocalLeaveRepository(db, auth, clock, demoEnabled: true);
    });
    tearDown(() async => db.close());

    Future<HolidayManagementCubit> mountHolidays(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final cubit = HolidayManagementCubit(repository, hr, year: 2026);
      addTearDown(cubit.close);
      await tester.pumpWidget(
        _wrap(
          BlocProvider<HolidayManagementCubit>.value(
            value: cubit,
            child: const HolidayManagementPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return cubit;
    }

    testWidgets('renders year navigation, compact summary and type legend', (
      tester,
    ) async {
      final cubit = await mountHolidays(tester);
      final l = AppLocalizations.of(
        tester.element(find.byType(HolidayManagementPage)),
      );
      expect(find.text(l.holidayCalendarTitle), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);
      expect(find.text(l.activeHolidays), findsOneWidget);
      expect(find.text(l.holidayOptional), findsWidgets);
      expect(find.text(l.holidayTypePublic), findsWidgets);
      expect(find.text(l.holidayCurrentYear), findsOneWidget);

      await tester.tap(find.byTooltip(l.holidayNextYear));
      await tester.pumpAndSettle();
      expect(cubit.state.year, 2027);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Arabic RTL holiday workspace renders without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final cubit = HolidayManagementCubit(repository, hr, year: 2026);
      addTearDown(cubit.close);
      await tester.pumpWidget(
        _wrap(
          BlocProvider<HolidayManagementCubit>.value(
            value: cubit,
            child: const HolidayManagementPage(),
          ),
          locale: const Locale('ar'),
          textScale: 1.3,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
