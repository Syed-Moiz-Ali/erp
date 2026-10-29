# Backend hand-off â€” MassERP client integration

Audit date: 2026-10-28
Source of findings: `audit-output/massep-2026-10-28/01..07` (read-only audit).
This document records backend decisions/fixes required by the Flutter client. No backend code is in this repository.

## 1. Employee view permission is a temporary QA grant (B-01)

**Finding:** the live permission catalog originally had no active `hr.employees.view`; every employee read returned `403 ACCESS_DENIED`. Permission master ids 1-3 are gone while user-permission rows still reference them (`permissionKey:null`, `permissionStatusId:2`).

**Current live state (2026-10-29):** permission id 18, "View employees (QA audit)", exists and is described as a temporary QA audit permission. Admin holds it through self-assigned grant 145, and the employee account also holds `hr.employees.view` plus `hr.employees.edit`. Both accounts now receive the employee list and lookups. The earlier Admin `403` fixture is retained as historical pre-grant evidence only.

**Permanent fix still required:** seed an official `hr.employees.view` permission and migrate grants off the temporary QA permission. Clean user-permission rows 1-3 (orphan grants pointing at deleted permission masters 1-3), and keep the permission seed idempotent.

**Client assumption:** a backend session receives `hr.employees.view` from `/api/me/permissions`; a key-only grant is treated as the broadest client scope.

**Open platform question:** `branches[]` versus `orgCount` in the login/session payload is still unresolved for the backend owner; the client continues to use `branches[]` for branch context.

## 2. Session permissions/scopes/modules (B-02, B-07, C-02/C-03)

**Finding:** login/refresh return no permission or module payload. `/api/me/permissions` returns key-only grants; there are no scopes and no enabled-modules endpoint.

**Client assumption (documented in `docs/client-decisions.md`):**
- call `/api/me/permissions` after login, refresh, app resume and `403 ACCESS_DENIED`;
- treat a granted key as the broadest client scope (`ALL`) for scoped keys;
- derive enabled modules from granted keys in `lib/core/security/backend_access_policy.dart`.

**What breaks if not fixed:** module entitlement is a client guess; SELF/TEAM/ASSIGNED record scoping cannot be enforced; changing a grant to a narrower scope is impossible. The client fails closed when the call fails, so users see "permissions unavailable" rather than stale access.

**Required:** add scopes and module entitlement to `/me/access` (or login/refresh), and document default scopes for existing grants.

## 3. Employee PUT is a destructive full replace (B-03)

**Finding:** `PUT /api/employees/{id}` clears optional fields that are omitted. A body without `email`, `phone`, `dateOfBirth`, `maritalStatus`, `employeeType` writes nulls.

**Client assumption:** update must send the complete employee object. The remote employee adapter must load the full detail, merge the form changes and send every field.

**What breaks if not fixed:** any partial update erases payroll/identity/contact data. The current Postman update body has this defect.

**Required:** choose and document PUT-as-replace (and make clients send full detail) or add PATCH/merge semantics. Add regression tests for omitted fields.

## 4. Activate does not restore login (B-04)

**Finding:** deactivating an employee disables the linked login; activating the employee leaves the login `InActive`. A second update with `login.enabled=true` is required.

**Client assumption:** the employee detail is re-read after activate; `login.enabled/canLogin` is displayed truthfully and never assumed active.

**What breaks if not fixed:** HR activates an employee who still cannot sign in, with no API-level signal explaining why.

**Required:** either restore the previous login state on activate or return/document an explicit two-step flow.

## 5. Inactive branch accepted on employee create (B-06)

**Finding:** employee create succeeds with an inactive branch (201) but rejects an inactive department (400).

**Client assumption:** lookup branches are selectable; inactive branches should not be usable for new employment.

**What breaks if not fixed:** employees can be assigned to closed branches; reports/attendance scope may be inconsistent.

**Required:** reject inactive branches consistently and exclude them from employee lookups.

## 6. Permission key format (B-05)

