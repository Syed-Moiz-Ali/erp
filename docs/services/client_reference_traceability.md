# Services client reference traceability

Authoritative mapping between the client's legacy ERP screens and this modern ERP.
**Every** visible client field, action, table column, status and upload must be
mapped here before a Services phase is implemented. Nothing may silently
disappear.

Status values: `IMPLEMENTED` (built as-is), `MODERNIZED` (represented by a better
modern concept), `SYSTEM-DERIVED` (derived from context/audit), `DEFERRED` (not
built yet), `TBD` (semantics unconfirmed — do not guess).

Confidence: `HIGH` / `MEDIUM` / `LOW`.

> Rule for every future Services phase (Job Assignment, Inspection, Material
> Request, Work Execution, …): inspect the relevant client screenshots, extend
> this matrix, classify each item, and only then design the domain/UI.

> **Cross-phase rule — Material Received.** `Material Received` originates in the
> **Service Enquiry** and is the single source of truth. It is inherited
> read-only by Job Assignment, Inspection and Request for Material (display
> context only) and is never an independently editable downstream value.
> `Material Received` **does not equal** Request for Material: neither YES
> blocks a request nor NO auto-generates one.

## Screen: Add / Update Service Enquiry

Header fields:

| Visible field | Business purpose | Modern equivalent | Domain property | Route / screen | Phase | Status | Confidence | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Company Name | Owning company | Active `CompanyContext` | `ServiceEnquiry.companyId` | all enquiry screens | 2 | SYSTEM-DERIVED | HIGH | Never editable. |
| Enquiry No | Human identifier | Shared sequence (`ENQ-…`) | `ServiceEnquiry.enquiryNumber` | detail header | 2 | MODERNIZED | HIGH | Auto-generated; not user-entered. |
| Date | Enquiry date | Created/business timestamp | `ServiceEnquiry.createdAt` | detail "Record" | 2 | SYSTEM-DERIVED | HIGH | System-generated, shown read-only. Editable business date not confirmed. |
| Customer Name | Who reported it | Phase 1 Customer directory | `ServiceEnquiry.customerId` + snapshot | form / detail | 1–2 | IMPLEMENTED | HIGH | Selected, not typed. |
| Mobile No | Contact | Customer/Site contact | snapshot `customerMobile` | form / detail | 2 | MODERNIZED | HIGH | Read-only derived. |
| Complaint Type | Classification | Complaint Type master | `ServiceEnquiry.complaintTypeId` | form / detail | 1–2 | IMPLEMENTED | HIGH | Filtered by Service Type. |
| Priority Type | Urgency | Service Priority master | `ServiceEnquiry.priorityId` | form / detail | 1–2 | IMPLEMENTED | HIGH | |
| Tenant Name | Site context | Service Site attribute | `ServiceSite.tenantName` + snapshot | site / detail | 1–2 | MODERNIZED | HIGH | Derived from selected Site. |
| Building | Site context | Service Site attribute | `ServiceSite.buildingName` + snapshot | site / detail | 1–2 | MODERNIZED | HIGH | Derived from selected Site. |
| Unit No | Site context | Service Site attribute | `ServiceSite.unitNumber` + snapshot | site / detail | 1–2 | MODERNIZED | HIGH | Derived from selected Site. |
| Material Received | Material already in hand? | Typed flag on the header | `ServiceEnquiry.materialReceived` | form / detail | 2.1 | TBD | LOW | Exact meaning at Enquiry stage unconfirmed; modelled as Yes/No only. No inventory/quantity. |
| Ticket Type | Ticket classification | Service Ticket Type master | `ServiceEnquiry.ticketTypeId` | form / detail | 1–2 | IMPLEMENTED | HIGH | |
| Insert By | Author | Audit | `ServiceEnquiry.createdByUserId` | detail "Record" | 2 | SYSTEM-DERIVED | HIGH | Not editable. |
| Update By | Last editor | Audit | `ServiceEnquiry.updatedByUserId` | detail "Record" | 2 | SYSTEM-DERIVED | HIGH | Not editable. |

