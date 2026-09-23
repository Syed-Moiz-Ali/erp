import 'package:modular_erp/core/errors/result.dart';
import 'attendance_correction.dart';

abstract interface class AttendanceCorrectionRepository {
  Stream<Result<List<AttendanceCorrectionRequest>>> watchMyRequests();
  Stream<Result<List<AttendanceCorrectionRequest>>> watchPendingRequests();
  Future<Result<AttendanceCorrectionRequest?>> getRequestById(String id);
  Future<Result<AttendanceCorrectionRequest>> createRequest(
    AttendanceCorrectionRequest request,
  );
  Future<Result<void>> cancelRequest(String id);
  Future<Result<AttendanceCorrectionRequest>> approveRequest(
    String id, {
    required String reviewerId,
    String? note,
  });
  Future<Result<AttendanceCorrectionRequest>> rejectRequest(
    String id, {
    required String reviewerId,
    required String note,
  });
}
