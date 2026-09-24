import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/job_assignments/data/local_service_job_assignment_repository.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/notifications/data/local_notification_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_activity_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_attachment_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_document_number_service.dart';

class _FakeDirectory implements WorkforceDirectory {
  _FakeDirectory(this.refs);
  final Map<String, WorkforcePersonRef> refs;
  @override
  Future<WorkforcePersonRef?> getEmployeeReference(
    String employeeId, {
    bool includeInactive = false,
  }) async {
    final ref = refs[employeeId];
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
  AppPermission.serviceJobAssignmentViewAll,
  AppPermission.serviceJobAssignmentCreate,
  AppPermission.serviceJobAssignmentEdit,
  AppPermission.serviceJobAssignmentCancel,
};

class _FixedClock implements AppClock {
  const _FixedClock(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
}

void main() {
  late AppDatabase db;
  late LocalServiceJobAssignmentRepository repo;
  final now = DateTime.utc(2026, 1, 10, 9);
  final clock = _FixedClock(DateTime.utc(2026, 1, 10, 9));
  var seq = 0;
  String nextId() => 'id-${seq++}';

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
    await db
        .into(db.serviceTypes)
        .insert(
          ServiceTypesCompanion.insert(
            id: 'st1',
            companyId: 'c1',
            code: 'ELEC',
            name: 'Electrical',
            status: 'active',
            createdAt: now,
            updatedAt: now,
            syncStatus: 'synced',
          ),
        );
    await db
        .into(db.complaintTypes)
        .insert(
          ComplaintTypesCompanion.insert(
            id: 'ct1',
            companyId: 'c1',
            code: 'POWER',
            name: 'Power Issue',
            serviceTypeId: const Value('st1'),
            status: 'active',
            createdAt: now,
            updatedAt: now,
            syncStatus: 'synced',
          ),
        );
    await db
        .into(db.servicePriorities)
        .insert(
          ServicePrioritiesCompanion.insert(
            id: 'pr1',
            companyId: 'c1',
            code: 'HIGH',
            name: 'High',
            rank: const Value(2),
            status: 'active',
            createdAt: now,
            updatedAt: now,
            syncStatus: 'synced',
          ),
        );
    await db
        .into(db.serviceTicketTypes)
        .insert(
          ServiceTicketTypesCompanion.insert(
            id: 'tt1',
            companyId: 'c1',
            code: 'COMPLAINT',
            name: 'Complaint',
            status: 'active',
            createdAt: now,
            updatedAt: now,
            syncStatus: 'synced',
          ),
        );
    // Team with a member.
    await db
        .into(db.serviceTeams)
        .insert(
          ServiceTeamsCompanion.insert(
            id: 'team1',
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
    await db
        .into(db.serviceTeamMembers)
        .insert(
          ServiceTeamMembersCompanion.insert(
            id: 'team1-e1',
            companyId: 'c1',
            teamId: 'team1',
            employeeId: 'e1',
            status: 'active',
            createdAt: now,
            createdByUserId: 'u1',
          ),
          mode: InsertMode.insertOrIgnore,
        );
    // Two OPEN enquiries.
    for (final id in ['enq1', 'enq2']) {
      await db
          .into(db.serviceEnquiries)
          .insert(
            ServiceEnquiriesCompanion.insert(
              id: id,
              companyId: 'c1',
              enquiryNumber: id == 'enq1' ? 'ENQ-000001' : 'ENQ-000002',
              customerId: 'cus1',
              siteId: 'site1',
              serviceTypeId: 'st1',
              complaintTypeId: 'ct1',
              priorityId: 'pr1',
              ticketTypeId: 'tt1',
              description: '',
              status: 'open',
              partySnapshot:
                  '{"customerName":"ABC Properties","customerMobile":"+971500000001","siteName":"Tower 1","buildingName":"Tower","unitNumber":"101"}',
              searchText: const Value('abc properties tower 101'),
              createdAt: now,
              updatedAt: now,
              createdByUserId: 'u1',
              updatedByUserId: 'u1',
              syncStatus: 'synced',
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  ServiceJobAssignmentDraft draft({
    String sourceEnquiryId = 'enq1',
    DateTime? visitDate,
    List<ServiceJobAssignmentLineDraft>? lines,
  }) => ServiceJobAssignmentDraft(
    sourceEnquiryId: sourceEnquiryId,
    scheduledVisitDate: visitDate ?? DateTime.utc(2026, 1, 12),
    lines:
        lines ??
        [
          ServiceJobAssignmentLineDraft(
            id: nextId(),
            work: 'Repair',
            assignedTeamId: 'team1',
          ),
        ],
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final numbers = LocalDocumentNumberService(db, clock);
    repo = LocalServiceJobAssignmentRepository(
      db,
      clock,
      numbers,
      LocalActivityRepository(db),
      LocalAttachmentRepository(db, clock),
      _FakeDirectory({
        'e1': const WorkforcePersonRef(
          id: 'e1',
          name: 'Ahmed Khan',
          employeeCode: 'EMP-1',
          linkedUserId: 'u-e1',
        ),
        'e2': const WorkforcePersonRef(
          id: 'e2',
          name: 'Sara',
          employeeCode: 'EMP-2',
        ),
      }),
      const FixedOffsetCompanyTimeService(),
      notifications: LocalNotificationRepository(db),
    );
    await seed();
  });
  tearDown(() => db.close());

  test('create assigns work, numbers it and transitions the enquiry', () async {
    final result = await repo.createAssignment(
      context(permissions: _all),
      draft(
        lines: [
          ServiceJobAssignmentLineDraft(
            id: 'l1',
            work: 'Inspect AC',
            assignedEmployeeId: 'e1',
            assignedTeamId: 'team1',
            descriptionForWork: 'Check pressure',
          ),
          ServiceJobAssignmentLineDraft(
            id: 'l2',
            work: 'Replace fitting',
            assignedTeamId: 'team1',
          ),
        ],
      ),
    );
    final assignment = (result as Success<ServiceJobAssignment>).value;
    expect(assignment.assignmentNumber, 'JA-000001');
    expect(assignment.status, ServiceJobAssignmentStatus.active);
    expect(assignment.lines, hasLength(2));
    final enquiry = await (db.select(
      db.serviceEnquiries,
    )..where((t) => t.id.equals('enq1'))).getSingle();
    expect(enquiry.status, 'assigned');
    final notifications = await db.select(db.appNotifications).get();
    expect(notifications.map((n) => n.userId), contains('u-e1'));
  });

  test('a second active assignment for the same enquiry is rejected', () async {
    await repo.createAssignment(context(permissions: _all), draft());
    final second = await repo.createAssignment(
      context(permissions: _all),
      draft(),
    );
    expect(
      (second as Failed<ServiceJobAssignment>).failure.code,
      'servicesJobAssignmentAlreadyActive',
    );
  });

  test(
    'create is idempotent and does not duplicate lines or transition',
    () async {
      final ctx = context(permissions: _all);
      final first =
          (await repo.createAssignment(
                ctx,
                draft(
                  lines: [
                    ServiceJobAssignmentLineDraft(
                      id: 'l1',
                      work: 'A',
                      assignedTeamId: 'team1',
                    ),
                  ],
                ),
                requestId: 'req-1',
              ))
              as Success<ServiceJobAssignment>;
      final retry =
          (await repo.createAssignment(
                ctx,
                draft(
                  lines: [
                    ServiceJobAssignmentLineDraft(
                      id: 'l1',
                      work: 'A',
                      assignedTeamId: 'team1',
                    ),
                  ],
                ),
                requestId: 'req-1',
              ))
              as Success<ServiceJobAssignment>;
      expect(retry.value.id, first.value.id);
      expect(await db.select(db.serviceJobAssignments).get(), hasLength(1));
      expect(await db.select(db.serviceJobAssignmentLines).get(), hasLength(1));
    },
  );

  test('cancel is historical and returns the enquiry to OPEN', () async {
    final ctx = context(permissions: _all);
    final created =
        (await repo.createAssignment(ctx, draft()))
            as Success<ServiceJobAssignment>;
    expect(
      await repo.cancelAssignment(ctx, created.value.id),
      isA<Success<void>>(),
    );
    final assignment = await (db.select(
      db.serviceJobAssignments,
    )..where((t) => t.id.equals(created.value.id))).getSingle();
    expect(assignment.status, 'cancelled');
    final enquiry = await (db.select(
      db.serviceEnquiries,
    )..where((t) => t.id.equals('enq1'))).getSingle();
    expect(enquiry.status, 'open');
    expect(
      (await repo.cancelAssignment(ctx, created.value.id) as Failed<void>)
          .failure
          .code,
      'servicesJobAssignmentAlreadyCancelled',
    );
  });

  test('scopes restrict visibility (all / assigned / team)', () async {
    final all = context(permissions: _all);
    final created =
        (await repo.createAssignment(
              all,
              draft(
                lines: [
                  ServiceJobAssignmentLineDraft(
                    id: 'l1',
                    work: 'A',
                    assignedEmployeeId: 'e1',
                    assignedTeamId: 'team1',
                  ),
                ],
              ),
            ))
            as Success<ServiceJobAssignment>;

    Future<List<String>> visibleIds(AuthContext ctx) async {
      final page = await repo.watchAssignments(ctx).first;
      return (page as Success<ServiceJobAssignmentPage>).value.items
          .map((i) => i.id)
          .toList();
    }

    expect(await visibleIds(all), contains(created.value.id));
    // Employee directly assigned sees it.
    expect(
      await visibleIds(
        context(
          permissions: {AppPermission.serviceJobAssignmentViewAssigned},
          employeeId: 'e1',
        ),
      ),
      contains(created.value.id),
    );
    // Employee in the assigned team sees it.
    expect(
      await visibleIds(
        context(
          permissions: {AppPermission.serviceJobAssignmentViewTeam},
          employeeId: 'e1',
        ),
      ),
      contains(created.value.id),
    );
    // Unrelated employee sees nothing.
    expect(
      await visibleIds(
        context(
          permissions: {AppPermission.serviceJobAssignmentViewAssigned},
          employeeId: 'e2',
        ),
      ),
      isEmpty,
    );
    // Other company sees nothing.
    expect(
      await visibleIds(context(permissions: _all, companyId: 'c2')),
      isEmpty,
    );
  });

  test(
    'restricted enquiry refs return only open, unassigned enquiries',
    () async {
      final ctx = context(permissions: _all);
      final before = await repo.searchAssignableEnquiries(ctx);
      expect(
        (before as Success<List<ServiceAssignableEnquiryRef>>).value,
        hasLength(2),
      );
      await repo.createAssignment(ctx, draft(sourceEnquiryId: 'enq1'));
      final after = await repo.searchAssignableEnquiries(ctx);
      expect(
        (after as Success<List<ServiceAssignableEnquiryRef>>).value.map(
          (e) => e.id,
        ),
        ['enq2'],
      );
    },
  );

  test(
    'reference validation rejects invalid employees, teams and membership',
    () async {
      final ctx = context(permissions: _all);
      expect(
        (await repo.createAssignment(
                  ctx,
                  draft(
                    lines: [
                      ServiceJobAssignmentLineDraft(
                        id: 'l1',
                        work: 'A',
                        assignedEmployeeId: 'missing',
                      ),
                    ],
                  ),
                )
                as Failed<ServiceJobAssignment>)
            .failure
            .code,
        'servicesJobAssignmentEmployeeInvalid',
      );
      expect(
        (await repo.createAssignment(
                  ctx,
                  draft(
                    lines: [
                      ServiceJobAssignmentLineDraft(
                        id: 'l2',
                        work: 'A',
                        assignedTeamId: 'missing',
                      ),
                    ],
                  ),
                )
                as Failed<ServiceJobAssignment>)
            .failure
            .code,
        'servicesJobAssignmentTeamInvalid',
      );
      expect(
        (await repo.createAssignment(
                  ctx,
                  draft(
                    lines: [
                      ServiceJobAssignmentLineDraft(
                        id: 'l3',
                        work: 'A',
                        assignedEmployeeId: 'e2',
                        assignedTeamId: 'team1',
                      ),
                    ],
                  ),
                )
                as Failed<ServiceJobAssignment>)
            .failure
            .code,
        'servicesJobAssignmentEmployeeNotInTeam',
      );
      expect(await db.select(db.serviceJobAssignments).get(), isEmpty);
    },
  );

  test('a cancelled enquiry cannot be assigned', () async {
    await db.customUpdate(
      "UPDATE service_enquiries SET status='cancelled' WHERE id='enq1'",
    );
    final result = await repo.createAssignment(
      context(permissions: _all),
      draft(),
    );
    expect(
      (result as Failed<ServiceJobAssignment>).failure.code,
      'servicesJobAssignmentEnquiryNotOpen',
    );
  });

  test('view exposes source enquiry context, material and issues', () async {
    final ctx = context(permissions: _all);
    final created =
        (await repo.createAssignment(ctx, draft()))
            as Success<ServiceJobAssignment>;
    final view =
        (await repo.getAssignment(ctx, created.value.id))
            as Success<ServiceJobAssignmentView?>;
    expect(view.value!.enquiryNumber, 'ENQ-000001');
    expect(view.value!.customerName, 'ABC Properties');
    expect(view.value!.materialReceived, MaterialReceived.no);
    expect(view.value!.partySnapshot.buildingName, 'Tower');
  });

  test('update reassigns lines and records activity', () async {
    final ctx = context(permissions: _all);
    final created =
        (await repo.createAssignment(
              ctx,
              draft(
                lines: [
                  ServiceJobAssignmentLineDraft(
                    id: 'l1',
                    work: 'A',
                    assignedTeamId: 'team1',
                  ),
                ],
              ),
            ))
            as Success<ServiceJobAssignment>;
    final updated =
        (await repo.updateAssignment(
              ctx,
              created.value.id,
              draft(
                visitDate: DateTime.utc(2026, 2, 1),
                lines: [
                  ServiceJobAssignmentLineDraft(
                    id: 'l1',
                    work: 'A revised',
                    assignedTeamId: 'team1',
                  ),
                  ServiceJobAssignmentLineDraft(
                    id: 'l2',
                    work: 'B',
                    assignedEmployeeId: 'e1',
                  ),
                ],
              ),
            ))
            as Success<ServiceJobAssignment>;
    expect(updated.value.version, 2);
    expect(updated.value.lines, hasLength(2));
    final events = await db.select(db.businessActivityEvents).get();
    expect(
      events.map((e) => e.eventType),
      containsAll([
        'services.jobAssignment.updated',
        'services.jobAssignment.visitDateChanged',
        'services.jobAssignment.assignmentChanged',
      ]),
    );
  });

  test('summary counts active, today and upcoming within scope', () async {
    final ctx = context(permissions: _all);
    await repo.createAssignment(
      ctx,
      draft(visitDate: DateTime.utc(2026, 1, 10)),
    );
    await repo.createAssignment(
      ctx,
      draft(sourceEnquiryId: 'enq2', visitDate: DateTime.utc(2026, 1, 20)),
    );
    final summary =
        (await repo.summary(ctx)) as Success<ServiceJobAssignmentSummary>;
    expect(summary.value.activeCount, 2);
    expect(summary.value.todayCount, 1);
    expect(summary.value.upcomingCount, 1);
  });
}
