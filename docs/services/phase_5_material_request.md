# Services Phase 5 — Request for Material

Phase 5 implements the **Request for Material** transaction that sits between
Inspection (Phase 4) and the future Work Execution (Phase 6). It deliberately
implements *only* the material request; there is no Inventory, Store, Stock,
approval, issue or consumption workflow.

## Workflow position

```
Service Enquiry
      ↓
Job Assignment & Scheduling
      ↓
Inspection
      ↓
Request for Material   ← Phase 5
      ↓
Work Execution         ← Phase 6 (not started)
```

## Client mapping

| Client field / action | Modern mapping | Notes |
| --- | --- | --- |
| Company Name | Active `CompanyContext` | System-derived; never editable. |
| Request No | `ServiceMaterialRequest.requestNumber` (`MR-…`) | Shared company-scoped sequence. |
| Date | `requestDate` | Company business date via `CompanyTimeService`. |
| JOB Order No | `jobOrderReference` (optional free text) | Business reference preserved; **no JobOrder entity**. |
| Purpose | `purposeId` → `ServiceMaterialRequestPurposes` master | Configurable; active values selectable. |
| Acknowledge | `acknowledgement` (optional safe text) | Semantics **TBD**; never drives state. |
| Received By | `receivedBy` (optional safe text) | Identity type **TBD**; no relationship forced. |
| Remarks | `remarks` | Request-level remarks. |
| Prepared By | `createdByUserId` | System-derived audit actor; not editable. |
| Code | `ServiceMaterialRequestLine.code` | Business code; no Product/Inventory entity. |
| Description | `line.description` | Required. |
| Batch No | `line.batchNumber` | Optional; not validated against a warehouse. |
| Qty | `line.quantity` (`double`, `> 0`) | Numeric; supports decimals, consistent 3 dp. |
| Remark | `line.remark` | Optional; distinct from request remarks. |
| Total Qty | `ServiceMaterialRequest.totalQuantity` | Derived `sum(lines.quantity)`; read-only. |
| Save | Create / Save Changes | |
| Print | Print Material Request | Reuses the shared `pdf` + `file_saver` report pipeline. |
| Clear | Reset Form / Discard Changes | Confirm before clearing. |
| Delete | Cancel Material Request | Never hard-deletes the transaction. |

## Material Received inheritance rule (locked)

`Material Received` is owned by the **Service Enquiry**. It is inherited
read-only downstream and is **not** a Material Request concept:

```
ServiceEnquiry.materialReceived            (authoritative)
      ↓ inherited, read-only
Job Assignment display
      ↓ inherited, read-only
Inspection display
      ↓ inherited, read-only
Material Request context (display only)
```

Rules enforced:

- No editable `materialReceived` exists on Job Assignment, Inspection or Material
  Request (the material request table has no `material_received` column; verified
  by test).
- `Material Received = YES` **does not** block creating a Material Request.
- `Material Received = NO` **does not** auto-generate a Material Request.
- Material Request creation is driven by the Inspection and its material
  requirements, not by guessing the meaning of the Enquiry flag.

## Inspection source

A Material Request references a **completed** source Inspection
(`sourceInspectionId`). The selected Inspection must be in the same company, be
`completed` (thus not `cancelled`) and be inside the creator's restricted
eligible-Inspection lookup. Lineage is retained:

```
Material Request → Inspection → Job Assignment → Enquiry
```

## Material requirement handoff

Phase 4 `ServiceInspectionMaterialRequirement` starts at `WAITING`. Phase 5 adds
one justified status, `REQUESTED`:

```
WAITING ── included in an active Material Request ──▶ REQUESTED
REQUESTED ── request cancelled / requirement removed ──▶ WAITING (when valid)
```

- Creating a request prefills draft lines from the Inspection's `WAITING`
  requirements (code + description; quantity entered by the operator). Manual
  lines are also supported with a null source requirement.
- Each generated line retains
  `sourceInspectionMaterialRequirementId` for traceability.
- A requirement may be linked to at most one **active** request. This is enforced
  both in the repository and by a partial unique index on
  `service_material_request_lines(company_id, active_requirement_id)` where
  `active_requirement_id IS NOT NULL`.
- Cancelling a request clears the active link (the source lineage column is
  retained) and reverts linked requirements `REQUESTED → WAITING`.
- Multiple requests per Inspection are allowed (e.g. materials requested later or
  partial requirements grouped separately).

## Job Order compatibility strategy

The client screen contains **JOB Order No**, but no supplied reference establishes
where a Job Order is created, which module owns it, how it links to a Quotation,
or whether Services creates it.

Therefore:

- No `JobOrder` entity/module/workflow is created.
- `jobOrderReference` is preserved as an optional free-text business reference.
- No fake Job Order dropdown is rendered.
- A later migration can replace it with `jobOrderId` + `jobOrderNumber` snapshot.
- **TBD — authoritative Job Order source.**

## Purpose master

`ServiceMaterialRequestPurposes` is a configurable company master (code, name,
description, status, sort order, sync metadata) managed through the shared
`LocalServiceMasterRepository` and the configuration list/form pages at
`/app/services/settings/material-request-purposes`. Active values are selectable;
inactive historical values still resolve by name on stored requests.

The exact production option list is **TBD — client confirmation**; only a demo
value ("Service Work") is seeded.

## Acknowledge / Received By TBD

- `acknowledgement` stores optional safe metadata/text and never approves, issues,
  receives or completes the request. Exact semantics are **TBD**.
