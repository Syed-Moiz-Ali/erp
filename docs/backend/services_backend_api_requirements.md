# Services Backend API Requirements

**Audience:** Backend architect / API developer.
**Source of truth:** the currently implemented Services module (directory,
configuration, Enquiry, Job Assignment, Inspection, Material Request, Work
Execution, workflow read model, overview) and the shared transaction foundation
(numbering, attachments, activity, outbox, company time). Nothing in this
document is invented from a generic ERP template; unresolved business rules are
marked **TBD** rather than guessed.
**Scope:** the complete Services module. HR, Attendance, Leave and Platform APIs
are specified in a separate increment.
**Status:** requirement document only. No backend code, no client changes.

> **Reading note.** Every endpoint below uses the full endpoint section format
> (all labels present). Where a label’s value is the standard defined earlier in this document
> it is written as a short pointer (for example “Standard (§9)”) so the label is
> never omitted while the contract stays readable. “None / Not applicable” is
> written where a feature genuinely does not exist.

---

## 1. Purpose & Scope

This document specifies every backend API required to serve the implemented
Services module so a backend can be built independently of the client
technology. It defines endpoints, authorization, request/response contracts,
server-derived fields, validations, atomic side effects, activity events,
notifications, idempotency, concurrency, audit, and the operational/dashboard
queries.

Covered domains:

1. Services Overview (operational dashboard + My Work).
2. Customers.
3. Service Sites.
4. Service Teams (+ membership, + team lead).
5. Services Configuration masters.
6. Service Enquiries (+ detail issue lines + photos + Material Received).
7. Job Assignment & Scheduling (+ work assignment lines).
8. Inspections (+ checklist + before-work photos + inspected points +
   material requirements).
9. Material Requests (+ requested lines + print data).
10. Work Executions (+ work lines + material used + after-work photos).
11. Workflow timeline / lineage (derived read model).
12. Services notifications / deep-link metadata where backend participation is
    required.
13. Services dashboard/summary queries.

The Services module is one of five implemented transactions forming a single
workflow:

```
Service Enquiry
      ↓
Job Assignment & Scheduling
      ↓
Inspection
      ↓
Request for Material   (CONDITIONAL / OPTIONAL)
      ↓
Work Execution
```

The optional branch is supported: `Enquiry → Assignment → Inspection → Work
Execution` when no material is required, and `Enquiry → Assignment → Inspection
→ Material Request → Work Execution` otherwise.

### 1.1 Relationship to existing backend conventions

The Services API follows the same platform conventions already established for
the rest of the ERP (base path, envelopes, headers, error model, tenant
isolation, idempotency, activity). Where the Services module adds a
domain-specific rule it is stated explicitly.

---

## 2. Explicit Exclusions

The following are **not** implemented and MUST NOT be invented by this document:

| Excluded | Rule |
| --- | --- |
| Job Order CRUD | No Job Order entity exists. `jobOrderReference` is an optional free-text compatibility reference only; authoritative owner/source = **TBD**. No lookup API may be built from this document. |
| Quotation CRUD | No Quotation entity exists. `quotationReference` is an optional free-text compatibility reference only; authoritative owner/source = **TBD**. No lookup API. |
| Inventory / Warehouse / Stock | Not implemented. Material records are business references only; recording Material Used has **no** stock or inventory side effect. |
| Purchase / Sales / Invoice / Payment | Not implemented. Charge Responsibility is a classification master, **not** an invoice or billing object. |
| Service Reports | Not implemented; no report endpoints (`revenue`, `technician-performance`, `sla`, etc.) exist. Client Service Reports requirements remain unavailable. |
| SLA / deadlines | Priority does **not** imply an SLA. No deadline fields or SLA endpoints. |
| Approval workflows | No approval/issue/receive/acknowledgement workflow exists for Material Requests or Inspections. |
| Department / Designation as Services access | Never used for Services authorization. |
| Technician / Inspector / Worker entities | Do not exist. Services references existing Employees. |
| Billing from Charge Responsibility | Not permitted. |
| Attachments as person/asset registry | Attachments are evidence metadata owned by a business record. |

---

## 3. API Standards

### 3.1 Base path & versioning

- Base path: `/api/v1`.
- Services domain base: `/api/v1/services`.
- Breaking changes → `/api/v2`; additive changes stay in `v1`.
- JSON only (`application/json; charset=utf-8`) except direct file upload
  (binary transport, §17). Binary bytes are **never** embedded in transaction
  JSON.

### 3.2 Content type & casing

- Request/response bodies are JSON object envelopes (see §9, §10).
- Field names are `camelCase`. Enum/status wire values are stable lower-camel
  strings exactly as implemented (for example `open`, `assigned`, `inProgress`).

### 3.3 Idempotent vs non-idempotent

- All creates, commands (cancel/complete/start/end), and child-row mutations
  support an idempotency key (§14).
- Reads are naturally safe.

### 3.4 Localization

- User-facing text is returned as stable keys/codes plus resolved labels, or
  resolved server-side using `Accept-Language`. Raw enum wire values are never
  translated. Error `code` is always machine-stable.

---

## 4. Authentication

| Aspect | Requirement |
| --- | --- |
| Scheme | `Authorization: Bearer <accessToken>` on every endpoint except platform login/refresh (out of Services scope). |
| Identity | The authenticated user account resolves to an optional linked Employee reference. |
| Services endpoints | In addition to a valid token, the effective access check in §6 must pass. |
| Anonymous | No Services endpoint is anonymous. |

Authentication failure → `401` with code `UNAUTHENTICATED` (§10).

---

## 5. Company / Tenant Context

| Aspect | Requirement |
| --- | --- |
| Selected company | Sent as `X-Company-Id: <company-uuid>` for all company-scoped requests. |
| Server authority | The server MUST NEVER trust a company id supplied in a request body or query string. The effective company = authenticated user ∩ selected company ∩ company membership. |
| Record ownership | Every Services query and mutation enforces `record.companyId == active authorized company`. |
| Cross-company | A technically valid UUID from another company MUST be rejected (treated as not found / forbidden per §10), never returned. |
| Sequences | Company-scoped: `(companyId, document number)` is unique. |
| Attachments & activity | Also company-scoped. |

Company mismatch / unauthorized company → `403` (`COMPANY_SCOPE_MISMATCH`) or
`404` where existence must not be disclosed (§10, §38).

---

## 6. Authorization & Scopes

### 6.1 Effective access model

A request is authorized only when **all** of the following hold:

```
company module "services" enabled
AND permission granted (per §33)
AND required Employee link valid (where the endpoint requires it)
AND requested record lies inside the granted scope
AND record.companyId == active company
```

Runtime authorization is **permission/scope-driven only**. Labels such as Admin,
Technician, Inspector, Manager, Service Manager, department name, designation
name or team name MUST NOT be used for authorization.

### 6.2 Scope vocabulary

Scopes are encoded on the permission grant: `NONE`, `SELF`, `ASSIGNED`, `TEAM`,
`ALL`. Services operational transactions use **ASSIGNED**, **TEAM**, **ALL**;
`SELF` is **not** used for Services transactions. `ALL` is always company-scoped,
never global.

### 6.3 Scope precedence

The broadest granted scope wins: `ALL > TEAM > ASSIGNED > NONE`. The server must
implement this precedence consistently with the platform access model.

### 6.4 ASSIGNED semantics (exact)

ASSIGNED is defined per transaction by the actual resolvers:

| Transaction | ASSIGNED qualifies a record when the linked Employee… |
| --- | --- |
| Job Assignment | is directly selected on a work line (`assignedEmployeeId`) **OR** is an active member of an assigned Service Team (`assignedTeamId`). |
| Inspection | is the assigned technician (`technicianEmployeeId`) **OR** is directly selected on a source Job Assignment line **OR** is an active member of an assigned Service Team on the source Job Assignment. |
| Material Request | is the source Inspection technician **OR** is directly selected on the source Job Assignment line **OR** is an active member of an assigned Service Team on the source Job Assignment. |
| Work Execution | is directly selected on a Work Execution line (`employeeId`) **OR** is directly selected on the source Job Assignment line **OR** is the source Inspection technician **OR** is an active member of an assigned Service Team (on a Work Execution line or the source Job Assignment line). |

An employee with no linked Employee reference resolves ASSIGNED/TEAM to **no
records** (empty scope), never to ALL.

### 6.5 TEAM semantics (exact)

TEAM is resolved from **Service Team membership only** (`service_team_members`
rows with status `active`). Department or designation MUST NOT imply Services
TEAM access. TEAM never silently expands to ALL.

| Transaction | TEAM qualifies a record when the linked Employee is an active member of a Service Team that is assigned on the relevant record |
| --- | --- |
| Job Assignment | the assignment’s work line references that team. |
| Inspection | a source Job Assignment line references that team. |
| Material Request | a source Job Assignment line references that team. |
| Work Execution | a Work Execution line references that team **OR** a source Job Assignment line references that team. |

### 6.6 ALL semantics

ALL returns all permitted records in the selected company only, subject to
filters.

### 6.7 Permission view dependencies

Action permissions imply the matching view scope (single normalization rule):

| Action permission (group) | Implied view |
| --- | --- |
| `services.enquiries.edit`, `services.enquiries.cancel` | `services.enquiries.view` (scope `all`) |
| `services.jobAssignments.create/edit/cancel` | `serviceJobAssignmentViewAll` |
| `services.inspections.create/edit/complete/cancel` | `serviceInspectionViewAll` |
| `services.materialRequests.create/edit/cancel/print` | `serviceMaterialRequestViewAll` |
| `services.workExecutions.create/edit/perform/complete/cancel` | `serviceWorkExecutionViewAll` |
| any `*.manage` (teams, masters) | matching `*.view` |

`services.enquiries.create` deliberately does **not** imply View: a create-only
operator can create enquiries and use restricted reference lookups, but cannot
list company enquiries.

### 6.8 Module disablement

If the company’s `services` module is disabled, **every** Services scope
resolver returns NONE and every Services endpoint must reject. Error:
`403 SERVICES_MODULE_DISABLED` (or an existence-hiding `404` where policy
requires).

### 6.9 No decorative permission

Every permission in §33 maps to real reads/actions. A permission that is not
granted must not be evaluable from response shape (do not distinguish “exists but
forbidden” from “not found” where this would leak restricted data).

---

## 7. Employee / Workforce Context

| Aspect | Requirement |
| --- | --- |
| No Services person entity | There is no Technician, Inspector or Worker entity. Services references existing Employees. |
| Employee link | The authenticated user account resolves to an optional Employee reference (`userAccountId`, `companyId`, `employeeId`). ASSIGNED/TEAM scope requires a valid link. |
| Employee reference fields | Only `id`, `name`, `employeeCode`, `departmentId`, `departmentName`, `designationId`, `designationName`, `workLocationId`, `avatarReference`, `isActive` and the linked user account id are ever needed by Services. HR-private fields (salary, personal data, documents) MUST NOT be exposed through Services reference endpoints. |
| Active-only selection | New assignment searches exclude inactive employees by default. Historical references resolve inactive employees for display. |
| Company scoping | Employee lookups are company-scoped; unknown or other-company ids are omitted. |
| Notification targeting | An employee’s linked user account id (when present) is used to target assignment/inspection notifications. |
| Team lead | A Service Team may have one `leadEmployeeId`; membership includes the lead. |
| Multiple teams | An employee may belong to multiple Service Teams. Membership does **not** grant any permission. |

Reference endpoint: `GET /services/references/employees` (§30).

---

## 8. Common Headers

| Header | Required | Notes |
| --- | --- | --- |
| `Authorization: Bearer <accessToken>` | yes | §4. |
| `X-Company-Id: <company-uuid>` | yes | §5; server verifies membership. |
| `X-Request-Id: <uuid>` | recommended | echoed in `meta.requestId`; used for tracing. |
| `Idempotency-Key: <uuid>` | required for every mutation listed in §14 | maps to the client outbox `requestId`. |
| `Accept-Language: en \| ar` | optional | response message language; never authorization. |
| `Content-Type` | yes on bodies | `application/json` (except binary upload). |

---

## 9. Response Envelope

### 9.1 Single-resource success

```json
{
  "success": true,
  "data": { },
  "meta": { "requestId": "uuid", "serverTimeUtc": "2026-09-28T06:00:00Z" }
}
```

### 9.2 List success (offset pagination)

```json
{
  "success": true,
  "data": [ ],
  "meta": {
    "page": 1,
    "pageSize": 25,
    "totalItems": 120,
    "totalPages": 5,
    "filteredItems": 12,
    "requestId": "uuid",
    "serverTimeUtc": "2026-09-28T06:00:00Z"
  }
}
```

`totalItems` is the company/scope total; `filteredItems` is the count after the
applied filters (matching the implemented total vs filtered counts).

### 9.3 Command success

Commands (cancel/complete/start/end) return the updated aggregate representation
(never only `{"success":true}`), plus `meta.requestId`, so the client can
reconcile local state. A `cancel` that produces no state change (already
cancelled via idempotent replay) returns the current aggregate.

---

## 10. Error Model

### 10.1 Error envelope

```json
{
  "success": false,
  "error": {
    "code": "SERVICES_ENQUIRY_NOT_FOUND",
    "message": "Service enquiry not found.",
    "fieldErrors": [ { "field": "customerId", "code": "SERVICES_ENQUIRY_CUSTOMER_REQUIRED" } ],
    "details": {}
  },
  "meta": { "requestId": "uuid", "serverTimeUtc": "2026-09-28T06:00:00Z" }
}
```

- `code` is a stable UPPER_SNAKE machine code (§36).
- `message` is a display-safe localized string (never a raw exception).
- `fieldErrors` carries field-level validation codes.
- `details` carries safe structured context only (no restricted record data).

### 10.2 HTTP status semantics

| Status | Meaning |
| --- | --- |
| `400` | Validation failure (missing/invalid field, cross-field rule). |
| `401` | Not authenticated / expired token. |
| `403` | Authenticated but not authorized (permission/scope/module/company). |
| `404` | Resource not found **or** hidden by security policy (scope/company). |
| `409` | State / concurrency / idempotency conflict. |
| `422` | Reserved; only if the wider backend convention adopts it. Otherwise unused. |
| `500` | Unexpected server failure. |

### 10.3 Security decision rule

When disclosure would leak restricted data, prefer `404` over `403`. Do not
reveal the existence of a record outside the caller’s scope/company.

---

## 11. Pagination / Search / Sort

### 11.1 Pagination

- Offset model: `page` (1-based; default 1) and `pageSize` (default 25, maximum
  100). `pageSize=0` is invalid.
- Responses include `page`, `pageSize`, `totalItems`, `totalPages`,
  `filteredItems`.

### 11.2 Common query conventions

Supported only where documented per endpoint:

| Query | Meaning |
| --- | --- |
| `q` | Free-text search over normalized searchable fields. |
| `status` | Status filter (documented per endpoint). |
| `customerId`, `siteId` | Context filter direction. |
| `employeeId`, `teamId` | Assignment relationship filter. |
| `dateFrom`, `dateTo` / `visitFrom`, `visitTo` | Business-date range (company-local date semantics). |
| `sort` | `field:asc\|desc` from an allow-list (§11.3). |
| `page`, `pageSize` | Pagination. |

Filtering/enumeration must never be used to enumerate records outside the
granted scope: scope is applied **before** filters.

### 11.3 Server-side sort allow-list

Only these sort keys may be accepted; any other key → `400`
`SERVICES_INVALID_SORT`. Implemented default orderings are noted.

| Domain | Allowed sort keys | Default |
| --- | --- | --- |
| Customers | `name`, `customerCode`, `updatedAt` | `name asc` |
| Sites | `siteName`, `siteCode`, `customerName`, `updatedAt` | `siteName asc` |
| Teams | `name`, `teamCode`, `updatedAt` | `name asc` |
| Enquiries | `createdAt`, `enquiryNumber`, `priorityRank` | `createdAt desc` |
| Job Assignments | `scheduledVisitDate`, `createdAt`, `assignmentNumber` | `scheduledVisitDate desc, createdAt desc` |
| Inspections | `visitDate`, `createdAt`, `inspectionNumber` | `visitDate desc, createdAt desc` |
| Material Requests | `requestDate`, `createdAt`, `requestNumber` | `requestDate desc, createdAt desc` |
| Work Executions | `executionDate`, `createdAt`, `executionNumber` | `executionDate desc, createdAt desc` |
| Masters | `sortOrder`, `name`, `code` | `sortOrder asc, name asc` |

Search behavior: case-insensitive substring (`LIKE`) over the documented
searchable fields; search characters are escaped. Search is not a scope bypass.

---

## 12. Dates & Timezones

| Concept | Rule |
| --- | --- |
| Instants | Persisted and returned as UTC ISO-8601 (for example `2026-09-28T06:00:00Z`). Applies to `createdAt`, `updatedAt`, `startedAtUtc`, `endedAtUtc`, activity/notification timestamps. |
| Business dates | `assignmentDate`, `inspectionDate`, `requestDate`, `executionDate`, `scheduledVisitDate`, `visitDate` are company-local **dates** (date-only significance). |
| Business date derivation | Derived from the company timezone, **never** from server or device timezone. |
| Time-of-day | Inspection `visitMinutes` is minutes-of-day in company-local time. |
| Company timezone | Comes from the company context. Supported fixed-offset zones (actual implementation): `UTC`, `Etc/UTC`, `Asia/Dubai` (+04:00), `Asia/Riyadh` (+03:00), `Asia/Karachi` (+05:00), `Asia/Kolkata`/`Asia/Calcutta` (+05:30). |
| Unsupported timezone | Fails safely (no fallback to device time); server must reject company onboarding for unsupported zones rather than guess. |
| Request format | Business dates accepted as `YYYY-MM-DD`; instants as UTC ISO-8601. Reject ambiguous local timestamps. |

---

## 13. IDs & Business Numbers

| Aspect | Rule |
| --- | --- |
| Internal IDs | UUID v4. Client may supply a UUID at create time for idempotent identity reconciliation (§14). |
| Business numbers | Separate human-readable numbers, backend-authoritative. |
| Numbering formats (implemented) | `ENQ-######` (Enquiry), `JA-######` (Job Assignment), `INS-######` (Inspection), `MR-######` (Material Request), `WE-######` (Work Execution); directory display codes `CUS-######` (Customer), `SITE-######` (Site), `TEAM-######` (Team). Padding 6, separator `-`. |
| Sequence scope | Company + document type. Atomic allocation; no duplicates; no cross-company collision. |
| Client authority | The client MUST NOT author authoritative business numbers. If the client generated a provisional local number, the backend returns the authoritative one and the client reconciles. |
| Provisioning seam | The platform supports adopting a server-assigned number to advance a local counter; the backend owns final integrity. |

---

## 14. Idempotency

### 14.1 Rule

Every mutation that can be retried accepts `Idempotency-Key` (maps to the
client outbox `requestId`). A repeated request with the same key and the same
company MUST NOT create duplicate:

- records,
- sequence numbers,
- child rows,
- activity events,
- state transitions,
- attachment metadata.

The server returns the same outcome as the original request (the current
authoritative representation) with `200`/`201` semantics as appropriate.

### 14.2 Endpoints requiring idempotency

| Domain | Operations |
| --- | --- |
| Enquiry | create, update, cancel |
| Job Assignment | create, update, cancel |
| Inspection | create, update, complete, cancel |
| Material Request | create, update, cancel |
| Work Execution | create, update, start line, end line, add/remove material used, add/update/remove photo, complete, cancel |
| Directory / masters | create, update, activate/deactivate |
| Attachments | upload-init, upload-complete, delete |

### 14.3 Identity reservation

Where the client generates a child UUID (detail lines, work lines, material
lines, photo entries, attachments), the backend accepts it as the entity
identity so retries reconcile by id. If a supplied id collides within the same
company it is treated as the same entity for that idempotent request, not as a
new row.

---

## 15. Concurrency

### 15.1 Optimistic concurrency

Every mutable transaction header (Enquiry, Job Assignment, Inspection, Material
Request, Work Execution) carries an integer `version` starting at 1 and
incremented on each successful state change.

- Updates/commands MUST send the expected `version`.
- Stale `version` → `409 RECORD_VERSION_CONFLICT`.
- The conflict response MUST return the current `version` and the current
  authoritative representation in `error.details.current` so the client can
  reconcile.

### 15.2 Command atomicity

State-changing commands are atomic with their side effects (§16.4). If any part
fails (validation, child write, activity, outbox, sequence), the whole operation
rolls back and no partial state is observable.

### 15.3 Terminal-state protection

Completed/cancelled records are read-only for structural edits. Attempting an
invalid transition returns a specific state conflict code (§36) rather than a
generic error.

---

## 16. Audit & Activity

### 16.1 Audit metadata

Mutable records expose: `createdAt`, `createdByUserId`, `updatedAt`,
`updatedByUserId`, `version`. The server derives the actor from the
authenticated user; the client MUST NOT supply authoritative `createdBy` /
`updatedBy` values.

### 16.2 Activity events

Activity is append-only, structured, never a stored English sentence. Minimum
shape:

```json
{
  "id": "uuid",
  "companyId": "uuid",
  "moduleKey": "services",
  "entityType": "serviceEnquiry",
  "entityId": "uuid",
  "eventType": "services.enquiry.created",
  "occurredAt": "2026-09-28T06:00:00Z",
  "actorUserId": "uuid",
  "actorEmployeeId": "uuid|null",
  "metadata": { }
}
```

- `eventType` is a stable namespaced key (see §16.3).
- `metadata` carries typed-from values (counts, status, source ids), never prose.
- Activity is company-scoped and visible only when the caller can view the
  owning record.

### 16.3 Implemented Services activity event keys

| Domain | eventType values |
| --- | --- |
| Customer | `services.customer.created`, `services.customer.updated`, `services.customer.activated`, `services.customer.deactivated` |
| Site | `services.site.created`, `services.site.updated`, `services.site.activated`, `services.site.deactivated` |
| Team | `services.team.created`, `services.team.members.updated`, `services.team.activated`, `services.team.deactivated` |
| Configuration master | `services.configuration.created`, `services.configuration.updated`, `services.configuration.activated`, `services.configuration.deactivated` |
| Enquiry | `services.enquiry.created`, `services.enquiry.updated`, `services.enquiry.cancelled`, `services.enquiry.assigned`, `services.enquiry.reopened` |
| Job Assignment | `services.jobAssignment.created`, `services.jobAssignment.updated`, `services.jobAssignment.visitDateChanged`, `services.jobAssignment.assignmentChanged`, `services.jobAssignment.cancelled` |
| Inspection | `services.inspection.created`, `services.inspection.updated`, `services.inspection.technicianChanged`, `services.inspection.visitChanged`, `services.inspection.rootCauseChanged`, `services.inspection.completed`, `services.inspection.cancelled` |
| Material Request | `services.materialRequest.created`, `services.materialRequest.updated`, `services.materialRequest.linesChanged`, `services.materialRequest.cancelled` |
| Work Execution | `services.workExecution.created`, `services.workExecution.updated`, `services.workExecution.workStarted`, `services.workExecution.workEnded`, `services.workExecution.materialUsedAdded`, `services.workExecution.materialUsedRemoved`, `services.workExecution.photoAdded`, `services.workExecution.photoUpdated`, `services.workExecution.photoRemoved`, `services.workExecution.completed`, `services.workExecution.cancelled` |

### 16.4 Operations requiring atomicity

The following must be single atomic units (sequence + header + children +
derived state + activity + outbox/notification where applicable):

1. Create Enquiry: sequence + header + detail lines + attachment metadata +
   activity.
2. Update Enquiry: header + reconciled detail lines + attachment metadata +
   activity.
3. Cancel Enquiry: status + `cancelledAt`/reason + version + activity.
4. Create Job Assignment: sequence + header + work lines + Enquiry
   `OPEN → ASSIGNED` + activity (+ notification).
5. Update Job Assignment: header + reconciled work lines + activity (+
   notification).
6. Cancel Job Assignment: status + Enquiry reconciliation (`ASSIGNED → OPEN`
   only when no other active assignment remains) + activity.
7. Create Inspection: sequence + header + checklist + points + material
   requirements + before-work attachment metadata + activity (+ notification).
8. Update Inspection: header + reconciled children + attachment metadata +
   activity (+ notification).
9. Complete Inspection: status + version + activity.
10. Cancel Inspection: status + version + activity.
11. Create Material Request: sequence + header + lines + requirement
    `WAITING → REQUESTED` + activity.
12. Update Material Request: header + replaced lines + requirement status
    reconciliation + activity.
13. Cancel Material Request: status + release active requirement links +
    requirement `REQUESTED → WAITING` + activity.
14. Create Work Execution: sequence + header + work lines + material used +
    photo entries + after-photo attachment metadata + activity.
15. Update Work Execution: header + reconciled work lines/material used/photo
    entries + attachment metadata + activity.
16. Start Work line: line `started_at_utc` + aggregate `PENDING → IN_PROGRESS`
    (when first start) + version + activity.
17. End Work line: line `ended_at_utc` + activity.
18. Complete Work Execution: status + version + activity.
19. Cancel Work Execution: status + version + activity.

### 16.5 Activity read

`GET /services/enquiries/{enquiryId}/activity` returns the merged,
authorization-filtered workflow activity feed (§28). Per-record activity is also
reachable via the record’s own detail/`activity` sub-resource.

---

## 17. Attachments

### 17.1 Purpose

Attachments are shared evidence metadata owned by a business record. Binary data
is **never** embedded in transaction JSON. Services uses attachments for exactly
three evidence concepts, each with a distinct owner:

| Evidence | Owner type | Category | Owning record |
| --- | --- | --- | --- |
| Enquiry issue photos | `serviceEnquiryDetail` | `problemPhoto` | Enquiry detail line |
| Before-work photos | `serviceInspectionChecklistItem` | `beforeWorkPhoto` | Inspection checklist item |
| After-work photos | `serviceWorkExecutionPhotoEntry` | `afterWorkPhoto` | Work Execution photo entry |

Ownership is never combined. The Work Execution detail presents before-work
photos (owned by the source Inspection) and after-work photos (owned by the Work
Execution) separately.

### 17.2 Attachment owner resolution

`ownerType` + `ownerId` form the ownership key. Owner integrity is enforced at
the service layer (owners span multiple tables). The server MUST verify the owner
exists, belongs to the same company, and that the caller can access the owning
record before granting attachment access.

### 17.3 Attachment authorization

Knowing an attachment UUID alone MUST NEVER grant access. Every attachment read,
download and delete is authorized **through the owning business record** using
the same permission + scope rules as that record. An attachment id can never
bypass transaction access.

### 17.4 Attachment upload lifecycle

- Upload initialization / direct upload → receive storage handle/URL.
- Upload completion → create/confirm attachment metadata linked to owner.
- Delete/remove → soft removal (audit evidence may still exist).
- Download/view → authorized by owner record.

### 17.5 Attachment validation (implemented limits)

| Rule | Value |
| --- | --- |
| Allowed MIME types | `image/jpeg`, `image/png`, `image/webp`, `image/heic`, `application/pdf` |
| Max file size | 15 MiB |
| Max attachments per owner | 20 |
| Empty file | rejected |

Attachment upload-state vocabulary: `localOnly`, `pendingUpload`, `uploaded`,
`failed`, `pendingDelete`, `deleted`. Malware/content scanning is a backend
concern; no numeric scanning limit is invented here.

### 17.6 Endpoints

Binary transport is implementation-defined (direct-to-storage upload preferred).
The following metadata endpoints are required.

---

### Initialize Attachment Upload

Purpose: Reserve an attachment identity and obtain an upload target for an owner
record.
Method: `POST`
Path: `/api/v1/services/attachments/upload-init`
Authentication: Bearer (§4).
Company Context: Required (§5).
Required Permission: The caller must be able to mutate the owning record (see
each owner’s create/edit/perform permission).
Supported Scope: Owner-record scope.
Required Employee Context: As required by the owner operation.
Headers: Standard (§8). `Idempotency-Key` required.
Path Parameters: None / Not applicable.
Query Parameters: None / Not applicable.
Request Body:

```json
{
  "attachmentId": "uuid",
  "ownerType": "serviceEnquiryDetail",
  "ownerId": "uuid",
  "category": "problemPhoto",
  "fileName": "issue.jpg",
  "displayName": "issue.jpg",
  "mimeType": "image/jpeg",
  "sizeBytes": 524288
}
```

Request Field Table:

| Field | Type | Required | Nullable | Source | Description | Validation | Example |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `attachmentId` | uuid | yes | no | client | Client-reserved identity | UUID; unique per company | `...` |
| `ownerType` | string | yes | no | client | Owner discriminator | one of the three Services owner types | `serviceEnquiryDetail` |
| `ownerId` | uuid | yes | no | client | Owning record id | owner exists & in scope | `...` |
| `category` | string | yes | no | client | Attachment category | category matches owner type | `problemPhoto` |
| `fileName` | string | yes | no | client | Storage file name | non-empty | `issue.jpg` |
| `displayName` | string | yes | no | client | Display name | non-empty | `issue.jpg` |
| `mimeType` | string | yes | no | client | Content type | allowed MIME set | `image/jpeg` |
| `sizeBytes` | integer | yes | no | client | Size | `>0` and `<= 15728640` | `524288` |

Server-Derived Fields: `companyId`, `createdByUserId`, `createdAt`,
`uploadStatus`.
Business Validations: owner exists, same company, in scope; MIME allowed; size
within limit; existing count per owner `< 20`.
Authorization / Object Scope Rules: authorizing operation’s permission + owner
record scope.
Transactional Side Effects: None / Not applicable (metadata created on
completion).
Activity Event: None / Not applicable at init (recorded with the owner
transaction / upload completion if the platform audits uploads).
Notification Side Effects: None / Not applicable.
Idempotency: Same `attachmentId` + key returns the same upload target.
Concurrency: Last-writer metadata reconciliation by `attachmentId`.
Success Response: `meta` + upload target (URL/handle), `attachmentId`,
`expiresAt`.
Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `attachmentId` | uuid | reserved identity |
| `uploadUrl` | string | target/handle (implementation-defined) |
| `expiresAt` | utc datetime | upload URL expiry |

Errors: `400` validation, `403` permission/scope, `404` owner not found,
`409` if id collides with a different owner.
Notes: No bytes in JSON.

---

### Complete Attachment Upload

Purpose: Confirm metadata after binary upload.
Method: `POST`
Path: `/api/v1/services/attachments/{attachmentId}/complete`
Authentication: Bearer.
Company Context: Required.
Required Permission: Owner mutation permission.
Supported Scope: Owner-record scope.
Required Employee Context: As required by the owner operation.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `attachmentId` (uuid).
Query Parameters: None / Not applicable.
Request Body:

```json
{ "checksum": "sha256:…", "storageKey": "…" }
```

Request Field Table:

| Field | Type | Required | Nullable | Source | Description | Validation | Example |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `checksum` | string | no | yes | client | Content checksum | optional | `sha256:…` |
| `storageKey` | string | no | yes | client | Storage key | optional | `…` |

