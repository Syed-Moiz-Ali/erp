> **v3 applicability (2026-10-29):** Produced during the previous integration session. For API v3 the UI baseline is `ac2ec6f`; UI/UX is frozen and demo/local code stays until a separate, module-by-module removal phase. Statements about the 5df51cf UI, a live-only runtime, or removed demo paths are historical and do not describe v3.

# UI/UX regression report and restoration plan

Read-only audit. Baseline: commit `5df51cf` ("original api_integration state").
Current: `f71cfe8` (HEAD at audit time). No code was changed for this report.

Rule going forward: the UI/UX is frozen. Future API work may change data sources,
models, repositories and field mappings only; layout, routes, navigation pattern,
pages vs dialogs, widgets, styling and interaction flows stay unchanged unless a
specific change is approved in chat.

## 1. Route comparison

### Baseline routes

| Area | Baseline routes |
|---|---|
| Auth | `/login`, `/forgot-password`, `/bootstrap`, `/app/change-password` |
| Dashboard | `/app/dashboard` |
| Employees | `/app/hr/employees`, `/app/hr/employees/new`, `/app/hr/employees/:employeeId`, `/app/hr/employees/:employeeId/edit` |
| Departments | `/app/hr/settings/departments`, `/new`, `/:id`, `/:id/edit` |
| Shifts | `/app/hr/settings/shifts`, `/new`, `/:id`, `/:id/edit` |
| Employee Shifts | none |
| Branches | none |
| Attendance | `/app/hr/attendance`, `/history`, `/history/:id`, `/corrections`, `/corrections/new/:dayId`, `/corrections/:id`, `/requests`, `/requests/:id`, `/team`, `/team/:employeeId/:dayId`, `/all`, `/all/:employeeId/:dayId` |
| Access & Users | `/app/settings/access`, `/app/settings/access/users/:id`, `/app/settings/modules` |
| Permission catalog | none |
| Profile/account | `/app/profile`, `/app/change-password` |
| Shell | `/app/dashboard`, `/app/more`, notifications/sync utility routes |

### Current routes

| Area | Current routes | Difference |
|---|---|---|
| Auth | `/login`, `/forgot-password`, `/bootstrap`, `/app/change-password` | Same paths; demo-account button removed |
| Dashboard | `/app/dashboard` | Same path; different page |
| Employees | `/app/hr/employees` only | **`/new`, `/:employeeId`, `/:employeeId/edit` no longer registered** |
| Departments | `/app/hr/settings/departments`, `/new`, `/:id`, `/:id/edit` | Same |
| Shifts | `/app/hr/settings/shifts`, `/new`, `/:id`, `/:id/edit` | Same |
| Employee Shifts | `/app/hr/employee-shifts` | NEW |
| Branches | `/app/settings/branches` | NEW |
| Attendance | Baseline routes plus `/app/hr/attendance-today` | NEW parallel live route and nav entry |
| Access & Users | `/app/settings/access`, `/app/settings/access/users/:id` | Same paths; changed content |
| Permission catalog | `/app/settings/access/permissions` | NEW |
| Profile/account | `/app/profile`, `/app/change-password` | Same paths; field labels changed |
| Shell | Adds live Employees/Branches/Employee Shifts/Live Attendance/Permission catalog destinations; unauthorized page exposes missing key | Changed |

### Permission-tree route suffix guards

`lib/core/security/access_tree.dart` still declares employee action routes:

```text
routeActions: {'/new': 'create', '/edit': 'edit'}
```

The current router no longer registers those employee routes. Deep links such as
`/app/hr/employees/new` and `/app/hr/employees/123/edit` therefore cannot reach
the intended create/edit action guard; they fall through to routing/not-found
behaviour. Departments and Shifts still register their `/new`, `/:id`, `/edit`
routes, so their suffix guards remain valid. Branches, Employee Shifts and
Permission catalog have no baseline suffix routes.

## 2. Module regression table

