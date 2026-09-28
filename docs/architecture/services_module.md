# Services module

`lib/modules/services/` is the business implementation of the Services chain.
Phases 1–6 are implemented: Customers, Sites, Service Teams, Services
configuration, Service Enquiry (with detail lines + photos + Material
Received), Job Assignment & Scheduling, Inspection (checklist, inspected points,
material requirements, before-work photos), Request for Material, and Work
Execution. The client-reference mapping lives in
[`../services/client_reference_traceability.md`](../services/client_reference_traceability.md).

```text
modules/services/
  domain/contracts/workforce_directory.dart   public workforce contract
  module/services_routes.dart                 ServicesRoutes (/app/services)
  module/services_module_registration.dart    buildServicesModules()
  module/services_dependencies.dart           ServicesModuleDependencies
  l10n/services_en.arb, services_ar.arb       Services localization source
  customers/, sites/, teams/, configuration/  directory + configuration
  enquiries/, job_assignments/, inspections/  enquiry → assignment → inspection
  material_requests/, work_executions/        material request → work execution
  overview/, presentation/                    overview + shared Services widgets
  demo/, access/                              demo seed + permission catalog
```

## Mandatory development rules

Every Services record must follow the shared foundation
([transaction_foundation.md](transaction_foundation.md)):

- **UUID internal identity** (`id`) plus a **generated display number**
  (`DocumentNumberService`), never a hand-typed key.
- **Company scoped** — all records, sequences, attachments and activity events
  carry `companyId` and never leak across tenants.
- **Typed status** — each aggregate owns its own status enum; no arbitrary
  strings and no universal `TransactionStatus`.
- **Domain transition methods** — widgets call `startWork()` /
  `completeInspection()`; they never assign `status = completed` directly, and
  invalid transitions fail with typed domain failures.
- **CompanyTimeService** for business dates; no raw `DateTime.now()`.
- **Structured activity events** via `ActivityRepository.append`; never store
  English sentences.
- **Generic attachment infrastructure** (`AttachmentRepository`); never create
  per-screen file tables or store bytes in Drift.
- **WorkforceDirectory** for employees/technicians; never import HR DAOs or
  presentation, and never create a duplicate technician person table.
- **Existing generic outbox** for sync; request-id idempotency for creates.
- **Atomic local writes** via `TransactionRunner` (record + sequence + activity +
  outbox in one transaction).
- **Module-first routes** under `/app/services/...` using `ServicesRoutes`
  builders; paths are not localized and never contain sensitive data.
- **Module-localization** — add Services strings to
  `modules/services/l10n/services_*.arb`, reuse `common` for generic vocabulary.

## Routes

Only `/app/services` is reserved. The implemented transactions add
`/app/services/enquiries`, `/app/services/job-assignments`,
`/app/services/inspections`, `/app/services/material-requests`,
`/app/services/work-executions`, the directory routes
(`/app/services/customers`, `/app/services/sites`, `/app/services/teams`) and
`/app/services/settings`.

## Unresolved client workflow questions

These are intentionally **not** solved by the infrastructure and must be
resolved during Services phases:

- Where does Quotation come from, and who owns it?
- Where does Job Order come from, and who owns it?
- Who approves a Material Request?
- Who issues stock?
- What is the inspector vs technician relationship?
- What are the exact Customer/Tenant/Building/Unit business semantics?
