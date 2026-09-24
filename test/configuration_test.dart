import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geolocator/geolocator.dart';
import 'package:modular_erp/modules/hr/demo/demo_configuration_seed.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/utils/local_time.dart';
import 'package:modular_erp/core/location/location_service.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/app/module_registry/navigation_resolver.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/data/repositories/demo_auth_repository.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';
import 'package:modular_erp/modules/hr/shifts/data/local_shift_repository.dart';
import 'package:modular_erp/modules/hr/shifts/presentation/bloc/shift_list_bloc.dart';
import 'package:modular_erp/modules/hr/shifts/presentation/bloc/shift_details_bloc.dart';
import 'package:modular_erp/modules/hr/shifts/presentation/bloc/shift_form_bloc.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location.dart';
import 'package:modular_erp/modules/hr/work_locations/data/local_work_location_repository.dart';
import 'package:modular_erp/modules/hr/work_locations/presentation/bloc/work_location_form_bloc.dart';
import 'package:modular_erp/modules/hr/work_locations/presentation/bloc/work_location_list_bloc.dart';
import 'package:modular_erp/modules/hr/work_locations/presentation/bloc/work_location_details_bloc.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy.dart';
import 'package:modular_erp/modules/hr/attendance_policies/data/local_attendance_policy_repository.dart';
import 'package:modular_erp/modules/hr/attendance_policies/presentation/bloc/attendance_policy_form_bloc.dart';
import 'package:modular_erp/modules/hr/attendance_policies/presentation/bloc/attendance_policy_list_bloc.dart';
import 'package:modular_erp/modules/hr/attendance_policies/presentation/bloc/attendance_policy_details_bloc.dart';
import 'package:modular_erp/modules/hr/employees/data/employee_dao.dart';
import 'package:modular_erp/modules/hr/employees/data/employee_seed.dart';
import 'package:modular_erp/modules/hr/employees/data/local_employee_repository.dart';
import 'package:modular_erp/modules/hr/employees/data/account_provisioning_repository.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'employee_test.dart'
    show employeeContext, validDraft, draftFrom, unwrap, until;
import 'support/memory_session_storage.dart';

class MockLocationService extends Mock implements LocationService {}

