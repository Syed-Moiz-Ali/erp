import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/bootstrap/demo_configuration_seed.dart';
import 'package:modular_erp/bootstrap/demo_workforce_seed.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/features/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/features/auth/domain/policies/account_role_templates.dart';
import 'package:modular_erp/features/employees/data/employee_seed.dart';
import 'package:modular_erp/features/leave/domain/leave_holiday_csv.dart';
import 'package:modular_erp/features/leave/data/local_leave_repository.dart';
import 'package:modular_erp/features/leave/domain/leave_models.dart';
import 'attendance_test.dart' show FakeClock, MockAuth;
import 'employee_test.dart' show employeeContext;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('permissions', () {
    test('HR can view and manage holidays', () {
      final hr = permissionsForRole(AppRole.hr);
      expect(hr.contains(AppPermission.holidayView), isTrue);
      expect(hr.contains(AppPermission.holidayManage), isTrue);
    });

    test('employees and managers cannot manage holidays by default', () {
      expect(
        permissionsForRole(
          AppRole.employee,
        ).contains(AppPermission.holidayManage),
        isFalse,
      );
      expect(
        permissionsForRole(
          AppRole.manager,
        ).contains(AppPermission.holidayManage),
        isFalse,
      );
    });

    test('company admin can manage holidays', () {
      final admin = permissionsForRole(AppRole.companyAdmin);
      expect(admin.contains(AppPermission.holidayView), isTrue);
      expect(admin.contains(AppPermission.holidayManage), isTrue);
    });

    test('a manage grant always carries its view dependency', () {
      for (final pair in [
        (manage: AppPermission.holidayManage, view: AppPermission.holidayView),
        (
          manage: AppPermission.leaveTypeManage,
          view: AppPermission.leaveTypeView,
        ),
        (
          manage: AppPermission.leavePolicyManage,
          view: AppPermission.leavePolicyView,
        ),
        (manage: AppPermission.shiftManage, view: AppPermission.shiftView),
      ]) {
        final set = PermissionSet([pair.manage]);
        expect(set.contains(pair.view), isTrue, reason: '${pair.manage}');
      }
    });
  });

  group('holiday calendar', () {
    late AppDatabase db;
    late MockAuth auth;
    late LocalLeaveRepository repo;
    late AuthContext hr;

    setUp(() async {
      hr = employeeContext(AppRole.hr);
      db = AppDatabase(NativeDatabase.memory());
      await seedEmployees(db);
      await seedAttendanceConfiguration(db);
      await seedDemoWorkforce(
        db,
        enabled: true,
        clock: FakeClock(DateTime.utc(2026, 9, 22, 12)),
      );
      auth = MockAuth();
      when(() => auth.checkSession()).thenAnswer((_) async => Success(hr));
      repo = LocalLeaveRepository(
        db,
        auth,
        FakeClock(DateTime.utc(2026, 9, 22, 12)),
        demoEnabled: true,
      );
    });
    tearDown(() async => db.close());

    test('demo holidays are year-filtered and categorised', () async {
      final year = await repo.watchHolidaysForYear(hr, 2026).first;
      final holidays = (year as Success<List<Holiday>>).value;
      expect(holidays.length, 6);
      expect(
        holidays.map((h) => h.type).toSet(),
        containsAll([
          HolidayType.publicHoliday,
          HolidayType.festivalHoliday,
          HolidayType.regionalHoliday,
          HolidayType.companyHoliday,
          HolidayType.specialClosure,
        ]),
      );
      final other = await repo.watchHolidaysForYear(hr, 2025).first;
      expect((other as Success<List<Holiday>>).value, isEmpty);
    });

    test('optionality is independent of the holiday category', () async {
      final year = await repo.watchHolidaysForYear(hr, 2026).first;
      final holidays = (year as Success<List<Holiday>>).value;
      final regional = holidays.firstWhere(
        (h) => h.type == HolidayType.regionalHoliday,
      );
      expect(regional.isOptional, isTrue);
      expect(
        HolidayType.values.any((t) => t.name == 'optionalHoliday'),
        isFalse,
      );
    });

    test('multi-day holiday renders every affected date', () async {
      final saved = await repo.saveHoliday(
        hr,
        HolidayDraft(
          name: 'Winter Shutdown',
          date: DateTime.utc(2026, 12, 28),
          endDate: DateTime.utc(2026, 12, 30),
          type: HolidayType.specialClosure,
        ),
      );
      expect(saved, isA<Success<Holiday>>());
      final calendar = await repo.calendar(
        hr,
        DateTime.utc(2026, 12, 28),
        DateTime.utc(2026, 12, 30),
      );
      final entries = (calendar as Success<List<LeaveCalendarEntry>>).value
          .where((e) => e.kind == LeaveCalendarKind.holiday)
          .toList();
      expect(entries.length, 3);
    });

    test('location-scoped holidays apply only to matching employees', () async {
      final locations = await (db.select(
        db.workLocationRecords,
      )..where((t) => t.companyId.equals(hr.company.id))).get();
      final locationId = locations.first.id;
      final employees = await (db.select(
        db.workforceEmployees,
      )..where((t) => t.companyId.equals(hr.company.id))).get();
      final matching = employees[0];
      final other = employees[1];
      await (db.update(
        db.workforceEmployees,
      )..where((t) => t.id.equals(matching.id))).write(
        WorkforceEmployeesCompanion(workLocationId: Value(locationId)),
      );
      await (db.update(
        db.workforceEmployees,
      )..where((t) => t.id.equals(other.id))).write(
        const WorkforceEmployeesCompanion(workLocationId: Value(null)),
      );
      final saved = await repo.saveHoliday(
        hr,
        HolidayDraft(
          name: 'Hyderabad Local Holiday',
          date: DateTime.utc(2026, 6, 15),
          scope: HolidayScope.specificWorkLocations,
          workLocationIds: {locationId},
        ),
      );
      expect(saved, isA<Success<Holiday>>());
      final applicable = await repo.applicableHolidays(
        hr,
        matching.id,
        DateTime.utc(2026, 6, 15),
        DateTime.utc(2026, 6, 15),
      );
      expect(
        (applicable as Success<List<Holiday>>).value.any(
          (h) => h.name == 'Hyderabad Local Holiday',
        ),
        isTrue,
      );
      final notApplicable = await repo.applicableHolidays(
        hr,
        other.id,
        DateTime.utc(2026, 6, 15),
        DateTime.utc(2026, 6, 15),
      );
      expect(
        (notApplicable as Success<List<Holiday>>).value.any(
          (h) => h.name == 'Hyderabad Local Holiday',
        ),
        isFalse,
      );
    });

    test(
      'copying the previous year creates a reviewed next-year calendar',
      () async {
        final result = await repo.copyHolidaysToYear(
          hr,
          fromYear: 2026,
          toYear: 2027,
        );
        expect((result as Success<int>).value, 6);
        final copied = await repo.watchHolidaysForYear(hr, 2027).first;
        final holidays = (copied as Success<List<Holiday>>).value;
        expect(holidays.length, 6);
        expect(
          holidays.every(
            (h) => h.source == HolidaySource.copiedFromPreviousYear,
          ),
          isTrue,
        );
        expect(holidays.first.date.year, 2027);
        final calendars = await repo.watchHolidayCalendars(hr).first;
        expect(
          (calendars as Success<List<HolidayCalendar>>).value.any(
            (c) => c.year == 2027,
          ),
          isTrue,
        );
      },
    );

    test('CSV parsing validates rows and import skips duplicates', () async {
      const csv =
          'name,date,type,optional,scope\n'
          'Harvest,2026-09-01,festivalHoliday,false,companyWide\n'
          'Bad,not-a-date,companyHoliday,false,companyWide\n'
          'New Year,2026-01-01,publicHoliday,false,companyWide\n';
      final rows = parseHolidayCsv(csv);
      expect(rows.length, 3);
      expect(rows.where((r) => r.isValid).length, 2);
      expect(rows.where((r) => !r.isValid).length, 1);

      final result = await repo.importHolidays(hr, rows);
      final summary = (result as Success<HolidayImportResult>).value;
      expect(summary.imported, 1);
      expect(summary.skipped, 2);
    });

    test('a holiday calendar can be set up for a new year', () async {
      final saved = await repo.saveHolidayCalendar(
        hr,
        const HolidayCalendarDraft(name: 'Company Calendar 2028', year: 2028),
      );
      expect(saved, isA<Success<HolidayCalendar>>());
      final calendars = await repo.watchHolidayCalendars(hr).first;
      expect(
        (calendars as Success<List<HolidayCalendar>>).value.any(
          (c) => c.year == 2028,
        ),
        isTrue,
      );
    });
  });
}