| Module | Baseline UI (routes, pages, pattern, key widgets) | Current UI | Changed? | Files deleted/added/changed | Restore effort | Needs data-shape adaptation? |
|---|---|---|---|---|---|---|
| Auth/login | `/login`; `LoginPage` with identifier/password, `AppTextField`, `AppPasswordField`, forgot-password link, demo-accounts button/dialog | Same login layout and widgets; demo-accounts button/dialog removed | YES | `login_page.dart`; `app_router.dart`; auth localization/demo files removed | Small | No (demo-only removal) |
| Dashboard | `/app/dashboard`; `UniversalDashboardPage` with coordinator/contributor cards, summary metrics and quick actions | `/app/dashboard`; `NoDashboardDataPage` with empty-state card and access-tree quick links | YES | Added `no_dashboard_data_page.dart`; platform route changed; `demo_dashboard_source.dart` deleted; local dashboard repo changed | Small-medium | Yes (no dashboard endpoint; empty/real summary only) |
| Employees | List page with `AppPage`, toolbar, filter dialog/bottom sheet, table/mobile cards; details via `AppDetailPage`; add/edit via `AppPage` forms; routes `/new`, `/:id`, `/:id/edit` | One `LiveEmployeesPage` list with inline search/status chips, action menu, detail dialog and add/edit dialog; only list route registered | YES | Deleted 3 pages + 3 blocs; added live page/cubit/data/repo/domain; changed registry/routes/tests | Large | Yes |
| Departments | List/detail/form pages; routes `/new`, `/:id`, `/:id/edit`; `AppPage`/`AppDetailPage` config pattern | Same pages, routes and widgets; live data wiring only | NO | `department_form_bloc.dart`, repositories/data only | None | Already adapted |
| Shifts | List/detail/form pages; routes `/new`, `/:id`, `/:id/edit`; `AppPage`/`AppDetailPage` config pattern | Same pages, routes and widgets; live data wiring only | NO | `shift_form_bloc.dart`, mapper/data; seed moved to tests | None | Already adapted |
| Employee Shifts | None | `/app/hr/employee-shifts`; single list page with `AppDataTable`, action buttons and assignment dialog; no detail route | NEW | All employee-shift API/domain/cubit/page files added | No baseline restore; medium to align to page/form convention | Yes |
| Branches | None | `/app/settings/branches`; list page with table/mobile cards, detail dialog and edit dialog; no child routes | NEW | All branch API/domain/cubit/page files added | No baseline restore; medium to align to page/form convention | Yes |
| Attendance | `/app/hr/attendance`; `AttendanceTodayPage` in `AttendanceModuleScaffold`, state card, context panel, duration summary, timeline, sync banner, confirmation sheet; history/corrections/team/all pages | Baseline routes/pages remain; new `/app/hr/attendance-today` `LiveAttendancePage` with `AppPage`, day summary, shift cards, allowed-action buttons; new nav destination | YES | Added attendance live API/domain/cubit/page; registry/nav changed; baseline attendance pages unchanged | Medium | Yes |
| Access & Users | `/app/settings/access`; users list with module chips, user detail page with scope editor and save/confirm flow | Same routes/pages, but feature chips replace module chips, Permission catalog button added, Add permissions dialog, empty state and orphan-revoke section added | YES | `users_access_page.dart`, `user_access_detail_page.dart`, access cubit/repository/domain, routes | Medium | Yes |
| Permission catalog | None | `/app/settings/access/permissions`; grouped permission list + create/edit dialog + activate/deactivate actions | NEW | Added `permission_masters_page.dart`, repository/interface, route and registry entry | No baseline restore; medium if rebuilt as route pages | Yes |
| Profile/account | `/app/profile`; profile overview sections; label "Login email" | Same page/pattern; shows login ID plus optional email row | YES | `my_profile_page.dart` | Small | Yes (email nullable) |
| Shell/navigation | Permission-driven destinations; Employees entry opened baseline list page; dashboard `UniversalDashboardPage`; unauthorized/no-destination status pages | Adds live Employees, Branches, Employee Shifts, Live Attendance, Permission catalog; dashboard empty page; unauthorized page shows missing key; no-destination states split into no-permissions/failure/no-destinations | YES | `registered_modules.dart`, `app_routes.dart`, `platform_routes.dart`, `app_router.dart`, `app_shell.dart`, `route_status_pages.dart` | Medium | Yes |

