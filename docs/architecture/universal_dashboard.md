# Universal ERP Dashboard

The ERP has **exactly one** user-facing dashboard. It is owned by a neutral
platform/workspace boundary and composes content contributed by business
modules. There are no role-based dashboards and no per-module dashboards (no HR
Dashboard page, no Services Overview/Dashboard page).

## Ownership

- Owner: `lib/platform/workspace/dashboard/` (neutral, cross-module).
- Page: `UniversalDashboardPage` / `UniversalDashboardView`.
- The dashboard is **not** owned by `lib/modules/hr/` or
  `lib/modules/services/`. It contains no module DAO, Drift table, bloc or
  business rule import.

## Canonical route

- Canonical dashboard route: `/app/dashboard` (`PlatformRoutes.dashboard`,
  exposed as `AppRoutes.dashboard`).
- `/app` redirects to the authenticated default landing, which is the
  dashboard (the dashboard destination has order `0` and no permission
  requirement).
- `/app/dashboard` is registered by
  `lib/platform/module/platform_registration.dart` as the first
  `AppModuleIds.dashboard` destination. Its `AppModule` is `alwaysAvailable`,
  so an authenticated user always has somewhere safe to land.

### Legacy redirects

`lib/app/router/legacy_routes.dart` rewrites old dashboard-only URLs, preserving
query parameters:

| Legacy URL | Canonical |
| --- | --- |
| `/app/hr/dashboard` | `/app/dashboard` |
| `/app/services/dashboard` | `/app/dashboard` |

There is no redirect loop: each rule maps to the canonical route once and the
canonical route has no redirect.

## Module landing redirects

Removing the duplicated dashboards must not break module feature routes. The
module roots redirect to the first **permitted** feature of that module, or to
the dashboard when the user can reach none of them:

- `/app/hr` → first of Employees, Attendance, Leave, Reports (by permission).
- `/app/services` → first of Enquiries, Job Assignments, Inspections, Material
  Requests, Work Execution, Customers, Sites, Teams, Services settings.

The redirects are implemented in `lib/app/router/app_router.dart`
(`_moduleLanding`) using the resolved navigation, so a disabled module or a
missing grant falls back to the dashboard rather than looping or rendering a
second dashboard.

Feature routes are unchanged: `/app/hr/employees`, `/app/hr/attendance`,
`/app/hr/leave`, `/app/hr/reports`, `/app/services/enquiries`,
`/app/services/job-assignments`, `/app/services/inspections`,
`/app/services/material-requests`, `/app/services/work-executions`, etc.

## Contributor architecture

```
UniversalDashboardBloc
        │
UniversalDashboardCoordinator
        │
DashboardContributor
        ├── HrDashboardContributor        (lib/modules/hr/dashboard/application)
        ├── ServicesDashboardContributor  (lib/modules/services/overview/application)
        └── future module contributors
```

- `DashboardContributor` (`domain/dashboard_contributor.dart`) exposes `id`,
  `moduleId`, `order`, `isVisible(context)` and
  `load(context) → DashboardContribution`.
- `UniversalDashboardCoordinator` runs every visible contributor in order and
  merges the typed contributions into a `UniversalDashboardSnapshot`. A
  contributor failure degrades that module only: the coordinator marks the
  snapshot `partialFailure` and keeps every other contribution.
- `UniversalDashboardBloc`
  (`presentation/bloc/universal_dashboard_bloc.dart`) exposes loading / ready /
  partial / refreshing / failure states.
- Registration is plain constructor injection in
  `lib/app/module_registry/registered_modules.dart`, so a future module
  registers a contributor without editing a giant switch.

### Module contribution contract

`DashboardContribution` carries presentation-ready, already-localized models:

- `DashboardKpi` - compact metric cards.
- `DashboardAttentionItem` - cross-module "Needs attention" rows.
- `DashboardScheduleItem` - chronological "Today's schedule" rows.
- `DashboardWorkItem` - "My work" (ASSIGNED) rows.
- `DashboardTeamRow` / `DashboardBreakdown` - team/company overview.
- `DashboardActivityItem` - recent structured activity with a module tag.
- `DashboardQuickAction` - capability-driven quick actions (capped at 6).
- `myDay` - module-owned personal widgets (attendance punch card, leave
  banner).
