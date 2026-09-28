import 'package:drift/drift.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry_repository.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection_repository.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection_scope.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment_repository.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment_scope.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request_repository.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request_scope.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution_repository.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution_scope.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';

/// Read-model implementation assembled from the five existing transaction
/// repositories. Each stage re-checks its own permission/scope, so the timeline
/// can never expose a restricted transaction (Phase 7 §16, §56).
///
/// The repository is intentionally stateless: `watchChain`/`watchActivity`
/// recompute on any change to the underlying Services tables/activity, avoiding
/// fragile hand-rolled stream merging while keeping a constant number of queries
/// per evaluation (no N+1).
class LocalServiceWorkflowRepository implements ServiceWorkflowRepository {
  LocalServiceWorkflowRepository({
    required AppDatabase db,
    required ServiceEnquiryRepository enquiries,
    required ServiceJobAssignmentRepository jobAssignments,
    required ServiceInspectionRepository inspections,
    required ServiceMaterialRequestRepository materialRequests,
    required ServiceWorkExecutionRepository workExecutions,
    required ActivityRepository activity,
  }) : _db = db,
       _enquiries = enquiries,
       _jobAssignments = jobAssignments,
       _inspections = inspections,
       _materialRequests = materialRequests,
       _workExecutions = workExecutions,
       _activity = activity;

  final AppDatabase _db;
  final ServiceEnquiryRepository _enquiries;
  final ServiceJobAssignmentRepository _jobAssignments;
  final ServiceInspectionRepository _inspections;
  final ServiceMaterialRequestRepository _materialRequests;
  final ServiceWorkExecutionRepository _workExecutions;
  final ActivityRepository _activity;

  static const _materialRequirementTable =
      'service_inspection_material_requirements';

  Set<ResultSetImplementation> get _reads => {
    _db.serviceEnquiries,
    _db.serviceJobAssignments,
    _db.serviceJobAssignmentLines,
    _db.serviceInspections,
    _db.serviceInspectionMaterialRequirements,
    _db.serviceMaterialRequests,
    _db.serviceMaterialRequestLines,
    _db.serviceWorkExecutions,
    _db.serviceWorkExecutionLines,
    _db.businessActivityEvents,
  };

  Stream<void> _ticks() =>
      _db.customSelect('SELECT 1', readsFrom: _reads).watch().map((_) {});

  bool _can(AuthContext context, AppPermission permission) =>
      context.user.permissions.contains(permission);

  @override
  Stream<Result<ServiceWorkflowChain?>> watchChain(
    AuthContext context,
    String enquiryId, {
    ServiceWorkflowStage? focus,
  }) => _ticks().asyncMap((_) => loadChain(context, enquiryId, focus: focus));