## 3. Employees deep dive

### Deleted baseline UI

- `lib/modules/hr/employees/presentation/pages/employee_list_page.dart`
- `lib/modules/hr/employees/presentation/pages/employee_details_page.dart`
- `lib/modules/hr/employees/presentation/pages/employee_form_page.dart`
- `lib/modules/hr/employees/presentation/bloc/employee_list_bloc.dart`
- `lib/modules/hr/employees/presentation/bloc/employee_details_bloc.dart`
- `lib/modules/hr/employees/presentation/bloc/employee_form_bloc.dart`

Added replacement: `live_employees_page.dart`, `live_employee_cubit.dart`, live
data/domain layer. The current page uses dialogs instead of the baseline page
routes.

### Restoration plan (no implementation yet)

1. Restore the three baseline page files and the three blocs from `5df51cf`,
   preserving their widgets, layout, spacing, breadcrumbs and page/dialog
   conventions.
2. Keep the live repository/DTO/mapper and add a small UI view model:
   - `EmployeeRowView` for list rows;
   - `EmployeeDetailView` for detail;
   - `EmployeeFormView` for add/edit, wrapping `LiveEmployee` and
     `LiveEmployeeDraft`.
   Do not restore the old local `EmployeeRepository` as the source of truth.
3. Register the baseline routes again:
   `/app/hr/employees`, `/app/hr/employees/new`,
   `/app/hr/employees/:employeeId`, `/app/hr/employees/:employeeId/edit`.
   Point the list route to the restored list page, not `LiveEmployeesPage`.
4. Keep live list filters where the backend supports them; preserve baseline
   filter dialog/bottom-sheet interaction.
5. In the restored form, add the login section in baseline form style: login ID
   (email), mobile, write-only password, branch multi-select. Keep
   `login.userType` stripped and preserve full-replace PUT.
6. Add Manage access to the baseline detail overflow menu (and list action menu)
   when `login.userId` exists and the actor has
   `company.access.permissions.manage`.
7. Keep `mapEmployeeServerError` field mapping and wire its field keys to the
   restored form fields.
8. Restore/adapt the deleted employee UI tests listed below.

### Employee field mismatches and decisions

| Baseline UI field | Backend field | Proposal | Needs your decision |
|---|---|---|---|
| `firstName`, `middleName`, `lastName` (three inputs) | `employeeName` only | Show one full-name input; map to `firstName` in the adapter and leave middle/last empty; hide the extra inputs | YES: keep one full-name field or restore three inputs and split/join |
| `email`, `phone` | `email` nullable, `uaeContactNumber` | Map directly; keep baseline inputs | No |
| `departmentId`, `designationId` | `departmentId` int + `departmentName`; `designation` string | Map department selector to live lookup; show designation as text/selector backed by free text, not a reference lookup | YES: designation input style |
| `managerId` | `reportingManager` | Hide manager selector or show read-only manager text | YES |
| `employmentType` enum (fullTime/partTime/contract/intern/temporary) | `employeeType` string (`Revenue`, `Non-Revenue`) | Replace dropdown options with backend strings in baseline style | YES: confirm backend value set and whether to hide |
| `status` enum | `statusId` / `statusName` (1/2) | Map active/inactive; keep baseline status control | No |
| `shiftId`, `workLocationId`, `attendancePolicyId` | Not in employee payload; shift assignment is Employee Shifts; work location/policy not present | Hide from employee form; manage shifts in Employee Shifts | YES: hide, or add read-only context |
| `avatarUrl` | `photoPath` | Hide avatar or show read-only photo path in same style | YES |
| `linkedUserId`, `loginEnabled` | `login.userId`, `login.enabled`, `canLogin` | Map for Manage access and login section | No |
| `createdAt`, `updatedAt`, `syncStatus` | Not returned | Hide | YES: confirm hiding sync/created metadata |
| Login email/mobile/password/branches | `login.loginId`, `mobileNo`, `password` (write), `branchIds`, `branchNames` | Restore login section; branch multi-select from branch lookups; branchNames read-only string | YES: multi-branch display/edit policy |
| Not shown by baseline | `reportingManager`, `resignationDate`, `organization`, `ticket`, `genderBloodGroup`, addresses, home-country contacts, bank/account/WPS, labour/personal/passport/Emirates/visa/work-permit/immigration, insurance, salary components, document paths, `totalSalary`, login status/startDate | Hide, or show extra read-only payroll/identity sections in baseline `AppDetailsSection` style | YES: which extra fields to expose and whether read-only |
| `employeeCode` / id | `employeeCode` / `employeeId` separate | Keep separate; never derive one from the other | No |

