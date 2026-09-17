import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/models/configuration_record.dart';
import '../../../core/security/app_permission.dart';
import '../../../features/auth/domain/entities/auth_context.dart';
import '../../../shared/data/local_configuration_repository.dart';
import '../domain/work_location.dart';
import '../domain/work_location_repository.dart';

class LocalWorkLocationRepository
    extends LocalConfigurationRepository<WorkLocation, WorkLocationDraft>
    implements WorkLocationRepository {
  LocalWorkLocationRepository(super.db);
  @override
  String get tableName => 'work_location_records';
  @override
  String get featureId => 'work_locations';
  @override
  String get employeeColumn => 'work_location_id';
  @override
  AppPermission get viewPermission => AppPermission.workLocationView;
  @override
  AppPermission get managePermission => AppPermission.workLocationManage;
  @override
  ResultSetImplementation get table => db.workLocationRecords;
  @override
  List<String> get searchColumns => ['name', 'code', 'address_line1', 'city'];
  @override
  WorkLocationDraft normalize(WorkLocationDraft draft) => draft.normalized();
  @override
  Map<String, String> validate(WorkLocationDraft draft) => draft.validate();
  @override
  WorkLocation readRow(QueryRow r) => WorkLocation(
    id: r.read('id'),
    companyId: r.read('company_id'),
    name: r.read('name'),
    status: ConfigurationStatus.values.byName(r.read('status')),
    createdAt: r.read<DateTime>('created_at').toUtc(),
    updatedAt: r.read<DateTime>('updated_at').toUtc(),
    syncStatus: RecordSyncStatus.values.byName(r.read('sync_status')),
    code: r.readNullable<String>('code'),
    addressLine1: r.read<String>('address_line1'),
    addressLine2: r.read<String>('address_line2'),
    city: r.read<String>('city'),
    stateRegion: r.read<String>('state_region'),
    postalCode: r.read<String>('postal_code'),
    countryCode: r.read<String>('country_code'),
    latitude: r.read<double>('latitude'),
    longitude: r.read<double>('longitude'),
    allowedRadiusMeters: r.read<double>('allowed_radius_meters'),
    maximumAccuracyMeters: r.readNullable<double>('maximum_accuracy_meters'),
    validationMode: LocationValidationMode.values.byName(
      r.read<String>('validation_mode'),
    ),
  );
  @override
  WorkLocation createRecord(
    AuthContext context,
    WorkLocationDraft d, {
    required String id,
    WorkLocation? previous,
    required DateTime now,
  }) => WorkLocation(
    id: id,
    companyId: context.company.id,
    name: d.name,
    status: d.status,
    createdAt: previous?.createdAt ?? now,
    updatedAt: now,
    syncStatus: RecordSyncStatus.pending,
    code: d.code.isEmpty ? null : d.code,
    addressLine1: d.addressLine1,
    addressLine2: d.addressLine2,
    city: d.city,
    stateRegion: d.stateRegion,
    postalCode: d.postalCode,
    countryCode: d.countryCode,
    latitude: d.latitude!,
    longitude: d.longitude!,
    allowedRadiusMeters: d.allowedRadiusMeters!,
    maximumAccuracyMeters: d.maximumAccuracyMeters,
    validationMode: d.validationMode,
  );
  @override
  WorkLocation withStatus(
    WorkLocation record,
    ConfigurationStatus status,
    DateTime now,
  ) => record.copyWith(
    status: status,
    updatedAt: now,
    syncStatus: RecordSyncStatus.pending,
  );
  @override
  Future<void> put(WorkLocation e) async {
    await db
        .into(db.workLocationRecords)
        .insertOnConflictUpdate(
          WorkLocationRecordsCompanion.insert(
            id: e.id,
            companyId: e.companyId,
            name: e.name,
            normalizedName: normalizedName(e.name),
            status: e.status.name,
            createdAt: e.createdAt,
            updatedAt: e.updatedAt,
            syncStatus: e.syncStatus.name,
            code: Value(e.code),
            addressLine1: e.addressLine1,
            addressLine2: Value(e.addressLine2),
            city: e.city,
            stateRegion: Value(e.stateRegion),
            postalCode: Value(e.postalCode),
            countryCode: e.countryCode,
            latitude: e.latitude,
            longitude: e.longitude,
            allowedRadiusMeters: e.allowedRadiusMeters,
            maximumAccuracyMeters: Value(e.maximumAccuracyMeters),
            validationMode: e.validationMode.name,
          ),
        );
  }
}
