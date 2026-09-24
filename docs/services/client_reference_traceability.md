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
| Enquiry No | Source enquiry | Eligible-Enquiry selector | `ServiceJobAssignment.sourceEnquiryId` | form / detail | 3 | IMPLEMENT | HIGH | Restricted reference lookup. |
| Customer Name | Context | Enquiry/customer snapshot | `partySnapshot.customerName` | detail | 2–3 | MODERNIZED | HIGH | Read-only. |
| Mobile No | Context | Enquiry party snapshot | `partySnapshot.customerMobile` | detail | 2–3 | MODERNIZED | HIGH | Read-only. |
| Complaint Type | Context | Source Enquiry ComplaintType | resolved name | detail | 2–3 | MODERNIZED | HIGH | Read-only. |
| Priority Type | Context | Source Enquiry Priority | resolved name/rank | list / detail | 2–3 | MODERNIZED | HIGH | Read-only. |
| Tenant Name | Context | Site snapshot | `partySnapshot.tenantName` | detail | 2–3 | MODERNIZED | HIGH | Read-only. |
| Building | Context | Site snapshot | `partySnapshot.buildingName` | detail | 2–3 | MODERNIZED | HIGH | Read-only. |
| Unit No | Context | Site snapshot | `partySnapshot.unitNumber` | detail | 2–3 | MODERNIZED | HIGH | Read-only. |
| Material Received | Context | Source Enquiry value | resolved from Enquiry | detail | 2.1–3 | IMPLEMENT | HIGH | Informational; no material behaviour. |
| Visit Date | Scheduling input | `scheduledVisitDate` | `ServiceJobAssignment.scheduledVisitDate` | form / detail | 3 | IMPLEMENT | HIGH | Company timezone. |
| Insert By | Author | Audit | `createdByUserId` | detail "Record" | 3 | SYSTEM-DERIVED | HIGH | Read-only. |
| Update By | Last editor | Audit | `updatedByUserId` | detail "Record" | 3 | SYSTEM-DERIVED | HIGH | Read-only. |

Repeating job assignment rows:

| Visible field / action | Business purpose | Modern equivalent | Domain property | Route / screen | Phase | Status | Confidence | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S.No | Row order | Line order | `ServiceJobAssignmentLine.lineNumber` | form / detail | 3 | MODERNIZED | HIGH | Presentation only, not identity. |
| Work | Task to assign | Multiline work | `ServiceJobAssignmentLine.work` | form / detail | 3 | IMPLEMENT | HIGH | Required. |
| Technician Name | Assignee | Employee via `WorkforceDirectory` | `assignedEmployeeId` | form / detail | 3 | MODERNIZED | HIGH | No Technician table. |
| Team (checkbox) | Assignee team | Explicit Service Team selector | `assignedTeamId` | form / detail | 3 | MODERNIZED | HIGH | Employee-only / Team-only / both. |
| Status | Per-line status | Typed per-line enum | `ServiceJobAssignmentLine.status` | form / detail | 3 | TBD | LOW | Only `pending` modelled; exact values unconfirmed. |
| Description For Work | Instructions | Multiline instructions | `descriptionForWork` | form / detail | 3 | IMPLEMENT | HIGH | Separate from `work`. |
| Add row (+) | Add work | Add work item | draft line (client UUID) | form | 3 | MODERNIZED | HIGH | Visible labelled button. |
| Delete row | Remove work | Remove work item (soft) | `removedAt` | form | 3 | MODERNIZED | HIGH | Never zero lines. |
| Delete transaction | Cancel | Cancel Assignment (historical) | `status` | list / detail | 3 | MODERNIZED | HIGH | No hard delete. |

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

## Change log

| Phase | Added |
| --- | --- |
| 2 | Enquiry header, Customer/Site, masters, status, sequence, permissions. |
| 2.1 | Detail lines, per-line status, per-line photos, Material Received, traceability doc. |
| 3 | Job Assignment & Scheduling (header, work lines, Employee/Team, Visit Date, scopes, notifications). |