  @override
  Future<Result<ServiceWorkflowChain?>> loadChain(
    AuthContext context,
    String enquiryId, {
    ServiceWorkflowStage? focus,
  }) async {
    try {
      final enquiryView = await _first<ServiceEnquiryView?>(
        _enquiries.watchEnquiry(context, enquiryId),
      );
      final assignmentRef = await _first<ServiceJobAssignmentRef?>(
        _jobAssignments.watchAssignmentForEnquiry(context, enquiryId),
      );

      ServiceInspectionRef? inspectionRef;
      var materialRequests = const <ServiceMaterialRequestRef>[];
      ServiceWorkExecutionRef? executionRef;
      var waitingMaterialCount = 0;
      if (assignmentRef != null) {
        inspectionRef = await _first<ServiceInspectionRef?>(
          _inspections.watchInspectionForAssignment(context, assignmentRef.id),
        );
        if (inspectionRef != null) {
          materialRequests =
              await _first<List<ServiceMaterialRequestRef>>(
                _materialRequests.watchRequestsForInspection(
                  context,
                  inspectionRef.id,
                ),
              ) ??
              const [];
          executionRef = await _first<ServiceWorkExecutionRef?>(
            _workExecutions.watchExecutionForInspection(
              context,
              inspectionRef.id,
            ),
          );
          waitingMaterialCount = await _waitingMaterialCount(
            context.company.id,
            inspectionRef.id,
          );
        }
      }

      final selectedRequest = _selectMaterialRequest(materialRequests);
      final enquiry = ServiceWorkflowNode(
        stage: ServiceWorkflowStage.enquiry,
        present: enquiryView != null,
        id: enquiryView?.enquiry.id,
        reference: enquiryView?.enquiry.enquiryNumber,
        statusKey: enquiryView?.enquiry.status.wire,
        cancelled: enquiryView?.enquiry.isCancelled ?? false,
      );
      final assignment = ServiceWorkflowNode(
        stage: ServiceWorkflowStage.jobAssignment,
        present: assignmentRef != null,
        id: assignmentRef?.id,
        reference: assignmentRef?.assignmentNumber,
        statusKey: 'active',
      );
      final inspection = ServiceWorkflowNode(
        stage: ServiceWorkflowStage.inspection,
        present: inspectionRef != null,
        id: inspectionRef?.id,
        reference: inspectionRef?.inspectionNumber,
        statusKey: inspectionRef?.status.wire,
        cancelled: inspectionRef?.status.isCancelled ?? false,
        waitingMaterialCount: waitingMaterialCount,
      );
      final materialRequest = ServiceWorkflowNode(
        stage: ServiceWorkflowStage.materialRequest,
        present: selectedRequest != null,
        id: selectedRequest?.id,
        reference: selectedRequest?.requestNumber,
        statusKey: selectedRequest?.status.wire,
        cancelled:
            materialRequests.isNotEmpty &&
            materialRequests.every((r) => r.status.isCancelled),
        recordCount: materialRequests.length,
      );
      final workExecution = ServiceWorkflowNode(
        stage: ServiceWorkflowStage.workExecution,
        present: executionRef != null,
        id: executionRef?.id,
        reference: executionRef?.executionNumber,
        statusKey: executionRef?.status.wire,
        cancelled: executionRef?.status.isCancelled ?? false,
        allLinesComplete: executionRef?.allLinesComplete ?? false,
      );

      return Success(
        ServiceWorkflowChain(
          enquiryId: enquiryId,
          enquiryNumber: enquiry.reference,
          focus: focus,
          status: deriveServiceWorkflowStatus(
            enquiry: enquiry,
            assignment: assignment,
            inspection: inspection,
            materialRequest: materialRequest,
            workExecution: workExecution,
          ),
          nodes: [
            enquiry,
            assignment,
            inspection,
            materialRequest,
            workExecution,
          ],
        ),
      );
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  Future<T?> _first<T>(Stream<Result<T>> stream) async {
    try {
      final result = await stream.first;
      return result is Success<T> ? result.value : null;
    } catch (_) {
      return null;
    }
  }

  ServiceMaterialRequestRef? _selectMaterialRequest(
    List<ServiceMaterialRequestRef> requests,
  ) {
    if (requests.isEmpty) return null;
    final open = requests.where((r) => r.status.isOpen).toList()
      ..sort((a, b) => b.requestDate.compareTo(a.requestDate));
    if (open.isNotEmpty) return open.first;
    final all = [...requests]
      ..sort((a, b) => b.requestDate.compareTo(a.requestDate));
    return all.first;
  }

  Future<int> _waitingMaterialCount(
    String companyId,
    String inspectionId,
  ) async {
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS c FROM $_materialRequirementTable '
          "WHERE company_id=? AND inspection_id=? AND removed_at IS NULL AND status='waiting'",
          variables: [Variable(companyId), Variable(inspectionId)],
        )
        .getSingle();
    return row.read<int>('c');
  }

  @override
  Future<Result<ServiceWorkflowSummary>> summary(AuthContext context) async {
    try {
      var openEnquiries = 0;
      var scheduledAssignments = 0;
      var pendingInspections = 0;
      var openMaterialRequests = 0;
      var workInProgress = 0;
      var completedWorkToday = 0;

      if (_can(context, AppPermission.serviceEnquiryView)) {
        final result = await _enquiries.summary(context);
        if (result case Success<ServiceEnquirySummary>(:final value)) {
          openEnquiries = value.openCount;
        }
      }
      if (const ServiceJobAssignmentScopeResolver().resolve(context) !=
          ServiceJobAssignmentScope.none) {
        final result = await _jobAssignments.summary(context);
        if (result case Success<ServiceJobAssignmentSummary>(:final value)) {
          scheduledAssignments = value.activeCount;
        }
      }
      if (const ServiceInspectionScopeResolver().resolve(context) !=
          ServiceInspectionScope.none) {
        final result = await _inspections.summary(context);
        if (result case Success<ServiceInspectionSummary>(:final value)) {
          pendingInspections = value.pendingCount;
        }
      }
      if (const ServiceMaterialRequestScopeResolver().resolve(context) !=
          ServiceMaterialRequestScope.none) {
        final result = await _materialRequests.summary(context);
        if (result case Success<ServiceMaterialRequestSummary>(:final value)) {
          openMaterialRequests = value.openCount;
        }
      }
      if (const ServiceWorkExecutionScopeResolver().resolve(context) !=
          ServiceWorkExecutionScope.none) {
        final result = await _workExecutions.summary(context);
        if (result case Success<ServiceWorkExecutionSummary>(:final value)) {
          workInProgress = value.inProgressCount;
          completedWorkToday = value.completedTodayCount;
        }
      }
      return Success(
        ServiceWorkflowSummary(
          openEnquiries: openEnquiries,
          scheduledAssignments: scheduledAssignments,
          pendingInspections: pendingInspections,
          openMaterialRequests: openMaterialRequests,
          workInProgress: workInProgress,
          completedWorkToday: completedWorkToday,
        ),
      );
    } catch (_) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
  }

  @override
  Stream<Result<List<ServiceWorkflowActivityEntry>>> watchActivity(
    AuthContext context,
    String enquiryId,
  ) => _ticks().asyncMap((_) => _loadActivity(context, enquiryId));

  Future<Result<List<ServiceWorkflowActivityEntry>>> _loadActivity(
    AuthContext context,
    String enquiryId,
  ) async {
    final chainResult = await loadChain(context, enquiryId);
    if (chainResult is! Success<ServiceWorkflowChain?>) {
      return const Failed(Failure(code: 'servicesStorage'));
    }
    final chain = chainResult.value;
    if (chain == null) {
      return const Success(<ServiceWorkflowActivityEntry>[]);
    }
    final entries = <ServiceWorkflowActivityEntry>[];
    for (final node in chain.nodes) {
      final entityType = _entityTypeFor(node.stage);
      if (entityType == null || !node.hasRecord) continue;
      try {
        final events = await _activity
            .watchForEntity(
              companyId: context.company.id,
              entityType: entityType,
              entityId: node.id!,
            )
            .first;
        for (final event in events) {
          entries.add(
            ServiceWorkflowActivityEntry(
              entityType: event.entityType,
              entityId: event.entityId,
              eventType: event.eventType,
              occurredAt: event.occurredAt,
              actorUserId: event.actorUserId,
              actorEmployeeId: event.actorEmployeeId,
              reference: node.reference,
              metadata: event.metadata,
            ),
          );
        }
      } catch (_) {
        // A restricted/unavailable entity simply contributes no events.
      }
    }
    entries.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return Success(entries);
  }

  String? _entityTypeFor(ServiceWorkflowStage stage) => switch (stage) {
    ServiceWorkflowStage.enquiry => 'serviceEnquiry',
    ServiceWorkflowStage.jobAssignment => 'serviceJobAssignment',
    ServiceWorkflowStage.inspection => 'serviceInspection',
    ServiceWorkflowStage.materialRequest => 'serviceMaterialRequest',
    ServiceWorkflowStage.workExecution => 'serviceWorkExecution',
  };
}