ShiftDraft shiftDraft({String name = 'New shift'}) => ShiftDraft(
  name: name,
  code: 'custom',
  startTime: const LocalTime(hour: 22, minute: 0),
  endTime: const LocalTime(hour: 7, minute: 0),
  workingDays: {WorkingDay.monday, WorkingDay.friday},
  gracePeriodMinutes: 10,
);
WorkLocationDraft locationDraft({String name = 'New location'}) =>
    WorkLocationDraft(
      name: name,
      addressLine1: 'Test street',
      city: 'Hyderabad',
      countryCode: 'in',
      latitude: 17.4,
      longitude: 78.4,
      allowedRadiusMeters: 150,
    );
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late LocalShiftRepository shifts;
  late LocalWorkLocationRepository locations;
  late LocalAttendancePolicyRepository policies;
  late LocalEmployeeRepository employees;
  final hr = employeeContext(DemoScenario.hr);
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedEmployees(db);
    await seedAttendanceConfiguration(db);
    shifts = LocalShiftRepository(db);
    locations = LocalWorkLocationRepository(db);
    policies = LocalAttendancePolicyRepository(db);
    employees = LocalEmployeeRepository(
      EmployeeDao(db),
      LocalAccountProvisioningRepository(db),
    );
  });
  tearDown(() async {
    await db.close();
  });
  test(
    'overnight duration, expected work and JSON retain local time/day identities',
    () async {
      final s = unwrap(
        await shifts.save(
          hr,
          shiftDraft().copyWith(
            breakMode: ShiftBreakMode.fixedBreak,
            defaultBreakMinutes: 30,
            minimumWorkMinutes: 480,
          ),
        ),
      );
      expect(s.isOvernight, true);
      expect(s.durationMinutes, 540);
      expect(s.expectedWorkMinutes, 510);
      expect(s.code, 'CUSTOM');
      expect(Shift.fromJson(s.toJson()), s);
      expect(
        Shift.fromJson(
          jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>,
        ),
        s,
      );
      expect((await db.select(db.syncOutbox).get()).single.moduleId, 'shifts');
    },
  );
  for (final entry in <String, ShiftDraft>{
    'equal times': shiftDraft().copyWith(
      endTime: const LocalTime(hour: 22, minute: 0),
    ),
    'missing start': shiftDraft().copyWith(startTime: null),
    'no days': shiftDraft().copyWith(workingDays: {}),
    'negative grace': shiftDraft().copyWith(gracePeriodMinutes: -1),
    'grace exceeds duration': shiftDraft().copyWith(gracePeriodMinutes: 540),
    'fixed break too long': shiftDraft().copyWith(
      breakMode: ShiftBreakMode.fixedBreak,
      defaultBreakMinutes: 540,
    ),
    'negative minimum': shiftDraft().copyWith(minimumWorkMinutes: -1),
    'invalid time': shiftDraft().copyWith(
      startTime: const LocalTime(hour: 24, minute: 0),
    ),
  }.entries) {
    test('shift rejects ${entry.key} without local writes', () async {
      expect(await shifts.save(hr, entry.value), isA<Failed<Shift>>());
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    });
  }
  for (final entry in <String, WorkLocationDraft>{
    'latitude': locationDraft().copyWith(latitude: 91),
    'longitude': locationDraft().copyWith(longitude: -181),
    'NaN': locationDraft().copyWith(latitude: double.nan),
    'infinity': locationDraft().copyWith(longitude: double.infinity),
    'zero radius': locationDraft().copyWith(allowedRadiusMeters: 0),
    'negative accuracy': locationDraft().copyWith(maximumAccuracyMeters: -1),
    'country': locationDraft().copyWith(countryCode: 'IND'),
  }.entries) {
    test('location rejects ${entry.key}', () async {
      expect(
        await locations.save(hr, entry.value),
        isA<Failed<WorkLocation>>(),
      );
    });
  }
  test(
    'location CRUD normalizes country, preserves identity and soft deactivates',
    () async {
      final first = unwrap(await locations.save(hr, locationDraft()));
      expect(first.countryCode, 'IN');
      final edit = unwrap(
        await locations.save(
          hr,
          locationDraft(
            name: 'Updated location',
          ).copyWith(allowedRadiusMeters: 200),
          id: first.id,
        ),
      );
      expect(edit.id, first.id);
      expect(edit.createdAt, first.createdAt);
      expect(edit.allowedRadiusMeters, 200);
      unwrap(await locations.setActive(hr, first.id, false));
      expect(
        unwrap(await locations.getById(hr, first.id))!.status,
        ConfigurationStatus.inactive,
      );
      unwrap(await locations.setActive(hr, first.id, true));
      expect(
        unwrap(await locations.watchList(hr, query: 'Updated').first).filtered,
        1,
      );
    },
  );
  test(
    'policy dependencies normalize at repository boundary and persist structured fields',
    () async {
      final p = unwrap(
        await policies.save(
          hr,
          const AttendancePolicyDraft(
            name: 'Normalized',
            requireLocation: false,
            requireLocationAccuracy: true,
            maximumAcceptedAccuracyMeters: 25,
            requireLocationOnBreak: true,
            allowOutsideLocation: true,
            trackBreaks: false,
            allowMultipleBreaks: true,
            allowPunchOutDuringBreak: true,
            allowEarlyPunchIn: false,
            earlyPunchInLimitMinutes: 30,
          ),
        ),
      );
      expect(p.requireLocationOnPunchIn, false);
      expect(p.requireLocationOnPunchOut, false);
      expect(p.requireLocationOnBreak, false);
      expect(p.requireLocationAccuracy, false);
      expect(p.maximumAcceptedAccuracyMeters, null);
      expect(p.allowOutsideLocation, false);
      expect(p.allowMultipleBreaks, false);
      expect(p.allowPunchOutDuringBreak, false);
      expect(p.earlyPunchInLimitMinutes, null);
      expect(AttendancePolicy.fromJson(p.toJson()), p);
    },
  );
  for (final entry in <String, AttendancePolicyDraft>{
    'no location events': const AttendancePolicyDraft(
      name: 'Invalid',
      requireLocationOnPunchIn: false,
      requireLocationOnPunchOut: false,
    ),
    'accuracy': const AttendancePolicyDraft(
      name: 'Invalid',
      requireLocationAccuracy: true,
      maximumAcceptedAccuracyMeters: 0,
    ),
    'early limit': const AttendancePolicyDraft(
      name: 'Invalid',
      allowEarlyPunchIn: true,
      earlyPunchInLimitMinutes: -1,
    ),
  }.entries) {
    test('policy rejects ${entry.key}', () async {
      expect(
        await policies.save(hr, entry.value),
        isA<Failed<AttendancePolicy>>(),
      );
    });
  }
  test('policy CRUD and active-name uniqueness survive reactivation', () async {
    final p = unwrap(
      await policies.save(
        hr,
        const AttendancePolicyDraft(name: 'Unique policy'),
      ),
    );
    unwrap(await policies.setActive(hr, p.id, false));
    final second = unwrap(
      await policies.save(
        hr,
        const AttendancePolicyDraft(name: ' UNIQUE   policy '),
      ),
    );
    expect(await policies.setActive(hr, p.id, true), isA<Failed<void>>());
    expect(
      unwrap(await policies.getById(hr, p.id))!.status,
      ConfigurationStatus.inactive,
    );
    unwrap(
      await policies.save(
        hr,
        const AttendancePolicyDraft(
          name: 'Renamed policy',
          description: 'Updated',
        ),
        id: second.id,
      ),
    );
    expect(
      unwrap(await policies.watchList(hr, query: 'Updated').first).filtered,
      1,
    );
  });
  test(
    'shift search escapes wildcards, filters statuses and paginates SQL results',
    () async {
      for (var n = 0; n < 13; n++) {
        unwrap(await shifts.save(hr, shiftDraft(name: 'Custom $n')));
      }
      expect(unwrap(await shifts.watchList(hr).first).total, 17);
      expect(unwrap(await shifts.watchList(hr, page: 1).first).items.length, 7);
      expect(unwrap(await shifts.watchList(hr, query: '%').first).filtered, 0);
      expect(
        unwrap(await shifts.watchList(hr, query: 'NIGHT').first).filtered,
        1,
      );
      unwrap(await shifts.setActive(hr, 'shift-night', false));
      expect(
        unwrap(
          await shifts
              .watchList(hr, status: ConfigurationStatus.inactive)
              .first,
        ).filtered,
        1,
      );
    },
  );
  test(
    'case-insensitive normalized active names are unique per company',
    () async {
      expect(
        await shifts.save(hr, shiftDraft(name: ' general   SHIFT ')),
        isA<Failed<Shift>>(),
      );
      final other = hr.copyWith(
        company: hr.company.copyWith(id: 'other'),
        user: hr.user.copyWith(companyId: 'other'),
      );
      final created = unwrap(
        await shifts.save(other, shiftDraft(name: 'General Shift')),
      );
      expect(created.companyId, 'other');
      expect(unwrap(await shifts.watchList(hr).first).total, 4);
      expect(unwrap(await shifts.getById(hr, created.id)), null);
      expect(
        await shifts.setActive(hr, created.id, false),
        isA<Failed<void>>(),
      );
    },
  );
  test(
    'view/manage permissions and company module enablement are explicit',
    () async {
      final self = employeeContext(DemoScenario.employee);
      expect(
        await shifts.watchList(self).first,
        isA<Failed<ConfigurationPageData<Shift>>>(),
      );
      expect(
        await locations.save(self, locationDraft()),
        isA<Failed<WorkLocation>>(),
      );
      expect(
        await policies.getById(self, 'policy-office'),
        isA<Failed<AttendancePolicy?>>(),
      );
      final disabled = hr.copyWith(
        company: hr.company.copyWith(enabledModules: {'employees'}),
      );
      expect(await shifts.save(disabled, shiftDraft()), isA<Failed<Shift>>());
      final view = hr.copyWith(
        user: hr.user.copyWith(
          permissions: PermissionSet([AppPermission.shiftView]),
        ),
      );
      expect(
        unwrap(await shifts.getById(view, 'shift-night'))!.isOvernight,
        true,
      );
      expect(await shifts.save(view, shiftDraft()), isA<Failed<Shift>>());
      final manage = hr.copyWith(
        user: hr.user.copyWith(
          permissions: PermissionSet([AppPermission.shiftManage]),
        ),
      );
      expect(
        unwrap(await shifts.getById(manage, 'shift-night', forEditing: true)),
        isNotNull,
      );
      expect(unwrap(await shifts.getById(manage, 'shift-night')), isNotNull);
    },
  );
  test(
    'employee assignments use active company records and SQL counts retain inactive history',
    () async {
      final e = unwrap(
        await employees.saveEmployee(
          hr,
          validDraft().copyWith(
            shiftId: 'shift-night',
            workLocationId: 'location-hyderabad',
            attendancePolicyId: 'policy-office',
          ),
        ),
      );
      expect(unwrap(await shifts.assignedEmployeeCount(hr, 'shift-night')), 1);
      expect(
        unwrap(await locations.assignedEmployeeCount(hr, 'location-hyderabad')),
        1,
      );
      expect(
        unwrap(await policies.assignedEmployeeCount(hr, 'policy-office')),
        1,
      );
      final detail = unwrap(
        await shifts.watchDetails(hr, 'shift-night').first,
      )!;
      expect(detail.assignedEmployees, 1);
      unwrap(await shifts.setActive(hr, 'shift-night', false));
      expect(
        unwrap(await employees.getEmployeeById(hr, e.id))!.shiftId,
        'shift-night',
      );
      final edit = draftFrom(e).copyWith(
        shiftId: e.shiftId,
        workLocationId: e.workLocationId,
        attendancePolicyId: e.attendancePolicyId,
        firstName: 'Retained',
      );
      unwrap(await employees.saveEmployee(hr, edit, id: e.id));
      expect(
        await employees.saveEmployee(
          hr,
          validDraft(
            email: 'another@erp.demo',
            phone: '+15557779999',
          ).copyWith(shiftId: 'shift-night'),
        ),
        isA<Failed<Employee>>(),
      );
      final refs = unwrap(await employees.getReferences(hr, excludingId: e.id));
      expect(
        refs.shifts.firstWhere((s) => s.id == 'shift-night').status,
        ConfigurationStatus.inactive,
      );
      unwrap(
        await employees.saveEmployee(
          hr,
          edit.copyWith(shiftId: null),
          id: e.id,
        ),
      );
      expect(unwrap(await shifts.assignedEmployeeCount(hr, 'shift-night')), 0);
    },
  );
  test(
    'self references expose only own assignments and readable entities',
    () async {
      final current = unwrap(
        await employees.getEmployeeById(hr, 'employee-employee'),
      )!;
      unwrap(
        await employees.saveEmployee(
          hr,
          draftFrom(current).copyWith(
            shiftId: 'shift-general',
            workLocationId: 'location-hyderabad',
            attendancePolicyId: 'policy-remote',
          ),
          id: current.id,
        ),
      );
      final self = employeeContext(DemoScenario.employee),
          refs = unwrap(
            await employees.getReferences(self, excludingId: current.id),
          );
      expect(refs.shifts.map((s) => s.name), ['General Shift']);
      expect(refs.workLocations.map((s) => s.name), ['Hyderabad HQ']);
      expect(refs.attendancePolicies.map((s) => s.name), [
        'Remote Staff Policy',
      ]);
      final unrelated = unwrap(
        await employees.getReferences(self, excludingId: 'employee-manager'),
      );
      expect(unrelated.shifts, isEmpty);
    },
  );
  test(
    'missing or cross-company assignment rejects entire employee transaction',
    () async {
      final other = hr.copyWith(
        company: hr.company.copyWith(id: 'other'),
        user: hr.user.copyWith(companyId: 'other'),
      );
      final s = unwrap(await shifts.save(other, shiftDraft()));
      for (final id in [s.id, 'missing']) {
        expect(
          await employees.saveEmployee(hr, validDraft().copyWith(shiftId: id)),
          isA<Failed<Employee>>(),
        );
      }
      expect((await db.select(db.workforceEmployees).get()).length, 25);
      expect((await db.select(db.syncOutbox).get()).length, 1);
    },
  );
  test('outbox failure rolls back configuration and reactivation', () async {
    await db.customStatement(
      "CREATE TRIGGER reject_configuration_outbox BEFORE INSERT ON sync_outbox BEGIN SELECT RAISE(ABORT,'test failure'); END",
    );
    expect(await shifts.save(hr, shiftDraft()), isA<Failed<Shift>>());
    expect(unwrap(await shifts.watchList(hr).first).total, 4);
    expect(
      await policies.setActive(hr, 'policy-office', false),
      isA<Failed<void>>(),
    );
    expect(
      unwrap(await policies.getById(hr, 'policy-office'))!.status,
      ConfigurationStatus.active,
    );
  });
  test(
    'fixture seeding is deterministic, idempotent and preserves edits',
    () async {
      unwrap(
        await shifts.save(
          hr,
          shiftDraft(name: 'Edited night'),
          id: 'shift-night',
        ),
      );
      unwrap(await policies.setActive(hr, 'policy-field', false));
      await seedAttendanceConfiguration(db);
      await seedAttendanceConfiguration(db);
      expect(unwrap(await shifts.watchList(hr).first).total, 4);
      expect(unwrap(await locations.watchList(hr).first).total, 2);
      expect(unwrap(await policies.watchList(hr).first).total, 3);
      expect(
        unwrap(await shifts.getById(hr, 'shift-night'))!.name,
        'Edited night',
      );
      expect(
        unwrap(await policies.getById(hr, 'policy-field'))!.status,
        ConfigurationStatus.inactive,
      );
      expect((await db.select(db.syncOutbox).get()).length, 2);
    },
  );
  test(
    'all configuration form BLoCs validate, save once and retain failed drafts',
    () async {
      final shift = ShiftFormBloc(shifts, hr)
        ..add(const RecordFormInitialized<ShiftDraft>());
      await until(() => !shift.state.loading);
      shift.add(const RecordSubmitted<ShiftDraft>());
      await until(() => shift.state.fieldErrors.isNotEmpty);
      shift.add(RecordDraftChanged<ShiftDraft>((_) => shiftDraft()));
      shift.add(const RecordSubmitted<ShiftDraft>());
      shift.add(const RecordSubmitted<ShiftDraft>());
      await until(() => shift.state.savedId != null);
      expect(shift.state.dirty, false);
      await shift.close();
      final location = WorkLocationFormBloc(
        locations,
        hr,
        MockLocationService(),
      )..add(const RecordFormInitialized<WorkLocationDraft>());
      await until(() => !location.state.loading);
      location.add(
        RecordDraftChanged<WorkLocationDraft>((_) => locationDraft()),
      );
      location.add(const RecordSubmitted<WorkLocationDraft>());
      await until(() => location.state.savedId != null);
      await location.close();
      final policy = AttendancePolicyFormBloc(policies, hr)
        ..add(const RecordFormInitialized<AttendancePolicyDraft>());
      await until(() => !policy.state.loading);
      policy.add(
        RecordDraftChanged<AttendancePolicyDraft>(
          (_) => const AttendancePolicyDraft(name: 'Office Staff Policy'),
        ),
      );
      policy.add(const RecordSubmitted<AttendancePolicyDraft>());
      await until(() => policy.state.failure != null);
      expect(policy.state.draft.name, 'Office Staff Policy');
      expect(policy.state.fieldErrors['name'], 'duplicateName');
      expect(policy.state.dirty, true);
      policy.add(
        RecordDraftChanged<AttendancePolicyDraft>(
          (d) => d.copyWith(name: 'Saved policy'),
        ),
      );
      policy.add(const RecordSubmitted<AttendancePolicyDraft>());
      await until(() => policy.state.savedId != null);
      await policy.close();
      expect((await db.select(db.syncOutbox).get()).length, 3);
    },
  );
  test('all list/detail BLoCs observe live assignment/status writes', () async {
    final sl = ShiftListBloc(shifts, hr)..add(const RecordListStarted()),
        sd = ShiftDetailsBloc(shifts, hr, 'shift-night')
          ..add(const RecordDetailsStarted()),
        ll = WorkLocationListBloc(locations, hr)
          ..add(const RecordListStarted()),
        ld = WorkLocationDetailsBloc(locations, hr, 'location-hyderabad')
          ..add(const RecordDetailsStarted()),
        pl = AttendancePolicyListBloc(policies, hr)
          ..add(const RecordListStarted()),
        pd = AttendancePolicyDetailsBloc(policies, hr, 'policy-office')
          ..add(const RecordDetailsStarted());
    await until(
      () =>
          !sl.state.loading &&
          !sd.state.loading &&
          !ll.state.loading &&
          !ld.state.loading &&
          !pl.state.loading &&
          !pd.state.loading,
    );
    expect(sl.state.data!.total, 4);
    expect(ll.state.data!.total, 2);
    expect(pl.state.data!.total, 3);
    unwrap(
      await employees.saveEmployee(
        hr,
        validDraft().copyWith(
          shiftId: 'shift-night',
          workLocationId: 'location-hyderabad',
          attendancePolicyId: 'policy-office',
        ),
      ),
    );
    await until(
      () =>
          sd.state.detail!.assignedEmployees == 1 &&
          ld.state.detail!.assignedEmployees == 1 &&
          pd.state.detail!.assignedEmployees == 1,
    );
    sd.add(const RecordDetailsStatusRequested(false));
    await until(
      () => sd.state.detail!.record.status == ConfigurationStatus.inactive,
    );
    sl.add(const RecordFilterChanged(ConfigurationStatus.inactive));
    await until(() => !sl.state.loading && sl.state.data!.filtered == 1);
    sl.add(const RecordSearchChanged('NIGHT'));
    await until(() => !sl.state.loading && sl.state.query == 'NIGHT');
    for (final bloc in [sl, sd, ll, ld, pl, pd]) {
      await bloc.close();
    }
  });
  for (final code in [
    'location_permission',
    'location_permanent',
    'location_disabled',
    'location_timeout',
    'location_unavailable',
  ]) {
    test(
      'user-driven location helper retains manual draft after $code',
      () async {
        final service = MockLocationService();
        when(
          () => service.currentPosition(requestPermission: true),
        ).thenAnswer((_) async => Failed(Failure(code: code)));
        final b = WorkLocationFormBloc(locations, hr, service)
          ..add(const RecordFormInitialized<WorkLocationDraft>());
        await until(() => !b.state.loading);
        verifyNever(
          () => service.currentPosition(
            requestPermission: any(named: 'requestPermission'),
          ),
        );
        b.add(RecordDraftChanged<WorkLocationDraft>((_) => locationDraft()));
        b.add(const CaptureCurrentLocation());
        await until(() => b.state.locationFailure != null);
        expect(b.state.draft.latitude, 17.4);
        expect(b.state.locating, false);
        await b.close();
      },
    );
  }
  test(
    'current location capture fills coordinates and retains honest accuracy',
    () async {
      final service = MockLocationService();
      when(() => service.currentPosition(requestPermission: true)).thenAnswer(
        (_) async => Success(
          Position(
            latitude: 17.5,
            longitude: 78.5,
            timestamp: DateTime.now(),
            accuracy: 120,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          ),
        ),
      );
      final b = WorkLocationFormBloc(locations, hr, service)
        ..add(const RecordFormInitialized<WorkLocationDraft>());
      await until(() => !b.state.loading);
      b.add(const CaptureCurrentLocation());
      await until(() => b.state.capturedAccuracy != null);
      expect(b.state.draft.latitude, 17.5);
      expect(b.state.capturedAccuracy, 120);
      await b.close();
    },
  );
  test(
    'numeric entry accepts Arabic/Persian decimals without treating invalid input as zero',
    () {
      expect(const AppNumericInput('١٧٫٣٨٥').value, 17.385);
      expect(const AppNumericInput('۷۸٫۴').value, 78.4);
      expect(const AppNumericInput('oops').optional!.isNaN, true);
      expect(const AppNumericInput('').optional, null);
      expect(const AppNumericInput('1.5').optionalInteger, -1);
    },
  );
  test(
    'configuration route permissions use longest owner and manage grants',
    () async {
      final auth = DemoAuthRepository(
        MemorySessionStorage(),
        source: DemoAuthSource(),
      );
      final registry = createErpRegistry(auth),
          resolver = NavigationResolver(registry);
      for (final pair in [
        (root: AppRoutes.shifts, permission: AppPermission.shiftManage),
        (
          root: AppRoutes.workLocations,
          permission: AppPermission.workLocationManage,
        ),
        (
          root: AppRoutes.attendancePolicies,
          permission: AppPermission.attendancePolicyManage,
        ),
        (root: AppRoutes.leaveTypes, permission: AppPermission.leaveTypeManage),
        (
          root: AppRoutes.leavePolicies,
          permission: AppPermission.leavePolicyManage,
        ),
        (root: AppRoutes.holidays, permission: AppPermission.holidayManage),
      ]) {
        final manage = hr.copyWith(
          user: hr.user.copyWith(permissions: PermissionSet([pair.permission])),
        );
        // A manage grant carries its view dependency, so the screen is never
        // inaccessible merely because View was not listed separately.
        expect(resolver.routeAccess(pair.root, manage), RouteAccess.allowed);
        expect(
          resolver.routeAccess('${pair.root}/new', manage),
          RouteAccess.allowed,
        );
        expect(
          resolver.routeAccess('${pair.root}/id/edit', manage),
          RouteAccess.allowed,
        );
        expect(
          resolver.routeAccess(
            '${pair.root}/id',
            employeeContext(DemoScenario.employee),
          ),
          RouteAccess.unauthorized,
        );
        expect(
          resolver.routeAccess('${pair.root}/id', hr),
          RouteAccess.allowed,
        );
      }
      await auth.dispose();
    },
  );
  test(
    'schema 2 to current upgrade preserves employees, accounts, assignments and queued operations',
    () async {
      await db.close();
      final dir = Directory.systemTemp.createTempSync('erp_config_migration_');
      final file = File('${dir.path}/erp.sqlite');
      var old = AppDatabase(NativeDatabase(file));
      await seedEmployees(old);
      final dao = EmployeeDao(old),
          account = LocalAccountProvisioningRepository(old);
      final repo = LocalEmployeeRepository(dao, account);
      final e = unwrap(await repo.saveEmployee(hr, validDraft()));
      await old.customStatement('DROP TABLE shift_records');
      await old.customStatement('DROP TABLE work_location_records');
      await old.customStatement('DROP TABLE attendance_policy_records');
      await old.customStatement('DROP TABLE attendance_events');
      await old.customStatement('DROP TABLE attendance_days');
      await old.customStatement('DROP TABLE attendance_correction_requests');
      await old.customStatement('DROP INDEX outbox_request');
      await old.customStatement('DROP INDEX IF EXISTS outbox_status_next');
      await old.customStatement('DROP INDEX IF EXISTS outbox_company_status');
      for (final column in [
        'company_id',
        'request_id',
        'status',
        'last_attempt_at',
        'failure_code',
      ]) {
        await old.customStatement(
          'ALTER TABLE sync_outbox DROP COLUMN $column',
        );
      }
      await old.customStatement('PRAGMA user_version=2');
      await old.close();
      final upgraded = AppDatabase(NativeDatabase(file));
      expect(
        (await upgraded.select(upgraded.workforceEmployees).get()).length,
        26,
      );
      expect(
        (await upgraded.select(upgraded.workforceAccounts).get()).length,
        5,
      );
      expect(
        (await upgraded.select(upgraded.syncOutbox).get()).single.entityId,
        e.id,
      );
      expect(
        (await upgraded.customSelect('PRAGMA user_version').getSingle())
            .read<int>('user_version'),
        12,
      );
      expect(await upgraded.select(upgraded.documentSequences).get(), isEmpty);
      expect(await upgraded.select(upgraded.attachmentRecords).get(), isEmpty);
      expect(
        await upgraded.select(upgraded.businessActivityEvents).get(),
        isEmpty,
      );
      await seedAttendanceConfiguration(upgraded);
      final sr = LocalShiftRepository(upgraded);
      unwrap(
        await sr.save(
          hr,
          shiftDraft(name: 'Persistent night'),
          id: 'shift-night',
        ),
      );
      await upgraded.close();
      final restored = AppDatabase(NativeDatabase(file));
      await seedAttendanceConfiguration(restored);
      expect(
        unwrap(
          await LocalShiftRepository(restored).getById(hr, 'shift-night'),
        )!.name,
        'Persistent night',
      );
      expect((await restored.select(restored.syncOutbox).get()).length, 2);
      await restored.close();
      file.deleteSync();
      dir.deleteSync();
    },
  );
}
