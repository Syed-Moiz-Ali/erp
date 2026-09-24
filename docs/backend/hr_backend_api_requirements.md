# HR + Platform Backend API Requirements

**Audience:** Backend architect / API developer.
**Source of truth:** the existing Flutter ERP implementation (models, repository
interfaces, enums, permission catalog, routes, outbox operations). Nothing in
this document was invented from a generic ERP template.
**Scope:** Platform + Access Control + complete HR. **Services is intentionally
excluded** and will have its own increment.
**Status:** requirement document only. No backend code, no Flutter changes.

---

## 1. Document Purpose

This document specifies every backend API required by the current Flutter ERP so
a backend can be implemented independently. It defines endpoints, authorization,
request/response contracts, validations, idempotency, concurrency, audit,
notifications, sync behavior and the mapping from existing Flutter repositories
and screens to backend APIs.

The Flutter app is **local-first** (Drift) with an **outbox**. The backend must be
compatible with that architecture: Flutter will keep Drift as its local cache and
will add remote data sources behind the existing repository interfaces.

---

## 2. Current Flutter Architecture Summary

- **State:** `flutter_bloc` (BLoC/Cubit). UI → BLoC → use case/application → repository → local (Drift) / future remote data source.
- **Persistence:** Drift (SQLite). Schema v10. Local repositories are the current source of truth in demo/local mode.
- **Routing:** `go_router`, module-first URLs under `/app/hr/...`, `/app/settings/...`. (Frontend routes are **not** backend endpoints.)
- **Auth:** one login for all company users; `AuthContext` = `UserAccount` + `CompanyContext` + optional `EmployeeReference` + `PermissionSet`.
- **Authorization:** permission + scope driven. No business role names. Effective access = `Company Module Enabled AND Permission Granted AND Required Employee Context Valid AND Record Within Granted Scope AND Company/Tenant Match`.
- **Permission scopes:** `NONE`, `SELF`, `ASSIGNED`, `TEAM`, `ALL`.
- **Sync:** generic outbox (`sync_outbox`) with `requestId`, retry/backoff, conflict records; local Drift remains the frontend read model.
- **Time:** `AppClock` (UTC instants) + `CompanyTimeService` (company timezone → business date).
- **Notifications:** platform-level, structured (`AppNotificationType` + payload), localized at render time.

### Key current permission keys (stable, from the catalog)

HR: `hr.employees.view|create|edit|deactivate`,
`hr.attendance.self.view|punch|punchOut|break|correctionRequest`,
`hr.attendance.records.view`, `hr.attendance.corrections.review|apply`,
`hr.attendance.reports.view`, `hr.leave.self.view|request|cancel|balanceView`,
`hr.leave.records.view`, `hr.leave.requests.review`,
`hr.leave.balances.view|adjust`, `hr.leave.settings.manage`,
`hr.leave.types.view|manage`, `hr.leave.policies.view|manage`,
`hr.holidays.view|manage`, `hr.reports.leave.view`,
`hr.attendance.shifts.view|manage`, `hr.attendance.locations.view|manage`,
`hr.attendance.policies.view|manage`.

Platform: `company.access.users.view`, `company.access.permissions.manage`,
`company.modules.view`, `company.users.manage`, `platform.companies.manage`,
`platform.modules.manage`.
There is **no role permission** — the legacy `company.roles.manage` permission
and the `AppRole` model have been removed; access is fully permission-based.

### Company module feature flags

`dashboard`, `employees`, `attendance`, `leave`, `reports`, `settings`.
`services` is reserved. A feature flag gates the module regardless of grants.

---

## 3. API Design Standards

### 3.1 Base path & versioning

- Base: `/api/v1`. Breaking changes → `/api/v2`. Additive changes stay in `v1`.
- JSON only (`application/json; charset=utf-8`), except file import (multipart).

### 3.2 Standard headers

| Header | Required | Notes |
| --- | --- | --- |
| `Authorization: Bearer <accessToken>` | yes (except login/refresh/reset) | JWT/opaque access token |
| `X-Company-Id: <uuid>` | yes (except login/refresh/reset/bootstrap-without-company) | active company; server verifies membership |
| `X-Request-Id: <uuid>` | recommended | echoed in `meta.requestId`; used for tracing |
| `Idempotency-Key: <uuid>` | required for mutations listed in §22 | maps to outbox `requestId` |
| `Accept-Language: en \| ar` | optional | response message language; **never** authorization |
| `X-Client-Platform: android \| ios \| web` | optional | diagnostics |
| `X-Client-Version: <semver>` | optional | min-version policy |

**Login headers:** do **not** require `X-Company-Id` (company is resolved after
auth). Company selection happens in bootstrap (§5).

### 3.3 Success envelope

```json
{
  "success": true,
  "data": {},
  "meta": { "requestId": "uuid", "serverTimeUtc": "2026-09-24T06:00:00Z" }
}
```

### 3.4 Paginated envelope

```json
{
  "success": true,
  "data": [],
  "meta": {
    "page": 1, "pageSize": 25, "totalItems": 120, "totalPages": 5,
    "requestId": "uuid", "serverTimeUtc": "2026-09-24T06:00:00Z"
  }
}
```

Pagination is **1-based** (`page` starts at 1). Default `pageSize = 25`,
maximum `100`. `pageSize=0` is invalid. The Flutter list repositories currently
use `page` (0-based internally) + `pageSize`; the backend contract is 1-based and
the Flutter remote source maps it.

### 3.5 Error envelope

```json
{
  "success": false,
  "error": {
    "code": "LEAVE_INSUFFICIENT_BALANCE",
    "message": "Insufficient leave balance.",
    "fieldErrors": { "endDate": "LEAVE_END_BEFORE_START" },
    "details": { "available": 2, "requested": 3 }
  },
  "meta": { "requestId": "uuid", "serverTimeUtc": "2026-09-24T06:00:00Z" }
}
```

`error.code` is a **stable machine code** (UPPER_SNAKE). Flutter maps codes to
localized copy; it never parses English text. `fieldErrors` keys are request
field paths.

### 3.6 HTTP status usage

| Status | Use |
| --- | --- |
| 200 | successful read/update |
| 201 | resource created |
| 204 | successful delete/deactivate with no body |
| 400 | malformed request / missing required field |
| 401 | missing/expired/invalid token |
| 403 | authenticated but **not authorized** (permission/scope/module/tenant) |
| 404 | resource not found **or** outside the caller's scope |
| 409 | state/concurrency conflict (already reviewed, duplicate) |
| 422 | semantically invalid input (business validation) |
| 429 | rate limited |
| 500 | server error |

`403 vs 404`: return **404** for records that exist but are outside the caller's
granted scope (do not reveal existence); return **403** for missing
permission/module/tenant mismatch on a known-collection endpoint.
`409 vs 422`: **409** when the request conflicts with current state
(already reviewed/duplicate); **422** when the payload is structurally valid but
fails business rules.

### 3.7 Enum wire values

Wire values are the exact Dart enum names (lowerCamelCase). Never send localized
text. Full catalog in §20.

### 3.8 ID contract

- Internal IDs: UUID strings.
- Human display codes: `employeeCode` (e.g. `EMP-001`), transaction
  `displayNumber` (future Services). Display codes are **not** primary keys.
- Foreign references use IDs (`departmentId`, `designationId`, `managerId`,
  `shiftId`, `workLocationId`, `attendancePolicyId`, `leaveTypeId`,
  `leavePolicyId`, `holidayCalendarId`). Never names/emails as IDs.

### 3.9 Date/time contract

- Absolute timestamps: ISO-8601 **UTC** (`2026-09-24T06:00:00Z`). Store UTC.
- Business dates: date-only `YYYY-MM-DD` in the **company timezone**
  (`CompanyContext.timezone`), e.g. leave dates, holiday dates, attendance date.
- Time-only: `HH:mm` (shift start/end, local wall clock).
- Overnight shifts: an attendance day is owned by its start date in company time.
- Never use server-local timezone as business truth.

### 3.10 Idempotency

See §22. Mutations accept `Idempotency-Key`; the server stores it and returns the
original result on replay (never a duplicate record). The Flutter outbox already
generates a `requestId` per mutation and has a unique index on it.

### 3.11 Optimistic concurrency

Entities expose `updatedAt` (and a `version` where noted). Mutations that can
race send the last-seen `updatedAt`/`version`; on mismatch the server returns
`409` with a stable code (`*_STALE` / `*_ALREADY_REVIEWED`). See §23.

### 3.12 Server authorization rule (critical)

**The backend must not trust the Flutter UI.** Hiding a button is UX only. Every
protected endpoint independently enforces: token validity → company membership →
module enabled → permission granted → employee link (where required) → record
scope → tenant match. See §8 and §24.

---

## 4. Authentication & Session

### 4.1 Login

PURPOSE: authenticate an email/phone + password and return a session.
METHOD: `POST`
PATH: `/api/v1/auth/login`
AUTHENTICATION: none
REQUIRED PERMISSION: none
ALLOWED SCOPE: n/a
REQUIRED HEADERS: `Content-Type: application/json`, `X-Request-Id` (optional)
REQUEST BODY:

```json
{ "identifier": "hr@company.com", "password": "secret" }
```

REQUEST FIELD TABLE:

| Field | Type | Required | Nullable | Example | Validation |
| --- | --- | --- | --- | --- | --- |
| `identifier` | string | yes | no | `hr@company.com` | email or phone (E.164 or local) |
| `password` | string | yes | no | `secret` | min length per password policy |

BUSINESS VALIDATIONS: account active; credentials valid; account not suspended.
SUCCESS RESPONSE: `200`

```json
{
  "success": true,
  "data": {
    "accessToken": "...",
    "refreshToken": "...",
    "expiresAtUtc": "2026-09-24T14:00:00Z",
    "account": { "id": "uuid", "displayName": "Layla Omar", "email": "hr@company.com", "phone": "+9715...", "status": "active" },
    "companies": [ { "id": "uuid", "name": "Acme", "code": "ACME", "timezone": "Asia/Dubai", "defaultLocale": "en", "enabledModules": ["dashboard","employees","attendance","leave","reports","settings"] } ],
    "activeCompanyId": "uuid"
  },
  "meta": { "requestId": "uuid", "serverTimeUtc": "..." }
}
```

ERROR RESPONSES: `400 AUTH_INVALID_INPUT`, `401 AUTH_INVALID_CREDENTIALS`,
`403 AUTH_ACCOUNT_SUSPENDED`, `429 AUTH_RATE_LIMITED`.
IDEMPOTENCY: not required (safe to retry; may rotate tokens).
AUDIT: login success/failure event (actor = account).
FLUTTER CONSUMER: `AuthRepository.login(AuthIdentifier, password)` →
`DemoAuthRepository._login`.

> NOTE: There is **no role in the authorization contract**. The backend must
> never return or accept a business role (`hr`, `manager`, `employee`,
> `technician`, `serviceManager`) as authorization truth. Access is derived only
> from **company module entitlement + permission grants + scopes + employee
> link**. Any legacy role field still present in the current Flutter model is
> migration metadata and must not influence any endpoint.

### 4.2 Refresh token

