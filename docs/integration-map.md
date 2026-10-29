# Integration map — API v3 (UI frozen at `ac2ec6f`)

**Branch:** `feat/api-v3` (from `ac2ec6f`)
**UI baseline:** `ac2ec6f` (tip of `services_module`, 2026-10-08), enforced by `tool/ui_freeze_check.dart`.
**Status:** integration map only. No module is wired, no live write is performed, and no screen is modified.

Legend:

| Code | Meaning |
|---|---|
| CARRIED | Data-layer code exists on `feat/api-v3`; not yet selected by DI |
| PENDING | Bridge/adapter not written yet |
| NEW | No baseline screen; build last, after approval |
| DECISION | Blocked until you choose an option |

Rules applied:

* API work may add data sources, DTOs, mappers, repositories, auth/session handling, permission loading, DI, field/error mapping, fixtures and tests.
* Screens, widgets, layouts, styles, routes, route structure, page-vs-dialog patterns, nav order, l10n copy and interaction flows stay frozen, except the approved Departments and Shifts items.
* Live implementations sit **behind the existing repository interfaces**; a screen is never rewritten to fit the API.
* Live writes are out of scope for this phase. Every write endpoint below is documented, not called.
* Permission data may only change visibility predicates of existing nav entries, routes and buttons. It must not reorder or restructure navigation.

---

## 1. Baseline inventory (at `ac2ec6f`)

| Module | Screens (baseline) | Routes | Blocs / cubits | Repository interface | Endpoint source |
|---|---|---|---|---|---|
| Auth | `lib/platform/auth/presentation/pages/{login,forgot_password,bootstrap,change_password}_page.dart` | `/login`, `/forgot-password`, `/bootstrap`, `/app/change-password` | `auth_bloc.dart`, `password_bloc.dart` | `AuthRepository` (`lib/platform/auth/domain/repositories/auth_repository.dart`) | `docs/api_integration/PHASE_0_AUDIT.md` A1–A5 |
| Dashboard | `lib/platform/workspace/dashboard/presentation/universal_dashboard_page.dart` | `/app/dashboard` | dashboard contributor/cubit under `lib/modules/hr/dashboard/` and `lib/platform/workspace/dashboard/` | `DashboardRepository` (`lib/modules/hr/dashboard/domain/dashboard_repository.dart`) | none |
| Settings | `lib/shared/presentation/configuration_landing_page.dart` | `/app/settings`, `/app/settings/notifications`, `/app/settings/sync` | `ConfigurationLandingBloc` (in the page file) | configuration repositories (shifts, departments after approval, work locations, policies, leave) | list endpoints for counts |
| Profile | `lib/platform/profile/presentation/my_profile_page.dart` | `/app/profile` | reads `AuthContext`; `my_profile_cubit` in `lib/platform/profile/application/` | session only | login/session payload |
| Employees | `lib/modules/hr/employees/presentation/pages/employee_{list,details,form}_page.dart` | `/app/hr/employees`, `/new`, `/:employeeId`, `/:employeeId/edit` | `employee_{list,details,form}_bloc.dart` | `EmployeeRepository` | E1–E5 in `PHASE_0_AUDIT.md` |
| Departments | **none at baseline** (UI approved from `19a0b24`) | proposed `/app/hr/settings/departments`, `/new`, `/:id`, `/:id/edit` | `department_{list,details,form}_bloc.dart` (approved) | `DepartmentRepository` | Departments matrix in `postman-coverage.md` |
| Shifts | `lib/modules/hr/shifts/presentation/pages/shift_{list,details,form}_page.dart` | `/app/hr/settings/shifts`, `/new`, `/:id`, `/:id/edit` | `shift_form_bloc.dart` + shared list/details | `ShiftRepository extends ConfigurationRepository<Shift, ShiftDraft>` | Shifts matrix |
| Attendance | `lib/modules/hr/attendance/presentation/pages/attendance_{today,history,day_details,correction}_pages.dart`, `workforce_attendance_{page,details}.dart` | `/app/hr/attendance`, `/history`, `/history/:id`, `/corrections`, `/corrections/new/:dayId`, `/corrections/:id`, `/requests`, `/requests/:id`, `/team`, `/team/:employeeId/:dayId`, `/all`, `/all/:employeeId/:dayId` | `attendance_bloc`, `attendance_history_bloc`, `attendance_day_details_bloc`, `attendance_correction_bloc`, `workforce_attendance_bloc` | `AttendanceRepository` (+ correction and workforce read repos) | Attendance matrix |
| Access & Users | `lib/platform/access/presentation/{users_access_page,user_access_detail_page,company_modules_page}.dart` | `/app/settings/access`, `/app/settings/access/users/:id`, `/app/settings/modules` | `lib/platform/access/application/user_access_cubit.dart` | `AccessRepository` | Permissions + User Permissions matrices |

