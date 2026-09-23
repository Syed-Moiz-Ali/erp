import 'package:modular_erp/core/errors/result.dart';
import 'attendance_report_models.dart';

abstract interface class AttendanceReportRepository {
  Future<Result<DateTime>> companyToday();
  Future<Result<AttendanceReportOptions>> options(
    AttendanceReportFilter filter,
  );
  Future<Result<AttendanceReportData>> load(
    AttendanceReportFilter filter,
    AttendanceReportType type, {
    AttendanceReportSort sort = AttendanceReportSort.newest,
    int page = 0,
    int pageSize = 25,
  });
  Future<Result<AttendanceReportData>> exportData(
    AttendanceReportFilter filter,
    AttendanceReportType type, {
    AttendanceReportSort sort = AttendanceReportSort.newest,
  });
}
