import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy.dart';
import 'local_attendance_policy_repository.dart';

Future<void> seedAttendancePolicies(AppDatabase db, AuthContext context) async {
  final repository = LocalAttendancePolicyRepository(db);

  final definitions = [
    (
      'policy-office',
      const AttendancePolicyDraft(
        name: 'Office Staff Policy',
        description:
            'Office attendance with location capture and tracked breaks.',
        requireLocationOnBreak: true,
        requireLocationAccuracy: true,
        maximumAcceptedAccuracyMeters: 50,
      ),
    ),
    (
      'policy-field',
      const AttendancePolicyDraft(
        name: 'Field Staff Policy',
        description: 'Location capture with outside-site attendance permitted.',
        allowOutsideLocation: true,
      ),
    ),
    (
      'policy-remote',
      const AttendancePolicyDraft(
        name: 'Remote Staff Policy',
        description: 'Remote attendance with tracked breaks.',
        requireLocation: false,
        allowRemoteAttendance: true,
      ),
    ),
  ];
  for (final d in definitions) {
    if (await repository.raw(context, d.$1) != null) continue;
    final record = repository
        .createRecord(
          context,
          d.$2.normalized(),
          id: d.$1,
          now: DateTime.utc(2026),
        )
        .copyWith(syncStatus: RecordSyncStatus.synced);
    await repository.unique(record);
    await repository.put(record);
  }
}