Nav entries and order at baseline (unchanged by this phase): dashboard 0, employees 10, attendance 20–25, leave 26–28, shifts 41, work locations 42, attendance policies 43, leave types 44, leave policies 45, holidays 46, profile 90.

---

## 2. Bridge architecture

```
Screen / Bloc / Cubit            (frozen, unchanged)
        │
        ▼
Existing repository interface    (EmployeeRepository, ShiftRepository, AttendanceRepository, ...)
        │
        ├── local / demo implementation      (kept for demo; not removed in v3)
        └── backend adapter (new)            (selected only when AppConfig.realApiEnabled)
                    │
                    ▼
        Remote data source + DTO + mapper (carried)
                    │
                    ▼
                ApiClient (shared, carried)
```

DI selection is per repository, not per screen. A backend adapter must return the **same domain types** the screen already consumes; when the backend cannot express a field, the value is mapped, hidden by the approved rule, or listed as DECISION.

---

## 3. Module maps

### 3.1 Auth

| Item | Value |
|---|---|
| Interface | `AuthRepository` (unchanged) |
| Backend adapter | `RemoteAuthRepository` — already implements `AuthRepository`, `SessionPermissionSink`, `TokenRefresher` (CARRIED) |
| Session storage | `SecureSessionStorage` with access/refresh expiry + `hasRefreshToken` (CARRIED) |
| Endpoints | `POST /api/auth/login`, `POST /api/auth/refresh`, `POST /api/auth/logout`, `GET /api/me/permissions` |
| Read/write | Login/refresh/logout are writes to the session; no business data write. `/me/permissions` is a read. |
| Planned bridge | Register `RemoteAuthRepository` when `AuthMode.backend`; keep `DemoAuthRepository` for demo and `DisabledAuthRepository` for disabled. Wired in `platform_dependencies.dart`; PENDING verification against the live backend. |
| UI impact | None to files. The demo-accounts button is hidden when bootstrap passes an empty list (existing behaviour); permission load happens after login. |

| # | UI field / behaviour (frozen) | Backend field | Type / nullability | Decision |
|---|---|---|---|---|
| A1 | Identifier input accepts email or phone; hint/label mention email/phone | `loginId` (3–100 chars, case-sensitive) | `String`, required | Map: `AuthIdentifier.parse` accepts `loginId` without changing the field or label. **NEEDS MY DECISION:** confirm that accepting a plain login id (e.g. `Admin`) in the frozen field is acceptable; otherwise the form must keep rejecting it and backend users cannot sign in. |
| A2 | Demo accounts button/dialog | none | — | Keep. In backend mode the list is empty and the button is not rendered (existing conditional). **NEEDS MY DECISION:** confirm this visibility-only change is acceptable under freeze. |
| A3 | Company name / branch display | `orgId`, `branchName`, `branches[]`, `orgCount` | int / String / List | `UserAccount.companyId = orgId`, company name = `branchName`. `branches[]` is not modelled in `AuthContext`. **NEEDS MY DECISION:** map single branch now, or extend the session model (data-only) to carry all branches. |
| A4 | Email shown on profile | `loginId` (no email on login) | String | `UserAccount.email = loginId` in the remote mapper. **NEEDS MY DECISION:** profile label says "Email"; keep mapping loginId there (no copy change) or add a separate login-id row later. |
| A5 | Session restore after app restart | access/refresh expiry + refresh rotation | DateTime? | Map. No UI change. |

