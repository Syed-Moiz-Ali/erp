# Integration map — API v3 (UI frozen at `ac2ec6f`)

**Branch:** `feat/api-v3` (from `ac2ec6f`)
**UI baseline:** `ac2ec6f` (tip of `services_module`, 2026-10-08), enforced by `tool/ui_freeze_check.dart`.
**Status:** integration map. Departments, Shifts, Employees and Attendance's today/punch paths have backend repositories selected by DI; no live write is performed and no screen is modified. Remaining decisions are listed per module.

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
| Backend adapter | `RemoteEmployeeRepository` (`lib/modules/hr/employees/live/data/repositories/remote_employee_repository.dart`, NEW and selected by DI) over the carried `LiveEmployeeRemoteDataSource` (Dio implementation + DTOs) |
| Endpoints | `GET /api/employees/lookups`, `GET /api/employees`, `GET /api/employees/{id}`, `POST /api/employees`, `PUT /api/employees/{id}`, `POST /api/employees/{id}/activate|deactivate` |
| Read/write | Reads are wired end to end. Create/update/activate/deactivate are wired in the data layer with the documented bodies; no live write is executed in this phase. |
| Planned bridge | DI selects `RemoteEmployeeRepository` when `AppConfig.realApiEnabled`, otherwise `LocalEmployeeRepository` (demo). `watchEmployees`/`watchEmployee` emit an initial fetch and re-fetch after any successful write through a broadcast revision stream. The screen stays the baseline list/detail/form. |
| UI impact | None to files. |

**Wired mapping (data-only):**

* Domain id is the decimal `employeeId`; `employeeCode` stays separate. `companyId` comes from the session.
* `employeeName` → `firstName`; middle/last stay empty. Null `email`/`phone` → empty strings.
* `departmentId` is the decimal string (`''` when absent); `designation` is carried as `designationId` text; `reportingManager` → `managerId`.
* `statusId == 1` → active, otherwise inactive. `joiningDate` parses ISO; missing → `DateTime.utc(1970,1,1)`. `createdAt`/`updatedAt` use the same UTC epoch sentinel and `syncStatus` is `synced`.
* Login: `login.userId` → `linkedUserId`, `login.enabled` → `loginEnabled`; shift/work-location/attendance-policy ids stay null.
* List query: `query` → `search` (trimmed), status → `statusId` 1/2, department → `departmentId`; `branchId` is never sent. Page 0 → server page 1.
* Sort: `nameAscending` → `nameAsc`, `nameDescending` → `nameDesc`, `code` → `codeAsc`, `newestJoined` → `newest`. **`oldestJoined` is unsupported by the backend; it is never sent, `nameAsc` is used instead.**
* `EmployeePageData.total` and `.filtered` both use the backend `totalItems`.
* `getReferences` exposes backend departments as `WorkforceReference(id.toString(), name)`; designations/managers/shifts/work locations/policies are empty in backend mode.
* `getLinkedAccount` maps `login` into `UserAccount` (id = `login.userId`, displayName = `employeeName`, email = `loginId ?? ''`, phone = `mobileNo`, permissions empty, status active while login is enabled). `credentialPending = !(loginEnabled && canLogin)`; no `login.userId` → `Success(null)`.
* Availability checks have no endpoint and return `Failure(code: 'unsupported', kind: notConfigured)`.
* Create sends only `employeeName`, `statusId`, `departmentId`, `designation`, `joiningDate`, `email`, `uaeContactNumber`, and `login` only when login is enabled (`enabled`, `loginId` from email, `mobileNo` from phone, `branchIds: []`); `login.userType` is never sent. Required backend fields the frozen form does not collect are deliberately omitted so a real 400 surfaces.
* Update is a full replace: a fresh `GET` is loaded, every loaded field is copied, only the form fields (name, department, designation, joining date, email, phone, status, `login.enabled`) are overlaid, and `login.userType` is stripped. No loaded field is dropped.
* `POST /api/employees/{id}/activate` and `/deactivate` back `setActive`; success bumps the revision.