Detail grid:

| Visible field / action | Business purpose | Modern equivalent | Domain property | Route / screen | Phase | Status | Confidence | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S.No | Row order | Line order | `ServiceEnquiryDetailLine.lineNumber` | form / detail | 2.1 | MODERNIZED | HIGH | Presentation only — **not** identity. |
| Description | Complaint line | Multiline detail text | `ServiceEnquiryDetailLine.description` | form / detail | 2.1 | IMPLEMENTED | HIGH | Required, max 4000 chars. |
| Photo | Evidence per line | Shared attachment metadata | `AttachmentRef` (`ownerType=serviceEnquiryDetail`, `category=problemPhoto`) | form / detail | 2.1 | MODERNIZED | HIGH | Metadata only; no bytes/base64 in Drift. Multiple per line. |
| Status | Per-line status | Typed per-line enum | `ServiceEnquiryDetailLine.status` | form / detail | 2.1 | TBD | LOW | Vocabulary unconfirmed; minimal `open`/`closed` only; must not drive workflow. |
| Add row | Add a line | Add detail line | draft detail line (client UUID) | form | 2.1 | IMPLEMENTED | HIGH | "Add another issue". |
| Delete row | Remove a line | Soft-remove (never hard-delete) | `ServiceEnquiryDetailLine` `removedAt` | form | 2.1 | IMPLEMENTED | HIGH | Historical lines remain resolvable. |

Also present in the modern form (not in the client's header list but required by
Phase 1/2 masters): **Service Type** → `ServiceEnquiry.serviceTypeId`
(IMPLEMENTED, HIGH) — drives Complaint Type filtering.

## Screen: Add / Update Job Assignment & Scheduling

Header / transaction fields:

| Visible field | Business purpose | Modern equivalent | Domain property | Route / screen | Phase | Status | Confidence | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Company Name | Owning company | Active `CompanyContext` | `ServiceJobAssignment.companyId` | all screens | 3 | SYSTEM-DERIVED | HIGH | Never editable. |
| Job Assignment No | Human identifier | Shared sequence (`JA-…`) | `ServiceJobAssignment.assignmentNumber` | detail header | 3 | MODERNIZED | HIGH | Auto-generated. |
| Date | Assignment date | Company business date | `ServiceJobAssignment.assignmentDate` | detail "Record" | 3 | MODERNIZED | HIGH | System-derived, read-only. |
| Enquiry No | Source enquiry | Eligible-Enquiry selector | `ServiceJobAssignment.sourceEnquiryId` | form / detail | 3 | IMPLEMENTED | HIGH | Restricted reference lookup. |
| Customer Name | Context | Enquiry/customer snapshot | `partySnapshot.customerName` | detail | 2–3 | MODERNIZED | HIGH | Read-only. |
| Mobile No | Context | Enquiry party snapshot | `partySnapshot.customerMobile` | detail | 2–3 | MODERNIZED | HIGH | Read-only. |
| Complaint Type | Context | Source Enquiry ComplaintType | resolved name | detail | 2–3 | MODERNIZED | HIGH | Read-only. |
| Priority Type | Context | Source Enquiry Priority | resolved name/rank | list / detail | 2–3 | MODERNIZED | HIGH | Read-only. |
| Tenant Name | Context | Site snapshot | `partySnapshot.tenantName` | detail | 2–3 | MODERNIZED | HIGH | Read-only. |
| Building | Context | Site snapshot | `partySnapshot.buildingName` | detail | 2–3 | MODERNIZED | HIGH | Read-only. |
| Unit No | Context | Site snapshot | `partySnapshot.unitNumber` | detail | 2–3 | MODERNIZED | HIGH | Read-only. |
| Material Received | Context | Source Enquiry value | resolved from Enquiry | detail | 2.1–3 | IMPLEMENTED | HIGH | Informational; no material behaviour. |
| Visit Date | Scheduling input | `scheduledVisitDate` | `ServiceJobAssignment.scheduledVisitDate` | form / detail | 3 | IMPLEMENTED | HIGH | Company timezone. |
| Insert By | Author | Audit | `createdByUserId` | detail "Record" | 3 | SYSTEM-DERIVED | HIGH | Read-only. |
| Update By | Last editor | Audit | `updatedByUserId` | detail "Record" | 3 | SYSTEM-DERIVED | HIGH | Read-only. |