Restore effort: **large**. The visual shell can be restored mostly verbatim, but
the form and detail bindings need a deliberate view-model/adapter because the
baseline domain and live API fields differ substantially.

## 4. Restoration plans for other changed/new modules

### Dashboard - YES, small-medium

Restore `UniversalDashboardPage` at `/app/dashboard` and its baseline route
registration. Keep the live data constraint: there is no dashboard endpoint, so
feed the existing empty `DashboardSummary`/contributors. The baseline summary
cards and quick actions need a decision on how they render with zero real data.

Decision: restore the universal dashboard with empty metrics, or keep the
current explicit no-data page.

### Auth/login - YES, small

The only baseline UI loss is the demo-accounts button/dialog. It has no live
backend equivalent. Restoring it would expose demo credentials.

Decision: keep it removed (recommended for live-only) or restore behind a
developer-only flag.

### Attendance - YES, medium

Restore `AttendanceTodayPage` as the only self-attendance page at
`/app/hr/attendance`; remove the parallel `/app/hr/attendance-today` nav entry
after approval. Feed the baseline state card/timeline/confirmation widgets from a
view model over live `AttendanceDay`:

- map live `state` to the baseline state card values;
- map live shifts/punch/break times to the baseline timeline;
- map `allowedActions` to the baseline action/confirmation flow;
- decide what to do with baseline sync banner, local workday context and
  location/policy context that the live day response does not provide;
- decide whether to show live-only `serverTime`, day time zone and current/next
  shift numbers in baseline style.

Decisions: hide local-only sync/context widgets vs keep disabled; show live
server time/timezone extras vs keep baseline summary only.

### Access & Users - YES, medium

Restore the baseline users list/detail composition and module chips. Keep live
grants. The additive Add-permissions flow, orphan revoke section and empty-grant
state were added after baseline and are required by the live grant contract; they
need to be placed inside the baseline visual structure rather than replacing it.

Decisions:
- keep feature-path chips or restore module chips;
- keep the Permission catalog button/route;
- keep Add permissions dialog and orphan row section in baseline detail style;
- keep grant-derived user list plus employee-screen Manage access, because a
  grantless login still cannot be found from Access.

### Permission catalog - NEW, medium to align

There was no baseline screen. Current screen follows the app's `AppPage` list and
dialog-editor conventions, but not the baseline configuration pattern of separate
list/detail/form routes. It is required for live permission CRUD.

Decision: accept the new page as-is, or rebuild it as `/permissions`,
`/permissions/new`, `/:id`, `/:id/edit` to match baseline configuration screens.

### Branches - NEW, medium to align

No baseline screen. Current page uses baseline `AppPage` list/table/mobile-card
patterns but opens detail/edit in dialogs and has no child routes. To match the
baseline configuration convention it would need list/detail/form routes.

Decision: accept the current NEW page, or rebuild as routed list/detail/form.

### Employee Shifts - NEW, medium to align

No baseline screen. Current page uses `AppPage` + table + assignment dialog; no
detail route. Same decision as Branches: accept the dialog-based NEW page, or
rebuild as routed list/detail/form.

### Profile/account - YES, small

