import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/utils/local_time.dart';
import 'package:modular_erp/modules/hr/shifts/data/dto/shift_dtos.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';

/// Anti-corruption boundary between the MassERP shift contract and the app's
/// [Shift].
///
/// The backend models a shift as times plus an early punch-in window and a late
/// grace window; the local model additionally tracks working days and break
/// rules that the backend does not expose. Remote shifts therefore map working
/// days to every day and break rules to `noBreak`, and the backend-only
/// `earlyPunchInMinutes` is preserved on the domain so a remote update never
/// loses it.
abstract final class ShiftMapper {
  const ShiftMapper._();

  static final DateTime _sentinel = DateTime.fromMillisecondsSinceEpoch(
    0,
    isUtc: true,
  );

  static Shift toDomain(ShiftDto dto, {required String companyId}) => Shift(
    id: dto.shiftId.toString(),
    companyId: companyId,
    name: dto.shiftName,
    code: null,
    startTime: _parseTime(dto.startTime),
    endTime: _parseTime(dto.endTime),
    workingDays: WorkingDay.values.toSet(),
    gracePeriodMinutes: dto.lateGraceMinutes,
    earlyPunchInMinutes: dto.earlyPunchInMinutes,
    breakMode: ShiftBreakMode.noBreak,
    defaultBreakMinutes: null,
    minimumWorkMinutes: null,
    status: dto.statusId == 2
        ? ConfigurationStatus.inactive
        : ConfigurationStatus.active,
    createdAt: _sentinel,
    updatedAt: _sentinel,
    syncStatus: RecordSyncStatus.synced,
  );

  static ShiftUpsertDto toUpsert(ShiftDraft draft) => ShiftUpsertDto(
    shiftName: draft.name.trim(),
    startTime: _formatTime(draft.startTime!),
    endTime: _formatTime(draft.endTime!),
    earlyPunchInMinutes: draft.earlyPunchInMinutes,
    lateGraceMinutes: draft.gracePeriodMinutes,
  );

  /// Parses `HH:mm` / `HH:mm:ss` into a [LocalTime].
  static LocalTime _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length < 2) throw FormatException('Invalid time: $value');
    return LocalTime(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _formatTime(LocalTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  static int? parseId(String id) => int.tryParse(id);
}
