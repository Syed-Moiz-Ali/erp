import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'service_material_request.dart';

/// Service Material Request persistence contract.
///
/// Reads require `services.materialRequests.view` **and** a record scope
/// (ASSIGNED/TEAM/ALL); mutations require the matching action permission. The
/// restricted eligible Inspection reference lookup is authorized by Material
/// Request Create, never by broad Inspection management.
abstract interface class ServiceMaterialRequestRepository {
  Stream<Result<ServiceMaterialRequestPage>> watchRequests(
    AuthContext context, {
    String query = '',
    ServiceMaterialRequestStatus? status,
    String? purposeId,
    String? inspectionId,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 0,
    int pageSize = 10,
  });

  Stream<Result<ServiceMaterialRequestView?>> watchRequest(
    AuthContext context,
    String id,
  );

  Future<Result<ServiceMaterialRequestView?>> getRequest(
    AuthContext context,
    String id,
  );

  /// Idempotent create: reusing [requestId] returns the existing request and
  /// does not duplicate lines or repeat the WAITING → REQUESTED transitions.
  Future<Result<ServiceMaterialRequest>> createRequest(
    AuthContext context,
    ServiceMaterialRequestDraft draft, {
    String? requestId,
  });

  Future<Result<ServiceMaterialRequest>> updateRequest(
    AuthContext context,
    String id,
    ServiceMaterialRequestDraft draft, {
    String? requestId,
  });

  Future<Result<void>> cancelRequest(
    AuthContext context,
    String id, {
    String? requestId,
  });

  /// Restricted eligible completed-Inspection reference search for the selector.
  Future<Result<List<ServiceEligibleInspectionRef>>> searchEligibleInspections(
    AuthContext context, {
    String query = '',
    int limit = 30,
  });

  /// Source context (customer/site snapshot, classification, inherited material
  /// received and WAITING material requirements) for the selected Inspection.
  Future<Result<ServiceMaterialRequestSourceContext?>> getSourceContext(
    AuthContext context,
    String inspectionId,
  );

  /// Material requests recorded against an Inspection (detail integration).
  Future<Result<List<ServiceMaterialRequestRef>>> getRequestsForInspection(
    AuthContext context,
    String inspectionId,
  );

  Stream<Result<List<ServiceMaterialRequestRef>>> watchRequestsForInspection(
    AuthContext context,
    String inspectionId,
  );

  Future<Result<ServiceMaterialRequestSummary>> summary(AuthContext context);

  Stream<Result<List<ServiceMaterialRequestListItem>>> watchRecentRequests(
    AuthContext context, {
    int limit = 5,
  });
}
