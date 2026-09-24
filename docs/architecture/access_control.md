# Access control

Authorization is **permission- and scope-driven**. A user's business access never
depends on a role name, department or designation.

## Identity model

```text
UserAccount (login/security identity)
   + Company membership
   + optional/expected Employee link (employment identity)
   + Permission grants (key + scope)
   + Organization/team/assignment relationships
   -> UserCapabilityContext
   -> Navigation + Routes + Actions + Record scope
```

- **Employee** is the single employment identity. There is no `TechnicianPerson`,
  `InspectorPerson` or `ServiceManagerPerson`; those are employees with grants.
- **UserAccount** is the login identity. A company employee may have no login;
  platform/super admin may have no employee link.
- **Designation / department / manager relationship** are employment facts. They
  never grant access automatically (they only define potential TEAM scope once a
  TEAM permission is granted).

## Permission catalog

Module-owned definitions are composed once in
`lib/app/access/erp_access_catalog.dart`:

```text
modules/hr/access/hr_permission_catalog.dart
modules/services/access/services_permission_catalog.dart   (empty until Phase 1)
platform/access/platform_permission_catalog.dart
```

A `PermissionDefinition` has a stable namespaced `key` (`hr.leave.records.view`),
module/submodule ids, localization keys, supported `PermissionScope`s and flags
(`requiresEmployeeLink`, `delegable`, `platformOnly`, `risk`). Each scope maps to
the existing runtime `AppPermission`, so scopes are additive metadata rather than
a second authorization system. Identity is the key, never a translated string.

## Scopes

`PermissionScope { none, self, assigned, team, all }`.

- `none` — action permissions (create/manage/configure).
- `self` — the user's linked employee records.
- `assigned` — records explicitly assigned (Services).
- `team` — module-resolved organizational/team records.
- `all` — company-wide records within the active company.

Scopes are module-resolved: HR TEAM comes from the reporting hierarchy; Services
TEAM will come from service-team membership. A scope is **not** a role.

## Grants

`UserPermissionGrants` (schema v10) stores one effective grant per
`(companyId, userId, permissionKey)` with a single scope. Grants are additive:
present means allowed, absent means not allowed. There are no deny rules, role
priorities or inheritance. `AccessRepository` watches users/grants/history and
replaces grants atomically (grants + access audit events + outbox mutation),
idempotent by `requestId`.

## Effective access formula

```text
EFFECTIVE ACCESS =
    Company Module Enabled
AND Permission Granted
AND Required Employee Context Valid
AND Requested Record Within Granted Scope
AND Company / Tenant Match
```

`PermissionSet` answers `contains`/`can`; the capability resolver combines
permissions with the linked-employee state. ALL visibility never implies a SELF
action: an unlinked user with `hr.leave.records.view`/ALL does **not** gain
"request my leave".

## Company modules vs user permissions

Module entitlement (does the company have HR/Services/Inventory/Finance?) is
separate from user access (what can this user do inside an enabled module). A
disabled module hides navigation and blocks routes/actions even if grants exist;
enabling it later restores applicable grants. An enabled module with zero user
grants stays hidden for that user.

## Delegation rules (foundation)

- Access administration requires explicit permissions
  (`company.access.users.view`, `company.access.permissions.manage`), never a
  role name.
- A company access manager can only grant company-delegable permissions inside
  their company and enabled modules; platform-only / non-delegable permissions
  are refused.
- Self-escalation is refused by default.
- The final company access administrator cannot be stripped of access-management
  capability.
- Grants that `requiresEmployeeLink` are refused for users without an active
  linked employee.

## Record-scope enforcement

Navigation visibility is not security. Repositories/use cases must enforce
company scope, permission and resolved scope, so a manually typed URL or entity id
cannot bypass access.

## Localization

Permission names/descriptions are localized through the module ARB sources
(HR → `modules/hr/l10n`, platform/access → `platform/l10n`); the Access UI never
shows raw keys.

## Future module integration

Adding Inventory later requires: register the module, register its permission
catalog contribution, add routes/navigation, implement its scope resolver, and
use `UserCapabilityContext`. The Access UI renders the new module automatically —
no Access-UI rewrite.

