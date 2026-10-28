import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift.dart';

void main() {
  test('assignment draft validates required fields and date order', () {
    const draft = EmployeeShiftDraft(fromDate: '2026-11-02', toDate: '2026-11-01');
    final errors = draft.validate();
    expect(errors['employeeId'], 'required');
    expect(errors['shiftId'], 'required');
    expect(errors['toDate'], 'range');
  });

  test('assignment body sends timezone only when supplied', () {
    const withZone = EmployeeShiftDraft(
      employeeId: 29,
      shiftId: 1,
      fromDate: '2026-11-01',
      toDate: '2026-11-02',
      timeZoneId: 'Asia/Dubai',
    );
    expect(withZone.toBody(), {
      'employeeId': 29,
      'shiftId': 1,
      'fromDate': '2026-11-01',
      'toDate': '2026-11-02',
      'timeZoneId': 'Asia/Dubai',
    });
    const without = EmployeeShiftDraft(
      employeeId: 29,
      shiftId: 1,
      fromDate: '2026-11-01',
      toDate: '2026-11-02',
    );
    expect(without.toBody(includeEmployee: false).containsKey('timeZoneId'), isFalse);
  });
}