PURPOSE: rotate access token.
METHOD: `POST` PATH: `/api/v1/auth/refresh`
AUTHENTICATION: refresh token
REQUEST: `{ "refreshToken": "..." }`
SUCCESS: new `accessToken`, `refreshToken`, `expiresAtUtc`.
ERRORS: `401 AUTH_REFRESH_INVALID`, `401 AUTH_REFRESH_EXPIRED`.
SECURITY: rotate refresh tokens; revoke on reuse; never log tokens.
FLUTTER CONSUMER: `AuthRepository.restoreSession/checkSession` (session lifecycle).

### 4.3 Logout

METHOD: `POST` PATH: `/api/v1/auth/logout` (Bearer)
SUCCESS: `204`. Server revokes refresh token(s).
FLUTTER CONSUMER: `AuthRepository.logout()`.

### 4.4 Current account / session validation

METHOD: `GET` PATH: `/api/v1/auth/session` (Bearer, optional `X-Company-Id`)
SUCCESS: `200` with `account`, `activeCompanyId`, `expiresAtUtc`.
ERRORS: `401` when invalid/expired.
FLUTTER CONSUMER: `AuthRepository.checkSession()`.

### 4.5 Change password

METHOD: `POST` PATH: `/api/v1/auth/change-password` (Bearer)
REQUEST: `{ "currentPassword": "...", "newPassword": "..." }`
VALIDATION: current password correct; new meets policy; new ≠ current.
SUCCESS: `204`. ERRORS: `422 AUTH_PASSWORD_POLICY`, `422 AUTH_PASSWORD_SAME`,
`401 AUTH_CURRENT_PASSWORD_INVALID`.
FLUTTER CONSUMER: `AuthRepository.changePassword`.

### 4.6 Request password reset

METHOD: `POST` PATH: `/api/v1/auth/forgot-password` (no auth)
REQUEST: `{ "identifier": "..." }`
SUCCESS: `202` always (no account enumeration).
FLUTTER CONSUMER: `AuthRepository.requestPasswordReset`.

---

## 5. Company Context & Bootstrap

### 5.1 Bootstrap (very important)

PURPOSE: return everything Flutter needs after login/company selection.
METHOD: `GET` PATH: `/api/v1/me/bootstrap`
AUTHENTICATION: Bearer + `X-Company-Id`
REQUIRED PERMISSION: none (membership required)
ALLOWED SCOPE: n/a
SUCCESS RESPONSE: `200`

```json
{
  "success": true,
  "data": {
    "account": { "id": "uuid", "displayName": "Layla Omar", "email": "...", "phone": "...", "status": "active" },
    "company": { "id": "uuid", "name": "Acme", "code": "ACME", "timezone": "Asia/Dubai", "defaultLocale": "en", "logoUrl": null, "enabledModules": ["employees","attendance","leave","reports","settings"] },
    "employee": { "id": "uuid", "employeeCode": "EMP-001", "displayName": "Layla Omar", "status": "active" },
    "permissions": [ { "key": "hr.employees.view", "scope": "all", "expiresAt": null } ],
    "catalogVersion": "2026-09-24.1",
    "serverTimeUtc": "2026-09-24T06:00:00Z"
  },
  "meta": { "requestId": "uuid", "serverTimeUtc": "..." }
}
```

BUSINESS VALIDATIONS: membership active; company active; expired grants excluded
by server time.
ERRORS: `401`, `403 COMPANY_MEMBERSHIP_REQUIRED`, `403 COMPANY_INACTIVE`.
NOTES: `permissions` is the authoritative effective grant list (key + scope).
`employee` is null for platform/admin accounts without an employee link.
CACHING: cacheable per session; revalidate on `catalogVersion` change (see §25).
FLUTTER CONSUMER: session/`UserGrantsController` + `NavigationResolver`.

### 5.2 Company memberships

METHOD: `GET` PATH: `/api/v1/me/companies` (Bearer)
SUCCESS: list of companies the account belongs to (id, name, code, timezone,
defaultLocale, enabledModules). **No role field** — access comes from grants.
FLUTTER CONSUMER: company switcher (session `companies`).

### 5.3 Company switch

PROCESS: client sets `X-Company-Id` to the target company and calls `GET
/api/v1/me/bootstrap`. The server rejects companies the user is not a member of
(`403`). The client partitions/clears stale tenant state. No separate switch
endpoint is required, but an explicit `POST /api/v1/me/active-company` may be
added if server-side active-company persistence is desired.
**Backend must reject unauthorized `X-Company-Id`.**

---

## 6. Profile

The current Profile is platform-global; HR employment data is optional linked
content.

### 6.1 Get my profile

METHOD: `GET` PATH: `/api/v1/me/profile` (Bearer, `X-Company-Id`)
PERMISSION: none (self). Returns account + preferences + optional employee link.
SUCCESS: `200` `{ account, employee|null, preferences }`.
SAFE FIELDS: no password hashes, tokens, or security secrets.

### 6.2 Update preferences

METHOD: `PATCH` PATH: `/api/v1/me/preferences`
REQUEST (partial): `{ "language": "en|ar", "attendanceReminders": true, "reminderLeadMinutes": 15 }`
SUCCESS: `200` updated preferences.
FLUTTER CONSUMER: `AppPreferencesRepository` (currently local `SharedPreferences`).

### 6.3 Employee-required profile shortcuts

Self attendance/leave shortcuts appear only with the corresponding self
permission and an active employee link; the APIs they call are §11/§12.

---

## 7. Permission & Access Control

### 7.1 Permission catalog (optional)

METHOD: `GET` PATH: `/api/v1/access/catalog` (Bearer, `X-Company-Id`)
PERMISSION: `company.access.users.view`
SUCCESS: `200` catalog of modules → submodules → permission definitions
(`key`, `moduleId`, `submoduleId`, `nameKey`, `descriptionKey`,
`supportedScopes`, `requiresEmployeeLink`, `delegable`, `platformOnly`, `risk`).
Versioned via `catalogVersion`. Backend may serve the same catalog the Flutter
app already bundles; this endpoint lets the backend drive new permissions
without an app release.

### 7.2 List access users

METHOD: `GET` PATH: `/api/v1/access/users`
PERMISSION: `company.access.users.view`
QUERY: `search`, `status` (`active|suspended|inactive`), `hasLogin`,
`activeEmployee`, `module` (`hr|services|...`), `page`, `pageSize`.
SCOPE: company-wide (access administration is company-scoped).
SUCCESS: `200` paginated `AccessUserListItemDto`:

| Field | Type | Nullable | Notes |
| --- | --- | --- | --- |
| `userId` | UUID | no | user account id |
| `displayName` | string | no | |
| `email` | string | no | safe login metadata only |
| `hasLogin` | bool | no | false = employee without account |
| `accountStatus` | enum | no | `active|suspended|inactive` |
| `employeeId` | UUID | yes | linked employee, else null |
| `employeeCode` | string | yes | |
| `designationName` | string | yes | |
| `departmentName` | string | yes | |
| `isEmployeeActive` | bool | no | |
| `modules` | string[] | no | modules with ≥1 active grant |
| `lastUpdatedUtc` | timestamp | yes | |

ERRORS: `403` without permission.
FLUTTER CONSUMER: `AccessRepository.watchUsers` → `LocalAccessUserDirectory`.

### 7.3 Get access user + grants

METHOD: `GET` PATH: `/api/v1/access/users/{userId}`
PERMISSION: `company.access.users.view`
SUCCESS: `200` `{ user: AccessUserListItemDto, grants: GrantDto[], history?: AccessEventDto[] }`.

GrantDto (actual model):

| Field | Type | Nullable | Notes |
| --- | --- | --- | --- |
| `key` | string | no | namespaced permission key |
| `scope` | enum | no | `none|self|assigned|team|all` |
| `expiresAt` | timestamp | yes | null = no expiry |
| `isActive` | bool | no | |
| `grantedByUserId` | UUID | no | |
| `grantedAt` | timestamp | no | |
| `updatedAt` | timestamp | no | |

### 7.4 Replace grants (atomic)

PURPOSE: replace the user's effective grant set.
METHOD: `PUT` PATH: `/api/v1/access/users/{userId}/grants`
PERMISSION: `company.access.permissions.manage`
ALLOWED SCOPE: n/a (action permission)
REQUIRED HEADERS: `Idempotency-Key` required.
REQUEST BODY:

```json
{ "grants": [ { "key": "hr.leave.requests.review", "scope": "team", "expiresAt": null } ] }
```

BUSINESS VALIDATIONS (server-side, mirroring `GrantAuthorityResolver`):

- Caller must hold `company.access.permissions.manage`.
- **Self-escalation:** caller must not equal `userId` → `403 ACCESS_SELF_ESCALATION`.
- **Grant ceiling:** caller may only grant permissions they themselves hold
  (or employee self-service when they can provision employees) → `403 ACCESS_NOT_PERMITTED`.
- **Platform-only / non-delegable:** only platform admins
  (`platform.modules.manage`/`platform.companies.manage`) → `403 ACCESS_PLATFORM_ONLY`.
- **Module enabled:** module of the permission must be enabled → `403 ACCESS_MODULE_DISABLED`.
- **Employee link:** `requiresEmployeeLink` permissions need an active linked
  employee → `422 ACCESS_EMPLOYEE_LINK_REQUIRED`.
- **Supported scope:** scope must be in the definition → `422 ACCESS_UNSUPPORTED_SCOPE`.
- **Unknown key:** `422 ACCESS_UNKNOWN_PERMISSION`.
- **Last access admin:** must not strip `company.access.permissions.manage` from
  the final holder → `409 ACCESS_LAST_ADMIN`.
- One effective grant per `(companyId, userId, permissionKey)`.

SUCCESS: `200` with the resulting grant list.
ERRORS: `403`, `409 ACCESS_LAST_ADMIN`, `422`.
IDEMPOTENCY: required; replay returns the stored result (no duplicate audit rows).
AUDIT: append structured activity events `access.permission.added|updated|removed`
with `{ permissionKey, oldScope, newScope }`, actor = caller.
NOTIFICATION: none (access changes are audited, not notified).
FLUTTER CONSUMER: `AccessRepository.replaceGrants` → `LocalAccessRepository`.

### 7.5 Access history

METHOD: `GET` PATH: `/api/v1/access/users/{userId}/history`
PERMISSION: `company.access.users.view`
SUCCESS: `200` list of `AccessEventDto` (newest first):
`{ id, eventType, occurredAt, actorUserId, actorEmployeeId?, metadata: { permissionKey, oldScope?, newScope? }, requestId? }`.
FLUTTER CONSUMER: `AccessRepository.watchHistory`.

### 7.6 Company module entitlements

METHOD: `GET` PATH: `/api/v1/company/modules`
PERMISSION: `company.modules.view`
SUCCESS: `200` `{ modules: [ { id: "employees", enabled: true }, ... ] }`.
MUTATION: **FUTURE / NOT REQUIRED BY CURRENT FRONTEND** (module enablement is
platform-level; the current UI is read-only).

---

## 8. Employees

### 8.1 Employee list

METHOD: `GET` PATH: `/api/v1/hr/employees`
PERMISSION: `hr.employees.view`
ALLOWED SCOPE: `self | team | all`
EMPLOYEE LINK REQUIRED: for `self` only.
COMPANY MODULE REQUIRED: `employees`.
QUERY PARAMETERS:

