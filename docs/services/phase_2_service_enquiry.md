# Services Phase 2 — Service Enquiry

Phase 2 adds the first real Services transaction: the **Service Enquiry**. It is
the company's unassigned incoming service queue. Job Assignment & Scheduling,
Inspection, Material Request, Work Execution, Quotation, Job Order and Customer
Portal are **not** implemented (see Deferred).

## Module structure

```text
lib/modules/services/enquiries/
  domain/        service_enquiry.dart, service_enquiry_repository.dart
  data/          local_service_enquiry_repository.dart
  application/   service_enquiry_use_cases.dart
  presentation/  bloc/service_enquiry_blocs.dart
                 pages/service_enquiry_list_page.dart
                 pages/service_enquiry_detail_page.dart
                 pages/service_enquiry_form_page.dart
lib/modules/services/presentation/widgets/
  service_reference_field.dart      (restricted async reference picker)
  recent_enquiries_section.dart     (Customer/Site detail integration)
```

## Domain model

`ServiceEnquiry` is a typed aggregate (a business transaction, not master data):

- `id` (UUID/internal identity) and `enquiryNumber` (company-scoped display
  number).
- Relationships by id: `customerId`, `siteId`, `serviceTypeId`,
  `complaintTypeId`, `priorityId`, `ticketTypeId`.
- `description`, `status`, `partySnapshot`, `cancelReason`, `cancelledAt`,
  `version`, timestamps, `createdByUserId`/`updatedByUserId`, `requestId`,
  `syncStatus`.

`ServiceEnquiryDraft` carries user-editable form data only; the UI never builds
Drift companions.

`ServiceEnquiryPartySnapshot` is a typed transaction-time snapshot persisted as
JSON. It preserves `customerName`/`customerCode`/`customerMobile` and
`siteName`/`tenantName`/`buildingName`/`unitNumber`/`addressSummary`/
`siteContactName`/`siteContactMobile`, so renaming or deactivating a Customer or
editing a Site later never makes a historical Enquiry misleading. The
Customer/Site **ids remain the authoritative relationship**; the snapshot is
display context only.

Read models: `ServiceEnquiryListItem` (list, no N+1), `ServiceEnquiryDetail`
(aggregate + resolved master labels), `ServiceEnquirySummary` (overview
aggregates), `ServiceEnquirySiteRef` (restricted site reference).

## State machine

```text
CREATE → OPEN
OPEN   ├── EDIT   → OPEN
       └── CANCEL → CANCELLED (terminal, historical, read-only)
```

No ASSIGNED/INSPECTED/MATERIAL_REQUESTED/COMPLETED states are created. A
successful create produces an OPEN enquiry (no separate DRAFT lifecycle).

## Sequence

The shared Phase 0.4 `DocumentNumberService` is reused with
`DocumentSequenceType.serviceEnquiry` (prefix `ENQ`). The display number
(`ENQ-000001`) is company-scoped and unique (`uniqueKeys {companyId,
enquiryNumber}` + a unique index). Formatting/padding/company scope live in the
shared infrastructure; the number is never the domain identity.

## Customer & Site references

- Customer is selected from the Phase 1 directory via a **restricted reference
  lookup** (`searchCustomerRefsForEnquiry`) authorized by Enquiry Create/Edit.
- Sites are loaded/search only for the selected Customer and only when active
  (`searchSiteRefsForEnquiry`), authorized by Enquiry Create/Edit.
- Changing the Customer clears the Site; a Site belonging to another Customer is
  rejected (`servicesEnquirySiteCustomerMismatch`).
- The form shows a compact Site preview (tenant/building/unit/address/contact)
  so operators never reopen Customer/Site detail screens.
- Customer/Site master contact data is never modified from the Enquiry form.

### Cross-permission rule

A user may hold `services.enquiries.create` without
`services.customers.view`/`services.sites.view`. They can still search and
select Customer/Site references (authorized by Enquiry Create/Edit), but they
**cannot** navigate the Customers/Sites directories or open arbitrary
Customer/Site detail. The Customer/Site repositories are not weakened globally.

## Permissions

