# PHASE 0 — ERP Backend API Integration Audit

**Project:** `modular_erp` (Bitlogix ERP) — Flutter 3.35.7 / Dart 3.9.2
**Scope:** HR + Branches + Authentication (the modules exposed by the supplied backend). Services is out of scope.
**Baseline commit audited:** `ac2ec6f` ("Add Shifts & Shift Assignment API documentation and UI-7 specialized workspaces")
**Nature:** Analysis only. No production code changed, no API implemented, no schema/dependency changes.
**Inputs:** `../audit-output/massep-2026-10-28/` (API inventory, test results, permission matrix and response-contract audit), plus the entire existing Flutter project.

> **Update 2026-10-09:** The supplied backend is the MassERP contract (`/api/...`, integer IDs, `{success,message,data,errors}` envelope). The earlier internal spec `docs/backend/hr_backend_api_requirements.md` (`/api/v1`, UUIDs, `meta`, outbox protocol) was **not** implemented by the backend and is treated as void for this integration.

---

## 1. Executive findings

1. **The app makes no remote API calls today.** `Dio` is only imported in `lib/core/api/api_client.dart`. `ApiClient` is registered in DI but resolved nowhere; it implements **only `get`**, has no POST/PUT, and no feature repository uses it.
2. **Authentication is demo-only.** The single `AuthRepository` implementation is `DemoAuthRepository` (`lib/platform/auth/data/repositories/demo_auth_repository.dart`). Release builds get `demo_disabled` and cannot log in at all. There is no real login, refresh, or server logout.
3. **The networking layer is a scaffold, not an implementation.** `AuthenticationInterceptor` only attaches a Bearer token; a code comment explicitly defers refresh/invalidation (`api_client.dart:25`). `ApiErrorMapper` maps any 401 to `sessionExpired` and never parses the backend error envelope.
4. **A latent session bug blocks refresh even when it exists.** `SecureSessionStorage._token` (`secure_session_storage.dart:30-43`) returns a token only while the envelope `expiresAt` is in the future — so the 30-day refresh token becomes unreadable once the 60-minute access token expires.
5. **The backend contract and the app's domain model are structurally different.** Backend uses **integer IDs** and a nested `data` envelope; the app uses **UUID strings**, its own `AuthContext`, and its own DTOs. A per-feature anti-corruption layer is mandatory.
6. **Several backend modules have no Flutter feature at all:** Departments (only a Drift table + references), Branches/Company, and Employee-Shift assignments. Employees/Shifts/Attendance exist only as **local-first Demo/Drift** implementations.
7. **The app has no source for its permission model from this backend.** Login returns only `transactionAccess`, `reportAccess`, `userType` and `branches[]` — no permission list. The app gates every route on `AppPermission` + scope (`lib/core/security/*`).
8. **Local-first + outbox is extensive but has no sender.** `SyncCoordinator`, `AttendanceSyncHandler`, `AttendanceRemoteSender`, `SyncTransport` exist, but **no handler is registered** and no transport is wired (`bootstrap.dart` comment: "No handlers are registered until a real transport is configured").
9. **Baseline is green except one pre-existing failure.** `flutter pub get` OK; `dart analyze` clean; `flutter test` = **+1204 passed / 1 failed** — a pre-existing source-scan failure in `test/localization_test.dart` (`lib/modules/hr/leave/presentation/pages/holiday_pages.dart:336`, `label: '$year'`). This failure predates any integration work (verified by stashing).

**Overall readiness:** The layered architecture (UI → BLoC → repository → data source, GetIt DI, Freezed models, module registry, permission system, outbox) is a **solid, reusable foundation**. Integration should **add remote data sources behind existing repository interfaces** and a proper networking/auth core — not rewrite the architecture.

---

## 2. Current architecture

### 2.1 Composition and scale
- Package: `modular_erp`, `pubspec.yaml:1`. Flutter 3.35.7 / Dart 3.9.2.
- Key deps: `dio ^5.11.1`, `drift ^2.29.0`, `flutter_bloc ^9.1.1`, `go_router ^17.2.3`, `get_it ^9.2.1`, `freezed ^3.1.0` / `freezed_annotation ^3.1.0`, `json_annotation ^4.9.0`, `flutter_secure_storage ^10.3.4`, `connectivity_plus`, `geolocator`.
- ~471 hand-written Dart files under `lib/` (excluding `*.g.dart` / `*.freezed.dart`); ~70 test files under `test/`.

### 2.2 Layering (per feature)
`UI (pages/widgets) → BLoC/Cubit → optional use case (application/) → repository interface (domain/) → local/remote data source (data/)`.
- Repositories are the declared source of truth; widgets/BLoCs never import Dio or Drift (README claims this is enforced by convention).
- Configuration masters share `ConfigurationRepository<T,D>` and `LocalConfigurationRepository<T,D>`.

### 2.3 Core infrastructure (`lib/core/`)
| Area | Path | State |
|---|---|---|
| API client | `lib/core/api/api_client.dart` | GET-only, unused, interceptor placeholder |
| Session storage | `lib/core/storage/secure_session_storage.dart` | Working, but expiry-gating bug for refresh token |
| Results/failures | `lib/core/errors/result.dart`, `failure_localization.dart` | `Result<T>`/`Failure`/`FailureKind` |
| Database | `lib/core/database/app_database.dart` | Drift, **schema v18**, additive migrations |
| Sync/outbox | `lib/core/sync/*` | `SyncCoordinator`, `OutboxRepository`, `PendingMutation`, retry policy, conflicts; **no registered handler** |
| Connectivity | `lib/core/connectivity/*` | Link state only (not server reachability) |
| Location | `lib/core/location/*` | Permission/location capture |
| Security | `lib/core/security/*` | `AppPermission`, catalog, `PermissionScope` (SELF/ASSIGNED/TEAM/ALL) |
| Localization | `lib/l10n/*` + `tool/l10n/*` | Custom ARB merge + `flutter gen-l10n` |