**NEEDS-UI-DECISION (recorded, not invented):**

* The frozen employee create/edit form does not collect required backend fields (`branchId`, `nationalityId`, date of birth, marital status, gratuity, working hours, salary, transport, accommodation). The data layer sends only the collected fields; the backend validation error is allowed to surface.
* The frozen form has no login password or branch multi-select controls. Create sends login from email/phone with `branchIds: []` and an empty `password` value because the form cannot collect one; update only toggles `login.enabled`. A UI decision is needed before credential writes can succeed.
* `oldestJoined` has no backend sort; the list silently falls back to `nameAsc`.
* The backend provides no designation lookup, so `getReferences.designations` is empty and `designation` remains free text.


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
| Backend adapter | `RemoteAttendanceRepository` (`lib/modules/hr/attendance/live/data/remote_attendance_repository.dart`) over the small `AttendanceApiClient` seam implemented by `AttendanceApi`; selected by DI when `AppConfig.realApiEnabled`, otherwise `LocalAttendanceRepository` stays for demo. |
| Endpoints | `GET /api/attendance/today`, `POST /api/attendance/punch` (`action: punchIn|break|resume|punchOut`, optional `latitude`/`longitude`). |
| Read/write | WIRED: today/current read, punch execute, company attendance date. DATA-ONLY: punch result re-mapped into the existing context. No live punch is executed in tests. |
| Bridge | `getCurrentAttendance`/`watchCurrentAttendance` map the payload through `RemoteAttendanceMapper`. States: `noShift|waitingForShift|readyToPunchIn -> notStarted`, `working`, `onBreak`, `completed`; any other state fails closed with `invalidAttendanceState`. `allowedActions[]` is authoritative via `AttendanceContext.allowedActions`; omitted actions are disabled by the existing engine/BLoC path. Shifts/breaks/punches/minutes map into the existing timeline and context. |
| UI impact | None to files. `AttendanceContext.allowedActions` and the engine's remote branch are data-only additions; no page/widget changed. |

**WIRED (backend mode):** today state, allowed actions, shifts timeline (shiftNo, planned start/end, punch in/out, breaks, status, late/worked/break minutes, current/next shift), punch action body with location evidence, company attendance date, and punch error envelopes (`DAY_COMPLETE -> alreadyCompleted`, `ATTENDANCE_NO_SHIFT -> shiftNotAssigned`, location errors -> `locationRequired`/`invalidLocationEvidence`, auth/permission errors -> `permissionDenied`/session-expired).

**EMPTY / UNSUPPORTED (correct in backend mode):** there is **no attendance history, correction, request, team or all-employees endpoint**. `getAttendanceHistory`/`watchAttendanceHistory` return an empty `AttendanceHistoryPageData`; `getAttendanceDayById`/`watchAttendanceDayById` and `getAttendanceForDate` return `Success(null)`; `watchAttendanceEvents` returns an empty list; `retryPendingOperation` returns `unsupported`. The adapter never reads or fabricates local attendance rows.

**NEEDS-UI-DECISION (recorded, not invented):**

* The payload supplies no `Shift`/`AttendancePolicy`/`WorkLocation` configuration. The adapter derives only the shift name/times present in `shifts[]` and uses inert policy defaults plus remote work mode so the existing context can be built and coordinates are still captured. Shift grace/expected-work and the local sync/location panels have no backend source.
* `serverTime`, `timeZone`, `currentShiftNo`, `nextShiftNo` are mapped into the context but the frozen UI has no dedicated row for them (AT6).
* Multiple punched shifts cannot be represented by the local single-cycle event summary. Events are built from all shifts when the summary matches the backend state, otherwise from the current/primary shift only; full multi-shift timeline display needs a UI decision.
* Backend `allowedActions` is authoritative through the engine's remote branch; there is still no separate UI element showing why an action was omitted.

