import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/utils/local_time.dart';
import 'package:modular_erp/modules/hr/shifts/data/shift_mapper.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';

import 'support/shift_test_doubles.dart';

void main() {
  test('maps a shift DTO to the domain with a stable integer-string id', () {
    final shift = ShiftMapper.toDomain(
      shiftDto(
        6,
        'Night',
        startTime: '19:00:00',
        endTime: '02:00:00',
        earlyPunchInMinutes: 20,
        lateGraceMinutes: 10,
        activeAssignments: 3,
      ),
      companyId: '3',
    );
    expect(shift.id, '6');
    expect(shift.companyId, '3');
    expect(shift.name, 'Night');
    expect(shift.startTime, const LocalTime(hour: 19, minute: 0));
    expect(shift.endTime, const LocalTime(hour: 2, minute: 0));
    expect(shift.isOvernight, isTrue);
    expect(shift.gracePeriodMinutes, 10); // backend lateGraceMinutes
    expect(shift.earlyPunchInMinutes, 20);
    // The backend exposes no working-day or break concept: all days / no break.
    expect(shift.workingDays, WorkingDay.values.toSet());
    expect(shift.breakMode, ShiftBreakMode.noBreak);
    expect(shift.syncStatus, RecordSyncStatus.synced);
  });

  test('maps inactive status from statusId 2', () {
    expect(
      ShiftMapper.toDomain(
        shiftDto(1, 'A', statusId: 2),
        companyId: '3',
      ).status,
      ConfigurationStatus.inactive,
    );
  });

  test('builds the documented upsert body from a draft', () {
    final request = ShiftMapper.toUpsert(
      const ShiftDraft(
        name: '  Morning  ',
        startTime: LocalTime(hour: 9, minute: 5),
        endTime: LocalTime(hour: 12, minute: 0),
        earlyPunchInMinutes: 30,
        gracePeriodMinutes: 10,
      ),
    );
    expect(request.shiftName, 'Morning');
    expect(request.startTime, '09:05');
    expect(request.endTime, '12:00');
    expect(request.earlyPunchInMinutes, 30);
    expect(request.lateGraceMinutes, 10);
  });

  test('parseId reads backend ids and rejects local demo ids', () {
    expect(ShiftMapper.parseId('12'), 12);
    expect(ShiftMapper.parseId('shift-morning'), isNull);
  });
}
