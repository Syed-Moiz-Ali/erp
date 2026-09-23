# ERP module boundaries and ownership

This document defines where code lives. Source ownership is independent of URL
architecture: a page's folder is decided by the business domain it represents,
not by its route name or by the screen name.

## Ownership rule

**Platform** — cross-module technical or product concerns that every module
uses. Examples: authentication/session, profile, notifications, sync/outbox,
workspace/shell behaviour.

**Business module** — domain-specific business functionality. Examples: HR
(employees, attendance, leave, holidays, shifts, work locations, attendance
policies, attendance reports, HR dashboard) and, later, Services, Finance,
Inventory, etc.

A folder called `dashboard` or `reports` does **not** automatically belong to
platform. Ownership follows the data and use cases the code actually contains.

## Current top-level layout

```text
lib/
  app/            # composition root, module registry, router, shell
  bootstrap/      # startup + DI orchestration
  core/           # cross-cutting technical foundations (db, security, sync, ...)
  design_system/  # shared UI primitives and theming
  l10n/           # common source ARBs + generated AppLocalizations
  shared/         # small cross-module domain/presentation contracts

  platform/
    auth/
    notifications/
    profile/
    sync/
    workspace/
    design_system_preview/
    l10n/         # platform_en.arb / platform_ar.arb
    module/       # platform destination + DI composition

  modules/
    hr/
      dashboard/
      employees/
      attendance/
      leave/
      shifts/
      work_locations/
      attendance_policies/
      reports/
      l10n/       # hr_en.arb / hr_ar.arb
      demo/       # HR demo seed data
      module/     # HR destination + DI composition, workforce adapter
    services/
      domain/contracts/   # cross-module contracts (WorkforceDirectory)
      l10n/               # services_en.arb / services_ar.arb
      module/             # Services destination + DI composition (empty today)
```

## Dashboard: current vs future ownership

**Current state.** The Dashboard is HR-owned: `lib/modules/hr/dashboard/`. It
consumes only workforce concerns (employees, attendance summaries, leave
summaries, HR persona/operational metrics) and its repository
(`LocalDashboardRepository`) queries HR data. Its destination is still
`/app/dashboard` and it is registered by the HR module so that a workforce
screen is not given fake platform ownership merely because its route is
`/app/dashboard`.

**Future state.** If several ERP modules must contribute to one combined landing
Dashboard, a thin platform composition layer may be introduced later, e.g.
`lib/platform/dashboard/` with a shell plus `DashboardContributor`
implementations in `lib/modules/hr/dashboard/` and
`lib/modules/services/dashboard/`. That composition is intentionally **not**
built yet; it will be introduced only when Services actually needs to
contribute data.

## Services: reserved ownership

`lib/modules/services/` exists as a foundation only (module registration, DI
no-ops and the `WorkforceDirectory` contract). Business capabilities such as
Service Enquiry, Scheduling, Inspection, Material Request, Work Execution, a
Services dashboard and Services reports are reserved for later phases. Do not
create empty placeholder folders; add `lib/modules/services/dashboard/` only
when real Services dashboard functionality exists.

## Import direction

- `modules/hr/dashboard/` may import public domain/repository contracts from
  other HR sub-modules (`employees`, `attendance`, `leave`) because they are all
  inside HR.
- `platform/` must not import HR dashboard implementation. The application
  composition root (`app/module_registry/`) may reference module destinations.
- `modules/services/` may depend on `platform/` contracts and its own
  `domain/contracts/` only; HR provides the `WorkforceDirectory` adapter.

## Shared transaction foundation

`lib/shared/transactions/` owns reusable infrastructure for future business
modules: company-scoped document numbering, attachment metadata, structured
activity events, the actor/company `TransactionContext`, and the atomic
`TransactionRunner`. Services consumes these; see
[transaction_foundation.md](transaction_foundation.md) and
[services_module.md](services_module.md). It is infrastructure only — no
business transaction tables are added in Phase 0.4.

## Localization ownership

Translation sources follow the same module boundaries. See
[localization.md](localization.md) for the source tree, merge workflow and key
ownership rules.
