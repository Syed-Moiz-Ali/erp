import 'package:drift/drift.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/data/local_configuration_repository.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy_repository.dart';

class LocalAttendancePolicyRepository
    extends
        LocalConfigurationRepository<AttendancePolicy, AttendancePolicyDraft>
    implements AttendancePolicyRepository {
  LocalAttendancePolicyRepository(super.db);
  @override
  String get tableName => 'attendance_policy_records';
  @override
  String get featureId => 'attendance_policies';
  @override
  String get employeeColumn => 'attendance_policy_id';
  @override
  AppPermission get viewPermission => AppPermission.attendancePolicyView;
  @override
  AppPermission get managePermission => AppPermission.attendancePolicyManage;
  @override
  ResultSetImplementation get table => db.attendancePolicyRecords;
  @override
  List<String> get searchColumns => ['name', 'description'];
  @override
  AttendancePolicyDraft normalize(AttendancePolicyDraft draft) =>
      draft.normalized();
  @override
  Map<String, String> validate(AttendancePolicyDraft draft) => draft.validate();
  @override
  AttendancePolicy readRow(QueryRow r) => AttendancePolicy(
    id: r.read('id'),
    companyId: r.read('company_id'),
    name: r.read('name'),
    status: ConfigurationStatus.values.byName(r.read('status')),
    createdAt: r.read<DateTime>('created_at').toUtc(),
    updatedAt: r.read<DateTime>('updated_at').toUtc(),
    syncStatus: RecordSyncStatus.values.byName(r.read('sync_status')),
    description: r.read<String>('description'),
    requireLocation: r.read<bool>('require_location'),
    allowOutsideLocation: r.read<bool>('allow_outside_location'),
    allowRemoteAttendance: r.read<bool>('allow_remote_attendance'),
    requireLocationOnPunchIn: r.read<bool>('require_location_on_punch_in'),
    requireLocationOnPunchOut: r.read<bool>('require_location_on_punch_out'),
    requireLocationOnBreak: r.read<bool>('require_location_on_break'),
    requireLocationAccuracy: r.read<bool>('require_location_accuracy'),
    maximumAcceptedAccuracyMeters: r.readNullable<double>(
      'maximum_accepted_accuracy_meters',
    ),
    trackBreaks: r.read<bool>('track_breaks'),
    allowMultipleBreaks: r.read<bool>('allow_multiple_breaks'),
    allowPunchOutDuringBreak: r.read<bool>('allow_punch_out_during_break'),
    allowEmployeeCorrectionRequest: r.read<bool>(
      'allow_employee_correction_request',
    ),
    allowEarlyPunchIn: r.read<bool>('allow_early_punch_in'),
    earlyPunchInLimitMinutes: r.readNullable<int>(
      'early_punch_in_limit_minutes',
    ),
    allowLatePunchIn: r.read<bool>('allow_late_punch_in'),
    allowEarlyPunchOut: r.read<bool>('allow_early_punch_out'),
    offlineMode: OfflineAttendanceMode.values.byName(
      r.read<String>('offline_mode'),
    ),
  );
  @override
  AttendancePolicy createRecord(
    AuthContext context,
    AttendancePolicyDraft d, {
    required String id,
    AttendancePolicy? previous,
    required DateTime now,
  }) => AttendancePolicy(
    id: id,
    companyId: context.company.id,
    name: d.name,
    status: d.status,
    createdAt: previous?.createdAt ?? now,
    updatedAt: now,
    syncStatus: RecordSyncStatus.pending,
    description: d.description,
    requireLocation: d.requireLocation,
    allowOutsideLocation: d.allowOutsideLocation,
    allowRemoteAttendance: d.allowRemoteAttendance,
    requireLocationOnPunchIn: d.requireLocationOnPunchIn,
    requireLocationOnPunchOut: d.requireLocationOnPunchOut,
    requireLocationOnBreak: d.requireLocationOnBreak,
    requireLocationAccuracy: d.requireLocationAccuracy,
    maximumAcceptedAccuracyMeters: d.maximumAcceptedAccuracyMeters,
    trackBreaks: d.trackBreaks,
    allowMultipleBreaks: d.allowMultipleBreaks,
    allowPunchOutDuringBreak: d.allowPunchOutDuringBreak,
    allowEmployeeCorrectionRequest: d.allowEmployeeCorrectionRequest,
    allowEarlyPunchIn: d.allowEarlyPunchIn,
    earlyPunchInLimitMinutes: d.earlyPunchInLimitMinutes,
    allowLatePunchIn: d.allowLatePunchIn,
    allowEarlyPunchOut: d.allowEarlyPunchOut,
    offlineMode: d.offlineMode,
  );
  @override
  AttendancePolicy withStatus(
    AttendancePolicy record,
    ConfigurationStatus status,
    DateTime now,
  ) => record.copyWith(
    status: status,
    updatedAt: now,
    syncStatus: RecordSyncStatus.pending,
  );
  @override
  Future<void> put(AttendancePolicy e) async {
    await db
        .into(db.attendancePolicyRecords)
        .insertOnConflictUpdate(
          AttendancePolicyRecordsCompanion.insert(
            id: e.id,
            companyId: e.companyId,
            name: e.name,
            normalizedName: normalizedName(e.name),
            status: e.status.name,
            createdAt: e.createdAt,
            updatedAt: e.updatedAt,
            syncStatus: e.syncStatus.name,
            description: Value(e.description),
            requireLocation: e.requireLocation,
            allowOutsideLocation: e.allowOutsideLocation,
            allowRemoteAttendance: e.allowRemoteAttendance,
            requireLocationOnPunchIn: e.requireLocationOnPunchIn,
            requireLocationOnPunchOut: e.requireLocationOnPunchOut,
            requireLocationOnBreak: e.requireLocationOnBreak,
            requireLocationAccuracy: e.requireLocationAccuracy,
            maximumAcceptedAccuracyMeters: Value(
              e.maximumAcceptedAccuracyMeters,
            ),
            trackBreaks: e.trackBreaks,
            allowMultipleBreaks: e.allowMultipleBreaks,
            allowPunchOutDuringBreak: e.allowPunchOutDuringBreak,
            allowEmployeeCorrectionRequest: e.allowEmployeeCorrectionRequest,
            allowEarlyPunchIn: e.allowEarlyPunchIn,
            earlyPunchInLimitMinutes: Value(e.earlyPunchInLimitMinutes),
            allowLatePunchIn: e.allowLatePunchIn,
            allowEarlyPunchOut: e.allowEarlyPunchOut,
            offlineMode: e.offlineMode.name,
          ),
        );
  }
}
