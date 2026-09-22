import 'package:drift/native.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/bootstrap/demo_attendance_seed.dart';
import 'package:modular_erp/bootstrap/demo_configuration_seed.dart';
import 'package:modular_erp/bootstrap/demo_workforce_seed.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/features/attendance/domain/workforce_attendance.dart';
import 'package:modular_erp/features/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/features/employees/data/employee_seed.dart';
import 'package:modular_erp/features/reports/data/local_attendance_report_repository.dart';
import 'package:modular_erp/features/reports/data/attendance_report_export_service.dart';
import 'package:modular_erp/features/reports/domain/attendance_report_models.dart';
import 'attendance_test.dart' show FakeClock, MockAuth;
import 'employee_test.dart' show employeeContext;

class _CaptureSaver implements ReportFileSaver {
  ReportExportResult? result;
  @override
  Future<void> save(ReportExportResult value) async => result = value;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late MockAuth auth;
  late LocalAttendanceReportRepository repo;
  final today = DateTime.utc(2026, 9, 18);
  var actor = employeeContext(AppRole.manager);
  setUp(() async {
    actor = employeeContext(AppRole.manager);
    db = AppDatabase(NativeDatabase.memory());
    await seedEmployees(db);
    await seedAttendanceConfiguration(db);
    final clock = FakeClock(DateTime.utc(2026, 9, 18, 12));
    await seedDemoAttendance(db, enabled: true, clock: clock);
    await seedDemoWorkforce(db, enabled: true, clock: clock);
    auth = MockAuth();
    when(() => auth.checkSession()).thenAnswer((_) async => Success(actor));
    repo = LocalAttendanceReportRepository(db, auth, clock: clock);
  });
  tearDown(() async => db.close());

  test(
    'team overview aggregates effective recorded days and exports all rows',
    () async {
      final filter = AttendanceReportFilter.preset(
        AttendanceReportPeriod.thisMonth,
        today,
        AttendanceScope.team,
      );
      final result = await repo.load(
        filter,
        AttendanceReportType.overview,
        pageSize: 2,
      );
      if (result is Failed<AttendanceReportData>) fail(result.failure.code);
      expect(result, isA<Success<AttendanceReportData>>());
      final page = (result as Success<AttendanceReportData>).value;
      expect(page.summary.recordedDays, greaterThan(2));
      expect(page.rows, hasLength(2));
      expect(page.rows.every((row) => row.employeeId != 'employee-hr'), isTrue);
      final exported =
          (await repo.exportData(filter, AttendanceReportType.overview)
                  as Success<AttendanceReportData>)
              .value;
      expect(exported.rows, hasLength(page.totalRows));
      expect(exported.summary.workMilliseconds, greaterThan(0));
    },
  );

  test(
    'company scope requires view-all and selected report modes load',
    () async {
      final team = AttendanceReportFilter.preset(
        AttendanceReportPeriod.thisMonth,
        today,
        AttendanceScope.team,
      );
      final company = AttendanceReportFilter.preset(
        AttendanceReportPeriod.thisMonth,
        today,
        AttendanceScope.company,
      );
      expect(
        await repo.load(company, AttendanceReportType.overview),
        isA<Failed<AttendanceReportData>>(),
      );
      actor = employeeContext(AppRole.hr);
      final full =
          (await repo.load(company, AttendanceReportType.overview)
                  as Success<AttendanceReportData>)
              .value;
      expect(full.summary.recordedDays, greaterThan(0));
      actor = employeeContext(AppRole.manager);
      for (final type in AttendanceReportType.values) {
        expect(
          await repo.load(team, type),
          isA<Success<AttendanceReportData>>(),
          reason: type.name,
        );
      }
    },
  );

  test(
    'range and combined status filter reject future and invalid scope',
    () async {
      final filter = AttendanceReportFilter.preset(
        AttendanceReportPeriod.thisMonth,
        today,
        AttendanceScope.team,
      ).copyWith(statuses: {'late'}, hasIssues: false);
      final late =
          (await repo.load(filter, AttendanceReportType.overview)
                  as Success<AttendanceReportData>)
              .value;
      expect(late.rows.every((row) => row.status == 'late'), isTrue);
      expect(
        await repo.load(
          filter.copyWith(to: today.add(const Duration(days: 1))),
          AttendanceReportType.overview,
        ),
        isA<Failed<AttendanceReportData>>(),
      );
    },
  );

