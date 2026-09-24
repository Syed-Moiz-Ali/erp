import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/modules/hr/demo/demo_attendance_seed.dart';
import 'package:modular_erp/modules/hr/demo/demo_configuration_seed.dart';
import 'package:modular_erp/modules/hr/demo/demo_workforce_seed.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/design_system/theme/app_theme.dart';
import 'package:modular_erp/modules/hr/attendance/domain/workforce_attendance.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/modules/hr/employees/data/employee_seed.dart';
import 'package:modular_erp/modules/hr/reports/data/attendance_report_export_service.dart';
import 'package:modular_erp/modules/hr/reports/data/local_attendance_report_repository.dart';
import 'package:modular_erp/modules/hr/reports/domain/attendance_report_models.dart';
import 'package:modular_erp/modules/hr/reports/presentation/attendance_reports_page.dart';
import 'package:modular_erp/modules/hr/reports/presentation/bloc/attendance_report_bloc.dart';
import 'package:modular_erp/l10n/generated/app_localizations.dart';
import 'attendance_test.dart' show FakeClock, MockAuth;
import 'employee_test.dart' show employeeContext;

class _NoSave implements ReportFileSaver {
  @override
  Future<void> save(ReportExportResult result) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final (locale, width) in [
    (const Locale('en'), 360.0),
    (const Locale('ar'), 1440.0),
  ]) {
    testWidgets('report workspace renders $locale at $width without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await seedEmployees(db);
      await seedAttendanceConfiguration(db);
      final clock = FakeClock(DateTime.utc(2026, 9, 18, 12));
      await seedDemoAttendance(db, enabled: true, clock: clock);
      await seedDemoWorkforce(db, enabled: true, clock: clock);
      final auth = MockAuth();
      when(
        () => auth.checkSession(),
      ).thenAnswer((_) async => Success(employeeContext(DemoScenario.manager)));
      final repo = LocalAttendanceReportRepository(db, auth, clock: clock);
      final bloc = AttendanceReportBloc(
        repo,
        AttendanceReportExportService(repo, _NoSave()),
        AttendanceScope.team,
      )..add(const AttendanceReportStarted());
      addTearDown(bloc.close);
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          theme: AppTheme.light(locale: locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocProvider.value(
              value: bloc,
              child: const AttendanceReportsPage(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(bloc.state.data, isNotNull);
      expect(tester.takeException(), isNull);
      expect(find.byType(AttendanceReportsPage), findsOneWidget);
      final l = AppLocalizations.of(
        tester.element(find.byType(AttendanceReportsPage)),
      );
      // The overview renders the primary analytics visualization.
      expect(
        find.descendant(
          of: find.byType(AttendanceReportsPage),
          matching: find.text(l.reportActivityTrend),
        ),
        findsOneWidget,
      );
      for (final type in AttendanceReportType.values) {
        bloc.add(AttendanceReportTypeChanged(type));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        expect(bloc.state.data?.type, type);
        expect(tester.takeException(), isNull);
      }
    });
  }
}
