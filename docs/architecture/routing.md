# Canonical module-first routing

Phase 0.3 restructured URLs so they reflect the ERP module boundaries:
`/app/{business-module}/{feature}/...`. Platform concerns stay global.

## Principles

- **Module-first paths.** Business destinations live under their module:
  `/app/hr/employees`, `/app/services/enquiries`, `/app/finance/invoices`.
- **Platform routes stay global.** `/app/profile`, `/app/settings`,
  `/app/notifications` are not nested under a module.
- **One GoRouter.** All module routes are composed into a single
  `StatefulShellRoute.indexedStack`; module-owned route constants/builders are
  defined by the module and composed by the app router.
- **URL is page identity.** go_router URL reflects imperative navigation
  (`optionURLReflectsImperativeAPIs = true`). BLoC state is never page identity.
- **Paths are not localized.** Routes are stable English identifiers in both
  English and Arabic. Only UI labels are localized.
- **Filters use query parameters.** List state (filters, page, sort, period,
  search) uses `?key=value`; sensitive data (leave reasons, phone, email,
  private notes) never appears in a URL.
- **Typed builders.** Build links with `HrRoutes.employee(id)`,
  `AppRoutes.leaveRequestDetails(id)`, etc. — never concatenate path strings in
  widgets. Path parameters hold stable record IDs, not names or translated text.

## Route ownership

| Owner | Source of truth | Examples |
| --- | --- | --- |
| HR module | `lib/modules/hr/module/hr_routes.dart` (`HrRoutes`) | `/app/hr`, `/app/hr/employees`, `/app/hr/attendance`, `/app/hr/leave`, `/app/hr/reports`, `/app/hr/settings/*` |
| Services module | `lib/modules/services/module/services_routes.dart` (`ServicesRoutes`) | `/app/services` (root reserved) |
| Platform | `lib/app/router/platform_routes.dart` (`PlatformRoutes`) | `/app/profile`, `/app/settings`, `/app/notifications`, `/app/change-password` |

`AppRoutes` remains the stable public facade used by existing callers; its HR
members delegate to `HrRoutes`, so the canonical value is defined once.

## Canonical HR routes

```text
/app/hr                          HR landing (current HR dashboard/overview)
/app/hr/employees
/app/hr/employees/new
/app/hr/employees/:employeeId
/app/hr/employees/:employeeId/edit
/app/hr/attendance
/app/hr/attendance/history
/app/hr/attendance/history/:attendanceDayId
/app/hr/attendance/corrections
/app/hr/attendance/corrections/new/:attendanceDayId
/app/hr/attendance/corrections/:correctionId
/app/hr/attendance/requests
/app/hr/attendance/requests/:correctionId
/app/hr/attendance/team
/app/hr/attendance/all
/app/hr/leave
/app/hr/leave/my-requests
/app/hr/leave/request
/app/hr/leave/requests/:requestId
/app/hr/leave/team
/app/hr/leave/all
/app/hr/leave/approvals
/app/hr/leave/balances
/app/hr/leave/calendar
/app/hr/leave/employee/:employeeId
/app/hr/reports
/app/hr/settings/shifts
/app/hr/settings/work-locations
/app/hr/settings/attendance-policies
/app/hr/settings/leave-types
/app/hr/settings/leave-policies
/app/hr/settings/holidays
```

HR configuration is `/app/hr/settings/*`; the application-wide settings remain
`/app/settings`. The Settings hub keeps owning the `/app/hr/settings` subtree via
`routeAliases` so configuration screens keep the Settings item selected.

## Services convention

Only `/app/services` is reserved. Services Phase 1+ adds
`/app/services/enquiries`, `/app/services/jobs`, `/app/services/schedule`,
`/app/services/inspections`, `/app/services/material-requests`,
`/app/services/work-executions`, `/app/services/reports`,
`/app/services/settings` and must follow the same rules. No Services feature
routes are implemented in Phase 0.3.

Future module namespaces: `/app/crm`, `/app/sales`, `/app/purchase`,
`/app/inventory`, `/app/finance`, `/app/rental`, `/app/production`.

## Legacy redirects

`lib/app/router/legacy_routes.dart` (`LegacyRoutes`) is a centralized,
segment-aware mapper applied at the top of `authRedirect`. It preserves dynamic
segments and query parameters and never duplicates a canonical route. It runs
before authentication/module/permission rules, so the canonical location is used
for the `from` target and the browser URL is updated to the canonical path.

| Old | New |
| --- | --- |
| `/app/dashboard` | `/app/hr` |
| `/app/employees` | `/app/hr/employees` |
| `/app/employees/:id` | `/app/hr/employees/:id` |
| `/app/employees/:id/edit` | `/app/hr/employees/:id/edit` |
| `/app/attendance` | `/app/hr/attendance` |
| `/app/attendance/history` | `/app/hr/attendance/history` |
| `/app/attendance/requests` | `/app/hr/attendance/requests` |
| `/app/attendance/team` | `/app/hr/attendance/team` |
| `/app/attendance/all` | `/app/hr/attendance/all` |
| `/app/leave` | `/app/hr/leave` |
| `/app/leave/*` | `/app/hr/leave/*` |
| `/app/reports` | `/app/hr/reports` |
| `/app/settings/shifts` | `/app/hr/settings/shifts` |
| `/app/settings/work-locations` | `/app/hr/settings/work-locations` |
| `/app/settings/attendance-policies` | `/app/hr/settings/attendance-policies` |
| `/app/settings/leave-types` | `/app/hr/settings/leave-types` |
| `/app/settings/leave-policies` | `/app/hr/settings/leave-policies` |
| `/app/settings/holidays` | `/app/hr/settings/holidays` |

`/app/settings`, `/app/settings/notifications`, `/app/settings/sync` and all
other platform routes are **not** rewritten.

Old routes are deprecated but retained for compatibility with persisted
notifications, bookmarks and browser history. New link generation must always use
the canonical `/app/hr/...` paths. A future release can remove the aliases once
old links have aged out.

## Authorization

Moving a route never weakens authorization. Access is still resolved per
destination via `NavigationResolver` using company module enablement, required
permissions and required capabilities. `/app/hr` does not grant blanket HR
access: each child route keeps its own permission/capability guard, and direct
URL access remains protected. `DefaultLandingResolver` returns the first
permitted destination's canonical route (`/app/hr` for HR users,
`/app/services` for future Services-only users).

## Tests

`test/phase0_routing_test.dart` covers the legacy mapper (roots, dynamic IDs,
query parameters, platform non-rewrites), `authRedirect` compatibility
(canonical `from`, canonical redirects), widget-level legacy deep links, and a
source scan asserting no old HR literal path remains in `lib/` outside the legacy
mapper.