Repeating job assignment rows:

| Visible field / action | Business purpose | Modern equivalent | Domain property | Route / screen | Phase | Status | Confidence | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S.No | Row order | Line order | `ServiceJobAssignmentLine.lineNumber` | form / detail | 3 | MODERNIZED | HIGH | Presentation only, not identity. |
| Work | Task to assign | Multiline work | `ServiceJobAssignmentLine.work` | form / detail | 3 | IMPLEMENTED | HIGH | Required. |
| Technician Name | Assignee | Employee via `WorkforceDirectory` | `assignedEmployeeId` | form / detail | 3 | MODERNIZED | HIGH | No Technician table. |
| Team (checkbox) | Assignee team | Explicit Service Team selector | `assignedTeamId` | form / detail | 3 | MODERNIZED | HIGH | Employee-only / Team-only / both. |
| Status | Per-line status | Typed per-line enum | `ServiceJobAssignmentLine.status` | form / detail | 3 | TBD | LOW | Only `pending` modelled; exact values unconfirmed. |
| Description For Work | Instructions | Multiline instructions | `descriptionForWork` | form / detail | 3 | IMPLEMENTED | HIGH | Separate from `work`. |
| Add row (+) | Add work | Add work item | draft line (client UUID) | form | 3 | MODERNIZED | HIGH | Visible labelled button. |
| Delete row | Remove work | Remove work item (soft) | `removedAt` | form | 3 | MODERNIZED | HIGH | Never zero lines. |
| Delete transaction | Cancel | Cancel Assignment (historical) | `status` | list / detail | 3 | MODERNIZED | HIGH | No hard delete. |

## Screen: Add / Update Inspection

Header: Company Name → CompanyContext (SYSTEM-DERIVED); Inspection No → sequence
(`INS-…`) (MODERNIZED); Date → `inspectionDate` (MODERNIZED); Job Assignment No →
`sourceJobAssignmentId` (IMPLEMENT); Enquiry No → derived from Assignment
(MODERNIZED); Customer Name / Mobile No / Complaint Type / Priority Type / Tenant
Name / Building / Unit No / Material Received → derived from the source
Job Assignment → Enquiry snapshot (MODERNIZED, read-only); Visit Date →
`visitDate` (IMPLEMENT); Visit Time → `visitMinutes` (IMPLEMENT); Technician Name →
`technicianEmployeeId` (Employee, MODERNIZED); Root Cause → `ServiceRootCause`
master (IMPLEMENT); Charged → `ServiceChargeResponsibility` master, Tenant seeded
(MODERNIZED); Status → `status` pending/completed/cancelled (IMPLEMENT); Insert By
/ Update By → audit (SYSTEM-DERIVED).

Checklist: S.No → `lineNumber` (MODERNIZED); Check List/Work Type → `workType`
(prefilled from Assignment line `work`) (IMPLEMENT); Description For Work →
`descriptionForWork` (IMPLEMENT); Status → `status` (`pending`, TBD) (IMPLEMENT);
Before Work Photos → shared attachments (`ownerType=serviceInspectionChecklistItem`,
`category=beforeWorkPhoto`, multiple) (MODERNIZED); Add row → add checklist item
(MODERNIZED); Delete row → soft-remove (MODERNIZED).

Inspected Points: S.No / Description → `ServiceInspectionPoint[]` (IMPLEMENT).

Material Required: S.No → order; Code → `code` (business reference, no Inventory);
Description → `description`; Status → `waiting` (IMPLEMENT). Add row → add
material requirement (MODERNIZED).

## Screen: Add / Update Request for Material

Header:

