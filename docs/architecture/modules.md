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
policies, attendance reports, HR dashboard contribution) and, later, Finance,
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

## Dashboard ownership

There is **one** universal ERP Dashboard, owned by the neutral platform
workspace boundary at `lib/platform/workspace/dashboard/` (see
[universal_dashboard.md](universal_dashboard.md)). It is not owned by HR or
Services. The page renders only module-contributed, permission/scope-filtered
data; it never imports a module DAO, Drift table or bloc.

Business modules contribute content through the typed `DashboardContributor`
contract:

- HR: `lib/modules/hr/dashboard/application/hr_dashboard_contributor.dart`
  (reuses the HR dashboard read repository plus HR-owned attendance/leave
  widgets).
- Services:
  `lib/modules/services/overview/application/services_dashboard_contributor.dart`
  (reuses the Phase 9 Services read projection).
- Future Finance/Inventory modules register another contributor in
  `lib/app/module_registry/registered_modules.dart` without editing a switch.

The canonical route is `/app/dashboard`; `/app/hr` and `/app/services` redirect
to the first permitted feature of their module.

## Services: ownership

`lib/modules/services/` owns the Service Enquiry, Job Assignment, Inspection,
Material Request and Work Execution domains plus their settings. It contributes
Services content to the universal dashboard via
`ServicesDashboardContributor`; it no longer owns a separate Overview/Dashboard
page.

## Import direction

- `modules/hr/dashboard/` may import public domain/repository contracts from
  other HR sub-modules (`employees`, `attendance`, `leave`) because they are all
  inside HR. It contributes to the universal dashboard through
  `HrDashboardContributor`.
- `platform/workspace/dashboard/` must not import HR or Services DAOs/Drift
  internals; it depends only on the neutral contributor contract and the module
  public read contracts. The application composition root
  (`app/module_registry/`) wires the contributors.
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
