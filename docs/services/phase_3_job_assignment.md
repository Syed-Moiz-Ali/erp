# Services Phase 3 — Job Assignment & Scheduling

Phase 3 adds the **Job Assignment & Scheduling** transaction: assigning work from
an eligible Service Enquiry to Employees and/or Service Teams, scheduled by Visit
Date. Inspection, Material Request and Work Execution are **not** implemented.

## Client reference mapping

See [client_reference_traceability.md](client_reference_traceability.md) (Screen:
Job Assignment & Scheduling) for the field-by-field mapping. Company, Assignment
No, Date, Insert/Update By are system/sequence/audit-derived; Customer/Mobile/
Complaint/Priority/Tenant/Building/Unit/Material Received come from the source
Enquiry (read-only); Visit Date is the scheduling input.

## Module structure

```text
lib/modules/services/job_assignments/
  domain/        service_job_assignment.dart, service_job_assignment_scope.dart,
                 service_job_assignment_repository.dart
  data/          local_service_job_assignment_repository.dart
  application/   service_job_assignment_use_cases.dart
  presentation/  bloc/service_job_assignment_blocs.dart
                 pages/service_job_assignment_{list,detail,form}_page.dart
                 widgets/job_assignment_widgets.dart
lib/modules/services/presentation/widgets/
  enquiry_job_assignment_section.dart   (Enquiry detail integration)
```

## Domain

`ServiceJobAssignment` (header) + `ServiceJobAssignmentLine[]`:
- Header: `id`, `companyId`, `assignmentNumber`, `assignmentDate`,
  `sourceEnquiryId`, `scheduledVisitDate`, `status` (`active`/`cancelled`),
  `version`, timestamps, `createdByUserId`/`updatedByUserId`, `requestId`,
  `syncStatus`.
- Line: stable UUID `id`, `lineNumber`, `work`, `assignedEmployeeId?`,
  `assignedTeamId?`, `status` (`pending`), `descriptionForWork`.

Customer/Site/Complaint/Priority/Tenant/Building/Unit/Material Received are read
from the source Enquiry (never re-typed, never duplicated as editable fields).
`work` (task) and `descriptionForWork` (instructions) are separate.

**TBD — CLIENT CONFIRMATION:** the exact per-line Status vocabulary is unknown;
only a minimal, non-workflow `pending` default is modelled.

## Header / detail relationship & one active assignment

One Job Assignment selects **one** Enquiry and holds **1..N** work lines. V1
enforces **one ACTIVE assignment per Enquiry** (partial unique index). A line may
target an Employee, a Service Team, or both; if both, the employee must be a
member of that team (never auto-modified).

## Enquiry state transition

`OPEN → (create assignment) → ASSIGNED`; `ASSIGNED → (cancel last active
assignment) → OPEN`. `CANCELLED` remains terminal. An ASSIGNED enquiry is no
longer freely editable (the assignment represents operational execution); its
detail stays readable. Both transitions are transactional and emit
`services.enquiry.assigned` / `services.enquiry.reopened` activity.

## Employee / Team assignment

- Technician = existing **Employee** via `WorkforceDirectory` (no Technician
  table).
- Team = explicit **Service Team** selector (`ServiceTeamRepository`), replacing
  the legacy checkbox.
- New assignment selects only active, same-company employees/teams; historical
  inactive targets remain resolvable.
- The HR workforce contract now uses restricted company-scoped lookups
  (`searchAssignableCompanyEmployees`/`getCompanyEmployee`/`getCompanyEmployees`)
  so an assignment operator can reference employees **without** HR directory
  access. Team membership does not grant app access, and assignment does not
  grant permissions.

## Visit Date

`scheduledVisitDate`, validated via `CompanyTimeService` (company timezone, no
device-time assumptions). No time/duration/recurrence fields (not in the client
screen).

## Assignment number & date

Shared `DocumentNumberService` with `DocumentSequenceType.serviceJobAssignment`
(prefix `JA`). `assignmentDate` is the company business date, system-derived.

## Permissions & scope

- `services.jobAssignments.view` with scopes `assigned`/`team`/`all`
  (`ServiceJobAssignmentScopeResolver` over the shared `AccessScopeResolver`).
- `services.jobAssignments.create` / `.edit` / `.cancel` (scope none; imply ALL
  view via `permissionViewDependencies`).
- Restricted Enquiry/Employee/Team reference lookups are authorized by
  Create/Edit. See
  [permission_coverage.md](../architecture/permission_coverage.md).

## Routes & navigation

`/app/services/job-assignments`, `/new`, `/:assignmentId`, `/:assignmentId/edit`.
Navigation: Overview, Enquiries, **Job Assignments**, Customers, Sites, Teams,
Settings. Direct URLs are guarded; the record scope is enforced on every read.

## Repository, use cases & atomicity

`ServiceJobAssignmentRepository` / `LocalServiceJobAssignmentRepository`:
`watchAssignments`, `watchAssignment`/`getAssignment`,
`createAssignment`/`updateAssignment`/`cancelAssignment`,
`searchAssignableEnquiries`, `getAssignableEnquiryContext`,
`getAssignmentForEnquiry`/`watchAssignmentForEnquiry`, `summary`,
`watchUpcomingAssignments`. Use cases mirror these.

Create/update/cancel run in **one database transaction**: sequence + header +
lines + Enquiry transition + activity + outbox (+ notifications). A failure
leaves no partial state. Idempotency uses `requestId` (no duplicate assignment,
lines or transition). The list resolves Enquiry/Customer/priority/employee/team
in batched queries (no N+1). Lines are soft-removed (`removedAt`), never hard
deleted.

## Outbox & activity

Operations `SERVICES_JOB_ASSIGNMENT_CREATE|UPDATE|CANCEL`. Payload: header
(`id`, `assignmentNumber`, `sourceEnquiryId`, `scheduledVisitDate`, `status`,
`version`) + `lines[]` (`id`, `lineNumber`, `work`, `assignedEmployeeId`,
`assignedTeamId`, `status`, `descriptionForWork`). Activity:
`services.jobAssignment.created|updated|visitDateChanged|assignmentChanged|cancelled`.

## Notifications

Creating/updating an assignment notifies the **linked UserAccount** of each
directly assigned employee, and for team lines the **team lead** (plus active
members), deduplicated per `assignment + user`. Employees without a linked
account are still assigned; they simply receive no in-app notification.
Notification deep links (`/app/services/job-assignments/:id`) pass through the
router guards, so permission/scope is re-checked on open. No notification is sent
merely because an enquiry exists.

## Services Overview & Enquiry integration

Overview adds **Scheduled assignments**, **Visits today** and **Upcoming visits**
cards plus an **Upcoming assignments** section, all scope-filtered and only when
a Job Assignment view scope is effective (real aggregate queries, never counting
a full list in a widget). Enquiry detail shows the active assignment
(number/visit date/assigned summary) with **Create job assignment** (OPEN) or
**View job assignment** (ASSIGNED) according to permission.

## Database

Schema **v15** adds `service_job_assignments` (with `search_text`) and
`service_job_assignment_lines`, plus indexes and a partial unique index enforcing
one ACTIVE assignment per enquiry. The migration is additive and preserves all
existing data.

## Deferred / TBD

- Inspection, Root Cause, Before-Work Photos, Inspection Checklist, Material
  Request/Issue/Receipt, Work Execution, Quotation, Job Order, Invoice, Payment —
  later phases.
- Job Assignment work-line Status vocabulary (TBD — client confirmation).
- Job Order / Quotation ownership remains unresolved.
