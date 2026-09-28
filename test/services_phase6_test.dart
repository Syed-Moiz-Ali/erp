import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/inspections/data/local_service_inspection_repository.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/work_executions/data/local_service_work_execution_repository.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';
import 'package:modular_erp/modules/services/work_executions/presentation/bloc/service_work_execution_blocs.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/data/local_activity_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_attachment_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_document_number_service.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';

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
  }) async {
    final ref = refs[id];
    if (ref == null) return null;
    if (!includeInactive && !ref.isActive) return null;
    return ref;
  }

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
    enabledModules: const {'services'},
  ),
  employeeReference: employeeId == null
      ? null
      : EmployeeReference(
          id: employeeId,
          userAccountId: 'u-$employeeId',
          companyId: companyId,
        ),
);

const _all = {
  AppPermission.serviceInspectionViewAll,
  AppPermission.serviceInspectionViewAssigned,
  AppPermission.serviceInspectionViewTeam,
  AppPermission.serviceInspectionCreate,
  AppPermission.serviceInspectionEdit,
  AppPermission.serviceInspectionComplete,
  AppPermission.serviceInspectionCancel,
  AppPermission.serviceWorkExecutionViewAll,
  AppPermission.serviceWorkExecutionViewAssigned,
  AppPermission.serviceWorkExecutionViewTeam,
  AppPermission.serviceWorkExecutionCreate,
  AppPermission.serviceWorkExecutionEdit,
  AppPermission.serviceWorkExecutionPerform,
  AppPermission.serviceWorkExecutionComplete,
  AppPermission.serviceWorkExecutionCancel,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late LocalServiceWorkExecutionRepository repo;
  late LocalAttachmentRepository attachments;
  late LocalServiceInspectionRepository inspections;
  final now = DateTime.utc(2026, 2, 10, 9);
  final clock = _FixedClock(DateTime.utc(2026, 2, 10, 9));

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

  Future<void> enquiry(String id, String number) => db
      .into(db.serviceEnquiries)
      .insert(
        ServiceEnquiriesCompanion.insert(
          id: id,
          companyId: 'c1',
          enquiryNumber: number,
          customerId: 'cus1',
          siteId: 'site1',
          serviceTypeId: 'st1',
          complaintTypeId: 'ct1',
          priorityId: 'pr1',
          ticketTypeId: 'tt1',
          description: '',
          status: 'assigned',
          materialReceived: const Value('yes'),
          partySnapshot:
              '{"customerName":"ABC Properties","customerMobile":"+971500000001","siteName":"Tower 1","buildingName":"Tower","unitNumber":"101"}',
          searchText: const Value('abc'),
          createdAt: now,
          updatedAt: now,
          createdByUserId: 'u1',
          updatedByUserId: 'u1',
          syncStatus: 'synced',
        ),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> assignment(String id, String number, String enquiryId) async {
    await db
        .into(db.serviceJobAssignments)
        .insert(
          ServiceJobAssignmentsCompanion.insert(
            id: id,
            companyId: 'c1',
            assignmentNumber: number,
            assignmentDate: now,
            sourceEnquiryId: enquiryId,
            scheduledVisitDate: DateTime.utc(2026, 2, 12),
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
        .into(db.serviceJobAssignmentLines)
        .insert(
          ServiceJobAssignmentLinesCompanion.insert(
            id: '$id-l1',
            companyId: 'c1',
            assignmentId: id,
            lineNumber: 1,
            work: 'Inspect AC',
            assignedEmployeeId: const Value('e1'),
            assignedTeamId: const Value('t1'),
            status: 'pending',
            descriptionForWork: const Value('Inspect cooling circuit'),
            createdAt: now,
            updatedAt: now,
            createdByUserId: 'u1',
            updatedByUserId: 'u1',
            syncStatus: 'synced',
          ),
          mode: InsertMode.insertOrIgnore,
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
    await enquiry('enq1', 'ENQ-000001');
    await assignment('ja1', 'JA-000001', 'enq1');
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final numbers = LocalDocumentNumberService(db, clock);
    final activity = LocalActivityRepository(db);
    attachments = LocalAttachmentRepository(db, clock);
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
      'e3': const WorkforcePersonRef(
        id: 'e3',
        name: 'Omar',
        employeeCode: 'EMP-3',
      ),
    });
    repo = LocalServiceWorkExecutionRepository(
      db,
      clock,
      numbers,
      activity,
      attachments,
      directory,
      const FixedOffsetCompanyTimeService(),
    );
    inspections = LocalServiceInspectionRepository(
      db,
      clock,
      numbers,
      activity,
      attachments,
      directory,
      const FixedOffsetCompanyTimeService(),
    );
    await seed();
  });
  tearDown(() => db.close());

  ServiceInspectionDraft inspectionDraft({String assignmentId = 'ja1'}) =>
      ServiceInspectionDraft(
        sourceJobAssignmentId: assignmentId,
        visitDate: DateTime.utc(2026, 2, 12),
        visitMinutes: 630,
        technicianEmployeeId: 'e1',
        rootCauseId: 'rc1',
        chargeResponsibilityId: 'ch1',
        checklistItems: [
          ServiceInspectionChecklistItemDraft(
            id: 'ck-$assignmentId',
            workType: 'Inspect AC',
            attachments: [
              AttachmentRef(
                id: 'before-1',
                companyId: 'c1',
                ownerType: 'serviceInspectionChecklistItem',
                ownerId: 'ck-$assignmentId',
                category: AttachmentCategory.beforeWorkPhoto,
                fileName: 'before.jpg',
                displayName: 'before.jpg',
                mimeType: 'image/jpeg',
                sizeBytes: 100,
                uploadStatus: AttachmentUploadStatus.localOnly,
                syncStatus: 'pending',
                createdByUserId: 'u1',
                createdAt: now,
                updatedAt: now,
              ),
            ],
          ),
        ],
        materialRequirements: [
          ServiceInspectionMaterialRequirementDraft(
            id: 'req-$assignmentId',
            code: 'CAP-35UF',
            description: '35uF capacitor',
          ),
        ],
      );

  Future<ServiceInspection> completedInspection() async {
    final ctx = context(permissions: _all);
    final created =
        (await inspections.createInspection(ctx, inspectionDraft()))
            as Success<ServiceInspection>;
    final completed =
        (await inspections.completeInspection(ctx, created.value.id))
            as Success<ServiceInspection>;
    return completed.value;
  }

  ServiceWorkExecutionDraft executionDraft({
    required String inspectionId,
    String jobOrderReference = '',
    String quotationReference = '',
    List<ServiceWorkExecutionLineDraft>? workLines,
    List<ServiceWorkExecutionMaterialUsedDraft>? materialsUsed,
    List<ServiceWorkExecutionPhotoEntryDraft>? photoEntries,
  }) => ServiceWorkExecutionDraft(
    sourceInspectionId: inspectionId,
    jobOrderReference: jobOrderReference,
    quotationReference: quotationReference,
    workLines:
        workLines ??
        [
          ServiceWorkExecutionLineDraft(
            id: 'wl1',
            sourceJobAssignmentLineId: 'ja1-l1',
            work: 'Inspect and replace faulty capacitor',
            description: 'Replace defective capacitor and test cooling',
            serviceTeamId: 't1',
            employeeId: 'e1',
          ),
          ServiceWorkExecutionLineDraft(
            id: 'wl2',
            work: 'Verify airflow',
            employeeId: 'e1',
          ),
        ],
    materialsUsed: materialsUsed ?? const [],
    afterWorkPhotoEntries: photoEntries ?? const [],
  );

  Future<ServiceWorkExecution> createExecution({
    required String inspectionId,
    ServiceWorkExecutionDraft? draft,
  }) async {
    final result = await repo.createExecution(
      context(permissions: _all),
      draft ?? executionDraft(inspectionId: inspectionId),
    );
    return (result as Success<ServiceWorkExecution>).value;
  }

  test(
    'client traceability: no fake duration and no job order/quotation entity',
    () async {
      final columns = await db
          .customSelect('PRAGMA table_info(service_work_execution_lines)')
          .get();
      final names = {for (final r in columns) r.read<String>('name')};
      expect(names, isNot(contains('duration')));
      expect(names, isNot(contains('work_time_minutes')));
      expect(names, isNot(contains('hours')));

      final materialColumns = await db
          .customSelect(
            'PRAGMA table_info(service_work_execution_materials_used)',
          )
          .get();
      final materialNames = {
        for (final r in materialColumns) r.read<String>('name'),
      };
      expect(materialNames, isNot(contains('quantity')));
      expect(materialNames, isNot(contains('batch_number')));
      expect(materialNames, isNot(contains('unit')));
      expect(materialNames, isNot(contains('unit_price')));

      final tables = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND (lower(name) LIKE '%job_order%' OR lower(name) LIKE '%quotation%')",
          )
          .get();
      expect(tables, isEmpty);

      // Legacy "Work Time" maps to lineNumber / S.No, not a duration.
      final inspection = await completedInspection();
      final execution = await createExecution(inspectionId: inspection.id);
      expect(execution.workLines.first.lineNumber, 1);
      expect(execution.workLines[1].lineNumber, 2);
    },
  );

  test('create from completed inspection derives assignment/enquiry', () async {
    final inspection = await completedInspection();
    final execution = await createExecution(inspectionId: inspection.id);
    expect(execution.executionNumber, 'WE-000001');
    expect(execution.sourceInspectionId, inspection.id);
    expect(execution.sourceJobAssignmentId, inspection.sourceJobAssignmentId);
    expect(execution.sourceEnquiryId, inspection.sourceEnquiryId);
    expect(execution.status, ServiceWorkExecutionStatus.pending);
  });

  test(
    'pending or cancelled inspection cannot create a work execution',
    () async {
      final ctx = context(permissions: _all);
      final pending =
          (await inspections.createInspection(ctx, inspectionDraft()))
              as Success<ServiceInspection>;
      final pendingResult = await repo.createExecution(
        ctx,
        executionDraft(inspectionId: pending.value.id),
      );
      expect(
        (pendingResult as Failed<ServiceWorkExecution>).failure.code,
        'servicesWorkExecutionInspectionNotEligible',
      );

      await inspections.cancelInspection(ctx, pending.value.id);
      final cancelledResult = await repo.createExecution(
        ctx,
        executionDraft(inspectionId: pending.value.id),
      );
      expect(
        (cancelledResult as Failed<ServiceWorkExecution>).failure.code,
        'servicesWorkExecutionInspectionNotEligible',
      );
    },
  );

  test('one active work execution per inspection', () async {
    final inspection = await completedInspection();
    await createExecution(inspectionId: inspection.id);
    final second = await repo.createExecution(
      context(permissions: _all),
      executionDraft(inspectionId: inspection.id),
    );
    expect(
      (second as Failed<ServiceWorkExecution>).failure.code,
      'servicesWorkExecutionAlreadyActive',
    );
  });

  test(
    'job assignment lines prefill work, description, team and employee',
    () async {
      final inspection = await completedInspection();
      final cubit = ServiceWorkExecutionFormCubit(
        repo,
        context(permissions: _all),
        null,
        initialInspectionId: inspection.id,
      );
      addTearDown(cubit.close);
      await cubit.init();
      final lines = cubit.state.draft.workLines;
      expect(lines, hasLength(1));
      expect(lines.single.work, 'Inspect AC');
      expect(lines.single.description, 'Inspect cooling circuit');
      expect(lines.single.serviceTeamId, 't1');
      expect(lines.single.employeeId, 'e1');
      expect(lines.single.sourceJobAssignmentLineId, 'ja1-l1');
    },
  );

  test(
    'start work sets timestamp and transitions status to in progress',
    () async {
      final inspection = await completedInspection();
      final ctx = context(permissions: _all);
      final execution =
          (await repo.createExecution(
                ctx,
                executionDraft(inspectionId: inspection.id),
              ))
              as Success<ServiceWorkExecution>;
      final started =
          (await repo.startWorkLine(ctx, execution.value.id, 'wl1'))
              as Success<ServiceWorkExecution>;
      expect(started.value.workLines.first.startedAtUtc, now);
      expect(started.value.status, ServiceWorkExecutionStatus.inProgress);

      // Double tap never creates a second timestamp.
      final again = await repo.startWorkLine(ctx, execution.value.id, 'wl1');
      expect(
        (again as Failed<ServiceWorkExecution>).failure.code,
        'servicesWorkExecutionLineAlreadyStarted',
      );
    },
  );

  test('end work sets the end timestamp and requires a started line', () async {
    final inspection = await completedInspection();
    final ctx = context(permissions: _all);
    final execution =
        (await repo.createExecution(
              ctx,
              executionDraft(inspectionId: inspection.id),
            ))
            as Success<ServiceWorkExecution>;
    final beforeStart = await repo.endWorkLine(ctx, execution.value.id, 'wl1');
    expect(
      (beforeStart as Failed<ServiceWorkExecution>).failure.code,
      'servicesWorkExecutionLineNotStarted',
    );
    await repo.startWorkLine(ctx, execution.value.id, 'wl1');
    final ended =
        (await repo.endWorkLine(ctx, execution.value.id, 'wl1'))
            as Success<ServiceWorkExecution>;
    expect(ended.value.workLines.first.endedAtUtc, now);
    final endedAgain = await repo.endWorkLine(ctx, execution.value.id, 'wl1');
    expect(
      (endedAgain as Failed<ServiceWorkExecution>).failure.code,
      'servicesWorkExecutionLineAlreadyEnded',
    );
  });

  test('an invalid end-before-start range prevents completion', () async {
    final inspection = await completedInspection();
    final execution = await createExecution(inspectionId: inspection.id);
    await repo.startWorkLine(context(permissions: _all), execution.id, 'wl1');
    // Force an invalid range directly (administrative corruption simulation).
    await db.customUpdate(
      'UPDATE service_work_execution_lines SET ended_at_utc=? WHERE company_id=? AND id=?',
      variables: [
        Variable(now.subtract(const Duration(hours: 1))),
        const Variable('c1'),
        const Variable('wl1'),
      ],
    );
    final result = await repo.completeExecution(
      context(permissions: _all),
      execution.id,
    );
    expect(
      (result as Failed<ServiceWorkExecution>).failure.code,
      'servicesWorkExecutionInvalidTimeRange',
    );
  });

  test('complete requires all work lines finished', () async {
    final inspection = await completedInspection();
    final ctx = context(permissions: _all);
    final execution = await createExecution(inspectionId: inspection.id);
    final incomplete = await repo.completeExecution(ctx, execution.id);
    expect(
      (incomplete as Failed<ServiceWorkExecution>).failure.code,
      'servicesWorkExecutionNotCompletable',
    );

    for (final lineId in ['wl1', 'wl2']) {
      await repo.startWorkLine(ctx, execution.id, lineId);
      await repo.endWorkLine(ctx, execution.id, lineId);
    }
    final completed =
        (await repo.completeExecution(ctx, execution.id))
            as Success<ServiceWorkExecution>;
    expect(completed.value.status, ServiceWorkExecutionStatus.completed);

    // Cancellation is not casual after completion.
    final cancel = await repo.cancelExecution(ctx, execution.id);
    expect(
      (cancel as Failed<ServiceWorkExecution>).failure.code,
      'servicesWorkExecutionAlreadyCompleted',
    );
  });

  test('edit and perform are separate capabilities', () async {
    final inspection = await completedInspection();
    final creator = context(
      permissions: {
        AppPermission.serviceWorkExecutionCreate,
        AppPermission.serviceWorkExecutionEdit,
        AppPermission.serviceWorkExecutionViewAll,
      },
    );
    final created =
        (await repo.createExecution(
              creator,
              executionDraft(inspectionId: inspection.id),
            ))
            as Success<ServiceWorkExecution>;

    // Edit without perform: structural edit works, operational start is denied.
    final edited = await repo.updateExecution(
      creator,
      created.value.id,
      executionDraft(
        inspectionId: inspection.id,
        workLines: [
          ServiceWorkExecutionLineDraft(
            id: 'wl1',
            work: 'Inspect and replace faulty capacitor',
            description: 'Updated description',
            serviceTeamId: 't1',
            employeeId: 'e1',
          ),
          ServiceWorkExecutionLineDraft(
            id: 'wl2',
            work: 'Verify airflow',
            employeeId: 'e1',
          ),
        ],
      ),
    );
    expect(edited, isA<Success<ServiceWorkExecution>>());
    final startDenied = await repo.startWorkLine(
      creator,
      created.value.id,
      'wl1',
    );
    expect(
      (startDenied as Failed<ServiceWorkExecution>).failure.code,
      'servicesWorkExecutionDenied',
    );

    // Perform without edit: operational actions work, structural edit denied.
    final performer = context(
      permissions: {
        AppPermission.serviceWorkExecutionViewAll,
        AppPermission.serviceWorkExecutionPerform,
      },
    );
    final startOk = await repo.startWorkLine(
      performer,
      created.value.id,
      'wl1',
    );
    expect(startOk, isA<Success<ServiceWorkExecution>>());
    final editDenied = await repo.updateExecution(
      performer,
      created.value.id,
      executionDraft(inspectionId: inspection.id),
    );
    expect(
      (editDenied as Failed<ServiceWorkExecution>).failure.code,
      'servicesWorkExecutionDenied',
    );
  });

  test('material used keeps code and description and mutates no stock', () async {
    final inspection = await completedInspection();
    final execution = await createExecution(inspectionId: inspection.id);
    final result =
        (await repo.addMaterialUsed(
              context(permissions: _all),
              execution.id,
              ServiceWorkExecutionMaterialUsedDraft(
                id: 'mu1',
                code: 'CAP-35UF',
                description: '35uF capacitor',
              ),
            ))
            as Success<ServiceWorkExecution>;
    expect(result.value.materialsUsed, hasLength(1));
    expect(result.value.materialsUsed.single.code, 'CAP-35UF');

    // No inventory/stock tables exist.
    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND (lower(name) LIKE '%stock%' OR lower(name) LIKE '%inventory%' OR lower(name) LIKE '%warehouse%' OR lower(name) LIKE '%voucher%')",
        )
        .get();
    expect(tables, isEmpty);
  });

  test(
    'source material request line links without mutating the request',
    () async {
      final inspection = await completedInspection();
      await db
          .into(db.serviceMaterialRequests)
          .insert(
            ServiceMaterialRequestsCompanion.insert(
              id: 'mr1',
              companyId: 'c1',
              requestNumber: 'MR-000001',
              requestDate: now,
              sourceInspectionId: inspection.id,
              sourceJobAssignmentId: inspection.sourceJobAssignmentId,
              sourceEnquiryId: inspection.sourceEnquiryId,
              status: 'open',
              createdAt: now,
              updatedAt: now,
              createdByUserId: 'u1',
              updatedByUserId: 'u1',
              syncStatus: 'synced',
            ),
            mode: InsertMode.insertOrIgnore,
          );
      await db
          .into(db.serviceMaterialRequestLines)
          .insert(
            ServiceMaterialRequestLinesCompanion.insert(
              id: 'mrl1',
              companyId: 'c1',
              materialRequestId: 'mr1',
              lineNumber: 1,
              code: 'CAP-35UF',
              description: '35uF capacitor',
              quantity: 1,
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      final execution = await createExecution(inspectionId: inspection.id);
      final result =
          (await repo.addMaterialUsed(
                context(permissions: _all),
                execution.id,
                ServiceWorkExecutionMaterialUsedDraft(
                  id: 'mu1',
                  sourceMaterialRequestLineId: 'mrl1',
                  code: 'CAP-35UF',
                  description: '35uF capacitor',
                ),
              ))
              as Success<ServiceWorkExecution>;
      expect(
        result.value.materialsUsed.single.sourceMaterialRequestLineId,
        'mrl1',
      );

      final request = await (db.select(
        db.serviceMaterialRequests,
      )..where((t) => t.id.equals('mr1'))).getSingle();
      expect(request.status, 'open');
    },
  );

  test(
    'after-work photos persist description and multiple attachments',
    () async {
      final inspection = await completedInspection();
      final execution = await createExecution(inspectionId: inspection.id);
      AttachmentRef ref(String id) => AttachmentRef(
        id: id,
        companyId: 'c1',
        ownerType: 'serviceWorkExecutionPhotoEntry',
        ownerId: 'p1',
        category: AttachmentCategory.afterWorkPhoto,
        fileName: '$id.jpg',
        displayName: '$id.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 100,
        uploadStatus: AttachmentUploadStatus.localOnly,
        syncStatus: 'pending',
        createdByUserId: 'u1',
        createdAt: now,
        updatedAt: now,
      );
      final result =
          (await repo.addPhotoEntry(
                context(permissions: _all),
                execution.id,
                ServiceWorkExecutionPhotoEntryDraft(
                  id: 'p1',
                  description: 'New capacitor installed and unit restored',
                  attachments: [ref('a1'), ref('a2')],
                ),
              ))
              as Success<ServiceWorkExecution>;
      final entry = result.value.afterWorkPhotoEntries.single;
      expect(entry.description, 'New capacitor installed and unit restored');
      expect(entry.attachments, hasLength(2));
      final stored = await attachments.getForOwners(
        companyId: 'c1',
        ownerType: 'serviceWorkExecutionPhotoEntry',
        ownerIds: ['p1'],
      );
      expect((stored as Success<List<AttachmentRef>>).value, hasLength(2));
      expect(stored.value.first.category, AttachmentCategory.afterWorkPhoto);
    },
  );

  test('before work photos remain separate from after work photos', () async {
    final inspection = await completedInspection();
    final execution = await createExecution(inspectionId: inspection.id);
    final view =
        (await repo.getExecution(context(permissions: _all), execution.id)
                as Success<ServiceWorkExecutionView?>)
            .value!;
    final before = [
      for (final item in view.checklistItems) ...item.attachments,
    ];
    expect(before, hasLength(1));
    expect(before.single.category, AttachmentCategory.beforeWorkPhoto);
    final afterStored = await attachments.getForOwners(
      companyId: 'c1',
      ownerType: 'serviceWorkExecutionPhotoEntry',
      ownerIds: const [],
    );
    expect((afterStored as Success<List<AttachmentRef>>).value, isEmpty);
  });

  test(
    'job order and quotation references are preserved without entities',
    () async {
      final inspection = await completedInspection();
      final ctx = context(permissions: _all);
      final result =
          (await repo.createExecution(
                    ctx,
                    executionDraft(
                      inspectionId: inspection.id,
                      jobOrderReference: 'JOB-9001',
                      quotationReference: 'QUO-7001',
                    ),
                  )
                  as Success<ServiceWorkExecution>)
              .value;
      expect(result.jobOrderReference, 'JOB-9001');
      expect(result.quotationReference, 'QUO-7001');
    },
  );

  test('assigned, team and all scopes restrict visibility', () async {
    final inspection = await completedInspection();
    final execution = await createExecution(inspectionId: inspection.id);

    Future<List<String>> ids(AuthContext ctx) async {
      final result = await repo.watchExecutions(ctx).first;
      return (result as Success<ServiceWorkExecutionPage>).value.items
          .map((i) => i.id)
          .toList();
    }

    expect(
      await ids(
        context(
          permissions: {AppPermission.serviceWorkExecutionViewAssigned},
          employeeId: 'e1',
        ),
      ),
      contains(execution.id),
    );
    expect(
      await ids(
        context(
          permissions: {AppPermission.serviceWorkExecutionViewAssigned},
          employeeId: 'e3',
        ),
      ),
      isEmpty,
    );
    expect(
      await ids(
        context(
          permissions: {AppPermission.serviceWorkExecutionViewTeam},
          employeeId: 'e2',
        ),
      ),
      contains(execution.id),
    );
    expect(
      await ids(
        context(
          permissions: {AppPermission.serviceWorkExecutionViewTeam},
          employeeId: 'e3',
        ),
      ),
      isEmpty,
    );
    expect(
      await ids(
        context(permissions: {AppPermission.serviceWorkExecutionViewAll}),
      ),
      contains(execution.id),
    );
    expect(
      await ids(
        context(
          permissions: {AppPermission.serviceWorkExecutionViewAll},
          companyId: 'c2',
        ),
      ),
      isEmpty,
    );
  });

  test('direct access and attachments enforce object scope', () async {
    final inspection = await completedInspection();
    final execution = await createExecution(inspectionId: inspection.id);
    final unrelated = context(
      permissions: {AppPermission.serviceWorkExecutionViewAssigned},
      employeeId: 'e3',
    );
    final read = await repo.getExecution(unrelated, execution.id);
    expect((read as Success<ServiceWorkExecutionView?>).value, isNull);
  });

  test(
    'create works without full inspection access via restricted selector',
    () async {
      final inspection = await completedInspection();
      final restricted = context(
        permissions: {AppPermission.serviceWorkExecutionCreate},
      );
      final eligible =
          (await repo.searchEligibleInspections(restricted)
                  as Success<List<ServiceWorkEligibleInspectionRef>>)
              .value;
      expect(eligible.map((e) => e.id), contains(inspection.id));
      final source = await repo.getSourceContext(restricted, inspection.id);
      expect(source, isA<Success<ServiceWorkExecutionSourceContext?>>());
      final created = await repo.createExecution(
        restricted,
        executionDraft(inspectionId: inspection.id),
      );
      expect(created, isA<Success<ServiceWorkExecution>>());
      final inspectionsRead = await inspections
          .watchInspections(restricted)
          .first;
      expect(inspectionsRead, isA<Failed<ServiceInspectionPage>>());
    },
  );

  test('permissions are enforced live without relogin', () async {
    final inspection = await completedInspection();
    final createOnly = context(
      permissions: {AppPermission.serviceWorkExecutionCreate},
    );
    final created = await repo.createExecution(
      createOnly,
      executionDraft(inspectionId: inspection.id),
    );
    expect(created, isA<Success<ServiceWorkExecution>>());
    final noPermission = context(permissions: const {});
    expect(
      await repo.watchExecutions(noPermission).first,
      isA<Failed<ServiceWorkExecutionPage>>(),
    );
    final viewer = context(
      permissions: {AppPermission.serviceWorkExecutionViewAssigned},
      employeeId: 'e1',
    );
    expect(
      await repo.watchExecutions(viewer).first,
      isA<Success<ServiceWorkExecutionPage>>(),
    );
  });

  test('company isolation prevents cross-company relationships', () async {
    final inspection = await completedInspection();
    final execution = await createExecution(inspectionId: inspection.id);
    final otherCompany = context(
      permissions: {AppPermission.serviceWorkExecutionViewAll},
      companyId: 'c2',
    );
    expect(
      await repo.watchExecutions(otherCompany).first,
      isA<Success<ServiceWorkExecutionPage>>(),
    );
    final page =
        (await repo.watchExecutions(otherCompany).first)
            as Success<ServiceWorkExecutionPage>;
    expect(page.value.items, isEmpty);
    final read = await repo.getExecution(otherCompany, execution.id);
    expect((read as Success<ServiceWorkExecutionView?>).value, isNull);
  });

  test('search text is derived from header and child data', () async {
    final inspection = await completedInspection();
    await createExecution(
      inspectionId: inspection.id,
      draft: executionDraft(
        inspectionId: inspection.id,
        workLines: [
          ServiceWorkExecutionLineDraft(
            id: 'wl1',
            work: 'Replace compressor',
            description: 'Swap compressor',
          ),
        ],
      ),
    );
    final found =
        (await repo
                    .watchExecutions(
                      context(permissions: _all),
                      query: 'compressor',
                    )
                    .first
                as Success<ServiceWorkExecutionPage>)
            .value;
    expect(found.items, hasLength(1));
  });

  test('material request context is read-only and linked', () async {
    final inspection = await completedInspection();
    await db
        .into(db.serviceMaterialRequests)
        .insert(
          ServiceMaterialRequestsCompanion.insert(
            id: 'mr1',
            companyId: 'c1',
            requestNumber: 'MR-000001',
            requestDate: now,
            sourceInspectionId: inspection.id,
            sourceJobAssignmentId: inspection.sourceJobAssignmentId,
            sourceEnquiryId: inspection.sourceEnquiryId,
            status: 'open',
            createdAt: now,
            updatedAt: now,
            createdByUserId: 'u1',
            updatedByUserId: 'u1',
            syncStatus: 'synced',
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await db
        .into(db.serviceMaterialRequestLines)
        .insert(
          ServiceMaterialRequestLinesCompanion.insert(
            id: 'mrl1',
            companyId: 'c1',
            materialRequestId: 'mr1',
            lineNumber: 1,
            code: 'CAP-35UF',
            description: '35uF capacitor',
            quantity: 1,
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    final source =
        (await repo.getSourceContext(context(permissions: _all), inspection.id)
                as Success<ServiceWorkExecutionSourceContext?>)
            .value!;
    expect(source.linkedMaterialRequests.single.requestNumber, 'MR-000001');
    expect(source.materialRequestLines.single.code, 'CAP-35UF');
    final linked = source.linkedMaterialRequests.single;
    expect(linked.status, 'open');
    expect(linked.itemCount, 1);
  });

  test('removing a missing material used is a safe no-op', () async {
    final inspection = await completedInspection();
    final execution = await createExecution(inspectionId: inspection.id);
    final removed = await repo.removeMaterialUsed(
      context(permissions: _all),
      execution.id,
      'missing',
    );
    expect(removed, isA<Success<ServiceWorkExecution>>());
  });

  test(
    'cancelled material requests are excluded from linked context',
    () async {
      final inspection = await completedInspection();
      await db
          .into(db.serviceMaterialRequests)
          .insert(
            ServiceMaterialRequestsCompanion.insert(
              id: 'mr-cancelled',
              companyId: 'c1',
              requestNumber: 'MR-000002',
              requestDate: now,
              sourceInspectionId: inspection.id,
              sourceJobAssignmentId: inspection.sourceJobAssignmentId,
              sourceEnquiryId: inspection.sourceEnquiryId,
              status: 'cancelled',
              createdAt: now,
              updatedAt: now,
              createdByUserId: 'u1',
              updatedByUserId: 'u1',
              syncStatus: 'synced',
            ),
            mode: InsertMode.insertOrIgnore,
          );
      await db
          .into(db.serviceMaterialRequestLines)
          .insert(
            ServiceMaterialRequestLinesCompanion.insert(
              id: 'mrl-cancelled',
              companyId: 'c1',
              materialRequestId: 'mr-cancelled',
              lineNumber: 1,
              code: 'WIRE-2.5',
              description: '2.5mm wire',
              quantity: 3,
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      final source =
          (await repo.getSourceContext(
                    context(permissions: _all),
                    inspection.id,
                  )
                  as Success<ServiceWorkExecutionSourceContext?>)
              .value!;
      expect(source.linkedMaterialRequests, isEmpty);
      expect(source.materialRequestLines, isEmpty);
    },
  );

  test('after work photos enforce work execution object scope', () async {
    final inspection = await completedInspection();
    final execution = await createExecution(
      inspectionId: inspection.id,
      draft: executionDraft(
        inspectionId: inspection.id,
        photoEntries: [
          ServiceWorkExecutionPhotoEntryDraft(
            id: 'pe1',
            description: 'New capacitor installed and unit restored',
            attachments: [
              AttachmentRef(
                id: 'after-1',
                companyId: 'c1',
                ownerType: 'serviceWorkExecutionPhotoEntry',
                ownerId: 'pe1',
                category: AttachmentCategory.afterWorkPhoto,
                fileName: 'after.jpg',
                displayName: 'after.jpg',
                mimeType: 'image/jpeg',
                sizeBytes: 100,
                uploadStatus: AttachmentUploadStatus.localOnly,
                syncStatus: 'pending',
                createdByUserId: 'u1',
                createdAt: now,
                updatedAt: now,
              ),
            ],
          ),
        ],
      ),
    );
    final assigned = context(
      permissions: {AppPermission.serviceWorkExecutionViewAssigned},
      employeeId: 'e1',
    );
    final view =
        (await repo.getExecution(assigned, execution.id)
                as Success<ServiceWorkExecutionView?>)
            .value!;
    expect(
      view.execution.afterWorkPhotoEntries.single.attachments.single.id,
      'after-1',
    );

    final unrelated = context(
      permissions: {AppPermission.serviceWorkExecutionViewAssigned},
      employeeId: 'e3',
    );
    expect(
      (await repo.getExecution(unrelated, execution.id)
              as Success<ServiceWorkExecutionView?>)
          .value,
      isNull,
    );
  });
}
