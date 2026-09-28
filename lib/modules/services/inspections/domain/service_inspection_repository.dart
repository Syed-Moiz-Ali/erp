import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'service_inspection.dart';

/// Service Inspection persistence contract.
///
/// Reads require `services.inspections.view` **and** a record scope
/// (ASSIGNED/TEAM/ALL); mutations require the matching action permission. The
/// restricted Job Assignment reference lookup is authorized by Inspection
/// Create/Edit, never by broad Job Assignment management.
abstract interface class ServiceInspectionRepository {
  Stream<Result<ServiceInspectionPage>> watchInspections(
    AuthContext context, {
    String query = '',
    ServiceInspectionStatus? status,
    String? technicianEmployeeId,
    String? rootCauseId,
    String? priorityId,
    DateTime? visitFrom,
    DateTime? visitTo,
    int page = 0,
    int pageSize = 10,
  });

  Stream<Result<ServiceInspectionView?>> watchInspection(
    AuthContext context,
    String id,
  );

  Future<Result<ServiceInspectionView?>> getInspection(
    AuthContext context,
    String id,
  );

  /// Idempotent create: reusing [requestId] returns the existing inspection.
  Future<Result<ServiceInspection>> createInspection(
    AuthContext context,
    ServiceInspectionDraft draft, {
    String? requestId,
  });

  Future<Result<ServiceInspection>> updateInspection(
    AuthContext context,
    String id,
    ServiceInspectionDraft draft, {
    String? requestId,
  });

  Future<Result<ServiceInspection>> completeInspection(
    AuthContext context,
    String id, {
    String? requestId,
  });

  Future<Result<void>> cancelInspection(
    AuthContext context,
    String id, {
    String? requestId,
  });

  /// Restricted eligible Job Assignment reference search for the selector.
  Future<Result<List<ServiceAssignableJobAssignmentRef>>>
  searchEligibleJobAssignments(
    AuthContext context, {
    String query = '',
    int limit = 30,
  });

  /// Source context (customer/site/classification, work lines, eligible
  /// technicians, scheduled visit date) for the selected Job Assignment.
  Future<Result<ServiceInspectionSourceContext?>> getSourceContext(
    AuthContext context,
    String jobAssignmentId,
  );

  Future<Result<ServiceInspectionRef?>> getInspectionForAssignment(
    AuthContext context,
    String jobAssignmentId,
  );

  Stream<Result<ServiceInspectionRef?>> watchInspectionForAssignment(
    AuthContext context,
    String jobAssignmentId,
  );

  Future<Result<ServiceInspectionSummary>> summary(AuthContext context);

  Stream<Result<List<ServiceInspectionListItem>>> watchRecentInspections(
    AuthContext context, {
    int limit = 5,
  });
}

/// Lightweight Inspection reference for the Job Assignment detail integration.
class ServiceInspectionRef {
  const ServiceInspectionRef({
    required this.id,
    required this.inspectionNumber,
    required this.status,
    required this.visitDate,
    this.visitMinutes,
    this.technicianName,
    this.rootCauseName,
  });
  final String id, inspectionNumber;
  final ServiceInspectionStatus status;
  final DateTime visitDate;
  final int? visitMinutes;
  final String? technicianName, rootCauseName;
}
