import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:modular_erp/core/models/configuration_record.dart';

part 'department.freezed.dart';
part 'department.g.dart';

/// A company department (HR configuration master).
///
/// The backend identifies departments by an integer; the domain carries that
/// value as its decimal string form so identity is stable across restarts and
/// is never reinterpreted as a UUID.
@freezed
abstract class Department with _$Department implements ConfigurationRecord {
  const Department._();
  // Freezed forwards this annotation to the generated concrete class.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory Department({
    required String id,
    required String companyId,
    required String name,
    @Default(ConfigurationStatus.active) ConfigurationStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(RecordSyncStatus.synced) RecordSyncStatus syncStatus,
  }) = _Department;

  factory Department.fromJson(Map<String, dynamic> json) =>
      _$DepartmentFromJson(json);
}

@freezed
abstract class DepartmentDraft with _$DepartmentDraft {
  const DepartmentDraft._();

  const factory DepartmentDraft({
    @Default('') String name,
    @Default(ConfigurationStatus.active) ConfigurationStatus status,
  }) = _DepartmentDraft;

  DepartmentDraft normalized() => copyWith(name: name.trim());

  /// Backend rule: `departmentName` is required, max 50 characters.
  Map<String, String> validate() {
    final errors = <String, String>{};
    final value = name.trim();
    if (value.isEmpty) {
      errors['name'] = 'required';
    } else if (value.length > 50) {
      errors['name'] = 'tooLong';
    }
    return Map.unmodifiable(errors);
  }

  factory DepartmentDraft.fromDepartment(Department department) =>
      DepartmentDraft(name: department.name, status: department.status);
}