### 3.2 Dashboard

| Item | Value |
|---|---|
| Interface | `DashboardRepository.load` (returns `DashboardSummary` / contributions) |
| Backend adapter | none — there is **no dashboard endpoint** |
| Endpoints | none |
| Planned bridge | In backend mode, return an empty real summary through the existing repository; in demo mode keep the local demo repository. No screen change. |
| UI impact | None to files. |

| # | UI behaviour | Backend | Decision |
|---|---|---|---|
| D1 | Summary cards, quick actions, contributor sections render numbers | no endpoint | **NEEDS MY DECISION:** show empty/zero real data (skeleton stays, numbers zero) or keep demo numbers in demo mode only and zero in backend. No new empty-state screen is allowed by the freeze. |
| D2 | Service/HR contributors | no endpoint | Same as D1. |

### 3.3 Settings & Profile

| Item | Value |
|---|---|
| Screens | `configuration_landing_page.dart`, `my_profile_page.dart` |
| Repositories | configuration repositories (`ShiftRepository`, `DepartmentRepository`, work-location/policy/leave) |
| Backend adapters | `RemoteShiftRepository`, `RemoteDepartmentRepository` (CARRIED); DI selection pending |
| Endpoints | `GET /api/shifts`, `GET /api/departments` for counts; profile data comes from the session |
| Planned bridge | Counts use `watchList(pageSize: 1).total`; profile maps `AuthContext`. No widget changes. |

| # | UI field | Backend | Type / nullability | Decision |
|---|---|---|---|---|
| S1 | Department row + count | `GET /api/departments` | paged `totalItems` | Add row only through the approved Departments change. |
| S2 | Shift row + count | `GET /api/shifts` | paged `totalItems` | Map, no UI change. |
| S3 | Profile "Login email" row | `loginId` | String | See A4. **NEEDS MY DECISION.** |
| S4 | Profile branch/company | `branchName`, `orgId` | String / int | Map; no extra rows unless approved. **NEEDS MY DECISION** if multiple branches must be shown. |

### 3.4 Employees

| Item | Value |
|---|---|
| Interface | `EmployeeRepository` (12 methods: list/detail/save/setActive/lookups/references/account access/availability) |
| Backend adapter | planned `LiveEmployeeRepositoryBridge` implementing `EmployeeRepository` over `LiveEmployeeRepository` (CARRIED data layer) |
| Endpoints | `GET /api/employees/lookups`, `GET /api/employees`, `GET /api/employees/{id}`, `POST /api/employees`, `PUT /api/employees/{id}`, `POST /api/employees/{id}/activate|deactivate` |
| Read/write | Reads only in this phase. Create/update/activate/deactivate are documented, **not called**. |
| Planned bridge | Adapter maps `LiveEmployee` to `Employee` and `EmployeeDraft` to `LiveEmployeeDraft`. Write methods return a "not enabled in this phase" failure until approved. The screen stays the baseline list/detail/form. |
| UI impact | None to files. |