### 2.4 Authentication (baseline)
- Domain: `lib/platform/auth/domain/entities/auth_context.dart` — `AuthContext{user, company, employeeReference, settings}`, `AuthSession{accessToken, refreshToken, expiresAt, context}` (tokens deliberately excluded from Bloc state).
- Repository interface: `lib/platform/auth/domain/repositories/auth_repository.dart` — `restoreSession`, `checkSession`, `login(AuthIdentifier, password)`, `logout`, `requestPasswordReset`, `changePassword`, `sessionChanges`, `dispose`.
- Only implementation: `DemoAuthRepository` (5 seeded accounts, in-memory tokens prefixed `demo-access-`/`demo-refresh-`, 8-hour expiry, local-only logout).
- DTO: `lib/platform/auth/data/dto/auth_session_dto.dart` + generated `*.g.dart` (app-owned envelope: `version, accessToken, refreshToken, expiresAt, user, company, employee, settings`).
- Identifier: `lib/core/auth/auth_identifier.dart` — **email/phone only** (backend wants `loginId`).
- State: `AuthBloc` (`lib/platform/auth/presentation/bloc/auth_bloc.dart`) drives `initial/bootstrapping/unauthenticated/authenticating/authenticated`; GoRouter guard in `lib/app/router/app_router.dart` (`authRedirect`, `AuthRouterRefresh`).
- Config: `lib/app/app_config.dart` — `demoAuthEnabled = bool.fromEnvironment('DEMO_AUTH', defaultValue: !kReleaseMode)`.

### 2.5 DI (`lib/bootstrap/*`)
- `configureCoreDependencies` registers `SessionStorage`, **`ApiClient` (unused)**, `AppDatabase`, outbox, connectivity, sync, prefs, locale.
- `configurePlatformDependencies` registers `AuthRepository → DemoAuthRepository` (source only in demo).
- `configureHrDependencies` registers all HR repositories as `Local*` implementations.
- `configureApplicationComposition` builds the `ModuleRegistry`.

### 2.6 HR modules (`lib/modules/hr/*`)
`employees`, `shifts`, `work_locations`, `attendance_policies`, `attendance` (engine + data + read/report repos), `leave`, `reports`, `dashboard`, `access`, `demo`, `module`, `l10n`.
- Employees tables: `WorkforceDepartments`, `WorkforceDesignations`, `WorkforceAccounts`, `WorkforceEmployees` (`employee_tables.dart`), with a `WorkforceSeeds` marker.
- Shifts table: `ShiftRecords` (minutes, working-day mask, break mode). Domain `Shift implements ConfigurationRecord`.
- Attendance: `AttendanceDays`, `AttendanceEvents`, `AttendanceCorrectionRequests`; `AttendanceEngine`, `AttendanceAuthority {demoLocal, productionPending}`.

### 2.7 Architectural problems (with references)
| # | Problem | Location |
|---|---|---|
| P1 | `ApiClient` has no mutation verbs and cannot express login/refresh/logout | `api_client.dart:81-92` |
| P2 | `ApiClient` registered but never resolved; dead entry point | `core_dependencies.dart:27-32` |
| P3 | No envelope parsing; backend `errors[].code` lost | `ApiErrorMapper.map`, `api_client.dart:36-64` |
| P4 | Refresh token unreadable after access expiry | `secure_session_storage.dart:30-43` |
| P5 | No token refresh; no single-flight lock; no session invalidation wired | `api_client.dart:25` (comment only) |
| P6 | No server logout | `demo_auth_repository.dart` `_logout` |
| P7 | Login identifier is email/phone, backend needs `loginId` | `auth_identifier.dart:7-17` |
| P8 | No request cancellation tokens | `ApiClient.get` signature |
| P9 | `AuthenticationInterceptor` masks storage read failure as `unknown` DioException | `api_client.dart:18-22` |
| P10 | No `X-Client-Platform` header | baseline interceptors |
| P11 | Sync layer has no registered handler/transport candidate | `bootstrap.dart`; `attendance_sync_handler.dart` |

---

## 3. Endpoint inventory

Legend: **Auth** = requires `Authorization: Bearer <accessToken>`. All bodies JSON (`Content-Type: application/json`). All responses use the envelope `{ success, message, data, errors[] }`. `X-Client-Platform` (`android|ios|web`) is optional on auth endpoints.

### 3.1 Authentication (`FLUTTER_LOGIN_API.md` + Postman)
| # | Endpoint | Method | Path | Auth | Request body | Response `data` | Notes / error codes | Flutter integration |
|---|---|---|---|---|---|---|---|---|
| A1 | Login | POST | `/api/auth/login` | No | `{ loginId (req, ≤100), password (req, ≤100) }` | `tokenType, accessToken, expiresIn, accessTokenExpiresAtUtc, refreshToken, refreshTokenExpiresAtUtc, user{userId, loginId, name, userType, empId?, orgId, branchName, timeZone?, orgCount, transactionAccess, reportAccess, branches[{orgId,branchName}]}` | 400 `VALIDATION_ERROR` (+`field`); 401 `AUTH_INVALID_CREDENTIALS`; 401 `AUTH_ACCOUNT_INACTIVE`; 429 `AUTH_RATE_LIMITED`; 503 `SERVICE_UNAVAILABLE`; 500 `SERVER_ERROR` | **None** |
| A2 | Refresh | POST | `/api/auth/refresh` | No | `{ refreshToken }` | Same shape as A1 ("Token refreshed.") | 401 `AUTH_REFRESH_INVALID` / `AUTH_REFRESH_EXPIRED` / `AUTH_REFRESH_REUSED` / `AUTH_ACCOUNT_INACTIVE`; 400; 429; 503 | **None** |
| A3 | Logout | POST | `/api/auth/logout` | (see ambiguity §5) | `{ refreshToken }` per MD; Postman sends empty body + bearer | always 200 `data:null` ("Logged out.") | Always 200, even for unknown token | **None** |

