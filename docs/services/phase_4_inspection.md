# Services Phase 4 — Inspection

Phase 4 adds the **Service Inspection** transaction: inspecting an eligible Job
Assignment, capturing checklist items (+ before-work photos), inspected points
and material requirements. Request for Material and Work Execution are **not**
implemented.

## Client reference mapping

See [client_reference_traceability.md](client_reference_traceability.md) (Screen:
Inspection). Company/No/Date/Insert/Update By are system/sequence/audit-derived;
Enquiry/Customer/Mobile/Complaint/Priority/Tenant/Building/Unit/Material Received
come from the source Job Assignment → Enquiry (read-only); Visit Date/Time,
Technician, Root Cause and Charge Responsibility are the inspection inputs.

## Module structure

```text
lib/modules/services/inspections/
  domain/        service_inspection.dart, service_inspection_scope.dart,
                 service_inspection_repository.dart
  data/          local_service_inspection_repository.dart
  application/   service_inspection_use_cases.dart
  presentation/  bloc/service_inspection_blocs.dart
                 pages/service_inspection_{list,detail,form}_page.dart
                 widgets/inspection_editors.dart
lib/modules/services/presentation/widgets/assignment_inspection_section.dart
```

## Aggregate

`ServiceInspection` (header) + `checklistItems[]`, `inspectedPoints[]`,
`materialRequirements[]`. Header: `inspectionNumber`, `inspectionDate`,
`sourceJobAssignmentId`, `sourceEnquiryId`, `visitDate`, `visitMinutes`
(typed time-only minutes-of-day), `technicianEmployeeId`, `rootCauseId`,
`chargeResponsibilityId`, `status`, `version`, audit, `requestId`, `syncStatus`.

### Status lifecycle (minimal)

`pending` (client-confirmed) → `completed` (finalized/read-only, eligible for
downstream) or `cancelled` (historical, not eligible). Completed inspections
cannot be cancelled. Do not hard-delete.

## Job Assignment relationship

Inspection originates from an **active** Job Assignment; Enquiry/Customer/Site
context is derived from it (never re-typed). One non-cancelled Inspection per Job
Assignment (V1, partial unique index). `sourceJobAssignmentLineId` preserves
checklist → assignment-line lineage.

## Technician

Existing Employee via `WorkforceDirectory`. Candidates are limited to the source
Assignment's direct employees + active members of its assigned Service Teams
(deduped, active only). No Technician entity. Restricted Employee lookup does not
grant HR directory access.

## Root Cause & Charge Responsibility

New Services configuration masters (same typed master conventions as the other
Services masters): `ServiceRootCause`, `ServiceChargeResponsibility`. Settings:
`/app/services/settings/root-causes`, `/app/services/settings/charge-responsibilities`.
Permissions `services.rootCauses.view|manage`, `services.chargeResponsibilities.view|manage`
(manage implies view). "Charged" is preserved as Charge Responsibility; the
client-confirmed **Tenant** value is seeded; unknown values are not guessed.

## Checklist / points / materials

- Checklist item: `workType` (prefilled from `ServiceJobAssignmentLine.work`),
  `descriptionForWork` (prefilled), `status` (`pending`; TBD vocabulary), 0..N
  **before-work photos** (shared attachments, `ownerType=serviceInspectionChecklistItem`,
  `category=beforeWorkPhoto`).
- Inspected points: 0..N free-text observations (separate from checklist).
- Material requirements: `code` (business reference, no Inventory integration),
  `description`, `status` = `waiting` (client-confirmed). **No inventory/stock
  transaction is created.**

## Permissions & scope

`services.inspections.view` with scopes `assigned`/`team`/`all`
(`ServiceInspectionScopeResolver`); `create`/`edit`/`complete`/`cancel` (imply
ALL view via `permissionViewDependencies`). ASSIGNED = technician OR directly
assigned on the source assignment OR in an assigned Service Team. See
[permission_coverage.md](../architecture/permission_coverage.md).

## Routes & navigation

`/app/services/inspections[/new|/:inspectionId|/:inspectionId/edit]`.
Navigation: Overview, Enquiries, Job Assignments, **Inspections**, Customers,
Sites, Teams, Settings. Direct URLs guarded; record scope enforced on every read.

## Repository & atomicity

`ServiceInspectionRepository` / `LocalServiceInspectionRepository`:
`watchInspections`, `watchInspection`/`getInspection`, `createInspection`,
`updateInspection`, `completeInspection`, `cancelInspection`,
`searchEligibleJobAssignments`, `getSourceContext`,
`getInspectionForAssignment`/`watchInspectionForAssignment`, `summary`,
`watchRecentInspections`. Create/update/complete/cancel run in one transaction
(sequence + header + children + attachment metadata + activity + outbox +
notification). `requestId` makes retries idempotent (no duplicate rows/attachments).
List resolves assignment/enquiry/customer/technician/root cause in batched queries
(no N+1). Children are soft-removed.

## Outbox & activity

`SERVICES_INSPECTION_CREATE|UPDATE|COMPLETE|CANCEL` with backend-ready payload
(header + checklistItems + inspectedPoints + materialRequirements + attachment
metadata; no binary). Activity: `services.inspection.created|updated|technicianChanged|visitChanged|rootCauseChanged|completed|cancelled`.

## Notifications

The technician's linked account is notified on assignment (deduped, deep link
`/app/services/inspections/:id`, permission re-checked on open). No completion
notifications without a confirmed workflow.

## Integrations

Services Overview shows **Pending inspections / Inspections today / Completed
inspections** cards + a **Recent inspections** section (scope-filtered, real
aggregates). Job Assignment detail shows the Inspection (number/status/visit/
technician/root cause) with **Create inspection** (active, no inspection) or
**View inspection**.

## Database

Schema **v16** adds `service_inspections` (with `search_text`), the three child
tables and `service_root_causes` / `service_charge_responsibilities`, plus indexes
and a partial unique index (one non-cancelled inspection per assignment).
Additive; preserves all data.

## Downstream handoff

A COMPLETED Inspection is the future source for Request for Material (Phase 5,
consuming `WAITING` material requirements) and Work Execution (Phase 6).
Reference DTOs are durable. No Job Order / Quotation is created.

## TBD — client confirmation

- Exact Inspection Status vocabulary beyond Pending.
- Checklist-line Status options (only `pending` modelled).
- Full Charge Responsibility values beyond Tenant.
- Whether revisit/reinspection needs multiple inspections per assignment.
