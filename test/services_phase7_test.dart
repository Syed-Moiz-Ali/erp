import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/enquiries/data/local_service_enquiry_repository.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/inspections/data/local_service_inspection_repository.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/job_assignments/data/local_service_job_assignment_repository.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/modules/services/material_requests/data/local_service_material_request_repository.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request.dart';
import 'package:modular_erp/modules/services/work_executions/data/local_service_work_execution_repository.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';
import 'package:modular_erp/modules/services/workflow/data/local_service_workflow_repository.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow_action.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow_validator.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/data/local_activity_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_attachment_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_document_number_service.dart';

class _FixedClock implements AppClock {
  const _FixedClock(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
}

class _FakeDirectory implements WorkforceDirectory {
  _FakeDirectory(this.refs);
  final Map<String, WorkforcePersonRef> refs;
  @override
  Future<WorkforcePersonRef?> getEmployeeReference(
    String id, {
    bool includeInactive = false,
  }) async => refs[id];
  @override
  Future<List<WorkforcePersonRef>> getEmployees(Iterable<String> ids) async => [
    for (final id in ids)
      if (refs[id] != null) refs[id]!,
  ];
  @override
  Future<List<WorkforcePersonRef>> searchAssignable({
    String query = '',
    int limit = 50,
  }) async => refs.values.where((r) => r.isActive).toList();
  @override
  Stream<List<AssignableEmployeeSummary>> watchAssignableEmployees({
    String query = '',
  }) => Stream.value(const []);
}

AuthContext context({
  required Set<AppPermission> permissions,
  String companyId = 'c1',
  String? employeeId,
  Set<String> modules = const {'services'},
}) => AuthContext(
  user: UserAccount(
    id: 'u1',
    displayName: 'Operator',
    email: 'op@erp.demo',
    companyId: companyId,
    permissions: PermissionSet(permissions),
    status: AccountStatus.active,
  ),
  company: CompanyContext(
    id: companyId,
    name: 'Company',
    code: 'C',
    timezone: 'UTC',
    defaultLocale: 'en',
    enabledModules: modules,
  ),
  employeeReference: employeeId == null
      ? null
      : EmployeeReference(
          id: employeeId,
          userAccountId: 'u-$employeeId',
          companyId: companyId,
        ),
);

const _adminPermissions = {
  AppPermission.serviceEnquiryView,
  AppPermission.serviceEnquiryCreate,
  AppPermission.serviceEnquiryEdit,
  AppPermission.serviceEnquiryCancel,
  AppPermission.serviceJobAssignmentViewAssigned,
  AppPermission.serviceJobAssignmentViewTeam,
  AppPermission.serviceJobAssignmentViewAll,
  AppPermission.serviceJobAssignmentCreate,
  AppPermission.serviceJobAssignmentEdit,
  AppPermission.serviceJobAssignmentCancel,
  AppPermission.serviceInspectionViewAssigned,
  AppPermission.serviceInspectionViewTeam,
  AppPermission.serviceInspectionViewAll,
  AppPermission.serviceInspectionCreate,
  AppPermission.serviceInspectionEdit,
  AppPermission.serviceInspectionComplete,
  AppPermission.serviceInspectionCancel,
  AppPermission.serviceMaterialRequestViewAssigned,
  AppPermission.serviceMaterialRequestViewTeam,
  AppPermission.serviceMaterialRequestViewAll,
  AppPermission.serviceMaterialRequestCreate,
  AppPermission.serviceMaterialRequestEdit,
  AppPermission.serviceMaterialRequestCancel,
  AppPermission.serviceMaterialRequestPrint,
  AppPermission.serviceWorkExecutionViewAssigned,
  AppPermission.serviceWorkExecutionViewTeam,
  AppPermission.serviceWorkExecutionViewAll,
  AppPermission.serviceWorkExecutionCreate,
  AppPermission.serviceWorkExecutionEdit,
  AppPermission.serviceWorkExecutionPerform,
  AppPermission.serviceWorkExecutionComplete,
  AppPermission.serviceWorkExecutionCancel,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late LocalServiceEnquiryRepository enquiries;
  late LocalServiceJobAssignmentRepository assignments;
  late LocalServiceInspectionRepository inspections;
  late LocalServiceMaterialRequestRepository materialRequests;
  late LocalServiceWorkExecutionRepository executions;
  late LocalServiceWorkflowRepository workflow;
  late LocalActivityRepository activity;

  final now = DateTime.utc(2026, 3, 2, 9);
  final clock = _FixedClock(DateTime.utc(2026, 3, 2, 9));
  const time = FixedOffsetCompanyTimeService();
  final admin = context(permissions: _adminPermissions);

  Future<void> master(
    TableInfo table,
    String id,
    String code,
    String name, {
    String status = 'active',
  }) async {
    final columns = await db
        .customSelect('PRAGMA table_info(${table.actualTableName})')
        .get();
    final names = columns.map((r) => r.read<String>('name')).toSet();
    final row = {
      'id': id,
      'company_id': 'c1',
      'code': code,
      'name': name,
      'status': status,
      'sort_order': 0,
      'created_at': now,
      'updated_at': now,
      'sync_status': 'synced',
    };
    final filtered = {
      for (final e in row.entries)
        if (names.contains(e.key)) e.key: e.value,
    };
    await db.customInsert(
      'INSERT OR IGNORE INTO ${table.actualTableName} '
      '(${filtered.keys.join(',')}) VALUES (${filtered.keys.map((_) => '?').join(',')})',
      variables: [for (final v in filtered.values) Variable(v)],
    );
  }

  Future<void> seed() async {
    await db
        .into(db.serviceCustomers)
        .insert(
          ServiceCustomersCompanion.insert(
            id: 'cus1',
            companyId: 'c1',
            customerCode: 'CUS-1',
            name: 'ABC Properties',
            mobile: '+971500000001',
            status: 'active',
            createdAt: now,
            updatedAt: now,
            createdByUserId: 'u1',
            updatedByUserId: 'u1',
            syncStatus: 'synced',
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await db
        .into(db.serviceSites)
        .insert(
          ServiceSitesCompanion.insert(
            id: 'site1',
            companyId: 'c1',
            customerId: 'cus1',
            siteCode: 'SITE-1',
            siteName: 'Tower 1',
            buildingName: const Value('Tower'),
            unitNumber: const Value('101'),
            addressLine1: 'Main Road',
            city: 'Dubai',
            status: 'active',
            createdAt: now,
            updatedAt: now,
            createdByUserId: 'u1',
            updatedByUserId: 'u1',
            syncStatus: 'synced',
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await master(db.serviceTypes, 'st1', 'ELEC', 'Electrical');
    await master(db.complaintTypes, 'ct1', 'POWER', 'Power');
    await master(db.servicePriorities, 'pr1', 'HIGH', 'High');
    await master(db.serviceTicketTypes, 'tt1', 'COMPLAINT', 'Complaint');
    await master(db.serviceRootCauses, 'rc1', 'ELECTRICAL', 'Electrical fault');
    await master(db.serviceChargeResponsibilities, 'ch1', 'TENANT', 'Tenant');
    await master(
      db.serviceMaterialRequestPurposes,
      'mrp1',
      'SERVICE',
      'Service work',
    );
    await db
        .into(db.serviceTeams)
        .insert(
          ServiceTeamsCompanion.insert(
            id: 't1',
            companyId: 'c1',
            teamCode: 'TEAM-1',
            name: 'HVAC Team',
            leadEmployeeId: const Value('e1'),
            status: 'active',
            createdAt: now,
            updatedAt: now,
            createdByUserId: 'u1',
            updatedByUserId: 'u1',
            syncStatus: 'synced',
          ),
          mode: InsertMode.insertOrIgnore,
        );
    for (final employeeId in ['e1', 'e2']) {
      await db
          .into(db.serviceTeamMembers)
          .insert(
            ServiceTeamMembersCompanion.insert(
              id: 't1-$employeeId',
              companyId: 'c1',
              teamId: 't1',
              employeeId: employeeId,
              status: 'active',
              createdAt: now,
              createdByUserId: 'u1',
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final numbers = LocalDocumentNumberService(db, clock);
    activity = LocalActivityRepository(db);
    final attachments = LocalAttachmentRepository(db, clock);
    final directory = _FakeDirectory({
      'e1': const WorkforcePersonRef(
        id: 'e1',
        name: 'Ahmed Khan',
        employeeCode: 'EMP-1',
      ),
      'e2': const WorkforcePersonRef(
        id: 'e2',
        name: 'Sara',
        employeeCode: 'EMP-2',
      ),
    });
    enquiries = LocalServiceEnquiryRepository(
      db,
      clock,
      numbers,
      activity,
      attachments,
    );
    assignments = LocalServiceJobAssignmentRepository(
      db,
      clock,
      numbers,
      activity,
      attachments,
      directory,
      time,
    );
    inspections = LocalServiceInspectionRepository(
      db,
      clock,
      numbers,
      activity,
      attachments,
      directory,
      time,
    );
    materialRequests = LocalServiceMaterialRequestRepository(
      db,
      clock,
      numbers,
      activity,
      directory,
      time,
    );
    executions = LocalServiceWorkExecutionRepository(
      db,
      clock,
      numbers,
      activity,
      attachments,
      directory,
      time,
    );
    workflow = LocalServiceWorkflowRepository(
      db: db,
      enquiries: enquiries,
      jobAssignments: assignments,
      inspections: inspections,
      materialRequests: materialRequests,
      workExecutions: executions,
      activity: activity,
    );
    await seed();
  });
  tearDown(() => db.close());

  Future<String> createEnquiry({
    MaterialReceived materialReceived = MaterialReceived.no,
  }) async {
    final result = await enquiries.createEnquiry(
      admin,
      ServiceEnquiryDraft(
        customerId: 'cus1',
        siteId: 'site1',
        serviceTypeId: 'st1',
        complaintTypeId: 'ct1',
        priorityId: 'pr1',
        ticketTypeId: 'tt1',
        materialReceived: materialReceived,
        details: const [
          ServiceEnquiryDraftDetail(id: 'd1', description: 'Leaking pipe'),
        ],
      ),
    );
    return (result as Success<ServiceEnquiry>).value.id;
  }

  Future<String> createAssignment(String enquiryId) async {
    final result = await assignments.createAssignment(
      admin,
      ServiceJobAssignmentDraft(
        sourceEnquiryId: enquiryId,
        scheduledVisitDate: DateTime.utc(2026, 3, 4),
        lines: const [
          ServiceJobAssignmentLineDraft(
            id: 'jal1',
            work: 'Repair leak',
            assignedEmployeeId: 'e1',
            assignedTeamId: 't1',
          ),
        ],
      ),
    );
    return (result as Success<ServiceJobAssignment>).value.id;
  }

  Future<String> completeInspection(
    String assignmentId, {
    bool withMaterial = false,
  }) async {
    final created = await inspections.createInspection(
      admin,
      ServiceInspectionDraft(
        sourceJobAssignmentId: assignmentId,
        visitDate: DateTime.utc(2026, 3, 4),
        visitMinutes: 600,
        technicianEmployeeId: 'e1',
        rootCauseId: 'rc1',
        chargeResponsibilityId: 'ch1',
        checklistItems: const [
          ServiceInspectionChecklistItemDraft(
            id: 'ck1',
            workType: 'Repair leak',
          ),
        ],
        materialRequirements: withMaterial
            ? const [
                ServiceInspectionMaterialRequirementDraft(
                  id: 'req1',
                  code: 'WASH-1',
                  description: 'Tap washer',
                ),
              ]
            : const [],
      ),
    );
    final inspection = (created as Success<ServiceInspection>).value;
    await inspections.completeInspection(admin, inspection.id);
    return inspection.id;
  }

  Future<String> createMaterialRequest(String inspectionId) async {
    final result = await materialRequests.createRequest(
      admin,
      const ServiceMaterialRequestDraft(
        sourceInspectionId: null,
        lines: [],
      ).copyWith(
        sourceInspectionId: inspectionId,
        lines: const [
          ServiceMaterialRequestLineDraft(
            id: 'mrl1',
            sourceInspectionMaterialRequirementId: 'req1',
            code: 'WASH-1',
            description: 'Tap washer',
            quantity: '2',
          ),
        ],
      ),
    );
    return (result as Success<ServiceMaterialRequest>).value.id;
  }

  Future<String> createWorkExecution(
    String inspectionId, {
    bool complete = false,
  }) async {
    final created = await executions.createExecution(
      admin,
      ServiceWorkExecutionDraft(
        sourceInspectionId: inspectionId,
        workLines: const [
          ServiceWorkExecutionLineDraft(
            id: 'wl1',
            work: 'Repair leak',
            employeeId: 'e1',
          ),
        ],
      ),
    );
    final execution = (created as Success<ServiceWorkExecution>).value;
    await executions.startWorkLine(admin, execution.id, 'wl1');
    await executions.endWorkLine(admin, execution.id, 'wl1');
    if (complete) {
      await executions.completeExecution(admin, execution.id);
    }
    return execution.id;
  }

  ServiceWorkflowNode node(
    ServiceWorkflowChain chain,
    ServiceWorkflowStage s,
  ) => chain.nodeFor(s);

  group('workflow read model — no-material path', () {
    test('resolves lineage and completes without a material request', () async {
      final enquiryId = await createEnquiry();
      final assignmentId = await createAssignment(enquiryId);
      final inspectionId = await completeInspection(assignmentId);
      final executionId = await createWorkExecution(
        inspectionId,
        complete: true,
      );

      final result = await workflow.loadChain(admin, enquiryId);
      final chain = (result as Success<ServiceWorkflowChain?>).value!;
      expect(chain.status, ServiceWorkflowStatus.workCompleted);
      expect(node(chain, ServiceWorkflowStage.enquiry).hasRecord, isTrue);
      expect(node(chain, ServiceWorkflowStage.jobAssignment).id, assignmentId);
      expect(node(chain, ServiceWorkflowStage.inspection).id, inspectionId);
      expect(
        node(chain, ServiceWorkflowStage.materialRequest).hasRecord,
        isFalse,
      );
      expect(
        node(chain, ServiceWorkflowStage.materialRequest).optionalAbsent,
        isTrue,
      );
      expect(node(chain, ServiceWorkflowStage.workExecution).id, executionId);
    });

    test(
      'completed inspection with no materials offers work execution',
      () async {
        final enquiryId = await createEnquiry();
        final assignmentId = await createAssignment(enquiryId);
        await completeInspection(assignmentId);
        final chain =
            (await workflow.loadChain(admin, enquiryId)
                    as Success<ServiceWorkflowChain?>)
                .value!;
        final actions = const ServiceWorkflowActionResolver().resolveForStage(
          admin,
          chain,
          ServiceWorkflowStage.inspection,
        );
        expect(
          actions.any(
            (a) =>
                a.targetStage == ServiceWorkflowStage.workExecution &&
                a.type == ServiceWorkflowActionType.create,
          ),
          isTrue,
        );
        expect(
          actions.any(
            (a) =>
                a.targetStage == ServiceWorkflowStage.materialRequest &&
                a.type == ServiceWorkflowActionType.create,
          ),
          isFalse,
        );
      },
    );
  });

  group('workflow read model — material path', () {
    test('waiting requirement surfaces a material request action', () async {
      final enquiryId = await createEnquiry();
      final assignmentId = await createAssignment(enquiryId);
      final inspectionId = await completeInspection(
        assignmentId,
        withMaterial: true,
      );
      final chain =
          (await workflow.loadChain(admin, enquiryId)
                  as Success<ServiceWorkflowChain?>)
              .value!;
      expect(
        node(chain, ServiceWorkflowStage.inspection).waitingMaterialCount,
        1,
      );
      expect(chain.status, ServiceWorkflowStatus.materialsRequested);
      final actions = const ServiceWorkflowActionResolver().resolveForStage(
        admin,
        chain,
        ServiceWorkflowStage.inspection,
      );
      expect(
        actions.any(
          (a) =>
              a.targetStage == ServiceWorkflowStage.materialRequest &&
              a.type == ServiceWorkflowActionType.create,
        ),
        isTrue,
      );
      expect(
        actions.any(
          (a) =>
              a.targetStage == ServiceWorkflowStage.workExecution &&
              a.type == ServiceWorkflowActionType.create,
        ),
        isTrue,
      );

      final requestId = await createMaterialRequest(inspectionId);
      final after =
          (await workflow.loadChain(admin, enquiryId)
                  as Success<ServiceWorkflowChain?>)
              .value!;
      expect(node(after, ServiceWorkflowStage.materialRequest).id, requestId);
      expect(
        node(after, ServiceWorkflowStage.inspection).waitingMaterialCount,
        0,
      );
      expect(after.status, ServiceWorkflowStatus.materialsRequested);
    });

    test('material received is inherited read-only from the enquiry', () async {
      final enquiryId = await createEnquiry(
        materialReceived: MaterialReceived.yes,
      );
      final assignmentId = await createAssignment(enquiryId);
      final inspectionId = await completeInspection(
        assignmentId,
        withMaterial: true,
      );
      final requestId = await createMaterialRequest(inspectionId);
      final view =
          (await materialRequests.getRequest(admin, requestId)
                  as Success<ServiceMaterialRequestView?>)
              .value!;
      expect(view.materialReceived, MaterialReceived.yes);

      final columns = await db
          .customSelect('PRAGMA table_info(service_material_requests)')
          .get();
      final names = {for (final r in columns) r.read<String>('name')};
      expect(names, isNot(contains('material_received')));
    });
  });

  group('cancellation lifecycle', () {
    test('cancelling the assignment returns the enquiry to OPEN', () async {
      final enquiryId = await createEnquiry();
      final assignmentId = await createAssignment(enquiryId);
      await assignments.cancelAssignment(admin, assignmentId);
      final chain =
          (await workflow.loadChain(admin, enquiryId)
                  as Success<ServiceWorkflowChain?>)
              .value!;
      expect(chain.status, ServiceWorkflowStatus.awaitingAssignment);
      final view =
          (await enquiries.getEnquiry(admin, enquiryId)
                  as Success<ServiceEnquiryView?>)
              .value!;
      expect(view.enquiry.status, ServiceEnquiryStatus.open);
    });

    test('a cancelled inspection cannot create a work execution', () async {
      final enquiryId = await createEnquiry();
      final assignmentId = await createAssignment(enquiryId);
      final created = await inspections.createInspection(
        admin,
        ServiceInspectionDraft(
          sourceJobAssignmentId: assignmentId,
          visitDate: DateTime.utc(2026, 3, 4),
          visitMinutes: 600,
          technicianEmployeeId: 'e1',
          rootCauseId: 'rc1',
          chargeResponsibilityId: 'ch1',
          checklistItems: const [
            ServiceInspectionChecklistItemDraft(id: 'ck1', workType: 'Repair'),
          ],
        ),
      );
      final inspectionId = (created as Success<ServiceInspection>).value.id;
      await inspections.cancelInspection(admin, inspectionId);
      final result = await executions.createExecution(
        admin,
        ServiceWorkExecutionDraft(
          sourceInspectionId: inspectionId,
          workLines: const [
            ServiceWorkExecutionLineDraft(id: 'wl1', work: 'Repair leak'),
          ],
        ),
      );
      expect(result, isA<Failed<ServiceWorkExecution>>());
      final chain =
          (await workflow.loadChain(admin, enquiryId)
                  as Success<ServiceWorkflowChain?>)
              .value!;
      expect(chain.status, ServiceWorkflowStatus.scheduled);
    });

    test('cancelling a work execution preserves captured times', () async {
      final enquiryId = await createEnquiry();
      final assignmentId = await createAssignment(enquiryId);
      final inspectionId = await completeInspection(assignmentId);
      final created = await executions.createExecution(
        admin,
        ServiceWorkExecutionDraft(
          sourceInspectionId: inspectionId,
          workLines: const [
            ServiceWorkExecutionLineDraft(
              id: 'wl1',
              work: 'Repair leak',
              employeeId: 'e1',
            ),
          ],
        ),
      );
      final executionId = (created as Success<ServiceWorkExecution>).value.id;
      await executions.startWorkLine(admin, executionId, 'wl1');
      await executions.endWorkLine(admin, executionId, 'wl1');
      final cancelled =
          (await executions.cancelExecution(admin, executionId)
                  as Success<ServiceWorkExecution>)
              .value;
      expect(cancelled.isCancelled, isTrue);
      final line = cancelled.workLines.single;
      expect(line.startedAtUtc, isNotNull);
      expect(line.endedAtUtc, isNotNull);
      final row = await db
          .customSelect(
            "SELECT COUNT(*) AS c FROM service_work_executions WHERE company_id='c1' AND id='$executionId'",
          )
          .getSingle();
      expect(row.read<int>('c'), 1);
    });

    test('cancelling a material request reconciles the requirement', () async {
      final enquiryId = await createEnquiry();
      final assignmentId = await createAssignment(enquiryId);
      final inspectionId = await completeInspection(
        assignmentId,
        withMaterial: true,
      );
      final requestId = await createMaterialRequest(inspectionId);
      await materialRequests.cancelRequest(admin, requestId);
      final row = await db
          .customSelect(
            "SELECT status FROM service_inspection_material_requirements WHERE company_id='c1' AND id='req1'",
          )
          .getSingle();
      expect(row.read<String>('status'), 'waiting');
    });
  });

  group('permission personas', () {
    test('persona A can assign but cannot inspect or execute', () async {
      final persona = context(
        permissions: {
          AppPermission.serviceEnquiryView,
          AppPermission.serviceEnquiryCreate,
          AppPermission.serviceJobAssignmentViewAll,
          AppPermission.serviceJobAssignmentCreate,
        },
      );
      final enquiryId = await createEnquiry();
      final chain =
          (await workflow.loadChain(persona, enquiryId)
                  as Success<ServiceWorkflowChain?>)
              .value!;
      final actions = const ServiceWorkflowActionResolver().resolve(
        persona,
        chain,
      );
      expect(
        actions.any(
          (a) =>
              a.type == ServiceWorkflowActionType.create &&
              a.targetStage == ServiceWorkflowStage.jobAssignment,
        ),
        isTrue,
      );
      expect(
        actions.any((a) => a.targetStage == ServiceWorkflowStage.inspection),
        isFalse,
      );
      expect(
        actions.any((a) => a.targetStage == ServiceWorkflowStage.workExecution),
        isFalse,
      );
    });

    test('a field employee sees only assigned work and no masters', () async {
      final enquiryId = await createEnquiry();
      final assignmentId = await createAssignment(enquiryId);
      await completeInspection(assignmentId);
      final field = context(
        permissions: {
          AppPermission.serviceJobAssignmentViewAssigned,
          AppPermission.serviceInspectionViewAssigned,
          AppPermission.serviceInspectionEdit,
          AppPermission.serviceInspectionComplete,
          AppPermission.serviceWorkExecutionViewAssigned,
          AppPermission.serviceWorkExecutionPerform,
        },
        employeeId: 'e1',
      );
      final chain =
          (await workflow.loadChain(field, enquiryId)
                  as Success<ServiceWorkflowChain?>)
              .value!;
      // The enquiry node is not viewable (no enquiry permission).
      expect(node(chain, ServiceWorkflowStage.enquiry).hasRecord, isFalse);
      expect(node(chain, ServiceWorkflowStage.jobAssignment).hasRecord, isTrue);
      final actions = const ServiceWorkflowActionResolver().resolve(
        field,
        chain,
      );
      expect(
        actions.any(
          (a) => a.targetStage == ServiceWorkflowStage.materialRequest,
        ),
        isFalse,
      );
    });

    test('company switch cannot leak another company workflow', () async {
      final enquiryId = await createEnquiry();
      await createAssignment(enquiryId);
      final other = context(permissions: _adminPermissions, companyId: 'c2');
      final chain =
          (await workflow.loadChain(other, enquiryId)
                  as Success<ServiceWorkflowChain?>)
              .value!;
      expect(chain.nodes.every((n) => !n.hasRecord), isTrue);
      final summary =
          (await workflow.summary(other) as Success<ServiceWorkflowSummary>)
              .value;
      expect(summary.scheduledAssignments, 0);
      expect(summary.openEnquiries, 0);
    });

    test('disabling the services module removes all workflow access', () async {
      final enquiryId = await createEnquiry();
      final disabled = context(
        permissions: _adminPermissions,
        modules: const {},
      );
      final chain =
          (await workflow.loadChain(disabled, enquiryId)
                  as Success<ServiceWorkflowChain?>)
              .value!;
      expect(chain.nodes.every((n) => !n.hasRecord), isTrue);
      expect(
        const ServiceWorkflowActionResolver().resolve(disabled, chain),
        isEmpty,
      );
    });
  });

  group('summary and activity', () {
    test('summary counts accessible workflow records', () async {
      final enquiryId = await createEnquiry();
      final assignmentId = await createAssignment(enquiryId);
      final inspectionId = await completeInspection(
        assignmentId,
        withMaterial: true,
      );
      await createMaterialRequest(inspectionId);
      await createWorkExecution(inspectionId);

      final summary =
          (await workflow.summary(admin) as Success<ServiceWorkflowSummary>)
              .value;
      expect(summary.scheduledAssignments, 1);
      expect(summary.openMaterialRequests, 1);
      expect(summary.workInProgress, 1);
      expect(summary.openEnquiries, 0);
    });

    test('activity feed merges events and orders newest first', () async {
      final enquiryId = await createEnquiry();
      final assignmentId = await createAssignment(enquiryId);
      final inspectionId = await completeInspection(assignmentId);
      await createWorkExecution(inspectionId);

      final events = await workflow.watchActivity(admin, enquiryId).first;
      final entries =
          (events as Success<List<ServiceWorkflowActivityEntry>>).value;
      expect(entries, isNotEmpty);
      final types = entries.map((e) => e.entityType).toSet();
      expect(types.length, greaterThan(1));
      for (var i = 1; i < entries.length; i++) {
        expect(
          entries[i - 1].occurredAt.isBefore(entries[i].occurredAt),
          isFalse,
        );
      }
    });
  });

  group('data consistency validator', () {
    test('a consistent chain reports no issues', () async {
      final enquiryId = await createEnquiry();
      final assignmentId = await createAssignment(enquiryId);
      final inspectionId = await completeInspection(assignmentId);
      await createWorkExecution(inspectionId);
      final issues = await ServiceWorkflowValidator(db).validate('c1');
      expect(issues, isEmpty);
    });

    test('detects an inspection whose enquiry lineage is wrong', () async {
      final enquiryId = await createEnquiry();
      final assignmentId = await createAssignment(enquiryId);
      await completeInspection(assignmentId);
      await db.customUpdate(
        "UPDATE service_inspections SET source_enquiry_id='bogus' WHERE company_id='c1'",
      );
      final issues = await ServiceWorkflowValidator(db).validate('c1');
      expect(issues.any((i) => i.code == 'inspectionEnquiryMismatch'), isTrue);
    });
  });

  group('idempotency and outbox', () {
    test('reusing a request id does not duplicate the enquiry', () async {
      final draft = ServiceEnquiryDraft(
        customerId: 'cus1',
        siteId: 'site1',
        serviceTypeId: 'st1',
        complaintTypeId: 'ct1',
        priorityId: 'pr1',
        ticketTypeId: 'tt1',
        details: const [
          ServiceEnquiryDraftDetail(id: 'd1', description: 'Leaking pipe'),
        ],
      );
      final first = await enquiries.createEnquiry(
        admin,
        draft,
        requestId: 'req-1',
      );
      final second = await enquiries.createEnquiry(
        admin,
        draft,
        requestId: 'req-1',
      );
      expect(
        (first as Success<ServiceEnquiry>).value.id,
        (second as Success<ServiceEnquiry>).value.id,
      );
      final count = await db
          .customSelect(
            "SELECT COUNT(*) AS c FROM service_enquiries WHERE company_id='c1'",
          )
          .getSingle();
      expect(count.read<int>('c'), 1);
    });

    test('workflow mutations emit outbox actions', () async {
      final enquiryId = await createEnquiry();
      await createAssignment(enquiryId);
      final rows = await db
          .customSelect(
            "SELECT DISTINCT operation FROM sync_outbox WHERE company_id='c1'",
          )
          .get();
      final actions = {for (final r in rows) r.read<String>('operation')};
      expect(actions, contains('SERVICES_ENQUIRY_CREATE'));
      expect(actions, contains('SERVICES_JOB_ASSIGNMENT_CREATE'));
    });
  });
}