  test(
    'Arabic CSV exports all scoped rows and PDF embeds local fonts',
    () async {
      final filter = AttendanceReportFilter.preset(
        AttendanceReportPeriod.thisMonth,
        today,
        AttendanceScope.team,
      );
      final saver = _CaptureSaver();
      final service = AttendanceReportExportService(repo, saver);
      ReportExportRequest request(ReportExportFormat format) =>
          ReportExportRequest(
            type: AttendanceReportType.overview,
            filter: filter,
            sort: AttendanceReportSort.newest,
            format: format,
            locale: const Locale('ar'),
            companyName: 'Demo ERP Company',
            generatedAt: today,
          );
      final csv =
          (await service.export(request(ReportExportFormat.csv))
                  as Success<ReportExportResult>)
              .value;
      expect(csv.bytes.take(3).toList(), [0xef, 0xbb, 0xbf]);
      final decoded = utf8.decode(csv.bytes.skip(3).toList());
      expect(decoded, contains('الموظف'));
      expect(decoded, isNot(contains('latitude')));
      final total =
          (await repo.exportData(filter, AttendanceReportType.overview)
                  as Success<AttendanceReportData>)
              .value
              .totalRows;
      expect(decoded.trim().split('\r\n').length, total + 1);
      expect(
        csv.fileName,
        contains('attendance_overview_2026-09-01_to_2026-09-18.csv'),
      );
      final pdf =
          (await service.export(request(ReportExportFormat.pdf))
                  as Success<ReportExportResult>)
              .value;
      expect(ascii.decode(pdf.bytes.take(4).toList()), '%PDF');
      expect(pdf.bytes.length, greaterThan(1000));
      expect(saver.result, same(pdf));
    },
  );

  test('trend granularity resolves by range and buckets points', () {
    expect(
      resolveReportGranularity(
        DateTime.utc(2026, 9, 1),
        DateTime.utc(2026, 9, 30),
      ),
      ReportGranularity.day,
    );
    expect(
      resolveReportGranularity(
        DateTime.utc(2026, 1, 1),
        DateTime.utc(2026, 3, 1),
      ),
      ReportGranularity.week,
    );
    expect(
      resolveReportGranularity(
        DateTime.utc(2026, 1, 1),
        DateTime.utc(2026, 12, 31),
      ),
      ReportGranularity.month,
    );
    final weekly = aggregateTrend([
      AttendanceTrendPoint(DateTime.utc(2026, 1, 2), 1, 100),
      AttendanceTrendPoint(DateTime.utc(2026, 1, 3), 2, 200),
      AttendanceTrendPoint(DateTime.utc(2026, 1, 9), 3, 300),
    ], ReportGranularity.week);
    expect(weekly, hasLength(2));
    expect(weekly.first.recordedDays, 3);
    expect(weekly.first.workMilliseconds, 300);
    expect(weekly.first.date, DateTime.utc(2025, 12, 29));
    final monthly = aggregateTrend([
      AttendanceTrendPoint(DateTime.utc(2026, 1, 2), 1, 100),
      AttendanceTrendPoint(DateTime.utc(2026, 2, 3), 2, 200),
    ], ReportGranularity.month);
    expect(monthly, hasLength(2));
    expect(monthly.first.date, DateTime.utc(2026, 1, 1));
  });

  test('English PDF keeps Arabic fallback for mixed-language data', () async {
    actor = employeeContext(AppRole.hr);
    final filter = AttendanceReportFilter.preset(
      AttendanceReportPeriod.thisMonth,
      today,
      AttendanceScope.company,
    );
    final service = AttendanceReportExportService(repo, _CaptureSaver());
    final result =
        (await service.export(
                  ReportExportRequest(
                    type: AttendanceReportType.employeeSummary,
                    filter: filter,
                    sort: AttendanceReportSort.newest,
                    format: ReportExportFormat.pdf,
                    locale: const Locale('en'),
                    companyName: 'Demo ERP Company',
                    generatedAt: today,
                  ),
                )
                as Success<ReportExportResult>)
            .value;
    expect(
      latin1.decode(result.bytes).contains('IBMPlexSansArabic'),
      isTrue,
      reason: 'Arabic data values embed the bundled Arabic fallback font',
    );
  });
}