**Rules from the MD:** access token 60 min; refresh 30-day sliding and **rotating** (every refresh returns a new refresh token); single refresh at a time; refresh ~1 min early; retry original once; persist before use; 30-second server tolerance for double-refresh; any 401 from refresh ⇒ clear tokens; 503/network ⇒ keep tokens; login 20/min, refresh+logout 60/min per IP.

### 3.2 Employees (Postman)
| # | Endpoint | Method | Path | Auth | Parameters / body | Response `data` | Flutter integration |
|---|---|---|---|---|---|---|---|
| E1 | Lookups | GET | `/api/employees/lookups` | Yes | – | `{branches[], departments[], nationalities[], statuses[]}` (asserted by test script) | **None** |
| E2 | List | GET | `/api/employees` | Yes | `page, pageSize, sort(nameAsc\|nameDesc\|codeAsc\|newest), search, statusId?, departmentId?, branchId?` | paged `{items[], page, pageSize, totalItems, totalPages}`; item: `employeeId, employeeCode, employeeName, designation, departmentId, departmentName, branchId, branchName, uaeContactNumber, email, joiningDate, statusId, statusName, photoPath, loginEnabled, canLogin` | **None** (local `Employee` exists) |
| E3 | Get by id | GET | `/api/employees/{id}` | Yes | – | full detail (personal, contacts, IDs, bank, salary, … many nullable) | **None** |
| E4 | Create | POST | `/api/employees` | Yes | `employeeName, branchId, departmentId, nationalityId, statusId, designation, joiningDate, dateOfBirth, maritalStatus, employeeType, gratuity, uaeContactNumber, email, workingHours, basicSalary, transportation, accommodation` (+ optional) | created employee (201, `Location` header) | **None** |
| E5 | Update | PUT | `/api/employees/{id}` | Yes | same shape (Send a renamed designation etc.) | updated employee | **None** |
| E6 | Deactivate | POST | `/api/employees/{id}/deactivate` | Yes | – | employee | **None** |
| E7 | Activate | POST | `/api/employees/{id}/activate` | Yes | – | employee | **None** |

Sort/query semantics are declared in the Postman `description` fields, not in MD.

### 3.3 Branches / Company (Postman)
| # | Endpoint | Method | Path | Auth | Parameters / body | Response `data` | Flutter integration |
|---|---|---|---|---|---|---|---|
| B1 | Lookups | GET | `/api/branches/lookups` | Yes | – | `{ divisions[{id,name}], statuses["Active","InActive"], yesNo["Yes","No"], timeZones[{id,name,utcOffset}] }` | **None** |
| B2 | List | GET | `/api/branches` | Yes | `page, pageSize, sort` | paged; item has `branchId, branchName, branchCode, contactPerson, mobileNo, landLine, address, email, inventoryAlerts, multiInventory, divisionId, divisionName, status, timeZoneId, trn, logoPath, arabicLogoPath, labourCode, tradeLicense, createdBy/On, updatedBy/On` | **None** |
| B3 | Get by id | GET | `/api/branches/{id}` | Yes | – | same as B2 item | **None** |
| B4 | Create | POST | `/api/branches` | Yes | branch/company fields (division, status, timezone, etc.) | created | **None** |
| B5 | Update | PUT | `/api/branches/{id}` | Yes | branch fields | updated | **None** |
| B6 | Deactivate | POST | `/api/branches/{id}/deactivate` | Yes | – | status `InActive` | **None** |
| B7 | Activate | POST | `/api/branches/{id}/activate` | Yes | – | status `Active` | **None** |

### 3.4 Departments (`FLUTTER_DEPARTMENT_API.md` + Postman)
| # | Endpoint | Method | Path | Auth | Parameters / body | Response `data` | Errors | Flutter integration |
|---|---|---|---|---|---|---|---|---|
| D1 | List | GET | `/api/departments` | Yes | `page, pageSize, search, sort(nameAsc\|nameDesc\|newest)` | paged; item `{departmentId, departmentName, employeeCount}` | 403 `ACCESS_DENIED` | **None** (Drift table only) |
| D2 | Get | GET | `/api/departments/{id}` | Yes | – | `{departmentId, departmentName, employeeCount}` | 404 `DEPARTMENT_NOT_FOUND` | **None** |
| D3 | Create | POST | `/api/departments` | Yes | `{ departmentName (req, ≤50, unique) }` | 201 item | 400 `VALIDATION_ERROR`; 409 `DEPARTMENT_DUPLICATE_NAME` | **None** |
| D4 | Rename | PUT | `/api/departments/{id}` | Yes | `{ departmentName }` | item | 400; 404; 409 duplicate | **None** |
| D5 | Deactivate | POST | `/api/departments/{id}/deactivate` | Yes | – | item/200 | 409 `DEPARTMENT_IN_USE` when `employeeCount>0` | **None** |

Access model: HRMS-Masters privileges (view/save/edit) on the backend.