| # | UI field / behaviour | Backend field | Type / nullability | Options | Decision |
|---|---|---|---|---|---|
| E1 | `firstName` + `middleName` + `lastName` | `employeeName` (single string) | String, required | (a) map full name to `firstName`, blank middle/last; (b) split on spaces; (c) restore a single full-name input | **NEEDS MY DECISION** |
| E2 | `email` required | `email` | String?, nullable | (a) show empty when null; (b) show placeholder; (c) require before save | **NEEDS MY DECISION** |
| E3 | `phone` required | `uaeContactNumber` | String?, nullable | Map directly; validation stays client-side | Map (no decision) |
| E4 | `departmentId` reference selector | `departmentId` int + `departmentName` | int, required | Map by string form of int; show name from `departmentName` | Map |
| E5 | `designationId` reference selector | `designation` free text | String?, nullable | (a) show as text; (b) keep selector backed by lookup-free text; (c) hide | **NEEDS MY DECISION** |
| E6 | `managerId` selector | `reportingManager` text | String?, nullable | (a) read-only text; (b) hide; (c) keep empty selector | **NEEDS MY DECISION** |
| E7 | `employmentType` enum (5 values) | `employeeType` string (`Revenue`, `Non-Revenue`, ...) | String?, nullable | (a) map to dropdown options; (b) read-only; (c) hide | **NEEDS MY DECISION** |
| E8 | `status` enum active/inactive | `statusId` (1/2), `statusName` | int + String | Map 1→active, else inactive | Map |
| E9 | `shiftId`, `workLocationId`, `attendancePolicyId` | not in employee payload | — | (a) hide; (b) read-only context from other modules | **NEEDS MY DECISION** |
| E10 | `avatarUrl` | `photoPath` | String?, nullable | (a) hide; (b) show read-only path text | **NEEDS MY DECISION** |
| E11 | `linkedUserId`, `loginEnabled` | `login.userId`, `login.enabled`, `canLogin` | int?, bool, bool | Map for read-only display; writes deferred | Map |
| E12 | `createdAt`, `updatedAt`, `syncStatus` | not returned | — | (a) hide; (b) show nothing | **NEEDS MY DECISION** |
| E13 | Login section (login id, mobile, password, branch) | `login.loginId`, `mobileNo`, `password`, `branchIds`, `branchNames` | String / List<int> | (a) read-only; (b) editable but password write deferred | **NEEDS MY DECISION** |
| E14 | Many baseline fields not shown | ~40 payroll/identity/document fields | nullable | (a) hide; (b) read-only extra sections in the same style | **NEEDS MY DECISION** |
| E15 | `employeeCode` vs id | `employeeCode`, `employeeId` | String, int | Keep separate; id as decimal string | Map |
| E16 | UUID string ids everywhere | integer ids | int | Use decimal string form as the domain id; never derive one from the other | Map |
| E17 | Employee list search/status filter | `page, pageSize, sort, search, statusId, departmentId, branchId` | — | Map to existing filter controls | Map |
| E18 | Full-replace PUT | `PUT` clears omitted fields | — | Adapter must send the complete object from a fresh detail read | Map (write phase only) |

### 3.5 Departments (approved UI, not built yet)

| Item | Value |
|---|---|
| Interface | `DepartmentRepository` (CARRIED; remote implementation CARRIED) |
| Baseline screen | none. Approved screens from `19a0b24` (list/detail/form), same configuration pattern. |
| Routes | `/app/hr/settings/departments`, `/new`, `/:id`, `/:id/edit` (approved) |
| Endpoints | `GET /api/departments`, `GET /api/departments/{id}`, `POST /api/departments`, `PUT /api/departments/{id}`, `POST /api/departments/{id}/deactivate` |
| Read/write | Reads only now. |
| Planned bridge | Select `RemoteDepartmentRepository` in backend mode and `LocalDepartmentRepository` in demo mode. Requires the two approved `AppPermission.department*` values and their labels (deferred to the Departments commit). |
| UI impact | The 6 approved files + registration/settings wiring only. |

| # | UI field | Backend field | Type / nullability | Decision |
|---|---|---|---|---|
| DP1 | `name` | `departmentName` | String, required | Map |
| DP2 | `status` | `statusId` / `status` | int / String | Map 1→active |
| DP3 | id (UUID string) | `departmentId` int | int | Decimal string |
| DP4 | `companyId` | not in payload | — | Use session company id |
| DP5 | `createdAt`/`updatedAt`/`syncStatus` | not returned | — | **NEEDS MY DECISION:** hide or show read-only |
| DP6 | Duplicate-name / in-use errors | `VALIDATION_ERROR`, `DEPARTMENT_IN_USE` (409) | — | Map to the approved field-error copy |

### 3.6 Shifts (approved backend-mode adaptation, not wired)

