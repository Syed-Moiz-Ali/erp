# Shared transaction foundation

Phase 0.4 establishes the reusable transaction infrastructure the Services module
(and later business modules) build on. It is infrastructure only: no Service
Enquiry, Job Assignment, Inspection, Material Request or Work Execution is
implemented here.

Code lives in `lib/shared/transactions/`:

```text
domain/   document_number.dart, document_number_service.dart, attachment.dart,
          attachment_repository.dart, activity_event.dart,
          transaction_context.dart, transaction_runner.dart
data/     transactions_tables.dart, local_document_number_service.dart,
          local_attachment_repository.dart, local_activity_repository.dart
transactions_dependencies.dart
```

## Internal ID vs display number

Every transaction uses two identities:

- `id` — stable UUID primary key (routes and references use this).
- `displayNumber` — human-readable, company-scoped business number such as
  `ENQ-000042`.

The display number is never the only identity. Records are creatable with a UUID
immediately; the display number can later be reconciled by the backend.

## Sequence generation

- `DocumentSequenceType` (`lib/shared/transactions/domain/document_number.dart`)
  is a typed identity carrying `key`, `prefix`, `padding` and `separator`
  (`serviceEnquiry` → `ENQ`, `serviceJob` → `JOB`, `serviceInspection` → `INS`,
  `materialRequest` → `MR`, `workExecution` → `EXEC`). Add a type only when a
  module owns it; do not add speculative Quotation/Job Order types.
- `DocumentNumberFormatter.format` is the single place that pads/joins the
  number. Widgets never build `prefix + padded number` strings.
- `LocalDocumentNumberService` (`DocumentNumberService`) generates the next
  number inside a Drift transaction, so concurrent local reservations cannot
  duplicate a number. Counters are scoped by `companyId` + `sequenceKey`
  (`document_sequences` table, unique index on both).
- `adoptServerNumber` reconciles the local counter with a server-assigned value
  (advances past any trailing integer). Local generation is deterministic but
  distributed uniqueness is ultimately a backend concern.

## Attachments / media

- `AttachmentRef` stores **metadata only** — `companyId`, `ownerType`,
  `ownerId`, `category`, file name/display name, MIME type, size, optional
  local path/remote URL/storage key/thumbnail/checksum, upload + sync status and
  actor/timestamps.
- **No file bytes are stored in Drift.** There is no BLOB/base64 column; files
  live on the local filesystem/cache and, later, backend/object storage. A test
  asserts the metadata table has no BLOB columns.
- `AttachmentCategory` is string-backed and typed (`problemPhoto`,
  `beforeWorkPhoto`, `afterWorkPhoto`, `supportingDocument`,
  `inspectionEvidence`, `signature`); raw values are never shown in the UI.
- `AttachmentValidation` centralizes allowed MIME types, max file size and
  per-owner count. Server-side verification remains authoritative.
- `AttachmentUploadStatus` (`localOnly`, `pendingUpload`, `uploaded`, `failed`,
  `pendingDelete`, `deleted`) supports offline capture: a local record and its
  attachment upload state are separable, so work is not lost when an upload
  fails.
- Owner references use `ownerType`/`ownerId` with repository-level integrity, not
  SQL foreign keys, because owners span future module tables. Queries always
  enforce company scope; knowing an attachment id is not enough to read another
  company's metadata.

## Activity / audit

- `BusinessActivityEvent` is append-only and structured: `moduleKey`,
  `entityType`, `entityId`, `eventType`, `occurredAt`, `actorUserId`,
  `actorEmployeeId?`, `summaryKey`, `metadata`, `requestId`, `syncStatus`.
- Events store **structured meaning**, never English sentences. `eventType` uses
  stable namespaced keys (`ActivityEventKeys.of('hr', 'leave', 'approved')` →
  `hr.leave.approved`; `services.enquiry.created`, `services.job.assigned`).
  Presentation maps the event to localized text.
- `ActivityRepository` exposes `watchForEntity` and `append` only — there is no
  update/delete path, so history is not rewritten to make current state look
  cleaner.
- **Audit vs activity.** Audit is technical accountability (who changed what);
  activity is the human-friendly business timeline. For V1 the structured
  activity event model serves both practical needs; it is not a
  regulatory-grade audit log.

## Transaction metadata convention

Future transactional records consistently carry: `id`, `companyId`,
`displayNumber`, `createdAt`, `updatedAt`, `createdByUserId`, `updatedByUserId`,
`requestId`/idempotency key, `syncStatus`, and a version/revision where needed.
No inheritance hierarchy is imposed; this is a documented convention.