| Visible field | Business purpose | Modern equivalent | Domain property | Route / screen | Phase | Status | Confidence | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Company Name | Owning company | Active `CompanyContext` | `ServiceMaterialRequest.companyId` | all screens | 5 | SYSTEM-DERIVED | HIGH | Never editable. |
| Request No | Human identifier | Shared sequence (`MR-…`) | `ServiceMaterialRequest.requestNumber` | detail header | 5 | MODERNIZED | HIGH | Auto-generated. |
| Date | Request date | Company business date | `ServiceMaterialRequest.requestDate` | detail "Record" | 5 | MODERNIZED | HIGH | `CompanyTimeService`. |
| JOB Order No | External job order reference | Optional free text | `ServiceMaterialRequest.jobOrderReference` | form / detail / print | 5 | TBD | LOW | No JobOrder entity; authoritative owner **TBD**. |
| Purpose | Material request purpose | Configurable master | `ServiceMaterialRequest.purposeId` → `ServiceMaterialRequestPurposes` | form / detail | 5 | IMPLEMENTED | MEDIUM | Option list **TBD — client confirmation**. |
| Acknowledge | Acknowledgement | Optional safe metadata | `ServiceMaterialRequest.acknowledgement` | form / detail | 5 | TBD | LOW | Exact semantics unconfirmed; never drives state. |
| Received By | Receiver | Optional safe text | `ServiceMaterialRequest.receivedBy` | form / detail | 5 | TBD | LOW | Identity type unconfirmed; no relationship forced. |
| Remarks | Request remarks | Optional text | `ServiceMaterialRequest.remarks` | form / detail | 5 | IMPLEMENTED | HIGH | |
| Prepared By | Author | Audit | `createdByUserId` | detail "Record" | 5 | SYSTEM-DERIVED | HIGH | Read-only. |
| Inspection No | Source transaction | Completed-Inspection selector | `sourceInspectionId` | form / detail | 5 | IMPLEMENTED | HIGH | Same company, COMPLETED, in scope. |
| Job Assignment No / Enquiry No | Lineage | Inherited from Inspection | derived | detail | 5 | MODERNIZED | HIGH | Read-only. |
| Customer / Mobile / Site / Tenant / Building / Unit | Context | Enquiry snapshot | `partySnapshot` | detail | 5 | MODERNIZED | HIGH | Read-only. |
| Material Received | Context | Source Enquiry value | resolved from Enquiry | detail / print | 5 | MODERNIZED | HIGH | **Read-only inherited**; not a request field. |

Detail lines:

| Visible field / action | Business purpose | Modern equivalent | Domain property | Route / screen | Phase | Status | Confidence | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S.No | Row order | Line order | `ServiceMaterialRequestLine.lineNumber` | form / detail | 5 | MODERNIZED | HIGH | Presentation only, not identity. |
| Code | Material code | Business reference | `code` | form / detail | 5 | IMPLEMENTED | HIGH | No Product/Inventory entity. |
| Description | Material description | Required text | `description` | form / detail | 5 | IMPLEMENTED | HIGH | |
| Batch No | Batch reference | Optional text | `batchNumber` | form / detail | 5 | IMPLEMENTED | MEDIUM | Not validated against a warehouse. |
| Qty | Requested quantity | Numeric (`> 0`) | `quantity` | form / detail | 5 | IMPLEMENTED | HIGH | Decimal supported; no UOM. |
| Remark | Line remark | Optional text | `remark` | form / detail | 5 | IMPLEMENTED | HIGH | Distinct from request remarks. |
| Total Qty | Summary | Derived sum | `totalQuantity` | form / detail / print | 5 | MODERNIZED | HIGH | Never entered manually. |
| Add row / Action | Add material | Add material line | draft line (client UUID) | form | 5 | MODERNIZED | HIGH | "+ Add material"; manual lines have null source. |
| Delete row | Remove material | Remove line | draft line | form | 5 | MODERNIZED | HIGH | Never zero lines. |
| Save | Persist | Create / Save Changes | repository create/update | form | 5 | IMPLEMENTED | HIGH | |
| Print | Printable document | `MaterialRequestPrintService` | PDF | detail | 5 | IMPLEMENTED | HIGH | View + Print + scope. |
| Clear | Reset unsaved | Reset Form / Discard Changes | draft reset | form | 5 | MODERNIZED | HIGH | Confirm before clearing. |
| Delete | Remove transaction | Cancel Material Request | `status` | list / detail | 5 | MODERNIZED | HIGH | Never hard-deleted. |