| # | UI field / behaviour | Backend field | Type | Decision |
|---|---|---|---|---|
| AT1 | State card (not started / working / break / complete) | `state` | String | Map to the existing state enum; unknown → fail closed |
| AT2 | Action buttons | `allowedActions[]` | List<String> | **WIRED:** mapped to `AttendanceEventType`; omitted actions are disabled by the engine's remote branch. |
| AT3 | Timeline shifts and punches | `shifts[]` (`shiftNo`, `plannedStart/End`, `punchIn/Out`, `breaks[]`, `status`, `lateMinutes`) | strings / ints | **WIRED data-only:** mapped into the existing timeline/context; multi-shift cycles are a NEEDS-UI-DECISION. |
| AT4 | Duration summary | `workedMinutes`, `workedHours`, `breakMinutes` | int / double | Map |
| AT5 | Sync banner, workday/location/policy context | no backend field | - | **NEEDS-UI-DECISION:** the adapter uses inert defaults; the frozen panels have no backend source. |
| AT6 | Server time / time zone / current & next shift | `serverTime`, `timeZone`, `currentShiftNo`, `nextShiftNo` | String/int | **NEEDS-UI-DECISION:** mapped data-only; no dedicated baseline row. |
| AT7 | History, corrections, requests, team, all pages | no endpoints | - | **WIRED empty:** no endpoint exists; the adapter returns the existing empty/unsupported results and never reads the local DB. |
| AT8 | Punch-in/out/break/resume | `POST /punch` | write | **WIRED data layer:** action + latitude/longitude; tests use an in-memory fake, no live punch. |
| AT9 | Employee id / date | `employeeId` int, `date` | int / String | Decimal string / ISO date |

### 3.8 Access & Users

| Item | Value |
|---|---|
| Interface | `AccessRepository` - `LocalAccessRepository` in demo/disabled, `RemoteAccessRepository` in backend mode |
| Backend adapter | `RemoteAccessRepository` (NEW, selected by DI when `AppConfig.realApiEnabled`) over `AccessAdminRemoteDataSource`; `RemotePermissionMasterRepository` is registered in backend mode only. `RemoteEffectiveAccessRepository` and `/api/me/permissions` behaviour are unchanged. |
| Endpoints | `GET /api/me/permissions`, `GET /api/permissions`, `GET /api/user-permissions`, `GET /api/user-permissions/{id}`. Data-only write mappings: `POST /api/user-permissions` (`{userId, permissionIds}`), `PUT /api/user-permissions/users/{userId}` (`{permissionIds}`), `DELETE /api/user-permissions/{id}`. No live write is performed in this phase. |
| Read/write | `/me/permissions` feeds `BackendAccessPolicy.resolve` and `SessionPermissionSink`. Access reads come from grants and permission masters; write mappings are exercised only by tests. |
| Users list | Grants-derived only, grouped by `userId`; only users with at least one key-bearing, non-inactive grant (`permissionKey != null`, `permissionStatusId != 2`). Orphan rows are excluded. |
| Scope mapping | Self-service keys (`hr.attendance.self.punch`, `hr.attendance.self.view`) map to `PermissionScope.self`; every other key maps to `PermissionScope.all`. The backend stores no scopes, so this is an explicit, documented data assumption (AC3). |
| History | `watchHistory` always returns an empty list: there is no access-history endpoint and backend mode never reads the local Drift activity log. |
| UI impact | None to files. Chips/labels stay baseline. |

