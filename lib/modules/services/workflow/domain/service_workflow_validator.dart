import 'package:drift/drift.dart';
import 'package:modular_erp/core/database/app_database.dart';

/// A single detected Services workflow-integrity problem.
///
/// Reported as a stable [code] plus the offending record identity so tests and
/// diagnostics can act on it. The validator never repairs anything: integrity
/// problems must be fixed at their source (Phase 7 §63–64).
class ServiceWorkflowIntegrityIssue {
  const ServiceWorkflowIntegrityIssue({
    required this.code,
    required this.entityType,
    required this.entityId,
  });
  final String code;
  final String entityType;
  final String entityId;

  @override
  String toString() => '$code ($entityType/$entityId)';
}

/// Development/test-level Services workflow consistency validator.
///
/// It asserts company/lineage/child-company/attachment-owner integrity across
/// the five transactions. It is read-only and must never be wired to a silent
/// production repair path.
class ServiceWorkflowValidator {
  const ServiceWorkflowValidator(this._db);
  final AppDatabase _db;

  /// Validates all Services workflow integrity rules for one company.
  Future<List<ServiceWorkflowIntegrityIssue>> validate(String companyId) async {
    final issues = <ServiceWorkflowIntegrityIssue>[];
    Future<void> check(
      String code,
      String entityType,
      String sql,
      List<Variable> variables,
    ) async {
      final rows = await _db.customSelect(sql, variables: variables).get();
      for (final row in rows) {
        issues.add(
          ServiceWorkflowIntegrityIssue(
            code: code,
            entityType: entityType,
            entityId: row.read<String>('id'),
          ),
        );
      }
    }

    final c = Variable(companyId);

    // ---- Lineage: each downstream transaction must resolve its source.
    await check(
      'assignmentMissingEnquiry',
      'serviceJobAssignment',
      'SELECT a.id FROM service_job_assignments a '
          'LEFT JOIN service_enquiries e ON e.id=a.source_enquiry_id AND e.company_id=a.company_id '
          'WHERE a.company_id=? AND e.id IS NULL',
      [c],
    );
    await check(
      'inspectionMissingAssignment',
      'serviceInspection',
      'SELECT i.id FROM service_inspections i '
          'LEFT JOIN service_job_assignments a ON a.id=i.source_job_assignment_id AND a.company_id=i.company_id '
          'WHERE i.company_id=? AND a.id IS NULL',
      [c],
    );
    await check(
      'inspectionEnquiryMismatch',
      'serviceInspection',
      'SELECT i.id FROM service_inspections i '
          'JOIN service_job_assignments a ON a.id=i.source_job_assignment_id AND a.company_id=i.company_id '
          'WHERE i.company_id=? AND i.source_enquiry_id<>a.source_enquiry_id',
      [c],
    );
    await check(
      'materialRequestMissingInspection',
      'serviceMaterialRequest',
      'SELECT r.id FROM service_material_requests r '
          'LEFT JOIN service_inspections i ON i.id=r.source_inspection_id AND i.company_id=r.company_id '
          'WHERE r.company_id=? AND i.id IS NULL',
      [c],
    );
    await check(
      'materialRequestLineageMismatch',
      'serviceMaterialRequest',
      'SELECT r.id FROM service_material_requests r '
          'JOIN service_inspections i ON i.id=r.source_inspection_id AND i.company_id=r.company_id '
          'WHERE r.company_id=? AND (r.source_enquiry_id<>i.source_enquiry_id OR r.source_job_assignment_id<>i.source_job_assignment_id)',
      [c],
    );
    await check(
      'workExecutionMissingInspection',
      'serviceWorkExecution',
      'SELECT w.id FROM service_work_executions w '
          'LEFT JOIN service_inspections i ON i.id=w.source_inspection_id AND i.company_id=w.company_id '
          'WHERE w.company_id=? AND i.id IS NULL',
      [c],
    );
    await check(
      'workExecutionLineageMismatch',
      'serviceWorkExecution',
      'SELECT w.id FROM service_work_executions w '
          'JOIN service_inspections i ON i.id=w.source_inspection_id AND i.company_id=w.company_id '
          'WHERE w.company_id=? AND (w.source_enquiry_id<>i.source_enquiry_id OR w.source_job_assignment_id<>i.source_job_assignment_id)',
      [c],
    );

    // ---- Child rows must share their parent's company.
    await check(
      'enquiryDetailMissingEnquiry',
      'serviceEnquiryDetail',
      'SELECT d.id FROM service_enquiry_details d '
          'LEFT JOIN service_enquiries e ON e.id=d.enquiry_id AND e.company_id=d.company_id '
          'WHERE d.company_id=? AND e.id IS NULL',
      [c],
    );
    await check(
      'assignmentLineMissingAssignment',
      'serviceJobAssignmentLine',
      'SELECT l.id FROM service_job_assignment_lines l '
          'LEFT JOIN service_job_assignments a ON a.id=l.assignment_id AND a.company_id=l.company_id '
          'WHERE l.company_id=? AND a.id IS NULL',
      [c],
    );
    await check(
      'checklistItemMissingInspection',
      'serviceInspectionChecklistItem',
      'SELECT x.id FROM service_inspection_checklist_items x '
          'LEFT JOIN service_inspections i ON i.id=x.inspection_id AND i.company_id=x.company_id '
          'WHERE x.company_id=? AND i.id IS NULL',
      [c],
    );
    await check(
      'inspectionPointMissingInspection',
      'serviceInspectionPoint',
      'SELECT p.id FROM service_inspection_points p '
          'LEFT JOIN service_inspections i ON i.id=p.inspection_id AND i.company_id=p.company_id '
          'WHERE p.company_id=? AND i.id IS NULL',
      [c],
    );
    await check(
      'materialRequirementMissingInspection',
      'serviceInspectionMaterialRequirement',
      'SELECT m.id FROM service_inspection_material_requirements m '
          'LEFT JOIN service_inspections i ON i.id=m.inspection_id AND i.company_id=m.company_id '
          'WHERE m.company_id=? AND i.id IS NULL',
      [c],
    );
    await check(
      'materialRequestLineMissingRequest',
      'serviceMaterialRequestLine',
      'SELECT l.id FROM service_material_request_lines l '
          'LEFT JOIN service_material_requests r ON r.id=l.material_request_id AND r.company_id=l.company_id '
          'WHERE l.company_id=? AND r.id IS NULL',
      [c],
    );
    await check(
      'workExecutionLineMissingExecution',
      'serviceWorkExecutionLine',
      'SELECT l.id FROM service_work_execution_lines l '
          'LEFT JOIN service_work_executions w ON w.id=l.work_execution_id AND w.company_id=l.company_id '
          'WHERE l.company_id=? AND w.id IS NULL',
      [c],
    );
    await check(
      'materialUsedMissingExecution',
      'serviceWorkExecutionMaterialUsed',
      'SELECT m.id FROM service_work_execution_materials_used m '
          'LEFT JOIN service_work_executions w ON w.id=m.work_execution_id AND w.company_id=m.company_id '
          'WHERE m.company_id=? AND w.id IS NULL',
      [c],
    );
    await check(
      'photoEntryMissingExecution',
      'serviceWorkExecutionPhotoEntry',
      'SELECT p.id FROM service_work_execution_photo_entries p '
          'LEFT JOIN service_work_executions w ON w.id=p.work_execution_id AND w.company_id=p.company_id '
          'WHERE p.company_id=? AND w.id IS NULL',
      [c],
    );

    // ---- Optional material lineage must resolve when present.
    await check(
      'materialRequestRequirementLineageBroken',
      'serviceMaterialRequestLine',
      'SELECT l.id FROM service_material_request_lines l '
          'LEFT JOIN service_inspection_material_requirements m '
          'ON m.id=l.source_inspection_material_requirement_id AND m.company_id=l.company_id '
          'WHERE l.company_id=? AND l.source_inspection_material_requirement_id IS NOT NULL AND m.id IS NULL',
      [c],
    );
    await check(
      'materialUsedRequestLineageBroken',
      'serviceWorkExecutionMaterialUsed',
      'SELECT m.id FROM service_work_execution_materials_used m '
          'LEFT JOIN service_material_request_lines l '
          'ON l.id=m.source_material_request_line_id AND l.company_id=m.company_id '
          'WHERE m.company_id=? AND m.source_material_request_line_id IS NOT NULL AND l.id IS NULL',
      [c],
    );

    // ---- Attachment owner must exist (Before = Inspection, After = Execution).
    await check(
      'enquiryPhotoOwnerMissing',
      'serviceEnquiryDetail',
      "SELECT a.id FROM attachment_records a "
          "LEFT JOIN service_enquiry_details d ON d.id=a.owner_id AND d.company_id=a.company_id "
          "WHERE a.company_id=? AND a.owner_type='serviceEnquiryDetail' AND a.deleted_at IS NULL AND d.id IS NULL",
      [c],
    );
    await check(
      'beforeWorkPhotoOwnerMissing',
      'serviceInspectionChecklistItem',
      "SELECT a.id FROM attachment_records a "
          "LEFT JOIN service_inspection_checklist_items x ON x.id=a.owner_id AND x.company_id=a.company_id "
          "WHERE a.company_id=? AND a.owner_type='serviceInspectionChecklistItem' AND a.deleted_at IS NULL AND x.id IS NULL",
      [c],
    );
    await check(
      'afterWorkPhotoOwnerMissing',
      'serviceWorkExecutionPhotoEntry',
      "SELECT a.id FROM attachment_records a "
          "LEFT JOIN service_work_execution_photo_entries p ON p.id=a.owner_id AND p.company_id=a.company_id "
          "WHERE a.company_id=? AND a.owner_type='serviceWorkExecutionPhotoEntry' AND a.deleted_at IS NULL AND p.id IS NULL",
      [c],
    );

    return issues;
  }
}
