# Services Phase 6 — Work Execution

Work Execution is the final currently-known operational Services stage from the
client reference: assigned employees/teams perform the work, capture start/end
times, record materials used and upload after-work evidence.

```
Service Enquiry
      ↓
Job Assignment & Scheduling
      ↓
Inspection
      ↓
Request for Material (only when required)
      ↓
Work Execution
```

## Client mapping

| Client field / action | Modern equivalent | Notes |
| --- | --- | --- |
| Company Name | active `CompanyContext` | system-derived, never editable |
| Work Execution No | `ServiceWorkExecution.executionNumber` | shared sequence `services.workExecution`, prefix `WE-`, unique per company |
| Date | `executionDate` | `CompanyTimeService` company business date |
| Job Order No | `jobOrderReference` (optional free text) | **no** JobOrder entity/CRUD — owner/source TBD |
| Quotation No | `quotationReference` (optional free text) | **no** Quotation entity/CRUD — owner/source TBD |
| Inspection No | `sourceInspectionId` | the **primary** workflow source |
| Job Assignment No | `sourceJobAssignmentId` | derived from the Inspection lineage, never selected independently |
| Enquiry No | `sourceEnquiryId` | derived Inspection → Job Assignment → Enquiry |
| Insert By | `createdByUserId` | audit-derived (`AuditMetadataBlock`) |
| Update By | `updatedByUserId` | audit-derived |
| Status | `status` | PENDING → IN_PROGRESS → COMPLETED / CANCELLED |
| Work Time (row values 1,2,3…) | `lineNumber` (S.No) | row numbering; **not** a duration |
| Work | `ServiceWorkExecutionLine.work` | prefilled from `JobAssignmentLine.work` |
| Description | `line.description` | prefilled from `JobAssignmentLine.descriptionForWork` |
| Team Selection | `line.serviceTeamId` | existing active same-company `ServiceTeam` |
| Individual Employee | `line.employeeId` | existing Employee via `WorkforceDirectory` |
| Start Time | `line.startedAtUtc` | captured by **Start Work** (`AppClock.now()` UTC) |
| End Time | `line.endedAtUtc` | captured by **End Work**; `endedAt >= startedAt` |
| line Status | derived `ServiceWorkLineState` | NOT_STARTED / IN_PROGRESS / FINISHED from timestamps |
| Material Used — S.No | `ServiceWorkExecutionMaterialUsed.lineNumber` | |
| Material Used — Code | `material.code` | required |
| Material Used — Description | `material.description` | required; **no** Qty/Batch/UOM/Cost |
| Photos After Work — S.No | `ServiceWorkExecutionPhotoEntry.lineNumber` | |
| Photos After Work — Description | `entry.description` | required |
| Photos After Work — Photo | shared `AttachmentRecords` | `ownerType = serviceWorkExecutionPhotoEntry`, `category = afterWorkPhoto`; multiple per entry |
| Save | create / save changes | repository create/update |
| Clear | reset form | confirm before clearing |
| Delete | cancel Work Execution | never hard-deleted; history retained |

## Workflow lineage

- Source is a **same-company, COMPLETED, non-cancelled, in-scope Inspection**.
- `sourceJobAssignmentId` / `sourceEnquiryId` are copied from the Inspection.
- Customer / Mobile / Site / Tenant / Building / Unit / Complaint Type / Priority /
  Material Received / Root Cause / Charge Responsibility / Technician are resolved
  read-only through the lineage and never duplicated as editable header data.
- **Material Received** remains Enquiry-owned and is inherited read-only.

## Work lines

- 1..N lines (never a hardcoded five).
- Prefilled from the source Job Assignment lines, retaining
  `sourceJobAssignmentLineId`:
  `work ← Work`, `description ← Description For Work`, `team ← Team`,
  `employee ← Technician`.
- Manual extra lines have `sourceJobAssignmentLineId = null`.
- Team-only, employee-only, and team+employee are all valid (no forced exclusivity).
- Unstarted lines may be removed while editable; a line with timestamps is never
  casually deleted.
- There is deliberately **no stored duration** field. The legacy "Work Time"
  column visibly contained row numbers and maps to `lineNumber`.

## Start / End timing

- **Start Work** captures `AppClock.now()` as `startedAtUtc` (UTC) and transitions
  PENDING → IN_PROGRESS on the first start.