- `createdBy`/`updatedBy` are derived from the authenticated session, never typed
  by users, and may be shown read-only in detail/activity views.
- `createdBy` is the **UserAccount** identity, not the Employee identity; an
  optional Employee reference is recorded only where business meaning requires
  it. Not every admin/HR user has an Employee record.

## Actor identity

`TransactionContext` (`companyId`, `actorUserId`, `actorEmployeeId?`,
`requestId`, `occurredAt`) is built with `TransactionContext.fromAuth`. UI must
never pass `createdByUserId` as an editable field, and generated display numbers
are read-only (manual override, if ever needed, requires a dedicated permission).

## Company time

Services reuse the existing `AppClock` and `CompanyTimeService`; no `ServiceClock`
is introduced and business logic must not use raw `DateTime.now()`. Persist
absolute timestamps in UTC; business dates use the company timezone.

- `createdAt`/`occurredAt` → instant (UTC).
- `visitDate` → company business date.
- `scheduledVisitAt` → company-local scheduled datetime, converted consistently.

Scheduling helpers are prepared as conventions only; no scheduling is built here.

## Workforce / technician contract

A technician is an existing Employee with Services eligibility — **not** a new
person table. `WorkforceDirectory`
(`lib/modules/services/domain/contracts/workforce_directory.dart`) is the public
contract Services consumes; `HrWorkforceDirectory`
(`lib/modules/hr/module/workforce_directory_adapter.dart`) is the HR adapter.
Services never imports HR Drift tables, DAOs or presentation.

- `getEmployeeReference(id, {includeInactive})` — historical lookups resolve
  inactive/terminated employees when `includeInactive: true`.
- `searchAssignable({query, limit})` — active, company-scoped employees eligible
  for new assignment.
- `watchAssignableEmployees({query})` — reactive picker variant.
- All queries are company-scoped; cross-company employee ids do not resolve.

Technician eligibility rules (permission, skill, team, availability) belong to
Services Phase 1/3; Phase 0.4 only creates the seam.

## Cross-module references

- Use a lightweight domain-specific ref (`WorkforcePersonRef`, future
  `CustomerRef`, `ServiceSiteRef`) rather than duplicating display fields.
  Introduce a generic `EntityReference` only if several modules genuinely
  benefit.
- **Reference vs snapshot.** Use a reference for the current linked object; take
  a snapshot of historical values that must not change retroactively (for
  example a customer display name/contact captured at enquiry creation). Actual
  snapshot needs are decided per Services feature.

## Typed status

Records never use arbitrary `String status`. Each aggregate owns its own typed
enum (`ServiceEnquiryStatus`, `ServiceJobStatus`, ...) — there is no universal
`TransactionStatus`. Transitions belong to domain/application logic
(`startWork()`, `completeInspection()`), invalid transitions fail with typed
domain failures, and important transitions append a `BusinessActivityEvent`.

## Outbox / idempotency

The existing generic outbox (`core/sync`) remains the sync mechanism; no
`ServiceOutbox` is created. Future mutations carry `requestId`, `companyId`,
`entityId`, operation type, payload/version, `createdAt` and sync state. Operation
keys are stable and namespaced (`SERVICES_ENQUIRY_CREATE`,
`SERVICES_JOB_ASSIGN`). User double-clicks must not create duplicate records:
create use cases use request-id idempotency (the outbox already has a unique
`request_id` index).

## Atomic local write

`TransactionRunner` (`LocalTransactionRunner`) runs a local write inside one
Drift transaction. A future Service Enquiry create performs, atomically:
generate UUID → reserve display sequence → insert record → insert activity event
→ insert outbox mutation → commit. If any step fails, no half-created record
remains.

## Database

Schema version is **9** (was 8). Migration adds three infrastructure tables and
their indexes:

- `document_sequences` — unique `(company_id, sequence_key)`.
- `attachment_records` — index `(company_id, owner_type, owner_id)`.
- `business_activity_events` — index `(company_id, entity_type, entity_id, occurred_at)`.

No Service business tables are added, and a fresh database contains no fake
Service records. Existing HR/platform data is preserved.

## Localization

Generic infrastructure strings (`Created by`, `Updated by`, `Upload failed`,
`Retry upload`) belong to the `common`/`platform` source ARBs, not Services. No
Services business copy is added in this phase.