Inspection material requirement status handoff: `WAITING` → `REQUESTED` when
included in an active request; reverts on cancellation. One requirement cannot be
in two active requests. Multiple requests per Inspection are supported.

## Screen: Add / Update Work Execution

Header:

| Visible field | Business purpose | Modern equivalent | Domain property | Route / screen | Phase | Status | Confidence | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Company Name | Owning company | Active `CompanyContext` | `ServiceWorkExecution.companyId` | all screens | 6 | SYSTEM-DERIVED | HIGH | Never editable. |
| Work Execution No | Human identifier | Shared sequence (`WE-…`) | `ServiceWorkExecution.executionNumber` | detail header | 6 | MODERNIZED | HIGH | Auto-generated. |
| Date | Execution date | Company business date | `ServiceWorkExecution.executionDate` | detail "Record" | 6 | MODERNIZED | HIGH | `CompanyTimeService`. |
| Job Order No | External job order reference | Optional free text | `ServiceWorkExecution.jobOrderReference` | form / detail | 6 | IMPLEMENTED | MEDIUM | Compatibility reference implemented; authoritative owner/source **TBD**; no JobOrder entity. |
| Quotation No | External quotation reference | Optional free text | `ServiceWorkExecution.quotationReference` | form / detail | 6 | IMPLEMENTED | MEDIUM | Compatibility reference implemented; authoritative owner/source **TBD**; no Quotation entity. |
| Inspection No | Source transaction | Completed-Inspection selector | `sourceInspectionId` | form / detail | 6 | IMPLEMENTED | HIGH | Same company, COMPLETED, in scope, no active execution. |
| Job Assignment No | Lineage | Inherited from Inspection | `sourceJobAssignmentId` | detail | 6 | MODERNIZED | HIGH | Derived; never selected independently. |
| Enquiry No | Lineage | Inherited from Inspection → Assignment | `sourceEnquiryId` | detail | 6 | MODERNIZED | HIGH | Derived. |
| Insert By | Author | Audit | `createdByUserId` | detail "Record" | 6 | SYSTEM-DERIVED | HIGH | Read-only. |
| Update By | Editor | Audit | `updatedByUserId` | detail "Record" | 6 | SYSTEM-DERIVED | HIGH | Read-only. |
| Status | Lifecycle | Minimal modern lifecycle | `ServiceWorkExecution.status` | detail / list | 6 | MODERNIZED | HIGH | PENDING/IN_PROGRESS/COMPLETED/CANCELLED. |

Repeating work execution rows:

| Visible field / action | Business purpose | Modern equivalent | Domain property | Route / screen | Phase | Status | Confidence | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Work Time (values 1,2,3,4,5) | Row order | `lineNumber` (S.No) | `ServiceWorkExecutionLine.lineNumber` | form / detail | 6 | MODERNIZED | MEDIUM | Map to row numbering; **not** a duration (`TBD`). |
| Work | What to do | Prefilled | `line.work` | form / detail | 6 | IMPLEMENTED | HIGH | From Job Assignment `work`. |
| Description | Work description | Prefilled/editable | `line.description` | form / detail | 6 | IMPLEMENTED | HIGH | From Job Assignment `descriptionForWork`; does not mutate the assignment. |
| Team Selection | Team | Existing Service Team | `line.serviceTeamId` | form / detail | 6 | IMPLEMENTED | HIGH | Active same-company only; no new entity. |
| Individual Employee | Technician | Existing Employee | `line.employeeId` | form / detail | 6 | IMPLEMENTED | HIGH | Via `WorkforceDirectory`; no Technician table. |
| Start Time | Actual start | Start Work action | `line.startedAtUtc` | detail | 6 | MODERNIZED | HIGH | UTC persisted, company-local shown. |
| End Time | Actual end | End Work action | `line.endedAtUtc` | detail | 6 | MODERNIZED | HIGH | `endedAt >= startedAt`. |
| Status (shows "WORK START") | Line progress | Derived line state | `ServiceWorkLineState` | detail | 6 | MODERNIZED | MEDIUM | Derived from timestamps; unknown legacy values not invented. |
| Add row | Add work item | Add work item | draft line (client UUID) | form | 6 | MODERNIZED | HIGH | Manual lines have null source. |
| Delete row | Remove work item | Remove work line | draft line | form | 6 | MODERNIZED | HIGH | Only unstarted lines. |