### 3.5 Shifts (`FLUTTER_SHIFT_API.md` + Postman)
| # | Endpoint | Method | Path | Auth | Parameters / body | Response `data` | Errors | Flutter integration |
|---|---|---|---|---|---|---|---|---|
| S1 | List | GET | `/api/shifts` | Yes | `page, pageSize, search, statusId(1 Active,2 InActive), sort(startTime\|nameAsc\|nameDesc\|newest)` | paged; item `{shiftId, shiftName, startTime, endTime, durationMinutes, crossesMidnight, punchInOpensAt, earlyPunchInMinutes, lateGraceMinutes, statusId, status, activeAssignments, createdOn, modifiedOn}` | 403 | **None** (local `Shift` differs) |
| S2 | Get | GET | `/api/shifts/{id}` | Yes | – | item | 404 `SHIFT_NOT_FOUND` | **None** |
| S3 | Create | POST | `/api/shifts` | Yes | `{ shiftName, startTime, endTime, earlyPunchInMinutes, lateGraceMinutes }` | 201 item | 400; 409 `SHIFT_DUPLICATE_NAME` | **None** |
| S4 | Update | PUT | `/api/shifts/{id}` | Yes | same shape | item | 400; 404 | **None** |
| S5 | Deactivate | POST | `/api/shifts/{id}/deactivate` | Yes | – | item | 409 `SHIFT_IN_USE`; 409 `SHIFT_ALREADY_INACTIVE` | **None** |
| S6 | Activate | POST | `/api/shifts/{id}/activate` | Yes | – | item | 409 `SHIFT_ALREADY_ACTIVE` | **None** |

Times are 24-hour `HH:mm`, wall-clock of the company time zone; `endTime < startTime` = overnight; equal rejected. `createdOn`/`modifiedOn` are UTC.

### 3.6 Employee Shift assignments (`FLUTTER_SHIFT_API.md` + Postman)
| # | Endpoint | Method | Path | Auth | Parameters / body | Response `data` | Errors | Flutter integration |
|---|---|---|---|---|---|---|---|---|
| ES1 | List | GET | `/api/employee-shifts` | Yes | `employeeId, shiftId, fromDate, toDate, includeInactive, page, pageSize` | paged; item `{employeeShiftId, employeeId, employeeCode, employeeName, shiftId, shiftName, fromDate, toDate, startTime, endTime, earlyPunchInMinutes, lateGraceMinutes, statusId, status, timeZoneId, punchInOpensAt, crossesMidnight}` | 403 | **None** |
| ES2 | Get | GET | `/api/employee-shifts/{id}` | Yes | – | item | 404 `EMPLOYEE_SHIFT_NOT_FOUND` | **None** |
| ES3 | Assign | POST | `/api/employee-shifts` | Yes | `{ employeeId, shiftId, fromDate, toDate, timeZoneId? }` | 201 item | 409 `EMPLOYEE_SHIFT_OVERLAP` / `EMPLOYEE_SHIFT_LIMIT` / `EMPLOYEE_SHIFT_TIMEZONE_MISMATCH` / `BRANCH_TIMEZONE_MISSING` | **None** |
| ES4 | Update | PUT | `/api/employee-shifts/{id}` | Yes | `{ shiftId?, fromDate?, toDate?, timeZoneId? }` (employee immutable) | item | 409 `EMPLOYEE_SHIFT_HAS_PUNCHES` (zone change after punch) | **None** |
| ES5 | Remove | POST | `/api/employee-shifts/{id}/deactivate` | Yes | – | item status InActive | 409 `EMPLOYEE_SHIFT_ALREADY_REMOVED` | **None** |

Max 3 shifts/employee/day; no overlaps including the early punch-in window (also across midnight); one time zone across neighbouring dates; `timeZoneId` is an IANA name.

### 3.7 Attendance (`FLUTTER_ATTENDANCE_API.md` + Postman)
| # | Endpoint | Method | Path | Auth | Parameters / body | Response `data` | Errors | Flutter integration |
|---|---|---|---|---|---|---|---|---|
| AT1 | Today | GET | `/api/attendance/today` | Yes | – | `employeeId, date, timeZone, state, allowedActions[], currentShiftNo?, nextShiftNo?, shifts[], workedMinutes, workedHours, breakMinutes, serverTime` | 403 `ATTENDANCE_NO_EMPLOYEE`/`ATTENDANCE_EMPLOYEE_INACTIVE`; 409 `BRANCH_TIMEZONE_MISSING`/`ATTENDANCE_NO_SHIFT` | **None** (local engine only) |
| AT2 | Punch (all 4 actions) | POST | `/api/attendance/punch` | Yes | `{ action: punchIn\|break\|resume\|punchOut (req), latitude?, longitude? }` | same shape as AT1 | 400 `VALIDATION_ERROR`; 409 `ATTENDANCE_SHIFT_NOT_OPEN`/`ATTENDANCE_DAY_COMPLETE`/`ATTENDANCE_INVALID_ACTION`; 503 `ATTENDANCE_BUSY` | **None** |

`state ∈ {noShift, waitingForShift, readyToPunchIn, working, onBreak, completed}`; `allowedActions` drives the buttons; times carry offsets; server clock is authoritative (request carries no time); up to 3 shifts/day; overnight shifts belong to `shiftDate`.

---

## 4. Existing-versus-missing implementation matrix

