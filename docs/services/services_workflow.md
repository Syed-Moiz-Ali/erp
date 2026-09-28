# Services end-to-end workflow

Phase 7 turns the five existing Services transactions into **one coherent ERP
workflow** without introducing any new business transaction, monolithic
`ServiceCase` table, Job Order/Quotation module, Inventory, Billing or approval
workflow. The chain is:

```
Service Enquiry
        ↓
Job Assignment & Scheduling
        ↓
Inspection
        ↓
Request for Material   (CONDITIONAL)
        ↓
Work Execution
```

Actual flows:

- `Enquiry → Assignment → Inspection → Work Execution` (no material required), or
- `Enquiry → Assignment → Inspection → Material Request → Work Execution`.

Request for Material is **optional**. When an Inspection has no material
requirement the workflow continues directly to Work Execution and the Material
Request step is shown as *not required / none created* — never as broken.

## Workflow read model (no new aggregate)

`ServiceWorkflowChain` (with `ServiceWorkflowNode` and the derived
`ServiceWorkflowStatus`) is an **application-level read model** assembled from
the five existing transaction repositories
(`lib/modules/services/workflow/`). It is deliberately not persisted:

- No database column stores a workflow stage or status.
- Each transaction keeps its own authoritative lifecycle.
- `deriveServiceWorkflowStatus` recomputes a presentation-only summary on every
  read, so it cannot drift out of sync (`ServiceWorkflowStatus` is never a
  database status).
- Every node is resolved through the owning transaction repository, so the
  node's permission and record scope are re-checked. A restricted transaction is
  indistinguishable from an absent one — no restricted data leaks through the
  timeline.

`ServiceWorkflowRepository` exposes:

| Method | Purpose |
| --- | --- |
| `watchChain` / `loadChain` | Resolve Enquiry → Assignment → Inspection → Material Request → Work Execution with correct lineage and per-node authorization. |
| `summary` | Permission/scope-aware operational counts for the dashboard (`ServiceWorkflowSummary`). |
| `watchActivity` | Merged, authorization-filtered workflow activity feed ordered by event timestamp. |

### Derived workflow status vocabulary

`awaitingAssignment`, `scheduled`, `inspectionPending`, `inspectionCompleted`,
`materialsRequested`, `workInProgress`, `workCompleted`, `cancelled`, `unknown`.
Derived strictly from the resolved node states; `unknown` is used when a status
cannot be determined accurately.

## Source / owned / inherited fields

| Transaction | Source (lineage) | Owned fields |
| --- | --- | --- |
| Service Enquiry | — | Customer/Site selection + snapshot, Service Type, Complaint Type, Priority, Ticket Type, **Material Received**, description, detail lines (+ photos), status, cancel. |
| Job Assignment | `sourceEnquiryId` | Assignment No, Assignment Date, **Visit Date**, work assignment lines (work, assigned Employee/Team, Description For Work, line status). |
| Inspection | `sourceJobAssignmentId` → derived `sourceEnquiryId` | Inspection No, Inspection Date, **Visit Date/Time**, Technician, Root Cause, Charge Responsibility, Inspection Checklist (+ before-work photos), Inspected Points, Material Requirements. |
| Material Request | `sourceInspectionId` (+ derived Job Assignment/Enquiry) | Request No, Request Date, Purpose, Acknowledge metadata, Received By metadata, Remarks, Job Order reference (free text), material lines (Code, Description, Batch No, Qty, line Remark). |
| Work Execution | `sourceInspectionId` (+ derived Job Assignment/Enquiry) | Execution No, Execution Date, work lines, actual Start/End, Material Used (Code + Description), After Work Photos, Job Order/Quotation references (free text). |

Inherited read-only context (never re-typed downstream): Customer/Mobile/Site/
Tenant/Building/Unit snapshot, Service classification (Service Type, Complaint
Type, Priority, Ticket Type), and **Material Received**.

### Material Received — locked rule

`ServiceEnquiry.materialReceived` is the **single authoritative owner**.
Job Assignment, Inspection, Material Request context and Work Execution context
only display the inherited value. There is **no** mutable `materialReceived`
column on any downstream table, so contradictions are structurally impossible.
`Material Received` does **not** equal Request for Material: neither YES blocks a
request nor NO generates one.

## Lifecycle per transaction

| Transaction | Lifecycle |
| --- | --- |
| Enquiry | `OPEN → ASSIGNED → (CANCELLED)`; cancelling the last active Assignment returns it to `OPEN`. |
| Job Assignment | `ACTIVE → (CANCELLED)`; historical, never hard-deleted. |
| Inspection | `PENDING → COMPLETED` or `PENDING → CANCELLED`; completed/cancelled are read-only. |
| Material Request | `OPEN → (CANCELLED)`; no approval/issue/receive workflow exists. |
| Work Execution | `PENDING → IN_PROGRESS → COMPLETED` or `→ CANCELLED`; per-line state is derived from Start/End timestamps. |

## Permissions and scope