| Item | Value |
|---|---|
| Interface | `ShiftRepository extends ConfigurationRepository<Shift, ShiftDraft>` |
| Backend adapter | `RemoteShiftRepository` (CARRIED) |
| Endpoints | `GET /api/shifts`, `GET /api/shifts/{id}`, `POST /api/shifts`, `PUT /api/shifts/{id}`, `POST /api/shifts/{id}/deactivate` |
| Read/write | Reads only now. |
| Planned bridge | Select remote repository in backend mode. Approved Shifts UI change already defines which controls are hidden. |
| UI impact | Only the 4 approved shift files (+ approved Early punch l10n). No route change. |

| # | UI field | Backend field | Type | Decision |
|---|---|---|---|---|
| SH1 | `name` | `shiftName` | String, required | Map |
| SH2 | `startTime` / `endTime` | `startTime` / `endTime` `HH:mm:ss` | String | Map to `LocalTime` |
| SH3 | `gracePeriodMinutes` | `lateGraceMinutes` | int (default 15) | Map |
| SH4 | (new, approved) Early punch | `earlyPunchInMinutes` | int 0–120 | Approved |
| SH5 | `code` | not in payload | — | Hidden in backend mode (approved) |
| SH6 | `workingDays` | not in payload | — | Hidden in backend mode (approved); new shifts default to all days |
| SH7 | break mode / break minutes / minimum work / expected work | not in payload | — | Hidden in backend mode (approved) |
| SH8 | `status` | `statusId` / `status` | int / String | Map |
| SH9 | id (UUID string) | `shiftId` int | int | Decimal string |
| SH10 | `activeAssignments` | `activeAssignments` | int | **NEEDS MY DECISION:** show read-only, hide, or use for deactivate warning |

### 3.7 Attendance

| Item | Value |
|---|---|
| Interface | `AttendanceRepository` (today/current/history/day details/events/execute/retry) |
| Backend adapter | planned read-only adapter over `AttendanceApi` (CARRIED domain `AttendanceDay`) |
| Endpoints | `GET /api/attendance/today`, `POST /api/attendance/punch` |
| Read/write | Only `GET /today` is in scope. Punch is a write and stays disabled. |
| Planned bridge | `watchCurrentAttendance`/`getCurrentAttendance` map `AttendanceDay` into `AttendanceContext`; history/corrections/team/all have **no backend endpoints** and keep local data or show the existing empty/error states. |
| UI impact | None to files. |

| # | UI field / behaviour | Backend field | Type | Decision |
|---|---|---|---|---|
| AT1 | State card (not started / working / break / complete) | `state` | String | Map to the existing state enum; unknown → fail closed |
| AT2 | Action buttons | `allowedActions[]` | List<String> | Map to existing action widgets; hide actions not listed (visibility predicate only) |
| AT3 | Timeline shifts and punches | `shifts[]` (`shiftNo`, `plannedStart/End`, `punchIn/Out`, `breaks[]`, `status`, `lateMinutes`) | strings / ints | Map into the existing timeline model |
| AT4 | Duration summary | `workedMinutes`, `workedHours`, `breakMinutes` | int / double | Map |
| AT5 | Sync banner, workday/location/policy context | no backend field | — | **NEEDS MY DECISION:** hide in backend mode, or keep disabled. These are local-only concepts. |
| AT6 | Server time / time zone / current & next shift | `serverTime`, `timeZone`, `currentShiftNo`, `nextShiftNo` | String/int | **NEEDS MY DECISION:** show in baseline style (extra read-only row) or hide |
| AT7 | History, corrections, requests, team, all pages | no endpoints | — | **NEEDS MY DECISION:** keep local data in backend mode, hide entries, or block with the existing empty/error state. Freeze forbids removing routes. |
| AT8 | Punch-in/out/break/resume | `POST /punch` | write | Out of scope this phase. |
| AT9 | Employee id / date | `employeeId` int, `date` | int / String | Decimal string / ISO date |

### 3.8 Access & Users