| # | UI behaviour | Backend | Decision |
|---|---|---|---|
| AC1 | Users list built from local accounts + employees | `GET /api/user-permissions` returns grants, not a user directory | Resolved data-only: users are derived from key-bearing grants. |
| AC2 | Module chips on user rows | key-only grants, no scopes | **NEEDS-UI-DECISION:** keep module chips and derive from keys, or switch to feature-path chips (not approved as a UI change). |
| AC3 | Scope selector (self/team/all) | no scopes | Resolved: SELF for self-service keys, ALL for other keys. |
| AC4 | Save/assign grants | `POST/PUT/DELETE /api/user-permissions` (writes) | Data-only mappings wired; live writes remain out of scope. |
| AC5 | Last-admin / self-escalation warnings | backend policy is intended-allow | Kept client-side; `GrantAuthorityResolver` is never bypassed. **NEEDS-UI-DECISION** whether they still apply in backend mode. |
| AC6 | Orphan grants (permission master deleted) | `permissionKey: null`, `permissionStatusId: 2` | Data-only: excluded from users/grants. Read-only display is not in baseline UI. **NEEDS-UI-DECISION:** ignore, or show in the existing list style later. |
| AC7 | Permission catalog screen | `GET /api/permissions` | **NEEDS-UI-DECISION:** NEW screen; not built. The repository is registered in backend mode only; no local permission-master implementation exists. |
| AC8 | Access history / audit trail | no endpoint | **NEEDS-UI-DECISION:** history stays empty; no backend source exists. |
| AC9 | Branch permission enum / labels | branch keys deferred | **NEEDS-UI-DECISION:** enum values and labels are deferred until the Branches module is approved. |

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
3. Employees: `RemoteEmployeeRepository` wired for reads and data-only writes; remaining E-items are recorded under NEEDS-UI-DECISION.
4. Attendance: read-only `AttendanceRepository` adapter for today/current; resolve AT5–AT7.
5. Access & Users: session permission loading via `RemoteEffectiveAccessRepository`; read-only grant view; resolve AC1–AC6.
6. NEW modules: Branches, Employee Shifts, Permission catalog — last, one at a time.
7. Demo/local removal: separate, module-by-module, after live verticals are accepted.

Every step must keep `dart run tool/ui_freeze_check.dart` green and the full suite at the known baseline failure (`localization_test` source scan).

---

## 7. Decision register

`BLOCKER` marks the items that block the first integration step (Auth + permission
loading). Dashboard follows Auth because it is the post-login landing and has no
endpoint; the remaining groups follow the integration order you gave.

