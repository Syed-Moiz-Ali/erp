import '../../../core/database/app_database.dart';
import '../../../core/models/configuration_record.dart';
import '../../auth/domain/entities/auth_context.dart';
import '../domain/work_location.dart';
import 'local_work_location_repository.dart';

Future<void> seedWorkLocations(AppDatabase db, AuthContext context) async {
  final repository = LocalWorkLocationRepository(db);

  final definitions = [
    (
      'location-hyderabad',
      'Hyderabad HQ',
      'HQ',
      'Tolichowki Road',
      17.385044,
      78.486671,
      150.0,
    ),
    (
      'location-service',
      'Service Center',
      'SERVICE',
      'Jubilee Hills Road',
      17.4077,
      78.4418,
      200.0,
    ),
  ];
  for (final d in definitions) {
    if (await repository.raw(context, d.$1) != null) continue;
    final draft = WorkLocationDraft(
      name: d.$2,
      code: d.$3,
      addressLine1: d.$4,
      city: 'Hyderabad',
      stateRegion: 'Telangana',
      countryCode: 'IN',
      latitude: d.$5,
      longitude: d.$6,
      allowedRadiusMeters: d.$7,
      maximumAccuracyMeters: 50,
    );
    final record = repository
        .createRecord(context, draft, id: d.$1, now: DateTime.utc(2026))
        .copyWith(syncStatus: RecordSyncStatus.synced);
    await repository.unique(record);
    await repository.put(record);
  }
}
