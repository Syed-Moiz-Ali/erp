import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/models/configuration_record.dart';
import '../../../core/security/app_permission.dart';
import '../../../features/auth/domain/entities/auth_context.dart';
import '../../../shared/data/local_configuration_repository.dart';
import '../domain/shift.dart';
import '../domain/shift_repository.dart';
import '../../../core/utils/local_time.dart';

class LocalShiftRepository
    extends LocalConfigurationRepository<Shift, ShiftDraft>
    implements ShiftRepository {
  LocalShiftRepository(super.db);
  @override
  String get tableName => 'shift_records';
  @override
  String get featureId => 'shifts';
  @override
  String get employeeColumn => 'shift_id';
  @override
  AppPermission get viewPermission => AppPermission.shiftView;
  @override
  AppPermission get managePermission => AppPermission.shiftManage;
  @override
  ResultSetImplementation get table => db.shiftRecords;
  @override
  List<String> get searchColumns => ['name', 'code'];
  @override
  ShiftDraft normalize(ShiftDraft draft) => draft.normalized();
  @override
  Map<String, String> validate(ShiftDraft draft) => draft.validate();
  @override
  Shift readRow(QueryRow r) => Shift(
    id: r.read('id'),
    companyId: r.read('company_id'),
    name: r.read('name'),
    status: ConfigurationStatus.values.byName(r.read('status')),
    createdAt: r.read<DateTime>('created_at').toUtc(),
    updatedAt: r.read<DateTime>('updated_at').toUtc(),
    syncStatus: RecordSyncStatus.values.byName(r.read('sync_status')),
    code: r.readNullable<String>('code'),
    startTime: LocalTime.fromMinutes(r.read<int>('start_minutes')),
    endTime: LocalTime.fromMinutes(r.read<int>('end_minutes')),
    workingDays: WorkingDay.values
        .where(
          (d) =>
              (r.read<int>('working_day_mask') & (1 << (d.isoWeekday - 1))) !=
              0,
        )
        .toSet(),
    gracePeriodMinutes: r.read<int>('grace_period_minutes'),
    breakMode: ShiftBreakMode.values.byName(r.read<String>('break_mode')),
    defaultBreakMinutes: r.readNullable<int>('default_break_minutes'),
    minimumWorkMinutes: r.readNullable<int>('minimum_work_minutes'),
  );
  @override
  Shift createRecord(
    AuthContext context,
    ShiftDraft d, {
    required String id,
    Shift? previous,
    required DateTime now,
  }) => Shift(
    id: id,
    companyId: context.company.id,
    name: d.name,
    status: d.status,
    createdAt: previous?.createdAt ?? now,
    updatedAt: now,
    syncStatus: RecordSyncStatus.pending,
    code: d.code.isEmpty ? null : d.code,
    startTime: d.startTime!,
    endTime: d.endTime!,
    workingDays: d.workingDays,
    gracePeriodMinutes: d.gracePeriodMinutes,
    breakMode: d.breakMode,
    defaultBreakMinutes: d.defaultBreakMinutes,
    minimumWorkMinutes: d.minimumWorkMinutes,
  );
  @override
  Shift withStatus(Shift record, ConfigurationStatus status, DateTime now) =>
      record.copyWith(
        status: status,
        updatedAt: now,
        syncStatus: RecordSyncStatus.pending,
      );
  @override
  Future<void> put(Shift e) async {
    await db
        .into(db.shiftRecords)
        .insertOnConflictUpdate(
          ShiftRecordsCompanion.insert(
            id: e.id,
            companyId: e.companyId,
            name: e.name,
            normalizedName: normalizedName(e.name),
            status: e.status.name,
            createdAt: e.createdAt,
            updatedAt: e.updatedAt,
            syncStatus: e.syncStatus.name,
            code: Value(e.code),
            startMinutes: e.startTime.minutes,
            endMinutes: e.endTime.minutes,
            workingDayMask: e.workingDays.fold<int>(
              0,
              (mask, day) => mask | (1 << (day.isoWeekday - 1)),
            ),
            gracePeriodMinutes: e.gracePeriodMinutes,
            breakMode: e.breakMode.name,
            defaultBreakMinutes: Value(e.defaultBreakMinutes),
            minimumWorkMinutes: Value(e.minimumWorkMinutes),
          ),
        );
  }
}
