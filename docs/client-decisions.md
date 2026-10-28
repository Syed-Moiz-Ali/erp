# Client decisions â€” backend session permissions (Phase 1)

Date: 2026-10-28
Branch: `fix/backend-session-permissions`

These are the assumptions made while implementing Tasks Aâ€“C. Each one is deliberate and should be revisited when the backend contract changes.

## D-01 â€” Backend is the only permission source in backend mode

`AppConfig.authMode == AuthMode.backend` uses `GET /api/me/permissions`. `LocalUserGrantsController` is used only in demo mode. A backend session never falls back to Drift/demo grants.

Reason: the audit found two divergent grant stores; using local grants for a backend user could show actions the backend will deny.

## D-02 â€” Scope = ALL for key-only backend grants

The backend has no scope field. For scoped client permissions (currently employee view), a granted key is treated as the broadest scope (`ALL`). Self-service keys such as `hr.attendance.self.view` remain SELF because the key itself is self-scoped.

This is implemented once in `lib/core/security/backend_access_policy.dart`. It does not invent scope data; it records the only truthful interpretation of a key-only grant.

## D-03 â€” Module entitlement is derived from permission keys

The backend has no module endpoint. `BackendAccessPolicy.enabledModulesFor` derives:
- `employees` from employee/login-management permissions;
- `attendance` from self-attendance permissions;
- `settings` from shift, department, branch and access permissions.

Dashboard and account are always available. This derivation is the single place to replace when the backend supplies `enabledModules`.

## D-04 â€” Fail closed on permission-load failure

If `/api/me/permissions` fails, the session keeps authentication but has an empty permission/module set and a retryable `permissionsFailure`. The shell shows "Could not load permissions" with retry. No stale/local grants are used.

## D-05 â€” Re-fetch triggers

Permissions are re-fetched:
- after login;
- after token refresh (through the repository session update);
- on app resume (`AppLifecycleCoordinator.refreshPermissions`);
- after any `403 ACCESS_DENIED` (`AccessEndpoint` -> `AuthAccessDenied`).

There is no polling timer. The permission loader itself sets `skipPermissionRefresh` to avoid a reload loop.

## D-06 â€” Client-only permissions are hidden in backend mode

The backend exposes 15 keys. The client catalog is larger (leave, locations, policies, attendance corrections, services). `PermissionCatalog.backendDefinitions` exposes only keys the backend can grant and non-`clientOnly` definitions.

`hr.attendance.self.punch` is one backend key; the client expands it to punch-in, punch-out and break runtime permissions so existing action gates keep working. Separate punch-out/break catalog entries are marked `clientOnly` and hidden in backend mode.

## D-07 â€” Permission keys aligned to the backend

- Departments use `hr.departments.view|manage` (not `hr.attendance.departments.*`).
- Branches use `company.branches.view|manage` and map to new `companyBranchView|companyBranchManage` runtime permissions.
- Employee login management uses `company.users.manage`.
- Access uses `company.access.users.view|permissions.manage`.

A unit test fails if any runtime permission is missing from the catalog or if a backend key is not catalogued.

## D-08 â€” Login identifiers are case-insensitive

The live backend authenticates `admin` as `Admin`. The client does not rely on case; it sends the entered value verbatim and treats the returned `loginId` as authoritative.

## D-09 â€” 401 vs 403

- `401` session-ending codes invalidate the session (existing behavior).
- `403 ACCESS_DENIED` keeps the session, shows the normal "no permission" failure, and triggers a permission reload.
- A `403` from `/api/me/permissions` does not trigger a reload loop.

## D-10 â€” Employee PUT must be a complete object

The backend `PUT` clears omitted fields. The intended remote employee adapter must load the full detail, apply edits, and send the complete payload. The existing Postman update body is not a safe template.

## D-11 â€” Employee activate/login

Activate does not restore the linked login. The client must re-read the employee after activate and display the real `login.enabled/canLogin`; it must not assume login is active.

## D-12 â€” Branch create/update requires an IANA time zone

The client must send `timeZoneId` from the branch lookups. It must not use Windows zone names or offsets.

## D-13 â€” Remote module status in this phase

Implemented and covered by tests:
- Auth login/refresh/logout (existing) + backend effective permissions (new).
- Permission-driven navigation/route/action gating through the existing `PermissionSet`.
- Retryable permission failure and empty-permission states.
- Catalog key alignment, client-only filtering, branch keys.
- Access & Users administration in backend mode: `/api/permissions` + `/api/user-permissions` replace the local repository. Users are derived from grant rows (the contract has no standalone user directory), and history is empty (no backend endpoint).

Not completed in this phase:
- Remote Employee CRUD UI, Branches, and Employee Shifts/Attendance screens.
- Reason: these require domain/UI changes that are materially larger than the permission-bootstrap fix (employee name/ID/FK/salary/password model, missing branch screen, missing assignment screen, local attendance state machine). Wiring incompatible local models would regress demo and risk data loss. They must be implemented as separate verticals; `docs/backend-handoff.md` records the contract decisions they depend on.

## D-14 â€” No secrets or hardcoded environment values

Base URL comes from `AppConfig`/environment files. No token, password, ngrok URL, or credential is hardcoded in the client changes. The live smoke test (if any) uses environment values only and is read-only.