Services transactions use `ASSIGNED`, `TEAM` and `ALL`; `SELF` is not used for
transaction records. `ALL` is always company-scoped (never cross-company).

- ASSIGNED for Job Assignment = directly assigned employee on a line **or**
  member of an assigned Service Team.
- ASSIGNED for Inspection/Material Request/Work Execution = the source
  Inspection technician, a direct employee on the source Job Assignment, the
  employee on a Work Execution line, or membership of an assigned Service Team.
- TEAM uses the Services Team membership (never a department/designation);
  it never silently becomes ALL.

See `docs/architecture/permission_coverage.md` for the full permission matrix.

## Next actions (centrally resolved)

`ServiceWorkflowActionResolver` is the **single** place workflow-state logic
lives. Widgets render the resolved actions only.

| Page (pageStage) | Available actions |
| --- | --- |
| Enquiry | Create Job Assignment (OPEN, authorized, no active assignment); View Job Assignment. |
| Job Assignment | Create Inspection (ACTIVE, no inspection, authorized); View Inspection. |
| Inspection | PENDING: Edit / Complete / Cancel. COMPLETED: Create Material Request (only when WAITING requirements exist and no active request), Create Work Execution (always offered — materials do not block it), View Material Request, View Work Execution. |
| Material Request | OPEN: Edit / Print / Cancel. |
| Work Execution | open: Edit / Perform (Start–End) / Complete (only when all lines finished) / Cancel. |

Cancelled transactions never offer downstream creation; completed/final
transactions are read-only.

### Workflow transition matrix

| From state | Gate / condition | Allowed transition | Blocked when |
| --- | --- | --- | --- |
| Enquiry OPEN | authorized + no active assignment | Create Job Assignment → Enquiry ASSIGNED | Enquiry CANCELLED; active assignment already exists. |
| Enquiry ASSIGNED | — | (no downstream creation from Enquiry directly) | — |
| Enquiry CANCELLED | — | none | Always. |
| Assignment ACTIVE | authorized + no non-cancelled Inspection | Create Inspection | Assignment CANCELLED; inspection already exists. |
| Assignment CANCELLED | — | none | Always. |
| Inspection PENDING | authorized | Edit / Complete / Cancel | Inspection CANCELLED/COMPLETED. |
| Inspection COMPLETED | WAITING requirements + no active request + authorized | Create Material Request | Already requested; no waiting requirement. |
| Inspection COMPLETED | no active execution + authorized | Create Work Execution (regardless of materials) | Active execution exists. |
| Inspection CANCELLED | — | none (no Material Request / Work Execution) | Always. |
| Material Request OPEN | authorized | Edit / Print / Cancel | Cancelled. |
| Material Request CANCELLED | — | none | Always. |
| Work Execution PENDING/IN_PROGRESS | authorized + `perform` | Start/End work lines | Cancelled/Completed. |
| Work Execution (all lines finished) | authorized + `complete` | Complete Work Execution | Not all lines finished. |
| Work Execution COMPLETED/CANCELLED | — | none (read-only history) | Always. |

### Optional Material Request — documented open question

Whether Work Execution may begin **before** a Material Request is raised is not
confirmed by the client. The implementation therefore does **not** block Work
Execution when requirements are waiting: both *Create Material Request* and
*Create Work Execution* are offered and the operator decides. This is a genuine
business question (see Open questions).

## Attachments

| Evidence | Owner | Owner type / category |
| --- | --- | --- |
| Enquiry issue photos | Enquiry detail line | `serviceEnquiryDetail` / `problemPhoto` |
| Before Work Photos | Inspection checklist item | `serviceInspectionChecklistItem` / `beforeWorkPhoto` |
| After Work Photos | Work Execution photo entry | `serviceWorkExecutionPhotoEntry` / `afterWorkPhoto` |

Ownership is never combined: the Work Execution detail shows *Before work*
(authorized Inspection photos) and *After work* (Work Execution photos)
separately. Attachment authorization inherits the owning transaction, so an
attachment id can never bypass transaction access. Upload lifecycle (pending /
failed / retry / removed / offline metadata) follows the shared
`AttachmentRepository` conventions.

## Material lineage and distinction

Four distinct concepts are preserved and never merged:

1. **Enquiry Material Received** — contextual Yes/No (owned by Enquiry).
2. **Inspection Material Required** — requirements identified during inspection
   (`WAITING → REQUESTED`).
3. **Material Request** — requested materials/quantities.
4. **Work Execution Material Used** — Code + Description actually recorded as
   used (no Qty/UOM, **no inventory or stock-consumption claim** — no inventory
   exists).

Optional lineage is preserved with source ids and never required:

```
InspectionMaterialRequirement
        ↓ (optional sourceInspectionMaterialRequirementId)
MaterialRequestLine
        ↓ (optional sourceMaterialRequestLineId)
WorkExecutionMaterialUsed
```

## Activity integration

Each transaction keeps its own activity history. The workflow-level feed merges
structured events from all five transactions, ordered by event timestamp, using
structured event keys + metadata only (no stored English sentences). Only events
from records the user may view are included, so the audit trail cannot leak
hidden transactions.