| Capability | Domain model | Repository interface | Local impl | Remote data source | DTO | UI wired | Status |
|---|---|---|---|---|---|---|---|
| Login/logout/refresh | `AuthSession`, `AuthContext` | `AuthRepository` | `DemoAuthRepository` | ❌ | app-owned `AuthSessionDto` | ✅ | **Demo only** |
| Employees | `Employee`, `EmployeeDraft`, `EmployeeFilter` | `EmployeeRepository` | `LocalEmployeeRepository` | ❌ | ❌ | ✅ | Local only |
| Departments | ❌ (only Drift table + `WorkforceReference`) | ❌ | ❌ | ❌ | ❌ | ❌ | **Missing feature** |
| Branches/Company | `CompanyContext` (session only) | ❌ | ❌ | ❌ | ❌ | partial (session display) | **Missing feature** |
| Shifts | `Shift`, `ShiftDraft` | `ShiftRepository` | `LocalShiftRepository` | ❌ | ❌ | ✅ | Local only; model ≠ backend |
| Employee shifts | ❌ (only `Employee.shiftId`) | ❌ | ❌ | ❌ | ❌ | ❌ | **Missing feature** |
| Attendance (self) | `AttendanceDay/Event/Command`, engine | `AttendanceRepository` | `LocalAttendanceRepository` | `AttendanceRemoteSender` (interface only) | ❌ | ✅ | Local + outbox; no sender |
| Attendance policies | `AttendancePolicy` | `AttendancePolicyRepository` | `Local...` | ❌ | ❌ | ✅ | Local only |
| Work locations | `WorkLocation` | `WorkLocationRepository` | `Local...` | ❌ | ❌ | ✅ | Local only |
| Leave/Holidays | `LeaveType/Policy/Holiday` | `LeaveRepository` + config repos | `Local...` | ❌ | ❌ | ✅ | Local only (no backend endpoint) |
| Reports/Dashboard | report models | `AttendanceReportRepository`, `DashboardRepository` | `Local...` | ❌ | ❌ | ✅ | Local projections |
| Permissions/Access | `AppPermission`, scopes | `AccessRepository` | `LocalAccessRepository` | ❌ | ❌ | ✅ | Local grants |
| Notifications | `AppNotification*` | `NotificationRepository` | `LocalNotificationRepository` | ❌ | ❌ | ✅ | Local only |
| Sync/outbox | `PendingMutation` | `OutboxRepository` | `LocalOutboxRepository` | `SyncTransport` (iface) | ❌ | status UI | No sender |

**Reusable as-is:** `Result`/`Failure`, `SyncCoordinator`, outbox, Drift, BLoC, routing/guards, module registry, permission catalog, design system.
**Refactor:** `ApiClient` (add verbs/envelope/error mapping/refresh), `SecureSessionStorage` (refresh expiry), `AuthIdentifier` (`loginId`), auth repository selection in DI.
**Add:** remote data sources + DTOs + mappers for Auth, Departments, Branches, Shifts, Employee-Shifts, Attendance, Employees.

---

## 5. Backend contract ambiguities (must confirm with backend)

1. **Logout body/auth.** `FLUTTER_LOGIN_API.md` says `POST /api/auth/logout` with `{ refreshToken }` and no mention of `Authorization`; the Postman "Logout" request sends **no body** and a **bearer token**. Which is authoritative? (Affects whether logout can work after the access token expired.)
2. **No permission payload on login.** The app is fully permission/scope-driven; the backend returns only `transactionAccess`, `reportAccess`, `userType`, and `branches[]`. There is **no mapping** from `userType` (`Director`, `Accounts`, `Sales`, `HR`) to the app's `AppPermission` set + scopes. Must decide (derive coarse grants vs. keep local grants).
3. **Persistent identifiers.** Backend uses integer IDs; the app uses UUID strings everywhere (`Employee.id`, `Shift.id`, `departmentId`, `employeeShiftId`). Need a stable mapping rule (carry the int as the id string, or add `serverId`) and a decision on whether locally-created demo records ever sync.
4. **Multi-branch / company selection.** Login returns one `orgId`/`branchName` plus `branches[]` and `orgCount`. It is unclear whether the client must send a branch/company selector header on subsequent calls (the earlier internal spec required `X-Company-Id`; the MassERP endpoints shown do not).
5. **Envelope on non-2xx.** Postman samples show the envelope on 401. It is not documented whether 4xx/5xx always return the envelope with `errors[]`; the client should defensively handle both.
6. **`X-Client-Platform` effect.** Documented optional; effect on tokens/responses not specified.
7. **Time zone strings.** `timeZoneId` accepts IANA names only (Windows names/offsets rejected). The app currently stores a company `timezone` string; mapping to IANA is fine but the app's local `CompanyTimeService` supports only fixed offsets (per README) — verify.
8. **Attendance ordering/edge semantics** (3 shifts/day, overnight, `missedPunchOut` after 4 h) are documented but must be reconciled with the existing local `AttendanceEngine` state machine.
9. **Reset/change password.** Not present in the backend docs; the app has `requestPasswordReset`/`changePassword`. Treat as unsupported for now.
10. **Employee "lookups"** response shape is asserted but has no sample; confirm field names/types before modeling.

---

## 6. Security risks and priorities

| # | Risk | Evidence | Priority |
|---|---|---|---|
| SR1 | **Refresh token becomes unreadable after access expiry** (blocks refresh) | `secure_session_storage.dart:30-43` | **Critical** |
| SR2 | No refresh → no single-flight lock → once implemented naively it risks concurrent-refresh session kill (`AUTH_REFRESH_REUSED`) | `api_client.dart:25` | **Critical** |
| SR3 | No session invalidation path from 401 to `AuthBloc` | `api_client.dart`, `auth_bloc.dart` | **High** |
| SR4 | Logout is local-only; server session (other devices) not ended | `demo_auth_repository.dart` `_logout` | **High** |
| SR5 | No HTTPS enforcement / cert pinning; base URL from env with empty default | `core_dependencies.dart:27-32` | **High** |
| SR6 | `AuthenticationInterceptor` rejects with generic `unknown` on storage read failure (masks real cause, potential silent logout) | `api_client.dart:18-22` | **Medium** |
| SR7 | 401 collapse: `AUTH_TOKEN_EXPIRED` vs `AUTH_UNAUTHORIZED` not distinguished | `api_client.dart:56-57` | **Medium** |
| SR8 | No request cancellation (`CancelToken`) → stale responses after navigation/logout | `ApiClient.get` | **Medium** |
| SR9 | Flutter Web: `flutter_secure_storage` relies on a secure context; token-at-rest properties differ from native | README platform notes | **Medium** |
| SR10 | No rate-limit handling (429) UX | backend docs | **Medium** |
| SR11 | Token must never be attached to login/refresh; no skip mechanism exists yet | `AuthenticationInterceptor` | **Medium** |
| SR12 | Potential PII in attendance location (`latitude/longitude` stored server-side) | `FLUTTER_ATTENDANCE_API.md` | **Low** (server-owned) |
| SR13 | Payload logging | `AppLogger` logs event types only; no Dio `LogInterceptor` present — currently safe | **Info** |

