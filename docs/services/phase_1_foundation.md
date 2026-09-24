# Services Phase 1 — Foundation

Services Phase 1 is the first business implementation of the Services module:
the operational directory, teams and configuration needed before Service Enquiry.
No transactional Services feature (Enquiry, Job Assignment, Scheduling,
Inspection, Material Request, Work Execution) is implemented.

## Module structure

```text
lib/modules/services/
  access/            services_permission_catalog.dart
  configuration/     domain/ data/ presentation/   (4 masters)
  customers/         domain/ data/ presentation/
  sites/             domain/ data/ presentation/
  teams/             domain/ data/ presentation/
  overview/          presentation/
  demo/              services_demo_seed.dart
  module/            services_module_registration.dart
                     services_dependencies.dart
                     services_routes.dart
  domain/contracts/  workforce_directory.dart
  l10n/              services_en.arb, services_ar.arb
  services_module.dart
```

All Services code lives under `lib/modules/services/`; nothing is placed in HR or
in `lib/features/`.

## Customer model

`ServiceCustomer` — `id` (UUID), `companyId`, `customerCode` (`CUS-000001`),
`name`, `kind` (`individual|organization`), `mobile`, optional `alternateMobile`,
`email`, `notes`, `status` (`active|inactive`), timestamps and
`createdByUserId`/`updatedByUserId`/`syncStatus`. Codes come from the shared
`DocumentNumberService`; the UUID is the identity. Customers are deactivated, not
hard-deleted. `ServiceCustomerRef` is the lightweight selector contract.

## ServiceSite model

`ServiceSite` — belongs to a `ServiceCustomer`; `siteCode` (`SITE-000001`),
`siteName`, optional `tenantName`/`buildingName`/`unitNumber`, local contact,
address fields, optional `latitude`/`longitude`, `status`. Customer name/mobile
are never duplicated as authoritative site fields.

### Tenant / Building / Unit decision

The client's old ERP references Tenant/Building/Unit, but the property-management
semantics are **not confirmed**. Phase 1 stores `tenantName`, `buildingName` and
`unitNumber` as optional **site attributes**. There is deliberately no Tenant,
Building, Unit, leasing, rent or contract domain yet. See "Deferred".

## Service Team architecture

`ServiceTeam` (code `TEAM-000001`, optional `leadEmployeeId`) groups existing
**Employees** via `ServiceTeamMember` (`companyId + teamId + employeeId` unique).
A team is **not** an HR Department; an employee may be in a department and in
several Service Teams. An employee may belong to multiple teams.

- Technician is **not** a person/table: it is an Employee + future Services
  permissions + future job assignment. No `Technician`/`InspectorPerson` exists.
- Members are resolved through the cross-module `WorkforceDirectory` contract
  (`getEmployees`, `searchAssignable`); Services never imports HR DAO, Drift
  tables or presentation BLoCs. Only active employees are selectable for new
  membership; inactive members remain resolvable.
- **Team membership ≠ permission** and **permission ≠ team membership.** Adding an
  employee to a team does not grant Services access; granting Services access does
  not add a team member.

### ServiceTeamScopeResolver foundation

TEAM scope for future Service records will resolve from permission scope `team`
plus Service Team membership/supervision. It is **not used for transactions yet**
because jobs do not exist; the membership model above is the foundation.

## Masters

`ServiceType`, `ComplaintType` (optional `serviceTypeId`), `ServicePriority`
(`rank`, `isDefault`) and `ServiceTicketType` — company-scoped, code + name +
description + sort order + status. Typed records (no generic string map). Manage
implies view via `permissionViewDependencies`. Inactive masters remain resolvable
historically and are excluded from new selectors.

## Permissions

Contributed by `services_permission_catalog.dart` and rendered automatically in
Settings → Users & Access (no Access-UI changes):

