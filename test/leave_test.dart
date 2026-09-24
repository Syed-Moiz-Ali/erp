import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/modules/hr/demo/demo_configuration_seed.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/modules/hr/employees/data/employee_seed.dart';
import 'package:modular_erp/modules/hr/leave/data/leave_configuration_repositories.dart';
import 'package:modular_erp/modules/hr/leave/data/local_leave_repository.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_repository.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_services.dart';
import 'attendance_test.dart' show FakeClock, MockAuth;
import 'employee_test.dart' show employeeContext;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late MockAuth auth;
  late LocalLeaveRepository repo;
  late AuthContext manager;
  late AuthContext hr;

  setUp(() async {
    manager = employeeContext(DemoScenario.manager);
    hr = employeeContext(DemoScenario.hr);
    db = AppDatabase(NativeDatabase.memory());
    await seedEmployees(db);
    await seedAttendanceConfiguration(db);
    final clock = FakeClock(DateTime.utc(2026, 9, 18, 12));
    auth = MockAuth();
    when(() => auth.checkSession()).thenAnswer((_) async => Success(manager));
    repo = LocalLeaveRepository(db, auth, clock, demoEnabled: true);
  });
  tearDown(() async => db.close());

  LeaveRequestDraft annualDraft(
    DateTime start,
    DateTime end, {
    String typeId = 'leave-type-annual',
  }) => LeaveRequestDraft(leaveTypeId: typeId, startDate: start, endDate: end);

  test(
    'demo seed provides leave configuration and starting balances',
    () async {
      final types = await repo.watchLeaveTypes(manager).first;
      expect((types as Success<List<LeaveType>>).value.length, 4);
      final holidays = await repo.watchHolidays(manager).first;
      expect((holidays as Success<List<Holiday>>).value.length, 6);
      final employeeId = manager.employeeReference!.id;
      final balances = await repo.watchBalances(manager, employeeId).first;
      final list = (balances as Success<List<LeaveBalanceSummary>>).value;
      final annual = list.firstWhere(
        (b) => b.leaveTypeId == 'leave-type-annual',
      );
      expect(annual.entitlement, 30);
      expect(annual.available, 30);
    },
  );

  test('submit reserves balance and approval consumes it', () async {
    final employeeId = manager.employeeReference!.id;
    final submitted = await repo.submitRequest(
      manager,
      annualDraft(DateTime.utc(2026, 9, 21), DateTime.utc(2026, 9, 22)),
    );
    expect(submitted, isA<Success<LeaveRequest>>());
    final request = (submitted as Success<LeaveRequest>).value;
    expect(request.requestedDays, 2);

    final reserved = await repo.watchBalances(manager, employeeId).first;
    var annual = (reserved as Success<List<LeaveBalanceSummary>>).value
        .firstWhere((b) => b.leaveTypeId == 'leave-type-annual');
    expect(annual.pending, 2);
    expect(annual.used, 0);
    expect(annual.available, 28);

    final approved = await repo.approveRequest(hr, request.id);
    expect(approved, isA<Success<LeaveRequest>>());

    final consumed = await repo.watchBalances(manager, employeeId).first;
    annual = (consumed as Success<List<LeaveBalanceSummary>>).value.firstWhere(
      (b) => b.leaveTypeId == 'leave-type-annual',
    );
    expect(annual.pending, 0);
    expect(annual.used, 2);
    expect(annual.available, 28);
  });

  test('overlapping and over-balance paid requests are rejected', () async {
    final start = DateTime.utc(2026, 9, 21);
    final end = DateTime.utc(2026, 9, 22);
    await repo.submitRequest(manager, annualDraft(start, end));
    final overlap = await repo.submitRequest(
      manager,
      annualDraft(DateTime.utc(2026, 9, 22), DateTime.utc(2026, 9, 23)),
    );
    expect((overlap as Failed<LeaveRequest>).failure.code, 'leaveOverlapping');

    final tooLong = await repo.submitRequest(
      manager,
      annualDraft(DateTime.utc(2026, 11, 2), DateTime.utc(2026, 12, 31)),
    );
    expect(
      (tooLong as Failed<LeaveRequest>).failure.code,
      'leaveInsufficientBalance',
    );
  });

  test('self approval and invalid ranges are refused', () async {
    final submitted = await repo.submitRequest(
      manager,
      annualDraft(DateTime.utc(2026, 9, 21), DateTime.utc(2026, 9, 21)),
    );
    final request = (submitted as Success<LeaveRequest>).value;
    final selfApprove = await repo.approveRequest(manager, request.id);
    expect(
      (selfApprove as Failed<LeaveRequest>).failure.code,
      'leaveSelfApprovalNotAllowed',
    );
    final invalid = await repo.submitRequest(
      manager,
      annualDraft(DateTime.utc(2026, 9, 25), DateTime.utc(2026, 9, 21)),
    );
    expect(
      (invalid as Failed<LeaveRequest>).failure.code,
      'leaveInvalidDateRange',
    );
  });

  test('configuration adapter lists and pages leave types', () async {
    final configuration = leaveTypeConfiguration(repo);
    final page = await configuration.watchList(hr, pageSize: 10).first;
    final data = (page as Success).value;
    expect(data.total, 4);
    expect(data.filtered, 4);
    expect(data.items.length, 4);
  });

  test('day override reports holiday and approved leave', () async {
    final employeeId = manager.employeeReference!.id;
    final holidaysResult = await repo.watchHolidays(manager).first;
    final holidayDate =
        (holidaysResult as Success<List<Holiday>>).value.first.date;
    final holiday = await repo.dayOverride(manager, employeeId, holidayDate);
    expect(
      (holiday as Success<LeaveWorkdayOverlay?>).value?.classification,
      WorkdayClassification.holiday,
    );

    final submitted = await repo.submitRequest(
      manager,
      annualDraft(DateTime.utc(2026, 9, 21), DateTime.utc(2026, 9, 21)),
    );
    await repo.approveRequest(
      hr,
      (submitted as Success<LeaveRequest>).value.id,
    );
    final onLeave = await repo.dayOverride(
      manager,
      employeeId,
      DateTime.utc(2026, 9, 21),
    );
    expect(
      (onLeave as Success<LeaveWorkdayOverlay?>).value?.classification,
      WorkdayClassification.approvedLeave,
    );
  });

  test(
    'day calculator excludes weekends and holidays and honours half days',
    () {
      const calculator = LeaveDayCalculator();
      final result = calculator.calculate(
        startDate: DateTime.utc(2026, 9, 18),
        endDate: DateTime.utc(2026, 9, 23),
        workingWeekdays: const {1, 2, 3, 4, 5},
        holidayDates: {'2026-09-22'},
        startPortion: LeaveDayPortion.fullDay,
        endPortion: LeaveDayPortion.fullDay,
        allowHalfDay: true,
      );
      expect(result.excludedWeekends, 2);
      expect(result.excludedHolidays, 1);
      expect(result.quantityDays, 3);

      final half = calculator.calculate(
        startDate: DateTime.utc(2026, 9, 21),
        endDate: DateTime.utc(2026, 9, 21),
        workingWeekdays: const {1, 2, 3, 4, 5},
        holidayDates: const {},
        startPortion: LeaveDayPortion.firstHalf,
        endPortion: LeaveDayPortion.firstHalf,
        allowHalfDay: true,
      );
      expect(half.quantityDays, 0.5);
    },
  );
}