Positives already in place: tokens excluded from Bloc state; DTO `toString` redaction; failures carry no raw bodies; secure storage single atomic envelope; permission-based (not role-based) authorization.

---

## 7. Recommended folder structure (module-oriented)

Keep the existing `lib/core`, `lib/app`, `lib/platform`, `lib/modules`, `lib/shared` skeleton. Add a consistent remote pattern **per module** and a reusable networking core.

```
lib/core/api/
  api_client.dart                 # Dio verbs + envelope unwrap + typed Result
  api_error_codes.dart            # backend code -> Failure (safe, centralized)
  api_option_keys.dart            # skipAuth / skipTokenRefresh / retried flags
  token_refresher.dart            # TokenRefresher interface + outcome enum
  token_refresh_coordinator.dart  # single-flight refresh lock
  interceptors/
    request_id_interceptor.dart
    client_platform_interceptor.dart
    authentication_interceptor.dart
    auth_retry_interceptor.dart
  models/
    api_error.dart                # Freezed errors[] entry
    paged_result.dart             # Freezed reusable {items, page, pageSize, totalItems, totalPages}

lib/modules/hr/<feature>/
  domain/            # unchanged entities + repository interfaces (no backend leak)
  data/
    dto/             # Freezed request/response DTOs + *.g.dart
    mappers/         # DTO <-> domain
    datasources/remote/<feature>_remote_data_source.dart
    repositories/remote_<feature>_repository.dart   # implements existing interface
    repositories/local_<feature>_repository.dart    # existing, kept for demo
```

Naming stays consistent with the repo: `<Feature>Dto`, `Remote<Feature>Repository`, `Local<Feature>Repository`, `abstract interface class <Feature>Repository`.

---

## 8. Proposed Freezed DTO structure

Every request body and typed response uses **Freezed + `json_serializable`**, kept in the `data/dto` layer (never exposed to UI). Reusable envelopes/pagination are shared.

```
core/api/models/
  api_error.dart          ApiError { code, message, field? }
  paged_result.dart       PagedResult<T> { items:[T], page, pageSize, totalItems, totalPages }
                          # page/pageSize/totalItems are ints; items typed per module

platform/auth/data/dto/
  login_request_dto.dart      { loginId, password }
  refresh_request_dto.dart    { refreshToken }
  logout_request_dto.dart     { refreshToken }
  login_response_dto.dart     { tokenType, accessToken, expiresIn, accessTokenExpiresAtUtc,
                                refreshToken, refreshTokenExpiresAtUtc, user: AuthUserDto,
                                branches: [AuthBranchDto] }
  auth_user_dto.dart          { userId, loginId, name, userType, empId?, orgId, branchName,
                                timeZone?, orgCount, transactionAccess, reportAccess }
  auth_branch_dto.dart        { orgId, branchName }

modules/hr/departments/data/dto/
  department_dto.dart         { departmentId, departmentName, employeeCount }
  department_upsert_dto.dart  { departmentName }

modules/hr/shifts/data/dto/
  shift_dto.dart              { shiftId, shiftName, startTime, endTime, durationMinutes,
                                crossesMidnight, punchInOpensAt, earlyPunchInMinutes,
                                lateGraceMinutes, statusId, status, activeAssignments,
                                createdOn, modifiedOn }
  shift_upsert_dto.dart       { shiftName, startTime, endTime, earlyPunchInMinutes, lateGraceMinutes }
  employee_shift_dto.dart     { employeeShiftId, employeeId, employeeCode, employeeName, shiftId,
                                shiftName, fromDate, toDate, startTime, endTime,
                                earlyPunchInMinutes, lateGraceMinutes, statusId, status,
                                timeZoneId, punchInOpensAt, crossesMidnight }
  employee_shift_upsert_dto.dart { employeeId?, shiftId, fromDate, toDate, timeZoneId? }

modules/hr/attendance/data/dto/
  attendance_today_dto.dart   { employeeId, date, timeZone, state, allowedActions,
                                currentShiftNo?, nextShiftNo?, shifts:[AttendanceShiftDto],
                                workedMinutes, workedHours, breakMinutes, serverTime }
  attendance_shift_dto.dart   { shiftNo, employeeShiftId, shiftId, shiftName, shiftDate,
                                timeZone, crossesMidnight, plannedStart, plannedEnd,
                                punchInOpensAt, status, punchIn?, punchOut?,
                                punchInLocation?, lateMinutes, earlyLeaveMinutes,
                                workedMinutes, breakMinutes, breaks:[AttendanceBreakDto] }
  attendance_break_dto.dart   { start, end?, minutes }
  punch_request_dto.dart      { action, latitude?, longitude? }

modules/hr/employees/data/dto/
  employee_list_item_dto.dart { employeeId, employeeCode, employeeName, designation,
                                departmentId, departmentName, branchId, branchName,
                                uaeContactNumber?, email?, joiningDate?, statusId,
                                statusName, photoPath?, loginEnabled, canLogin }
  employee_detail_dto.dart    # full detail (many nullable)
  employee_upsert_dto.dart    # create/update body
  employee_lookups_dto.dart   { branches, departments, nationalities, statuses }

modules/hr/branches/data/dto/
  branch_dto.dart             { branchId, branchName, branchCode, ... timeZoneId, status, ... }
  branch_upsert_dto.dart
  branch_lookups_dto.dart     { divisions, statuses, yesNo, timeZones }
```

