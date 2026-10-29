import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/api_endpoints.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/attendance/live/domain/attendance_day.dart';

class AttendanceApi {
  AttendanceApi(this._client);
  final ApiClient _client;

  Future<Result<AttendanceDay>> today() => _client.get<AttendanceDay>(
    ApiEndpoints.attendance.today,
    fromJson: (json) =>
        AttendanceDay((json as Map).cast<String, dynamic>()),
  );

  Future<Result<AttendanceDay>> punch(
    String action, {
    double? latitude,
    double? longitude,
  }) => _client.post<AttendanceDay>(
    ApiEndpoints.attendance.punch,
    body: {
      'action': action,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    },
    fromJson: (json) =>
        AttendanceDay((json as Map).cast<String, dynamic>()),
  );
}
