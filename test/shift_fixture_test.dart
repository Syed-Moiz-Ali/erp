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

  test('write fixtures parse through the real ShiftDto', () {
    final expectations =
        <String, ({int id, String name, int statusId, bool overnight})>{
          'shift_create_morning.json': (
            id: 1,
            name: 'Morning',
            statusId: 1,
            overnight: false,
          ),
          'shift_create_evening.json': (
            id: 2,
            name: 'Shift 2',
            statusId: 1,
            overnight: false,
          ),
          'shift_create_night.json': (
            id: 3,
            name: 'Shift 3',
            statusId: 1,
            overnight: true,
          ),
          'shift_update.json': (
            id: 1,
            name: 'Morning',
            statusId: 1,
            overnight: false,
          ),
          'shift_deactivate.json': (
            id: 1,
            name: 'Morning',
            statusId: 2,
            overnight: false,
          ),
          'shift_activate.json': (
            id: 1,
            name: 'Morning',
            statusId: 1,
            overnight: false,
          ),
        };
    for (final entry in expectations.entries) {
      final dto = ShiftDto.fromJson(
        (load(entry.key)['data'] as Map).cast<String, dynamic>(),
      );
      expect(dto.shiftId, entry.value.id, reason: entry.key);
      expect(dto.shiftName, entry.value.name, reason: entry.key);
      expect(dto.statusId, entry.value.statusId, reason: entry.key);
      expect(dto.crossesMidnight, entry.value.overnight, reason: entry.key);
      expect(dto.createdOn, isNotNull, reason: entry.key);
    }
  });

  test('error fixtures carry the documented codes and fields', () {
    final expectations = <String, ({String code, String? field})>{
      'shift_duplicate_name.json': (
        code: 'SHIFT_DUPLICATE_NAME',
        field: 'shiftName',
      ),
      'shift_validation_same_time.json': (
        code: 'VALIDATION_ERROR',
        field: 'endTime',
      ),
      'shift_in_use.json': (code: 'SHIFT_IN_USE', field: null),
      'shift_already_active.json': (code: 'SHIFT_ALREADY_ACTIVE', field: null),
      'shift_already_inactive.json': (
        code: 'SHIFT_ALREADY_INACTIVE',
        field: null,
      ),
      'shifts_unauthorized.json': (code: 'AUTH_UNAUTHORIZED', field: null),
    };
    for (final entry in expectations.entries) {
      final envelope = load(entry.key);
      expect(envelope['success'], isFalse, reason: entry.key);
      final error = (envelope['errors'] as List).single as Map;
      expect(error['code'], entry.value.code, reason: entry.key);
      expect(error['field'], entry.value.field, reason: entry.key);
    }
  });

  test('fixtures contain no secrets or PII', () {
    final files = Directory(
      'test/fixtures/shifts',
    ).listSync().whereType<File>().where((file) => file.path.endsWith('.json'));
    for (final file in files) {
      final text = file.readAsStringSync();
      expect(text.contains('@'), isFalse, reason: file.path);
      expect(
        RegExp(
          r'\b(bearer|token|secret|password|api[_-]?key|ngrok)\b',
          caseSensitive: false,
        ).hasMatch(text),
        isFalse,
        reason: file.path,
      );
      expect(RegExp(r'\b\d{10,}\b').hasMatch(text), isFalse, reason: file.path);
    }
  });
}
