import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/modules/hr/shifts/data/dto/shift_dtos.dart';

void main() {
  test('upsert request serializes the documented fields only', () {
    const request = ShiftUpsertDto(
      shiftName: 'Morning',
      startTime: '09:00',
      endTime: '12:00',
      earlyPunchInMinutes: 15,
      lateGraceMinutes: 10,
    );
    expect(request.toJson(), {
      'shiftName': 'Morning',
      'startTime': '09:00',
      'endTime': '12:00',
      'earlyPunchInMinutes': 15,
      'lateGraceMinutes': 10,
    });
  });

  test('decodes a shift with typed integers, times and status', () {
    final dto = ShiftDto.fromJson({
      'shiftId': 6,
      'shiftName': 'Night',
      'startTime': '19:00:00',
      'endTime': '02:00:00',
      'durationMinutes': 420,
      'crossesMidnight': true,
      'punchInOpensAt': '18:45:00',
      'earlyPunchInMinutes': 15,
      'lateGraceMinutes': 15,
      'statusId': 1,
      'status': 'Active',
      'activeAssignments': 3,
      'createdOn': '2026-10-01T12:10:00Z',
      'modifiedOn': null,
    });
    expect(dto.shiftId, 6);
    expect(dto.shiftName, 'Night');
    expect(dto.crossesMidnight, isTrue);
    expect(dto.activeAssignments, 3);
    expect(dto.createdOn?.isUtc, isTrue);
    expect(dto.modifiedOn, isNull);
  });

  test('tolerates absent optional fields with safe defaults', () {
    final dto = ShiftDto.fromJson({
      'shiftId': 1,
      'shiftName': 'Morning',
      'startTime': '09:00:00',
      'endTime': '12:00:00',
    });
    expect(dto.earlyPunchInMinutes, 15);
    expect(dto.lateGraceMinutes, 15);
    expect(dto.statusId, 1);
    expect(dto.activeAssignments, 0);
  });

  test('throws on missing required fields', () {
    expect(() => ShiftDto.fromJson({'shiftName': 'x'}), throwsA(anything));
  });

  test('round-trips through JSON', () {
    final dto = ShiftDto.fromJson({
      'shiftId': 1,
      'shiftName': 'a',
      'startTime': '09:00:00',
      'endTime': '12:00:00',
    });
    expect(
      ShiftDto.fromJson(jsonDecode(jsonEncode(dto)) as Map<String, dynamic>),
      dto,
    );
  });
}
