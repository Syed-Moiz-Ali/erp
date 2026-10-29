import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/modules/hr/shifts/data/dto/shift_dtos.dart';

Map<String, dynamic> load(String name) =>
    jsonDecode(File('test/fixtures/shifts/$name').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('shift list keeps paging, times and overnight flags', () {
    final envelope = load('shifts_list.json');
    expect(envelope['message'], 'Shifts retrieved.');
    final data = envelope['data'] as Map<String, dynamic>;
    expect(data['page'], 1);
    expect(data['pageSize'], 25);
    expect(data['totalItems'], 25);
    final shifts = [
      for (final item in data['items'] as List)
        ShiftDto.fromJson((item as Map).cast<String, dynamic>()),
    ];
    expect(shifts, hasLength(25));
    expect(shifts.any((shift) => shift.crossesMidnight), isTrue);
    expect(
      shifts.every(
        (shift) => shift.startTime.length == 8 && shift.endTime.length == 8,
      ),
      isTrue,
    );
    expect(shifts.any((shift) => shift.activeAssignments > 0), isTrue);
  });

  test('shift detail parses duration, windows and timestamps', () {
    final detail = ShiftDto.fromJson(
      (load('shift_detail.json')['data'] as Map).cast(),
    );
    expect(detail.shiftId, 25);
    expect(detail.durationMinutes, 1320);
    expect(detail.crossesMidnight, isTrue);
    expect(detail.punchInOpensAt, '07:45:00');
    expect(detail.earlyPunchInMinutes, 15);
    expect(detail.lateGraceMinutes, 15);
    expect(detail.statusId, 1);
    expect(detail.createdOn, isNotNull);
    expect(detail.modifiedOn, isNull);
  });

  test('shift 404 and employee 403 envelopes are explicit', () {
    final notFound = load('shift_not_found.json');
    expect((notFound['errors'] as List).single['code'], 'SHIFT_NOT_FOUND');
    final forbidden = load('shifts_forbidden_employee.json');
    expect((forbidden['errors'] as List).single['code'], 'ACCESS_DENIED');
  });

  test('shift write body keeps documented field names', () {
    final body = ShiftUpsertDto(
      shiftName: 'QA Shift',
      startTime: '09:00',
      endTime: '12:00',
      earlyPunchInMinutes: 15,
      lateGraceMinutes: 15,
    ).toJson();
    expect(
      body.keys,
      containsAll([
        'shiftName',
        'startTime',
        'endTime',
        'earlyPunchInMinutes',
        'lateGraceMinutes',
      ]),
    );
  });
}
