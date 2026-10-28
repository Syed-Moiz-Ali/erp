import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/modules/hr/attendance/live/domain/attendance_day.dart';

void main() {
  test('maps backend attendance states, server time and actions', () {
    final day = AttendanceDay(const {
      'employeeId': 29,
      'date': '2026-10-28',
      'timeZone': 'Asia/Kolkata',
      'state': 'working',
      'allowedActions': ['break', 'punchOut'],
      'workedMinutes': 12,
      'breakMinutes': 3,
      'serverTime': '2026-10-28T11:27:09+05:30',
      'shifts': [
        {
          'shiftNo': 1,
          'shiftName': 'Morning',
          'shiftDate': '2026-10-28',
          'plannedStart': '09:00:00',
          'plannedEnd': '12:00:00',
          'status': 'working',
          'punchIn': '2026-10-28T09:01:00+05:30',
          'crossesMidnight': false,
        },
      ],
    });
    expect(day.state, 'working');
    expect(day.timeZone, 'Asia/Kolkata');
    expect(day.allowedActions, ['break', 'punchOut']);
    expect(day.serverTime, endsWith('+05:30'));
    expect(day.shifts.single.shiftName, 'Morning');
    expect(day.shifts.single.punchIn, isNotNull);
  });
}
