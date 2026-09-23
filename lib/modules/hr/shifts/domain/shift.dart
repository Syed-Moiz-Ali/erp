import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/utils/local_time.dart';
part 'shift.freezed.dart';
part 'shift.g.dart';

enum ShiftBreakMode { manualBreak, fixedBreak, noBreak }

@freezed
abstract class Shift with _$Shift implements ConfigurationRecord {
  const Shift._();
  // Freezed forwards this annotation to the generated concrete class.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory Shift({
    required String id,
    required String companyId,
    required String name,
    String? code,
    required LocalTime startTime,
    required LocalTime endTime,
    required Set<WorkingDay> workingDays,
    @Default(0) int gracePeriodMinutes,
    @Default(ShiftBreakMode.manualBreak) ShiftBreakMode breakMode,
    int? defaultBreakMinutes,
    int? minimumWorkMinutes,
    @Default(ConfigurationStatus.active) ConfigurationStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(RecordSyncStatus.pending) RecordSyncStatus syncStatus,
  }) = _Shift;
  bool get isOvernight => endTime.minutes < startTime.minutes;
  int get durationMinutes =>
      (endTime.minutes - startTime.minutes + 1440) % 1440;
  int get expectedWorkMinutes =>
      durationMinutes -
      (breakMode == ShiftBreakMode.fixedBreak ? defaultBreakMinutes ?? 0 : 0);
  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);
}

@freezed
abstract class ShiftDraft with _$ShiftDraft {
  const ShiftDraft._();
  const factory ShiftDraft({
    @Default('') String name,
    @Default('') String code,
    LocalTime? startTime,
    LocalTime? endTime,
    @Default(<WorkingDay>{}) Set<WorkingDay> workingDays,
    @Default(0) int gracePeriodMinutes,
    @Default(ShiftBreakMode.manualBreak) ShiftBreakMode breakMode,
    int? defaultBreakMinutes,
    int? minimumWorkMinutes,
    @Default(ConfigurationStatus.active) ConfigurationStatus status,
  }) = _ShiftDraft;
  ShiftDraft normalized() => copyWith(
    name: name.trim(),
    code: code.trim().toUpperCase(),
    defaultBreakMinutes: breakMode == ShiftBreakMode.fixedBreak
        ? defaultBreakMinutes
        : null,
  );
  Map<String, String> validate() {
    final errors = <String, String>{};
    if (name.trim().isEmpty) errors['name'] = 'required';
    if (startTime == null || !startTime!.isValid) {
      errors['startTime'] = 'invalidTimeRange';
    }
    if (endTime == null || !endTime!.isValid) {
      errors['endTime'] = 'invalidTimeRange';
    }
    if (workingDays.isEmpty) errors['workingDays'] = 'workingDays';
    final duration = startTime == null || endTime == null
        ? 0
        : (endTime!.minutes - startTime!.minutes + 1440) % 1440;
    if (duration == 0) errors['endTime'] = 'invalidTimeRange';
    if (gracePeriodMinutes < 0 ||
        duration > 0 && gracePeriodMinutes >= duration) {
      errors['gracePeriodMinutes'] = 'invalidGrace';
    }
    if (breakMode == ShiftBreakMode.fixedBreak &&
        (defaultBreakMinutes == null ||
            defaultBreakMinutes! < 0 ||
            defaultBreakMinutes! >= duration)) {
      errors['defaultBreakMinutes'] = 'invalidBreak';
    }
    final expected =
        duration -
        (breakMode == ShiftBreakMode.fixedBreak ? defaultBreakMinutes ?? 0 : 0);
    if (minimumWorkMinutes != null &&
        (minimumWorkMinutes! < 0 || minimumWorkMinutes! > expected)) {
      errors['minimumWorkMinutes'] = 'invalidMinimumWork';
    }
    return Map.unmodifiable(errors);
  }

  factory ShiftDraft.fromShift(Shift s) => ShiftDraft(
    name: s.name,
    code: s.code ?? '',
    startTime: s.startTime,
    endTime: s.endTime,
    workingDays: s.workingDays,
    gracePeriodMinutes: s.gracePeriodMinutes,
    breakMode: s.breakMode,
    defaultBreakMinutes: s.defaultBreakMinutes,
    minimumWorkMinutes: s.minimumWorkMinutes,
    status: s.status,
  );
}
