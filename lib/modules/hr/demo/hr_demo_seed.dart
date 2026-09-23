import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/hr/demo/demo_attendance_seed.dart';
import 'package:modular_erp/modules/hr/demo/demo_configuration_seed.dart';
import 'package:modular_erp/modules/hr/demo/demo_workforce_seed.dart';
import 'package:modular_erp/modules/hr/employees/data/employee_seed.dart';

/// Single HR demo-seed entry point. Global bootstrap only invokes this; HR owns
/// its own demo fixtures.
Future<void> seedHrDemoData(
  AppDatabase db, {
  AppClock clock = const SystemAppClock(),
  CompanyTimeService time = const FixedOffsetCompanyTimeService(),
}) async {
  await seedEmployees(db);
  await seedAttendanceConfiguration(db);
  await seedDemoAttendance(db, clock: clock, time: time);
  await seedDemoWorkforce(db, enabled: true, clock: clock, time: time);
}