Rules: `snake_case`/`camelCase` must match the backend JSON exactly (`expiresIn`, `accessTokenExpiresAtUtc`, `employeeShiftId`, …); date-times parsed then normalised to UTC; enums mapped defensively (unknown ⇒ null/fallback, fail closed as the existing DTO does).

---

## 9. Repository migration strategy

**Principle:** add remote implementations *behind the existing repository interfaces*; select local vs remote at composition; never touch BLoCs/pages/routes; never leak DTOs past `data/`.

1. **Selection seam.** Introduce a single runtime switch (e.g. `AppConfig.realApiEnabled` derived from `API_BASE_URL`). Register `Remote<Feature>Repository` when configured, else keep `Local<Feature>Repository` (demo/tests).
2. **Anti-corruption mappers.** `<Feature>RemoteMapper` maps DTO ⇄ existing domain entity. Keep the domain model authoritative for UI.
3. **ID strategy.** Carry the backend integer id as the entity's `id` string for remote-originated records; do **not** migrate Drift schema in Phase 1. In demo mode, keep UUID ids. Never post demo-seeded UUID records to the backend.
4. **Read-through cache (optional, later).** Where offline value exists (employees, departments, shifts), write remote results into the existing Drift tables and expose repository streams as today. This is additive and can be staged after the remote path is proven.
5. **Writes.** For backend-authoritative modules, start **online-first** (remote write → update cache); do not route them through the outbox until a sync protocol exists. Attendance is the exception to design carefully (server decides shift/time; offline punches are not in the backend contract).
6. **Auth is special.** A `RemoteAuthRepository` implements the same `AuthRepository` interface and additionally provides the refresh logic via a `TokenRefresher` injected into the core coordinator.
7. **Keep demo.** `DemoAuthRepository` and all local seeds remain for the design-system preview and the 1204-test baseline.

---

## 10. Server / local data authority matrix

| Domain | Classification | Notes |
|---|---|---|
| Login/refresh/logout | **1. Server-authoritative** | Tokens/session decided by server |
| Departments | **1. Server-authoritative** | No local feature; add remote |
| Branches/Company | **1. Server-authoritative** | Add remote; session uses branch info |
| Shifts | **1. Server-authoritative** | Backend is source; local `Shift` is demo |
| Employee-Shift assignments | **1. Server-authoritative** | New concept client-side |
| Attendance punch/today | **1. Server-authoritative** | Server clock/shift decision |
| Employees | **1. Server-authoritative** | Local `Employee` is demo cache |
| Employees/Departments/Shifts (cache) | **2. Local cached copy of server data** | Future read-through; not yet |
| Access grants / permission catalog | **3. Local-only** | No backend permission payload |
| Notifications, preferences, locale | **3. Local-only** | No backend endpoint |
| Dashboard/report projections | **3. Local-only** | Derived from local data |
| Leave types/policies/holidays, leave | **3. Local-only** | No backend endpoint yet |
| Work locations, attendance policies | **3. Local-only** | No backend endpoint |
| Attendance outbox mutations | **4. Explicitly offline mutations (demo)** | `AttendanceAuthority.productionPending`; **no sender wired** |
| Config/employee outbox enqueues | **4. Offline mutations** | Enqueue only; no sender |
| Refresh, server logout, password reset/change | **5. Unsupported / unresolved** | Not in backend docs |
| Sync protocol / automatic upload | **5. Unsupported** | No contract; outbox has no transport |

**Hard rule:** never silently upload locally seeded/demo records. Demo authority (`demoLocal`) must never reach the backend.

---

## 11. Testing strategy

**Baseline:** `flutter pub get` ✅ · `dart analyze` ✅ (No issues) · `flutter test` **+1204 passed / 1 failed** (`localization_test.dart`, pre-existing `holiday_pages.dart:336`).

**Coverage gaps to close (per area):**
- **Dio interceptors:** auth header attach; skip-auth on login/refresh; `X-Client-Platform`/`X-Request-ID`; retry-once on `AUTH_TOKEN_EXPIRED`.
- **Freezed JSON:** request/response round-trips for every DTO; nullable and enum handling; unknown-enum fail-closed.
- **Repository mapping:** DTO ⇄ domain for each feature; ID mapping; date/time normalisation.
- **API errors:** every documented `errors[0].code` → expected `Failure`; envelope on 2xx/4xx/5xx; malformed envelope.
- **Auth refresh:** single-flight (N concurrent 401s ⇒ 1 refresh); early refresh; retry original once; `AUTH_REFRESH_REUSED` ⇒ clear session; 503 ⇒ keep tokens.
- **Concurrent requests:** several calls during one refresh; request cancellation on logout/navigation.
- **Module isolation:** no cross-module DTO leakage (source-scan test).
- **Permissions:** real-mode grant resolution from `userType` + flags; route guards still enforced.
- **UI states:** loading/empty/error/retry for new remote-backed lists; button gating from `allowedActions`.
- **Offline behavior:** remote failure classification; no accidental upload of demo data.
- **Server conflicts:** 409 mapping (departments, shifts, employee-shifts overlap, attendance windows).