| Param | Type | Notes |
| --- | --- | --- |
| `search` | string | name / code / email / phone |
| `status` | enum | `active | inactive` |
| `departmentId` | UUID | filter |
| `designationId` | UUID | filter |
| `workLocationId` | UUID | filter |
| `shiftId` | UUID | filter |
| `managerId` | UUID | filter |
| `sort` | enum | `nameAscending | nameDescending | code | newestJoined | oldestJoined` |
| `page` / `pageSize` | int | 1-based / default 25 |

RECORD-SCOPE RULE: `all` → company-wide; `team` → server resolves the caller's
employee (via their linked employee) and returns only employees whose
`managerId` = caller's employee id (current frontend rule); `self` → the caller's
own employee only. **Never** return company data to a `team` caller.
SUCCESS: `200` paginated `EmployeeListItemDto` (list view — not the full
aggregate):

| Field | Type | Nullable | Notes |
| --- | --- | --- | --- |
| `id` | UUID | no | |
| `employeeCode` | string | no | |
| `displayName` | string | no | |
| `email` | string | no | |
| `phone` | string | no | |
| `departmentId` / `designationId` | UUID | no | |
| `departmentName` / `designationName` | string | yes | denormalized for list |
| `employmentType` | enum | no | |
| `status` | enum | no | |
| `avatarUrl` | string | yes | |
| `joiningDate` | date | no | company date |

ERRORS: `403 ACCESS_MODULE_DISABLED`, `403` no permission, `404` none.
FLUTTER CONSUMER: `EmployeeRepository.watchEmployees(context, query, filter, sort, page, pageSize)` → `LocalEmployeeRepository`.

### 8.2 Employee detail