- **End Work** captures `endedAtUtc`; `endedAt >= startedAt` is enforced.
- Double-tap is safe: a second start/end returns a typed conflict and never writes
  a second timestamp.
- Timestamps persist in UTC and render company-local.
- Line state is **derived** from the timestamps:
  `startedAt == null → NOT_STARTED`, `startedAt != null && endedAt == null →
  IN_PROGRESS`, `endedAt != null → FINISHED`. Duration is derived for display only.

## Overall lifecycle

```
CREATE → PENDING
first line starts → IN_PROGRESS
all required work finished + authorized finalization → COMPLETED
PENDING / IN_PROGRESS → CANCELLED (when permitted)
```

COMPLETED is historical/final. Cancellation is not casual after completion and
never hard-deletes history.

## Material Used

- Separate child collection `ServiceWorkExecutionMaterialsUsed`.
- Only **Code** and **Description** (both required). No quantity/UOM/batch/cost is
  invented; the client reference shows none.
- Optionally linked to a Material Request line via `sourceMaterialRequestLineId`
  (prefills Code + Description). A requested material is **not** automatically a
  used material.
- Recording Material Used never mutates the Material Request lifecycle and has
  **no** stock/issue/consumption side effects. No Inventory/Warehouse/Batch model
  exists.

## After Work Photos

- Separate child collection `ServiceWorkExecutionPhotoEntries` with a required
  `description`.
- Images are shared `AttachmentRecords`; multiple attachments per entry are
  supported. No BLOB/base64 is stored in Drift.
- **Before Work Photos** belong to the Inspection (`serviceInspectionChecklistItem`
  / `beforeWorkPhoto`); **After Work Photos** belong to Work Execution
  (`serviceWorkExecutionPhotoEntry` / `afterWorkPhoto`). They are never merged.

## Permissions & scopes

| Permission | Scope | Controls |
| --- | --- | --- |
| `services.workExecutions.view` | assigned / team / all | queue + detail reads |
| `services.workExecutions.create` | none | New Work Execution, create from completed Inspection, `/new` |
| `services.workExecutions.edit` | none | header references + work-line structure while eligible |
| `services.workExecutions.perform` | none | Start Work, End Work, Material Used, After Work Photos |
| `services.workExecutions.complete` | none | explicit Complete Work Execution |
| `services.workExecutions.cancel` | none | Cancel Work Execution |

- Create/Edit/Perform/Complete/Cancel imply `serviceWorkExecutionViewAll` via
  `permissionViewDependencies`.
- ASSIGNED = current linked Employee is directly on a work line, is relevant via
  the source Job Assignment assignment, is the source Inspection technician, or
  belongs to an assigned Service Team.
- TEAM uses the Services team scope and **never** expands to ALL. ALL is
  company-scoped.
- **Edit and Perform are separate capabilities enforced in both UI and
  use-case/domain.** An edit-only user cannot start/end work; a perform-only user
  cannot structurally edit.
- `perform` requires an active linked Employee for ASSIGNED/self scope.
- Direct URLs, use cases and attachments all enforce object scope (no ID bypass).
- Users & Access automatically displays the Work Execution submodule and the
  View/Create/Edit/Perform/Complete/Cancel definitions; there is no hardcoded
  Services Access UI.

## Job Order / Quotation compatibility

`jobOrderReference` and `quotationReference` are optional free-text compatibility
fields. No JobOrder/Quotation entity, repository or CRUD is created. If an
upstream value exists it is prefilled; otherwise the optional field is available.

**TBD — authoritative owner/source.**

## Routes

```
/app/services/work-executions
/app/services/work-executions/new
/app/services/work-executions/:executionId
/app/services/work-executions/:executionId/edit
```

Navigation places **Work Execution** after Material Requests. Restricted eligible
Inspection access is granted by Work Execution Create and never grants full
Inspection navigation, all Customer records or the HR directory.

## Repositories & API trace

`ServiceWorkExecutionRepository` (local: `LocalServiceWorkExecutionRepository`):

- reads: `watchExecutions`, `watchExecution`, `getExecution`, `summary`,
  `watchRecentExecutions`