| Item | Value |
|---|---|
| Interface | `AccessRepository` (local, reads + replaceGrants) |
| Backend data carried | `EffectiveAccess`, `EffectiveAccessSource`, `RemoteEffectiveAccessRepository`, `RemotePermissionMasterRepository`, permission DTOs (CARRIED) |
| Endpoints | `GET /api/me/permissions`, `GET /api/permissions`, `GET /api/user-permissions`; write endpoints documented but disabled |
| Planned bridge | `/me/permissions` feeds `BackendAccessPolicy.resolve` and `SessionPermissionSink` (session permissions only). The Users list/detail keeps local reads until a read-only remote adapter is approved. Permission catalog is NEW (not built). |
| UI impact | None to files. Chips/labels stay baseline. |

| # | UI behaviour | Backend | Decision |
|---|---|---|---|
| AC1 | Users list built from local accounts + employees | `GET /api/user-permissions` returns grants, not a user directory | **NEEDS MY DECISION:** derive users from grants (only users with at least one grant), keep local accounts, or add a read-only grants summary to the existing local list. |
| AC2 | Module chips on user rows | key-only grants, no scopes | **NEEDS MY DECISION:** keep module chips and derive from keys, or switch to feature-path chips (not approved as a UI change). |
| AC3 | Scope selector (self/team/all) | no scopes | Keep SELF for self keys, ALL for other keys (documented data assumption). **NEEDS MY DECISION:** confirm. |
| AC4 | Save/assign grants | `POST/PUT /api/user-permissions` (writes) | Out of scope. Keep disabled. |
| AC5 | Last-admin / self-escalation warnings | backend policy is intended-allow | Keep existing local warnings; **NEEDS MY DECISION** whether they still apply in backend mode. |
| AC6 | Orphan grants (permission master deleted) | `permissionKey: null`, `permissionStatusId: 2` | Read-only display is not in baseline UI. **NEEDS MY DECISION:** ignore, or show in the existing list style later. |
| AC7 | Permission catalog screen | `GET /api/permissions` | NEW screen; not built. |

---

## 4. Permission mapping (data only)

Source: `lib/core/security/backend_access_policy.dart` (CARRIED, temporary reduced map) and `lib/platform/access/domain/effective_access.dart`.

| Backend key | AppPermission | Derived module | Visibility effect |
|---|---|---|---|
| `hr.employees.view` | `employeeViewAll` (scope ALL) | employees | Employees nav entry + list/detail buttons |
| `hr.employees.create` | `employeeCreate` | employees | Add employee button |
| `hr.employees.edit` | `employeeUpdate` | employees | Edit employee button |
| `hr.employees.deactivate` | `employeeDeactivate` | employees | Activate/deactivate action |
| `hr.attendance.self.view` | `attendanceViewSelf` | attendance | Attendance nav entry |
| `hr.attendance.self.punch` | `attendancePunchIn`, `attendancePunchOut`, `attendanceBreak` | attendance | Punch/break/resume action buttons |
| `hr.attendance.shifts.view` | `shiftView` | settings | Shifts settings destination |
| `hr.attendance.shifts.manage` | `shiftManage` | settings | Shift add/edit/deactivate actions |
| `company.access.users.view` | `accessUsersView` | settings | Access & Users entry |
| `company.access.permissions.manage` | `accessPermissionsManage` | settings | Grant editing / permission catalog actions |
| `company.users.manage` | `userManage` | employees | Account-management actions |

Deferred until their modules are approved (documented in the policy comment):

| Backend key | AppPermission | Module |
|---|---|---|
| `company.branches.view` / `manage` | `companyBranchView` / `Manage` | Branches (NEW) |
| `hr.departments.view` / `manage` | `departmentView` / `Manage` | Departments (approved UI, next phase) |

Rules:

* Unknown keys are ignored and reported (`unknownKeys`).
* Module entitlement is derived from granted keys: `employees`, `attendance`, `settings`. Dashboard and profile are always available.
* The mapping changes **only** `requiredPermissions` predicates already present on destinations, routes and buttons. It does not add, remove or reorder destinations.
* No scopes exist on the backend; a key-only grant is treated as ALL for scoped client permissions, SELF for self-service keys.