## Users & Access UI

Global Settings contains an **Access & modules** section:

- `/app/settings/access` — `UsersAccessPage` (search + All/Active filter chips,
  a summary line, identity cells with avatars, module pills; desktop table /
  mobile cards; Manage Access).
- `/app/settings/access/users/:userId` — `UserAccessDetailPage`: a user header
  card, access summary, and one **module card** per module. Each module card
  shows an icon, access status and a quick menu (Grant view / Grant full /
  Clear) so a whole module can be assigned in one tap; expanding shows
  submodule sections with self-action switches and scope choice chips.
  Includes access history and an edit-session Save with confirmation.
- `/app/settings/modules` — `CompanyModulesPage` (module availability,
  read-only in the local demo).

Routes are guarded by `company.access.users.view` / `company.access.permissions.manage`
and `company.modules.view`; they live under `/app/settings` (never under
`/app/hr/settings`) because access spans all modules. `UserAccessCubit` owns the
catalog, current/draft grants, dirty state and save; widgets never compute
effective grants. Permission labels/descriptions are localized in the module
ARBs.

## Runtime permission enforcement

Enforcement happens at three levels; hiding UI alone is never sufficient.

1. **Discovery** — navigation, menus and actions are generated from the
   permission/capability set (`NavigationResolver`, capability resolvers).
2. **Route/page** — `NavigationResolver.routeAccess` guards every canonical
   route, so a direct URL cannot bypass a grant. Entity routes additionally
   enforce record scope.
3. **Business operation** — repositories/use cases enforce company scope,
   permission and record scope.

**Hidden vs disabled.** No permission → the action is hidden entirely (never a
disabled "Add Employee 🔒"). Authorized but the business state blocks the
operation → the action is shown disabled or fails validation with an
explanation (permission ≠ business-state eligibility).

**Live refresh.** The session's effective `PermissionSet` is derived from
persisted grants by `UserGrantsController` (`LocalUserGrantsController`). The
`AuthBloc` applies grants on login/session restore and subscribes to the current
user's grant stream; when grants change (add/remove/scope change/expiry),
`AuthPermissionsRefreshed` re-emits the session context, which refreshes
navigation, routes and actions without a re-login. The router's refresh
listenable then re-evaluates the current route, redirecting to a safe landing if
it became unauthorized. The effective set is also written back into the stored
session (`SessionPermissionSink.applyEffectivePermissions`), so repositories that
read the session context (`checkSession`) enforce the updated scope on their next
query. Company switch re-subscribes to the new company's grants; logout/expiry
cancels the subscription. Expired grants (`expiresAt`) are excluded using
`AppClock`.

**Scope enforcement.** TEAM and ALL are distinct grants. A single
`AccessScopeResolver` owns the `all > team > assigned > self > none` precedence;
the module scope resolvers (employee/attendance/dashboard), the report access
check and the leave review check all delegate to it, so scope resolution is
identical everywhere and free of role logic. The session `PermissionSet` also
carries the granted scope per permission (`scopeFor`). List/detail/export
queries use the same scope, so counts cannot leak unauthorized data.

**Module integration.** A future module must register permission definitions, a
capability resolver, a scope resolver, navigation/route requirements and use-case
authorization. See [permission_coverage.md](permission_coverage.md) for the
per-permission matrix.

## Current status (Phase 0.5)

Implemented and tested: permission scope/definition/catalog + module
contributions + composition; explicit grants table (v10) + repository + atomic
replace + access audit events + outbox; `GrantAuthorityResolver` (delegation
ceiling, self-escalation, last-admin, employee-link, platform-only, module
enablement); demo grant seeding; Users & Access list, Access Detail editor and
Company Modules screens with routes, Settings navigation and EN/AR localization;
catalog completeness, role-independence, delegation, route-guard and UI
(desktop/mobile/Arabic) tests; and this documentation.

Phase 0.6 adds runtime wiring: grants drive the session's effective
`PermissionSet`, a reactive grant stream refreshes navigation/routes/actions
without re-login, expired grants are excluded, and the coverage matrix
documents every consumer.

Module enablement is read-only in the local demo (platform-level in a real
backend).