Contributed by `services_permission_catalog.dart` (submodule `enquiries`) and
rendered automatically in Settings → Users & Access:

- `services.enquiries.view` (scope `all`)
- `services.enquiries.create`, `.edit`, `.cancel` (scope none)

`edit`/`cancel` imply `view` via `permissionViewDependencies`; `create` does not
(so a create-only operator is not given the company list). See
[permission_coverage.md](../architecture/permission_coverage.md).

## Routes

`/app/services/enquiries`, `/app/services/enquiries/new`,
`/app/services/enquiries/:enquiryId`,
`/app/services/enquiries/:enquiryId/edit` (plural only; no singular
`/enquiry`). `NavigationResolver.routeAccess` guards `/new` (create), `/edit`
(edit) and detail (view); typing a URL cannot bypass permission.

Navigation order: Overview, **Enquiries**, Customers, Sites, Teams, Settings.
Each destination is independently permission driven.

## Repository

`ServiceEnquiryRepository` / `LocalServiceEnquiryRepository`:

- `watchEnquiries(filter/sort/page)` — single joined query resolving master
  labels; searchable via `enquiry_number` + a denormalized `search_text`
  (customer name/mobile, site name, building, unit). Counts are computed with
  aggregate queries (no per-row fetches, no full-list counting in widgets).
- `getEnquiry` / `watchEnquiry` (view), `watchRecentEnquiries`,
  `watchEnquiriesForCustomer`, `watchEnquiriesForSite` (view).
- `createEnquiry`, `updateEnquiry`, `cancelEnquiry` (matching action
  permission).
- `searchCustomerRefsForEnquiry`, `searchSiteRefsForEnquiry`,
  `getCustomerRefForEnquiry`, `getSiteRefForEnquiry` (create/edit).
- `summary` — open / today / high-urgent-open / total counts.

Default sort is newest first (`created_at DESC, id DESC`). Filters: status,
service type, complaint type, priority, ticket type, created date range.

## Use cases

`CreateServiceEnquiry`, `UpdateServiceEnquiry`, `CancelServiceEnquiry`,
`GetServiceEnquiry`, `WatchServiceEnquiries` (application layer). Transaction
rules live in the repository, never in widgets.

Authorization (create/edit/cancel) checks: Services module enabled, matching
permission, same company, active Customer/Site, valid active masters, OPEN
status for edit/cancel.

## Atomicity, activity and outbox

Each mutation runs in **one database transaction**: sequence allocation +
insert/update + activity event + outbox operation. A failure leaves no partial
Enquiry.

- Activity events: `services.enquiry.created`, `.updated`, `.cancelled`
  (structured metadata: status, customerId, siteId, serviceTypeId, priorityId).
- Outbox operations: `SERVICES_ENQUIRY_CREATE`, `SERVICES_ENQUIRY_UPDATE`,
  `SERVICES_ENQUIRY_CANCEL`.
- Idempotency: `requestId` is persisted on the enquiry and used as the outbox
  `request_id` (unique). Repeating a create with the same request id returns the
  existing enquiry instead of creating a duplicate; repeated update/cancel are
  no-ops. `version` increments per mutation so a future backend can reject stale
  edits.
- Enquiries are never hard-deleted; cancel only changes status.

## Services Overview integration

`ServiceOverviewCubit` reuses `summary` + `watchRecentEnquiries` (never counts a
full list in the widget). Cards: Open Enquiries, Enquiries Today, High/Urgent
Open, plus the existing Customers/Sites/Teams cards. A compact **Recent
Enquiries** section links to detail. A **New enquiry** header action appears with
Enquiry Create. All Enquiry data is queried/rendered only when
`services.enquiries.view` is effective, so no Enquiry information leaks without
permission.

## Customer / Site detail integration

`ServiceRecentEnquiriesSection` renders a read-only "Recent enquiries" section
on Customer and Site detail **only** when the viewer has
`services.enquiries.view`. The host screens never depend on Enquiry permission
for their basic rendering.

## Backend-ready contract

Repository/domain shapes map cleanly to future endpoints: `GET enquiries`,
`GET enquiry detail`, `POST enquiry`, `PATCH enquiry`, `POST cancel`, restricted
Customer/Site reference search. No fake Dio calls are added.