---

## 5. NEW modules (listed, **not built**)

| Module | Baseline screen | Proposed route(s) | Endpoints | Permission | Build order |
|---|---|---|---|---|---|
| Branches (Company) | none | `/app/settings/branches` (+ list/detail/form routes in the Departments pattern) | `/api/branches/lookups`, list, get, create, update, activate, deactivate | `companyBranchView` / `companyBranchManage` (enum + labels deferred) | Last, after Departments |
| Employee Shifts | none | `/app/hr/employee-shifts` (+ list/detail/form routes in the Departments pattern) | `/api/employee-shifts` list/create/update/deactivate | `hr.attendance.shifts.view` / `manage` | Last, after Shifts |
| Permission catalog | none | `/app/settings/access/permissions` (+ list/detail/form routes in the Departments pattern) | `/api/permissions` list/get/create/update/activate/deactivate | `company.access.users.view` / `company.access.permissions.manage` | Last, after Access |

These must follow the approved Departments page/route pattern (list → detail → form as routes, not dialogs) when they are built. They are explicitly out of scope for this phase.

---

## 6. Planned order after the decisions

1. Departments: add the two approved permission values + labels, local repository, approved screens/wiring; wire remote/local selection behind `DepartmentRepository`; reads only.
2. Shifts: select `RemoteShiftRepository` in backend mode; apply the approved shift UI changes; reads only.
3. Employees: read-only `EmployeeRepository` adapter over `LiveEmployeeRepository`; resolve E1–E18 decisions first.
4. Attendance: read-only `AttendanceRepository` adapter for today/current; resolve AT5–AT7.
5. Access & Users: session permission loading via `RemoteEffectiveAccessRepository`; read-only grant view; resolve AC1–AC6.
6. NEW modules: Branches, Employee Shifts, Permission catalog — last, one at a time.
7. Demo/local removal: separate, module-by-module, after live verticals are accepted.

Every step must keep `dart run tool/ui_freeze_check.dart` green and the full suite at the known baseline failure (`localization_test` source scan).

---

## 7. Decision register (blocking)

| ID | Decision |
|---|---|
| A1 | Allow plain `loginId` input in the frozen identifier field? |
| A2 | Accept hiding the demo-accounts button in backend mode (empty list)? |
| A3 | Model `branches[]` now or keep single branch? |
| A4 | Profile "Email" shows `loginId`: acceptable? |
| D1/D2 | Dashboard in backend mode: zero/empty real data or keep demo numbers in demo mode only? |
| E1 | One full-name field vs split into first/middle/last? |
| E2 | Nullable email: show empty, placeholder, or require? |
| E5 | Designation: text, selector, or hidden? |
| E6 | Manager: read-only text or hidden? |
| E7 | Employment type: map to backend strings, read-only, or hidden? |
| E9 | Shift/work location/policy fields: hide or read-only? |
| E10 | Avatar/photo: hide or read-only path? |
| E12 | Created/updated/sync metadata: hide? |
| E13 | Employee login section: read-only or editable (writes deferred)? |
| E14 | Which extra payroll/identity/document fields to show read-only? |
| DP5 | Department created/updated/sync metadata: hide or read-only? |
| SH10 | Shift `activeAssignments`: show read-only, hide, or use in deactivate warning? |
| AT5 | Local-only attendance context (sync/workday/location/policy): hide or disabled? |
| AT6 | Show server time/time zone/current & next shift in baseline style? |
| AT7 | Attendance history/corrections/requests/team/all with no endpoint: keep local, hide entries, or block? |
| AC1 | Access users list source in backend mode: grants-derived, local account directory, or hybrid? |
| AC2 | Keep module chips or switch to feature-path chips? (UI change if switched) |
| AC3 | Confirm key-only grant = ALL (except self keys). |
| AC5 | Keep last-admin/self-escalation warnings in backend mode? |
| AC6 | Show orphan grants? |
| NEW | Approve building Branches / Employee Shifts / Permission catalog later in the Departments pattern? |
