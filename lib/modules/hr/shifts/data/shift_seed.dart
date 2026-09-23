import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';
import 'local_shift_repository.dart';
import 'package:modular_erp/core/utils/local_time.dart';

Future<void> seedShifts(AppDatabase db, AuthContext context) async {
  final repository = LocalShiftRepository(db);

  final definitions = [
    ('shift-general', 'General Shift', 'GENERAL', 9, 18),
    ('shift-morning', 'Morning Shift', 'MORNING', 6, 15),
    ('shift-evening', 'Evening Shift', 'EVENING', 14, 23),
    ('shift-night', 'Night Shift', 'NIGHT', 22, 7),
  ];
  for (final d in definitions) {
    if (await repository.raw(context, d.$1) != null) continue;
    final draft = ShiftDraft(
      name: d.$2,
      code: d.$3,
      startTime: LocalTime(hour: d.$4, minute: 0),
      endTime: LocalTime(hour: d.$5, minute: 0),
      workingDays: {
        WorkingDay.monday,
        WorkingDay.tuesday,
        WorkingDay.wednesday,
        WorkingDay.thursday,
        WorkingDay.friday,
      },
      gracePeriodMinutes: 10,
    );
    final record = repository
        .createRecord(context, draft, id: d.$1, now: DateTime.utc(2026))
        .copyWith(syncStatus: RecordSyncStatus.synced);
    await repository.unique(record);
    await repository.put(record);
  }
}