- `receivedBy` stores optional safe text. The reference does not prove whether it
  is an Employee, store user, tenant, customer or free-text person, so no
  relationship is forced. **TBD — client confirmation.**

## Request lifecycle

Minimal, evidence-based states only:

- `OPEN` — editable (permission-gated) and printable.
- `CANCELLED` — historical/read-only, no normal edit, no second cancel.

No `APPROVED` / `REJECTED` / `ISSUED` / `RECEIVED` / `PARTIALLY_ISSUED` /
`CONSUMED` states are modelled.

## Line model

`ServiceMaterialRequest` ── `lines[]` ── `ServiceMaterialRequestLine`.

Lines have a stable UUID identity, display order (`lineNumber`), business code,
required description, optional batch number, numeric quantity (`> 0`) and optional
remark. The aggregate derives both `itemCount` and `totalQuantity`; totals are
never stored authoritatively and never entered by hand. The number of lines is
1..N (no fixed rows).

## Status transitions

| Trigger | Material requirement transition | Request status |
| --- | --- | --- |
| Create request with linked requirements | `WAITING → REQUESTED` | (new) `OPEN` |
| Update: requirement added | `WAITING → REQUESTED` | `OPEN` |
| Update: requirement removed | `REQUESTED → WAITING` (if no other active link) | `OPEN` |
| Cancel request | linked `REQUESTED → WAITING` | `OPEN → CANCELLED` |

All transitions happen atomically with line changes, activity and outbox in one
transaction.

## Permissions

| Permission | Scope | Enforced at |
| --- | --- | --- |
| `services.materialRequests.view` | assigned / team / all | nav, route, reads (scope), actions |
| `services.materialRequests.create` | none (implies view all) | nav, `/new`, restricted inspection lookup, mutation |
| `services.materialRequests.edit` | none (implies view all) | `/edit`, mutation |
| `services.materialRequests.cancel` | none (implies view all) | cancel action, mutation |
| `services.materialRequests.print` | none (implies view all) | print action, direct print invocation |
| `services.materialRequestPurposes.view` | none | settings nav, purpose list |
| `services.materialRequestPurposes.manage` | none (implies purpose view) | purpose new/edit, mutations |

Direct URLs and direct print invocation re-check permission **and** object scope;
use cases and the repository re-check every mutation.

## Scopes

`ServiceMaterialRequestScopeResolver` resolves `none / assigned / team / all` via
the shared `AccessScopeResolver` (`all > team > assigned`). ASSIGNED resolves from
the source workflow relationships: the Inspection technician, a direct employee on
the source Job Assignment, or membership of an assigned Service Team. TEAM uses
the Services team scope and never expands to ALL. ALL is company-scoped only.

## Routes

```
/app/services/material-requests
/app/services/material-requests/new
/app/services/material-requests/:requestId
/app/services/material-requests/:requestId/edit
/app/services/material-requests/:requestId/print
/app/services/settings/material-request-purposes
/app/services/settings/material-request-purposes/new
/app/services/settings/material-request-purposes/:id
/app/services/settings/material-request-purposes/:id/edit
```

The navigation item "Material Requests" sits directly after Inspections.

## Repository

`ServiceMaterialRequestRepository` (local Drift implementation) provides:
watch requests, detail, create, update, cancel, restricted eligible-Inspection
search, source context, requests for an Inspection, summary and recent queries.
Every read enforces view permission + record scope; every mutation enforces the
action permission.

## Print

`MaterialRequestPrintService` builds a `MaterialRequestPrintDocument` from the
detail read model and renders a professional PDF (company name, request number,
date, inspection/assignment/enquiry numbers, job order reference, purpose,
customer/site, inherited material received, acknowledge, received by, remarks,
prepared by, the material table with S.No/Code/Description/Batch/Qty/Remark and
the derived Total Qty). It reuses the shared `pdf` + `file_saver` pipeline and
enforces View + Print + object scope.

## Outbox and activity

Outbox operations (idempotent by unique `requestId`):

```
SERVICES_MATERIAL_REQUEST_CREATE
SERVICES_MATERIAL_REQUEST_UPDATE
SERVICES_MATERIAL_REQUEST_CANCEL
```

Payload contains the request header, source Inspection/Assignment/Enquiry ids,
job order reference, purpose id, acknowledgement, received by, remarks and the
lines (id, source requirement id, code, description, batch number, quantity,
remark). No binary attachments.

Activity events: `services.materialRequest.created`, `.updated`, `.cancelled`,
`.linesChanged`. No Store/Approval notifications are created (activity only).

## Database

Schema **version 17**. New tables:

- `service_material_request_purposes`
- `service_material_requests`
- `service_material_request_lines`

Plus indices (company/status/date, company/inspection, company/assignment,
company/enquiry, lines-by-request) and the partial unique index
`service_material_request_lines_active_requirement` guaranteeing one active
request per requirement. Migrations are idempotent (`_ensureTable`), preserving
all existing data.

## Next-phase handoff

Phase 6 (Work Execution) will consume the Inspection and material requests as
context. It will introduce its own Work Execution transaction (Job Order,
Quotation, Work, Description, Team/Individual, Start/End Time, Status, Material
Used, After Work Photos). Phase 5 intentionally does not model any of that.

## Remaining genuine TBDs

1. Where a Job Order is created and which module owns it.
2. The client's actual Purpose option list.
3. The exact meaning of Acknowledge.
4. Who/what Received By can represent.
5. Whether a later Store process approves/issues the request.
