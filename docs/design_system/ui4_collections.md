# UI-4 — Collections, tables, search, filters & operational lists

One enterprise collection experience for HR, Services and Platform screens.
`AppPage` (1200px centered) stays the single outer layout; collections compose
shared primitives and never introduce a feature-level width or an extra outer
padding.

## Collection anatomy

```
AppPage
├── AppPageHeader          (title • subtitle • permission-aware primary action)
├── filters: AppCollectionToolbar
│     ├── AppSearchField            (context hint • icon • clear)
│     ├── AppFilterButton           ("Filters (n)")
│     ├── AppSortControl            (only where the query layer supports sort)
│     ├── secondary controls        (inline filter chips, view/segmented controls)
│     ├── result count (AppResultCount)
│     └── AppActiveFilters          (removable chips + Clear all)
└── child
      ├── AppCollectionSkeleton     (initial load)
      ├── AppCollectionEmptyState   (no data / no results / error)
      └── one coherent collection surface
            ├── desktop → AppCollectionSurface > AppDataTable
            └── compact → purpose-built AppMobileRecordCard list
      └── AppPagination             (where paging exists)
```

The whole surface is one coherenth block: the table is not re-wrapped in a
second card, and loading/empty/list states keep the toolbar shell intact.

## Toolbar (`AppCollectionToolbar`)

One control order everywhere: **Search → Filters → Sort/secondary → result
count**. Desktop renders a single row with a sensibly sized search (max 420px,
never stretched to 1200). Compact and tablet stack: full-width search, then a
wrapping control row, then the result count. This is why 600/768 do not squash
the desktop row.

## Search (`AppSearchField`)

