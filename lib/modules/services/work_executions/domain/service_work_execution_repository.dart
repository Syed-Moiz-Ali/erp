import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'service_work_execution.dart';

/// Service Work Execution persistence contract.
///
/// Reads require `services.workExecutions.view` **and** a record scope
/// (ASSIGNED/TEAM/ALL). Structural mutations require `edit`; operational
/// actions (start/end work, material used, after-work photos) require
/// `perform`; finalization requires `complete`; cancellation requires `cancel`.
/// The restricted eligible Inspection lookup is authorized by Work Execution
/// Create, never by broad Inspection management.
abstract interface class ServiceWorkExecutionRepository {
  Stream<Result<ServiceWorkExecutionPage>> watchExecutions(
    AuthContext context, {
    String query = '',
    ServiceWorkExecutionStatus? status,
    String? employeeId,
    String? teamId,
    String? inspectionId,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 0,
    int pageSize = 10,
  });

  Stream<Result<ServiceWorkExecutionView?>> watchExecution(
    AuthContext context,
    String id,
  );

  Future<Result<ServiceWorkExecutionView?>> getExecution(
    AuthContext context,
    String id,
  );

  /// Idempotent create: reusing [requestId] returns the existing execution.
  Future<Result<ServiceWorkExecution>> createExecution(
    AuthContext context,
    ServiceWorkExecutionDraft draft, {
    String? requestId,
  });

  /// Structural edit (header references + work lines). `edit` permission.
  Future<Result<ServiceWorkExecution>> updateExecution(
    AuthContext context,
    String id,
    ServiceWorkExecutionDraft draft, {
    String? requestId,
  });

  /// Operational: capture the start timestamp for an eligible line.
  Future<Result<ServiceWorkExecution>> startWorkLine(
    AuthContext context,
    String executionId,
    String lineId, {
    String? requestId,
  });

  /// Operational: capture the end timestamp for a started line.
  Future<Result<ServiceWorkExecution>> endWorkLine(
    AuthContext context,
    String executionId,
    String lineId, {
    String? requestId,
  });

  Future<Result<ServiceWorkExecution>> addMaterialUsed(
    AuthContext context,
    String executionId,
    ServiceWorkExecutionMaterialUsedDraft draft, {
    String? requestId,
  });

  Future<Result<ServiceWorkExecution>> removeMaterialUsed(
    AuthContext context,
    String executionId,
    String materialUsedId, {
    String? requestId,
  });

  Future<Result<ServiceWorkExecution>> addPhotoEntry(
    AuthContext context,
    String executionId,
    ServiceWorkExecutionPhotoEntryDraft draft, {
    String? requestId,
  });

  Future<Result<ServiceWorkExecution>> updatePhotoEntryDescription(
    AuthContext context,
    String executionId,
    String photoEntryId,
    String description, {
    String? requestId,
  });

  Future<Result<ServiceWorkExecution>> removePhotoEntry(
    AuthContext context,
    String executionId,
    String photoEntryId, {
    String? requestId,
  });

  Future<Result<ServiceWorkExecution>> completeExecution(
    AuthContext context,
    String id, {
    String? requestId,
  });

  Future<Result<ServiceWorkExecution>> cancelExecution(
    AuthContext context,
    String id, {
    String? requestId,
  });

  /// Restricted eligible Inspection reference search for the selector.
  Future<Result<List<ServiceWorkEligibleInspectionRef>>>
  searchEligibleInspections(
    AuthContext context, {
    String query = '',
    int limit = 30,
  });

  /// Read-only source context (customer/site/classification, job assignment
  /// lines, checklist, inspected points, material requirements and linked
  /// material requests) for the selected completed Inspection.
  Future<Result<ServiceWorkExecutionSourceContext?>> getSourceContext(
    AuthContext context,
    String inspectionId,
  );

  /// The active (non-cancelled) Work Execution for an Inspection, if any.
  Future<Result<ServiceWorkExecutionRef?>> getExecutionForInspection(
    AuthContext context,
    String inspectionId,
  );

  Stream<Result<ServiceWorkExecutionRef?>> watchExecutionForInspection(
    AuthContext context,
    String inspectionId,
  );

  /// The active Work Execution for a Job Assignment lineage, if any.
  Stream<Result<ServiceWorkExecutionRef?>> watchExecutionForAssignment(
    AuthContext context,
    String jobAssignmentId,
  );

  Future<Result<List<ServiceWorkExecutionRef>>> getExecutionsForEnquiry(
    AuthContext context,
    String enquiryId,
  );

  Future<Result<ServiceWorkExecutionSummary>> summary(AuthContext context);

  Stream<Result<List<ServiceWorkExecutionListItem>>> watchRecentExecutions(
    AuthContext context, {
    int limit = 5,
  });
}
