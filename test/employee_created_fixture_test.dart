import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/modules/hr/employees/live/data/dto/live_employee_dtos.dart';

void main() {
  final envelope =
      jsonDecode(
            File(
              'test/fixtures/employees/employee_created.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final data = (envelope['data'] as Map).cast<String, dynamic>();

  test('maps the real create response without deriving id or code', () {
    final employee = LiveEmployeeDto.fromJson(data).toDomain();
    expect(employee.id, 1032);
    expect(employee.code, 'EMP-33');
    expect(employee.name, 'Sanitized Name');
    expect(employee.branchName, 'Mass Technologies');
    expect(employee.departmentName, 'technainc');
    expect(employee.nationalityName, 'INDIA');
    expect(employee.statusName, 'Active');
    expect(employee.designation, 'Technician');
    expect(employee.reportingManager, isNull);
    expect(employee.joiningDate, '2026-09-01');
    expect(employee.resignationDate, isNull);
    expect(employee.organization, isNull);
    expect(employee.ticket, 0);
    expect(employee.genderBloodGroup, isNull);
    expect(employee.uaeAddress, isNull);
    expect(employee.bankName, isNull);
    expect(employee.accountNumber, isNull);
    expect(employee.passportNumber, isNull);
    expect(employee.emiratesId, isNull);
    expect(employee.visaUidNumber, isNull);
    expect(employee.workPermitNumber, isNull);
    expect(employee.insuranceNumber, isNull);
    expect(employee.photoPath, isNull);
    expect(employee.basicSalary, 3000);
    expect(employee.transportation, 500);
    expect(employee.accommodation, 1000);
    expect(employee.totalSalary, 4500);
  });

  test(
    'maps every login field including startDate, status and branchNames',
    () {
      final employee = LiveEmployeeDto.fromJson(data).toDomain();
      expect(employee.loginEnabled, isTrue);
      expect(employee.canLogin, isTrue);
      expect(employee.loginUserId, 31);
      expect(employee.loginId, 'sanitized@example.com');
      expect(employee.loginMobile, 'SANITIZED_PHONE');
      expect(employee.loginStatus, 'Active');
      expect(employee.loginStartDate, '2026-09-30');
      expect(employee.loginBranchIds, [1]);
      expect(employee.loginBranchNames, 'Mass Technologies');
      expect(employee.loginBranchNames, isA<String>());
    },
  );

  test('create fixture still tolerates an optional userType', () {
    final login = (data['login'] as Map).cast<String, dynamic>();
    expect(login['userType'], 'Sales');
    expect(LiveEmployeeDto.fromJson(data).toDomain().loginId, login['loginId']);
    final withoutType = <String, dynamic>{
      ...data,
      'login': {...login}..remove('userType'),
    };
    expect(
      LiveEmployeeDto.fromJson(withoutType).toDomain().loginId,
      'sanitized@example.com',
    );
  });
}
