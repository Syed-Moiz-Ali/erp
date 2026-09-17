import '../core/database/app_database.dart';
import '../features/auth/data/datasources/local/demo_auth_source.dart';
import '../features/auth/domain/entities/auth_context.dart';
import '../features/shifts/data/shift_seed.dart';
import '../features/work_locations/data/work_location_seed.dart';
import '../features/attendance_policies/data/attendance_policy_seed.dart';

Future<void> seedAttendanceConfiguration(AppDatabase db) =>
    db.transaction(() async {
      final context = DemoAuthSource().accounts
          .firstWhere((a) => a.context.user.role == AppRole.superAdmin)
          .context;
      await seedShifts(db, context);
      await seedWorkLocations(db, context);
      await seedAttendancePolicies(db, context);
    });