- Customers: `services.customers.view|create|edit|deactivate`
- Sites: `services.sites.view|create|edit|deactivate`
- Teams: `services.teams.view|manage`
- Configuration: `services.serviceTypes.*`, `services.complaintTypes.*`,
  `services.priorities.*`, `services.ticketTypes.*` (view/manage)

All are gated by the company `services` feature flag. See
[permission_coverage.md](../architecture/permission_coverage.md).

## Routes

`/app/services` (Overview), `/app/services/customers[/new|/:id|/:id/edit]`,
`/app/services/sites[...]`, `/app/services/teams[...]`,
`/app/services/settings[/service-types|/complaint-types|/priorities|/ticket-types]`.
One primary Services destination; the rest are internal destinations.

## Navigation & information architecture

The shell navigation groups every destination by its owning **business module**
(`NavigationSection`: Human resources, Services, Settings, Account) so it is
always clear which module an item belongs to. This replaces the earlier
fine-grained group labels in the sidebar and the mobile *More* page; the
desktop sidebar renders a module header above each section and Account stays
pinned at the bottom. `NavigationSection` is derived from the destination's
module id via `navigationSectionOf`, so a new module automatically gets its own
section without touching the shell.

## Screen standards

Customers, Sites and Teams share one presentation standard on both compact
(mobile) and expanded (desktop) layouts:

- List: `AppPage` header with a record-count subtitle and an add action, an
  `AppToolbar` (search + `AppFilterBar` status chips), a desktop `AppDataTable`
  (leading avatar, row selection, `AppActionMenu`) or compact
  `AppMobileRecordCard` list, plus skeleton/error/empty states with retry.
- Detail: a hero card (avatar, name, status), `AppFormSection` +
  `AppDetailsGrid` fact sections, `AppSettingsSection` related rows and a
  localized `AppActivityItem` timeline (event keys are localized, never
  persisted as English sentences).
- Form: `AppFormSection` + `AppFormGrid` (two columns on desktop, one on
  mobile), a localized failure banner and field-level errors derived from the
  repository failure code via `serviceFieldForFailure`.

## Repositories

`ServiceCustomerRepository`, `ServiceSiteRepository`, `ServiceTeamRepository`,
`ServiceMasterRepository` — typed drafts, company-scoped reactive Drift queries,
read models with counts (no N+1), and reference search for selectors. Remote
sources are future work; Drift stays the local source of truth.

## Outbox / activity

Mutations reuse the shared outbox and append structured activity events:
`SERVICES_CUSTOMER_CREATE|UPDATE|DEACTIVATE`, `SERVICES_SITE_*`,
`SERVICES_TEAM_CREATE|MEMBERS_UPDATE|UPDATE`,
`SERVICES_<MASTER>_CREATE|SERVICES_CONFIG_UPDATE`; events
`services.customer.*`, `services.site.*`, `services.team.*`,
`services.configuration.*`. No noisy end-user notifications for directory/config
changes.

## Database

Schema **v12** adds `service_customers`, `service_sites`, `service_teams`,
`service_team_members`, `service_types`, `complaint_types`, `service_priorities`,
`service_ticket_types` with company-scoped unique keys and indexes. The migration
is idempotent and preserves all existing data.

## Demo seed

`seedServicesDemoData` seeds Service Types (Electrical/Plumbing/HVAC), Complaint
Types, Priorities (Normal/High/Urgent), Ticket Types, 2 customers, 3 sites and 2
teams (members drawn from existing HR demo employees — no employee duplication).
It is idempotent. Demo permission grants are explicit (no role templates):
Super admin / Company admin / HR have full Services management; Manager has
view-only customer access; Employee has none.

## Deferred

- Tenant/Building/Unit full domain, leasing, rent, contracts, Customer Portal.
- Quotation ownership, Job Order ownership, Inspector vs Technician workflow,
  Material approval/issue workflow — unresolved; not guessed.
- Service Enquiry / Job Assignment / Scheduling / Inspection / Material Request /
  Work Execution — Services Phase 2+.