Material Used:

| Visible field / action | Business purpose | Modern equivalent | Domain property | Route / screen | Phase | Status | Confidence | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S.No | Row order | Line order | `ServiceWorkExecutionMaterialUsed.lineNumber` | form / detail | 6 | MODERNIZED | HIGH | Presentation only. |
| Code | Material code | Business reference | `code` | form / detail | 6 | IMPLEMENTED | HIGH | Optional link to a Material Request line. |
| Description | Material description | Required text | `description` | form / detail | 6 | IMPLEMENTED | HIGH | |
| Add row / Delete row | Add/remove used material | Add/remove material used | draft/child row | form / detail | 6 | MODERNIZED | HIGH | No stock/inventory side effect. |

Photos After Work:

| Visible field / action | Business purpose | Modern equivalent | Domain property | Route / screen | Phase | Status | Confidence | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S.No | Row order | Line order | `ServiceWorkExecutionPhotoEntry.lineNumber` | form / detail | 6 | MODERNIZED | HIGH | |
| Description | Photo description | Required text | `entry.description` | form / detail | 6 | IMPLEMENTED | HIGH | |
| Photo | Evidence image | Shared attachments | `AttachmentRecords` | form / detail | 6 | IMPLEMENTED | HIGH | `serviceWorkExecutionPhotoEntry` / `afterWorkPhoto`; multiple allowed. |
| Add row / Delete row | Add/remove evidence | Add/remove photo entry | draft/child row | form / detail | 6 | MODERNIZED | HIGH | |

Actions:

| Visible action | Modern equivalent | Notes |
| --- | --- | --- |
| Save | Create / Save Changes | |
| Clear | Reset Form | Confirm before clearing. |
| Delete | Cancel Work Execution | Never hard-deleted. |

Before/After photo separation: Inspection owns **Before Work Photos**
(`serviceInspectionChecklistItem` / `beforeWorkPhoto`); Work Execution owns
**After Work Photos** (`serviceWorkExecutionPhotoEntry` / `afterWorkPhoto`).

## Open product-confirmation questions

1. **Material Received** — what does it mean at the Enquiry stage, and is it
   editable later? (Currently a header Yes/No flag carried into Assignment.)
2. **Per-detail Enquiry Status vocabulary** — only a minimal `open`/`closed` set
   is modelled; explicitly non-workflow.
3. **Per-line Job Assignment Status vocabulary** — the client shows a Status
   selector per work row but not its values; only a minimal `pending` default is
   modelled. **TBD — CLIENT CONFIRMATION.**
4. **Photo types** — images only, or documents too? (Attachment policy currently
   allows common images + PDF.)
5. **Multiple files per detail** — assumed yes (up to the shared limit of 20).

Phase 6 closure — final TBD classification (implemented behavior vs. remaining
client confirmation):

