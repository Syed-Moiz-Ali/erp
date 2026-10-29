import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/api_endpoints.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/attendance/live/domain/attendance_day.dart';

/// Small seam over the two self-service attendance endpoints so repositories
/// can be exercised with an in-memory fake and never touch the network in tests.
abstract interface class AttendanceApiClient {
  Future<Result<AttendanceDay>> today();
  Future<Result<AttendanceDay>> punch(
    String action, {
    double? latitude,
    double? longitude,
  });
}

class AttendanceApi implements AttendanceApiClient {
  AttendanceApi(this._client);
  final ApiClient _client;

  @override
  Future<Result<AttendanceDay>> today() => _client.get<AttendanceDay>(
    ApiEndpoints.attendance.today,
    fromJson: (json) => AttendanceDay((json as Map).cast<String, dynamic>()),
  );

  @override
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
    fromJson: (json) => AttendanceDay((json as Map).cast<String, dynamic>()),
  );
}