METHOD: `GET` PATH: `/api/v1/hr/employees/{employeeId}`
PERMISSION: `hr.employees.view` (+ record scope; `self` requires the id to equal
the caller's linked employee).
RECORD-SCOPE: `team`/`all` as above; out-of-scope id → `404`.
SUCCESS: `200` `EmployeeDto` (full aggregate): id, companyId, employeeCode,
firstName, middleName, lastName, email, phone, avatarUrl, departmentId,
designationId, managerId, joiningDate, employmentType, status, shiftId,
workLocationId, attendancePolicyId, linkedUserId, loginEnabled, createdAt,
updatedAt, syncStatus.
FIELD VISIBILITY: account/security data (`linkedUserId`, `loginEnabled`, account
provisioning) may require `hr.employees.accountAccess.manage`
(**TBD — BACKEND/PRODUCT CONFIRMATION REQUIRED**, current Flutter shows account
access inside the employee form gated by employee edit + userManage).
FLUTTER CONSUMER: `EmployeeRepository.watchEmployee/getEmployeeById`.

### 8.3 Employee create

METHOD: `POST` PATH: `/api/v1/hr/employees`
PERMISSION: `hr.employees.create`
ALLOWED SCOPE: n/a
REQUIRED HEADERS: `Idempotency-Key` recommended (retry-safe).
REQUEST BODY (from `EmployeeDraft`):

```json
{
  "firstName": "Ahmed", "middleName": "", "lastName": "Khan",
  "email": "ahmed@company.com", "phone": "+9715...",
  "departmentId": "uuid", "designationId": "uuid", "managerId": null,
  "joiningDate": "2026-01-15", "employmentType": "fullTime",
  "shiftId": "uuid", "workLocationId": "uuid", "attendancePolicyId": "uuid",
  "loginEnabled": false
}
```

> No `role`/`accountRole` is part of this contract. Account access is assigned as
> **explicit permission grants** (see §7.4), never a role.

REQUEST FIELD TABLE:

| Field | Type | Required | Nullable | Validation |
| --- | --- | --- | --- | --- |
| `firstName` | string | yes | no | 1–100, trimmed |
| `middleName` | string | no | no | ≤100 |
| `lastName` | string | yes | no | 1–100 |
| `email` | string | yes | no | email; unique per company |
| `phone` | string | yes | no | valid; unique per company |
| `departmentId` | UUID | yes | no | must belong to company & active |
| `designationId` | UUID | yes | no | company & active |
| `managerId` | UUID | no | yes | company; not self; no cycle |
| `joiningDate` | date | yes | no | company date |
| `employmentType` | enum | yes | no | `fullTime|partTime|contract|intern|temporary` |
| `shiftId`/`workLocationId`/`attendancePolicyId` | UUID | no | yes | company & active |
| `loginEnabled` | bool | no | no | provisioning intent (grants are assigned separately) |

BUSINESS VALIDATIONS: duplicate email/phone → `422 EMP_DUPLICATE_EMAIL/PHONE`;
invalid reference → `422 EMP_INVALID_REFERENCE`; `employeeCode` generated by
server, unique per company. Account provisioning (if `loginEnabled`) follows the
existing provisioning flow; do not create login credentials in this call without
the provisioning contract.
SUCCESS: `201` `EmployeeDto`.
ERRORS: `422`, `403`.
AUDIT: `employee.created` activity event (actor from session).
NOTIFICATION: none.
FLUTTER CONSUMER: `EmployeeRepository.saveEmployee(context, draft)`.

### 8.4 Employee edit

METHOD: `PATCH` PATH: `/api/v1/hr/employees/{employeeId}`
PERMISSION: `hr.employees.edit` (+ record scope where team edits are supported).
CONCURRENCY: send last `updatedAt`; mismatch → `409 EMP_STALE`.
Same field rules as create (code/email/phone uniqueness excluding self).
SUCCESS: `200` `EmployeeDto`. AUDIT: `employee.updated`.
FLUTTER CONSUMER: `EmployeeRepository.saveEmployee(context, draft, id:)`.

### 8.5 Employee activate/deactivate

METHOD: `POST` PATH: `/api/v1/hr/employees/{employeeId}/deactivate` (and
`/activate`).
PERMISSION: `hr.employees.deactivate`.
BUSINESS: deactivation makes employee-required capabilities unavailable; do not
delete history. SUCCESS: `200` `EmployeeDto`.
ERRORS: `409 EMP_ALREADY_INACTIVE`, `422` if business rules block.
AUDIT: `employee.activated|deactivated`.
FLUTTER CONSUMER: `EmployeeRepository.setActive`.

### 8.6 Reference / selector data

METHOD: `GET` PATH: `/api/v1/hr/employees/references`
PERMISSION: `hr.employees.view` (scoped).
QUERY: `search`, `excludingId`.
SUCCESS: `200` lightweight references, scoped to the caller:
`{ managers: EmployeeReferenceDto[], departments: ReferenceDto[],
designations: ReferenceDto[], shifts: ReferenceDto[],
workLocations: ReferenceDto[], attendancePolicies: ReferenceDto[] }`.
`EmployeeReferenceDto = { id, employeeCode, displayName }`.
**Do not return full employee aggregates to selectors, and do not leak
company-wide employees to `team` callers.**
FLUTTER CONSUMER: `EmployeeRepository.getReferences`.

### 8.7 Availability checks

`GET /api/v1/hr/employees/email-availability?email=&excludingId=`
`GET /api/v1/hr/employees/phone-availability?phone=&excludingId=`
PERMISSION: `hr.employees.create|edit`.
SUCCESS: `200` `{ available: true }`.
FLUTTER CONSUMER: `EmployeeRepository.checkEmailAvailability/checkPhoneAvailability`.

### 8.8 Linked account

`GET /api/v1/hr/employees/{employeeId}/account`
PERMISSION: `hr.employees.view` + account-access permission (see §8.2).
SUCCESS: `200` `{ user: UserAccountDto, credentialPending: bool } | null`.
FLUTTER CONSUMER: `EmployeeRepository.getLinkedAccount`.

---

## 9. HR Configuration

Configuration entities share a common contract
(`ConfigurationRepository<T,D>`): list (paginated, searchable, status filter),
details, save (create/update), set active/inactive, assigned-employee count.
Permissions follow `view`/`manage`; `manage` implies `view`.

### 9.1 Shifts

- `GET /api/v1/hr/shifts` — `hr.attendance.shifts.view`. Query: `search`,
  `status`, `page`, `pageSize`. Sort by name.
- `GET /api/v1/hr/shifts/{id}` — view.
- `POST /api/v1/hr/shifts` / `PATCH /api/v1/hr/shifts/{id}` — `hr.attendance.shifts.manage`.
- `POST /api/v1/hr/shifts/{id}/activate|deactivate` — manage.
- `GET /api/v1/hr/shifts/{id}/assigned-employee-count` — view.

Shift fields (from model): `id, companyId, name, code, startTime` (HH:mm),
`endTime` (HH:mm), `workingDays` (subset of `mon..sun`), `graceMinutes`,
`breakMode` (`manual|fixed|none`), `breakMinutes`, `minimumWorkMinutes`,
`overnight` (bool, derived from start>end), `status` (`active|inactive`),
`createdAt, updatedAt`.
VALIDATION: `endTime ≠ startTime`; working days non-empty; grace/break/minimum
non-negative; name unique among active per company.

### 9.2 Work Locations

- `GET /api/v1/hr/work-locations`, `/{id}`, `POST`, `PATCH`, `activate|deactivate`,
  `/{id}/assigned-employee-count`.
- Permission: `hr.attendance.locations.view|manage`.

Fields: `id, companyId, name, code, addressLine1, addressLine2, city, state,
postalCode, country, latitude, longitude, radiusMeters, accuracyLimitMeters,
validationMode` (`geofenceRequired|geofencePreferred|captureOnly|none`),
`status, createdAt, updatedAt`.
VALIDATION: coordinates in range; radius/accuracy > 0; name unique among active.

### 9.3 Attendance Policies

- `GET /api/v1/hr/attendance-policies`, `/{id}`, `POST`, `PATCH`,
  `activate|deactivate`, `/{id}/assigned-employee-count`.
- Permission: `hr.attendance.policies.view|manage`.

Fields (from model): `id, companyId, name, code, description,
requireLocation, allowRemote, allowMultipleBreaks, trackBreaks,
allowPunchOutDuringBreak, correctionsEnabled, earlyPunchInMinutes,
latePunchInMinutes, earlyPunchOutMinutes, offlineMode` (`none|pending|warning`),
`status, createdAt, updatedAt`.
INTERACTION: a policy references a shift + work location indirectly through the
employee assignment; policy + shift + work location together drive attendance
eligibility (see §10.3).

---

## 10. Attendance

### 10.1 Attendance Today

PURPOSE: everything the Today screen needs to render state and actions.
METHOD: `GET` PATH: `/api/v1/hr/attendance/today`
PERMISSION: `hr.attendance.self.view`
EMPLOYEE LINK REQUIRED: yes (active). Employee identity is derived from the
session; **the client must not send `employeeId`.**
COMPANY MODULE: `attendance`.
SUCCESS: `200`:

```json
{
  "success": true,
  "data": {
    "attendanceDate": "2026-09-24",
    "state": "working",
    "serverTimeUtc": "2026-09-24T06:00:00Z",
    "shift": { "id": "uuid", "name": "General", "startTime": "09:00", "endTime": "18:00", "overnight": false },
    "policy": { "id": "uuid", "name": "Standard", "requireLocation": true, "allowRemote": false },
    "workLocation": { "id": "uuid", "name": "HQ", "latitude": 25.0, "longitude": 55.0, "radiusMeters": 150, "validationMode": "geofencePreferred" },
    "actions": { "canPunchIn": false, "canBreak": true, "canResume": false, "canPunchOut": true },
    "warnings": [ { "code": "latePunchIn", "detail": 5 } ],
    "workTimeMinutes": 120, "breakTimeMinutes": 15,
    "locationState": "insideAllowedArea",
    "pendingSyncCount": 0
  },
  "meta": { "requestId": "uuid", "serverTimeUtc": "..." }
}
```

STATE: `notStarted | working | onBreak | completed`.
The `actions` object is server-computed from the state machine + policy +
location + sync; Flutter renders it directly and never infers it.
ERRORS: `403 ATT_NOT_LINKED_TO_EMPLOYEE`, `403 ATT_EMPLOYEE_INACTIVE`,
`403 ATT_SHIFT_NOT_ASSIGNED`, `403 ATT_POLICY_NOT_ASSIGNED`, `403 ATT_LOCATION_REQUIRED`.
FLUTTER CONSUMER: `AttendanceRepository.getCurrentAttendance/watchCurrentAttendance`.

### 10.2 Attendance actions

Prefer one command endpoint (matches the current `AttendanceCommand`):

METHOD: `POST` PATH: `/api/v1/hr/attendance/actions`
PERMISSION: `hr.attendance.self.punch` (punch/break/resume/out all require the
punch grant; see §11 rules).
EMPLOYEE LINK REQUIRED: yes.
REQUIRED HEADERS: `Idempotency-Key` **required** (maps to outbox `requestId`).
REQUEST BODY:

```json
{
  "action": "punchIn",
  "requestId": "uuid",
  "clientTimestampUtc": "2026-09-24T06:00:00Z",
  "location": { "latitude": 25.0, "longitude": 55.0, "accuracyMeters": 12.0, "capturedAtUtc": "2026-09-24T05:59:58Z" }
}
```

REQUEST FIELD TABLE:

| Field | Type | Required | Nullable | Validation |
| --- | --- | --- | --- | --- |
| `action` | enum | yes | no | `punchIn|breakStart|breakEnd|punchOut` |
| `requestId` | UUID | yes | no | idempotency |
| `clientTimestampUtc` | timestamp | yes | no | UTC; within allowed skew |
| `location` | object | conditional | yes | required when policy requires location |
| `location.latitude/longitude` | double | yes (if location) | no | range |
| `location.accuracyMeters` | double | yes (if location) | no | > 0 |
| `location.capturedAtUtc` | timestamp | yes (if location) | no | not stale |

BUSINESS VALIDATIONS (server authoritative): employee link + active; shift/policy
assigned; state-machine transition valid; duplicate event rejected by
`requestId`; geofence/accuracy; company timezone + overnight day ownership;
permission.
SUCCESS: `200` updated Attendance Today payload (§10.1) + `event`.
ERRORS (stable codes from `AttendanceFailureCode`): `409 ATT_ALREADY_PUNCHED_IN`,
`409 ATT_NOT_PUNCHED_IN`, `409 ATT_ALREADY_ON_BREAK`, `409 ATT_NOT_ON_BREAK`,
`422 ATT_BREAK_TRACKING_DISABLED`, `422 ATT_MULTIPLE_BREAKS_NOT_ALLOWED`,
`422 ATT_PUNCH_OUT_DURING_BREAK_NOT_ALLOWED`, `409 ATT_ALREADY_COMPLETED`,
`422 ATT_TOO_EARLY_TO_PUNCH_IN`, `422 ATT_LATE_PUNCH_IN_NOT_ALLOWED`,
`422 ATT_EARLY_PUNCH_OUT_NOT_ALLOWED`, `422 ATT_UNSCHEDULED_DAY`,
`422 ATT_OFFLINE_NOT_ALLOWED`, `422 ATT_OUTSIDE_ALLOWED_LOCATION`,
`422 ATT_LOCATION_ACCURACY_TOO_LOW`, `422 ATT_STALE_LOCATION_EVIDENCE`,
`403 ATT_REMOTE_NOT_ALLOWED`, `422 ATT_INVALID_TIMESTAMP`.
IDEMPOTENCY: required; same `requestId` → same result, no duplicate event.
CONCURRENCY: last-write-wins per state machine; conflicting transitions → 409.
AUDIT: attendance event (immutable) + activity event.
NOTIFICATION: punch-out reminder reconciliation; correction review notifications
where relevant.
FLUTTER CONSUMER: `AttendanceRepository.execute(AttendanceCommand)`.

### 10.3 Attendance state machine

```
notStarted --punchIn--> working --breakStart--> onBreak --breakEnd--> working
working --punchOut--> completed
onBreak --punchOut--> completed   (only if policy.allowPunchOutDuringBreak)
completed --(no mutation)-->
```

### 10.4 Attendance history (self)

METHOD: `GET` PATH: `/api/v1/hr/attendance/history`
PERMISSION: `hr.attendance.self.view`
EMPLOYEE LINK: yes.
QUERY: `month` (`YYYY-MM`), `status` (`present|late|working|incomplete`),
`sort` (`newest|oldest`), `page`, `pageSize`.
SUCCESS: `200` `{ monthlySummary: { present, late, incomplete, workedMinutes }, days: AttendanceDaySummaryDto[] }`.
Day detail: `GET /api/v1/hr/attendance/history/{attendanceDayId}` →
`AttendanceDayDetailsDto` (events timeline, breaks, issues).
FLUTTER CONSUMER: `AttendanceRepository.getAttendanceHistory/watchAttendanceHistory`,
`getAttendanceDayById`.

### 10.5 Team / All attendance

METHOD: `GET` PATH: `/api/v1/hr/attendance/records`
PERMISSION: `hr.attendance.records.view`
ALLOWED SCOPE: `team | all`
RECORD-SCOPE: `team` → resolved team only; `all` → company-wide. The server
resolves scope from grants; **never trust a client scope parameter.**
QUERY: `date`, `search`, `status`, `departmentId`, `shiftId`, `workLocationId`,
`sort`, `page`, `pageSize`.
SUCCESS: `200` paginated workforce rows + counts.
Day detail: `GET /api/v1/hr/attendance/records/{employeeId}/{attendanceDayId}`.
FLUTTER CONSUMER: `WorkforceAttendanceReadRepository.read/watch/readDay`.

### 10.6 Attendance corrections

- `POST /api/v1/hr/attendance/corrections` — `hr.attendance.self.correctionRequest`
  (+ employee link). Body: `{ type, attendanceDayId, requestedTimeUtc?, reason }`.
  Types: `missingPunchIn|missingPunchOut|changePunchIn|changePunchOut|missingBreakStart|missingBreakEnd|changeBreakStart|changeBreakEnd|custom`.
- `GET /api/v1/hr/attendance/corrections/mine` — `hr.attendance.self.correctionRequest`.
- `GET /api/v1/hr/attendance/corrections` — `hr.attendance.corrections.review`,
  scope `team|all`; pending queue.
- `GET /api/v1/hr/attendance/corrections/{id}` — review permission + scope.
- `POST /api/v1/hr/attendance/corrections/{id}/approve|reject` —
  `hr.attendance.corrections.review`. Body `{ note? }`.
- `POST /api/v1/hr/attendance/corrections/{id}/cancel` — self.

CONCURRENCY: a reviewed correction cannot be reviewed twice → `409 ATT_CORRECTION_ALREADY_REVIEWED`.
SELF-REVIEW: reviewer must not be the requesting employee → `403 ATT_SELF_REVIEW_NOT_ALLOWED`.
IMMUTABILITY: original attendance events are never mutated; approval records an
effective overlay (correction effect). Approval re-computes day totals.
IDEMPOTENCY: required for create/approve/reject/cancel.
NOTIFICATION: correction approved/rejected → requester; pending review →
reviewers with `hr.attendance.corrections.review`.
FLUTTER CONSUMER: `AttendanceCorrectionRepository.*`.

### 10.7 Attendance reports

- `GET /api/v1/hr/reports/attendance` — `hr.attendance.reports.view`, scope
  `team|all`.
  QUERY: `type` (`overview|workHours|lateAttendance|breakAnalysis|issues|employeeSummary`),
  `period` (`today|thisWeek|thisMonth|lastMonth|custom`), `from`, `to`,
  `scope` (server-validated against grants), `employeeId`, `departmentId`,
  `workLocationId`, `shiftId`, `issues`, `groupBy` (`department|shift|location`),
  `sort`, `granularity` (`day|week|month`), `page`, `pageSize`.
  SUCCESS: `200` report data (metrics, series, rows).
- `GET /api/v1/hr/reports/attendance/options` — filter option lists (scoped).
- `GET /api/v1/hr/reports/attendance/export?format=csv|pdf&...` — same
  authorization + filters as the on-screen report; **no scope bypass**. Returns
  a file stream (`text/csv` / `application/pdf`) or a download URL.
ERRORS: `403 REPORT_PERMISSION_DENIED`, `422` invalid filter, `422` filter scope
≠ granted scope.
FLUTTER CONSUMER: `AttendanceReportRepository.load/options/exportData` +
`AttendanceReportExportService`.

### 10.8 Attendance + Leave + Holiday classification

The server must support the same workday classification as Flutter:
`scheduledNoRecord`, `working`, `onBreak`, `completed`, `incomplete`,
`approvedLeave`, `holiday`, `nonWorkingDay`, `issue`.
**Do not label a missing attendance day "absent"** — there is no absence engine in
the current product. `approvedLeave` and `holiday` are derived from approved
leave requests + applicable holidays for the employee's work location.

---

## 11. Leave

### 11.1 Leave types

- `GET /api/v1/hr/leave/types` — `hr.leave.types.view` (+ self read for request
  forms). Query `search`, `status`, `page`, `pageSize`.
- `GET /api/v1/hr/leave/types/{id}` — view.
- `POST` / `PATCH /api/v1/hr/leave/types/{id}` — `hr.leave.types.manage`.
- `POST /api/v1/hr/leave/types/{id}/activate|deactivate` — manage.

Fields: `id, companyId, code, name, compensation` (`paid|unpaid|informational`),
`requiresApproval, allowsHalfDay, requiresReason, requiresAttachment, status,
createdAt, updatedAt`.
VALIDATION: code/name unique among active; `manage` implies `view`.

### 11.2 Leave policies

- `GET /api/v1/hr/leave/policies`, `/{id}`, `POST`, `PATCH`,
  `activate|deactivate`, `/{id}/assigned-employee-count` —
  `hr.leave.policies.view|manage`.

Fields (from model): `id, companyId, code, name, leaveTypeId, entitlementDays,
minimumDays, maximumConsecutiveDays, advanceNoticeDays, allowPastRequests,
pastRequestWindowDays, allowNegativeBalance, carryForwardEnabled,
carryForwardLimitDays, employmentScope, status, createdAt, updatedAt`.
Do not add fields the model does not have (e.g. no probation field unless present).

### 11.3 Leave policy assignments

The current domain tracks `EmployeeLeavePolicyAssignments` (data model). UI is
partially deferred. **BACKEND REQUIRED / CURRENT UI DEFERRED**:
`GET/PUT /api/v1/hr/leave/policy-assignments?employeeId=` (server resolves the
effective policy per employee).

### 11.4 Leave balance (ledger model — important)

Balances are derived from an **append-only ledger**, never a directly overwritten
number.

- `GET /api/v1/hr/leave/balances` — `hr.leave.balances.view`, scope `self|team|all`.
  `self` requires an employee link and returns the caller's balances.
- `GET /api/v1/hr/leave/balances/table` — scoped balance table for team/all.
- `GET /api/v1/hr/leave/balances/{employeeId}/ledger` —
  `hr.leave.balances.view` (scope).
- `POST /api/v1/hr/leave/balances/{employeeId}/adjust` —
  `hr.leave.balances.adjust`. Body: `{ leaveTypeId, quantity, reason, effectiveDate }`.
  Creates a ledger transaction (`adjustmentAdd|adjustmentSubtract`); **never
  overwrites a balance field.** Idempotency required.

Balance model: `entitlement`, `used`, `pending/reserved`, `available` derived
from ledger transaction types: `entitlement`, `adjustmentAdd`, `adjustmentSubtract`,
`leaveReserved`, `leaveReleased`, `leaveConsumed`, `carryForward`, `expiry`,
`migration`.

### 11.5 Leave preview

METHOD: `POST` PATH: `/api/v1/hr/leave/preview`
PERMISSION: `hr.leave.self.request` (or `hr.leave.records.view` when previewing
for others where supported).
REQUEST: `{ leaveTypeId, startDate, endDate, startPortion, endPortion }`.
SERVER CALCULATES (mirrors `LeaveDayCalculator`): working leave days, excluded
weekends/non-working days, excluded holidays, half-day handling, balance impact
(available before/after), eligibility, warnings.
SUCCESS: `200` `LeaveRequestPreviewDto`.
FLUTTER CONSUMER: `LeaveRepository.previewRequest`.

### 11.6 Leave request submit

METHOD: `POST` PATH: `/api/v1/hr/leave/requests`
PERMISSION: `hr.leave.self.request` (+ employee link)
REQUIRED HEADERS: `Idempotency-Key` required.
REQUEST: `{ leaveTypeId, startDate, endDate, startPortion, endPortion, reason, attachmentIds? }`.
VALIDATION: start ≤ end; type active; no overlap with existing requests; policy
eligibility (min/max/advance notice/past window); holiday/weekend exclusion; no
working days → `422 LEAVE_NO_WORKING_DAYS`; insufficient balance →
`422 LEAVE_INSUFFICIENT_BALANCE`.
SUCCESS: `201` `LeaveRequestDto` (status `pending`), reserve ledger entries.
AUDIT: `leave.requested` event. NOTIFICATION: approver (manager with
`hr.leave.requests.review`), submitter.
FLUTTER CONSUMER: `LeaveRepository.submitRequest`.

### 11.7 Leave request status

`pending | approved | rejected | cancelled`. Transitions:
`pending → approved | rejected | cancelled`; `approved → cancelled` (policy
permitting); `rejected`/`cancelled` terminal.

### 11.8 Leave request detail / list

- `GET /api/v1/hr/leave/requests` — `hr.leave.records.view`, scope `self|team|all`.
  QUERY: `status`, `employeeId`, `leaveTypeId`, `departmentId`, `period`
  (`today|thisWeek|thisMonth|next30|custom`), `search`, `page`, `pageSize`.
- `GET /api/v1/hr/leave/requests/{id}` — view + record scope.
- `GET /api/v1/hr/leave/requests/{id}` used for self via `self` scope.

### 11.9 Leave cancellation

METHOD: `POST` PATH: `/api/v1/hr/leave/requests/{id}/cancel`
PERMISSION: `hr.leave.self.cancel` (own) or review permission (administrative).
BODY `{ reason }`. Only pending/approved-cancellable requests →
`409 LEAVE_CANNOT_CANCEL_APPROVED`. Releases reserved ledger.
Idempotency required. AUDIT + notification.

### 11.10 Leave approval / rejection

METHOD: `POST` PATH: `/api/v1/hr/leave/requests/{id}/approve` (or `/reject`)
PERMISSION: `hr.leave.requests.review`, scope `team|all`.
BODY `{ note? }`.
BUSINESS (transactional): status transition + ledger reservation→consumption
(approve) or release (reject) + activity event + notification, in one unit.
SELF-APPROVAL: reviewer ≠ requester → `403 LEAVE_SELF_APPROVAL_NOT_ALLOWED`.
CONCURRENCY: already reviewed → `409 LEAVE_ALREADY_REVIEWED`.
IDEMPOTENCY: required.
NOTIFICATION: approved/rejected → requester.
FLUTTER CONSUMER: `LeaveRepository.approveRequest/rejectRequest`.

### 11.11 Team / All leave

Same endpoint (`/leave/requests`) with `team|all` scope. `team` = resolved team
only; `all` = company-wide. Never send company data to a team caller.

### 11.12 Approval queue

METHOD: `GET` PATH: `/api/v1/hr/leave/approvals`
PERMISSION: `hr.leave.requests.review`, scope `team|all`.
QUERY: `status` (default pending), `startingSoon`, `employeeId`, `leaveTypeId`,
`period`, `departmentId`, `page`, `pageSize`.
SUCCESS: `200` approval items (employee, type, dates, days, balance impact).
FLUTTER CONSUMER: `LeaveRepository.watchApprovalQueue`.

### 11.13 Employee leave profile

METHOD: `GET` PATH: `/api/v1/hr/leave/employees/{employeeId}`
PERMISSION: `hr.leave.records.view` + scope (or `self` for own).
SUCCESS: composed `{ employee, balances, upcoming, recentRequests, ledger? }`.
Recommend one composed endpoint to avoid N+1.
FLUTTER CONSUMER: `LeaveRepository.watchEmployeeLeave`.

### 11.14 Leave calendar

METHOD: `GET` PATH: `/api/v1/hr/leave/calendar`
PERMISSION: `hr.leave.records.view` (self/team/all).
QUERY: `from`, `to`, `scope`, `employeeId`, `departmentId`.
SUCCESS: `200` calendar entries `{ kind: leave|holiday, date, employeeId?, leaveTypeId?, status? }`.
PRIVACY: **do not include leave reasons** unless the permission requires it.

### 11.15 Leave operations (overview)

METHOD: `GET` PATH: `/api/v1/hr/leave/operations`
PERMISSION: `hr.leave.records.view` / review as applicable, scope.
SUCCESS: composed summary (on leave today, pending approvals, upcoming, team).
FLUTTER CONSUMER: `LeaveRepository.watchOperations`.

### 11.16 Leave reports

`GET /api/v1/hr/reports/leave` — `hr.reports.leave.view`, scope. Same filter/sort/
export rules as attendance reports. **NO BACKEND API REQUIRED** beyond a scoped
report read if the current UI only surfaces leave aggregates inside HR reports
(verify; the current leave report permission exists, so provide the scoped read).

---

## 12. Holidays

### 12.1 Holiday calendars

- `GET /api/v1/hr/holiday-calendars` — `hr.holidays.view` (list years/calendars).
- `GET /api/v1/hr/holiday-calendars/{id}` — view.
- `POST /api/v1/hr/holiday-calendars` / `PATCH /{id}` — `hr.holidays.manage`
  (year setup). Fields: `id, companyId, year, name, status, createdAt, updatedAt`.

### 12.2 Holiday CRUD

- `GET /api/v1/hr/holidays` — `hr.holidays.view`. Query `year`, `calendarId`,
  `type`, `scope`, `workLocationId`, `status`, `page`, `pageSize`.
- `GET /api/v1/hr/holidays/{id}` — view.
- `POST` / `PATCH /{id}` — `hr.holidays.manage`.
- `POST /api/v1/hr/holidays/{id}/deactivate` — manage.

Holiday fields: `id, companyId, calendarId, name, date` (company date),
`endDate?` (multi-day), `type` (`publicHoliday|festivalHoliday|regionalHoliday|companyHoliday|specialClosure`),
`isOptional` (bool, independent of type), `scope` (`companyWide|specificWorkLocations`),
`workLocationIds` (when scope = specific), `source`
(`manual|copied|imported|template`), `countryCode?`, `regionCode?`, `status,
createdAt, updatedAt`.
VALIDATION: date valid; multi-day end ≥ start; work-location scope requires ≥1
location; duplicate date+scope warning.

### 12.3 Holiday applicability

`GET /api/v1/hr/holidays/applicable?from=&to=&workLocationId=` —
`hr.holidays.view`. Server resolves which holidays apply to an employee/work
location (company-wide + matching specific locations).

### 12.4 Copy previous year

`POST /api/v1/hr/holidays/copy-year` — `hr.holidays.manage`.
BODY: `{ fromYear, toYear }`. Optional preview:
`POST /api/v1/hr/holidays/copy-year/preview`.
Returns created/skipped counts; sets `source = copied`; validates duplicates;
festival dates should be flagged for review. Idempotency recommended.
FLUTTER CONSUMER: `LeaveRepository.copyHolidaysToYear`.

### 12.5 Holiday CSV import

METHOD: `POST` PATH: `/api/v1/hr/holidays/import`
CONTENT-TYPE: `multipart/form-data`
PERMISSION: `hr.holidays.manage`
FILE FIELD: `file` (`.csv`, `text/csv`, max 2 MB).
REQUEST (optional): `calendarId`, `dryRun` (bool).
RESPONSE (dry-run or preview): `200` `HolidayImportResult`:

```json
{
  "success": true,
  "data": {
    "imported": 0, "skipped": 2,
    "rows": [ { "row": 3, "status": "skipped", "code": "HOLIDAY_DUPLICATE", "name": "New Year" } ]
  }
}
```

`dryRun=true` returns validation/preview without persisting; the client confirms
then calls again with `dryRun=false`. Idempotency required for the commit call.
FLUTTER CONSUMER: `LeaveRepository.importHolidays`.

---

## 13. Dashboard

### 13.1 HR dashboard

METHOD: `GET` PATH: `/api/v1/hr/dashboard`
PURPOSE: one composed endpoint for the HR dashboard (avoid 15 independent calls).
PERMISSION: none directly; **server shapes the payload by effective
permissions/scope** (see §13.2).
QUERY: `refresh` (bool).
SUCCESS: `200`:

```json
{
  "success": true,
  "data": {
    "scope": "team",
    "asOf": "2026-09-24",
    "metrics": [ { "kind": "teamSize", "value": 12 }, { "kind": "present", "value": 9 } ],
    "status": { "onTime": 9, "late": 2, "absent": 1, "onLeave": 0 },
    "activities": [ { "kind": "checkedIn", "person": "Ahmed", "timestamp": "..." } ],
    "alerts": [ { "kind": "lateArrivals", "count": 2 } ]
  },
  "meta": { "requestId": "uuid", "serverTimeUtc": "..." }
}
```

Metric kinds: `employees, teamSize, present, late, absent, leave, working,
onBreak, corrections, hours, attendanceRate, locations, users`.

### 13.2 Dashboard security (critical)

The server must **not** compute company-wide counts and rely on the UI to hide
them. Shape by effective permissions/scope:
- `employees` only with `hr.employees.view`/ALL.
- `teamSize` only with TEAM/ALL employee view.
- attendance metrics only with the matching attendance scope.
- `corrections` only with `hr.attendance.corrections.review|apply`.
- leave metrics only with the matching leave scope; pending approvals only with
  `hr.leave.requests.review`.
- `users` only with `company.users.manage`.
Quick actions are the resolved navigation destinations (Flutter); no backend
endpoint.

FLUTTER CONSUMER: `DashboardRepository.load` → `LocalDashboardRepository`.

---

## 14. Notifications

### 14.1 List notifications

METHOD: `GET` PATH: `/api/v1/notifications`
PERMISSION: none (self), `X-Company-Id` scoped.
QUERY: `unreadOnly`, `page`, `pageSize`.
SUCCESS: `200` paginated `AppNotificationDto`:
`{ id, type, priority, source, route, payload, readAt, createdAt }`.
Types: `shiftStartingSoon, punchOutReminder, correctionApproved, correctionRejected,
attendanceSyncFailed, attendanceConflict, pendingCorrectionReview,
leaveRequestSubmitted, leaveRequestApproved, leaveRequestRejected,
leaveRequestCancelled, leaveApprovalRequired`.
`route` is a **frontend** route (e.g. `/app/hr/leave/requests/{id}`); the client
re-checks permission on open.

### 14.2 Unread count / mark read

- `GET /api/v1/notifications/unread-count` → `{ count }`.
- `POST /api/v1/notifications/{id}/read` → `204`.
- `POST /api/v1/notifications/read-all` → `204`.
- Preferences: `GET/PATCH /api/v1/me/notification-preferences`
  (`{ attendanceReminders, leadMinutes }`).

### 14.3 HR-caused notifications (recipient + permission)

| Type | Trigger | Recipient | Deep link | Permission consideration |
| --- | --- | --- | --- | --- |
| `leaveApprovalRequired` | leave submitted | employee's manager (linked user) | `/app/hr/leave/requests/{id}` | recipient must hold `hr.leave.requests.review` (server filters) |
| `leaveRequestSubmitted` | leave submitted | submitter (ack) | `/app/hr/leave/my-requests` | self |
| `leaveRequestApproved/Rejected/Cancelled` | review/cancel | requester | `/app/hr/leave/requests/{id}` | self |
| `pendingCorrectionReview` | correction submitted | reviewers | `/app/hr/attendance/requests/{id}` | `hr.attendance.corrections.review` |
| `correctionApproved/Rejected` | review | requester | `/app/hr/attendance/corrections/{id}` | self |
| `punchOutReminder` / `shiftStartingSoon` | schedule | linked employee | `/app/hr/attendance` | `hr.attendance.self.view` |
| `attendanceSyncFailed` / `attendanceConflict` | sync | affected employee | `/app/hr/attendance/history` | self |

RULE: never target an actionable notification at a user who lacks the required
permission; re-check permission when the deep link is opened.

---

## 15. Sync / Outbox / Offline

The Flutter app is local-first with an outbox (`sync_outbox`): each mutation
stores `{ id, moduleId, entityId, entityType?, operation, payload, companyId,
requestId, status, attempts, nextAttemptAt, failureCode }`. `requestId` is
unique (idempotency). Recommendation: **normal resource endpoints + idempotency
+ retry/backoff**, not a bespoke batch sync engine, matching the existing outbox.

- Every mutation endpoint accepts `Idempotency-Key` (= outbox `requestId`).
- Replaying a stored request returns the original result (`200`/`201`), never a
  duplicate.
- On success Flutter deletes the outbox row and updates Drift.
- Conflict responses (`409`) map to `sync_conflicts` records for the UI.

### 15.1 Outbox operation matrix (current keys from code)

| moduleId | operation | Entity | Endpoint | Idempotency |
| --- | --- | --- | --- | --- |
| `employees` | `create` / `update` | Employee | `POST/PATCH /hr/employees` | yes |
| `employees` | `activate` / `deactivate` | Employee | `POST /hr/employees/{id}/activate|deactivate` | yes |
| `attendance` | `punchIn` / `breakStart` / `breakEnd` / `punchOut` | Attendance event | `POST /hr/attendance/actions` | required |
| `attendance-correction` | `request` | Correction | `POST /hr/attendance/corrections` | yes |
| `attendance-correction` | `cancel` | Correction | `POST /hr/attendance/corrections/{id}/cancel` | yes |
| `attendance-correction` | `approve` / `reject` | Correction | `POST /hr/attendance/corrections/{id}/approve|reject` | yes |
| `leave` | `leaveRequest.create` | Leave request | `POST /hr/leave/requests` | required |
| `leave` | `leaveRequest.cancel` | Leave request | `POST /hr/leave/requests/{id}/cancel` | required |
| `leave` | `leaveRequest.approve` / `leaveRequest.reject` | Leave request | `POST /hr/leave/requests/{id}/approve|reject` | required |
| `leave` | `leaveBalance.adjust` | Balance | `POST /hr/leave/balances/{employeeId}/adjust` | required |
| `leave` | `leaveType.create|update`, `leavePolicy.create|update`, `holiday.create|update` | Configuration | §9/§11/§12 | recommended |
| `hr`/`shared` | `create` / `update` / `activate` / `deactivate` | Shifts, Work Locations, Attendance Policies | §9 | recommended |
| `access` | `ACCESS_GRANTS_REPLACE` | Permission grants | `PUT /access/users/{id}/grants` | required |

### 15.2 Sync conflict mapping

| Situation | HTTP | Stable code |
| --- | --- | --- |
| duplicate request | `200/201` (idempotent replay) | — |
| server newer version | `409` | `*_STALE` |
| resource deleted/deactivated | `409` | `*_INACTIVE` |
| already reviewed | `409` | `LEAVE_ALREADY_REVIEWED` / `ATT_CORRECTION_ALREADY_REVIEWED` |
| permission removed | `403` | `ACCESS_PERMISSION_REVOKED` |
| company disabled | `403` | `COMPANY_INACTIVE` |
| validation changed | `422` | `*_INVALID` |

---

## 16. Audit / Activity

Structured, append-only events (never only English sentences):
`{ id, companyId, moduleKey, entityType, entityId, eventType, occurredAt,
actorUserId, actorEmployeeId?, summaryKey?, metadata, requestId?, syncStatus }`.

Required producers: `employee.created|updated|activated|deactivated`,
`leave.requested|approved|rejected|cancelled`, `leaveBalance.adjusted`,
`attendance.correction.requested|approved|rejected|cancelled`,
`access.permission.added|updated|removed`, configuration `created|updated|activated|deactivated`,
holiday `created|updated|imported|copied`.
`createdBy`/`updatedBy` are derived from the authenticated session — **never**
accepted from the request body. Documented distinction: audit = accountability,
activity = business timeline.

---

## 17. Attachments

**NO CURRENT HR ATTACHMENT ENDPOINT REQUIRED.** The attachment/media foundation
(metadata only, no bytes in Drift) exists as shared infrastructure for future
Services. If leave attachments (`requiresAttachment`) are activated, the
contract is: `POST /api/v1/attachments` (metadata + upload), `GET
/api/v1/attachments/{id}`, `DELETE /api/v1/attachments/{id}` — reserved for the
Services increment.

---

## 18. Standard DTOs

- `EmployeeReferenceDto`: `{ id, employeeCode, displayName }`.
- `ReferenceDto`: `{ id, name }` (+ `code` where present).
- `UserAccountDto`: `{ id, displayName, email, phone, avatarUrl, status }`.
- `CompanyDto`: `{ id, name, code, timezone, defaultLocale, logoUrl, enabledModules }`.
- `GrantDto`: `{ key, scope, expiresAt, isActive, grantedByUserId, grantedAt, updatedAt }`.
- `PageMeta`: `{ page, pageSize, totalItems, totalPages, requestId, serverTimeUtc }`.
- `ApiError`: `{ code, message, fieldErrors, details }`.

Data minimization: list DTOs omit heavy fields; detail DTOs are richer; selectors
use reference DTOs only.

---

## 19. Error Catalog

Grouped stable codes (derived from current domain failures; not speculative):

- **AUTH**: `AUTH_INVALID_INPUT`, `AUTH_INVALID_CREDENTIALS`,
  `AUTH_ACCOUNT_SUSPENDED`, `AUTH_REFRESH_INVALID`, `AUTH_REFRESH_EXPIRED`,
  `AUTH_CURRENT_PASSWORD_INVALID`, `AUTH_PASSWORD_POLICY`, `AUTH_PASSWORD_SAME`,
  `AUTH_RATE_LIMITED`.
- **ACCESS**: `ACCESS_NOT_PERMITTED`, `ACCESS_SELF_ESCALATION`,
  `ACCESS_LAST_ADMIN`, `ACCESS_PLATFORM_ONLY`, `ACCESS_NOT_DELEGABLE`,
  `ACCESS_MODULE_DISABLED`, `ACCESS_EMPLOYEE_LINK_REQUIRED`,
  `ACCESS_UNSUPPORTED_SCOPE`, `ACCESS_UNKNOWN_PERMISSION`,
  `ACCESS_PERMISSION_REVOKED`.
- **COMPANY**: `COMPANY_MEMBERSHIP_REQUIRED`, `COMPANY_INACTIVE`,
  `COMPANY_MODULE_DISABLED`.
- **EMPLOYEE**: `EMP_DUPLICATE_EMAIL`, `EMP_DUPLICATE_PHONE`,
  `EMP_INVALID_REFERENCE`, `EMP_INVALID_MANAGER`, `EMP_STALE`,
  `EMP_ALREADY_INACTIVE`, `EMP_NOT_FOUND`.
- **ATTENDANCE**: all `AttendanceFailureCode` values (see §10.2) e.g.
  `ATT_ALREADY_PUNCHED_IN`, `ATT_NOT_PUNCHED_IN`, `ATT_ALREADY_ON_BREAK`,
  `ATT_NOT_ON_BREAK`, `ATT_ALREADY_COMPLETED`, `ATT_OUTSIDE_ALLOWED_LOCATION`,
  `ATT_LOCATION_ACCURACY_TOO_LOW`, `ATT_LOCATION_UNAVAILABLE`,
  `ATT_SHIFT_NOT_ASSIGNED`, `ATT_POLICY_NOT_ASSIGNED`,
  `ATT_LOCATION_REQUIRED_BUT_MISSING`, `ATT_UNSCHEDULED_DAY`,
  `ATT_OFFLINE_NOT_ALLOWED`, `ATT_STALE_LOCATION_EVIDENCE`,
  `ATT_INVALID_TIMESTAMP`, `ATT_NOT_LINKED_TO_EMPLOYEE`, `ATT_EMPLOYEE_INACTIVE`.
- **CORRECTION**: `ATT_CORRECTION_ALREADY_REVIEWED`, `ATT_SELF_REVIEW_NOT_ALLOWED`,
  `ATT_CORRECTION_NOT_FOUND`.
- **LEAVE**: `LEAVE_INVALID_DATE_RANGE`, `LEAVE_NO_WORKING_DAYS`,
  `LEAVE_MINIMUM_DAYS`, `LEAVE_OVERLAPPING`, `LEAVE_INSUFFICIENT_BALANCE`,
  `LEAVE_PAST_REQUEST_NOT_ALLOWED`, `LEAVE_ADVANCE_NOTICE_REQUIRED`,
  `LEAVE_INVALID_QUANTITY`, `LEAVE_TYPE_INACTIVE`, `LEAVE_REASON_REQUIRED`,
  `LEAVE_ALREADY_REVIEWED`, `LEAVE_CANNOT_CANCEL_APPROVED`,
  `LEAVE_SELF_APPROVAL_NOT_ALLOWED`, `LEAVE_REQUEST_NOT_FOUND`.
- **HOLIDAY**: `HOLIDAY_DUPLICATE`, `HOLIDAY_INVALID_RANGE`,
  `HOLIDAY_SCOPE_REQUIRES_LOCATION`, `HOLIDAY_IMPORT_INVALID_FILE`,
  `HOLIDAY_IMPORT_ROW_ERROR`.
- **CONFIGURATION**: `CFG_DUPLICATE_NAME`, `CFG_INVALID_TIME`,
  `CFG_WORKING_DAYS_REQUIRED`, `CFG_INVALID_GRACE`, `CFG_INVALID_BREAK`,
  `CFG_INVALID_MINIMUM`, `CFG_INVALID_COORDINATES`, `CFG_INVALID_RADIUS`,
  `CFG_INVALID_ACCURACY`, `CFG_IN_USE`, `CFG_NOT_FOUND`.
- **SYNC**: `SYNC_CONFLICT`, `SYNC_STALE`, `SYNC_IDEMPOTENT_REPLAY`.
- **VALIDATION**: `VALIDATION_REQUIRED_FIELD`, `VALIDATION_INVALID_FORMAT`,
  `VALIDATION_UNKNOWN_FIELD`.

---

## 20. Enum Contract

| Enum | Wire values | Notes |
| --- | --- | --- |
| `AccountStatus` | `active, suspended, inactive` | |
| `EmploymentType` | `fullTime, partTime, contract, intern, temporary` | |
| `EmploymentStatus` | `active, inactive` | |
| `AttendanceWorkdayState` | `notStarted, working, onBreak, completed` | transitions §10.3 |
| `AttendanceEventType` | `punchIn, breakStart, breakEnd, punchOut` | |
| `AttendanceEventSource` | `mobile, web, manual, kiosk` | |
| `AttendanceSyncStatus` | `pending, synced, failed, rejected` | |
| `AttendanceHistoryStatus` | `present, late, working, incomplete` | |
| `AttendanceHistorySort` | `newest, oldest` | |
| `AttendanceRecordIssue` | `missingPunchOut, openBreak, syncFailed, serverRejected` | |
| `AttendanceCorrectionStatus` | `pending, approved, rejected, cancelled` | |
| `AttendanceCorrectionType` | `missingPunchIn, missingPunchOut, changePunchIn, changePunchOut, missingBreakStart, missingBreakEnd, changeBreakStart, changeBreakEnd, custom` | |
| `AttendanceCorrectionChangeType` | `add, replace` | |
| `BreakMode` | `manual, fixed, none` | |
| `LocationValidationMode` | `geofenceRequired, geofencePreferred, captureOnly, none` | |
| `OfflineMode` | `none, pending, warning` | |
| `LeaveRequestStatus` | `pending, approved, rejected, cancelled` | transitions §11.7 |
| `LeaveDayPortion` | `fullDay, firstHalf, secondHalf` | |
| `LeaveCompensationType` | `paid, unpaid, informational` | |
| `LeaveBalanceTransactionType` | `entitlement, adjustmentAdd, adjustmentSubtract, leaveReserved, leaveReleased, leaveConsumed, carryForward, expiry, migration` | ledger |
| `HolidayType` | `publicHoliday, festivalHoliday, regionalHoliday, companyHoliday, specialClosure` | |
| `HolidayScope` | `companyWide, specificWorkLocations` | |
| `HolidaySource` | `manual, copied, imported, template` | |
| `ConfigurationStatus` | `active, inactive` | |
| `WorkdayClassification` | `scheduledNoRecord, working, onBreak, completed, incomplete, approvedLeave, holiday, nonWorkingDay, issue` | |
| `AttendanceReportType` | `overview, workHours, lateAttendance, breakAnalysis, issues, employeeSummary` | |
| `AttendanceReportPeriod` | `today, thisWeek, thisMonth, lastMonth, custom` | |
| `AttendanceReportSort` | `newest, oldest, employee, workedMost, breaksMost` | |
| `AttendanceReportGroup` | `department, shift, location` | |
| `ReportGranularity` | `day, week, month` | |
| `PermissionScope` | `none, self, assigned, team, all` | |
| `NotificationType` | see §14.1 | |
| `NotificationPriority` | `low, normal, high` | |
| `OutboxOperationStatus` | `pending, processing, retryScheduled, synced, failed, rejected, conflict, cancelled` | |

---

## 21. Permission → API Matrix

| Endpoint | Method | Module | Permission | Scope | Employee link | Record-scope rule |
| --- | --- | --- | --- | --- | --- | --- |
| `/auth/login` | POST | platform | — | — | no | — |
| `/me/bootstrap` | GET | platform | — | — | no | membership |
| `/me/profile` | GET | platform | — | — | no | self |
| `/access/users` | GET | platform | `company.access.users.view` | — | no | company |
| `/access/users/{id}/grants` | PUT | platform | `company.access.permissions.manage` | — | no | authority rules §7.4 |
| `/company/modules` | GET | platform | `company.modules.view` | — | no | company |
| `/hr/employees` | GET | employees | `hr.employees.view` | self/team/all | self | team = manager subtree |
| `/hr/employees` | POST | employees | `hr.employees.create` | — | no | company |
| `/hr/employees/{id}` | PATCH | employees | `hr.employees.edit` | team/all | no | scope |
| `/hr/employees/{id}/deactivate` | POST | employees | `hr.employees.deactivate` | — | no | company |
| `/hr/employees/references` | GET | employees | `hr.employees.view` | self/team/all | — | scoped selectors |
| `/hr/shifts*` | GET | attendance | `hr.attendance.shifts.view` | — | no | company |
| `/hr/shifts*` | POST/PATCH | attendance | `hr.attendance.shifts.manage` | — | no | company |
| `/hr/work-locations*` | GET | attendance | `hr.attendance.locations.view` | — | no | company |
| `/hr/work-locations*` | POST/PATCH | attendance | `hr.attendance.locations.manage` | — | no | company |
| `/hr/attendance-policies*` | GET | attendance | `hr.attendance.policies.view` | — | no | company |
| `/hr/attendance-policies*` | POST/PATCH | attendance | `hr.attendance.policies.manage` | — | no | company |
| `/hr/attendance/today` | GET | attendance | `hr.attendance.self.view` | self | yes | self |
| `/hr/attendance/actions` | POST | attendance | `hr.attendance.self.punch` | self | yes | self |
| `/hr/attendance/history` | GET | attendance | `hr.attendance.self.view` | self | yes | self |
| `/hr/attendance/records` | GET | attendance | `hr.attendance.records.view` | team/all | team | resolved team / company |
| `/hr/attendance/corrections` (mine) | GET/POST | attendance | `hr.attendance.self.correctionRequest` | self | yes | self |
| `/hr/attendance/corrections` (queue) | GET | attendance | `hr.attendance.corrections.review` | team/all | no | resolved team / company |
| `/hr/attendance/corrections/{id}/approve|reject` | POST | attendance | `hr.attendance.corrections.review` | team/all | no | scope + not self |
| `/hr/reports/attendance` | GET | reports | `hr.attendance.reports.view` | team/all | no | scope |
| `/hr/reports/attendance/export` | GET | reports | `hr.attendance.reports.view` | team/all | no | same as on-screen |
| `/hr/leave/types*` | GET | leave | `hr.leave.types.view` | — | no | company |
| `/hr/leave/types*` | POST/PATCH | leave | `hr.leave.types.manage` | — | no | company |
| `/hr/leave/policies*` | GET | leave | `hr.leave.policies.view` | — | no | company |
| `/hr/leave/policies*` | POST/PATCH | leave | `hr.leave.policies.manage` | — | no | company |
| `/hr/leave/balances` | GET | leave | `hr.leave.balances.view` | self/team/all | self | scope |
| `/hr/leave/balances/{id}/adjust` | POST | leave | `hr.leave.balances.adjust` | — | no | company |
| `/hr/leave/preview` | POST | leave | `hr.leave.self.request` | self | yes | self |
| `/hr/leave/requests` | POST | leave | `hr.leave.self.request` | self | yes | self |
| `/hr/leave/requests` | GET | leave | `hr.leave.records.view` | self/team/all | self | scope |
| `/hr/leave/requests/{id}/cancel` | POST | leave | `hr.leave.self.cancel` | self | yes | self |
| `/hr/leave/requests/{id}/approve|reject` | POST | leave | `hr.leave.requests.review` | team/all | no | scope + not self |
| `/hr/leave/approvals` | GET | leave | `hr.leave.requests.review` | team/all | no | scope |
| `/hr/leave/employees/{id}` | GET | leave | `hr.leave.records.view` | self/team/all | — | scope |
| `/hr/leave/calendar` | GET | leave | `hr.leave.records.view` | self/team/all | — | scope |
| `/hr/leave/operations` | GET | leave | `hr.leave.records.view` | self/team/all | — | scope |
| `/hr/reports/leave` | GET | reports | `hr.reports.leave.view` | team/all | no | scope |
| `/hr/holiday-calendars*` | GET | leave | `hr.holidays.view` | — | no | company |
| `/hr/holidays*` | GET | leave | `hr.holidays.view` | — | no | company |
| `/hr/holidays*` | POST/PATCH | leave | `hr.holidays.manage` | — | no | company |
| `/hr/holidays/import` | POST | leave | `hr.holidays.manage` | — | no | company |
| `/hr/holidays/copy-year` | POST | leave | `hr.holidays.manage` | — | no | company |
| `/hr/dashboard` | GET | hr | (permission-shaped) | scope | — | server shapes payload |
| `/notifications*` | GET/POST | platform | — | — | no | self |

Module column also implies the company feature flag must be enabled.

---

## 22. Idempotency Summary

`Idempotency-Key` **required**: attendance actions, correction create/approve/
reject/cancel, leave submit/approve/reject/cancel, balance adjust, holiday import
commit, permission grant replacement, employee create (recommended).
Behavior: store key + result for a retention window; replay returns the original
status/body; never create a second record.

---

## 23. Concurrency Summary

| Operation | Guard | Conflict code |
| --- | --- | --- |
| Leave review | status must be `pending` + last-seen `updatedAt` | `LEAVE_ALREADY_REVIEWED` |
| Correction review | status must be `pending` | `ATT_CORRECTION_ALREADY_REVIEWED` |
| Permission replacement | last-seen grant set version/`updatedAt` | `ACCESS_STALE` |
| Configuration edit | last-seen `updatedAt` | `CFG_STALE` |
| Holiday edit | last-seen `updatedAt` | `HOLIDAY_STALE` |

---

## 24. Repository → API Matrix

| Repository (interface) | Method | Local impl | Endpoint | Method | Permission | Scope |
| --- | --- | --- | --- | --- | --- | --- |
| `AuthRepository` | `login/restoreSession/checkSession/logout/changePassword/requestPasswordReset` | `DemoAuthRepository` | §4 | POST/GET | — | — |
| `AccessRepository` | `watchUsers/getGrants/replaceGrants/watchHistory/watchCompanyGrants` | `LocalAccessRepository` | §7 | GET/PUT | access perms | company |
| `EmployeeRepository` | `watchEmployees/watchEmployee/getEmployeeById/saveEmployee/setActive/checkEmail…/getLinkedAccount/getReferences` | `LocalEmployeeRepository` | §8 | GET/POST/PATCH | employees perms | self/team/all |
| `ShiftRepository` | list/details/save/setActive/assignedEmployeeCount | `LocalShiftRepository` | §9.1 | GET/POST/PATCH | shifts view/manage | — |
| `WorkLocationRepository` | same | `LocalWorkLocationRepository` | §9.2 | GET/POST/PATCH | locations view/manage | — |
| `AttendancePolicyRepository` | same | `LocalAttendancePolicyRepository` | §9.3 | GET/POST/PATCH | policies view/manage | — |
| `AttendanceRepository` | `getCurrentAttendance/watchCurrentAttendance/execute/getAttendanceHistory/watchAttendanceHistory/getAttendanceDayById/retryPendingOperation` | `LocalAttendanceRepository` | §10.1–10.4 | GET/POST | self view/punch | self |
| `WorkforceAttendanceReadRepository` | `read/watch/readDay/options/select/companyToday` | `WorkforceAttendanceReadRepository` | §10.5 | GET | records.view | team/all |
| `AttendanceCorrectionRepository` | `createRequest/cancelRequest/approveRequest/rejectRequest/watchMyRequests/watchPendingRequests/getRequestById` | `LocalAttendanceCorrectionRepository` | §10.6 | GET/POST | self.correctionRequest / review | self/team/all |
| `AttendanceReportRepository` | `load/options/exportData/companyToday` | `LocalAttendanceReportRepository` | §10.7 | GET | reports.view | team/all |
| `LeaveRepository` | types/policies/holidays/requests/balances/ledger/calendar/operations | `LocalLeaveRepository` | §11–§12 | GET/POST/PATCH | leave perms | self/team/all |
| `ConfigurationRepository<T,D>` | `watchList/watchDetails/getById/save/setActive/assignedEmployeeCount` | `LocalConfigurationRepository` | §9 | GET/POST/PATCH | view/manage | — |
| `NotificationRepository` | `createLocal/watch/list/markRead/…` | `LocalNotificationRepository` | §14 | GET/POST | — | self |
| `DashboardRepository` | `load` | `LocalDashboardRepository` | §13 | GET | (shaped) | scope |
| `OutboxRepository` | `enqueue/watchPending/acknowledge` | `LocalOutboxRepository` | §15 | — | — | — |
| `UserGrantsController` | `permissionsFor/watch` | `LocalUserGrantsController` | §5.1 bootstrap | GET | — | — |

---

## 25. Screen → API Matrix

| Screen (route) | APIs required |
| --- | --- |
| Login (`/login`) | `POST /auth/login` |
| Bootstrap/session | `GET /auth/session`, `GET /me/bootstrap` |
| HR dashboard (`/app/hr`) | `GET /hr/dashboard` |
| Employee list (`/app/hr/employees`) | `GET /hr/employees`, `GET /hr/employees/references` |
| Employee details (`/app/hr/employees/:id`) | `GET /hr/employees/{id}`, `GET /hr/employees/{id}/account` |
| Employee form (new/edit) | `POST/PATCH /hr/employees`, `GET /hr/employees/references`, availability checks |
| Attendance today (`/app/hr/attendance`) | `GET /hr/attendance/today`, `POST /hr/attendance/actions` |
| Attendance history | `GET /hr/attendance/history`, `GET /hr/attendance/history/{id}` |
| Team/All attendance | `GET /hr/attendance/records`, `GET /hr/attendance/records/{emp}/{day}` |
| Corrections | §10.6 endpoints |
| Attendance reports | `GET /hr/reports/attendance`, `.../options`, `.../export` |
| Leave home / my requests | `GET /hr/leave/requests`, `POST /hr/leave/preview`, `POST /hr/leave/requests` |
| Leave approvals | `GET /hr/leave/approvals`, `POST /hr/leave/requests/{id}/approve|reject` |
| Leave balances | `GET /hr/leave/balances`, `.../ledger`, `.../adjust` |
| Leave calendar | `GET /hr/leave/calendar` |
| Leave types/policies/holidays settings | §11.1/§11.2/§12 |
| Holiday management | §12 CRUD + copy + import |
| Users & Access (`/app/settings/access`) | §7 endpoints |
| Company modules (`/app/settings/modules`) | `GET /company/modules` |
| Profile (`/app/profile`) | `GET /me/profile`, `PATCH /me/preferences`, `POST /auth/change-password` |
| Notifications | §14 |

---

## 26. Backend vs Frontend Authority

| Concern | Authority |
| --- | --- |
| Permission / scope / module enforcement | **Backend** |
| Tenant isolation | **Backend** |
| Attendance transition validity | **Backend** |
| Attendance geofence/location validation | **Backend** |
| Leave day calculation | **Backend** (Flutter may preview) |
| Leave balance / ledger | **Backend** |
| Leave approval state | **Backend** |
| Holiday calendar + applicability | **Backend** |
| Employee records + codes | **Backend** |
| Company timezone | **Backend config**; Flutter renders |
| Idempotency / concurrency | **Backend** |
| Navigation, menus, action visibility | **Flutter** |
| Localization labels | **Flutter** |
| Offline cache / outbox | **Flutter** |

---

## 27. Security Requirements

- Validate tokens on every request; short-lived access tokens; rotating refresh tokens; revoke on logout/reuse.
- Tenant isolation: verify membership + company active + module enabled; record company must match `X-Company-Id`; never trust `companyId` from the body.
- Enforce permission + scope server-side on every endpoint (§21).
- Mass-assignment prevention: whitelist fields; ignore `createdByUserId`/`updatedByUserId`/`id`/`companyId` from bodies.
- Do not accept permission/scope assertions from the body.
- Input validation + parameterized queries (SQL injection).
- File upload validation: type, size, content sniffing; scan; never trust extension/MIME alone.
- PII minimization: return only needed fields; no secrets/tokens/password hashes.
- Audit actor from session only.
- Rate limit login, password reset, file import, repeated attendance mutation.
- HTTPS only; strict CORS; CSRF protection for cookie-based web sessions (Bearer tokens are less exposed).
- Self-service APIs derive employee identity from the session (never an arbitrary `employeeId`).

---

## 28. Performance / Caching

- Avoid N+1: employee list returns denormalized department/designation names; leave/attendance lists return employee display fields; dashboard is one composed endpoint; calendar is a range endpoint.
- Cache (with revalidation): permission catalog, company bootstrap, configuration/master lists, holidays, references.
- Do **not** cache volatile attendance mutations or leave balances.
- Recommend `ETag`/`If-None-Match` on read endpoints and `catalogVersion` for permissions.

---

## 29. OpenAPI Implementation Notes

- Model success/error envelopes as generic wrappers (`ApiResponse<T>`, `ApiError`).
- Map every enum to a string schema with the wire values in §20.
- Reuse `PageMeta`, `EmployeeReferenceDto`, `GrantDto`, `ReferenceDto`.
- One `Idempotency-Key` header parameter on all mutations listed in §22.
- Security scheme: `bearerAuth`; `X-Company-Id` as a required header parameter on company-scoped operations.
- Group tags by module: `Auth`, `Access`, `Company`, `Employees`, `Attendance`, `Leave`, `Holidays`, `Dashboard`, `Notifications`, `Sync`.

---

## 30. Product Questions / TBDs

1. **Employee account/security field permission.** Should `linkedUserId`/`loginEnabled`/provisioning require a dedicated `hr.employees.accountAccess.manage` permission? Current Flutter gates account access inside the employee form by employee edit + `company.users.manage`. **Recommended default:** introduce the dedicated permission; until then reuse employee edit + user manage. Affects §8.2/§8.8.
2. **Leave attachments.** `requiresAttachment` exists on leave types but no HR attachment endpoint is implemented. **Recommended default:** reserve §17 endpoints, do not enable until Services.
3. **Leave policy assignments UI.** Data model exists; UI deferred. **Recommended default:** provide the backend endpoints (§11.3) so future UI can consume them.
4. **Company module mutation.** Read-only today. **Recommended default:** platform-only mutation endpoint, future.
5. **Global search.** Current search is a placeholder (navigation only). **Recommended default:** no record-search API required now.
6. **Exact attendance report payload shape.** Derive from `AttendanceReportData`; confirm aggregation semantics (trends/series) with product.
7. **Multi-company active-company persistence.** Whether the server stores the active company or the client sends it per request. **Recommended default:** client sends `X-Company-Id`; server verifies membership.

---

## 31. API Completeness Checklist

- [x] Authentication covered (§4)
- [x] Refresh token covered (§4.2)
- [x] Logout covered (§4.3)
- [x] Session validation covered (§4.4)
- [x] Password change/reset covered (§4.5/§4.6)
- [x] Company bootstrap covered (§5.1)
- [x] Company memberships covered (§5.2)
- [x] Company switch covered (§5.3)
- [x] Profile covered (§6)
- [x] Permission catalog covered (§7.1)
- [x] Access list/detail covered (§7.2/§7.3)
- [x] Grant replacement + authority rules covered (§7.4)
- [x] Access history covered (§7.5)
- [x] Module entitlement covered (§7.6)
- [x] Employee CRUD covered (§8)
- [x] Employee references covered (§8.6)
- [x] Employee availability/linked account covered (§8.7/§8.8)
- [x] Shift CRUD covered (§9.1)
- [x] Work Location CRUD covered (§9.2)
- [x] Attendance Policy CRUD covered (§9.3)
- [x] Attendance Today covered (§10.1)
- [x] Punch In / Break / Resume / Punch Out covered (§10.2)
- [x] Attendance state machine covered (§10.3)
- [x] Attendance History covered (§10.4)
- [x] Team Attendance covered (§10.5)
- [x] All Attendance covered (§10.5)
- [x] Corrections + review covered (§10.6)
- [x] Attendance Reports + export covered (§10.7)
- [x] Attendance/Leave/Holiday classification covered (§10.8)
- [x] Leave Types covered (§11.1)
- [x] Leave Policies covered (§11.2)
- [x] Leave Policy assignments covered (§11.3)
- [x] Balance + ledger covered (§11.4)
- [x] Leave preview covered (§11.5)
- [x] Leave submit covered (§11.6)
- [x] Leave status covered (§11.7)
- [x] Leave detail/list covered (§11.8)
- [x] Leave cancel covered (§11.9)
- [x] Leave approval/rejection covered (§11.10)
- [x] Team/All Leave covered (§11.11)
- [x] Approval queue covered (§11.12)
- [x] Employee Leave covered (§11.13)
- [x] Leave Calendar covered (§11.14)
- [x] Leave operations covered (§11.15)
- [x] Holiday Calendars covered (§12.1)
- [x] Holiday CRUD covered (§12.2)
- [x] Holiday scope/applicability covered (§12.3)
- [x] Holiday copy year covered (§12.4)
- [x] Holiday CSV import covered (§12.5)
- [x] Dashboard covered (§13)
- [x] Notifications covered (§14)
- [x] Sync/outbox covered (§15)
- [x] Audit/activity covered (§16)
- [x] Attachments covered (no HR endpoint required) (§17)
- [x] Standard DTOs covered (§18)
- [x] Error catalog covered (§19)
- [x] Enum contract covered (§20)
- [x] Permission → API matrix complete (§21)
- [x] Idempotency covered (§22)
- [x] Concurrency covered (§23)
- [x] Repository → API matrix complete (§24)
- [x] Screen → API matrix complete (§25)
- [x] Backend vs Frontend authority covered (§26)
- [x] Security covered (§27)
- [x] Performance/caching covered (§28)
- [x] OpenAPI notes covered (§29)
- [x] TBDs captured (§30)
- [x] Services excluded (per scope)
- [x] No application behavior modified (documentation only)