- `viewAll` - section → module list route, only when permitted.

Modules map their own domain state into these models. Domain rules stay in the
module; the universal dashboard only composes.

## Section ordering

The universal page renders sections by work/attention, never as stacked module
panels:

1. Context header (title, subtitle, date, scope badges).
2. My Day (personal, module-owned widgets).
3. Key metrics (compact, capped at 6 by priority).
4. Needs Attention (merged, sorted urgency → business date → stable id).
5. Today's schedule.
6. My Work (ASSIGNED, strong section).
7. Team/company overview (team rows + breakdowns).
8. Recent activity (merged chronologically, subtle module tag).
9. Quick actions (3-6, capability-driven).

Desktop uses the shared two-column composition; mobile is a single operational
feed ordered My Day, Needs Attention, My Work, Today's Schedule, KPIs,
Team/Overview, Recent Activity, Quick Actions.

Data limits: 5-10 items for attention/schedule/activity (currently 8),
8 for my work, 6 KPIs, 6 quick actions.

## Permission behaviour

- A contributor's `isVisible` gate is evaluated **before** any read. If it
  returns false, the module performs no query at all (HR-only users do not
  query Services, and vice versa).
- Every section, KPI and item is produced only from a permission/scope-filtered
  module projection. KPI presence is never authorization; a count is only
  queried when the user may see that domain.
- Attendance punch actions are independently gated by
  `attendance.punchIn`/`punchOut`/`break`; view does not grant punch.
- Quick actions are capability-driven: hidden, never disabled.
- "View all" links appear only for a route the user may open.

## Scope behaviour

- Services contributors reuse the existing Phase 9 projection, so their scope is
  `ASSIGNED` / `TEAM` / `ALL` exactly as before. Services Team (service teams)
  is never mixed with HR department/team.
- HR contributors reuse `DashboardScopeResolver`: `SELF` / `TEAM` / `COMPANY`
  with the highest explicitly granted attendance scope.
- Company-wide metrics appear only for an ALL-scoped grant.

## Employee link behaviour

- Personal widgets (attendance, leave) require a linked `EmployeeReference`.
  Without one, the HR contributor simply omits them; broad company metrics may
  still appear according to explicit grants.
- Losing the employee link removes the personal records; nothing stale is kept.

## Module enablement and company switch

- If HR is disabled, no HR contribution is loaded; if Services is disabled, no
  Services contribution is loaded. Disabling a module never breaks the
  dashboard.
- Switching company recreates the auth context, which recreates the dashboard
  bloc keyed by that context; every contribution recomputes. No previous-company
  counts or items remain.
- A live permission grant/revoke updates the dashboard without a re-login: the
  HR/Services read projections re-resolve scope on each load and the page's
  bloc is keyed by the current auth context.

## Data and security responsibilities

- The universal dashboard imports only module **public read contracts**
  (`DashboardRepository`, `ServicesDashboardRepository`) and module-owned
  presentation widgets. It never imports an HR/Services DAO, Drift table or
  bloc.
- Read efficiency is the module's responsibility: batched, scope-filtered
  projections, no "load all employees/enquiries/work executions to count", no
  N+1 label resolution, bounded recent limits.
- The dashboard does not duplicate the global Notification Center; sync is
  never presented as a KPI.

## Layout

The dashboard uses the one global centered `AppPage` content width
(`AppDimensions.contentMaxWidth`). There is no dashboard-specific wider
container.

## Localization

Neutral dashboard strings live in the neutral platform source
(`lib/platform/l10n/platform_en.arb` / `platform_ar.arb`) as
`universalDashboard*` keys. Module labels and events stay module-owned (HR and
Services ARB sources) and are resolved by the contributors. English/Arabic
parity and RTL are preserved.