| Concept | Implemented behavior | Remaining TBD |
| --- | --- | --- |
| Job Order | `jobOrderReference` compatibility reference | authoritative owner/source — **TBD — CLIENT CONFIRMATION** |
| Quotation | `quotationReference` compatibility reference | authoritative owner/source — **TBD — CLIENT CONFIRMATION** |
| Work Time | `lineNumber` row ordering | reason for the misleading legacy label — **TBD — CLIENT CONFIRMATION** |
| Work-line Status | derived Start/End state (NOT_STARTED / IN_PROGRESS / FINISHED) | exact legacy dropdown vocabulary — **TBD — CLIENT CONFIRMATION** |
| After Work Photos | description + multiple attachments + gallery + scoped access | whether mandatory before completion — **TBD — CLIENT CONFIRMATION** |
| Material Used | Code + Description | future Qty/UOM once Inventory exists — **TBD / FUTURE INVENTORY SCOPE** |

None of these concepts is unimplemented; each has its approved modern
representation. Only the surrounding business rule/source remains open.

## Phase 7 — end-to-end workflow integration (traceability closure)

Phase 7 adds **no** new client-facing field and no new business transaction. It
integrates the existing transactions into one workflow read model. The following
previous items are now resolved or clarified by implementation (see
`docs/services/services_workflow.md`):

| Item | Phase 7 status | Notes |
| --- | --- | --- |
| Material Received single owner | RESOLVED (rule) | Exactly one authoritative owner: Enquiry. No downstream table stores an editable value; contradiction is structurally impossible. Business *meaning* remains TBD. |
| Transaction lineage | IMPLEMENTED | Enquiry → Assignment → Inspection → Material Request → Work Execution resolved by `ServiceWorkflowChain`; source ids re-checked per node. |
| Workflow timeline | IMPLEMENTED | Shared `ServiceWorkflowTimeline` on all five detail pages; real records only; optional Material Request shown as "not required / none created". |
| Cross-detail navigation | IMPLEMENTED | Backward/forward links per stage; each re-checks authorization. |
| Next-action engine | IMPLEMENTED | Central `ServiceWorkflowActionResolver`; no workflow-state logic in widgets. |
| Derived workflow status | IMPLEMENTED | Presentation-only `ServiceWorkflowStatus`, never persisted. |
| Services Overview / My Work | IMPLEMENTED | Permission/scope-aware metrics + ASSIGNED "My Work" + TEAM/ALL; summary projections (no N+1). |
| Operational queues | IMPLEMENTED (derived) | Derived list/filter views; no new queue entities; no approval queues. |
| Workflow activity feed | IMPLEMENTED | Merged structured events across the five transactions, authorization-filtered, timestamp-ordered. |
| Attachment ownership audit | IMPLEMENTED | Before (Inspection) vs After (Work Execution) visual evidence; ownership never combined. |
| Material lineage | IMPLEMENTED (optional) | Inspection → Request → Used preserved with optional source ids; manual records allowed. |
| Work Execution before Material Request | TBD (documented) | Not blocked; both actions offered. Genuine business question. |
| Service Reports | DEFERRED | Hidden / not implemented; not replaced by dashboard metrics. |

No client field was silently omitted. Fields previously classified `IMPLEMENT`
are normalized to `IMPLEMENTED` above.

## Change log

| Phase | Added |
| --- | --- |
| 2 | Enquiry header, Customer/Site, masters, status, sequence, permissions. |
| 2.1 | Detail lines, per-line status, per-line photos, Material Received, traceability doc. |
| 3 | Job Assignment & Scheduling (header, work lines, Employee/Team, Visit Date, scopes, notifications). |
| 4 | Inspection (header, checklist + before-work photos, inspected points, material required, Root Cause / Charge Responsibility masters, scopes). |
| 5 | Request for Material (header, material lines, purpose master, WAITING→REQUESTED handoff, print, scopes, cross-phase Material Received rule). |
| 6 | Work Execution (header, work lines + Start/End, derived line state, Material Used, After Work Photos, complete/cancel, edit vs perform, scopes, Job Order/Quotation compatibility, schema 18). |
| 7 | Workflow read model (`ServiceWorkflowChain`), shared timeline, cross-detail links, next-action resolver, derived workflow status, Overview + My Work, derived operational queues, merged workflow activity, before/after evidence, data consistency validator, workflow docs (ownership + transition matrices). No schema change (v18). |