## Notifications

- Job Assignment may notify the linked active user accounts of assigned
  Employees (directly / by team) per the documented policy.
- Inspection may notify the technician when a meaningful action is required.
- Work Execution may notify the relevant operational Employee when work is
  ready; Start/End events are **not** notified (no spam).
- Notifications are not authorization: opening one re-evaluates company,
  module, permission, scope and record state before resolving the deep link.

## Outbox, idempotency, sequences and company time

- All Services writes follow `UI → BLoC/use case → repository → local
  transaction → activity/outbox → Drift source of truth`. No feature bypasses the
  repository.
- Every mutation emits a structured outbox action (`SERVICES_*`); retries reuse
  the same `requestId` and are idempotent (no duplicate transaction, child line,
  sequence, activity event or attachment metadata).
- Display numbers are company-scoped sequences (`ENQ`, `JA`, `INS`, `MR`, `WE`);
  no cross-company collision.
- Business dates use `AppClock`/`CompanyTimeService`; timestamps persist in UTC
  and display in the company-local timezone. No raw `DateTime.now()` business
  logic.

## Data ownership matrix

| Field / concept | Owner |
| --- | --- |
| Material Received | **Enquiry** (inherited read-only downstream) |
| Customer / Site snapshot (Customer, Mobile, Tenant, Building, Unit) | **Enquiry** |
| Service classification (Service Type, Complaint Type, Priority, Ticket Type) | **Enquiry** |
| Visit Date | **Job Assignment** |
| Assigned Employee / Service Team / Description For Work | **Job Assignment** |
| Technician | **Inspection** |
| Root Cause | **Inspection** |
| Charge Responsibility | **Inspection** |
| Before Work Photos | **Inspection** checklist item |
| Material Required | **Inspection** |
| Requested Qty / Code / Description / Batch / Remark | **Material Request** |
| Actual Start / End Time | **Work Execution** |
| Material Used (Code + Description) | **Work Execution** |
| After Work Photos | **Work Execution** |
| Job Order | **TBD — external/future owner** (free-text compatibility reference only) |
| Quotation | **TBD — external/future owner** (free-text compatibility reference only) |

## Operational queues (derived, no new entities)

The dashboard/queues are derived queries over existing records: enquiries
awaiting assignment, upcoming scheduled jobs, pending inspections, waiting/
requested material requirements, work executions in progress. There are **no
approval queues** — the client reference establishes no material/inspection/work
completion approval workflow.

## Data consistency validator

`ServiceWorkflowValidator` (test/development level) asserts, read-only:

- every downstream transaction resolves its source and shares the source company;
- Inspection's derived Enquiry matches its Assignment's Enquiry;
- Material Request / Work Execution lineage matches the source Inspection;
- child rows share the parent company;
- optional material lineage resolves when present;
- attachment owners exist.

It never repairs anything: integrity problems must be fixed at their source.

## Architecture boundaries

- **Services → HR** only through the `WorkforceDirectory` contract (no HR DAOs/
  presentation imports).
- **Services → Notifications** through the platform `NotificationRepository`.
- **Services → Attachments** through the shared `AttachmentRepository`.
- **Services → Sync/Outbox** through the shared outbox and `AppClock`.
- **Services → Company time** through `CompanyTimeService`.
- **Services → Access control** through `AppPermission` + the module scope
  resolvers; live grant/revoke refreshes navigation, routes, dashboard cards,
  buttons and record access without re-login.

## Service Reports — explicitly deferred

The client navigation contains *Service Reports*, but no sufficient report
requirements/screens are available. Service Reports are **not implemented /
hidden** in Phase 7 and are **not** replaced by the operational dashboard
metrics. They remain a separate future scope once requirements exist.

## Genuine open questions (do not guess)

- Job Order ownership/lifecycle.
- Quotation ownership/lifecycle.
- Service Reports requirements.
- Exact Enquiry detail-line status vocabulary.
- Exact Job Assignment line status vocabulary.
- Full Inspection checklist status vocabulary.
- Full Charge Responsibility values beyond confirmed examples.
- Material Request Acknowledge semantics.
- Material Request Received By identity semantics.
- Future inventory/store process.
- Whether Work Execution Material Used later requires Qty/UOM.
- Whether Work Execution may begin before a Material Request.
- Whether reinspection/rework/multiple execution visits are required.

## Demo data

`services_demo_seed.dart` is deterministic and idempotent and seeds four
internally consistent flows using real Customers/Sites/Employees/Teams:

- **A** `demo-enq-1 → demo-ja-1 → demo-ins-1 (completed) → demo-mr-1 → demo-we-1 (in progress)`
- **B** `demo-enq-5 → demo-ja-3 → demo-ins-2 (completed) → demo-we-2 (completed, no materials)`
- **C** `demo-enq-2` open enquiry awaiting assignment.
- **D** `demo-enq-4 → demo-ja-2` scheduled assignment awaiting inspection.
