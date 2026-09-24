import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/modules/hr/shifts/data/shift_seed.dart';
import 'package:modular_erp/modules/hr/work_locations/data/work_location_seed.dart';
import 'package:modular_erp/modules/hr/attendance_policies/data/attendance_policy_seed.dart';
import 'package:modular_erp/modules/hr/leave/data/leave_seed.dart';

Future<void> seedAttendanceConfiguration(AppDatabase db) =>
    db.transaction(() async {
      final context = DemoAuthSource()
          .findByScenario(DemoScenario.platformAdmin)!
          .context;
      await seedShifts(db, context);
      await seedWorkLocations(db, context);
      await seedAttendancePolicies(db, context);
      await seedLeaveConfiguration(db, context);
    });
