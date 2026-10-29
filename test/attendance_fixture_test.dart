import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/modules/hr/attendance/live/domain/attendance_day.dart';

Map<String, dynamic> load(String name) =>
    jsonDecode(File('test/fixtures/attendance/$name').readAsStringSync())
        as Map<String, dynamic>;

AttendanceDay day(String name) =>
    AttendanceDay((load(name)['data'] as Map).cast<String, dynamic>());

void main() {
  test('working day exposes state, actions, shifts and breaks', () {
    final today = day('today_working.json');
    expect(today.employeeId, 29);
    expect(today.date, '2026-10-28');
    expect(today.timeZone, 'Asia/Dubai');
    expect(today.state, 'working');
    expect(today.allowedActions, ['break', 'punchOut']);
    expect(today.currentShiftNo, 1);
    expect(today.nextShiftNo, 2);
    expect(today.workedMinutes, 120);
    expect(today.workedHours, 2);
    expect(today.breakMinutes, 15);
    expect(today.serverTime, '2026-10-28T11:27:08+05:30');
    expect(today.shifts, hasLength(2));

    final first = today.shifts.first;
    expect(first.shiftNo, 1);
    expect(first.timeZone, 'Asia/Dubai');
    expect(first.punchIn, contains('+05:30'));
    expect(first.punchOut, isNull);
    expect(first.lateMinutes, 7);
    expect(first.breaks.single.minutes, 15);
    expect(first.breaks.single.end, isNotNull);
  });

  test('completed day has no allowed actions and real punch-out', () {
    final today = day('today_completed.json');
    expect(today.state, 'completed');
    expect(today.allowedActions, isEmpty);
    expect(today.shifts.single.punchOut, contains('+05:30'));
  });

  test('no-shift day is a valid state, not an exception', () {
    final today = day('today_no_shift.json');
    expect(today.state, 'noShift');
    expect(today.allowedActions, isEmpty);
    expect(today.shifts, isEmpty);
    expect(today.currentShiftNo, isNull);
    expect(today.nextShiftNo, isNull);
  });

  test('day-complete and prerequisite errors keep codes', () {
    final complete = load('day_complete_error.json');
    expect((complete['errors'] as List).single['code'], 'DAY_COMPLETE');
    final noShift = load('no_shift_error.json');
    expect((noShift['errors'] as List).single['code'], 'ATTENDANCE_NO_SHIFT');
  });
}