Restore the baseline "Login email" label and row composition if the frozen UI
must be exact. The live backend has a nullable `email` and a mandatory `loginId`;
showing loginId under an email label would be inaccurate.

Decision: restore the baseline label using `loginId`, or keep the current
loginId + optional email rows.

### Shell/navigation - YES, medium

The shell chrome is largely unchanged, but navigation destinations and status
pages changed. Restoring navigation exactly means removing live Branches, Employee
Shifts, Live Attendance and Permission catalog entries until each module is
approved, and restoring the baseline employee destination to the restored employee
list. The unauthorized page also gained a missing-permission-key line.

Decisions: which NEW destinations stay visible after the freeze; whether the
unauthorized page keeps the extra key line; whether dashboard returns to the
universal page.

## 5. Tests deleted or rewritten for the replaced UI

Deleted tests that covered the baseline employee pages/routes:

- `test/employee_widget_test.dart` - baseline employee list, detail, add/edit,
  filters and navigation.
- `test/configuration_widget_test.dart` - employee form/detail portions of the
  configuration flow (whole file deleted).
- `test/phase0_routing_test.dart` - baseline employee routing.
- `test/phase13_5_routing_test.dart` - employee list/detail route transitions.
- `test/phase13_6_routing_state_test.dart` - employee route state/back behaviour.
- `test/shell_test.dart` - employee nav/destination access assertions among shell
  coverage.

Rewritten or partially rewritten:

- `test/employee_test.dart` - now retains local repository/DAO tests but no
  longer exercises the deleted employee blocs/pages.
- `test/ui7_specialized_workspaces_test.dart`, `test/ui2_shell_test.dart`,
  `test/navigation_ia_test.dart`, `test/page_layout_test.dart` - updated for the
  new registry/live pages.

Added replacements, not baseline-equivalent:

- `test/employee_editor_widget_test.dart` - dialog editor.
- `test/employee_fixture_test.dart`, `test/live_employee_test.dart`,
  `test/employee_created_fixture_test.dart` - live data/model.
- `test/employee_access_entry_test.dart` - Manage access condition.

Restore these tests from `5df51cf` when the employee pages are restored, then
adapt their data setup to live fixtures. Keep the live DTO/repository/fixture
tests.

## 6. Decision checklist

1. Employees: restore three separate name inputs or one full-name input?
2. Employees: designation and manager fields - editable, read-only, or hidden?
3. Employees: `employeeType` - show backend `Revenue`/`Non-Revenue` strings or
   hide the baseline employment-type control?
4. Employees: hide shift/work location/attendance policy fields, or show
   read-only context?
5. Employees: show or hide avatar/photo path and created/updated/sync metadata?
6. Employees: which backend-only payroll/identity/document fields should be
   shown, and read-only or editable?
7. Employees login: how should multiple branches be displayed/edited?
8. Dashboard: restore `UniversalDashboardPage` with empty real data, or keep
   `NoDashboardDataPage`?
9. Auth: keep demo-account access removed (recommended), or restore behind a
   developer-only flag?
10. Attendance: restore baseline `AttendanceTodayPage` as the sole page and
    remove `/app/hr/attendance-today`, or keep both?
11. Attendance: hide local sync/workday/location context, or keep it where live
    data can be mapped?
12. Access: restore module chips or keep feature-path chips?
13. Access: keep the new Permission catalog button/route?
14. Access: keep Add permissions/orphan/empty-grant sections inside the baseline
    detail layout?
15. Permission catalog: accept the NEW dialog-based page, or rebuild as routed
    list/detail/form pages?
16. Branches: accept the NEW dialog-based page, or rebuild as routed pages?
17. Employee Shifts: accept the NEW dialog-based page, or rebuild as routed
    pages?
18. Profile: keep loginId + optional email rows, or restore the baseline "Login
    email" row using loginId?
19. Shell/navigation: which NEW destinations remain visible under the freeze?
20. Shell/status pages: keep the extra missing-permission-key line and split
    no-permission/no-destination states?

No code has been restored or changed.
