import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_repository.dart';
import 'package:modular_erp/modules/hr/employees/live/data/dto/live_employee_dtos.dart';
import 'package:modular_erp/modules/hr/employees/live/data/repositories/remote_employee_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

import 'support/department_test_doubles.dart' show departmentAuthContext;
import 'support/employee_test_doubles.dart';

Map<String, dynamic> employeeFixture(String name) {
  final envelope =
      jsonDecode(File('test/fixtures/employees/$name').readAsStringSync())
          as Map<String, dynamic>;
  return (envelope['data'] as Map).cast<String, dynamic>();
}

List<Map<String, dynamic>> employeeItems() {
  final data = employeeFixture('employees_list.json');
  return [
    for (final item in (data['items'] as List))
      (item as Map).cast<String, dynamic>(),
  ];
}

void main() {
  final context = departmentAuthContext();
  late FakeLiveEmployeeRemoteDataSource dataSource;
  late RemoteEmployeeRepository repository;

  setUp(() {
    dataSource = FakeLiveEmployeeRemoteDataSource();
    repository = RemoteEmployeeRepository(dataSource);
  });

  tearDown(() => repository.dispose());

  test('maps list employees, null contacts, ids, status and dates', () async {
    final items = employeeItems();
    dataSource.onList =
        (
          search,
          statusId,
          departmentId,
          branchId,
          sort,
          page,
          pageSize,
        ) async => Success(
          employeePage([
            for (final item in items) employeeDto(item),
          ], totalItems: 34),
        );

    final result = await repository.watchEmployees(context, pageSize: 25).first;
    final page = (result as Success<EmployeePageData>).value;
    expect(page.total, 34);
    expect(page.filtered, 34);
    expect(page.employees, hasLength(items.length));

    final first = page.employees.first;
    expect(first.id, '15');
    expect(first.employeeCode, 'EMP-15');
    expect(first.companyId, '3');
    expect(first.firstName, 'Sanitized Name');
    expect(first.middleName, '');
    expect(first.lastName, '');
    expect(first.email, 'sanitized@example.com');
    expect(first.phone, 'SANITIZED_PHONE');
    expect(first.departmentId, '1');
    expect(first.designationId, 'Technician');
    expect(first.managerId, isNull);
    expect(first.joiningDate, DateTime(2026, 9, 1));
    expect(first.status, EmploymentStatus.active);
    expect(first.shiftId, isNull);
    expect(first.workLocationId, isNull);
    expect(first.attendancePolicyId, isNull);
    expect(first.createdAt, DateTime.utc(1970, 1, 1));
    expect(first.updatedAt, DateTime.utc(1970, 1, 1));
    expect(first.syncStatus, EmployeeSyncStatus.synced);

    final noContacts = page.employees.firstWhere((e) => e.id == '30');
    expect(noContacts.email, '');
    expect(noContacts.phone, '');
    expect(noContacts.designationId, 'QA Child');
    expect(noContacts.joiningDate, DateTime(2026, 10, 28));
  });

  test('maps detail login into the baseline employee model', () async {
    final detail = employeeFixture('employee_detail.json');
    final dto = employeeDto(detail);
    dataSource.onGet = (_) async => Success(dto);

    final result = await repository.getEmployeeById(context, '15');
    final employee = (result as Success<Employee?>).value!;
    expect(employee.id, '15');
    expect(employee.linkedUserId, '31');
    expect(employee.loginEnabled, isTrue);
    expect(employee.email, 'sanitized@example.com');
    expect(employee.phone, 'SANITIZED_PHONE');
    expect(employee.joiningDate, DateTime(2026, 9, 1));
    expect(employee.branchId, '1');
    expect(employee.nationalityId, '99');
    expect(employee.dateOfBirth, DateTime(1995, 5, 20));
    expect(employee.maritalStatus, 'Single');
    expect(employee.gratuity, 'Limited Contract');
    expect(employee.workingHours, 8);
    expect(employee.basicSalary, 3000);
    expect(employee.transportation, 500);
    expect(employee.accommodation, 1000);
  });

  test('maps the created fixture without deriving id or code', () async {
    final created = employeeFixture('employee_created.json');
    final dto = employeeDto(created);
    dataSource.onCreate = (_) async => Success(dto);
    dataSource.onGet = (_) async => Success(dto);

    final result = await repository.saveEmployee(
      context,
      const EmployeeDraft(firstName: 'Sanitized Name'),
    );
    final employee = (result as Success<Employee>).value;
    expect(employee.id, '1032');
    expect(employee.employeeCode, 'EMP-33');
    expect(employee.linkedUserId, '31');
    expect(employee.loginEnabled, isTrue);
    expect(employee.departmentId, '1');
    expect(employee.designationId, 'Technician');
  });

  test('maps list filters, paging and supported sorts', () async {
    dataSource.onList =
        (
          search,
          statusId,
          departmentId,
          branchId,
          sort,
          page,
          pageSize,
        ) async => Success(employeePage([]));

    await repository
        .watchEmployees(
          context,
          query: '  QA  ',
          filter: const EmployeeFilter(
            status: EmploymentStatus.active,
            departmentId: '2',
          ),
          sort: EmployeeSort.nameDescending,
          page: 0,
          pageSize: 10,
        )
        .first;
    expect(dataSource.lastSearch, 'QA');
    expect(dataSource.lastStatusId, 1);
    expect(dataSource.lastDepartmentId, 2);
    expect(dataSource.lastBranchId, isNull);
    expect(dataSource.lastSort, 'nameDesc');
    expect(dataSource.lastPage, 1);
    expect(dataSource.lastPageSize, 10);

    await repository
        .watchEmployees(
          context,
          filter: const EmployeeFilter(status: EmploymentStatus.inactive),
          sort: EmployeeSort.code,
        )
        .first;
    expect(dataSource.lastStatusId, 2);
    expect(dataSource.lastSort, 'codeAsc');
    expect(dataSource.lastBranchId, isNull);

    await repository
        .watchEmployees(context, sort: EmployeeSort.newestJoined)
        .first;
    expect(dataSource.lastSort, 'newest');

    await repository
        .watchEmployees(context, sort: EmployeeSort.oldestJoined)
        .first;
    expect(dataSource.lastSort, 'nameAsc');
    expect(dataSource.lastBranchId, isNull);
  });

  test(
    'create body sends the backend employment fields and no userType',
    () async {
      final created = employeeFixture('employee_created.json');
      dataSource.onCreate = (_) async => Success(employeeDto(created));
      dataSource.onGet = (_) async => Success(employeeDto(created));

      final result = await repository.saveEmployee(
        context,
        EmployeeDraft(
          firstName: ' QA ',
          middleName: ' Audit ',
          lastName: ' User ',
          email: ' qa@example.com ',
          phone: ' 0500000000 ',
          departmentId: '2',
          designationId: ' Engineer ',
          joiningDate: DateTime(2026, 10, 1),
          status: EmploymentStatus.active,
          loginEnabled: true,
          branchId: '1',
          nationalityId: '99',
          dateOfBirth: DateTime(1995, 5, 20),
          maritalStatus: 'Single',
          gratuity: 'Limited Contract',
          workingHours: 8,
          basicSalary: 3000,
          transportation: 500,
          accommodation: 1000,
        ),
      );
      expect(result, isA<Success<Employee>>());

      final body = dataSource.lastCreateBody!;
      expect(body['employeeName'], 'QA Audit User');
      expect(body['statusId'], 1);
      expect(body['departmentId'], 2);
      expect(body['designation'], 'Engineer');
      expect(body['joiningDate'], '2026-10-01');
      expect(body['email'], 'qa@example.com');
      expect(body['uaeContactNumber'], '0500000000');
      expect(body['branchId'], 1);
      expect(body['nationalityId'], 99);
      expect(body['dateOfBirth'], '1995-05-20');
      expect(body['maritalStatus'], 'Single');
      expect(body['gratuity'], 'Limited Contract');
      expect(body['workingHours'], 8);
      expect(body['basicSalary'], 3000);
      expect(body['transportation'], 500);
      expect(body['accommodation'], 1000);

      final login = (body['login'] as Map).cast<String, dynamic>();
      expect(login.keys.toSet(), {
        'enabled',
        'loginId',
        'mobileNo',
        'password',
        'branchIds',
      });
      expect(login['enabled'], isTrue);
      expect(login['loginId'], 'qa@example.com');
      expect(login['mobileNo'], '0500000000');
      expect(login['branchIds'], isEmpty);
      expect(login.containsKey('userType'), isFalse);

      expect(dataSource.createCalls, 1);
      expect(dataSource.getCalls, 1);
    },
  );

  test(
    'create with empty contacts sends null and omits disabled login',
    () async {
      dataSource.onCreate = (_) async => Success(
        employeeDto({
          'employeeId': 7,
          'employeeCode': 'EMP-7',
          'employeeName': 'No Contacts',
          'statusId': 2,
        }),
      );
      dataSource.onGet = (_) async =>
          const Failed(Failure(code: 'offline', kind: FailureKind.offline));

      await repository.saveEmployee(
        context,
        const EmployeeDraft(
          firstName: 'No Contacts',
          status: EmploymentStatus.inactive,
        ),
      );
      final body = dataSource.lastCreateBody!;
      expect(body['email'], isNull);
      expect(body['uaeContactNumber'], isNull);
      expect(body.containsKey('login'), isFalse);
      expect(body['statusId'], 2);
    },
  );

  test('full-replace update keeps loaded fields and overlays edits', () async {
    final detail = employeeFixture('employee_detail.json');
    dataSource.onGet = (_) async => Success(employeeDto(detail));
    dataSource.onUpdate = (id, body) async =>
        Success(employeeDto({...body, 'employeeId': id}));

    final result = await repository.saveEmployee(
      context,
      EmployeeDraft(
        firstName: 'Edited Name',
        email: 'edited@example.com',
        phone: '',
        departmentId: '2',
        designationId: 'Lead',
        joiningDate: DateTime(2026, 10, 1),
        status: EmploymentStatus.inactive,
        loginEnabled: false,
      ),
      id: '15',
    );
    expect(result, isA<Success<Employee>>());
    expect(dataSource.lastUpdateId, 15);

    final body = dataSource.lastUpdateBody!;
    expect(body['employeeName'], 'Edited Name');
    expect(body['departmentId'], 2);
    expect(body['designation'], 'Lead');
    expect(body['joiningDate'], '2026-10-01');
    expect(body['email'], 'edited@example.com');
    expect(body['uaeContactNumber'], isNull);
    expect(body['statusId'], 2);

    for (final key in detail.keys) {
      expect(
        body.containsKey(key),
        isTrue,
        reason: 'dropped loaded field $key',
      );
    }
    expect(body['employeeCode'], 'EMP-15');
    expect(body['branchId'], 1);
    expect(body['branchName'], 'Mass Technologies');
    expect(body['nationalityId'], 99);
    expect(body['dateOfBirth'], '1995-05-20');
    expect(body['maritalStatus'], 'Single');
    expect(body['gratuity'], 'Limited Contract');
    expect(body['workingHours'], 8);
    expect(body['basicSalary'], 3000);
    expect(body['transportation'], 500);
    expect(body['accommodation'], 1000);
    expect(body['totalSalary'], 4500);
    expect(body['ticket'], 0);

    final login = (body['login'] as Map).cast<String, dynamic>();
    final loadedLogin = (detail['login'] as Map).cast<String, dynamic>();
    expect(login.containsKey('userType'), isFalse);
    expect(login['enabled'], isFalse);
    expect(login['loginId'], loadedLogin['loginId']);
    expect(login['mobileNo'], loadedLogin['mobileNo']);
    expect(login['branchIds'], loadedLogin['branchIds']);
    expect(login['userId'], loadedLogin['userId']);
  });

  test('activate and deactivate use the matching endpoint selection', () async {
    await repository.setActive(context, '15', true);
    expect(dataSource.setActiveCalls, 1);
    expect(dataSource.lastSetActiveId, 15);
    expect(dataSource.lastActive, isTrue);

    await repository.setActive(context, '15', false);
    expect(dataSource.setActiveCalls, 2);
    expect(dataSource.lastActive, isFalse);
  });

  test('a successful write bumps the revision for active watchers', () async {
    dataSource.onList =
        (
          search,
          statusId,
          departmentId,
          branchId,
          sort,
          page,
          pageSize,
        ) async => Success(employeePage([]));
    final iterator = StreamIterator(repository.watchEmployees(context));
    expect(await iterator.moveNext(), isTrue);
    final callsBeforeWrite = dataSource.listCalls;

    await repository.setActive(context, '15', false);
    expect(await iterator.moveNext(), isTrue);
    expect(dataSource.listCalls, greaterThan(callsBeforeWrite));
    await iterator.cancel();
  });

  test(
    'availability checks report unsupported without a backend call',
    () async {
      final email = await repository.checkEmailAvailability(
        context,
        'qa@example.com',
      );
      final phone = await repository.checkPhoneAvailability(
        context,
        '0500000000',
      );
      expect((email as Failed<bool>).failure.code, 'unsupported');
      expect(email.failure.kind, FailureKind.notConfigured);
      expect((phone as Failed<bool>).failure.code, 'unsupported');
      expect(phone.failure.kind, FailureKind.notConfigured);
    },
  );

  test(
    'references expose backend departments, branches and nationalities',
    () async {
      final lookups = mapLookups(employeeFixture('employee_lookups.json'));
      dataSource.onLookups = () async => Success(lookups);

      final result = await repository.getReferences(context);
      final references = (result as Success<EmployeeReferences>).value;
      expect(references.departments.first.id, '2');
      expect(references.departments.first.name, 'accounts');
      expect(
        references.departments.map((d) => d.id),
        containsAll(['2', '7', '3', '1', '4']),
      );
      expect(references.branches.first.id, '2');
      expect(references.branches.first.name, 'Bitlogix');
      expect(references.branches, isNotEmpty);
      expect(references.nationalities, isNotEmpty);
      expect(references.nationalities.first.id, '240');
      expect(references.maritalStatuses, containsAll(['Single', 'Married']));
      expect(references.gratuityTypes, contains('Limited Contract'));
      expect(references.hasBackendProfileLookups, isTrue);
      expect(references.designations, isEmpty);
      expect(references.managers, isEmpty);
      expect(references.shifts, isEmpty);
      expect(references.workLocations, isEmpty);
      expect(references.attendancePolicies, isEmpty);
    },
  );

  test('update overlays the backend employment fields', () async {
    final detail = employeeFixture('employee_detail.json');
    dataSource.onGet = (_) async => Success(employeeDto(detail));
    dataSource.onUpdate = (id, body) async =>
        Success(employeeDto({...body, 'employeeId': id}));

    final result = await repository.saveEmployee(
      context,
      EmployeeDraft(
        firstName: 'Edited Name',
        email: 'edited@example.com',
        phone: '',
        departmentId: '2',
        designationId: 'Lead',
        joiningDate: DateTime(2026, 10, 1),
        status: EmploymentStatus.active,
        branchId: '2',
        nationalityId: '1',
        dateOfBirth: DateTime(1990, 1, 2),
        maritalStatus: 'Married',
        gratuity: 'Unlimited Contract',
        workingHours: 9,
        basicSalary: 4000,
        transportation: 600,
        accommodation: 1100,
      ),
      id: '15',
    );
    expect(result, isA<Success<Employee>>());

    final body = dataSource.lastUpdateBody!;
    expect(body['branchId'], 2);
    expect(body['nationalityId'], 1);
    expect(body['dateOfBirth'], '1990-01-02');
    expect(body['maritalStatus'], 'Married');
    expect(body['gratuity'], 'Unlimited Contract');
    expect(body['workingHours'], 9);
    expect(body['basicSalary'], 4000);
    expect(body['transportation'], 600);
    expect(body['accommodation'], 1100);
  });

  test('linked account maps login and credential readiness', () async {
    dataSource.onGet = (_) async =>
        Success(employeeDto(employeeFixture('employee_detail.json')));

    final result = await repository.getLinkedAccount(context, '15');
    final access = (result as Success<EmployeeAccountAccess?>).value!;
    expect(access.credentialPending, isFalse);
    expect(access.user.id, '31');
    expect(access.user.displayName, 'Sanitized Name');
    expect(access.user.email, 'sanitized@example.com');
    expect(access.user.phone, 'SANITIZED_PHONE');
    expect(access.user.companyId, '3');
    expect(access.user.permissions.values, isEmpty);
    expect(access.user.status, AccountStatus.active);
  });

  test(
    'linked account returns null without a login and flags pending',
    () async {
      dataSource.onGet = (_) async => Success(
        employeeDto({
          'employeeId': 30,
          'employeeCode': 'EMP-30',
          'employeeName': 'No Login',
          'statusId': 1,
        }),
      );
      final none = await repository.getLinkedAccount(context, '30');
      expect((none as Success<EmployeeAccountAccess?>).value, isNull);

      dataSource.onGet = (_) async => Success(
        employeeDto({
          'employeeId': 31,
          'employeeCode': 'EMP-31',
          'employeeName': 'Pending Login',
          'statusId': 1,
          'login': {
            'enabled': true,
            'canLogin': false,
            'userId': 77,
            'loginId': 'pending',
            'mobileNo': 'SANITIZED_PHONE',
          },
        }),
      );
      final pending = await repository.getLinkedAccount(context, '31');
      final access = (pending as Success<EmployeeAccountAccess?>).value!;
      expect(access.credentialPending, isTrue);
      expect(access.user.id, '77');
    },
  );

  test(
    'non-numeric ids are null for single lookups and skipped in batch',
    () async {
      final single = await repository.getEmployeeById(context, 'uuid');
      expect((single as Success<Employee?>).value, isNull);
      final batch = await repository.getCompanyEmployees(context, [
        'uuid',
        '15',
      ]);
      expect((batch as Success<List<Employee>>).value.single.id, '15');
    },
  );
}