Centralized search with a search icon, clear button, focus/hover treatment and a
localized hint. Hints are context-specific ("Search employees", "Search
enquiries"). Search semantics are preserved from the module state layer; no
client-side full-dataset filtering is introduced and module-level debounce (for
example `EmployeeListBloc`) is untouched.

## Filters

- One `AppFilterButton` opens the module filter surface (dialog on desktop,
  bottom sheet on compact). The button shows the active count `Filters (n)`.
- Frequently used, low-cardinality filters may render inline as `AppFilterChip`
  (for example customer/site/team status), never as permanent dropdowns.
- Runtime filters bind to the existing Cubit/BLoC query state — filter logic is
  not moved into widgets.

## Active filters (`AppActiveFilters`)

Active filters appear as removable chips (`Status: Pending ×`). A `Clear all`
action is offered when more than one filter is active. Removing a chip calls the
module's filter change with the specific field cleared, so counts/search/paging
stay consistent and scope-safe.

## Sorting (`AppSortControl`)

A compact, standardized selector, rendered only where the query/data model
supports sorting. Default operational ordering is preserved (for example newest
first, employee name, master sort order).

## Table system

- `AppDataTable` is the single desktop foundation (dense header/row heights,
  typed header style, internal horizontal scroll as the last resort).
- Rows carry one strong primary identity cell with in-cell hierarchy (business
  number prominent, secondary typography for code/site/mobile/subtitle).
- Status is always a semantic `AppStatusBadge`; dates use the existing localized
  formatters; numbers use tabular figures where useful.
- Booleans render as Yes/No or a metadata chip — never a read-only switch.
- Row click navigates to detail with hover/cursor; secondary and destructive
  actions live in an `AppActionMenu` (`⋯`).

### Column priorities

Columns are classified Primary / Important / Secondary / Optional. Larger
desktops (≥1000) may show more columns; narrower widths drop lower-priority
columns rather than widening the page.

| Collection | Primary | Important | Secondary |
| --- | --- | --- | --- |
| Employees | Name + code | Department, employment status | Designation, manager, type, joined |
| Service enquiries | ENQ number + customer·site | Complaint (service+complaint type), priority, status | Created date |
| Inspections | INS number + customer·site | Assignment ref, visit date-time | Technician |
| Job assignments | JA number + enquiry ref | Customer·site, visit date | Assigned summary |
| Material requests | MR number + inspection ref | Customer·site, purpose, total qty | Request date |
| Work executions | WE number + inspection ref | Customer·site, assigned summary | State, started/completed |
| Customers | Name + code | Mobile | Sites count |
| Sites | Name + code | Customer, building/unit | City |
| Teams | Name + code | Lead, member count | — |
| Masters | Name | Code, sort order | Default chip |
| Leave requests | Employee/self | Type, date range, days | Status, submitted |
| Attendance | Employee | Date, check-in/out, classification | Location |

## Row actions (`AppActionMenu`)

- Permission absent → action absent (never a disabled affordance that reveals
  functionality).
- Permission present but business state disallows → the action may be shown
  disabled with a reason (for example an Edit only when the record is open).
- Destructive actions use semantic wording inside the menu, not always-visible
  red icons.
- Material Request **Print** appears only in the row menu and only when the
  record is in view scope and the print permission exists.

## Pagination (`AppPagination`)

Previous / accurate range / page info / Next, driven by real pagination
metadata (`filtered` totals, never current-page length). Pages clamp when
filtering reduces the available pages (handled by the module state layer).
Page-size controls are added only where the data architecture already supports
them; where a module does not page, no pagination is rendered.

## Result count (`AppResultCount`)

Rendered next to the toolbar controls: `12 of 40 results` while filtered, or
`40 results` when nothing is filtered. Counts use the repository's scope-limited
totals so filtering/search can never leak inaccessible records.

## Loading, empty and error states

- Initial load → `AppCollectionSkeleton` (table geometry on desktop, card
  skeletons on compact). Refresh/search keeps the existing layout and shows a
  light indicator.
- No data → `AppCollectionEmptyState.noData` with a create CTA only when the
  user can create.
- No search/filter results → `AppCollectionEmptyState.noResults` with
  **Clear filters**.
- Query error → `AppState`/`AppErrorState` with **Retry**; a failed query is
  never rendered as zero records.

## Mobile transformation

On compact widths collections switch to purpose-built `AppMobileRecordCard`s:
primary identifier, status, key context, date and one or two values, plus a
`⋯` menu. Desktop tables are never squeezed; no horizontal page scroll is
introduced and `AppPage` is never widened.

## Responsive rules

| Width | Behaviour |
| --- | --- |
| 390 | cards; full-width search; filters in a bottom sheet |
| 600–1000 | stacked toolbar; list/card or compact table |
| 1000+ | single-row toolbar; full desktop table |
| 1920 | table stays inside the 1200 content width |

## RTL and mixed direction

Tables, toolbars, chips and pagination mirror correctly; pagination chevrons
flip; business codes, phone numbers and transaction numbers remain readable LTR
inside Arabic layout. Filter chips never overflow at scale.

## Accessibility

Meaningful semantics for search, filters, row menus (record context) and
status; keyboard focus is visible across search, filter, sort, rows, row menus
and pagination; status is never conveyed by colour alone.

## Localization

All new strings are localized EN/AR in `lib/l10n/common`: `resultsCount`,
`resultsCountFiltered`, `sortLabel`, `clearAll`, `removeFilter`, `pageOf`, plus
context-specific search hints per module.

## Screen inventory

### Migrated to the UI-4 collection language

| Screen | Location |
| --- | --- |
| Employees | `modules/hr/employees/presentation/pages/employee_list_page.dart` |
| Attendance history | `modules/hr/attendance/presentation/pages/attendance_history_page.dart` |
| Leave requests | `modules/hr/leave/presentation/pages/leave_request_list_page.dart` + `widgets/leave_operations_widgets.dart` |
| Leave approvals queue | `modules/hr/leave/presentation/pages/leave_approvals_page.dart` |
| Leave balances | `modules/hr/leave/presentation/pages/leave_balances_page.dart` |
| Holidays | `modules/hr/leave/presentation/pages/holiday_pages.dart` |
| Shifts / Work locations / Attendance policies | shared `shared/presentation/configuration_layouts.dart` |
| Service enquiries | `modules/services/enquiries/presentation/pages/service_enquiry_list_page.dart` |
| Job assignments | `modules/services/job_assignments/presentation/pages/service_job_assignment_list_page.dart` |
| Inspections | `modules/services/inspections/presentation/pages/service_inspection_list_page.dart` |
| Material requests | `modules/services/material_requests/presentation/pages/service_material_request_list_page.dart` |
| Work executions | `modules/services/work_executions/presentation/pages/service_work_execution_list_page.dart` |
| Customers | `modules/services/customers/presentation/pages/service_customer_list_page.dart` |
| Sites | `modules/services/sites/presentation/pages/service_site_list_page.dart` |
| Service teams | `modules/services/teams/presentation/pages/service_team_list_page.dart` |
| Services masters (7 kinds) | `modules/services/configuration/presentation/pages/service_master_list_page.dart` |
| Users & Access | `platform/access/presentation/users_access_page.dart` |
| Notifications | `platform/notifications/presentation/notifications_page.dart` |
| Workforce attendance (Team / All) | `modules/hr/attendance/presentation/pages/workforce_attendance_page.dart` |
| Attendance corrections queue & my requests | `modules/hr/attendance/presentation/pages/attendance_correction_pages.dart` (list/queue surface) |
| Attendance report detailed records | `modules/hr/reports/presentation/attendance_reports_page.dart` (records table/mobile-card surface only) |

### Intentionally excluded / follow-up

| Screen | Reason |
| --- | --- |
| Attendance Today | A personal daily attendance action surface (state card, context panel, live timeline, punch/break actions) with no record collection — there is no search/filter/sort/pagination to bind, so converting it to the collection pattern would require inventing list semantics and business behaviour. |
| Attendance day details, workforce attendance details, attendance correction form/detail | Detail/action surfaces, not collections — UI-4 covers list/collection UX only. |
| Leave calendar / employee leave sections | A month grid plus a per-day agenda, not a tabular record collection; there is no collection toolbar/search/pagination to bind without business changes. |
| Attendance reports (metrics + charts) | The report itself is a matrix of grouped metrics and analytics, not a record collection; only its existing "detailed records" table/mobile list uses the UI-4 collection surface. No reports were invented. |
| Company modules | Small settings card grid, not a record collection. |
| Service settings hub, create/edit forms, detail pages | Out of scope (UI-5). |
