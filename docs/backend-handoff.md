# Backend hand-off â€” MassERP client integration

Audit date: 2026-10-28
Source of findings: `audit-output/massep-2026-10-28/01..07` (read-only audit).
This document records backend decisions/fixes required by the Flutter client. No backend code is in this repository.

## 1. Employee view permission is missing (B-01)

**Finding:** the live permission catalog has no active `hr.employees.view`. Admin holds create/edit/deactivate but every employee read returns `403 ACCESS_DENIED`. Permission master ids 1â€“3 are gone while user-permission rows still reference them (`permissionKey:null`).

**Client assumption:** a backend session receives `hr.employees.view` when an administrator grants it; `/api/me/permissions` is the authoritative source.

**What breaks if not fixed:** the employee list/detail/lookups screens cannot be used by any user until the seed is restored; the client shows the "no permissions" state. The Postman collection also fails its seeded-key assertion.

**Required:** restore the active key, repair grants, clean orphan rows, and make the permission seed idempotent.

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
- Employees, branches, employee shifts and attendance remote UI: not completed in this phase. See `docs/client-decisions.md` for the reasons and the contract decisions they depend on.