**Recommendation:** add a `MockDioAdapter` test helper and a `FakeTokenRefresher`, mirroring the existing `MemorySessionStorage`/`MemoryPreferences` support classes. Keep tests hermetic (no network).

---

## 12. Updated phase implementation roadmap

| Phase | Goal | Deliverables |
|---|---|---|
| **0 (this)** | Audit | This report |
| **1** | Networking + secure token foundation | Dio verbs + envelope + error mapping; HTTPS enforcement; single-flight refresh coordinator + interceptors; fix refresh-token expiry; extend `AuthSession`/DTO; `AppConfig` switch; unit tests |
| **2** | Real authentication | `RemoteAuthRepository`, remote data source + Freezed DTOs + mapper; `loginId`; server logout; DI selection; permission-source decision implemented |
| **3** | Departments | New `modules/hr/departments` feature (domain/data/presentation), remote repo + DTOs, route + DI + permissions; first full CRUD module to prove the pattern |
| **4** | Shifts + Employee-Shifts | Map backend shift model ⇄ local `Shift`; add assignments feature; admin screens |
| **5** | Attendance (self-service) | `GET today` + `POST punch`; adapter to existing engine/UI; server-authoritative time; lat/long |
| **6** | Employees + Branches | Remote employees CRUD (replace demo cache read-through); branches/company feature |
| **7** | Hardening | Cert pinning, cancellation, 429 UX, security review, web storage review |

---

## Actionable Phase 1 file-by-file plan

> Analysis only in Phase 0. The following is the proposed Phase 1 work, not executed here.

**Create**
- `lib/core/api/api_error_codes.dart` — backend `code` + HTTP status → `Failure` (preserve code; new kinds `rateLimited`, `forbidden`, `accountInactive`).
- `lib/core/api/api_option_keys.dart` — `skipAuthentication`, `skipTokenRefresh`, `authRetried`.
- `lib/core/api/token_refresher.dart` — `TokenRefresher` interface + `TokenRefreshOutcome {refreshed, invalidated, unavailable}`.
- `lib/core/api/token_refresh_coordinator.dart` — single-flight refresh lock (concurrent 401s share one refresh).
- `lib/core/api/interceptors/request_id_interceptor.dart` — move existing `X-Request-ID`.
- `lib/core/api/interceptors/client_platform_interceptor.dart` — `X-Client-Platform`.
- `lib/core/api/interceptors/authentication_interceptor.dart` — Bearer + proactive refresh near expiry.
- `lib/core/api/interceptors/auth_retry_interceptor.dart` — refresh once + retry on `401 AUTH_TOKEN_EXPIRED`.
- `lib/core/api/models/api_error.dart` — Freezed `errors[]` entry.
- `test/api_foundation_test.dart` — HTTPS guard, envelope unwrap, error mapping, refresh-token-after-expiry, single-flight.

**Modify**
- `lib/core/api/api_client.dart` — add `post/put/patch/delete` + `requestVoid`; unwrap `{success,message,data,errors}`; `ApiBaseUrl` HTTPS guard; register new interceptors; keep `ApiErrorMapper` signature for the existing test.
- `lib/core/storage/secure_session_storage.dart` — store/read `refreshTokenExpiresAt`; add `readAccessTokenExpiresAt`, `readRefreshTokenExpiresAt`, `hasRefreshToken`; stop gating refresh token by access expiry.
- `lib/core/errors/result.dart` — add `FailureKind.rateLimited/forbidden/accountInactive`.
- `lib/core/errors/failure_localization.dart` + `lib/l10n/common/common_{en,ar}.arb` — localized copy.
- `lib/platform/auth/domain/entities/auth_context.dart` — `AuthSession.refreshTokenExpiresAt`, `tokenType`.
- `lib/platform/auth/data/dto/auth_session_dto.dart` (+ regenerate `.g.dart`) — new fields + mapper encode/decode.
- `lib/app/app_config.dart` — `apiBaseUrl`, `realApiEnabled`.
- `lib/bootstrap/core_dependencies.dart` — register `TokenRefreshCoordinator`; construct `ApiClient` only when configured.
- `test/support/memory_session_storage.dart` — implement new interface methods.

**Do not (Phase 1):** change Drift schema, add dependencies, alter BLoC/router/permission contracts, or touch local repositories.

---

## Final summary

**Discovered issues (highest first):** refresh token unreadable after access expiry (SR1); no refresh/single-flight/session-invalidation path (SR2/SR3); local-only logout (SR4); no HTTPS enforcement (SR5); `ApiClient` GET-only and unused (P1/P2); no envelope/error-code parsing (P3); `loginId` mismatch (P7); missing Departments/Branches/Employee-Shift features; no backend permission payload.

**Baseline test results:** `flutter pub get` ✅; `dart analyze` — No issues ✅; `flutter test` — **+1204 passed / 1 failed**, failure pre-existing at `lib/modules/hr/leave/presentation/pages/holiday_pages.dart:336` (`label: '$year'` false-positive in the hardcoded-string source scan), unrelated to API integration.

**Backend contract questions:** logout body vs bearer (§5.1); permission/scope source (§5.2); integer↔UUID id mapping (§5.3); branch/company selection on later calls (§5.4); envelope on non-2xx (§5.5); employee lookups shape (§5.10); attendance-engine reconciliation (§5.8); password reset/change unsupported (§5.9).

**Phase 1 readiness:** **Ready.** The architecture supports additive remote data sources; Phase 1 is self-contained (core networking + secure token foundation) and does not depend on resolving the backend ambiguities, which can be settled in parallel before Phase 2.

**STOP — Phase 0 complete. Awaiting instruction before starting Phase 1.**