Server-Derived Fields: `uploadStatus=uploaded`, `remoteUrl`.
Business Validations: attachment exists; owner in scope; binary size/type
verified against declared metadata.
Authorization / Object Scope Rules: Owner mutation permission + scope.
Transactional Side Effects: attachment metadata becomes authoritative; owner
record may be reconciled by the client as part of its next save.
Activity Event: None / Not applicable (owner transaction emits activity).
Notification Side Effects: None / Not applicable.
Idempotency: repeat completion is a no-op returning the same metadata.
Concurrency: by `attachmentId`.
Success Response: attachment metadata (see Response Field Table).
Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | attachment id |
| `ownerType` | string | owner discriminator |
| `ownerId` | uuid | owner record id |
| `category` | string | category |
| `fileName`,`displayName` | string | names |
| `mimeType` | string | content type |
| `sizeBytes` | integer | size |
| `uploadStatus` | string | `uploaded` |
| `remoteUrl` | string | authorized URL |
| `createdAt`,`updatedAt` | utc datetime | audit |

Errors: `400`, `403`, `404`, `409`.
Notes: None / Not applicable.

---

### Get Attachment Metadata

Purpose: Read attachment metadata for an owner (authorized through the owner).
Method: `GET`
Path: `/api/v1/services/attachments/{attachmentId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: Owner view permission.
Supported Scope: Owner-record scope.
Required Employee Context: As required by the owner view operation.
Headers: Standard.
Path Parameters: `attachmentId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `ownerType`, `ownerId`, `companyId`.
Business Validations: attachment exists, active.
Authorization / Object Scope Rules: MUST resolve the owner and authorize through
it; attachment id alone never grants access.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable (read).
Concurrency: Not applicable.
Success Response: attachment metadata.
Response Field Table: as “Complete Attachment Upload”.
Errors: `401`, `403`, `404`.
Notes: Return only metadata; binary served separately.

---

### List Attachments For Owner

Purpose: Load all active attachment metadata for one owner (aggregate display).
Method: `GET`
Path: `/api/v1/services/attachments`
Authentication: Bearer.
Company Context: Required.
Required Permission: Owner view permission.
Supported Scope: Owner-record scope.
Required Employee Context: As required by the owner view operation.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: `ownerType` (required), `ownerId` (required), or
`ownerType` + repeated `ownerIds` for batch (aggregate child rows).
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `companyId`.
Business Validations: ownerType is a known Services owner type.
Authorization / Object Scope Rules: authorize through each owner record.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: list of attachment metadata.
Response Field Table: as “Complete Attachment Upload”.
Errors: `400`, `403`, `404`.
Notes: Batch lookup avoids N+1 for aggregate child rows.

---

### Download / View Attachment