- create/update: `createExecution`, `updateExecution`
- operations: `startWorkLine`, `endWorkLine`, `addMaterialUsed`,
  `removeMaterialUsed`, `addPhotoEntry`, `updatePhotoEntryDescription`,
  `removePhotoEntry`
- finalization: `completeExecution`, `cancelExecution`
- references/integrations: `searchEligibleInspections`, `getSourceContext`,
  `getExecutionForInspection`, `watchExecutionForInspection`,
  `watchExecutionForAssignment`, `getExecutionsForEnquiry`

Use cases: `CreateServiceWorkExecution`, `UpdateServiceWorkExecution`,
`StartServiceWork`, `EndServiceWork`, `AddServiceWorkMaterial` (via repository),
`CompleteServiceWorkExecution`, `CancelServiceWorkExecution`,
`WatchServiceWorkExecutions`, `GetServiceWorkExecution`. No business rules live in
widgets.

Mapping to a future backend API:

| API endpoint | Repository method |
| --- | --- |
| list Work Executions | `watchExecutions` |
| detail | `getExecution` / `watchExecution` |
| create | `createExecution` |
| update | `updateExecution` |
| Start Work | `startWorkLine` |
| End Work | `endWorkLine` |
| Complete | `completeExecution` |
| Cancel | `cancelExecution` |
| Material Used | `addMaterialUsed` / `removeMaterialUsed` |
| After Work Photos | `addPhotoEntry` / `updatePhotoEntryDescription` / `removePhotoEntry` |

## Outbox

Registered keys: `SERVICES_WORK_EXECUTION_CREATE`, `SERVICES_WORK_EXECUTION_UPDATE`,
`SERVICES_WORK_EXECUTION_START_LINE`, `SERVICES_WORK_EXECUTION_END_LINE`,
`SERVICES_WORK_EXECUTION_COMPLETE`, `SERVICES_WORK_EXECUTION_CANCEL`. The payload
carries header + source ids + references + `workLines`, `materialsUsed` and
`afterWorkPhotoEntries` (attachment **metadata** only, never image bytes). Child
add/remove operations are emitted as aggregate `SERVICES_WORK_EXECUTION_UPDATE`
mutations. `requestId` idempotency prevents duplicate executions, lines, events,
material/photo rows, activity and outbox entries.

## Activity

Structured events: `services.workExecution.created`, `updated`, `workStarted`,
`workEnded`, `materialUsedAdded`, `materialUsedRemoved`, `photoAdded`,
`photoUpdated`, `photoRemoved`, `completed`, `cancelled`. Field keystrokes are not
recorded.

## Database

Schema **17 → 18** (exactly once). Idempotent migration adds
`ServiceWorkExecutions`, `ServiceWorkExecutionLines`,
`ServiceWorkExecutionMaterialsUsed`, `ServiceWorkExecutionPhotoEntries` plus the
indexes in the phase spec and a partial unique index enforcing one non-cancelled
Work Execution per Inspection (V1). Existing data is preserved; attachments remain
shared.

## Final TBD classification

Every client-visible concept below has its approved modern representation in
place. The only outstanding items are client-business confirmations about a
source/rule **around** an implemented feature — not missing functionality.

| Concept | Implemented behavior | Remaining TBD |
| --- | --- | --- |
| Job Order | `jobOrderReference` optional compatibility field (+ prefill when upstream provides it) | authoritative owner/source |
| Quotation | `quotationReference` optional compatibility field (+ prefill when upstream provides it) | authoritative owner/source |
| Work Time | mapped to `lineNumber` / S.No row ordering | reason for the misleading legacy label |
| Work-line Status | timestamp-derived `ServiceWorkLineState` (NOT_STARTED / IN_PROGRESS / FINISHED) with **Start Work** / **End Work**; the visible "WORK START" is represented by the Start Work action/state | exact legacy dropdown vocabulary |
| After Work Photos | entry `description` + shared attachments (multiple per entry), detail gallery, scoped access | whether ≥1 photo is mandatory before completion |
| Material Used | `code` + `description` (both required), optional Material Request line link | future Qty/UOM requirement once an Inventory domain exists |

Not implemented by design (not gaps): Inventory/Stock/Warehouse/Batch/IssueVoucher,
material Qty/UOM, Material Request lifecycle mutation on Work Execution
create/complete, notification spam, and print. No Job Order / Quotation owner was
guessed and no unknown business rule was invented.