## Next-phase integration contract (Phase 3)

Phase 3 (Job Assignment & Scheduling) may rely on an OPEN `ServiceEnquiry`'s:
`enquiryId`, `enquiryNumber`, Customer, Site, Service Type, Complaint Type,
Priority, Ticket Type, `description`, `status`, and created metadata. A Job
should reference `sourceEnquiryId` when it exists; no `jobId`/quotation/job-order
field is added to Enquiry now.

## Deferred (not guessed)

Assignment, scheduling, inspection, material request/issue, work execution,
quotation ownership, job order ownership, invoicing, payments, Customer Portal,
and full Tenant/Building/Unit property semantics.

## Tests

`test/services_phase2_test.dart` covers create/number/snapshot, request-id
idempotency, cross-customer/inactive/complaint-type validation, edit/cancel
state machine, no-delete, activity + outbox, view/create/edit permission gates,
company isolation, summary and recent/per-customer/per-site read models.
`test/services_phase1_test.dart` covers enquiry route guards and destination
visibility. `test/services_widget_test.dart` renders every Services screen
(including enquiry list/new/detail) on mobile and desktop.

## Phase 2.1 — client reference alignment

A re-review of the client's Enquiry reference showed the single
`complaintDetails` field was too aggressive a simplification. Phase 2.1 corrects
the model. See
[client_reference_traceability.md](client_reference_traceability.md) for the
field-by-field mapping (this document is authoritative for future phases).

### Detail aggregate

`ServiceEnquiry` is now a proper aggregate: a header plus `details[]` of typed
`ServiceEnquiryDetailLine` (stable UUID `id`, `lineNumber` order, `description`,
its own `status`, and photo `attachments`). The collection is normalized in a
`service_enquiry_details` table — never an untyped map or JSON column. One
enquiry supports 1..N lines; at least one meaningful line is required.

### Header vs detail status

- `ServiceEnquiry.status` — the transaction lifecycle (`open`/`cancelled`).
- `ServiceEnquiryDetailLine.status` — the per-line status from the client
  reference. **TBD — CLIENT CONFIRMATION:** the allowed vocabulary is unknown, so
  only a minimal, non-workflow-driving `open`/`closed` set is modelled. It must
  not drive future workflow transitions until confirmed.

### Material Received

Header flag `ServiceEnquiry.materialReceived` (`no`/`yes`), from the client
reference. **TBD:** the exact meaning at Enquiry stage requires client
confirmation. Modelled conservatively — no inventory, quantity, store workflow or
valuation.

### Photos / attachments

Each detail line owns zero-or-more photos via the shared Phase 0.4 attachment
foundation: `ownerType = serviceEnquiryDetail`, `ownerId = detailLineId`,
`category = problemPhoto`. Only metadata is stored (no image bytes/base64 in
Drift; no separate upload subsystem). Multiple files per line are supported
(shared limit 20, common image types + PDF). The picker is behind an
`AttachmentPicker` interface (default `file_selector`), so the UI/tests never
depend on a concrete plugin.

**Attachment access inherits Enquiry access:** attachments are only ever read
through an authorized enquiry read (`getEnquiry`/`watchEnquiry`, which require
`services.enquiries.view`); knowing an attachment id cannot bypass Enquiry
access. Attachments are reconciled atomically with the enquiry on save.

### Atomicity, activity, outbox

Create/update still run in one transaction and now also persist detail lines and
attachment metadata. The outbox payload (`SERVICES_ENQUIRY_CREATE` /
`SERVICES_ENQUIRY_UPDATE`) carries the header plus a `details` array
(`id`, `lineNumber`, `description`, `status`, `attachments[]` with
`id`/`fileName`/`mimeType`/`sizeBytes`/`category`) — never image bytes. Activity
remains a single structured aggregate event per mutation (metadata includes
`detailCount`), avoiding per-line event spam.

### Migration

Schema v14 adds `service_enquiry_details` and `service_enquiries.material_received`.
Existing Phase 2 enquiries are preserved: each legacy header `description` is
copied into a single detail line so no historical complaint text is lost.