| ID | Module | Question (one line) | Options | Your recommended option | Why (one line) | UI impact |
|---|---|---|---|---|---|---|
| **A1** BLOCKER | Auth | Accept a plain `loginId` in the frozen identifier field? | (a) accept loginId; (b) keep email/phone only; (c) add a separate login-id field | (a) accept loginId | The backend authenticates by loginId and the existing parser can accept it | none |
| A2 | Auth | Hide the demo-accounts button in backend mode via the existing empty-list conditional? | (a) hide when the list is empty; (b) always show; (c) remove the dialog | (a) hide when the list is empty | Zero widget change; demo mode keeps its accounts | none |
| A3 | Auth | Model all `branches[]` or keep the single branch? | (a) single branch now; (b) extend the session model with the list | (a) single branch now | Least data change; the list can be added later | none |
| A4 | Auth/Profile | Show `loginId` in the existing "Email" row? | (a) map loginId into that row; (b) add a separate read-only login row; (c) leave blank | (a) map loginId into that row | No layout change and the value is the real login identity | none |
| A5 | Auth | Map access and refresh expiry into the session? | (a) both expiries; (b) access expiry only | (a) both expiries | Needed for correct refresh and invisible to the UI | none |
| D1 | Dashboard | What data does the dashboard show in backend mode? | (a) zero/empty in all modes; (b) demo numbers only in demo mode, zero in backend; (c) demo numbers in backend too | (b) demo only, zero in backend | Keeps the demo experience and never shows fake live numbers | none |
| DP5 | Departments | Show department created/updated/sync metadata? | (a) hide; (b) add read-only fields | (a) hide | The approved page has no metadata fields; hiding keeps it identical | none |
| SH10 | Shifts | Show `activeAssignments`? | (a) hide; (b) add a read-only count; (c) use it in the deactivate warning | (a) hide | No baseline field; hiding keeps the approved detail page unchanged | none |
| E1 | Employees | Split the name or keep three inputs? | (a) map the full name to firstName and leave middle/last blank; (b) split on spaces; (c) replace with one full-name input | (a) map to firstName | Keeps the three baseline inputs and their layout | none |
| E2 | Employees | How to show a null email? | (a) show empty; (b) placeholder text; (c) require before save | (a) show empty | The existing input and copy stay unchanged | none |
| E5 | Employees | Designation comes as free text? | (a) read-only text in the existing field; (b) editable free text in the same field; (c) hide | (a) read-only text | Keeps the field and position without inventing a lookup | read-only field |
| E6 | Employees | Manager comes as free text? | (a) read-only text in the existing field; (b) hide; (c) keep an empty selector | (a) read-only text | Keeps the baseline row and field position | read-only field |
| E7 | Employees | Employment type is a backend string? | (a) map the strings into the existing dropdown; (b) read-only; (c) hide | (a) map into the dropdown | Same control and position; no layout change | none |
| E9 | Employees | Shift/work location/policy are absent from the payload? | (a) hide the three fields; (b) read-only context in the same fields | (b) read-only context | Preserves the form layout; hiding removes three controls | read-only field |
| E10 | Employees | What about photo/avatar? | (a) ignore `photoPath` so the initials avatar stays; (b) read-only path text | (a) ignore `photoPath` | The baseline avatar uses initials, so there is no visual change | none |
| E12 | Employees | Created/updated/sync metadata? | (a) hide the sync badge and metadata; (b) show read-only | (a) hide | The backend returns none; avoids empty or wrong badges | hide field |
| E13 | Employees | Employee login section? | (a) read-only in the existing fields; (b) editable with writes deferred; (c) hide | (a) read-only | Keeps the baseline section and layout; writes are out of scope | read-only field |
| E14 | Employees | Extra payroll/identity/document fields? | (a) hide all; (b) add read-only sections | (a) hide all | No new sections; the baseline style is unchanged | none |
| AT5 | Attendance | Local-only sync/workday/location/policy context? | (a) hide; (b) keep but disabled; (c) keep as-is | (a) hide | The backend has no such data; hiding avoids stale local context | hide field |
| AT6 | Attendance | Server time, time zone, current and next shift? | (a) hide; (b) add read-only values in the summary style | (a) hide | No baseline element exists; hiding keeps the screen identical | none |
| AT7 | Attendance | History/corrections/requests/team/all have no endpoint? | (a) keep local data in backend mode; (b) hide nav entries; (c) show the existing empty/error state | (c) existing empty/error state | Keeps all routes, nav and pages; no local/live data mix | none |
| AC1 | Access | Users list source in backend mode? | (a) grants-derived only; (b) local directory only; (c) local directory plus grants-derived rows | (c) hybrid | Same list widgets and shows every grant holder | none |
| AC2 | Access | Module chips or feature-path chips? | (a) keep module chips, derive from keys; (b) switch to feature-path chips | (a) keep module chips | No visual change; derivation is data-only | none |
| **AC3** BLOCKER | Access | Confirm key-only grant = ALL except self keys? | (a) confirm ALL; (b) SELF everywhere; (c) no scopes | (a) confirm ALL | Only truthful reading; unblocks the `/api/me/permissions` mapping | none |
| AC5 | Access | Keep last-admin/self-escalation warnings? | (a) keep; (b) hide; (c) keep with backend-authoritative text | (a) keep | No layout change and the warnings stay useful | none |
| AC6 | Access | Orphan grants? | (a) ignore for now; (b) add a read-only row in the existing list style | (a) ignore | Avoids new UI until Access is integrated | none |
| NEW | New screens | Build Branches, Employee Shifts and Permission catalog now or last? | (a) build last, one at a time, in the Departments pattern; (b) build now; (c) skip | (a) build last | No baseline screens; protects the freeze and the first steps | new screen |