Purpose: Authorized binary access to an attachment.
Method: `GET`
Path: `/api/v1/services/attachments/{attachmentId}/content`
Authentication: Bearer.
Company Context: Required.
Required Permission: Owner view permission.
Supported Scope: Owner-record scope.
Required Employee Context: As required by the owner view operation.
Headers: Standard.
Path Parameters: `attachmentId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: None / Not applicable.
Business Validations: attachment exists and is not soft-deleted.
Authorization / Object Scope Rules: authorize through owner record; may return a
short-lived signed URL.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: binary stream or redirect to a signed URL.
Response Field Table: None / Not applicable.
Errors: `401`, `403`, `404`.
Notes: Binary permitted here only; never inside transaction JSON.

---

### Delete Attachment

Purpose: Remove an attachment from an owner (soft).
Method: `DELETE`
Path: `/api/v1/services/attachments/{attachmentId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: Owner mutation permission.
Supported Scope: Owner-record scope.
Required Employee Context: As required by the owner operation.
Headers: Standard. `Idempotency-Key` recommended.
Path Parameters: `attachmentId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `deletedAt`.
Business Validations: attachment exists.
Authorization / Object Scope Rules: owner mutation permission + scope.
Transactional Side Effects: soft-delete metadata; remote evidence may remain.
Activity Event: None / Not applicable (owner transaction may emit).
Notification Side Effects: None / Not applicable.
Idempotency: repeat delete is a no-op.
Concurrency: by `attachmentId`.
Success Response: `{ "attachmentId": "…", "deleted": true }`.
Response Field Table: None / Not applicable.
Errors: `401`, `403`, `404`.
Notes: Never a hard delete of audit evidence; deletion is a business status.

## 18. Services Overview

The overview is a permission- and scope-aware operational summary. Counts MUST
respect ASSIGNED/TEAM/ALL and permissions: the server must not compute a
company-wide count and rely on the client to hide rows. A metric is included only
when the caller holds the corresponding view permission/scope; otherwise it is
omitted (not zeroed in a way that leaks existence).

### 18.1 Overview metric sources (implemented)

| Metric | Source | Gate |
| --- | --- | --- |
| `customers` (directory total) | Customer list total | `services.customers.view` |
| `activeSites` | Site list total (status `active`) | `services.sites.view` |
| `teams` | Team list total | `services.teams.view` |
| `serviceTypes` | Service Type master total | `services.serviceTypes.view` |
| `priorities` | Priority master total | `services.priorities.view` |
| Enquiry summary (`open`, `today`, `highUrgentOpen`, `total`) | Enquiry summary | `services.enquiries.view` |
| Recent enquiries (limit 5) | Enquiry list (recent) | `services.enquiries.view` |
| Assignment summary (`active`, `today`, `upcoming`, `total`) + upcoming assignments (limit 5) | Assignment summary/list | any assignment view scope |
| Inspection summary (`pending`, `today`, `completed`, `total`) + recent (limit 5) | Inspection summary/list | any inspection view scope |
| Material request summary (`open`, `today`, `lines`, `total`) + recent (limit 5) | Material request summary/list | any material request view scope |
| Work execution summary (`pending`, `inProgress`, `completedToday`, `total`) + recent (limit 5) | Work execution summary/list | any work execution view scope |
| My Work (ASSIGNED projection) | see 18.3 | view scope + linked Employee |

### 18.2 Summary definitions (exact)

| Summary | Fields and exact derivation |
| --- | --- |
| Enquiry | `openCount` = status open; `todayCount` = open created since company-local start of day; `highUrgentOpenCount` = open with priority `rank >= 2`; `totalCount` = all in scope. |
| Job Assignment | `activeCount` = status active; `todayCount` = active with `scheduledVisitDate == today`; `upcomingCount` = active with `scheduledVisitDate > today`; `totalCount`. |
| Inspection | `pendingCount` = pending; `completedCount` = completed; `todayCount` = `visitDate == today`; `totalCount`. |
| Material Request | `openCount` = open; `todayCount` = `requestDate == today`; `lineCount` = total lines in scope; `totalCount`. |
| Work Execution | `pendingCount` = pending; `inProgressCount` = inProgress; `completedTodayCount` = completed with `executionDate == today`; `totalCount`. |

`today` means the company-local business date (§12).

---

### Services Overview

Purpose: Return the operational dashboard for the caller.
Method: `GET`
Path: `/api/v1/services/overview`
Authentication: Bearer (§4).
Company Context: Required (§5).
Required Permission: None specific; each section is gated by its own view
permission/scope and omitted when absent.
Supported Scope: ASSIGNED / TEAM / ALL per section.
Required Employee Context: Only for the My Work section (linked Employee).
Headers: Standard (§8).
Path Parameters: None / Not applicable.
Query Parameters: `include` (optional, comma list to restrict sections).
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: all counts and `today` boundaries (company-local).
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: each metric uses the same scope resolver as
its domain; sections with no permission/scope are omitted.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable (read).
Concurrency: Not applicable.
Success Response:

```json
{
  "success": true,
  "data": {
    "customers": 42,
    "activeSites": 88,
    "teams": 6,
    "serviceTypes": 5,
    "priorities": 4,
    "enquiries": { "openCount": 7, "todayCount": 2, "highUrgentOpenCount": 3, "totalCount": 120, "recent": [] },
    "jobAssignments": { "activeCount": 9, "todayCount": 2, "upcomingCount": 5, "totalCount": 60, "upcoming": [] },
    "inspections": { "pendingCount": 4, "todayCount": 1, "completedCount": 22, "totalCount": 30, "recent": [] },
    "materialRequests": { "openCount": 3, "todayCount": 1, "lineCount": 14, "totalCount": 25, "recent": [] },
    "workExecutions": { "pendingCount": 2, "inProgressCount": 3, "completedTodayCount": 1, "totalCount": 18, "recent": [] },
    "myWork": null
  },
  "meta": { "requestId": "uuid", "serverTimeUtc": "2026-09-28T06:00:00Z" }
}
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `customers` | integer? | directory total (omitted without permission) |
| `activeSites` | integer? | active site total |
| `teams` | integer? | team total |
| `serviceTypes` | integer? | service type master total |
| `priorities` | integer? | priority master total |
| `enquiries.*` | object? | enquiry summary + recent list |
| `jobAssignments.*` | object? | assignment summary + upcoming list |
| `inspections.*` | object? | inspection summary + recent list |
| `materialRequests.*` | object? | material request summary + recent list |
| `workExecutions.*` | object? | work execution summary + recent list |
| `myWork` | object? | My Work projection (see 18.3) |

Errors: `401`, `403` (module disabled), `500`.
Notes: Recent lists default to 5. Upcoming assignments default to 5, ordered by
`scheduledVisitDate` ascending.

---

### My Work

Purpose: Return the caller’s own operational queue (ASSIGNED projection).
Method: `GET`
Path: `/api/v1/services/overview/my-work`
Authentication: Bearer.
Company Context: Required.
Required Permission: Any of the assignment/inspection/work-execution view
permissions (each item is independently gated).
Supported Scope: ASSIGNED (derived from the linked Employee).
Required Employee Context: Yes. The server derives the Employee from the
authenticated user; a client-supplied `employeeId` MUST NOT be honored to read
another person’s ASSIGNED data.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: `limit` (per section, default 5).
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: employee identity, scope.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: the linked Employee is the only subject;
sections without permission are omitted; returns empty when no linked Employee.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{
  "success": true,
  "data": {
    "assignments": [], "assignmentCount": 2,
    "inspections": [], "inspectionCount": 1,
    "executions": [], "executionCount": 1,
    "isEmpty": false
  },
  "meta": { "requestId": "uuid", "serverTimeUtc": "2026-09-28T06:00:00Z" }
}
```

Implemented selection: active assignments assigned to the employee; pending
inspections where the employee is the technician; work executions in progress
with the employee on a line.

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `assignments` | array | active assignments for the employee |
| `assignmentCount` | integer | filtered count |
| `inspections` | array | pending inspections for the technician |
| `inspectionCount` | integer | filtered count |
| `executions` | array | in-progress executions for the employee |
| `executionCount` | integer | filtered count |
| `isEmpty` | boolean | true when all three are empty |

Errors: `401`, `403`.
Notes: A user without a linked Employee gets `isEmpty: true` / omitted sections,
never company data.

---

## 19. Customers

Service Customers form a company-scoped directory. Customer codes are
company-scoped sequences (`CUS-…`). Status is `active` / `inactive`.

### Customer entity (read model)

| Field | Type | Notes |
| --- | --- | --- |
| `id` | uuid | internal id |
| `companyId` | uuid | server-derived |
| `customerCode` | string | backend sequence, immutable |
| `name` | string | required |
| `kind` | enum | `individual`, `organization` |
| `mobile` | string | required; duplicate-checked among active |
| `alternateMobile` | string? | optional |
| `email` | string? | optional; must contain `@`; duplicate-checked among active |
| `notes` | string? | optional |
| `status` | enum | `active`, `inactive` |
| `siteCount` | integer | derived count of active sites |
| `createdAt`,`updatedAt` | utc datetime | audit |
| `createdByUserId`,`updatedByUserId` | uuid | audit |
| `version`? | integer | see Notes |

Notes: The implemented Customer model has no explicit `version` column; if the
backend adds optimistic concurrency for customers it must document it. Duplicate
rules apply to **active** customers only.

---

### List Customers

Purpose: Paginated, searchable customer directory.
Method: `GET`
Path: `/api/v1/services/customers`
Authentication: Bearer (§4).
Company Context: Required (§5).
Required Permission: `services.customers.view`.
Supported Scope: Company (directory).
Required Employee Context: None / Not applicable.
Headers: Standard (§8).
Path Parameters: None / Not applicable.
Query Parameters: `q`, `status`, `sort`, `page`, `pageSize`.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `customerCode`, `siteCount`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: company-scoped directory.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable (read).
Concurrency: Not applicable.
Success Response:

```json
{
  "success": true,
  "data": [
    { "id": "11111111-1111-4111-8111-111111111111", "customerCode": "CUS-000001", "name": "Acme Facilities", "mobile": "+971500000000", "status": "active", "siteCount": 3, "updatedAt": "2026-09-20T10:00:00Z" }
  ],
  "meta": { "page": 1, "pageSize": 25, "totalItems": 42, "totalPages": 2, "filteredItems": 42, "requestId": "uuid", "serverTimeUtc": "2026-09-28T06:00:00Z" }
}
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | customer id |
| `customerCode` | string | sequence code |
| `name` | string | customer name |
| `mobile` | string | primary mobile |
| `status` | enum | active/inactive |
| `siteCount` | integer | active sites count |
| `updatedAt` | utc datetime | last change |

Search fields: `name`, `customerCode`, `mobile`.
Errors: `400` invalid sort, `401`, `403`.
Notes: Reference selection must not expose unrestricted data (§30).

---

### Create Customer

Purpose: Create a customer.
Method: `POST`
Path: `/api/v1/services/customers`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.customers.create`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: None / Not applicable.
Query Parameters: None / Not applicable.
Request Body:

```json
{ "name": "Acme Facilities", "kind": "organization", "mobile": "+971500000000", "alternateMobile": null, "email": "ops@acme.example", "notes": null }
```

Request Field Table:

| Field | Type | Required | Nullable | Source | Description | Validation | Example |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `name` | string | yes | no | client | Customer name | non-empty (trimmed) | `Acme Facilities` |
| `kind` | enum | yes | no | client | `individual`/`organization` | enum; default `individual` | `organization` |
| `mobile` | string | yes | no | client | Primary mobile | non-empty; not duplicate active | `+971500000000` |
| `alternateMobile` | string | no | yes | client | Alt mobile | optional | `null` |
| `email` | string | no | yes | client | Email | if present must contain `@`; not duplicate active | `ops@acme.example` |
| `notes` | string | no | yes | client | Notes | optional | `null` |

Server-Derived Fields: `id`, `companyId`, `customerCode`, `status=active`,
audit fields.
Business Validations: name required; mobile required; email format; duplicate
mobile/email among active customers.
Authorization / Object Scope Rules: company only.
Transactional Side Effects: sequence `CUS-…` + insert + activity (+ outbox).
Activity Event: `services.customer.created`.
Notification Side Effects: None / Not applicable.
Idempotency: same key returns the same customer; no duplicate code/activity.
Concurrency: Not applicable on create.
Success Response: `201` with created customer (full read model, §9.1).
Response Field Table: as Customer entity.
Errors: `400` (`SERVICES_CUSTOMER_REQUIRED`, `SERVICES_CUSTOMER_INVALID_MOBILE`,
`SERVICES_CUSTOMER_INVALID_EMAIL`, `SERVICES_CUSTOMER_DUPLICATE_MOBILE`,
`SERVICES_CUSTOMER_DUPLICATE_EMAIL`), `401`, `403`.
Notes: `createdBy`/`updatedBy` derived server-side.

---

### Get Customer

Purpose: Read one customer.
Method: `GET`
Path: `/api/v1/services/customers/{customerId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.customers.view`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: `customerId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `siteCount`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: company-scoped; cross-company → `404`.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: customer read model.
Response Field Table: as Customer entity.
Errors: `401`, `403`, `404`.
Notes: None / Not applicable.

---

### Update Customer

Purpose: Edit a customer.
Method: `PATCH`
Path: `/api/v1/services/customers/{customerId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.customers.edit`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `customerId` (uuid).
Query Parameters: None / Not applicable.
Request Body: same mutable fields as Create (partial).
Request Field Table: as Create (all optional in PATCH).
Server-Derived Fields: `customerCode` (immutable), `updatedByUserId`,
`updatedAt`.
Business Validations: same field rules; duplicate check excludes self.
Authorization / Object Scope Rules: company only.
Transactional Side Effects: update + activity (+ outbox).
Activity Event: `services.customer.updated`.
Notification Side Effects: None / Not applicable.
Idempotency: repeat update is a no-op / returns current record.
Concurrency: If the backend adds `version`, apply `409` semantics (§15);
otherwise document last-write-wins.
Success Response: updated customer read model.
Response Field Table: as Customer entity.
Errors: `400`, `401`, `403`, `404`, `409` (if versioned).
Notes: `customerCode` is never editable.

---

### Activate / Deactivate Customer

Purpose: Change directory status.
Method: `POST`
Path: `/api/v1/services/customers/{customerId}/activate` (activate) and
`/api/v1/services/customers/{customerId}/deactivate` (deactivate)
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.customers.deactivate` (both directions; there is
one status-toggle authority).
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` recommended.
Path Parameters: `customerId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `status`, `updatedAt`, `updatedByUserId`.
Business Validations: customer exists; no-op when already in target status.
Authorization / Object Scope Rules: company only.
Transactional Side Effects: status update + activity.
Activity Event: `services.customer.activated` / `services.customer.deactivated`.
Notification Side Effects: None / Not applicable.
Idempotency: repeat is a no-op.
Concurrency: status change is atomic.
Success Response: updated customer.
Response Field Table: as Customer entity.
Errors: `401`, `403`, `404`.
Notes: Inactive customers are not selectable for new enquiries but remain
resolvable historically.

---

### Customer Reference Lookup

Purpose: Lightweight customer selector data.
Method: `GET`
Path: `/api/v1/services/references/customers`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.customers.view` **or** Enquiry Create/Edit
(restricted contextual reference).
Supported Scope: Company active customers.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: `q`, `limit` (default 30–50, max 100), `for` (optional
context tag, e.g. `enquiry`).
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: None / Not applicable.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: active, same-company only; return only
reference fields.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{ "success": true, "data": [ { "id": "…", "customerCode": "CUS-000001", "displayName": "Acme Facilities", "mobile": "+971500000000" } ], "meta": { "requestId": "uuid", "serverTimeUtc": "…" } }
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | customer id |
| `customerCode` | string | code |
| `displayName` | string | name |
| `mobile` | string? | mobile |

Errors: `401`, `403`.
Notes: A Service user may select a customer for an Enquiry without gaining full
Customer-directory management access (§30).

---

## 20. Sites

Service Sites belong to a Customer within the same company. Site codes are
company-scoped sequences (`SITE-…`).

### Site entity (read model)

| Field | Type | Notes |
| --- | --- | --- |
| `id` | uuid | internal id |
| `companyId` | uuid | server-derived |
| `customerId` | uuid | required; same company |
| `siteCode` | string | backend sequence, immutable |
| `siteName` | string | required |
| `tenantName`,`buildingName`,`unitNumber` | string? | optional site context |
| `contactName`,`contactMobile`,`contactEmail` | string? | optional site contact |
| `addressLine1` | string | required |
| `addressLine2`,`area` | string? | optional |
| `city` | string | required |
| `state`,`postalCode`,`countryCode` | string? | optional |
| `latitude`,`longitude` | number? | optional coordinates |
| `notes` | string? | optional |
| `status` | enum | `active`, `inactive` |
| audit fields | | `createdAt`,`updatedAt`,`createdByUserId`,`updatedByUserId` |

---

### List Sites

Purpose: Paginated, searchable site directory, optionally customer-scoped.
Method: `GET`
Path: `/api/v1/services/sites`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.sites.view`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: `q`, `status`, `customerId`, `sort`, `page`, `pageSize`.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `customerName`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: company-scoped.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{
  "success": true,
  "data": [ { "id": "…", "siteCode": "SITE-000001", "siteName": "Tower A", "customerId": "…", "customerName": "Acme Facilities", "city": "Dubai", "buildingName": "Tower A", "unitNumber": "1204", "contactName": "Sara", "status": "active", "updatedAt": "…" } ],
  "meta": { "page": 1, "pageSize": 25, "totalItems": 88, "totalPages": 4, "filteredItems": 88, "requestId": "uuid", "serverTimeUtc": "…" }
}
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | site id |
| `siteCode` | string | code |
| `siteName` | string | name |
| `customerId` | uuid | owner customer |
| `customerName` | string | resolved customer name |
| `buildingName`,`unitNumber` | string? | context |
| `contactName` | string? | contact |
| `city` | string | city |
| `status` | enum | active/inactive |
| `updatedAt` | utc datetime | last change |

Search fields: `siteName`, `siteCode`, `customerName`.
Errors: `400`, `401`, `403`.
Notes: `watchSitesForCustomer` is served by `customerId` filter.

---

### Create Site

Purpose: Create a site for a customer.
Method: `POST`
Path: `/api/v1/services/sites`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.sites.create`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: None / Not applicable.
Query Parameters: None / Not applicable.
Request Body:

```json
{
  "customerId": "11111111-1111-4111-8111-111111111111",
  "siteName": "Tower A",
  "tenantName": "Acme Holdings",
  "buildingName": "Tower A",
  "unitNumber": "1204",
  "contactName": "Sara",
  "contactMobile": "+971500000001",
  "contactEmail": "sara@acme.example",
  "addressLine1": "Sheikh Zayed Road",
  "addressLine2": null,
  "area": "Business Bay",
  "city": "Dubai",
  "state": null,
  "postalCode": null,
  "countryCode": "AE",
  "latitude": 25.185,
  "longitude": 55.276,
  "notes": null
}
```

Request Field Table:

| Field | Type | Required | Nullable | Source | Description | Validation | Example |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `customerId` | uuid | yes | no | client | Owner customer | exists & same company | `…` |
| `siteName` | string | yes | no | client | Site name | non-empty | `Tower A` |
| `tenantName` | string | no | yes | client | Tenant | optional | `Acme Holdings` |
| `buildingName` | string | no | yes | client | Building | optional | `Tower A` |
| `unitNumber` | string | no | yes | client | Unit | optional | `1204` |
| `contactName` | string | no | yes | client | Contact | optional | `Sara` |
| `contactMobile` | string | no | yes | client | Contact mobile | optional | `+971500000001` |
| `contactEmail` | string | no | yes | client | Contact email | optional | `sara@acme.example` |
| `addressLine1` | string | yes | no | client | Address | non-empty | `Sheikh Zayed Road` |
| `addressLine2` | string | no | yes | client | Address | optional | `null` |
| `area` | string | no | yes | client | Area | optional | `Business Bay` |
| `city` | string | yes | no | client | City | non-empty | `Dubai` |
| `state` | string | no | yes | client | State | optional | `null` |
| `postalCode` | string | no | yes | client | Postal code | optional | `null` |
| `countryCode` | string | no | yes | client | ISO country | optional | `AE` |
| `latitude` | number | no | yes | client | Latitude | optional numeric | `25.185` |
| `longitude` | number | no | yes | client | Longitude | optional numeric | `55.276` |
| `notes` | string | no | yes | client | Notes | optional | `null` |

Server-Derived Fields: `id`, `companyId`, `siteCode`, `status=active`, audit.
Business Validations: customer required and exists in company; siteName,
addressLine1, city required; latitude/longitude numeric when present.
Authorization / Object Scope Rules: company only.
Transactional Side Effects: sequence `SITE-…` + insert + activity (+ outbox).
Activity Event: `services.site.created`.
Notification Side Effects: None / Not applicable.
Idempotency: same key returns same site.
Concurrency: Not applicable on create.
Success Response: `201` created site read model.
Response Field Table: as Site entity.
Errors: `400` (`SERVICES_SITE_CUSTOMER_REQUIRED`, `SERVICES_SITE_REQUIRED`),
`401`, `403`.
Notes: None / Not applicable.

---

### Get Site

Purpose: Read one site.
Method: `GET`
Path: `/api/v1/services/sites/{siteId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.sites.view`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: `siteId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `customerName`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: company-scoped; cross-company → `404`.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: site read model.
Response Field Table: as Site entity.
Errors: `401`, `403`, `404`.
Notes: None / Not applicable.

---

### Update Site

Purpose: Edit a site.
Method: `PATCH`
Path: `/api/v1/services/sites/{siteId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.sites.edit`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `siteId` (uuid).
Query Parameters: None / Not applicable.
Request Body: same mutable fields as Create (partial).
Request Field Table: as Create (all optional in PATCH).
Server-Derived Fields: `siteCode` (immutable), audit.
Business Validations: same field rules; customer must exist in company.
Authorization / Object Scope Rules: company only.
Transactional Side Effects: update + activity (+ outbox).
Activity Event: `services.site.updated`.
Notification Side Effects: None / Not applicable.
Idempotency: repeat is a no-op.
Concurrency: document `409` if versioned; else last-write-wins.
Success Response: updated site.
Response Field Table: as Site entity.
Errors: `400`, `401`, `403`, `404`.
Notes: None / Not applicable.

---

### Activate / Deactivate Site

Purpose: Change site status.
Method: `POST`
Path: `/api/v1/services/sites/{siteId}/activate` (activate) and
`/api/v1/services/sites/{siteId}/deactivate` (deactivate)
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.sites.deactivate`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` recommended.
Path Parameters: `siteId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `status`, audit.
Business Validations: site exists; no-op when already in target status.
Authorization / Object Scope Rules: company only.
Transactional Side Effects: status update + activity.
Activity Event: `services.site.activated` / `services.site.deactivated`.
Notification Side Effects: None / Not applicable.
Idempotency: repeat is a no-op.
Concurrency: atomic.
Success Response: updated site.
Response Field Table: as Site entity.
Errors: `401`, `403`, `404`.
Notes: None / Not applicable.

---

### Site Reference Lookup

Purpose: Lightweight site selector data, optionally customer-scoped.
Method: `GET`
Path: `/api/v1/services/references/sites`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.sites.view` **or** Enquiry Create/Edit.
Supported Scope: Company active sites.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: `q`, `customerId`, `limit`, `for`.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `customerName`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: active, company only; reference fields only.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{ "success": true, "data": [ { "id": "…", "siteCode": "SITE-000001", "displayName": "Tower A", "customerId": "…", "customerName": "Acme Facilities", "locationSummary": "Dubai" } ], "meta": { "requestId": "uuid", "serverTimeUtc": "…" } }
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | site id |
| `siteCode` | string | code |
| `displayName` | string | site name |
| `customerId` | uuid | owner |
| `customerName` | string | customer name |
| `locationSummary` | string? | city summary |

Errors: `401`, `403`.
Notes: Enquiry site references are additionally constrained to the selected
customer (§23).

---

## 21. Teams

Service Teams are company-scoped groups of Employees, separate from Department.
Codes are company-scoped sequences (`TEAM-…`). A team has at most one lead
(`leadEmployeeId`); the lead is also a member. Membership is many-to-many and
never grants permission.

### Team entity (read model)

| Field | Type | Notes |
| --- | --- | --- |
| `id` | uuid | internal id |
| `companyId` | uuid | server-derived |
| `teamCode` | string | backend sequence, immutable |
| `name` | string | required |
| `description` | string? | optional |
| `leadEmployeeId` | uuid? | optional; must be a member |
| `leadName` | string? | resolved |
| `memberCount` | integer | active members |
| `status` | enum | `active`, `inactive` |
| audit fields | | |

### Team member (read model)

| Field | Type | Notes |
| --- | --- | --- |
| `employeeId` | uuid | Employee reference |
| `name`,`employeeCode` | string | resolved |
| `designationId`,`departmentId` | uuid? | display context only |
| `isActive` | boolean | resolved |

---

### List Teams

Purpose: Paginated, searchable team directory.
Method: `GET`
Path: `/api/v1/services/teams`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.teams.view`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: `q`, `status`, `sort`, `page`, `pageSize`.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `memberCount`, `leadName`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: company-scoped.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{ "success": true, "data": [ { "id": "…", "teamCode": "TEAM-000001", "name": "HVAC Team", "leadName": "Ahmed Khan", "memberCount": 4, "status": "active", "updatedAt": "…" } ], "meta": { "page": 1, "pageSize": 25, "totalItems": 6, "totalPages": 1, "filteredItems": 6, "requestId": "uuid", "serverTimeUtc": "…" } }
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | team id |
| `teamCode` | string | code |
| `name` | string | name |
| `leadName` | string? | resolved lead |
| `memberCount` | integer | active members |
| `status` | enum | active/inactive |
| `updatedAt` | utc datetime | last change |

Search fields: `name`, `teamCode`.
Errors: `400`, `401`, `403`.
Notes: None / Not applicable.

---

### Create Team

Purpose: Create a team with optional members.
Method: `POST`
Path: `/api/v1/services/teams`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.teams.manage`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: None / Not applicable.
Query Parameters: None / Not applicable.
Request Body:

```json
{ "name": "HVAC Team", "description": "Air conditioning", "leadEmployeeId": "…", "memberIds": ["…", "…"] }
```

Request Field Table:

| Field | Type | Required | Nullable | Source | Description | Validation | Example |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `name` | string | yes | no | client | Team name | non-empty | `HVAC Team` |
| `description` | string | no | yes | client | Description | optional | `Air conditioning` |
| `leadEmployeeId` | uuid | no | yes | client | Team lead | employee valid, same company, active; added to members | `…` |
| `memberIds` | uuid[] | no | yes | client | Members | each valid, same company; de-duplicated | `["…"]` |

Server-Derived Fields: `id`, `companyId`, `teamCode`, `status=active`, audit.
Business Validations: name required; every member and the lead must resolve to
an Employee in the same company; lead included in membership.
Authorization / Object Scope Rules: company only.
Transactional Side Effects: sequence `TEAM-…` + team + member rows (insert-if-
absent) + activity (+ outbox).
Activity Event: `services.team.created`.
Notification Side Effects: None / Not applicable.
Idempotency: same key returns same team; no duplicate membership/activity.
Concurrency: Not applicable on create.
Success Response: `201` created team.
Response Field Table: as Team entity.
Errors: `400` (`SERVICES_TEAM_REQUIRED`), `401`, `403`.
Notes: Membership never grants permission.

---

### Get Team

Purpose: Read one team.
Method: `GET`
Path: `/api/v1/services/teams/{teamId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.teams.view`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: `teamId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `memberCount`, `leadName`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: company-scoped.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: team read model.
Response Field Table: as Team entity.
Errors: `401`, `403`, `404`.
Notes: None / Not applicable.

---

### Update Team

Purpose: Edit a team and reconcile its membership.
Method: `PATCH`
Path: `/api/v1/services/teams/{teamId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.teams.manage`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `teamId` (uuid).
Query Parameters: None / Not applicable.
Request Body: same fields as Create (partial). Supplying `memberIds` replaces
the active membership set; the lead is always included.
Request Field Table: as Create.
Server-Derived Fields: `teamCode` (immutable), audit.
Business Validations: name required when supplied; members/lead valid same
company; de-duplicate.
Authorization / Object Scope Rules: company only.
Transactional Side Effects: update team + reconcile membership + activity (+
outbox).
Activity Event: `services.team.members.updated` (or `services.team.updated` for
header-only changes; document the chosen mapping).
Notification Side Effects: None / Not applicable.
Idempotency: repeat returns current team.
Concurrency: membership reconciliation is atomic.
Success Response: updated team.
Response Field Table: as Team entity.
Errors: `400`, `401`, `403`, `404`.
Notes: A member removed from a team loses TEAM-scope visibility on next read,
without affecting other users’ grants.

---

### Activate / Deactivate Team

Purpose: Change team status.
Method: `POST`
Path: `/api/v1/services/teams/{teamId}/activate` (activate) and
`/api/v1/services/teams/{teamId}/deactivate` (deactivate)
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.teams.manage`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` recommended.
Path Parameters: `teamId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `status`, audit.
Business Validations: team exists; no-op when already in target.
Authorization / Object Scope Rules: company only.
Transactional Side Effects: status update + activity.
Activity Event: `services.team.activated` / `services.team.deactivated`.
Notification Side Effects: None / Not applicable.
Idempotency: repeat is a no-op.
Concurrency: atomic.
Success Response: updated team.
Response Field Table: as Team entity.
Errors: `401`, `403`, `404`.
Notes: Inactive teams are not selectable for new assignments.

---

### List Team Members

Purpose: Resolve active members of a team for display.
Method: `GET`
Path: `/api/v1/services/teams/{teamId}/members`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.teams.view`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: `teamId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: resolved employee name/code/active.
Business Validations: team exists.
Authorization / Object Scope Rules: company-scoped.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{ "success": true, "data": [ { "employeeId": "…", "name": "Ahmed Khan", "employeeCode": "EMP-000123", "designationId": "…", "departmentId": "…", "isActive": true } ], "meta": { "requestId": "uuid", "serverTimeUtc": "…" } }
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `employeeId` | uuid | employee id |
| `name` | string | name |
| `employeeCode` | string | code |
| `designationId` | uuid? | display only |
| `departmentId` | uuid? | display only |
| `isActive` | boolean | active flag |

Errors: `401`, `403`, `404`.
Notes: Only active memberships are returned for selection; historical inactive
membership remains resolvable for past transactions.

---

### Team Reference Lookup

Purpose: Lightweight team selector data.
Method: `GET`
Path: `/api/v1/services/references/teams`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.teams.view` **or** Job Assignment/Inspection/
Work Execution Create-Edit.
Supported Scope: Company active teams.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: `q`, `limit`, `ids` (repeatable, for batch resolution).
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: None / Not applicable.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: active for selection; `ids` may resolve
historical for display.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{ "success": true, "data": [ { "id": "…", "teamCode": "TEAM-000001", "displayName": "HVAC Team" } ], "meta": { "requestId": "uuid", "serverTimeUtc": "…" } }
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | team id |
| `teamCode` | string | code |
| `displayName` | string | name |

Errors: `401`, `403`.
Notes: None / Not applicable.

---

## 22. Services Configuration Masters

Seven implemented masters share one shape and one endpoint pattern. The path
`{masterType}` selects the master.

### 22.1 Master kinds (implemented)

| `masterType` | Display | Table concept | view permission | manage permission |
| --- | --- | --- | --- | --- |
| `service-types` | Service Type | `service_types` | `services.serviceTypes.view` | `services.serviceTypes.manage` |
| `complaint-types` | Complaint Type | `complaint_types` (optional `serviceTypeId`) | `services.complaintTypes.view` | `services.complaintTypes.manage` |
| `priorities` | Priority | `service_priorities` (`rank`, `isDefault`) | `services.priorities.view` | `services.priorities.manage` |
| `ticket-types` | Ticket Type | `service_ticket_types` | `services.ticketTypes.view` | `services.ticketTypes.manage` |
| `root-causes` | Root Cause | `service_root_causes` | `services.rootCauses.view` | `services.rootCauses.manage` |
| `charge-responsibilities` | Charge Responsibility | `service_charge_responsibilities` | `services.chargeResponsibilities.view` | `services.chargeResponsibilities.manage` |
| `material-request-purposes` | Material Request Purpose | `service_material_request_purposes` | `services.materialRequestPurposes.view` | `services.materialRequestPurposes.manage` |

All masters share: `id`, `companyId`, `code` (unique per company, uppercased),
`name`, `description`, `status` (`active`/`inactive`), `sortOrder`, audit.
Complaint Type adds `serviceTypeId`; Priority adds `rank` and `isDefault`.

Manage implies view for every master.

### 22.2 Referential integrity

- Inactive masters are **not** selectable for new transactions but remain
  resolvable historically (existing transactions still display the old value).
- A master `code` and `name` must be unique per company (case-insensitive).
- Deletion is never hard delete; use deactivate.

---

### List Configuration Masters

Purpose: Paginated list of one master.
Method: `GET`
Path: `/api/v1/services/configuration/{masterType}`
Authentication: Bearer.
Company Context: Required.
Required Permission: the master’s `*.view`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: `masterType` (§22.1).
Query Parameters: `q`, `status`, `sort`, `page`, `pageSize`.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: None / Not applicable.
Business Validations: `masterType` must be one of the seven.
Authorization / Object Scope Rules: company-scoped.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{ "success": true, "data": [ { "id": "…", "code": "ELEC", "name": "Electrical", "description": null, "status": "active", "sortOrder": 0, "rank": 0, "isDefault": false, "serviceTypeId": null } ], "meta": { "page": 1, "pageSize": 25, "totalItems": 5, "totalPages": 1, "filteredItems": 5, "requestId": "uuid", "serverTimeUtc": "…" } }
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | master id |
| `code` | string | code (upper) |
| `name` | string | name |
| `description` | string? | description |
| `status` | enum | active/inactive |
| `sortOrder` | integer | display order |
| `rank` | integer | Priority only |
| `isDefault` | boolean | Priority only |
| `serviceTypeId` | uuid? | Complaint Type only |

Search fields: `name`, `code`.
Errors: `400` invalid masterType, `401`, `403`.
Notes: Default sort `sortOrder`, then `name`.

---

### Master Reference Lookup

Purpose: Active values for selectors.
Method: `GET`
Path: `/api/v1/services/references/configuration/{masterType}`
Authentication: Bearer.
Company Context: Required.
Required Permission: master `*.view` **or** the consuming transaction’s
Create/Edit permission.
Supported Scope: Company active.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: `masterType`.
Query Parameters: `q`, `limit`.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: None / Not applicable.
Business Validations: masterType valid.
Authorization / Object Scope Rules: active only for selection.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: list of `{ id, code, name }`.
Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | master id |
| `code` | string | code |
| `name` | string | name |

Errors: `400`, `401`, `403`.
Notes: Complaint Type reference may accept `serviceTypeId` to filter by Service
Type (implemented linkage).

---

### Create Configuration Master

Purpose: Create a master value.
Method: `POST`
Path: `/api/v1/services/configuration/{masterType}`
Authentication: Bearer.
Company Context: Required.
Required Permission: master `*.manage`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `masterType`.
Query Parameters: None / Not applicable.
Request Body:

```json
{ "code": "ELEC", "name": "Electrical", "description": null, "sortOrder": 0, "serviceTypeId": null, "rank": 0, "isDefault": false }
```

Request Field Table:

| Field | Type | Required | Nullable | Source | Description | Validation | Example |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `code` | string | yes | no | client | Code | non-empty; unique company; uppercased | `ELEC` |
| `name` | string | yes | no | client | Name | non-empty; unique company | `Electrical` |
| `description` | string | no | yes | client | Description | optional | `null` |
| `sortOrder` | integer | no | yes | client | Order | optional | `0` |
| `serviceTypeId` | uuid | no | yes | client | Complaint Type link | valid active service type; only `complaint-types` | `null` |
| `rank` | integer | no | yes | client | Priority rank | only `priorities` | `0` |
| `isDefault` | boolean | no | yes | client | Default priority | only `priorities` | `false` |

Server-Derived Fields: `id`, `companyId`, `status=active`, audit.
Business Validations: code unique; name unique; master-specific fields only
allowed for their master.
Authorization / Object Scope Rules: company only.
Transactional Side Effects: insert + activity + outbox.
Activity Event: `services.configuration.created`.
Notification Side Effects: None / Not applicable.
Idempotency: same key returns same master.
Concurrency: Not applicable on create.
Success Response: `201` created master.
Response Field Table: as list item.
Errors: `400` (`SERVICES_MASTER_CODE_REQUIRED`,
`SERVICES_MASTER_NAME_REQUIRED`, `SERVICES_MASTER_DUPLICATE_CODE`), `401`,
`403`.
Notes: None / Not applicable.

---

### Get Configuration Master

Purpose: Read one master value.
Method: `GET`
Path: `/api/v1/services/configuration/{masterType}/{id}`
Authentication: Bearer.
Company Context: Required.
Required Permission: master `*.view`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: `masterType`, `id`.
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: None / Not applicable.
Business Validations: masterType valid.
Authorization / Object Scope Rules: company-scoped.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: master item.
Response Field Table: as list item.
Errors: `400`, `401`, `403`, `404`.
Notes: None / Not applicable.

---

### Update Configuration Master

Purpose: Edit a master value.
Method: `PATCH`
Path: `/api/v1/services/configuration/{masterType}/{id}`
Authentication: Bearer.
Company Context: Required.
Required Permission: master `*.manage`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `masterType`, `id`.
Query Parameters: None / Not applicable.
Request Body: same fields as Create (partial).
Request Field Table: as Create.
Server-Derived Fields: audit.
Business Validations: code/name unique excluding self; master-specific fields.
Authorization / Object Scope Rules: company only.
Transactional Side Effects: update + activity + outbox.
Activity Event: `services.configuration.updated`.
Notification Side Effects: None / Not applicable.
Idempotency: repeat is a no-op.
Concurrency: last-write-wins unless versioned.
Success Response: updated master.
Response Field Table: as list item.
Errors: `400`, `401`, `403`, `404`.
Notes: Historical transactions continue to resolve the master after edit.

---

### Activate / Deactivate Configuration Master

Purpose: Change master status.
Method: `POST`
Path: `/api/v1/services/configuration/{masterType}/{id}/activate` (activate)
and `/api/v1/services/configuration/{masterType}/{id}/deactivate` (deactivate)
Authentication: Bearer.
Company Context: Required.
Required Permission: master `*.manage`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` recommended.
Path Parameters: `masterType`, `id`.
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `status`, audit.
Business Validations: master exists; no-op when already in target.
Authorization / Object Scope Rules: company only.
Transactional Side Effects: status update + activity.
Activity Event: `services.configuration.activated` /
`services.configuration.deactivated`.
Notification Side Effects: None / Not applicable.
Idempotency: repeat is a no-op.
Concurrency: atomic.
Success Response: updated master.
Response Field Table: as list item.
Errors: `400`, `401`, `403`, `404`.
Notes: Inactive values are excluded from new-transaction references but remain
resolvable for history.

## 23. Enquiries

A Service Enquiry is the root transaction. It owns Customer/Site selection and
snapshot, classification, **Material Received**, detail issue lines and photos,
and its own lifecycle. The Customer/Site/classification relationship is stored
by id; a transaction-time snapshot preserves historical display context.

### 23.1 Lifecycle

`OPEN → ASSIGNED → (CANCELLED)`. Cancelling the **last** active Job Assignment
returns the Enquiry to `OPEN`. Cancelled is terminal. The Enquiry is editable and
cancellable only while `OPEN`.

| Status | Meaning | Allowed transitions |
| --- | --- | --- |
| `open` | created, not assigned | create Job Assignment (→ assigned); cancel (→ cancelled) |
| `assigned` | an active Job Assignment exists | cancel (→ cancelled) |
| `cancelled` | terminal historical | none |

### 23.2 Enquiry entity (read model)

| Field | Type | Notes |
| --- | --- | --- |
| `id`,`companyId` | uuid | internal/company |
| `enquiryNumber` | string | `ENQ-…`, immutable |
| `customerId`,`siteId` | uuid | authoritative relationships |
| `serviceTypeId`,`complaintTypeId`,`priorityId`,`ticketTypeId` | uuid | classification |
| `materialReceived` | enum | `no`/`yes`; **owned here only** (§23.5) |
| `status` | enum | open/assigned/cancelled |
| `partySnapshot` | object | transaction-time customer/site context |
| `details` | array | detail issue lines (+ attachments) |
| `cancelReason` | string? | cancel reason |
| `cancelledAt` | utc datetime? | cancel timestamp |
| `version` | integer | optimistic concurrency |
| `requestId` | uuid? | client request id |
| audit | | `createdAt`,`updatedAt`,`createdByUserId`,`updatedByUserId` |
| resolved labels | | `serviceTypeName`,`complaintTypeName`,`priorityName`,`priorityRank`,`ticketTypeName` |

`partySnapshot` fields: `customerName`, `customerCode`, `customerMobile`,
`siteName`, `tenantName`, `buildingName`, `unitNumber`, `addressSummary`,
`siteContactName`, `siteContactMobile`.

### 23.3 Detail line (child of the aggregate)

| Field | Type | Notes |
| --- | --- | --- |
| `id` | uuid | stable identity (client-generated allowed) |
| `lineNumber` | integer | display order only (reassigned on save) |
| `description` | string | required, max 4000 chars |
| `status` | enum | `open`/`closed` — vocabulary **TBD**; must not drive workflow |
| `attachments` | array | shared attachment metadata (`serviceEnquiryDetail`/`problemPhoto`) |

Detail lines are persisted **only** through the Enquiry aggregate create/update
(the child set is reconciled by stable id). There are no independent detail-line
endpoints. Removed lines are soft-removed (`removedAt`) and never hard-deleted.

### 23.4 Classification snapshot rule

The server derives and persists the snapshot from the selected Customer and Site
at save time. Later master/site/customer edits do not rewrite history.

### 23.5 Material Received — authoritative ownership

`materialReceived` is owned by the **Enquiry only**. No downstream table exposes
an independent mutable Material Received field. Job Assignment, Inspection,
Material Request and Work Execution may return it as **inherited read-only**
context. Enquiry create/update is the only way to change it. Exact business
meaning remains **TBD** (modelled as a Yes/No flag; no quantity/inventory).

---

### List Enquiries

Purpose: Paginated, searchable enquiry list.
Method: `GET`
Path: `/api/v1/services/enquiries`
Authentication: Bearer (§4).
Company Context: Required (§5).
Required Permission: `services.enquiries.view`.
Supported Scope: `ALL` only (company).
Required Employee Context: None / Not applicable.
Headers: Standard (§8).
Path Parameters: None / Not applicable.
Query Parameters: `q`, `status`, `serviceTypeId`, `complaintTypeId`,
`priorityId`, `ticketTypeId`, `dateFrom`, `dateTo` (creation date),
`customerId`, `siteId`, `sort`, `page`, `pageSize`, `recent` (boolean; recent
mode), `limit` (recent limit).
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: resolved classification labels, `customerName`,
`siteName`, `priorityRank`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: company only (no ASSIGNED/TEAM for
enquiries).
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable (read).
Concurrency: Not applicable.
Success Response:

```json
{
  "success": true,
  "data": [
    { "id": "…", "enquiryNumber": "ENQ-000120", "createdAt": "2026-09-27T08:00:00Z", "customerName": "Acme Facilities", "customerMobile": "+971500000000", "siteName": "Tower A", "serviceTypeName": "HVAC", "complaintTypeName": "No cooling", "priorityName": "High", "priorityRank": 2, "ticketTypeName": "Reactive", "status": "open" }
  ],
  "meta": { "page": 1, "pageSize": 25, "totalItems": 120, "totalPages": 5, "filteredItems": 7, "requestId": "uuid", "serverTimeUtc": "2026-09-28T06:00:00Z" }
}
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | enquiry id |
| `enquiryNumber` | string | number |
| `createdAt` | utc datetime | created |
| `customerName`,`customerMobile` | string? | snapshot |
| `siteName` | string | snapshot site |
| `serviceTypeName`,`complaintTypeName`,`priorityName`,`ticketTypeName` | string | resolved labels |
| `priorityRank` | integer | priority rank |
| `status` | enum | enquiry status |

Search fields: `enquiryNumber`, customer name/mobile, site name/building/unit.
Default sort `createdAt desc`.
Errors: `400`, `401`, `403`.
Notes: `recent=true` returns the latest N (default 5) for the overview.

---

### Create Enquiry

Purpose: Create an enquiry with detail lines and photos.
Method: `POST`
Path: `/api/v1/services/enquiries`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.enquiries.create`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: None / Not applicable.
Query Parameters: None / Not applicable.
Request Body:

```json
{
  "customerId": "11111111-1111-4111-8111-111111111111",
  "siteId": "22222222-2222-4222-8222-222222222222",
  "serviceTypeId": "…", "complaintTypeId": "…", "priorityId": "…", "ticketTypeId": "…",
  "materialReceived": "no",
  "details": [
    { "id": "33333333-3333-4333-8333-333333333333", "description": "Unit 1204 not cooling", "status": "open",
      "attachments": [ { "id": "44444444-4444-4444-8444-444444444444", "fileName": "issue.jpg", "displayName": "issue.jpg", "mimeType": "image/jpeg", "sizeBytes": 524288, "category": "problemPhoto" } ] }
  ]
}
```

Request Field Table:

| Field | Type | Required | Nullable | Source | Description | Validation | Example |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `customerId` | uuid | yes | no | client | Customer | exists, active, same company | `…` |
| `siteId` | uuid | yes | no | client | Site | exists, active, same company, belongs to customer | `…` |
| `serviceTypeId` | uuid | yes | no | client | Service type | active master | `…` |
| `complaintTypeId` | uuid | yes | no | client | Complaint type | active master; service-type link must match if set | `…` |
| `priorityId` | uuid | yes | no | client | Priority | active master | `…` |
| `ticketTypeId` | uuid | yes | no | client | Ticket type | active master | `…` |
| `materialReceived` | enum | no | no | client | Material received | `no`/`yes`; default `no` | `no` |
| `details` | array | yes | no | client | Detail lines | at least 1 | `[…]` |
| `details[].id` | uuid | yes | no | client | Line identity | unique UUID | `…` |
| `details[].description` | string | yes | no | client | Issue text | non-empty, ≤4000 | `Unit 1204 not cooling` |
| `details[].status` | enum | no | no | client | Line status | `open`/`closed` (TBD) | `open` |
| `details[].attachments[]` | array | no | yes | client | Photo metadata | validated per §17 | `[…]` |

Server-Derived Fields: `id`, `companyId`, `enquiryNumber` (sequence), `status=open`,
`partySnapshot`, `version=1`, audit, `searchText`.
Business Validations: customer/site/service-type/complaint-type/priority/
ticket-type required; customer/site active & same company; site belongs to
customer; masters active; complaint-type/service-type linkage; at least one
detail; each description non-empty ≤4000.
Authorization / Object Scope Rules: company only.
Transactional Side Effects: sequence + header + detail lines + attachment
metadata + activity + outbox (atomic, §16.4).
Activity Event: `services.enquiry.created`.
Notification Side Effects: None / Not applicable.
Idempotency: same key returns the same enquiry; no duplicate lines/activity.
Concurrency: Not applicable on create.
Success Response: `201` created enquiry aggregate.
Response Field Table: as Enquiry entity.
Errors: `400` (`SERVICES_ENQUIRY_CUSTOMER_REQUIRED`,
`SERVICES_ENQUIRY_SITE_REQUIRED`, `SERVICES_ENQUIRY_SERVICE_TYPE_REQUIRED`,
`SERVICES_ENQUIRY_COMPLAINT_TYPE_REQUIRED`,
`SERVICES_ENQUIRY_PRIORITY_REQUIRED`, `SERVICES_ENQUIRY_TICKET_TYPE_REQUIRED`,
`SERVICES_ENQUIRY_DETAILS_REQUIRED`,
`SERVICES_ENQUIRY_DETAIL_DESCRIPTION_REQUIRED`,
`SERVICES_ENQUIRY_DESCRIPTION_TOO_LONG`,
`SERVICES_ENQUIRY_CUSTOMER_NOT_FOUND`, `SERVICES_ENQUIRY_CUSTOMER_INACTIVE`,
`SERVICES_ENQUIRY_SITE_NOT_FOUND`, `SERVICES_ENQUIRY_SITE_INACTIVE`,
`SERVICES_ENQUIRY_SITE_CUSTOMER_MISMATCH`,
`SERVICES_ENQUIRY_SERVICE_TYPE_INVALID`,
`SERVICES_ENQUIRY_COMPLAINT_TYPE_INVALID`,
`SERVICES_ENQUIRY_COMPLAINT_TYPE_MISMATCH`,
`SERVICES_ENQUIRY_PRIORITY_INVALID`, `SERVICES_ENQUIRY_TICKET_TYPE_INVALID`),
`401`, `403`.
Notes: The client may generate line/attachment UUIDs for later reconciliation.

---

### Get Enquiry

Purpose: Read the enquiry aggregate (header + lines + attachments + labels).
Method: `GET`
Path: `/api/v1/services/enquiries/{enquiryId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.enquiries.view`.
Supported Scope: ALL.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: `enquiryId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: resolved labels, snapshot, detail lines with attachments.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: company-scoped; cross-company → `404`.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: enquiry aggregate.
Response Field Table: as Enquiry entity.
Errors: `401`, `403`, `404`.
Notes: None / Not applicable.

---

### Update Enquiry

Purpose: Edit an OPEN enquiry and reconcile its detail lines/photos.
Method: `PATCH`
Path: `/api/v1/services/enquiries/{enquiryId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.enquiries.edit`.
Supported Scope: ALL.
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `enquiryId` (uuid).
Query Parameters: None / Not applicable.
Request Body: same as Create; `details` is the **complete desired set** (missing
ids are soft-removed; supplied existing ids are updated; new ids are inserted).
Request Field Table: as Create.
Server-Derived Fields: `partySnapshot` re-derived, `version` incremented, audit.
Business Validations: enquiry exists and is `OPEN` (else
`SERVICES_ENQUIRY_NOT_EDITABLE`); same field rules as create; at least one
detail line remains.
Authorization / Object Scope Rules: company only.
Transactional Side Effects: header + line reconciliation + attachment metadata
reconciliation + version + activity + outbox.
Activity Event: `services.enquiry.updated`.
Notification Side Effects: None / Not applicable.
Idempotency: same key is a no-op returning the current aggregate.
Concurrency: send `version`; stale → `409 RECORD_VERSION_CONFLICT`.
Success Response: updated aggregate.
Response Field Table: as Enquiry entity.
Errors: `400`, `401`, `403`, `404`, `409`
(`SERVICES_ENQUIRY_NOT_EDITABLE`, `RECORD_VERSION_CONFLICT`).
Notes: Header `enquiryNumber` is immutable.

---

### Cancel Enquiry

Purpose: Cancel an OPEN enquiry (historical, no delete).
Method: `POST`
Path: `/api/v1/services/enquiries/{enquiryId}/cancel`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.enquiries.cancel`.
Supported Scope: ALL.
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `enquiryId` (uuid).
Query Parameters: None / Not applicable.
Request Body: `{ "reason": "duplicate" }` (optional).
Request Field Table:

| Field | Type | Required | Nullable | Source | Description | Validation | Example |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `reason` | string | no | yes | client | Cancel reason | optional trimmed | `duplicate` |

Server-Derived Fields: `status=cancelled`, `cancelledAt`, `version` increment,
`updatedByUserId`.
Business Validations: enquiry exists; must be `OPEN` (else
`SERVICES_ENQUIRY_ALREADY_CANCELLED` / not cancellable).
Authorization / Object Scope Rules: company only.
Transactional Side Effects: status + timestamps + version + activity + outbox.
Activity Event: `services.enquiry.cancelled`.
Notification Side Effects: None / Not applicable.
Idempotency: same key is a no-op.
Concurrency: `version`; stale → `409`.
Success Response: cancelled enquiry aggregate.
Response Field Table: as Enquiry entity.
Errors: `400`, `401`, `403`, `404`, `409`.
Notes: Cancellation does not delete the record or its children.

---

### Enquiry Summary

Purpose: Return the Enquiry summary counts (used by the overview).
Method: `GET`
Path: `/api/v1/services/enquiries/summary`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.enquiries.view`.
Supported Scope: ALL.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `today` boundary (company-local), `priorityRank >= 2`
high/urgent definition.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: company only.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{ "success": true, "data": { "openCount": 7, "todayCount": 2, "highUrgentOpenCount": 3, "totalCount": 120 }, "meta": { "requestId": "uuid", "serverTimeUtc": "…" } }
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `openCount` | integer | open enquiries |
| `todayCount` | integer | open created today (company-local) |
| `highUrgentOpenCount` | integer | open with priority rank ≥ 2 |
| `totalCount` | integer | all in scope |

Errors: `401`, `403`.
Notes: Prefer serving this from the overview endpoint for a single round trip.

---

### Eligible Enquiry Reference (for Job Assignment)

Purpose: Restricted eligible-enquiry selector for creating a Job Assignment,
without requiring full Enquiry access.
Method: `GET`
Path: `/api/v1/services/references/eligible-enquiries`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.jobAssignments.create` or
`services.jobAssignments.edit`.
Supported Scope: Company eligible set.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: `q`, `limit`.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: eligibility (open, no active assignment).
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: authorized by Job Assignment Create/Edit,
**not** by Enquiry View.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{ "success": true, "data": [ { "id": "…", "enquiryNumber": "ENQ-000120", "customerName": "Acme Facilities", "customerMobile": "…", "siteSummary": "Tower A / 1204", "complaintTypeName": "No cooling", "priorityName": "High", "priorityRank": 2 } ], "meta": { "requestId": "uuid", "serverTimeUtc": "…" } }
```

Implemented eligibility: `status = open` **and** no active Job Assignment for the
enquiry.

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | enquiry id |
| `enquiryNumber` | string | number |
| `customerName` | string | snapshot customer |
| `customerMobile` | string? | snapshot mobile |
| `siteSummary` | string | building/unit or site name |
| `complaintTypeName` | string | label |
| `priorityName` | string | label |
| `priorityRank` | integer | rank |

Errors: `401`, `403`.
Notes: None / Not applicable.

---

### Get Job Assignment For Enquiry

Purpose: Integration read for the Enquiry detail (active assignment reference).
Method: `GET`
Path: `/api/v1/services/enquiries/{enquiryId}/job-assignment`
Authentication: Bearer.
Company Context: Required.
Required Permission: any Job Assignment view scope.
Supported Scope: assignment scope.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: `enquiryId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `assignedSummary`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: the assignment is resolved through the Job
Assignment scope; a restricted assignment is indistinguishable from absent.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: `{ "success": true, "data": { "id": "…", "assignmentNumber": "JA-000045", "sourceEnquiryId": "…", "customerName": "…", "siteSummary": "…", "scheduledVisitDate": "2026-09-30", "assignedSummary": "Ahmed Khan + HVAC Team", "priorityName": "High" } }` or `data: null`.
Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | assignment id |
| `assignmentNumber` | string | number |
| `sourceEnquiryId` | uuid | enquiry |
| `customerName` | string | snapshot |
| `siteSummary` | string | site summary |
| `scheduledVisitDate` | date | visit date |
| `assignedSummary` | string | compact assignee summary |
| `priorityName` | string | label |

Errors: `401`, `403`.
Notes: Returns the active assignment only.

---

### Get Work Executions For Enquiry

Purpose: Integration read for the Enquiry detail (work execution references).
Method: `GET`
Path: `/api/v1/services/enquiries/{enquiryId}/work-executions`
Authentication: Bearer.
Company Context: Required.
Required Permission: any Work Execution view scope.
Supported Scope: work execution scope.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: `enquiryId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `allLinesComplete`, aggregate start/end.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: resolved through the Work Execution scope.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{ "success": true, "data": [ { "id": "…", "executionNumber": "WE-000012", "status": "inProgress", "executionDate": "2026-09-28", "workLineCount": 2, "allLinesComplete": false, "startedAtUtc": "…", "endedAtUtc": null } ] }
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | execution id |
| `executionNumber` | string | number |
| `status` | enum | execution status |
| `executionDate` | date | business date |
| `workLineCount` | integer | lines |
| `allLinesComplete` | boolean | all lines started+finished |
| `startedAtUtc`,`endedAtUtc` | utc datetime? | aggregate range |

Errors: `401`, `403`.
Notes: None / Not applicable.

---

### Enquiry Activity

Purpose: Structured activity history for one enquiry.
Method: `GET`
Path: `/api/v1/services/enquiries/{enquiryId}/activity`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.enquiries.view`.
Supported Scope: ALL.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: `enquiryId` (uuid).
Query Parameters: `page`, `pageSize`.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: actor, `occurredAt`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: company-scoped; only events of the viewable
record.
Transactional Side Effects: None / Not applicable.
Activity Event: Returns activity (§16.2).
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: paginated activity entries.
Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | event id |
| `eventType` | string | namespaced key |
| `occurredAt` | utc datetime | when |
| `actorUserId` | uuid | actor |
| `actorEmployeeId` | uuid? | actor employee |
| `metadata` | object | typed context |

Errors: `401`, `403`, `404`.
Notes: The workflow-level merged feed is §28.

---

## 24. Job Assignments

A Job Assignment schedules and assigns work for an eligible Enquiry. It
references the source Enquiry and carries 1..N work lines. **V1 rule: at most one
ACTIVE assignment per Enquiry.**

### 24.1 Lifecycle

`ACTIVE → (CANCELLED)`. Cancellation is historical (no delete). Cancelling the
last active assignment returns the Enquiry `ASSIGNED → OPEN`.

### 24.2 Job Assignment entity (read model)

| Field | Type | Notes |
| --- | --- | --- |
| `id`,`companyId` | uuid | |
| `assignmentNumber` | string | `JA-…`, immutable |
| `assignmentDate` | date | company-local, server-derived |
| `sourceEnquiryId` | uuid | authoritative lineage |
| `scheduledVisitDate` | date | company-local |
| `status` | enum | active/cancelled |
| `lines` | array | work lines |
| `version` | integer | optimistic concurrency |
| `requestId` | uuid? | |
| audit | | |
| enquiry context | | `enquiryNumber`, customer snapshot, `priorityName`/`priorityRank`, `complaintTypeName`, `materialReceived` (inherited), `enquiryDetails[]` |

### 24.3 Work line (child)

| Field | Type | Notes |
| --- | --- | --- |
| `id` | uuid | stable identity |
| `lineNumber` | integer | display order |
| `work` | string | required, ≤500 |
| `assignedEmployeeId` | uuid? | Employee reference |
| `assignedTeamId` | uuid? | Service Team reference |
| `status` | enum | `pending` only — vocabulary **TBD**; non-workflow |
| `descriptionForWork` | string | ≤2000 |

At least one of `assignedEmployeeId` / `assignedTeamId` is required per line. If
both are given, the employee must be an active member of the team. Lines are
soft-removed and reconciled by id within the aggregate.

### 24.4 Server-derived context

Job Assignment never accepts client-supplied Customer/Site/Complaint/Priority/
Material Received. These are derived from the source Enquiry. Mismatched
client context is ignored/rejected.

---

### List Job Assignments

Purpose: Paginated, scope-aware assignment list (also serves upcoming).
Method: `GET`
Path: `/api/v1/services/job-assignments`
Authentication: Bearer.
Company Context: Required.
Required Permission: any of `services.jobAssignments.view` scopes.
Supported Scope: ASSIGNED / TEAM / ALL.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: `q`, `status`, `priorityId`, `teamId`, `employeeId`,
`visitFrom`, `visitTo`, `sort`, `page`, `pageSize`, `upcoming` (boolean),
`limit` (upcoming limit).
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `enquiryNumber`, customer snapshot, `assignedSummary`,
`priorityName`/`priorityRank`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: scope applied before filters; ASSIGNED =
directly on a line or member of an assigned team; TEAM = assigned-team
membership; ALL = company.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{
  "success": true,
  "data": [
    { "id": "…", "assignmentNumber": "JA-000045", "createdAt": "…", "scheduledVisitDate": "2026-09-30", "status": "active", "enquiryNumber": "ENQ-000120", "customerName": "Acme Facilities", "customerMobile": "…", "siteSummary": "Tower A / 1204", "priorityName": "High", "priorityRank": 2, "assignedSummary": "Ahmed Khan + HVAC Team" }
  ],
  "meta": { "page": 1, "pageSize": 25, "totalItems": 60, "totalPages": 3, "filteredItems": 9, "requestId": "uuid", "serverTimeUtc": "…" }
}
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | assignment id |
| `assignmentNumber` | string | number |
| `scheduledVisitDate` | date | visit date |
| `status` | enum | active/cancelled |
| `enquiryNumber` | string | source enquiry |
| `customerName`,`customerMobile` | string? | snapshot |
| `siteSummary` | string | site summary |
| `priorityName`,`priorityRank` | string/integer | priority |
| `assignedSummary` | string | compact assignee summary |

Default sort `scheduledVisitDate desc, createdAt desc`.
`upcoming=true`: `status=active` and `scheduledVisitDate >= today`, ordered
ascending, default limit 5.
Errors: `400`, `401`, `403`.
Notes: None / Not applicable.

---

### Create Job Assignment

Purpose: Create an assignment and transition the Enquiry to ASSIGNED.
Method: `POST`
Path: `/api/v1/services/job-assignments`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.jobAssignments.create`.
Supported Scope: Company (create).
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: None / Not applicable.
Query Parameters: None / Not applicable.
Request Body:

```json
{
  "sourceEnquiryId": "11111111-1111-4111-8111-111111111111",
  "scheduledVisitDate": "2026-09-30",
  "lines": [
    { "id": "55555555-5555-4555-8555-555555555555", "work": "Inspect cooling unit", "assignedEmployeeId": "…", "assignedTeamId": null, "status": "pending", "descriptionForWork": "Check refrigerant" }
  ]
}
```

Request Field Table:

| Field | Type | Required | Nullable | Source | Description | Validation | Example |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `sourceEnquiryId` | uuid | yes | no | client | Source enquiry | exists, same company | `…` |
| `scheduledVisitDate` | date | yes | no | client | Visit date | company-local date | `2026-09-30` |
| `lines` | array | yes | no | client | Work lines | ≥1 | `[…]` |
| `lines[].id` | uuid | yes | no | client | Line identity | unique | `…` |
| `lines[].work` | string | yes | no | client | Work | non-empty, ≤500 | `Inspect cooling unit` |
| `lines[].assignedEmployeeId` | uuid | no | yes | client | Employee | valid same-company; required if no team | `…` |
| `lines[].assignedTeamId` | uuid | no | yes | client | Service Team | active same-company; required if no employee | `null` |
| `lines[].status` | enum | no | no | client | Line status | `pending` only (TBD) | `pending` |
| `lines[].descriptionForWork` | string | no | no | client | Instructions | ≤2000 | `Check refrigerant` |

Server-Derived Fields: `id`, `companyId`, `assignmentNumber`, `assignmentDate`,
`status=active`, `version=1`, `searchText`, audit.
Business Validations: enquiry exists & same company; enquiry must be OPEN (or
already has no active assignment); no other active assignment; employee/team
valid; if employee+team, employee is an active team member; at least one line;
work length; description length.
Authorization / Object Scope Rules: company create authority.
Transactional Side Effects: sequence + header + lines + Enquiry
`OPEN → ASSIGNED` (+ Enquiry activity `services.enquiry.assigned`) + activity +
outbox + assignment notification (atomic, §16.4).
Activity Event: `services.jobAssignment.created`.
Notification Side Effects: `serviceWorkAssigned` to assigned Employees’ linked
user accounts and assigned Team members/lead (deduped), deep-link metadata to
the assignment.
Idempotency: same key returns same assignment; no duplicate lines, no repeated
Enquiry transition, no duplicate notifications.
Concurrency: Not applicable on create beyond the one-active rule.
Success Response: `201` created assignment.
Response Field Table: as Job Assignment entity.
Errors: `400` (`SERVICES_JOB_ASSIGNMENT_ENQUIRY_REQUIRED`,
`SERVICES_JOB_ASSIGNMENT_VISIT_DATE_REQUIRED`,
`SERVICES_JOB_ASSIGNMENT_LINES_REQUIRED`,
`SERVICES_JOB_ASSIGNMENT_WORK_REQUIRED`,
`SERVICES_JOB_ASSIGNMENT_WORK_TOO_LONG`,
`SERVICES_JOB_ASSIGNMENT_DESCRIPTION_TOO_LONG`,
`SERVICES_JOB_ASSIGNMENT_TARGET_REQUIRED`,
`SERVICES_JOB_ASSIGNMENT_ENQUIRY_NOT_FOUND`,
`SERVICES_JOB_ASSIGNMENT_ENQUIRY_NOT_OPEN`,
`SERVICES_JOB_ASSIGNMENT_ALREADY_ACTIVE`,
`SERVICES_JOB_ASSIGNMENT_EMPLOYEE_INVALID`,
`SERVICES_JOB_ASSIGNMENT_TEAM_INVALID`,
`SERVICES_JOB_ASSIGNMENT_EMPLOYEE_NOT_IN_TEAM`), `401`, `403`.
Notes: Customer/Site/classification/Material Received must NOT be sent; they are
derived from the enquiry.

---

### Get Job Assignment

Purpose: Read the assignment aggregate with inherited Enquiry context.
Method: `GET`
Path: `/api/v1/services/job-assignments/{assignmentId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: any assignment view scope.
Supported Scope: ASSIGNED / TEAM / ALL.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: `assignmentId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: inherited enquiry context, resolved assignee names/codes.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: scope-checked; out-of-scope → `404`.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: assignment aggregate including `materialReceived` (inherited,
read-only) and `enquiryDetails[]`.
Response Field Table: as Job Assignment entity.
Errors: `401`, `403`, `404`.
Notes: None of the inherited context is editable here.

---

### Update Job Assignment

Purpose: Edit an ACTIVE assignment (visit date + work lines).
Method: `PATCH`
Path: `/api/v1/services/job-assignments/{assignmentId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.jobAssignments.edit`.
Supported Scope: Company (edit implies View All).
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `assignmentId` (uuid).
Query Parameters: None / Not applicable.
Request Body: `scheduledVisitDate` + `lines` (complete desired set;
`sourceEnquiryId` immutable).
Request Field Table: as Create lines (enquiry optional/immutable).
Server-Derived Fields: `version` increment, audit, `searchText`.
Business Validations: assignment exists and `ACTIVE` (else
`SERVICES_JOB_ASSIGNMENT_NOT_EDITABLE`); line/reference rules; ≥1 line.
Authorization / Object Scope Rules: company edit authority.
Transactional Side Effects: header + line reconciliation + version + activity +
outbox + notification.
Activity Event: `services.jobAssignment.updated`, plus
`services.jobAssignment.visitDateChanged` when the visit date changes and
`services.jobAssignment.assignmentChanged` when line targets change.
Notification Side Effects: `serviceWorkAssigned` re-notify (deduped by key).
Idempotency: same key is a no-op.
Concurrency: `version`; stale → `409 RECORD_VERSION_CONFLICT`.
Success Response: updated assignment.
Response Field Table: as Job Assignment entity.
Errors: `400`, `401`, `403`, `404`, `409`.
Notes: Editing lines does not change the Enquiry status.

---

### Cancel Job Assignment

Purpose: Cancel an ACTIVE assignment and reconcile the Enquiry.
Method: `POST`
Path: `/api/v1/services/job-assignments/{assignmentId}/cancel`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.jobAssignments.cancel`.
Supported Scope: Company (cancel implies View All).
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `assignmentId` (uuid).
Query Parameters: None / Not applicable.
Request Body: `{ "reason": "customer cancelled" }` (optional).
Request Field Table: `reason` string? optional.
Server-Derived Fields: `status=cancelled`, `version` increment, audit.
Business Validations: assignment exists and `ACTIVE` (else
`SERVICES_JOB_ASSIGNMENT_ALREADY_CANCELLED`).
Authorization / Object Scope Rules: company cancel authority.
Transactional Side Effects: assignment status + (when no other active assignment
for the enquiry) Enquiry `ASSIGNED → OPEN` + Enquiry activity
`services.enquiry.reopened` + assignment activity + outbox.
Activity Event: `services.jobAssignment.cancelled`.
Notification Side Effects: None / Not applicable.
Idempotency: same key is a no-op.
Concurrency: `version`; stale → `409`.
Success Response: cancelled assignment.
Response Field Table: as Job Assignment entity.
Errors: `400`, `401`, `403`, `404`, `409`.
Notes: Historical, never deleted.

---

### Job Assignment Summary

Purpose: Scope-aware assignment counts.
Method: `GET`
Path: `/api/v1/services/job-assignments/summary`
Authentication: Bearer.
Company Context: Required.
Required Permission: any assignment view scope.
Supported Scope: ASSIGNED / TEAM / ALL.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `today` (company-local).
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: scope-aware.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: `{ "activeCount": 9, "todayCount": 2, "upcomingCount": 5, "totalCount": 60 }`.
Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `activeCount` | integer | active assignments |
| `todayCount` | integer | active with visit date today |
| `upcomingCount` | integer | active with visit date after today |
| `totalCount` | integer | all in scope |

Errors: `401`, `403`.
Notes: None / Not applicable.

---

### Eligible Enquiry Context (for Job Assignment form)

Purpose: Restricted source-enquiry context for the assignment form/detail.
Method: `GET`
Path: `/api/v1/services/references/eligible-enquiries/{enquiryId}/context`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.jobAssignments.create` or
`services.jobAssignments.edit`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: `enquiryId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: snapshot, classification, `materialReceived` (inherited),
enquiry detail lines.
Business Validations: enquiry exists.
Authorization / Object Scope Rules: authorized by Job Assignment Create/Edit.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: source context (customer/site snapshot, classification,
`materialReceived`, `details[]`).
Response Field Table: as Enquiry context fields.
Errors: `401`, `403`, `404`.
Notes: Does not grant full Enquiry directory access.

---

### Get Inspection For Job Assignment

Purpose: Integration read (active/non-cancelled inspection reference).
Method: `GET`
Path: `/api/v1/services/job-assignments/{assignmentId}/inspection`
Authentication: Bearer.
Company Context: Required.
Required Permission: any Inspection view scope.
Supported Scope: inspection scope.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: `assignmentId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: resolved technician/root-cause names.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: resolved through the Inspection scope.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: `{ "id": "…", "inspectionNumber": "INS-000030", "status": "pending", "visitDate": "2026-09-30", "visitMinutes": 600, "technicianName": "…", "rootCauseName": null }` or `null`.
Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | inspection id |
| `inspectionNumber` | string | number |
| `status` | enum | inspection status |
| `visitDate` | date | visit date |
| `visitMinutes` | integer? | minutes-of-day |
| `technicianName`,`rootCauseName` | string? | labels |

Errors: `401`, `403`.
Notes: Returns the non-cancelled inspection.

---

### Get Work Execution For Job Assignment

Purpose: Integration read (active work execution reference).
Method: `GET`
Path: `/api/v1/services/job-assignments/{assignmentId}/work-execution`
Authentication: Bearer.
Company Context: Required.
Required Permission: any Work Execution view scope.
Supported Scope: work execution scope.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: `assignmentId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `allLinesComplete`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: resolved through the Work Execution scope.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: work execution ref or `null`.
Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | execution id |
| `executionNumber` | string | number |
| `status` | enum | execution status |
| `executionDate` | date | date |
| `workLineCount` | integer | lines |
| `allLinesComplete` | boolean | completion gate |

Errors: `401`, `403`.
Notes: None / Not applicable.

---

### Job Assignment Activity

Purpose: Structured activity for one assignment.
Method: `GET`
Path: `/api/v1/services/job-assignments/{assignmentId}/activity`
Authentication: Bearer.
Company Context: Required.
Required Permission: any assignment view scope.
Supported Scope: ASSIGNED / TEAM / ALL.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: `assignmentId` (uuid).
Query Parameters: `page`, `pageSize`.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: actor, `occurredAt`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: scope-checked.
Transactional Side Effects: None / Not applicable.
Activity Event: returns activity.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: paginated activity entries.
Response Field Table: as Enquiry Activity.
Errors: `401`, `403`, `404`.
Notes: None / Not applicable.

## 25. Inspections

An Inspection records the field assessment of a source Job Assignment: checklist,
before-work photos, inspected points, and material requirements. Customer/Site/
classification/Material Received are read from the source Enquiry, never retyped.

### 25.1 Lifecycle

`PENDING → COMPLETED` or `PENDING → CANCELLED`. Completed/cancelled are
read-only. **V1 rule: at most one non-cancelled Inspection per Job Assignment.**

### 25.2 Inspection entity (read model)

| Field | Type | Notes |
| --- | --- | --- |
| `id`,`companyId` | uuid | |
| `inspectionNumber` | string | `INS-…` |
| `inspectionDate` | date | company-local, server-derived |
| `sourceJobAssignmentId` | uuid | authoritative |
| `sourceEnquiryId` | uuid | derived from assignment |
| `visitDate` | date | company-local |
| `visitMinutes` | integer? | minutes-of-day company-local |
| `technicianEmployeeId` | uuid? | Employee reference |
| `rootCauseId` | uuid? | master |
| `chargeResponsibilityId` | uuid? | master |
| `status` | enum | pending/completed/cancelled |
| `checklistItems` | array | checklist + before-work photos |
| `inspectedPoints` | array | 0..N points |
| `materialRequirements` | array | material required |
| `version` | integer | optimistic concurrency |
| audit | | |
| context | | inherited enquiry snapshot, classification, `materialReceived`, `assignmentNumber`, `enquiryNumber`, resolved technician/root-cause/charge names |

### 25.3 Checklist item (child)

| Field | Type | Notes |
| --- | --- | --- |
| `id` | uuid | stable identity |
| `sourceJobAssignmentLineId` | uuid? | optional lineage to assignment line |
| `lineNumber` | integer | order |
| `workType` | string | required (prefilled from assignment `work`) |
| `descriptionForWork` | string | optional |
| `status` | enum | `pending` only — vocabulary **TBD** |
| `attachments` | array | `serviceInspectionChecklistItem` / `beforeWorkPhoto` |

### 25.4 Inspected point (child)

`id`, `lineNumber`, `description` (required). 0..N allowed.

### 25.5 Material requirement (child)

`id`, `lineNumber`, `code` (required), `description` (required), `status`
(`waiting`/`requested`). **WAITING → REQUESTED** when included in an active
Material Request; reverts to WAITING when that request is cancelled. No
inventory states are modelled.

### 25.6 Completion rules (exact)

An Inspection may be completed only when: technician set, `visitMinutes` set,
root cause set, charge responsibility set, and at least one checklist item or
inspected point exists.

---

### List Inspections

Purpose: Paginated, scope-aware inspection list.
Method: `GET`
Path: `/api/v1/services/inspections`
Authentication: Bearer.
Company Context: Required.
Required Permission: any `services.inspections.view` scope.
Supported Scope: ASSIGNED / TEAM / ALL.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: `q`, `status`, `technicianEmployeeId`, `rootCauseId`,
`priorityId`, `visitFrom`, `visitTo`, `sort`, `page`, `pageSize`, `recent`,
`limit`.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `assignmentNumber`, `enquiryNumber`, snapshot,
`technicianName`, `rootCauseName`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: ASSIGNED = technician OR direct employee on
source assignment OR member of an assigned team; TEAM = assigned-team
membership; ALL = company.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{
  "success": true,
  "data": [ { "id": "…", "inspectionNumber": "INS-000030", "createdAt": "…", "visitDate": "2026-09-30", "visitMinutes": 600, "status": "pending", "assignmentNumber": "JA-000045", "enquiryNumber": "ENQ-000120", "customerName": "Acme Facilities", "siteSummary": "Tower A / 1204", "technicianName": "Ahmed Khan", "rootCauseName": null } ],
  "meta": { "page": 1, "pageSize": 25, "totalItems": 30, "totalPages": 2, "filteredItems": 4, "requestId": "uuid", "serverTimeUtc": "…" }
}
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | inspection id |
| `inspectionNumber` | string | number |
| `visitDate` | date | visit date |
| `visitMinutes` | integer? | minutes-of-day |
| `status` | enum | inspection status |
| `assignmentNumber`,`enquiryNumber` | string | lineage numbers |
| `customerName` | string | snapshot |
| `siteSummary` | string | site summary |
| `technicianName`,`rootCauseName` | string? | labels |

Default sort `visitDate desc, createdAt desc`.
Errors: `400`, `401`, `403`.
Notes: None / Not applicable.

---

### Create Inspection

Purpose: Create an inspection (checklist, points, material requirements,
before-work photos).
Method: `POST`
Path: `/api/v1/services/inspections`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.inspections.create`.
Supported Scope: Company (create implies View All).
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: None / Not applicable.
Query Parameters: None / Not applicable.
Request Body:

```json
{
  "sourceJobAssignmentId": "66666666-6666-4666-8666-666666666666",
  "visitDate": "2026-09-30",
  "visitMinutes": 600,
  "technicianEmployeeId": "…",
  "rootCauseId": "…",
  "chargeResponsibilityId": "…",
  "checklistItems": [
    { "id": "…", "sourceJobAssignmentLineId": "…", "workType": "Inspect cooling unit", "descriptionForWork": "Check refrigerant", "status": "pending",
      "attachments": [ { "id": "…", "fileName": "before.jpg", "displayName": "before.jpg", "mimeType": "image/jpeg", "sizeBytes": 500000, "category": "beforeWorkPhoto" } ] }
  ],
  "inspectedPoints": [ { "id": "…", "description": "Compressor noise" } ],
  "materialRequirements": [ { "id": "…", "code": "R-410A", "description": "Refrigerant", "status": "waiting" } ]
}
```

Request Field Table:

| Field | Type | Required | Nullable | Source | Description | Validation | Example |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `sourceJobAssignmentId` | uuid | yes | no | client | Source assignment | exists, same company, ACTIVE | `…` |
| `visitDate` | date | yes | no | client | Visit date | company-local | `2026-09-30` |
| `visitMinutes` | integer | no | yes | client | Visit time | 0–1439 | `600` |
| `technicianEmployeeId` | uuid | no | yes | client | Technician | must be eligible for the assignment | `…` |
| `rootCauseId` | uuid | no | yes | client | Root cause | active master | `…` |
| `chargeResponsibilityId` | uuid | no | yes | client | Charge responsibility | active master | `…` |
| `checklistItems[]` | array | no | yes | client | Checklist | each `workType` non-empty | `[…]` |
| `inspectedPoints[]` | array | no | yes | client | Points | each `description` non-empty | `[…]` |
| `materialRequirements[]` | array | no | yes | client | Material required | each `code`,`description` non-empty | `[…]` |
| child `id`s | uuid | yes | no | client | identities | unique per aggregate | `…` |

Server-Derived Fields: `id`, `companyId`, `inspectionNumber`, `inspectionDate`,
`sourceEnquiryId` (from assignment), `status=pending`, `version=1`, `searchText`,
audit.
Business Validations: assignment exists/ACTIVE/same company; no other
non-cancelled inspection; technician eligible (direct employee on assignment
lines, active member or lead of an assigned team, active employee); root
cause/charge responsibility active when supplied; child field rules.
Authorization / Object Scope Rules: company create authority.
Transactional Side Effects: sequence + header + checklist + points + material
requirements + before-work attachment metadata + activity + outbox + technician
notification (atomic, §16.4).
Activity Event: `services.inspection.created`.
Notification Side Effects: `serviceInspectionAssigned` to the technician’s
linked user account (when set), deep-link metadata to the inspection.
Idempotency: same key returns same inspection; no duplicate children/activity.
Concurrency: Not applicable on create beyond one-active rule.
Success Response: `201` created inspection aggregate.
Response Field Table: as Inspection entity.
Errors: `400` (`SERVICES_INSPECTION_ASSIGNMENT_REQUIRED`,
`SERVICES_INSPECTION_VISIT_DATE_REQUIRED`,
`SERVICES_INSPECTION_WORK_TYPE_REQUIRED`,
`SERVICES_INSPECTION_POINT_REQUIRED`,
`SERVICES_INSPECTION_MATERIAL_CODE_REQUIRED`,
`SERVICES_INSPECTION_MATERIAL_DESCRIPTION_REQUIRED`,
`SERVICES_INSPECTION_ASSIGNMENT_INVALID`,
`SERVICES_INSPECTION_ALREADY_ACTIVE`,
`SERVICES_INSPECTION_TECHNICIAN_INVALID`,
`SERVICES_INSPECTION_ROOT_CAUSE_INVALID`,
`SERVICES_INSPECTION_CHARGE_RESPONSIBILITY_INVALID`), `401`, `403`.
Notes: Customer/Site/classification/Material Received are derived; do not send.

---

### Get Inspection

Purpose: Read the inspection aggregate with inherited context.
Method: `GET`
Path: `/api/v1/services/inspections/{inspectionId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: any inspection view scope.
Supported Scope: ASSIGNED / TEAM / ALL.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: `inspectionId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: inherited context, resolved names, child attachments.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: scope-checked; out-of-scope → `404`.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: inspection aggregate.
Response Field Table: as Inspection entity.
Errors: `401`, `403`, `404`.
Notes: None / Not applicable.

---

### Update Inspection

Purpose: Edit a PENDING inspection and reconcile children/photos.
Method: `PATCH`
Path: `/api/v1/services/inspections/{inspectionId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.inspections.edit`.
Supported Scope: Company (edit implies View All).
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `inspectionId` (uuid).
Query Parameters: None / Not applicable.
Request Body: same as Create (without `sourceJobAssignmentId`, which is
immutable); children are the complete desired sets.
Request Field Table: as Create.
Server-Derived Fields: `version` increment, audit, `searchText`.
Business Validations: inspection exists and `PENDING` (else
`SERVICES_INSPECTION_NOT_EDITABLE`); reference rules; child rules.
Authorization / Object Scope Rules: company edit authority.
Transactional Side Effects: header + child reconciliation + attachment metadata
+ version + activity + outbox + technician notification.
Activity Event: `services.inspection.updated`, plus
`services.inspection.technicianChanged` / `services.inspection.visitChanged` /
`services.inspection.rootCauseChanged` when the respective values change.
Notification Side Effects: `serviceInspectionAssigned` when a technician is set.
Idempotency: same key is a no-op.
Concurrency: `version`; stale → `409 RECORD_VERSION_CONFLICT`.
Success Response: updated inspection.
Response Field Table: as Inspection entity.
Errors: `400`, `401`, `403`, `404`, `409`.
Notes: Changing material requirements does not affect already-requested
requirements’ linkage rules (server re-validates).

---

### Complete Inspection

Purpose: Mark a PENDING inspection COMPLETED.
Method: `POST`
Path: `/api/v1/services/inspections/{inspectionId}/complete`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.inspections.complete`.
Supported Scope: Company (complete implies View All).
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `inspectionId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `status=completed`, `version` increment, audit.
Business Validations: inspection exists and `PENDING` (else
`SERVICES_INSPECTION_NOT_COMPLETABLE`); technician required
(`SERVICES_INSPECTION_TECHNICIAN_REQUIRED`); `visitMinutes` required
(`SERVICES_INSPECTION_VISIT_TIME_REQUIRED`); root cause required
(`SERVICES_INSPECTION_ROOT_CAUSE_REQUIRED`); charge responsibility required
(`SERVICES_INSPECTION_CHARGE_RESPONSIBILITY_REQUIRED`); at least one checklist
item or inspected point (`SERVICES_INSPECTION_ASSESSMENT_REQUIRED`).
Authorization / Object Scope Rules: company complete authority.
Transactional Side Effects: status + version + activity + outbox.
Activity Event: `services.inspection.completed`.
Notification Side Effects: None / Not applicable.
Idempotency: same key is a no-op.
Concurrency: `version`; stale → `409`.
Success Response: completed inspection.
Response Field Table: as Inspection entity.
Errors: `400`, `401`, `403`, `404`, `409`.
Notes: Completion is required before a Material Request or Work Execution can
reference the inspection.

---

### Cancel Inspection

Purpose: Cancel a PENDING inspection (historical).
Method: `POST`
Path: `/api/v1/services/inspections/{inspectionId}/cancel`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.inspections.cancel`.
Supported Scope: Company (cancel implies View All).
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `inspectionId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `status=cancelled`, `version` increment, audit.
Business Validations: inspection exists; must be `PENDING`; already cancelled →
`SERVICES_INSPECTION_ALREADY_CANCELLED`; completed →
`SERVICES_INSPECTION_NOT_CANCELLABLE`.
Authorization / Object Scope Rules: company cancel authority.
Transactional Side Effects: status + version + activity + outbox.
Activity Event: `services.inspection.cancelled`.
Notification Side Effects: None / Not applicable.
Idempotency: same key is a no-op.
Concurrency: `version`; stale → `409`.
Success Response: cancelled inspection.
Response Field Table: as Inspection entity.
Errors: `400`, `401`, `403`, `404`, `409`.
Notes: Cancelling does not delete children; before-work photos remain owned by
the cancelled inspection (read-only).

---

### Inspection Summary

Purpose: Scope-aware inspection counts.
Method: `GET`
Path: `/api/v1/services/inspections/summary`
Authentication: Bearer.
Company Context: Required.
Required Permission: any inspection view scope.
Supported Scope: ASSIGNED / TEAM / ALL.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `today` (company-local).
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: scope-aware.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: `{ "pendingCount": 4, "todayCount": 1, "completedCount": 22, "totalCount": 30 }`.
Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `pendingCount` | integer | pending |
| `todayCount` | integer | visit date today |
| `completedCount` | integer | completed |
| `totalCount` | integer | all in scope |

Errors: `401`, `403`.
Notes: None / Not applicable.

---

### Eligible Job Assignment Reference (for Inspection)

Purpose: Restricted eligible-assignment selector, without broad assignment
access.
Method: `GET`
Path: `/api/v1/services/references/eligible-job-assignments`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.inspections.create` or
`services.inspections.edit`.
Supported Scope: Company eligible set.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: `q`, `limit`.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: eligibility.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: authorized by Inspection Create/Edit.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{ "success": true, "data": [ { "id": "…", "assignmentNumber": "JA-000045", "enquiryNumber": "ENQ-000120", "customerName": "Acme Facilities", "customerMobile": "…", "siteSummary": "Tower A / 1204", "scheduledVisitDate": "2026-09-30", "priorityName": "High" } ] }
```

Implemented eligibility: assignment `status=active` and no non-cancelled
inspection.

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | assignment id |
| `assignmentNumber`,`enquiryNumber` | string | numbers |
| `customerName`,`customerMobile` | string? | snapshot |
| `siteSummary` | string | site summary |
| `scheduledVisitDate` | date | visit date |
| `priorityName` | string? | label |

Errors: `401`, `403`.
Notes: None / Not applicable.

---

### Inspection Source Context (for Inspection form)

Purpose: Restricted source context from a selected Job Assignment.
Method: `GET`
Path: `/api/v1/services/references/eligible-job-assignments/{assignmentId}/context`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.inspections.create` or
`services.inspections.edit`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: `assignmentId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: snapshot, classification, `materialReceived`,
`scheduledVisitDate`, `workLines[]`, `eligibleTechnicians[]`.
Business Validations: assignment exists.
Authorization / Object Scope Rules: authorized by Inspection Create/Edit.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: source context; `eligibleTechnicians` = direct employees on
assignment lines + active members + lead of assigned teams, active employees
only.

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `jobAssignmentId`,`assignmentNumber` | uuid/string | source |
| `enquiryId`,`enquiryNumber` | uuid/string | lineage |
| `customerName`,`customerMobile` | string? | snapshot |
| `priorityName`,`priorityRank`,`complaintTypeName` | | classification |
| `materialReceived` | enum | inherited read-only |
| `scheduledVisitDate` | date | visit date |
| `workLines` | array | assignment lines |
| `eligibleTechnicians` | array | `{id,name,employeeCode}` |

Errors: `401`, `403`, `404`.
Notes: None / Not applicable.

---

### Get Material Requests For Inspection

Purpose: Integration read (material requests recorded against an inspection).
Method: `GET`
Path: `/api/v1/services/inspections/{inspectionId}/material-requests`
Authentication: Bearer.
Company Context: Required.
Required Permission: any Material Request view scope.
Supported Scope: material request scope.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: `inspectionId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `itemCount`, `totalQuantity`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: resolved through the Material Request scope.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: `[ { "id": "…", "requestNumber": "MR-000010", "status": "open", "requestDate": "2026-09-30", "itemCount": 3, "totalQuantity": 5.5 } ]`.
Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | request id |
| `requestNumber` | string | number |
| `status` | enum | request status |
| `requestDate` | date | date |
| `itemCount` | integer | line count |
| `totalQuantity` | number | derived sum |

Errors: `401`, `403`.
Notes: None / Not applicable.

---

### Get Work Execution For Inspection

Purpose: Integration read (active work execution for an inspection).
Method: `GET`
Path: `/api/v1/services/inspections/{inspectionId}/work-execution`
Authentication: Bearer.
Company Context: Required.
Required Permission: any Work Execution view scope.
Supported Scope: work execution scope.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: `inspectionId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `allLinesComplete`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: resolved through the Work Execution scope.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: work execution ref or `null`.
Response Field Table: as Get Work Execution For Job Assignment.
Errors: `401`, `403`.
Notes: None / Not applicable.

---

### Inspection Activity

Purpose: Structured activity for one inspection.
Method: `GET`
Path: `/api/v1/services/inspections/{inspectionId}/activity`
Authentication: Bearer.
Company Context: Required.
Required Permission: any inspection view scope.
Supported Scope: ASSIGNED / TEAM / ALL.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: `inspectionId` (uuid).
Query Parameters: `page`, `pageSize`.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: actor, `occurredAt`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: scope-checked.
Transactional Side Effects: None / Not applicable.
Activity Event: returns activity.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: paginated activity entries.
Response Field Table: as Enquiry Activity.
Errors: `401`, `403`, `404`.
Notes: None / Not applicable.

---

## 26. Material Requests

A Material Request records materials requested against a **completed** Inspection.
It preserves lineage to the Inspection/Job Assignment/Enquiry and stores
requested lines (code, description, optional batch, quantity, remark). It does
**not** store Material Received (inherited read-only).

### 26.1 Lifecycle

`OPEN → (CANCELLED)`. No approval/issue/receive workflow exists. Multiple
requests per Inspection are allowed; one source requirement may be in at most one
**active** request.

### 26.2 Material Request entity (read model)

| Field | Type | Notes |
| --- | --- | --- |
| `id`,`companyId` | uuid | |
| `requestNumber` | string | `MR-…` |
| `requestDate` | date | company-local, server-derived |
| `sourceInspectionId` | uuid | authoritative |
| `sourceJobAssignmentId`,`sourceEnquiryId` | uuid | derived |
| `jobOrderReference` | string? | compatibility reference only (**TBD owner**) |
| `purposeId` | uuid? | active master |
| `acknowledgement` | string? | optional metadata; semantics **TBD**; never state-driving |
| `receivedBy` | string? | optional free text; identity **TBD**; not a relationship |
| `remarks` | string? | optional |
| `status` | enum | open/cancelled |
| `lines` | array | requested lines |
| `totalQuantity` | number | derived sum (never client-authoritative) |
| `version` | integer | |
| audit | | |
| context | | inherited enquiry snapshot + classification + `materialReceived` + purpose/technician names |

### 26.3 Material Request line (child)

| Field | Type | Notes |
| --- | --- | --- |
| `id` | uuid | stable identity |
| `sourceInspectionMaterialRequirementId` | uuid? | optional lineage; null for manual lines |
| `lineNumber` | integer | order |
| `code` | string | required |
| `description` | string | required |
| `batchNumber` | string? | optional |
| `quantity` | number | required; `> 0`; ≤3 decimals |
| `remark` | string? | optional |

### 26.4 Requirement state transition

- On create/update: each included requirement goes `WAITING → REQUESTED`.
- On cancel: linked requirements return `REQUESTED → WAITING` and the internal
  active requirement link is released (source lineage retained).
- One requirement may be linked to at most one active request.

### 26.5 Material concepts (distinct)

| Concept | Owner | Meaning |
| --- | --- | --- |
| Material Received | Enquiry | contextual Yes/No |
| Material Required | Inspection | finding (`WAITING`/`REQUESTED`) |
| Material Requested | Material Request | requested lines + quantity |
| Material Used | Work Execution | code + description actually used |

---

### List Material Requests

Purpose: Paginated, scope-aware material request list.
Method: `GET`
Path: `/api/v1/services/material-requests`
Authentication: Bearer.
Company Context: Required.
Required Permission: any `services.materialRequests.view` scope.
Supported Scope: ASSIGNED / TEAM / ALL.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: `q`, `status`, `purposeId`, `inspectionId`, `dateFrom`,
`dateTo`, `sort`, `page`, `pageSize`, `recent`, `limit`.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `inspectionNumber`, `assignmentNumber`, `enquiryNumber`,
snapshot, `purposeName`, `itemCount`, `totalQuantity`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: ASSIGNED = source inspection technician OR
direct employee on the source assignment OR member of an assigned team; TEAM =
assigned-team membership; ALL = company.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{
  "success": true,
  "data": [ { "id": "…", "requestNumber": "MR-000010", "requestDate": "2026-09-30", "createdAt": "…", "status": "open", "inspectionNumber": "INS-000030", "assignmentNumber": "JA-000045", "enquiryNumber": "ENQ-000120", "customerName": "Acme Facilities", "siteSummary": "Tower A / 1204", "purposeName": "Repair", "preparedByUserId": "…", "itemCount": 3, "totalQuantity": 5.5 } ],
  "meta": { "page": 1, "pageSize": 25, "totalItems": 25, "totalPages": 1, "filteredItems": 3, "requestId": "uuid", "serverTimeUtc": "…" }
}
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | request id |
| `requestNumber` | string | number |
| `requestDate` | date | date |
| `status` | enum | open/cancelled |
| `inspectionNumber`,`assignmentNumber`,`enquiryNumber` | string | lineage |
| `customerName` | string | snapshot |
| `siteSummary` | string | site summary |
| `purposeName` | string? | purpose label |
| `preparedByUserId` | uuid | author |
| `itemCount` | integer | lines |
| `totalQuantity` | number | derived sum |

Default sort `requestDate desc, createdAt desc`.
Errors: `400`, `401`, `403`.
Notes: None / Not applicable.

---

### Create Material Request

Purpose: Create a request against a completed inspection; transition linked
requirements.
Method: `POST`
Path: `/api/v1/services/material-requests`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.materialRequests.create`.
Supported Scope: Company (create implies View All).
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: None / Not applicable.
Query Parameters: None / Not applicable.
Request Body:

```json
{
  "sourceInspectionId": "77777777-7777-4777-8777-777777777777",
  "jobOrderReference": "JO-EXT-001",
  "purposeId": "…",
  "acknowledgement": null,
  "receivedBy": null,
  "remarks": "Urgent",
  "lines": [
    { "id": "…", "sourceInspectionMaterialRequirementId": "…", "code": "R-410A", "description": "Refrigerant", "batchNumber": "B-12", "quantity": 2.5, "remark": null }
  ]
}
```

Request Field Table:

| Field | Type | Required | Nullable | Source | Description | Validation | Example |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `sourceInspectionId` | uuid | yes | no | client | Source inspection | exists, same company, COMPLETED | `…` |
| `jobOrderReference` | string | no | yes | client | Job Order reference | free text; TBD owner | `JO-EXT-001` |
| `purposeId` | uuid | no | yes | client | Purpose | active master when supplied | `…` |
| `acknowledgement` | string | no | yes | client | Acknowledge metadata | semantics TBD; never state | `null` |
| `receivedBy` | string | no | yes | client | Received-by text | identity TBD; no FK | `null` |
| `remarks` | string | no | yes | client | Remarks | optional | `Urgent` |
| `lines` | array | yes | no | client | Requested lines | ≥1 | `[…]` |
| `lines[].id` | uuid | yes | no | client | line identity | unique | `…` |
| `lines[].sourceInspectionMaterialRequirementId` | uuid | no | yes | client | Requirement lineage | belongs to inspection; WAITING or already linked to this request | `…` |
| `lines[].code` | string | yes | no | client | Code | non-empty | `R-410A` |
| `lines[].description` | string | yes | no | client | Description | non-empty | `Refrigerant` |
| `lines[].batchNumber` | string | no | yes | client | Batch | optional | `B-12` |
| `lines[].quantity` | number | yes | no | client | Quantity | `> 0`; ≤3 dp | `2.5` |
| `lines[].remark` | string | no | yes | client | Line remark | optional | `null` |

Server-Derived Fields: `id`, `companyId`, `requestNumber`, `requestDate`,
`sourceJobAssignmentId`, `sourceEnquiryId`, `status=open`, `version=1`,
`totalQuantity` (sum), `searchText`, audit.
Business Validations: inspection required, exists, same company, COMPLETED; each
line code/description non-empty; quantity `> 0`; each linked requirement belongs
to the inspection, not removed, and is `WAITING` or already linked to this
request; no requirement linked to another active request; purpose active.
Authorization / Object Scope Rules: company create authority.
Transactional Side Effects: sequence + header + lines + requirement
`WAITING → REQUESTED` + activity + outbox (atomic, §16.4).
Activity Event: `services.materialRequest.created`.
Notification Side Effects: None / Not applicable.
Idempotency: same key returns same request; no duplicate lines/transitions.
Concurrency: Not applicable on create.
Success Response: `201` created request (with derived `totalQuantity`).
Response Field Table: as Material Request entity.
Errors: `400` (`SERVICES_MATERIAL_REQUEST_INSPECTION_REQUIRED`,
`SERVICES_MATERIAL_REQUEST_LINES_REQUIRED`,
`SERVICES_MATERIAL_REQUEST_CODE_REQUIRED`,
`SERVICES_MATERIAL_REQUEST_DESCRIPTION_REQUIRED`,
`SERVICES_MATERIAL_REQUEST_QUANTITY_REQUIRED`,
`SERVICES_MATERIAL_REQUEST_INSPECTION_INVALID`,
`SERVICES_MATERIAL_REQUEST_REQUIREMENT_LINKED`,
`SERVICES_MATERIAL_REQUEST_PURPOSE_INVALID`), `401`, `403`.
Notes: Material Received is never accepted here; it is inherited from the
Enquiry. Totals are server-derived.

---

### Get Material Request

Purpose: Read the request aggregate with inherited context.
Method: `GET`
Path: `/api/v1/services/material-requests/{requestId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: any material request view scope.
Supported Scope: ASSIGNED / TEAM / ALL.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: `requestId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: inherited context, resolved names, `totalQuantity`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: scope-checked; out-of-scope → `404`.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: request aggregate including `materialReceived` (inherited,
read-only).
Response Field Table: as Material Request entity.
Errors: `401`, `403`, `404`.
Notes: `materialReceived` is never editable here.

---

### Update Material Request

Purpose: Edit an OPEN request and reconcile lines/requirements.
Method: `PATCH`
Path: `/api/v1/services/material-requests/{requestId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.materialRequests.edit`.
Supported Scope: Company (edit implies View All).
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `requestId` (uuid).
Query Parameters: None / Not applicable.
Request Body: same mutable header fields + complete desired `lines` set
(`sourceInspectionId` immutable).
Request Field Table: as Create (source inspection immutable).
Server-Derived Fields: `version` increment, `totalQuantity`, audit.
Business Validations: request exists and `OPEN` (else
`SERVICES_MATERIAL_REQUEST_NOT_EDITABLE`); line/reference rules; released
requirements revert `REQUESTED → WAITING`; newly included go
`WAITING → REQUESTED`; ≥1 line remains.
Authorization / Object Scope Rules: company edit authority.
Transactional Side Effects: header + line replacement + requirement status
reconciliation + version + activity + outbox.
Activity Event: `services.materialRequest.updated`, plus
`services.materialRequest.linesChanged` when line/requirement linkage changes.
Notification Side Effects: None / Not applicable.
Idempotency: same key is a no-op.
Concurrency: `version`; stale → `409 RECORD_VERSION_CONFLICT`.
Success Response: updated request.
Response Field Table: as Material Request entity.
Errors: `400`, `401`, `403`, `404`, `409`.
Notes: The server reconciles by stable line id as well as requirement linkage.

---

### Cancel Material Request

Purpose: Cancel an OPEN request and release its requirements.
Method: `POST`
Path: `/api/v1/services/material-requests/{requestId}/cancel`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.materialRequests.cancel`.
Supported Scope: Company (cancel implies View All).
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `requestId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `status=cancelled`, `version` increment, audit.
Business Validations: request exists; already cancelled →
`SERVICES_MATERIAL_REQUEST_ALREADY_CANCELLED`.
Authorization / Object Scope Rules: company cancel authority.
Transactional Side Effects: status + release active requirement links +
requirement `REQUESTED → WAITING` + version + activity + outbox.
Activity Event: `services.materialRequest.cancelled`.
Notification Side Effects: None / Not applicable.
Idempotency: same key is a no-op.
Concurrency: `version`; stale → `409`.
Success Response: cancelled request.
Response Field Table: as Material Request entity.
Errors: `400`, `401`, `403`, `404`, `409`.
Notes: Source lineage is retained; requirements become re-requestable.

---

### Material Request Print Data

Purpose: Return structured printable data for a request (authorized).
Method: `GET`
Path: `/api/v1/services/material-requests/{requestId}/print`
Authentication: Bearer.
Company Context: Required.
Required Permission: **both** any material request view scope **and**
`services.materialRequests.print`.
Supported Scope: ASSIGNED / TEAM / ALL.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: `requestId` (uuid).
Query Parameters: `format` (`json` default; `pdf` future/optional).
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `totalQuantity`, resolved labels.
Business Validations: request exists.
Authorization / Object Scope Rules: View + Print + object scope (all three).
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable (an optional print-audit event may be
added by the backend).
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable (read).
Concurrency: Not applicable.
Success Response: (structured print document; see Response Field Table)

```json
{
  "success": true,
  "data": {
    "companyName": "Bitlogix",
    "requestNumber": "MR-000010", "requestDate": "2026-09-30",
    "inspectionNumber": "INS-000030", "assignmentNumber": "JA-000045", "enquiryNumber": "ENQ-000120",
    "customerName": "Acme Facilities", "customerMobile": "…", "siteSummary": "Tower A / 1204",
    "materialReceived": "no", "jobOrderReference": "JO-EXT-001", "purposeName": "Repair",
    "acknowledgement": null, "receivedBy": null, "remarks": "Urgent",
    "preparedByUserId": "…",
    "lines": [ { "lineNumber": 1, "code": "R-410A", "description": "Refrigerant", "batchNumber": "B-12", "quantity": 2.5, "remark": null } ],
    "totalQuantity": 2.5
  },
  "meta": { "requestId": "uuid", "serverTimeUtc": "…" }
}
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `companyName` | string | company display name |
| `requestNumber`,`requestDate` | string/date | header |
| `inspectionNumber`,`assignmentNumber`,`enquiryNumber` | string | lineage |
| `customerName`,`customerMobile` | string? | snapshot |
| `siteSummary` | string | site summary |
| `materialReceived` | enum | inherited read-only |
| `jobOrderReference` | string? | compatibility reference |
| `purposeName` | string? | label |
| `acknowledgement`,`receivedBy`,`remarks` | string? | metadata |
| `preparedByUserId` | uuid | author |
| `lines` | array | printable lines |
| `totalQuantity` | number | derived sum |

Errors: `401`, `403` (`SERVICES_MATERIAL_REQUEST_DENIED`), `404`.
Notes: PDF generation may be server-side; if so, return a binary/URL variant.
Never trust a client-generated total.

---

### Material Request Summary

Purpose: Scope-aware material request counts.
Method: `GET`
Path: `/api/v1/services/material-requests/summary`
Authentication: Bearer.
Company Context: Required.
Required Permission: any material request view scope.
Supported Scope: ASSIGNED / TEAM / ALL.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `today` (company-local).
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: scope-aware.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: `{ "openCount": 3, "todayCount": 1, "lineCount": 14, "totalCount": 25 }`.
Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `openCount` | integer | open requests |
| `todayCount` | integer | request date today |
| `lineCount` | integer | total lines in scope |
| `totalCount` | integer | all in scope |

Errors: `401`, `403`.
Notes: None / Not applicable.

---

### Eligible Inspection Reference (for Material Request)

Purpose: Restricted eligible completed-inspection selector for creating a
request.
Method: `GET`
Path: `/api/v1/services/references/eligible-inspections`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.materialRequests.create` (and
`services.workExecutions.create` for the work-execution variant; see Notes).
Supported Scope: Company eligible set.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: `q`, `limit`, `for` (`material-request` | `work-execution`).
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: waiting requirement count (material-request variant).
Business Validations: `for` valid.
Authorization / Object Scope Rules: authorized by the consuming Create
permission.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{ "success": true, "data": [ { "id": "…", "inspectionNumber": "INS-000030", "assignmentNumber": "JA-000045", "enquiryNumber": "ENQ-000120", "customerName": "Acme Facilities", "siteSummary": "Tower A / 1204", "visitDate": "2026-09-30", "waitingRequirementCount": 2 } ] }
```

Implemented eligibility: inspection `status=completed`. For
`for=material-request`, `waitingRequirementCount` is returned. For
`for=work-execution`, only completed inspections with no non-cancelled work
execution are returned.

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | inspection id |
| `inspectionNumber`,`assignmentNumber`,`enquiryNumber` | string | numbers |
| `customerName` | string | snapshot |
| `siteSummary` | string | site summary |
| `visitDate` | date | visit date |
| `waitingRequirementCount` | integer | waiting requirements (material-request variant) |

Errors: `400`, `401`, `403`.
Notes: `for=work-execution` uses `services.workExecutions.create`.

---

### Material Request Source Context

Purpose: Restricted source context from a selected completed inspection.
Method: `GET`
Path: `/api/v1/services/references/eligible-inspections/{inspectionId}/context`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.materialRequests.create`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: `inspectionId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: snapshot, classification, `materialReceived`,
`waitingRequirements[]`.
Business Validations: inspection exists and is completed.
Authorization / Object Scope Rules: authorized by Material Request Create.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: source context including `waitingRequirements[]` (WAITING
material requirements only).
Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `inspectionId`,`inspectionNumber`,`inspectionStatus` | | source |
| `jobAssignmentId`,`assignmentNumber` | | lineage |
| `enquiryId`,`enquiryNumber`,`customerName`,`customerMobile` | | lineage |
| `complaintTypeName`,`priorityName` | | classification |
| `materialReceived` | enum | inherited |
| `technicianName` | string? | label |
| `waitingRequirements` | array | WAITING requirements |

Errors: `401`, `403`, `404`.
Notes: None / Not applicable.

---

### Material Request Activity

Purpose: Structured activity for one request.
Method: `GET`
Path: `/api/v1/services/material-requests/{requestId}/activity`
Authentication: Bearer.
Company Context: Required.
Required Permission: any material request view scope.
Supported Scope: ASSIGNED / TEAM / ALL.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: `requestId` (uuid).
Query Parameters: `page`, `pageSize`.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: actor, `occurredAt`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: scope-checked.
Transactional Side Effects: None / Not applicable.
Activity Event: returns activity.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: paginated activity entries.
Response Field Table: as Enquiry Activity.
Errors: `401`, `403`, `404`.
Notes: None / Not applicable.

## 27. Work Executions

A Work Execution records the actual field work against a **completed** Inspection.
It owns work lines with actual start/end timestamps, Material Used (code +
description only), and after-work photo entries. Execution lineage
(Inspection → Job Assignment → Enquiry) is derived, never independently selected.

### 27.1 Lifecycle

`PENDING → IN_PROGRESS → COMPLETED` or `→ CANCELLED`. `PENDING`/`IN_PROGRESS` are
the open (editable/performable) states; completed/cancelled are read-only.
**V1 rule: at most one non-cancelled Work Execution per Inspection.**

### 27.2 Work Execution entity (read model)

| Field | Type | Notes |
| --- | --- | --- |
| `id`,`companyId` | uuid | |
| `executionNumber` | string | `WE-…` |
| `executionDate` | date | company-local, server-derived |
| `sourceInspectionId` | uuid | authoritative |
| `sourceJobAssignmentId`,`sourceEnquiryId` | uuid | derived |
| `jobOrderReference` | string? | compatibility reference only (**TBD**) |
| `quotationReference` | string? | compatibility reference only (**TBD**) |
| `status` | enum | pending/inProgress/completed/cancelled |
| `workLines` | array | work lines |
| `materialsUsed` | array | material used (code + description) |
| `afterWorkPhotoEntries` | array | photo entries + after-work photos |
| `version` | integer | |
| audit | | |
| context | | inherited enquiry snapshot + classification + `materialReceived` + checklist/points/material requirements + linked material requests |

Aggregate helpers: `allLinesComplete` (≥1 line, all started+finished, no invalid
range), `hasInvalidRange`.

### 27.3 Work line (child)

| Field | Type | Notes |
| --- | --- | --- |
| `id` | uuid | stable identity |
| `sourceJobAssignmentLineId` | uuid? | optional lineage |
| `lineNumber` | integer | order |
| `work` | string | required |
| `description` | string | optional |
| `serviceTeamId` | uuid? | Service Team |
| `employeeId` | uuid? | Employee |
| `startedAtUtc` | utc datetime? | captured by Start Work |
| `endedAtUtc` | utc datetime? | captured by End Work |
| derived `state` | enum | `notStarted` / `inProgress` / `finished` (derived, not stored) |

Lines may target an Employee, a Service Team, or both. A started line may not be
removed by structural edit.

### 27.4 Material used (child)

`id`, `sourceMaterialRequestLineId` (uuid?, optional lineage), `lineNumber`,
`code` (required), `description` (required). **No** quantity, UOM, batch or cost
— recording Material Used has **no** stock/inventory side effect and does **not**
mutate the Material Request lifecycle.

### 27.5 After-work photo entry (child)

`id`, `lineNumber`, `description` (required), `attachments` array
(`serviceWorkExecutionPhotoEntry` / `afterWorkPhoto`). Whether a photo is
mandatory to complete is **TBD**.

---

### List Work Executions

Purpose: Paginated, scope-aware work execution list.
Method: `GET`
Path: `/api/v1/services/work-executions`
Authentication: Bearer.
Company Context: Required.
Required Permission: any `services.workExecutions.view` scope.
Supported Scope: ASSIGNED / TEAM / ALL.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: `q`, `status`, `employeeId`, `teamId`, `inspectionId`,
`dateFrom`, `dateTo`, `sort`, `page`, `pageSize`, `recent`, `limit`.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `inspectionNumber`, `assignmentNumber`, `enquiryNumber`,
snapshot, `assignedSummary`, aggregate `startedAtUtc`/`endedAtUtc`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: ASSIGNED = employee on a work line OR on the
source assignment line OR the source inspection technician OR member of an
assigned team; TEAM = assigned-team membership; ALL = company.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{
  "success": true,
  "data": [ { "id": "…", "executionNumber": "WE-000012", "createdAt": "…", "executionDate": "2026-09-28", "status": "inProgress", "inspectionNumber": "INS-000030", "assignmentNumber": "JA-000045", "enquiryNumber": "ENQ-000120", "customerName": "Acme Facilities", "siteSummary": "Tower A / 1204", "assignedSummary": "Ahmed Khan + HVAC Team", "startedAtUtc": "2026-09-28T05:00:00Z", "endedAtUtc": null } ],
  "meta": { "page": 1, "pageSize": 25, "totalItems": 18, "totalPages": 1, "filteredItems": 3, "requestId": "uuid", "serverTimeUtc": "…" }
}
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | execution id |
| `executionNumber` | string | number |
| `executionDate` | date | business date |
| `status` | enum | status |
| `inspectionNumber`,`assignmentNumber`,`enquiryNumber` | string | lineage |
| `customerName` | string | snapshot |
| `siteSummary` | string | site summary |
| `assignedSummary` | string | compact assignee summary |
| `startedAtUtc`,`endedAtUtc` | utc datetime? | aggregate range |

Default sort `executionDate desc, createdAt desc`.
Errors: `400`, `401`, `403`.
Notes: None / Not applicable.

---

### Create Work Execution

Purpose: Create a work execution against a completed inspection.
Method: `POST`
Path: `/api/v1/services/work-executions`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.workExecutions.create`.
Supported Scope: Company (create implies View All).
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: None / Not applicable.
Query Parameters: None / Not applicable.
Request Body:

```json
{
  "sourceInspectionId": "88888888-8888-4888-8888-888888888888",
  "jobOrderReference": "JO-EXT-001",
  "quotationReference": "QT-EXT-002",
  "workLines": [
    { "id": "…", "sourceJobAssignmentLineId": "…", "work": "Replace compressor", "description": "As inspected", "serviceTeamId": null, "employeeId": "…" }
  ],
  "materialsUsed": [ { "id": "…", "sourceMaterialRequestLineId": "…", "code": "R-410A", "description": "Refrigerant" } ],
  "afterWorkPhotoEntries": [ { "id": "…", "description": "Completed unit", "attachments": [ { "id": "…", "fileName": "after.jpg", "displayName": "after.jpg", "mimeType": "image/jpeg", "sizeBytes": 600000, "category": "afterWorkPhoto" } ] } ]
}
```

Request Field Table:

| Field | Type | Required | Nullable | Source | Description | Validation | Example |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `sourceInspectionId` | uuid | yes | no | client | Source inspection | exists, same company, COMPLETED | `…` |
| `jobOrderReference` | string | no | yes | client | Job Order reference | free text; TBD owner | `JO-EXT-001` |
| `quotationReference` | string | no | yes | client | Quotation reference | free text; TBD owner | `QT-EXT-002` |
| `workLines` | array | yes | no | client | Work lines | ≥1; each `work` non-empty | `[…]` |
| `workLines[].id` | uuid | yes | no | client | line identity | unique | `…` |
| `workLines[].sourceJobAssignmentLineId` | uuid | no | yes | client | assignment-line lineage | optional | `…` |
| `workLines[].work` | string | yes | no | client | Work | non-empty | `Replace compressor` |
| `workLines[].description` | string | no | no | client | Description | optional | `As inspected` |
| `workLines[].serviceTeamId` | uuid | no | yes | client | Team | active same-company | `null` |
| `workLines[].employeeId` | uuid | no | yes | client | Employee | valid same-company | `…` |
| `materialsUsed[]` | array | no | yes | client | Material used | each `code`,`description` non-empty | `[…]` |
| `materialsUsed[].sourceMaterialRequestLineId` | uuid | no | yes | client | Material request-line lineage | belongs to a request whose source inspection matches | `…` |
| `afterWorkPhotoEntries[]` | array | no | yes | client | Photo entries | each `description` non-empty | `[…]` |
| `afterWorkPhotoEntries[].attachments[]` | array | no | yes | client | Photo metadata | validated per §17 | `[…]` |

Server-Derived Fields: `id`, `companyId`, `executionNumber`, `executionDate`,
`sourceJobAssignmentId`, `sourceEnquiryId`, `status=pending`, `version=1`,
`searchText`, audit.
Business Validations: inspection required, exists, same company, COMPLETED; no
other non-cancelled execution; ≥1 work line; each `work` non-empty; team active
when supplied; employee valid; material source-line belongs to a material request
whose source inspection matches; material code/description; photo description.
Authorization / Object Scope Rules: company create authority.
Transactional Side Effects: sequence + header + work lines + material used +
photo entries + after-work attachment metadata + activity + outbox (atomic,
§16.4).
Activity Event: `services.workExecution.created`.
Notification Side Effects: None / Not applicable (see §29.3 — the documented
“work execution ready” notification is **not implemented**).
Idempotency: same key returns same execution; no duplicate children/activity.
Concurrency: Not applicable on create beyond one-active rule.
Success Response: `201` created execution aggregate.
Response Field Table: as Work Execution entity.
Errors: `400` (`SERVICES_WORK_EXECUTION_INSPECTION_REQUIRED`,
`SERVICES_WORK_EXECUTION_LINES_REQUIRED`,
`SERVICES_WORK_EXECUTION_WORK_REQUIRED`,
`SERVICES_WORK_EXECUTION_CODE_REQUIRED`,
`SERVICES_WORK_EXECUTION_DESCRIPTION_REQUIRED`,
`SERVICES_WORK_EXECUTION_PHOTO_DESCRIPTION_REQUIRED`,
`SERVICES_WORK_EXECUTION_INSPECTION_NOT_ELIGIBLE`,
`SERVICES_WORK_EXECUTION_ALREADY_ACTIVE`,
`SERVICES_WORK_EXECUTION_TEAM_INVALID`,
`SERVICES_WORK_EXECUTION_EMPLOYEE_INVALID`,
`SERVICES_WORK_EXECUTION_MATERIAL_REQUEST_LINE_INVALID`), `401`, `403`.
Notes: Client may prefill work lines from the source Job Assignment; the
assignment itself is never mutated.

---

### Get Work Execution

Purpose: Read the execution aggregate with inherited context.
Method: `GET`
Path: `/api/v1/services/work-executions/{executionId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: any work execution view scope.
Supported Scope: ASSIGNED / TEAM / ALL.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: `executionId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: inherited context, derived line states, aggregate range.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: scope-checked; out-of-scope → `404`.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: execution aggregate including inherited context and read-only
checklist/points/material requirements/linked material requests.
Response Field Table: as Work Execution entity.
Errors: `401`, `403`, `404`.
Notes: Before-work photos are returned as Inspection-owned evidence and are not
mutable here.

---

### Update Work Execution

Purpose: Structural edit of an open execution (references + work lines +
material used + photo entries).
Method: `PATCH`
Path: `/api/v1/services/work-executions/{executionId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.workExecutions.edit`.
Supported Scope: Company (edit implies View All).
Required Employee Context: None / Not applicable.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `executionId` (uuid).
Query Parameters: None / Not applicable.
Request Body: same mutable fields as Create (`sourceInspectionId` immutable; all
child sets are the complete desired sets).
Request Field Table: as Create.
Server-Derived Fields: `version` increment, `searchText`, audit.
Business Validations: execution exists and is open (else
`SERVICES_WORK_EXECUTION_NOT_EDITABLE`); a started line may not be removed
(`SERVICES_WORK_EXECUTION_NOT_EDITABLE`); reference/child rules as Create.
Authorization / Object Scope Rules: company edit authority.
Transactional Side Effects: header + line/material/photo reconciliation +
attachment metadata + version + activity + outbox.
Activity Event: `services.workExecution.updated`.
Notification Side Effects: None / Not applicable.
Idempotency: same key is a no-op.
Concurrency: `version`; stale → `409 RECORD_VERSION_CONFLICT`.
Success Response: updated execution.
Response Field Table: as Work Execution entity.
Errors: `400`, `401`, `403`, `404`, `409`.
Notes: **Edit** is distinct from **Perform**: structural edits require `edit`;
timestamps, material used and photos require `perform`. Both are independently
enforced.

---

### Start Work Line

Purpose: Capture the authoritative start timestamp for an eligible line.
Method: `POST`
Path: `/api/v1/services/work-executions/{executionId}/lines/{lineId}/start`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.workExecutions.perform`.
Supported Scope: Company (perform implies View All) plus record scope.
Required Employee Context: Required for ASSIGNED/TEAM scope.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `executionId` (uuid), `lineId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable. (The server uses its authoritative clock;
arbitrary client start timestamps are not accepted.)
Request Field Table: None / Not applicable.
Server-Derived Fields: `startedAtUtc` (server clock, UTC); when the first line
starts, aggregate `status` becomes `inProgress` and `version` increments.
Business Validations: execution open (not completed/cancelled); line exists; line
not already started (`SERVICES_WORK_EXECUTION_LINE_ALREADY_STARTED`).
Authorization / Object Scope Rules: permission + record scope + company. A
perform grant alone does not permit performing every execution.
Transactional Side Effects: line timestamp + aggregate status/version +
activity + outbox (atomic, §16.4).
Activity Event: `services.workExecution.workStarted`.
Notification Side Effects: None / Not applicable (start/end are not notified, to
avoid spam).
Idempotency: repeat with the same key does not create a second timestamp/event.
Concurrency: only sets a NULL timestamp once; concurrent start → `409`.
Success Response: updated execution aggregate.
Response Field Table: as Work Execution entity.
Errors: `400`, `401`, `403`, `404`, `409`
(`SERVICES_WORK_EXECUTION_ALREADY_COMPLETED`, `SERVICES_WORK_EXECUTION_CANCELLED`,
`SERVICES_WORK_EXECUTION_LINE_NOT_FOUND`,
`SERVICES_WORK_EXECUTION_LINE_ALREADY_STARTED`).
Notes: Server time is authoritative; a correction workflow does not currently
exist.

---

### End Work Line

Purpose: Capture the authoritative end timestamp for a started line.
Method: `POST`
Path: `/api/v1/services/work-executions/{executionId}/lines/{lineId}/end`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.workExecutions.perform`.
Supported Scope: Company (perform implies View All) plus record scope.
Required Employee Context: Required for ASSIGNED/TEAM scope.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `executionId` (uuid), `lineId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `endedAtUtc` (server clock, UTC); `version` increments.
Business Validations: execution open; line exists; line started
(`SERVICES_WORK_EXECUTION_LINE_NOT_STARTED`); line not already ended
(`SERVICES_WORK_EXECUTION_LINE_ALREADY_ENDED`); `end >= start`
(`SERVICES_WORK_EXECUTION_INVALID_TIME_RANGE`).
Authorization / Object Scope Rules: permission + record scope + company.
Transactional Side Effects: line timestamp + version + activity + outbox.
Activity Event: `services.workExecution.workEnded`.
Notification Side Effects: None / Not applicable.
Idempotency: repeat is a no-op.
Concurrency: only sets a NULL timestamp once; concurrent end → `409`.
Success Response: updated execution aggregate.
Response Field Table: as Work Execution entity.
Errors: `400`, `401`, `403`, `404`, `409`.
Notes: Duration is derived, never stored.

---

### Add Material Used

Purpose: Add a Material Used record (code + description).
Method: `POST`
Path: `/api/v1/services/work-executions/{executionId}/materials-used`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.workExecutions.perform`.
Supported Scope: Company (perform implies View All) plus record scope.
Required Employee Context: Required for ASSIGNED/TEAM scope.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `executionId` (uuid).
Query Parameters: None / Not applicable.
Request Body:

```json
{ "id": "…", "sourceMaterialRequestLineId": "…", "code": "R-410A", "description": "Refrigerant" }
```

Request Field Table:

| Field | Type | Required | Nullable | Source | Description | Validation | Example |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | uuid | yes | no | client | Material-used identity | unique | `…` |
| `sourceMaterialRequestLineId` | uuid | no | yes | client | Optional lineage | line belongs to a request whose source inspection matches | `…` |
| `code` | string | yes | no | client | Code | non-empty | `R-410A` |
| `description` | string | yes | no | client | Description | non-empty | `Refrigerant` |

Server-Derived Fields: `companyId`, `lineNumber`, audit.
Business Validations: execution open; code/description non-empty; optional source
line valid for the execution’s source inspection.
Authorization / Object Scope Rules: permission + record scope + company.
Transactional Side Effects: insert + activity + outbox. **No** inventory/stock
side effect; **no** Material Request mutation.
Activity Event: `services.workExecution.materialUsedAdded`.
Notification Side Effects: None / Not applicable.
Idempotency: same `id` + key does not duplicate.
Concurrency: appended by `lineNumber`.
Success Response: updated execution aggregate.
Response Field Table: as Work Execution entity.
Errors: `400`, `401`, `403`, `404`, `409`.
Notes: Explicitly **no** Qty/UOM/Batch/Cost (TBD future inventory scope).

---

### Remove Material Used

Purpose: Remove a Material Used record from an open execution.
Method: `DELETE`
Path: `/api/v1/services/work-executions/{executionId}/materials-used/{materialUsedId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.workExecutions.perform`.
Supported Scope: Company (perform implies View All) plus record scope.
Required Employee Context: Required for ASSIGNED/TEAM scope.
Headers: Standard. `Idempotency-Key` recommended.
Path Parameters: `executionId` (uuid), `materialUsedId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: None / Not applicable.
Business Validations: execution open; record belongs to the execution.
Authorization / Object Scope Rules: permission + record scope + company.
Transactional Side Effects: delete child + activity + outbox. No inventory
side effect.
Activity Event: `services.workExecution.materialUsedRemoved`.
Notification Side Effects: None / Not applicable.
Idempotency: repeat delete is a no-op.
Concurrency: by material-used id.
Success Response: updated execution aggregate.
Response Field Table: as Work Execution entity.
Errors: `401`, `403`, `404`, `409`.
Notes: Material Used is an execution record, not a stock movement.

---

### Add Photo Entry

Purpose: Add an after-work photo evidence entry.
Method: `POST`
Path: `/api/v1/services/work-executions/{executionId}/photos`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.workExecutions.perform`.
Supported Scope: Company (perform implies View All) plus record scope.
Required Employee Context: Required for ASSIGNED/TEAM scope.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `executionId` (uuid).
Query Parameters: None / Not applicable.
Request Body:

```json
{ "id": "…", "description": "Completed unit", "attachments": [ { "id": "…", "fileName": "after.jpg", "displayName": "after.jpg", "mimeType": "image/jpeg", "sizeBytes": 600000, "category": "afterWorkPhoto" } ] }
```

Request Field Table:

| Field | Type | Required | Nullable | Source | Description | Validation | Example |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | uuid | yes | no | client | photo entry identity | unique | `…` |
| `description` | string | yes | no | client | Description | non-empty | `Completed unit` |
| `attachments[]` | array | no | yes | client | Photo metadata | `afterWorkPhoto`; validated per §17 | `[…]` |

Server-Derived Fields: `companyId`, `lineNumber`, `createdByUserId`, `createdAt`.
Business Validations: execution open; description non-empty; attachment
validation.
Authorization / Object Scope Rules: permission + record scope + company.
Transactional Side Effects: insert entry + attachment metadata + activity +
outbox.
Activity Event: `services.workExecution.photoAdded`.
Notification Side Effects: None / Not applicable.
Idempotency: same `id` + key does not duplicate.
Concurrency: appended by `lineNumber`.
Success Response: updated execution aggregate.
Response Field Table: as Work Execution entity.
Errors: `400`, `401`, `403`, `404`, `409`.
Notes: After-work photos are owned by the Work Execution (distinct from
before-work photos owned by the Inspection).

---

### Update Photo Entry Description

Purpose: Edit an after-work photo entry description.
Method: `PATCH`
Path: `/api/v1/services/work-executions/{executionId}/photos/{photoEntryId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.workExecutions.perform`.
Supported Scope: Company (perform implies View All) plus record scope.
Required Employee Context: Required for ASSIGNED/TEAM scope.
Headers: Standard. `Idempotency-Key` recommended.
Path Parameters: `executionId` (uuid), `photoEntryId` (uuid).
Query Parameters: None / Not applicable.
Request Body: `{ "description": "Updated" }`.
Request Field Table:

| Field | Type | Required | Nullable | Source | Description | Validation | Example |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `description` | string | yes | no | client | Description | non-empty | `Updated` |

Server-Derived Fields: `updatedAt`.
Business Validations: execution open; description non-empty; entry belongs to the
execution.
Authorization / Object Scope Rules: permission + record scope + company.
Transactional Side Effects: entry update + activity + outbox.
Activity Event: `services.workExecution.photoUpdated`.
Notification Side Effects: None / Not applicable.
Idempotency: repeat is a no-op.
Concurrency: by entry id.
Success Response: updated execution aggregate.
Response Field Table: as Work Execution entity.
Errors: `400`, `401`, `403`, `404`, `409`.
Notes: None / Not applicable.

---

### Remove Photo Entry

Purpose: Remove an after-work photo entry and its attachments.
Method: `DELETE`
Path: `/api/v1/services/work-executions/{executionId}/photos/{photoEntryId}`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.workExecutions.perform`.
Supported Scope: Company (perform implies View All) plus record scope.
Required Employee Context: Required for ASSIGNED/TEAM scope.
Headers: Standard. `Idempotency-Key` recommended.
Path Parameters: `executionId` (uuid), `photoEntryId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: None / Not applicable.
Business Validations: execution open; entry belongs to the execution.
Authorization / Object Scope Rules: permission + record scope + company.
Transactional Side Effects: remove attachments (soft) + delete entry + activity +
outbox.
Activity Event: `services.workExecution.photoRemoved`.
Notification Side Effects: None / Not applicable.
Idempotency: repeat delete is a no-op.
Concurrency: by entry id.
Success Response: updated execution aggregate.
Response Field Table: as Work Execution entity.
Errors: `401`, `403`, `404`, `409`.
Notes: None / Not applicable.

---

### Complete Work Execution

Purpose: Finalize a work execution once all lines are complete.
Method: `POST`
Path: `/api/v1/services/work-executions/{executionId}/complete`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.workExecutions.complete`.
Supported Scope: Company (complete implies View All) plus record scope.
Required Employee Context: Required for ASSIGNED/TEAM scope.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `executionId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `status=completed`, `version` increment, audit.
Business Validations: not already completed
(`SERVICES_WORK_EXECUTION_ALREADY_COMPLETED`); not cancelled
(`SERVICES_WORK_EXECUTION_CANCELLED`); ≥1 work line
(`SERVICES_WORK_EXECUTION_LINES_REQUIRED`); no invalid time range
(`SERVICES_WORK_EXECUTION_INVALID_TIME_RANGE`); all lines started+finished
(`SERVICES_WORK_EXECUTION_NOT_COMPLETABLE`).
Authorization / Object Scope Rules: permission + record scope + company.
Transactional Side Effects: status + version + activity + outbox.
Activity Event: `services.workExecution.completed`.
Notification Side Effects: None / Not applicable.
Idempotency: same key is a no-op.
Concurrency: `version`; stale → `409`.
Success Response: completed execution.
Response Field Table: as Work Execution entity.
Errors: `400`, `401`, `403`, `404`, `409`.
Notes: **Photos are not required** to complete (rule remains TBD).

---

### Cancel Work Execution

Purpose: Cancel an open execution (historical).
Method: `POST`
Path: `/api/v1/services/work-executions/{executionId}/cancel`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.workExecutions.cancel`.
Supported Scope: Company (cancel implies View All) plus record scope.
Required Employee Context: Required for ASSIGNED/TEAM scope.
Headers: Standard. `Idempotency-Key` required.
Path Parameters: `executionId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `status=cancelled`, `version` increment, audit.
Business Validations: not already cancelled
(`SERVICES_WORK_EXECUTION_CANCELLED`); not completed
(`SERVICES_WORK_EXECUTION_ALREADY_COMPLETED`).
Authorization / Object Scope Rules: permission + record scope + company.
Transactional Side Effects: status + version + activity + outbox.
Activity Event: `services.workExecution.cancelled`.
Notification Side Effects: None / Not applicable.
Idempotency: same key is a no-op.
Concurrency: `version`; stale → `409`.
Success Response: cancelled execution.
Response Field Table: as Work Execution entity.
Errors: `400`, `401`, `403`, `404`, `409`.
Notes: There is no hard delete; cancellation is a business status.

---

### Work Execution Summary

Purpose: Scope-aware work execution counts.
Method: `GET`
Path: `/api/v1/services/work-executions/summary`
Authentication: Bearer.
Company Context: Required.
Required Permission: any work execution view scope.
Supported Scope: ASSIGNED / TEAM / ALL.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `today` (company-local).
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: scope-aware.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: `{ "pendingCount": 2, "inProgressCount": 3, "completedTodayCount": 1, "totalCount": 18 }`.
Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `pendingCount` | integer | pending |
| `inProgressCount` | integer | in progress |
| `completedTodayCount` | integer | completed with execution date today |
| `totalCount` | integer | all in scope |

Errors: `401`, `403`.
Notes: None / Not applicable.

---

### Work Execution Source Context

Purpose: Restricted read-only source context from a selected completed inspection.
Method: `GET`
Path: `/api/v1/services/references/eligible-inspections/{inspectionId}/work-context`
Authentication: Bearer.
Company Context: Required.
Required Permission: `services.workExecutions.create`.
Supported Scope: Company.
Required Employee Context: None / Not applicable.
Headers: Standard.
Path Parameters: `inspectionId` (uuid).
Query Parameters: None / Not applicable.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: snapshot, classification, `materialReceived`,
`jobAssignmentLines[]`, `checklistItems[]`, `inspectedPoints[]`,
`materialRequirements[]`, `linkedMaterialRequests[]`, `materialRequestLines[]`.
Business Validations: inspection exists.
Authorization / Object Scope Rules: authorized by Work Execution Create.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: source context (read-only). None of it is independently
editable here.
Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `inspectionId`,`inspectionNumber`,`inspectionStatus` | | source |
| `jobAssignmentId`,`assignmentNumber` | | lineage |
| `enquiryId`,`enquiryNumber`,`customerName`,`customerMobile` | | lineage |
| `complaintTypeName`,`priorityName` | | classification |
| `materialReceived` | enum | inherited |
| `rootCauseName`,`chargeResponsibilityName`,`technicianName` | string? | labels |
| `jobAssignmentLines` | array | prefill source |
| `checklistItems` | array | read-only |
| `inspectedPoints` | array | read-only |
| `materialRequirements` | array | read-only |
| `linkedMaterialRequests` | array | read-only |
| `materialRequestLines` | array | copy source for Material Used |

Errors: `401`, `403`, `404`.
Notes: This endpoint does not grant full Inspection navigation.

---

### Work Execution Activity

Purpose: Structured activity for one execution.
Method: `GET`
Path: `/api/v1/services/work-executions/{executionId}/activity`
Authentication: Bearer.
Company Context: Required.
Required Permission: any work execution view scope.
Supported Scope: ASSIGNED / TEAM / ALL.
Required Employee Context: Required for ASSIGNED/TEAM.
Headers: Standard.
Path Parameters: `executionId` (uuid).
Query Parameters: `page`, `pageSize`.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: actor, `occurredAt`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: scope-checked.
Transactional Side Effects: None / Not applicable.
Activity Event: returns activity.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response: paginated activity entries.
Response Field Table: as Enquiry Activity.
Errors: `401`, `403`, `404`.
Notes: None / Not applicable.

## 28. Workflow / Lineage

The workflow is a **derived read model**, never a stored entity. Each stage
resolves to its own independently auditable transaction. There is deliberately no
workflow column/status in storage; the derived status is recomputed on every
read.

### 28.1 Chain

`Enquiry → Job Assignment → Inspection → Material Request (optional) → Work
Execution`.

### 28.2 Derived workflow status vocabulary

`awaitingAssignment`, `scheduled`, `inspectionPending`, `inspectionCompleted`,
`materialsRequested`, `workInProgress`, `workCompleted`, `cancelled`, `unknown`.

### 28.3 Node rules

- A node is `present` only when a real record exists **and** the caller is
  authorized to view it. A restricted record is indistinguishable from an absent
  one — no restricted data leaks through the timeline.
- The optional Material Request node is `optionalAbsent` (never “broken”) when no
  requirement is waiting and no request exists.
- `statusKey` is the underlying aggregate’s raw status wire value.

---

### Get Workflow Chain

Purpose: Resolve the full chain rooted at an enquiry.
Method: `GET`
Path: `/api/v1/services/enquiries/{enquiryId}/workflow`
Authentication: Bearer (§4).
Company Context: Required (§5).
Required Permission: The owning view permission **and** scope of each node,
re-checked per node: `services.enquiries.view` (all);
`services.jobAssignments.view*`; `services.inspections.view*`;
`services.materialRequests.view*`; `services.workExecutions.view*`.
Supported Scope: per node.
Required Employee Context: Required for ASSIGNED/TEAM nodes.
Headers: Standard (§8).
Path Parameters: `enquiryId` (uuid).
Query Parameters: `focus` (optional stage marker; never changes access).
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `status`, node presence, references, waiting material
count, record count, `allLinesComplete`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: each node re-checks its own permission/scope;
a restricted node is absent.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable (read).
Concurrency: Not applicable.
Success Response:

```json
{
  "success": true,
  "data": {
    "enquiryId": "…", "enquiryNumber": "ENQ-000120",
    "status": "materialsRequested",
    "nodes": [
      { "stage": "enquiry", "present": true, "id": "…", "reference": "ENQ-000120", "statusKey": "assigned", "cancelled": false },
      { "stage": "jobAssignment", "present": true, "id": "…", "reference": "JA-000045", "statusKey": "active", "cancelled": false },
      { "stage": "inspection", "present": true, "id": "…", "reference": "INS-000030", "statusKey": "completed", "cancelled": false, "waitingMaterialCount": 0 },
      { "stage": "materialRequest", "present": true, "id": "…", "reference": "MR-000010", "statusKey": "open", "cancelled": false, "recordCount": 1 },
      { "stage": "workExecution", "present": false, "id": null, "reference": null, "allLinesComplete": false }
    ]
  },
  "meta": { "requestId": "uuid", "serverTimeUtc": "…" }
}
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `enquiryId`,`enquiryNumber` | uuid/string | root |
| `status` | enum | derived workflow status |
| `nodes[].stage` | enum | enquiry/jobAssignment/inspection/materialRequest/workExecution |
| `nodes[].present` | boolean | real record + authorized |
| `nodes[].id`,`reference` | uuid?/string? | real values only |
| `nodes[].statusKey` | string? | raw aggregate status |
| `nodes[].cancelled` | boolean | cancelled marker |
| `nodes[].waitingMaterialCount` | integer | inspection waiting requirements |
| `nodes[].recordCount` | integer | linked requests |
| `nodes[].allLinesComplete` | boolean | execution gate |

Errors: `401`, `403`, `404`.
Notes: The backend mutations enforce the same transition rules independently; UI
availability is never the only source of truth.

---

### Get Workflow Activity

Purpose: Merged, authorization-filtered activity across the chain.
Method: `GET`
Path: `/api/v1/services/enquiries/{enquiryId}/workflow/activity`
Authentication: Bearer.
Company Context: Required.
Required Permission: same per-node view permissions as the chain.
Supported Scope: per node.
Required Employee Context: Required for ASSIGNED/TEAM nodes.
Headers: Standard.
Path Parameters: `enquiryId` (uuid).
Query Parameters: `page`, `pageSize`.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: ordered by `occurredAt` descending.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: only events from viewable nodes are returned.
Transactional Side Effects: None / Not applicable.
Activity Event: returns merged activity.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{ "success": true, "data": [ { "entityType": "serviceInspection", "entityId": "…", "eventType": "services.inspection.completed", "occurredAt": "2026-09-30T09:00:00Z", "actorUserId": "…", "actorEmployeeId": "…", "reference": "INS-000030", "metadata": { } } ], "meta": { "requestId": "uuid", "serverTimeUtc": "…" } }
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `entityType` | string | owning transaction |
| `entityId` | uuid | owning record |
| `eventType` | string | namespaced key |
| `occurredAt` | utc datetime | when |
| `actorUserId` | uuid | actor |
| `actorEmployeeId` | uuid? | actor employee |
| `reference` | string? | display number |
| `metadata` | object | typed context |

Errors: `401`, `403`, `404`.
Notes: Entries from restricted entities are omitted entirely.

---

## 29. Notifications

Services notifications are targeted, structured and localized at render time.
They carry IDs/deep-link metadata (never a stored client URL as authoritative
business data). Receiving a notification does **not** guarantee future read
access: the record endpoint rechecks permission/scope/company/module before
resolving the deep link.

### 29.1 Notification taxonomy (implemented by Services)

| Type | Trigger | Recipients | Dedupe key | Payload |
| --- | --- | --- | --- | --- |
| `serviceWorkAssigned` | Job Assignment created/updated | linked user accounts of directly assigned Employees and of assigned Team members + lead | `jobAssignment:{assignmentId}:{userId}` | `{ assignmentId }` |
| `serviceInspectionAssigned` | Inspection created/updated with a technician | the technician’s linked user account | `inspection:{inspectionId}:{userId}` | `{ inspectionId }` |
| Work Execution “ready” | documented intent only | — | — | **Not implemented** (see §29.3) |

### 29.2 Notification payload contract

| Field | Type | Description |
| --- | --- | --- |
| `type` | string | notification taxonomy value |
| `companyId` | uuid | owning company |
| `entityType` | string | `serviceJobAssignment` / `serviceInspection` |
| `entityId` | uuid | owning record |
| `transactionNumber` | string | business number |
| `recipientUserId` | uuid | target user account |
| `route` | object | structured deep-link metadata (`kind` + `id`), not authoritative |
| `priority` | enum | `low`/`normal`/`high` (normal for Services) |
| `dedupeKey` | string | dedupe identity |
| `createdAt` | utc datetime | when |

### 29.3 Work-execution-ready notification — not implemented

The workflow documentation describes a possible “Work Execution may notify the
relevant operational Employee when work is ready”, but the implemented code does
**not** emit any Work Execution notification. Building one would be an invention.
It is recorded here as **not implemented / TBD**, not as a requirement.

### 29.4 Endpoints

Notification delivery/listing is platform-level (out of Services scope). The
Services requirement is: when a Services mutation occurs, the backend MUST
persist/target the notification above using the platform notification model, and
MUST NOT expose restricted record data in the notification payload.

---

## 30. Reference Lookup APIs

Reference endpoints provide permission-safe, minimal-field selector data. They
MUST apply permission/scope **before** search so they cannot be used to enumerate
inaccessible records.

| Reference | Endpoint | Authorizing permission(s) | Fields |
| --- | --- | --- | --- |
| Customers | `GET /services/references/customers` | `services.customers.view` OR Enquiry create/edit | `id`, `customerCode`, `displayName`, `mobile` |
| Sites | `GET /services/references/sites` | `services.sites.view` OR Enquiry create/edit | `id`, `siteCode`, `displayName`, `customerId`, `customerName`, `locationSummary` |
| Employees | `GET /services/references/employees` | assignment/inspection/work-execution create/edit/perform | `id`, `name`, `employeeCode`, `departmentId`, `designationId`, `isActive` (no HR-private fields) |
| Service Teams | `GET /services/references/teams` | `services.teams.view` OR assignment/inspection/work-execution create/edit | `id`, `teamCode`, `displayName` |
| Eligible Enquiries | `GET /services/references/eligible-enquiries` | Job Assignment create/edit | `id`, `enquiryNumber`, `customerName`, `siteSummary`, classification labels |
| Eligible Job Assignments | `GET /services/references/eligible-job-assignments` | Inspection create/edit | `id`, `assignmentNumber`, `enquiryNumber`, `customerName`, `siteSummary`, `scheduledVisitDate` |
| Eligible Inspections | `GET /services/references/eligible-inspections` | Material Request create / Work Execution create (via `for`) | `id`, `inspectionNumber`, `customerName`, `siteSummary`, `visitDate`, variant counts |
| Configuration masters | `GET /services/references/configuration/{masterType}` | master `*.view` OR consuming create/edit | `id`, `code`, `name` |
| Master contexts | `…/context` variants | consuming create/edit | source context (see §23–§27) |

### 30.1 Reference access ≠ directory access

Selecting an Employee, Customer, Team or Master from a picker MUST NOT grant the
corresponding directory/manage capability. Reference endpoints are authorized by
the **consuming operation’s** create/edit/perform permission, never by the
referenced directory’s own view/manage permission, except where the same user
also holds that permission.

### 30.2 Employee reference endpoint

`GET /api/v1/services/references/employees`

- Required Permission: assignment/inspection/work-execution create/edit/perform.
- Returns only: `id`, `name`, `employeeCode`, `departmentId`, `designationId`,
  `isActive`.
- MUST NOT expose salary, personal documents, contact details or any HR-private
  field.
- Excludes inactive employees for new selection by default; historical
  references may include inactive.
- Company-scoped; other-company ids omitted.

Detailed format for this endpoint:

Purpose: Restricted employee selector for Services assignment.
Method: `GET`
Path: `/api/v1/services/references/employees`
Authentication: Bearer.
Company Context: Required.
Required Permission: Services assignment/inspection/work-execution
create/edit/perform.
Supported Scope: Company.
Required Employee Context: None / Not applicable (except perform scope checks
elsewhere).
Headers: Standard.
Path Parameters: None / Not applicable.
Query Parameters: `q`, `limit`, `ids` (repeatable, batch/historical), `includeInactive`.
Request Body: None / Not applicable.
Request Field Table: None / Not applicable.
Server-Derived Fields: `isActive`.
Business Validations: None / Not applicable.
Authorization / Object Scope Rules: consuming-operation permission; no HR
directory grant.
Transactional Side Effects: None / Not applicable.
Activity Event: None / Not applicable.
Notification Side Effects: None / Not applicable.
Idempotency: Not applicable.
Concurrency: Not applicable.
Success Response:

```json
{ "success": true, "data": [ { "id": "…", "name": "Ahmed Khan", "employeeCode": "EMP-000123", "departmentId": "…", "designationId": "…", "isActive": true } ], "meta": { "requestId": "uuid", "serverTimeUtc": "…" } }
```

Response Field Table:

| Field | Type | Description |
| --- | --- | --- |
| `id` | uuid | employee id |
| `name` | string | display name |
| `employeeCode` | string | code |
| `departmentId` | uuid? | display context only |
| `designationId` | uuid? | display context only |
| `isActive` | boolean | active flag |

Errors: `401`, `403`.
Notes: Employee reference access never equals HR Employee-directory access.

---

## 31. Sync Requirements

The client is local-first with an outbox. The backend must be compatible with
safe synchronization.

| Requirement | Detail |
| --- | --- |
| `requestId` | Every mutation carries a client `requestId`; the backend maps it to idempotent identity and echoes it in `meta.requestId`. |
| Idempotency | §14. Repeated sync of the same queued mutation must not duplicate records/children/sequences/activity/transitions. |
| Client UUIDs | The backend accepts client-supplied entity/child UUIDs as stable identity and returns the authoritative representation for reconciliation. |
| Server version | Every mutable transaction returns its `version`; the client stores it and sends it on the next mutation. |
| `updatedAt` | Returned as UTC ISO-8601; the client reconciles its local copy. |
| Soft cancellation | Cancel/command operations are business statuses; the backend never hard-deletes transaction records. |
| Conflict response | `409 RECORD_VERSION_CONFLICT` with the current authoritative record in `error.details.current`. |
| Sequence reconciliation | If a local provisional number was assigned, the backend returns the authoritative number; the client adopts it. |
| Ordering | Outbox operations may arrive out of order; the server must validate lineage/state at apply time and reject impossible sequences with a specific state conflict. |
| Partial sync | Child rows are reconciled by stable id within the aggregate transaction; a client must send the complete desired child set on structural update. |

### 31.1 Outbox operation mapping (implemented action keys)

The client enqueues these action keys; the backend should map them to the
corresponding endpoint. Entity types: `serviceCustomer`, `serviceSite`,
`serviceTeam`, configuration entity types, `serviceEnquiry`,
`serviceJobAssignment`, `serviceInspection`, `serviceMaterialRequest`,
`serviceWorkExecution`.

| Domain | Action keys |
| --- | --- |
| Customer | `SERVICES_CUSTOMER_CREATE`, `SERVICES_CUSTOMER_UPDATE`, `SERVICES_CUSTOMER_DEACTIVATE` |
| Site | `SERVICES_SITE_CREATE`, `SERVICES_SITE_UPDATE`, `SERVICES_SITE_DEACTIVATE` |
| Team | `SERVICES_TEAM_CREATE`, `SERVICES_TEAM_MEMBERS_UPDATE`, `SERVICES_TEAM_UPDATE` |
| Config | `SERVICES_SERVICE_TYPE_CREATE`, `SERVICES_COMPLAINT_TYPE_CREATE`, `SERVICES_PRIORITY_CREATE`, `SERVICES_TICKET_TYPE_CREATE`, `SERVICES_ROOT_CAUSE_CREATE`, `SERVICES_CHARGE_RESPONSIBILITY_CREATE`, `SERVICES_MATERIAL_REQUEST_PURPOSE_CREATE`, `SERVICES_CONFIG_UPDATE` |
| Enquiry | `SERVICES_ENQUIRY_CREATE`, `SERVICES_ENQUIRY_UPDATE`, `SERVICES_ENQUIRY_CANCEL` |
| Job Assignment | `SERVICES_JOB_ASSIGNMENT_CREATE`, `SERVICES_JOB_ASSIGNMENT_UPDATE`, `SERVICES_JOB_ASSIGNMENT_CANCEL` |
| Inspection | `SERVICES_INSPECTION_CREATE`, `SERVICES_INSPECTION_UPDATE`, `SERVICES_INSPECTION_COMPLETE`, `SERVICES_INSPECTION_CANCEL` |
| Material Request | `SERVICES_MATERIAL_REQUEST_CREATE`, `SERVICES_MATERIAL_REQUEST_UPDATE`, `SERVICES_MATERIAL_REQUEST_CANCEL` |
| Work Execution | `SERVICES_WORK_EXECUTION_CREATE`, `SERVICES_WORK_EXECUTION_UPDATE`, `SERVICES_WORK_EXECUTION_START_LINE`, `SERVICES_WORK_EXECUTION_END_LINE`, `SERVICES_WORK_EXECUTION_COMPLETE`, `SERVICES_WORK_EXECUTION_CANCEL` |

## 32. Endpoint Matrix

Master implementation checklist. Base: `/api/v1/services`. Scope column is the
supported record scope (`—` = not scope-based; `none` = company action
permission).

| # | Domain | Method | Path | Permission | Scope | Idempotent? | Purpose |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Overview | GET | `/overview` | per-section view | ASSIGNED/TEAM/ALL | n/a | operational dashboard |
| 2 | Overview | GET | `/overview/my-work` | view* | ASSIGNED | n/a | own queue |
| 3 | Customer | GET | `/customers` | `services.customers.view` | ALL | n/a | list |
| 4 | Customer | POST | `/customers` | `services.customers.create` | ALL | yes | create |
| 5 | Customer | GET | `/customers/{id}` | `services.customers.view` | ALL | n/a | detail |
| 6 | Customer | PATCH | `/customers/{id}` | `services.customers.edit` | ALL | yes | update |
| 7 | Customer | POST | `/customers/{id}/activate` | `services.customers.deactivate` | ALL | yes | activate |
| 8 | Customer | POST | `/customers/{id}/deactivate` | `services.customers.deactivate` | ALL | yes | deactivate |
| 9 | Customer | GET | `/references/customers` | view OR enquiry create/edit | ALL | n/a | reference |
| 10 | Site | GET | `/sites` | `services.sites.view` | ALL | n/a | list |
| 11 | Site | POST | `/sites` | `services.sites.create` | ALL | yes | create |
| 12 | Site | GET | `/sites/{id}` | `services.sites.view` | ALL | n/a | detail |
| 13 | Site | PATCH | `/sites/{id}` | `services.sites.edit` | ALL | yes | update |
| 14 | Site | POST | `/sites/{id}/activate` | `services.sites.deactivate` | ALL | yes | activate |
| 15 | Site | POST | `/sites/{id}/deactivate` | `services.sites.deactivate` | ALL | yes | deactivate |
| 16 | Site | GET | `/references/sites` | view OR enquiry create/edit | ALL | n/a | reference |
| 17 | Team | GET | `/teams` | `services.teams.view` | ALL | n/a | list |
| 18 | Team | POST | `/teams` | `services.teams.manage` | ALL | yes | create |
| 19 | Team | GET | `/teams/{id}` | `services.teams.view` | ALL | n/a | detail |
| 20 | Team | PATCH | `/teams/{id}` | `services.teams.manage` | ALL | yes | update/membership |
| 21 | Team | POST | `/teams/{id}/activate` | `services.teams.manage` | ALL | yes | activate |
| 22 | Team | POST | `/teams/{id}/deactivate` | `services.teams.manage` | ALL | yes | deactivate |
| 23 | Team | GET | `/teams/{id}/members` | `services.teams.view` | ALL | n/a | members |
| 24 | Team | GET | `/references/teams` | view OR tx create/edit | ALL | n/a | reference |
| 25 | Workforce | GET | `/references/employees` | tx create/edit/perform | ALL | n/a | restricted employee ref |
| 26 | Masters | GET | `/configuration/{masterType}` | master `*.view` | ALL | n/a | list |
| 27 | Masters | GET | `/references/configuration/{masterType}` | view OR consuming create/edit | ALL | n/a | reference |
| 28 | Masters | POST | `/configuration/{masterType}` | master `*.manage` | ALL | yes | create |
| 29 | Masters | GET | `/configuration/{masterType}/{id}` | master `*.view` | ALL | n/a | detail |
| 30 | Masters | PATCH | `/configuration/{masterType}/{id}` | master `*.manage` | ALL | yes | update |
| 31 | Masters | POST | `/configuration/{masterType}/{id}/activate` | master `*.manage` | ALL | yes | activate |
| 32 | Masters | POST | `/configuration/{masterType}/{id}/deactivate` | master `*.manage` | ALL | yes | deactivate |
| 33 | Enquiry | GET | `/enquiries` | `services.enquiries.view` | ALL | n/a | list |
| 34 | Enquiry | POST | `/enquiries` | `services.enquiries.create` | ALL | yes | create (+ lines + photos) |
| 35 | Enquiry | GET | `/enquiries/{id}` | `services.enquiries.view` | ALL | n/a | detail |
| 36 | Enquiry | PATCH | `/enquiries/{id}` | `services.enquiries.edit` | ALL | yes | update (+ reconciles lines) |
| 37 | Enquiry | POST | `/enquiries/{id}/cancel` | `services.enquiries.cancel` | ALL | yes | cancel |
| 38 | Enquiry | GET | `/enquiries/summary` | `services.enquiries.view` | ALL | n/a | summary |
| 39 | Enquiry | GET | `/references/eligible-enquiries` | `services.jobAssignments.create/edit` | none | n/a | assignable refs |
| 40 | Enquiry | GET | `/references/eligible-enquiries/{id}/context` | `services.jobAssignments.create/edit` | ALL | n/a | assignable context |
| 41 | Enquiry | GET | `/enquiries/{id}/job-assignment` | assignment view* | ASSIGNED/TEAM/ALL | n/a | integration |
| 42 | Enquiry | GET | `/enquiries/{id}/work-executions` | work-execution view* | ASSIGNED/TEAM/ALL | n/a | integration |
| 43 | Enquiry | GET | `/enquiries/{id}/activity` | `services.enquiries.view` | ALL | n/a | activity |
| 44 | Enquiry | GET | `/enquiries/{id}/workflow` | per-node view* | per node | n/a | workflow chain |
| 45 | Enquiry | GET | `/enquiries/{id}/workflow/activity` | per-node view* | per node | n/a | merged activity |
| 46 | Assignment | GET | `/job-assignments` | assignment view* | ASSIGNED/TEAM/ALL | n/a | list (+upcoming) |
| 47 | Assignment | POST | `/job-assignments` | `services.jobAssignments.create` | none | yes | create (+ enquiry→assigned) |
| 48 | Assignment | GET | `/job-assignments/{id}` | assignment view* | ASSIGNED/TEAM/ALL | n/a | detail |
| 49 | Assignment | PATCH | `/job-assignments/{id}` | `services.jobAssignments.edit` | none | yes | update |
| 50 | Assignment | POST | `/job-assignments/{id}/cancel` | `services.jobAssignments.cancel` | none | yes | cancel (+ enquiry reopen) |
| 51 | Assignment | GET | `/job-assignments/summary` | assignment view* | ASSIGNED/TEAM/ALL | n/a | summary |
| 52 | Assignment | GET | `/references/eligible-job-assignments` | `services.inspections.create/edit` | none | n/a | eligible refs |
| 53 | Assignment | GET | `/references/eligible-job-assignments/{id}/context` | `services.inspections.create/edit` | ALL | n/a | inspection context |
| 54 | Assignment | GET | `/job-assignments/{id}/inspection` | inspection view* | ASSIGNED/TEAM/ALL | n/a | integration |
| 55 | Assignment | GET | `/job-assignments/{id}/work-execution` | work-execution view* | ASSIGNED/TEAM/ALL | n/a | integration |
| 56 | Assignment | GET | `/job-assignments/{id}/activity` | assignment view* | ASSIGNED/TEAM/ALL | n/a | activity |
| 57 | Inspection | GET | `/inspections` | inspection view* | ASSIGNED/TEAM/ALL | n/a | list |
| 58 | Inspection | POST | `/inspections` | `services.inspections.create` | none | yes | create |
| 59 | Inspection | GET | `/inspections/{id}` | inspection view* | ASSIGNED/TEAM/ALL | n/a | detail |
| 60 | Inspection | PATCH | `/inspections/{id}` | `services.inspections.edit` | none | yes | update |
| 61 | Inspection | POST | `/inspections/{id}/complete` | `services.inspections.complete` | none | yes | complete |
| 62 | Inspection | POST | `/inspections/{id}/cancel` | `services.inspections.cancel` | none | yes | cancel |
| 63 | Inspection | GET | `/inspections/summary` | inspection view* | ASSIGNED/TEAM/ALL | n/a | summary |
| 64 | Inspection | GET | `/inspections/{id}/material-requests` | material-request view* | ASSIGNED/TEAM/ALL | n/a | integration |
| 65 | Inspection | GET | `/inspections/{id}/work-execution` | work-execution view* | ASSIGNED/TEAM/ALL | n/a | integration |
| 66 | Inspection | GET | `/inspections/{id}/activity` | inspection view* | ASSIGNED/TEAM/ALL | n/a | activity |
| 67 | Material Request | GET | `/material-requests` | material-request view* | ASSIGNED/TEAM/ALL | n/a | list |
| 68 | Material Request | POST | `/material-requests` | `services.materialRequests.create` | none | yes | create (+ waiting→requested) |
| 69 | Material Request | GET | `/material-requests/{id}` | material-request view* | ASSIGNED/TEAM/ALL | n/a | detail |
| 70 | Material Request | PATCH | `/material-requests/{id}` | `services.materialRequests.edit` | none | yes | update |
| 71 | Material Request | POST | `/material-requests/{id}/cancel` | `services.materialRequests.cancel` | none | yes | cancel (+ requested→waiting) |
| 72 | Material Request | GET | `/material-requests/{id}/print` | view* + `services.materialRequests.print` | ASSIGNED/TEAM/ALL | n/a | structured print data |
| 73 | Material Request | GET | `/material-requests/summary` | material-request view* | ASSIGNED/TEAM/ALL | n/a | summary |
| 74 | Material Request | GET | `/references/eligible-inspections` | `services.materialRequests.create` / `services.workExecutions.create` | none | n/a | eligible inspections |
| 75 | Material Request | GET | `/references/eligible-inspections/{id}/context` | `services.materialRequests.create` | ALL | n/a | source context |
| 76 | Material Request | GET | `/material-requests/{id}/activity` | material-request view* | ASSIGNED/TEAM/ALL | n/a | activity |
| 77 | Work Execution | GET | `/work-executions` | work-execution view* | ASSIGNED/TEAM/ALL | n/a | list |
| 78 | Work Execution | POST | `/work-executions` | `services.workExecutions.create` | none | yes | create |
| 79 | Work Execution | GET | `/work-executions/{id}` | work-execution view* | ASSIGNED/TEAM/ALL | n/a | detail |
| 80 | Work Execution | PATCH | `/work-executions/{id}` | `services.workExecutions.edit` | none | yes | structural edit |
| 81 | Work Execution | POST | `/work-executions/{id}/lines/{lineId}/start` | `services.workExecutions.perform` | none + record | yes | start work |
| 82 | Work Execution | POST | `/work-executions/{id}/lines/{lineId}/end` | `services.workExecutions.perform` | none + record | yes | end work |
| 83 | Work Execution | POST | `/work-executions/{id}/materials-used` | `services.workExecutions.perform` | none + record | yes | add material used |
| 84 | Work Execution | DELETE | `/work-executions/{id}/materials-used/{mid}` | `services.workExecutions.perform` | none + record | yes | remove material used |
| 85 | Work Execution | POST | `/work-executions/{id}/photos` | `services.workExecutions.perform` | none + record | yes | add photo entry |
| 86 | Work Execution | PATCH | `/work-executions/{id}/photos/{pid}` | `services.workExecutions.perform` | none + record | yes | edit photo description |
| 87 | Work Execution | DELETE | `/work-executions/{id}/photos/{pid}` | `services.workExecutions.perform` | none + record | yes | remove photo entry |
| 88 | Work Execution | POST | `/work-executions/{id}/complete` | `services.workExecutions.complete` | none + record | yes | complete |
| 89 | Work Execution | POST | `/work-executions/{id}/cancel` | `services.workExecutions.cancel` | none + record | yes | cancel |
| 90 | Work Execution | GET | `/work-executions/summary` | work-execution view* | ASSIGNED/TEAM/ALL | n/a | summary |
| 91 | Work Execution | GET | `/references/eligible-inspections/{id}/work-context` | `services.workExecutions.create` | ALL | n/a | source context |
| 92 | Work Execution | GET | `/work-executions/{id}/activity` | work-execution view* | ASSIGNED/TEAM/ALL | n/a | activity |
| 93 | Attachment | POST | `/attachments/upload-init` | owner mutation | owner scope | yes | init upload |
| 94 | Attachment | POST | `/attachments/{id}/complete` | owner mutation | owner scope | yes | complete upload |
| 95 | Attachment | GET | `/attachments/{id}` | owner view | owner scope | n/a | metadata |
| 96 | Attachment | GET | `/attachments` | owner view | owner scope | n/a | list by owner |
| 97 | Attachment | GET | `/attachments/{id}/content` | owner view | owner scope | n/a | download |
| 98 | Attachment | DELETE | `/attachments/{id}` | owner mutation | owner scope | yes | soft delete |

Total: **98 endpoint requirements** (configuration/directory 30; transaction 60
— of which command/operation 14 and reference/context 12; overview/dashboard 2;
attachment 6; see the completion report in §43.1).

---

## 33. Permission Matrix

Services permissions (exact implemented keys). “Employee link” = whether the
endpoint/scope requires a valid Employee reference.

| Permission key | Scope support | Employee link | Notes |
| --- | --- | --- | --- |
| `services.customers.view` | none (company directory) | no | list/detail/reference |
| `services.customers.create` | none | no | create |
| `services.customers.edit` | none | no | update |
| `services.customers.deactivate` | none | no | activate/deactivate |
| `services.sites.view` | none | no | list/detail/reference |
| `services.sites.create` | none | no | create |
| `services.sites.edit` | none | no | update |
| `services.sites.deactivate` | none | no | activate/deactivate |
| `services.teams.view` | none | no | list/detail/members/reference |
| `services.teams.manage` | none | no | create/update/members/status |
| `services.serviceTypes.view` / `.manage` | none | no | master |
| `services.complaintTypes.view` / `.manage` | none | no | master |
| `services.priorities.view` / `.manage` | none | no | master |
| `services.ticketTypes.view` / `.manage` | none | no | master |
| `services.rootCauses.view` / `.manage` | none | no | master |
| `services.chargeResponsibilities.view` / `.manage` | none | no | master |
| `services.materialRequestPurposes.view` / `.manage` | none | no | master |
| `services.enquiries.view` | `all` only | no | list/detail/summary/activity |
| `services.enquiries.create` | none | no | create + restricted refs |
| `services.enquiries.edit` | none | no | edit (OPEN) + restricted refs |
| `services.enquiries.cancel` | none | no | cancel (OPEN) |
| `services.jobAssignments.view` | `assigned`/`team`/`all` | yes (for assigned/team) | list/detail/summary/integration |
| `services.jobAssignments.create` | none | no | create |
| `services.jobAssignments.edit` | none | no | edit (ACTIVE) |
| `services.jobAssignments.cancel` | none | no | cancel (ACTIVE) |
| `services.inspections.view` | `assigned`/`team`/`all` | yes (for assigned/team) | list/detail/summary/integration |
| `services.inspections.create` | none | no | create |
| `services.inspections.edit` | none | no | edit (PENDING) |
| `services.inspections.complete` | none | no | complete (PENDING) |
| `services.inspections.cancel` | none | no | cancel (PENDING) |
| `services.materialRequests.view` | `assigned`/`team`/`all` | yes (for assigned/team) | list/detail/summary/print read |
| `services.materialRequests.create` | none | no | create |
| `services.materialRequests.edit` | none | no | edit (OPEN) |
| `services.materialRequests.cancel` | none | no | cancel (OPEN) |
| `services.materialRequests.print` | none | no | print |
| `services.workExecutions.view` | `assigned`/`team`/`all` | yes (for assigned/team) | list/detail/summary/integration |
| `services.workExecutions.create` | none | no | create |
| `services.workExecutions.edit` | none | no | structural edit (open) |
| `services.workExecutions.perform` | none (+ record scope) | yes (assigned/team) | start/end/material used/photos |
| `services.workExecutions.complete` | none (+ record scope) | yes (assigned/team) | complete |
| `services.workExecutions.cancel` | none (+ record scope) | yes (assigned/team) | cancel |

**No `SELF` scope** exists for Services transactions. `TEAM` is Service-Team
membership only. `ALL` is company only. `*Manage` implies `*View`.

---

## 34. Workflow Transition Matrix

| Entity | From | Gate / condition | Transition | Blocked when |
| --- | --- | --- | --- | --- |
| Enquiry | `OPEN` | authorized + no active assignment | create Job Assignment → `ASSIGNED` | cancelled; active assignment exists |
| Enquiry | `ASSIGNED` | — | (no direct downstream creation) | — |
| Enquiry | `ASSIGNED` | cancel, or last active assignment cancelled | → `OPEN` (reopened) | other active assignment remains |
| Enquiry | `OPEN` | cancel permission | → `CANCELLED` | already assigned? (no — cancel OPEN only) |
| Enquiry | `CANCELLED` | — | none | always |
| Job Assignment | `ACTIVE` | authorized | edit; create Inspection (if none) | cancelled; inspection already exists |
| Job Assignment | `ACTIVE` | cancel permission | → `CANCELLED` | already cancelled |
| Job Assignment | `CANCELLED` | — | none | always |
| Inspection | `PENDING` | authorized | edit / complete / cancel | completed/cancelled |
| Inspection | `PENDING` | complete rules satisfied | → `COMPLETED` | missing technician/visit time/root cause/charge/assessment |
| Inspection | `PENDING` | cancel permission | → `CANCELLED` | completed |
| Inspection | `COMPLETED` | waiting requirements + no active request | create Material Request | no waiting requirement / active request exists |
| Inspection | `COMPLETED` | no active execution | create Work Execution (regardless of materials) | active execution exists |
| Inspection | `CANCELLED` | — | none | always |
| Inspection Material Requirement | `WAITING` | included in active request | → `REQUESTED` | already `REQUESTED` |
| Inspection Material Requirement | `REQUESTED` | owning request cancelled | → `WAITING` | — |
| Material Request | `OPEN` | authorized | edit / print / cancel | cancelled |
| Material Request | `OPEN` | cancel permission | → `CANCELLED` (+ requirements → `WAITING`) | already cancelled |
| Material Request | `CANCELLED` | — | none | always |
| Work Execution | `PENDING` | perform permission + record scope | start a line → aggregate `IN_PROGRESS` | completed/cancelled |
| Work Execution | `IN_PROGRESS` | perform permission + record scope | start/end lines; edit children | completed/cancelled |
| Work Execution | `PENDING`/`IN_PROGRESS` | complete permission + all lines finished | → `COMPLETED` | no lines; invalid time range; incomplete lines |
| Work Execution | `PENDING`/`IN_PROGRESS` | cancel permission | → `CANCELLED` | completed |
| Work Execution Line | `NOT_STARTED` | start | → `IN_PROGRESS` (startedAt) | already started |
| Work Execution Line | `IN_PROGRESS` | end, end≥start | → `FINISHED` (endedAt) | not started; already ended |
| Work Execution | `COMPLETED`/`CANCELLED` | — | none (read-only) | always |

Note: Work Execution may begin **before** a Material Request exists — the
implementation does not block it (documented open question, §41).

---

## 35. Source-of-Truth Matrix

| Concept | Authoritative owner | Downstream read |
| --- | --- | --- |
| Material Received | **Enquiry** | Job Assignment / Inspection / Material Request / Work Execution (inherited read-only) |
| Customer historical snapshot | **Enquiry** | assignment / inspection / material request / work execution |
| Service classification (type/complaint/priority/ticket) | **Enquiry** | downstream inherited |
| Visit Date | **Job Assignment** | inspection (`scheduledVisitDate` prefill) |
| Assigned Employee / Service Team / Description For Work | **Job Assignment** | inspection/inspection technician candidates; work execution line prefill |
| Technician | **Inspection** | material request / work execution context |
| Root Cause | **Inspection** | work execution context |
| Charge Responsibility | **Inspection** | work execution context |
| Before Work Photos | **Inspection** (checklist item) | work execution detail (read-only) |
| Material Required | **Inspection** (material requirement) | material request (source requirement) |
| Requested Qty / Code / Description / Batch / Remark | **Material Request** | work execution material-used source (code/description) |
| Actual Start / End Time | **Work Execution** | derived line state / durations |
| Material Used (Code + Description) | **Work Execution** | none (no stock/inventory) |
| After Work Photos | **Work Execution** | none |
| Job Order | **TBD — external/future owner** | compatibility reference only |
| Quotation | **TBD — external/future owner** | compatibility reference only |
| Workflow stage/status | **Derived (no owner)** | recomputed per read |

### 35.1 API dependency map

```
Customer ──▶ Sites
Enquiry  ──▶ Customer/Site (+ snapshot), classification masters
Job Assignment ──▶ Enquiry (lineage + inherited context)
Inspection ──▶ Job Assignment (lineage) ──▶ Enquiry (derived)
Material Request ──▶ Inspection (lineage) ──▶ Assignment/Enquiry (derived)
Material Request Line ──▶ optional Inspection Material Requirement
Work Execution ──▶ Inspection (lineage) ──▶ Assignment/Enquiry (derived)
Work Execution Material Used ──▶ optional Material Request Line
Attachments ──▶ owning transaction (Enquiry detail / Inspection checklist / Work Execution photo entry)
Activity ──▶ owning transaction
Notification ──▶ owning transaction (assignment/inspection)
Workflow read model ──▶ all five transactions (authorization re-checked per node)
```

### 35.2 Workflow step → API usage matrix

| Client workflow step | Backend APIs used |
| --- | --- |
| Services Overview | `GET /overview` (+ optional per-domain summaries) |
| My Work | `GET /overview/my-work` |
| Customers list / detail / form | `GET/POST/PATCH /customers`, `/customers/{id}/activate|deactivate`, `/references/customers` |
| Sites list / detail / form | `GET/POST/PATCH /sites`, `/sites/{id}/activate|deactivate`, `/references/sites` |
| Teams list / detail / form | `GET/POST/PATCH /teams`, `/teams/{id}/members`, `/teams/{id}/activate|deactivate`, `/references/teams`, `/references/employees` |
| Services settings (masters) | `/configuration/{masterType}` CRUD + status, `/references/configuration/{masterType}` |
| Enquiries list | `GET /enquiries` |
| New Enquiry | `GET /references/customers`, `GET /references/sites?customerId=`, `GET /references/configuration/*` (classification), `POST /enquiries`, attachment upload |
| Enquiry detail | `GET /enquiries/{id}`, `GET /enquiries/{id}/activity`, attachments, `GET /enquiries/{id}/workflow`, `GET /enquiries/{id}/job-assignment`, `GET /enquiries/{id}/work-executions` |
| Enquiry edit / cancel | `PATCH /enquiries/{id}`, `POST /enquiries/{id}/cancel` |
| Job Assignment create | `GET /references/eligible-enquiries` (+ context), `GET /references/employees`, `GET /references/teams`, `POST /job-assignments` |
| Job Assignment detail/edit/cancel | `GET/PATCH /job-assignments/{id}`, `POST /job-assignments/{id}/cancel`, integration reads |
| Inspection create | `GET /references/eligible-job-assignments` (+ context), `GET /references/configuration/*`, `POST /inspections`, attachment upload |
| Inspection detail/edit/complete/cancel | `GET/PATCH /inspections/{id}`, `POST /inspections/{id}/complete|cancel`, integration reads |
| Material Request create | `GET /references/eligible-inspections?for=material-request` (+ context), `GET /references/configuration/material-request-purposes`, `POST /material-requests` |
| Material Request detail/edit/cancel/print | `GET/PATCH /material-requests/{id}`, `POST /material-requests/{id}/cancel`, `GET /material-requests/{id}/print` |
| Work Execution create | `GET /references/eligible-inspections?for=work-execution` (+ work-context), `POST /work-executions`, attachment upload |
| Work Execution detail/edit | `GET/PATCH /work-executions/{id}` |
| Work Execution perform | `POST .../lines/{lineId}/start|end`, `POST/DELETE .../materials-used`, `POST/PATCH/DELETE .../photos` |
| Work Execution complete/cancel | `POST /work-executions/{id}/complete|cancel` |
| Workflow timeline (any detail) | `GET /enquiries/{id}/workflow`, `GET /enquiries/{id}/workflow/activity` |
| Notifications | platform notification delivery (Services emits; §29) |

---

## 36. Error Code Catalog

`error.code` is a stable UPPER_SNAKE machine code.

### 36.1 Common / platform

| Code | HTTP | Meaning |
| --- | --- | --- |
| `UNAUTHENTICATED` | 401 | missing/invalid token |
| `FORBIDDEN` | 403 | authenticated but unauthorized |
| `SERVICES_PERMISSION_DENIED` | 403 | Services permission/scope denied |
| `SERVICES_MODULE_DISABLED` | 403 | company `services` module disabled |
| `COMPANY_SCOPE_MISMATCH` | 403/404 | record not in the authorized company |
| `VALIDATION_ERROR` | 400 | generic field validation |
| `SERVICES_INVALID_SORT` | 400 | disallowed sort key |
| `NOT_FOUND` | 404 | resource unavailable |
| `RECORD_VERSION_CONFLICT` | 409 | stale version |
| `INTERNAL_ERROR` | 500 | unexpected |

### 36.2 Directory / masters

| Code | HTTP | Meaning |
| --- | --- | --- |
| `SERVICES_CUSTOMER_NOT_FOUND` | 404 | customer missing |
| `SERVICES_CUSTOMER_REQUIRED` | 400 | name/mobile required |
| `SERVICES_CUSTOMER_INVALID_MOBILE` | 400 | invalid mobile |
| `SERVICES_CUSTOMER_INVALID_EMAIL` | 400 | invalid email |
| `SERVICES_CUSTOMER_DUPLICATE_MOBILE` | 409 | duplicate active mobile |
| `SERVICES_CUSTOMER_DUPLICATE_EMAIL` | 409 | duplicate active email |
| `SERVICES_CUSTOMER_DENIED` | 403 | customer permission denied |
| `SERVICES_SITE_NOT_FOUND` | 404 | site missing |
| `SERVICES_SITE_REQUIRED` | 400 | site name/address/city required |
| `SERVICES_SITE_CUSTOMER_REQUIRED` | 400 | customer required/not found |
| `SERVICES_SITE_DENIED` | 403 | site permission denied |
| `SERVICES_TEAM_NOT_FOUND` | 404 | team missing |
| `SERVICES_TEAM_REQUIRED` | 400 | team name required |
| `SERVICES_TEAM_DENIED` | 403 | team permission denied |
| `SERVICES_MASTER_NOT_FOUND` | 404 | master value missing |
| `SERVICES_MASTER_CODE_REQUIRED` | 400 | master code required |
| `SERVICES_MASTER_NAME_REQUIRED` | 400 | master name required |
| `SERVICES_MASTER_DUPLICATE_CODE` | 409 | duplicate master code/name |
| `SERVICES_CONFIG_DENIED` | 403 | configuration permission denied |

### 36.3 Enquiry

| Code | HTTP | Meaning |
| --- | --- | --- |
| `SERVICES_ENQUIRY_NOT_FOUND` | 404 | enquiry missing |
| `SERVICES_ENQUIRY_NOT_EDITABLE` | 409 | not OPEN |
| `SERVICES_ENQUIRY_ALREADY_CANCELLED` | 409 | already cancelled |
| `SERVICES_ENQUIRY_NOT_ASSIGNABLE` | 409 | not open / not eligible for assignment |
| `SERVICES_ENQUIRY_CUSTOMER_REQUIRED` | 400 | customer required |
| `SERVICES_ENQUIRY_SITE_REQUIRED` | 400 | site required |
| `SERVICES_ENQUIRY_SERVICE_TYPE_REQUIRED` | 400 | service type required |
| `SERVICES_ENQUIRY_COMPLAINT_TYPE_REQUIRED` | 400 | complaint type required |
| `SERVICES_ENQUIRY_PRIORITY_REQUIRED` | 400 | priority required |
| `SERVICES_ENQUIRY_TICKET_TYPE_REQUIRED` | 400 | ticket type required |
| `SERVICES_ENQUIRY_DETAILS_REQUIRED` | 400 | at least one detail line |
| `SERVICES_ENQUIRY_DETAIL_DESCRIPTION_REQUIRED` | 400 | line description required |
| `SERVICES_ENQUIRY_DESCRIPTION_TOO_LONG` | 400 | >4000 chars |
| `SERVICES_ENQUIRY_CUSTOMER_NOT_FOUND` | 400 | customer not found |
| `SERVICES_ENQUIRY_CUSTOMER_INACTIVE` | 400 | customer inactive |
| `SERVICES_ENQUIRY_SITE_NOT_FOUND` | 400 | site not found |
| `SERVICES_ENQUIRY_SITE_INACTIVE` | 400 | site inactive |
| `SERVICES_ENQUIRY_SITE_CUSTOMER_MISMATCH` | 400 | site not of customer |
| `SERVICES_ENQUIRY_SERVICE_TYPE_INVALID` | 400 | service type inactive/invalid |
| `SERVICES_ENQUIRY_COMPLAINT_TYPE_INVALID` | 400 | complaint type invalid |
| `SERVICES_ENQUIRY_COMPLAINT_TYPE_MISMATCH` | 400 | complaint/service type mismatch |
| `SERVICES_ENQUIRY_PRIORITY_INVALID` | 400 | priority invalid |
| `SERVICES_ENQUIRY_TICKET_TYPE_INVALID` | 400 | ticket type invalid |
| `SERVICES_ENQUIRY_SEQUENCE_FAILED` | 500 | sequence allocation failed |
| `SERVICES_ENQUIRY_PERMISSION_DENIED` | 403 | enquiry permission denied |

### 36.4 Job Assignment

| Code | HTTP | Meaning |
| --- | --- | --- |
| `SERVICES_ASSIGNMENT_NOT_FOUND` | 404 | assignment missing |
| `SERVICES_ASSIGNMENT_NOT_EDITABLE` | 409 | not ACTIVE |
| `SERVICES_ASSIGNMENT_ALREADY_CANCELLED` | 409 | already cancelled |
| `SERVICES_ASSIGNMENT_ALREADY_EXISTS` | 409 | active assignment already exists |
| `SERVICES_ASSIGNMENT_ENQUIRY_NOT_FOUND` | 400 | enquiry missing |
| `SERVICES_ASSIGNMENT_ENQUIRY_NOT_OPEN` | 400 | enquiry not open |
| `SERVICES_ASSIGNMENT_ENQUIRY_REQUIRED` | 400 | source enquiry required |
| `SERVICES_ASSIGNMENT_VISIT_DATE_REQUIRED` | 400 | visit date required |
| `SERVICES_ASSIGNMENT_LINES_REQUIRED` | 400 | at least one line |
| `SERVICES_ASSIGNMENT_WORK_REQUIRED` | 400 | work required |
| `SERVICES_ASSIGNMENT_WORK_TOO_LONG` | 400 | >500 chars |
| `SERVICES_ASSIGNMENT_DESCRIPTION_TOO_LONG` | 400 | >2000 chars |
| `SERVICES_ASSIGNMENT_TARGET_REQUIRED` | 400 | employee or team required |
| `SERVICES_ASSIGNMENT_EMPLOYEE_INVALID` | 400 | employee invalid |
| `SERVICES_ASSIGNMENT_TEAM_INVALID` | 400 | team invalid/inactive |
| `SERVICES_ASSIGNMENT_EMPLOYEE_NOT_IN_TEAM` | 400 | employee not a team member |
| `SERVICES_ASSIGNMENT_SEQUENCE_FAILED` | 500 | sequence allocation failed |
| `SERVICES_ASSIGNMENT_PERMISSION_DENIED` | 403 | permission denied |

### 36.5 Inspection

| Code | HTTP | Meaning |
| --- | --- | --- |
| `SERVICES_INSPECTION_NOT_FOUND` | 404 | inspection missing |
| `SERVICES_INSPECTION_NOT_EDITABLE` | 409 | not PENDING |
| `SERVICES_INSPECTION_NOT_COMPLETABLE` | 409 | missing completion prerequisites |
| `SERVICES_INSPECTION_NOT_CANCELLABLE` | 409 | completed cannot be cancelled |
| `SERVICES_INSPECTION_NOT_ELIGIBLE` | 409 | assignment not eligible |
| `SERVICES_INSPECTION_ALREADY_ACTIVE` | 409 | non-cancelled inspection exists |
| `SERVICES_INSPECTION_ALREADY_CANCELLED` | 409 | already cancelled |
| `SERVICES_INSPECTION_ASSIGNMENT_REQUIRED` | 400 | source assignment required |
| `SERVICES_INSPECTION_ASSIGNMENT_INVALID` | 400 | assignment missing/inactive |
| `SERVICES_INSPECTION_VISIT_DATE_REQUIRED` | 400 | visit date required |
| `SERVICES_INSPECTION_WORK_TYPE_REQUIRED` | 400 | checklist work type required |
| `SERVICES_INSPECTION_POINT_REQUIRED` | 400 | inspected point description required |
| `SERVICES_INSPECTION_MATERIAL_CODE_REQUIRED` | 400 | material code required |
| `SERVICES_INSPECTION_MATERIAL_DESCRIPTION_REQUIRED` | 400 | material description required |
| `SERVICES_INSPECTION_TECHNICIAN_INVALID` | 400 | technician not eligible |
| `SERVICES_INSPECTION_TECHNICIAN_REQUIRED` | 400 | technician required to complete |
| `SERVICES_INSPECTION_VISIT_TIME_REQUIRED` | 400 | visit time required to complete |
| `SERVICES_INSPECTION_ROOT_CAUSE_INVALID` | 400 | root cause invalid |
| `SERVICES_INSPECTION_ROOT_CAUSE_REQUIRED` | 400 | root cause required to complete |
| `SERVICES_INSPECTION_CHARGE_RESPONSIBILITY_INVALID` | 400 | charge responsibility invalid |
| `SERVICES_INSPECTION_CHARGE_RESPONSIBILITY_REQUIRED` | 400 | charge responsibility required |
| `SERVICES_INSPECTION_ASSESSMENT_REQUIRED` | 400 | checklist or point required |
| `SERVICES_INSPECTION_SEQUENCE_FAILED` | 500 | sequence allocation failed |

### 36.6 Material Request

| Code | HTTP | Meaning |
| --- | --- | --- |
| `SERVICES_MATERIAL_REQUEST_NOT_FOUND` | 404 | request missing |
| `SERVICES_MATERIAL_REQUEST_NOT_EDITABLE` | 409 | not OPEN |
| `SERVICES_MATERIAL_REQUEST_ALREADY_CANCELLED` | 409 | already cancelled |
| `SERVICES_MATERIAL_REQUEST_DENIED` | 403 | deny (incl. print without permission) |
| `SERVICES_MATERIAL_REQUEST_INSPECTION_REQUIRED` | 400 | source inspection required |
| `SERVICES_MATERIAL_REQUEST_INSPECTION_INVALID` | 400 | inspection missing/not completed |
| `SERVICES_MATERIAL_REQUEST_LINES_REQUIRED` | 400 | at least one line |
| `SERVICES_MATERIAL_REQUEST_CODE_REQUIRED` | 400 | code required |
| `SERVICES_MATERIAL_REQUEST_DESCRIPTION_REQUIRED` | 400 | description required |
| `SERVICES_MATERIAL_REQUEST_QUANTITY_REQUIRED` | 400 | quantity must be > 0 |
| `SERVICES_MATERIAL_REQUEST_REQUIREMENT_LINKED` | 409 | requirement already requested or linked to another active request |
| `SERVICES_MATERIAL_REQUEST_PURPOSE_INVALID` | 400 | purpose invalid/inactive |
| `SERVICES_MATERIAL_REQUEST_SEQUENCE_FAILED` | 500 | sequence allocation failed |
| `SERVICES_MATERIAL_REQUEST_PRINT_FAILED` | 500 | print data/PDF generation failed |

### 36.7 Work Execution

| Code | HTTP | Meaning |
| --- | --- | --- |
| `SERVICES_WORK_EXECUTION_NOT_FOUND` | 404 | execution missing |
| `SERVICES_WORK_EXECUTION_NOT_EDITABLE` | 409 | not open / started line removal |
| `SERVICES_WORK_EXECUTION_ALREADY_COMPLETED` | 409 | already completed |
| `SERVICES_WORK_EXECUTION_NOT_COMPLETABLE` | 409 | lines not all finished |
| `SERVICES_WORK_EXECUTION_CANCELLED` | 409 | cancelled |
| `SERVICES_WORK_EXECUTION_DENIED` | 403 | permission denied |
| `SERVICES_WORK_EXECUTION_INSPECTION_REQUIRED` | 400 | source inspection required |
| `SERVICES_WORK_EXECUTION_INSPECTION_NOT_ELIGIBLE` | 400 | inspection missing/not completed |
| `SERVICES_WORK_EXECUTION_ALREADY_ACTIVE` | 409 | non-cancelled execution exists |
| `SERVICES_WORK_EXECUTION_LINES_REQUIRED` | 400 | at least one line |
| `SERVICES_WORK_EXECUTION_WORK_REQUIRED` | 400 | work required |
| `SERVICES_WORK_EXECUTION_CODE_REQUIRED` | 400 | material code required |
| `SERVICES_WORK_EXECUTION_DESCRIPTION_REQUIRED` | 400 | material description required |
| `SERVICES_WORK_EXECUTION_PHOTO_DESCRIPTION_REQUIRED` | 400 | photo description required |
| `SERVICES_WORK_EXECUTION_TEAM_INVALID` | 400 | team invalid/inactive |
| `SERVICES_WORK_EXECUTION_EMPLOYEE_INVALID` | 400 | employee invalid |
| `SERVICES_WORK_EXECUTION_MATERIAL_REQUEST_LINE_INVALID` | 400 | source line not of the inspection |
| `SERVICES_WORK_EXECUTION_LINE_NOT_FOUND` | 404 | line missing |
| `SERVICES_WORK_EXECUTION_LINE_ALREADY_STARTED` | 409 | already started |
| `SERVICES_WORK_EXECUTION_LINE_NOT_STARTED` | 409 | cannot end before start |
| `SERVICES_WORK_EXECUTION_LINE_ALREADY_ENDED` | 409 | already ended |
| `SERVICES_WORK_EXECUTION_INVALID_TIME_RANGE` | 400 | end < start |
| `SERVICES_WORK_EXECUTION_SEQUENCE_FAILED` | 500 | sequence allocation failed |

### 36.8 Attachment / storage

| Code | HTTP | Meaning |
| --- | --- | --- |
| `ATTACHMENT_UNSUPPORTED_TYPE` | 400 | MIME not allowed |
| `ATTACHMENT_EMPTY_FILE` | 400 | zero/negative size |
| `ATTACHMENT_TOO_LARGE` | 400 | > 15 MiB |
| `ATTACHMENT_LIMIT_REACHED` | 409 | > 20 per owner |
| `SERVICES_STORAGE` | 500 | local/storage failure |

---

## 37. DTO Catalog

All DTOs are JSON. IDs are UUID strings; dates are `YYYY-MM-DD`; timestamps are
UTC ISO-8601; enums are stable lower-camel wire values.

| DTO | Fields |
| --- | --- |
| `ServiceCustomer` | id, companyId, customerCode, name, kind, mobile, alternateMobile, email, notes, status, siteCount, createdAt, updatedAt, createdByUserId, updatedByUserId |
| `ServiceCustomerRef` | id, customerCode, displayName, mobile |
| `ServiceSite` | id, companyId, customerId, siteCode, siteName, tenantName, buildingName, unitNumber, contactName, contactMobile, contactEmail, addressLine1, addressLine2, area, city, state, postalCode, countryCode, latitude, longitude, notes, status, createdAt, updatedAt, audit |
| `ServiceSiteRef` | id, siteCode, displayName, customerId, customerName, locationSummary |
| `ServiceTeam` | id, companyId, teamCode, name, description, leadEmployeeId, leadName, memberCount, status, createdAt, updatedAt, audit |
| `ServiceTeamMember` | employeeId, name, employeeCode, designationId, departmentId, isActive |
| `ServiceTeamRef` | id, teamCode, displayName |
| `WorkforcePersonRef` | id, name, employeeCode, departmentId, designationId, isActive |
| `ServiceMaster` | id, code, name, description, status, sortOrder, rank (priority), isDefault (priority), serviceTypeId (complaint type) |
| `ServiceEnquiry` | id, companyId, enquiryNumber, customerId, siteId, serviceTypeId, complaintTypeId, priorityId, ticketTypeId, materialReceived, status, partySnapshot, details[], cancelReason, cancelledAt, version, createdAt, updatedAt, audit, resolved labels |
| `ServiceEnquiryPartySnapshot` | customerName, customerCode, customerMobile, siteName, tenantName, buildingName, unitNumber, addressSummary, siteContactName, siteContactMobile |
| `ServiceEnquiryDetailLine` | id, lineNumber, description, status, attachments[] |
| `ServiceEnquiryListItem` | id, enquiryNumber, createdAt, customerName, customerMobile, siteName, serviceTypeName, complaintTypeName, priorityName, priorityRank, ticketTypeName, status |
| `ServiceEnquirySummary` | openCount, todayCount, highUrgentOpenCount, totalCount |
| `ServiceJobAssignment` | id, companyId, assignmentNumber, assignmentDate, sourceEnquiryId, scheduledVisitDate, status, lines[], version, createdAt, updatedAt, audit, enquiry context |
| `ServiceJobAssignmentLine` | id, lineNumber, work, assignedEmployeeId, assignedTeamId, status, descriptionForWork |
| `ServiceJobAssignmentListItem` | id, assignmentNumber, createdAt, scheduledVisitDate, status, enquiryNumber, customerName, customerMobile, siteSummary, priorityName, priorityRank, assignedSummary |
| `ServiceJobAssignmentSummary` | activeCount, todayCount, upcomingCount, totalCount |
| `AssignableEnquiryRef` | id, enquiryNumber, customerName, customerMobile, siteSummary, complaintTypeName, priorityName, priorityRank |
| `AssignableEnquiryContext` | enquiryId, enquiryNumber, customerName, customerMobile, priorityName, priorityRank, complaintTypeName, materialReceived, partySnapshot, details[] |
| `ServiceInspection` | id, companyId, inspectionNumber, inspectionDate, sourceJobAssignmentId, sourceEnquiryId, visitDate, visitMinutes, technicianEmployeeId, rootCauseId, chargeResponsibilityId, status, checklistItems[], inspectedPoints[], materialRequirements[], version, audit, context |
| `ServiceInspectionChecklistItem` | id, sourceJobAssignmentLineId, lineNumber, workType, descriptionForWork, status, attachments[] |
| `ServiceInspectionPoint` | id, lineNumber, description |
| `ServiceInspectionMaterialRequirement` | id, lineNumber, code, description, status |
| `ServiceInspectionListItem` | id, inspectionNumber, createdAt, visitDate, visitMinutes, status, assignmentNumber, enquiryNumber, customerName, siteSummary, technicianName, rootCauseName |
| `ServiceInspectionSummary` | pendingCount, todayCount, completedCount, totalCount |
| `ServiceInspectionRef` | id, inspectionNumber, status, visitDate, visitMinutes, technicianName, rootCauseName |
| `EligibleJobAssignmentRef` | id, assignmentNumber, enquiryNumber, customerName, customerMobile, siteSummary, scheduledVisitDate, priorityName |
| `InspectionSourceContext` | jobAssignmentId, assignmentNumber, enquiryId, enquiryNumber, customerName, customerMobile, priorityName, priorityRank, complaintTypeName, materialReceived, scheduledVisitDate, workLines[], eligibleTechnicians[] |
| `EligibleTechnicianRef` | id, name, employeeCode |
| `ServiceMaterialRequest` | id, companyId, requestNumber, requestDate, sourceInspectionId, sourceJobAssignmentId, sourceEnquiryId, jobOrderReference, purposeId, acknowledgement, receivedBy, remarks, status, lines[], totalQuantity, version, audit, context |
| `ServiceMaterialRequestLine` | id, sourceInspectionMaterialRequirementId, lineNumber, code, description, batchNumber, quantity, remark |
| `ServiceMaterialRequestListItem` | id, requestNumber, requestDate, createdAt, status, inspectionNumber, assignmentNumber, enquiryNumber, customerName, siteSummary, purposeName, preparedByUserId, itemCount, totalQuantity |
| `ServiceMaterialRequestSummary` | openCount, todayCount, lineCount, totalCount |
| `ServiceMaterialRequestRef` | id, requestNumber, status, requestDate, itemCount, totalQuantity |
| `EligibleInspectionRef` | id, inspectionNumber, assignmentNumber, enquiryNumber, customerName, siteSummary, visitDate, waitingRequirementCount |
| `MaterialRequestSourceContext` | inspectionId, inspectionNumber, inspectionStatus, jobAssignmentId, assignmentNumber, enquiryId, enquiryNumber, customerName, customerMobile, complaintTypeName, priorityName, materialReceived, technicianName, waitingRequirements[] |
| `MaterialRequestPrintDocument` | companyName, requestNumber, requestDate, inspectionNumber, assignmentNumber, enquiryNumber, customerName, customerMobile, siteSummary, materialReceived, jobOrderReference, purposeName, acknowledgement, receivedBy, remarks, preparedByUserId, lines[], totalQuantity |
| `ServiceWorkExecution` | id, companyId, executionNumber, executionDate, sourceInspectionId, sourceJobAssignmentId, sourceEnquiryId, jobOrderReference, quotationReference, status, workLines[], materialsUsed[], afterWorkPhotoEntries[], version, audit, context |
| `ServiceWorkExecutionLine` | id, sourceJobAssignmentLineId, lineNumber, work, description, serviceTeamId, employeeId, startedAtUtc, endedAtUtc, state (derived) |
| `ServiceWorkExecutionMaterialUsed` | id, sourceMaterialRequestLineId, lineNumber, code, description |
| `ServiceWorkExecutionPhotoEntry` | id, lineNumber, description, attachments[] |
| `ServiceWorkExecutionListItem` | id, executionNumber, executionDate, createdAt, status, inspectionNumber, assignmentNumber, enquiryNumber, customerName, siteSummary, assignedSummary, startedAtUtc, endedAtUtc |
| `ServiceWorkExecutionSummary` | pendingCount, inProgressCount, completedTodayCount, totalCount |
| `ServiceWorkExecutionRef` | id, executionNumber, status, executionDate, workLineCount, allLinesComplete, startedAtUtc, endedAtUtc |
| `EligibleInspectionWorkRef` | id, inspectionNumber, assignmentNumber, enquiryNumber, customerName, siteSummary, visitDate, technicianName |
| `WorkExecutionSourceContext` | inspectionId, inspectionNumber, inspectionStatus, jobAssignmentId, assignmentNumber, enquiryId, enquiryNumber, customerName, customerMobile, complaintTypeName, priorityName, materialReceived, rootCauseName, chargeResponsibilityName, technicianName, jobAssignmentLines[], checklistItems[], inspectedPoints[], materialRequirements[], linkedMaterialRequests[], materialRequestLines[] |
| `AttachmentRef` | id, companyId, ownerType, ownerId, category, fileName, displayName, mimeType, sizeBytes, uploadStatus, remoteUrl, checksum, createdAt, updatedAt |
| `ActivityEvent` | id, companyId, moduleKey, entityType, entityId, eventType, occurredAt, actorUserId, actorEmployeeId, metadata |
| `Notification` | type, companyId, entityType, entityId, transactionNumber, recipientUserId, route{kind,id}, priority, dedupeKey, createdAt |
| `WorkflowChain` | enquiryId, enquiryNumber, status, focus, nodes[] |
| `WorkflowNode` | stage, present, id, reference, statusKey, cancelled, waitingMaterialCount, recordCount, allLinesComplete |
| `ErrorEnvelope` | success=false, error{code,message,fieldErrors[],details}, meta |
| `PageMeta` | page, pageSize, totalItems, totalPages, filteredItems, requestId, serverTimeUtc |

---

## 38. Security Requirements

### 38.1 Server trust rules (server MUST NOT trust client)

| Never trust client-supplied | Server derives/verifies |
| --- | --- |
| company ownership (`companyId`) | active authorized company |
| `createdBy` / `updatedBy` | authenticated actor |
| derived enquiry ids | from source lineage |
| derived job assignment lineage | from source inspection |
| Customer context in downstream requests | from source enquiry snapshot |
| Material Received downstream | from source enquiry |
| scope decisions | from grants + relationship resolvers |
| workflow transition validity | server-enforced |
| document numbers | server sequence |
| record totals (`totalQuantity`) | server-derived sum |
| attachment ownership | owner existence + scope |

### 38.2 Mass-assignment allow-list

Only these fields are ever mutable per operation; arbitrary DTO→entity patching
is forbidden.

| Entity | Mutable on create | Mutable on update | Never mutable |
| --- | --- | --- | --- |
| Customer | name, kind, mobile, alternateMobile, email, notes | same | id, companyId, customerCode, status, audit |
| Site | customerId, siteName, tenantName, buildingName, unitNumber, contacts, address, coordinates, notes | same | id, companyId, siteCode, status, audit |
| Team | name, description, leadEmployeeId, memberIds | same | id, companyId, teamCode, status, audit |
| Master | code, name, description, sortOrder, serviceTypeId, rank, isDefault | same | id, companyId, status, audit |
| Enquiry | classification ids, materialReceived, details[] | same (OPEN) | id, companyId, enquiryNumber, partySnapshot (derived), status (via commands), audit |
| Job Assignment | scheduledVisitDate, lines[] | same (ACTIVE) | id, companyId, assignmentNumber, assignmentDate, sourceEnquiryId, status, audit |
| Inspection | visitDate, visitMinutes, technicianEmployeeId, rootCauseId, chargeResponsibilityId, checklistItems[], inspectedPoints[], materialRequirements[] | same (PENDING) | id, companyId, inspectionNumber, inspectionDate, source ids, status, audit |
| Material Request | jobOrderReference, purposeId, acknowledgement, receivedBy, remarks, lines[] | same (OPEN) | id, companyId, requestNumber, requestDate, source ids, status, totalQuantity, materialReceived, audit |
| Work Execution | jobOrderReference, quotationReference, workLines[], materialsUsed[], afterWorkPhotoEntries[] | same (open) | id, companyId, executionNumber, executionDate, source ids, status, started/ended timestamps (via perform), audit |

### 38.3 Search security

Reference/search endpoints apply permission + scope **before** search. Search
must never enumerate inaccessible records. Do not return total counts that reveal
records outside the caller’s scope.

### 38.4 Attachment security

Owner-resolved authorization (§17, §22). Knowing an attachment id never grants
access. MIME/size/count limits enforced server-side.

### 38.5 Audit API exposure

Do not expose sensitive internal audit data beyond the required fields. Activity
metadata must not contain restricted record data.

### 38.6 No role-based authorization

Never authorize by role name, designation, team name or department name. Explicit
permissions + scopes only (§6).

### 38.7 Restricted employee references

Employee reference endpoints return the permitted fields only (§30.2); no HR
directory grant is implied.

---

## 39. Performance / Indexing Requirements

### 39.1 Behavior

- Pagination on every list; no unbounded result sets.
- Batch/join list projections (avoid N+1 per row); the implemented list queries
  resolve labels via joins and batched child loads.
- Dashboard aggregates are computed with scope-aware aggregate queries, not by
  loading full lists.
- Scope filtering is applied in the query, not after.
- Attachment/child lookups support batch owner lookup.

### 39.2 Logical indexes (implemented)

| Table | Index |
| --- | --- |
| `service_customers` | `(company_id, status, name)` |
| `service_sites` | `(company_id, customer_id, status)` |
| `service_teams` | `(company_id, status, name)` |
| `service_team_members` | `(company_id, team_id, status)`, `(company_id, employee_id)` |
| `service_enquiries` | unique `(company_id, enquiry_number)`, `(company_id, status, created_at)`, `(company_id, created_at)`, `(company_id, customer_id)`, `(company_id, site_id)` |
| `service_enquiry_details` | `(company_id, enquiry_id, line_number)`, `(company_id, removed_at)` |
| `service_job_assignments` | `(company_id, status, scheduled_visit_date)`, `(company_id, source_enquiry_id)`, `(company_id, scheduled_visit_date)`, unique active `(company_id, source_enquiry_id) WHERE status='active'` |
| `service_job_assignment_lines` | `(company_id, assignment_id, line_number)`, `(company_id, assigned_employee_id)`, `(company_id, assigned_team_id)` |
| `service_inspections` | `(company_id, status, visit_date)`, `(company_id, source_job_assignment_id)`, `(company_id, source_enquiry_id)`, `(company_id, technician_employee_id)`, `(company_id, visit_date)`, unique active `(company_id, source_job_assignment_id) WHERE status <> 'cancelled'` |
| `service_material_requests` | `(company_id, status, request_date)`, `(company_id, source_inspection_id)`, `(company_id, source_job_assignment_id)`, `(company_id, source_enquiry_id)` |
| `service_material_request_lines` | `(company_id, material_request_id, line_number)`, unique active `(company_id, active_requirement_id) WHERE active_requirement_id IS NOT NULL` |
| `service_work_executions` | unique `(company_id, execution_number)`, `(company_id, status, execution_date)`, `(company_id, execution_date)`, `(company_id, source_inspection_id)`, `(company_id, source_job_assignment_id)`, `(company_id, source_enquiry_id)`, unique active `(company_id, source_inspection_id) WHERE status <> 'cancelled'` |
| `service_work_execution_lines` | `(company_id, work_execution_id, line_number)`, `(company_id, employee_id)`, `(company_id, service_team_id)` |
| child tables | `(company_id, parent_id, line_number)` per child |

### 39.3 Additional backend index guidance

- Normalized searchable text column per transaction (the implemented search
  concatenates number/customer/site/assignee fields) → index for `LIKE`.
- `(company_id, updated_at)` for sync/incremental pull.
- Activity `(company_id, entity_type, entity_id, occurred_at)`.
- Attachment `(company_id, owner_type, owner_id)` and
  `(company_id, owner_type, deleted_at)`.

Do not prescribe a specific DB engine; these are logical needs.

---

## 40. OpenAPI Implementation Notes

- Paths, DTO schemas, enum definitions, error schema and security schemes can be
  transcribed directly.
- Security scheme: HTTP bearer (`Authorization: Bearer`).
- Global parameters: `X-Company-Id` (header), `X-Request-Id` (header),
  `Idempotency-Key` (header, on mutations), `Accept-Language` (header).
- Common schemas: `SuccessEnvelope`, `PaginatedEnvelope`, `ErrorEnvelope`,
  `PageMeta`, `ActivityEvent`, `AttachmentRef`.
- Enumerations: `ConfigurationStatus`, `ServiceEnquiryStatus`, `MaterialReceived`,
  `ServiceEnquiryDetailStatus`, `ServiceJobAssignmentStatus`,
  `ServiceJobAssignmentLineStatus`, `ServiceInspectionStatus`,
  `ServiceInspectionChecklistStatus`, `ServiceInspectionMaterialStatus`,
  `ServiceMaterialRequestStatus`, `ServiceWorkExecutionStatus`,
  `ServiceWorkLineState`, `AttachmentCategory`, `AttachmentUploadStatus`.
- A full OpenAPI YAML is intentionally not generated here; it can be derived from
  this document on request.

---

## 41. Open Integration Questions / TBDs

These are preserved as **TBD**; do not invent behavior.

| # | Topic | State |
| --- | --- | --- |
| 1 | **Job Order** | Preserved as a free-text compatibility reference (`jobOrderReference`) on Material Request and Work Execution. Authoritative owner/source **not confirmed**. No Job Order API. |
| 2 | **Quotation** | Preserved as a free-text compatibility reference (`quotationReference`) on Work Execution. Authoritative owner/source **not confirmed**. No Quotation API. |
| 3 | **Acknowledge** | `acknowledgement` exists as optional metadata on Material Request. Full business semantics **not confirmed**. No acknowledgement command/status API. |
| 4 | **Received By** | `receivedBy` is optional free text. Identity type **not confirmed**; it is **not** an Employee FK. No relationship API. |
| 5 | **After-photo mandatory-ness** | After-work photos exist and are supported; whether a photo is **mandatory to complete** Work Execution is **TBD**. Completion does not currently require photos. |
| 6 | **Material Used Qty/UOM** | Material Used stores Code + Description only. Qty/UOM/Batch/Cost are **not** present and must not be added unless future Inventory scope is confirmed. |
| 7 | **Work Execution before Material Request** | Not blocked by implementation; both Create Material Request and Create Work Execution are offered when requirements are waiting. Whether this is the intended business rule is **TBD**. |
| 8 | **Service Reports** | Client navigation contains Service Reports but requirements are unavailable. **Not implemented / deferred**; no endpoints. |
| 9 | **SLA** | Priority does **not** imply SLA. No deadline fields or SLA policy. |
| 10 | **Billing** | Charge Responsibility is a classification master, **not** an invoice. No billing endpoints. |
| 11 | **Enquiry detail-line status vocabulary** | Only a minimal `open`/`closed` is modelled; exact vocabulary **TBD**; must not drive workflow. |
| 12 | **Job Assignment line status vocabulary** | Only `pending` is modelled; exact values **TBD**. |
| 13 | **Inspection checklist status vocabulary** | Only `pending` is modelled; exact values **TBD**. |
| 14 | **Charge Responsibility values** | Beyond confirmed examples, the full value set is **TBD**. |
| 15 | **Material Received business meaning** | Modelled as a header Yes/No; exact meaning at the Enquiry stage is **TBD**. No quantity/inventory semantics. |
| 16 | **Data retention** | **TBD / organization policy.** No retention period is invented. |
| 17 | **Reinspection / rework / multiple execution visits** | Not confirmed; V1 permits one non-cancelled execution per inspection. |
| 18 | **Work-execution-ready notification** | Documented intent only; **not implemented**. Do not build without confirmation. |
| 19 | **Work Time label** | Legacy “Work Time” label maps to line ordering (`lineNumber`); the reason for the legacy label is **TBD**. |
| 20 | **Customer/Site versioning** | Directory records have no explicit version column; if optimistic concurrency is added it must be documented. |

---

## 42. Completeness Checklist

### 42.1 Implemented operation coverage (no silent omission)

| Implemented operation / concept | Contract coverage |
| --- | --- |
| Customer watch/get/save/setActive/searchReferences/hasDuplicate | §19 (list/detail/create/update/activate/deactivate/reference) |
| Site watch/watchForCustomer/get/save/setActive/searchReferences | §20 |
| Team watch/get/save/setActive/watchMembers/searchReferences/getReferences | §21 |
| Master watchList/watchDetails/getById/save/setActive (7 kinds) | §22 |
| Enquiry watch/get/create/update/cancel/summary/recent/customer/site refs | §23 |
| Enquiry detail line persist/reconcile/soft-remove + photos | §23.3, §17 |
| Job Assignment watch/get/create/update/cancel/eligible refs/context/summary/upcoming/enquiry-integration | §24 |
| Inspection watch/get/create/update/complete/cancel/eligible refs/context/summary/recent/assignment-integration | §25 |
| Material Request watch/get/create/update/cancel/eligible refs/context/summary/recent/print/inspection-integration | §26 |
| Work Execution watch/get/create/update/start/end/add-remove material/add-update-remove photo/complete/cancel/eligible refs/context/summary/recent/integrations | §27 |
| Workflow chain/load/summary/activity | §28 |
| Overview load (metrics, recents, My Work) | §18 |
| Attachments (owner metadata, upload lifecycle) | §17 |
| Activity append/read | §16, §28 |
| Notifications (assignment/inspection) | §29 |
| Outbox action keys | §31.1 |
| Sequences (ENQ/JA/INS/MR/WE + CUS/SITE/TEAM) | §13 |
| Company time | §12 |
| Permission catalog (all keys) | §33 |
| Scope resolvers (ASSIGNED/TEAM/ALL per transaction) | §6.4–§6.6 |

### 42.2 Local-only / demo elements explicitly excluded

| Element | Why no endpoint |
| --- | --- |
| Demo seed data | Not a business feature; no API. |
| Workflow integrity validator | Development/test diagnostic; no API. |
| Client-local draft objects | Client form state; not a backend resource. |
| Local attachment upload queue | Client sync concern; backend sees upload-init/complete only. |
| Derived line state (`NOT_STARTED`/`IN_PROGRESS`/`FINISHED`) | Computed from timestamps; not a stored field. |
| Derived workflow status | Recomputed per read; not stored. |

### 42.3 Final quality checklist

- [x] Endpoint methods/paths consistent; base `/api/v1/services`.
- [x] Permissions documented are the real implemented `services.*` keys.
- [x] Scopes documented are real (ASSIGNED/TEAM/ALL; no SELF).
- [x] Company isolation explicit (§5, §38).
- [x] State transitions documented (§34).
- [x] Source lineage documented (§35).
- [x] Attachment ownership documented (§17, §35).
- [x] Idempotency documented (§14).
- [x] Audit/activity behavior documented (§16).
- [x] No excluded domain invented (Job Order/Quotation/Inventory/Billing/Service Reports).
- [x] Backend-facing body contains no client-framework terminology.
- [x] Request/response examples match DTO definitions.
- [x] Enquiry owns Material Received; downstream read-only/inherited.
- [x] Inspection owns Material Required; Material Request owns Requested; Work Execution owns Used.
- [x] Enquiry/Before/After photos have distinct ownership.
- [x] Optional Material Request branch supported.
- [x] Job Order / Quotation are compatibility references only.
- [x] All known TBDs preserved (§41).
- [x] Endpoint, permission, transition, source-of-truth and DTO/error catalogs present.

---

## 43. Internal Traceability Appendix

> This appendix is for internal engineering verification only. It is **not** part
> of the backend contract and must not be required to implement the API. It maps
> domain concepts to existing source locations.

| Domain concept | Implemented source (internal) |
| --- | --- |
| Services schema | `lib/modules/services/data/services_tables.dart`; `lib/core/database/app_database.dart` (schema v18, indexes) |
| Permission catalog | `lib/modules/services/access/services_permission_catalog.dart`; `lib/core/security/app_permission.dart` |
| Scope resolvers | `.../job_assignments/domain/service_job_assignment_scope.dart`, `.../inspections/domain/service_inspection_scope.dart`, `.../material_requests/domain/service_material_request_scope.dart`, `.../work_executions/domain/service_work_execution_scope.dart` |
| Directory repositories | `customers/data/local_service_customer_repository.dart`, `sites/data/local_service_site_repository.dart`, `teams/data/local_service_team_repository.dart`, `configuration/data/local_service_master_repository.dart` |
| Transaction repositories | `enquiries/data/local_service_enquiry_repository.dart`, `job_assignments/data/local_service_job_assignment_repository.dart`, `inspections/data/local_service_inspection_repository.dart`, `material_requests/data/local_service_material_request_repository.dart`, `work_executions/data/local_service_work_execution_repository.dart` |
| Workflow read model | `workflow/domain/service_workflow.dart`, `service_workflow_action.dart`, `service_workflow_validator.dart`; `workflow/data/local_service_workflow_repository.dart` |
| Overview / My Work | `overview/presentation/bloc/service_overview_cubit.dart` |
| Routes / module wiring | `module/services_routes.dart`, `services_module_registration.dart`, `services_dependencies.dart` |
| Workforce contract | `domain/contracts/workforce_directory.dart` |
| Attachments | `lib/shared/transactions/domain/attachment.dart`, `attachment_repository.dart` |
| Activity | `lib/shared/transactions/domain/activity_event.dart` |
| Document numbers | `lib/shared/transactions/domain/document_number.dart`, `document_number_service.dart` |
| Company time | `lib/modules/hr/attendance/domain/shift_workday_resolver.dart` (`CompanyTimeService`) |
| Notifications | `lib/platform/notifications/domain/app_notification.dart` |
| Auth context | `lib/platform/auth/domain/entities/auth_context.dart` |
| Print | `material_requests/application/service_material_request_print.dart` |
| Use cases | `enquiries/application/service_enquiry_use_cases.dart`, `job_assignments/application/service_job_assignment_use_cases.dart`, `inspections/application/service_inspection_use_cases.dart`, `material_requests/application/service_material_request_use_cases.dart`, `work_executions/application/service_work_execution_use_cases.dart` |
| Documentation | `docs/services/services_workflow.md`, `docs/services/client_reference_traceability.md`, `docs/services/phase_1..6_*.md`, `docs/architecture/permission_coverage.md`, `docs/architecture/services_module.md` |
| Demo data | `lib/modules/services/demo/services_demo_seed.dart` (not a backend feature) |

### 43.1 Final completion report

1. Output file: `docs/backend/services_backend_api_requirements.md`.
2. Domains covered: Overview; Customers; Sites; Teams; Configuration masters;
   Enquiries (+ detail lines + photos); Job Assignments; Inspections (+ checklist
   + before-work photos + inspected points + material requirements); Material
   Requests (+ lines + print); Work Executions (+ lines + material used +
   after-work photos); Workflow/lineage; Notifications; dashboard/summary
   queries; Attachments.
3. Total endpoint requirements: **98**.
4. Configuration/directory endpoints: 30 (customers 7, sites 7, teams 8,
   workforce 1, masters 7).
5. Transaction endpoints (enquiry 13, assignment 11, inspection 10, material
   request 10, work execution 16): 60.
6. Command/operation endpoints: 14 (cancels, completes, start/end, material
   used add/remove, photo add/update/remove).
7. Reference/context endpoints: 12 (dedicated `/references/*` selectors and
   source contexts).
8. Attachment requirements: 6 endpoints + ownership/authorization rules.
9. Permissions/scopes: all implemented `services.*` keys; ASSIGNED/TEAM/ALL
   semantics for the four operational transactions; no SELF.
10. Source-of-truth rules: §35.
11. Workflow transitions: §34.
12. Idempotency: §14.
13. Concurrency: §15.
14. Company isolation: §5, §38.
15. Audit/activity: §16.
16. Notification requirements: §29.
17. Dashboard requirements: §18.
18. Print requirements: §26 (Material Request Print Data).
19. TBDs preserved: §41 (20 items).
20. No Job Order APIs invented.
21. No Quotation APIs invented.
22. No Inventory APIs invented.
23. No Service Reports APIs invented.
24. Backend-facing body contains no client-framework implementation language
    (framework-specific names appear only in this appendix).