**Finding:** `permissionKey: "bad key with spaces"` is accepted (201).

**Client assumption:** backend keys are machine identifiers and match the client catalog mapping.

**What breaks if not fixed:** a key can never be mapped by the client and silently grants nothing.

**Required:** validate key format, length and case-insensitive uniqueness; return a field error.

## 7. Delegation ceiling (B-09)

**Finding:** any holder of `company.access.permissions.manage` can grant that key to another ordinary user.

**Decided policy (product owner):** this is intended. Admin means any user holding `company.access.permissions.manage`; an Admin may grant any permission key to any employee user, including module permissions. There is no delegation ceiling to enforce. Self-assignment is not blocked in the client; if the backend refuses a self-grant, the client must show the backend `403` message.

**What remains required:** document this policy in the backend authorization contract and keep the last-admin/self-escalation behaviour explicit (whether allowed or refused). The client no longer treats B-09 as an open decision.

## 8. Logout without a body returns 415 (B-11)

**Finding:** `POST /api/auth/logout` without JSON/body returns 415, outside the documented 200/400 table.

**Client assumption:** always send a JSON body with the refresh token; 415 is treated as a request error, not a session-ending code.

**What breaks if not fixed:** third-party/legacy clients can fail to log out cleanly and the documented error contract is inaccurate.

**Required:** accept an empty body (best effort 200) or document 415 and keep the body mandatory.

## 9. No health endpoint (B-13)

**Finding:** `/health` and `/api/health` return 401 from the protected catch-all.

**Client assumption:** none; the client uses normal protected calls.

**What breaks if not fixed:** monitoring/load balancers cannot perform an unauthenticated liveness check; incident diagnosis is slower.

**Required:** add an unauthenticated minimal health endpoint and document it.

## 9a. Stale OpenAPI employee login contract (B-14)

**Finding:** `GET /openapi/v1.json` still lists `userType` (optional) on both `EmployeeLoginRequest` and `EmployeeLogin`, although the backend removed it. `EmployeeSaveRequest.login` resolves to `EmployeeLoginRequest`, so the published write contract is stale.

**Client decision:** the client never sends `login.userType` on create or update. It strips the field from a loaded login object before a full-replace PUT, tolerates it on responses, and never displays it.

**Required:** regenerate the OpenAPI document so `EmployeeLoginRequest` no longer advertises `userType`.

## 9b. User-permission assign returns the complete grant list (B-15)

**Finding:** `POST /api/user-permissions` returns the target user's complete grant list after the assign (for example 4 rows for the employee account and 18 rows for Admin), not only the newly added grants. The list can include orphan rows (`permissionKey:null`, `permissionName:null`, `permissionStatusId:2`).

**Client behavior:** the client treats the response as the full list and refreshes the grant list after the write. It does not append the response to an existing list. Orphan rows remain visible as revocable rows on the Access screen.

**Required:** keep the documented response as the full list and return the same shape for additive assign and replace.

## 10. Still required for full remote integration

These backend contracts are available but need decisions before/while wiring UI:

- **Branch create/update** requires `timeZoneId`; the Postman bodies omit it. The client will send an IANA zone.
- **Department activate** does not exist; the client treats re-activation as unsupported.
- **Company/branch scope** is not represented in grants or headers. If the deployment is multi-company, tenant scoping must be added.
- **Module entitlement** remains absent; the client derivation must be replaced when the backend supplies it.

## 11. Client-side integration status

- Auth + permission bootstrap: implemented.
- Navigation/route/action gating from backend permissions: implemented.
- Fail-closed + retry state: implemented.
- Access & Users administration in backend mode: implemented against `/api/permissions` and `/api/user-permissions` (users derived from grants; no history endpoint).
- Branches, employees, employee shifts and attendance now have live verticals. Employees use the canonical `/app/hr/employees` route; the legacy local employee destination is disabled in production composition. Remaining employee limitations (inactive-selector filtering, full 400 field mapping, full payroll form editing) are recorded in `docs/client-decisions.md`.



