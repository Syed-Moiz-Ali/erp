import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/hr/departments/data/department_mapper.dart';

import 'support/department_test_doubles.dart';

void main() {
  test('maps a DTO to a domain department with a stable integer-string id', () {
    final department = DepartmentMapper.toDomain(
      departmentDto(7, 'Sales', employeeCount: 3),
      companyId: '3',
    );
    expect(department.id, '7');
    expect(department.companyId, '3');
    expect(department.name, 'Sales');
    expect(department.status, ConfigurationStatus.active);
    expect(department.syncStatus, RecordSyncStatus.synced);
  });

  test('identity is stable and never regenerated across fetches', () {
    final first = DepartmentMapper.toDomain(
      departmentDto(7, 'Sales'),
      companyId: '3',
    );
    final second = DepartmentMapper.toDomain(
      departmentDto(7, 'Sales'),
      companyId: '3',
    );
    expect(first.id, second.id);
    expect(first, second);
  });

  test('company scoping is applied by the caller', () {
    final department = DepartmentMapper.toDomain(
      departmentDto(1, 'A'),
      companyId: '99',
    );
    expect(department.companyId, '99');
  });

  test('parseId reads backend ids and rejects local demo ids', () {
    expect(DepartmentMapper.parseId('12'), 12);
    expect(DepartmentMapper.parseId('dept-0'), isNull);
    expect(DepartmentMapper.parseId(''), isNull);
  });
}
