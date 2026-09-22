# Session & Tenant State

How the app keeps one authenticated identity and one tenant authoritative, and
why previous users/companies can never leak into the next session.

## 1. Identity model

- **UserAccount** — authentication, role/permission grants, company membership.
- **EmployeeReference** — the business/person record linked to a UserAccount.
  An HR/Admin account may have **no** linked employee.

`AuthContext` is the single source of truth for the current session: `user`,
`company`, and an optional `employeeReference`. It is resolved by the
`AuthRepository` and streamed through `AuthBloc` (`sessionChanges`).

## 2. One session, re-resolved per login

On every login/bootstrap the repository rebuilds `AuthContext` from the session
storage and the account store. The linked employee is resolved **afresh**; the
previous session's `EmployeeReference` is never reused. `AuthContext` equality
includes the employee reference, so consumers keyed on it reset.

## 3. Session isolation (no previous-user data)

Session-scoped presentation state is recreated when the principal changes:

- the attendance session scope and its BLoC are keyed by the `AuthContext`
  (`ValueKey(auth)`), so a new user gets a new attendance bloc;
- the notification badge/bloc and sync status bind to the current
  company/user and re-subscribe on `sessionChanges`;
- list/detail/form `BlocProvider`s are keyed by route id, and the shell/region
  providers are keyed by the auth context.

Feature repositories re-check the session on every read/write and return typed
failures when the actor changes mid-operation (see the attendance repository's
`_historyRead`/`_session` guards). Logout clears the session in secure storage
and routes to login; any browser Back to a protected URL immediately re-runs
the guards.

## 4. Company (tenant) isolation

- Every repository query is scoped by the active `company.id` resolved from the
  repository/use-case, never from a widget-supplied id.
- Detail queries use `(companyId, id)` together; an id from another company is
  treated as Not Found / Unauthorized and never leaks existence.
- The outbox persists `companyId` per operation, and the sync processor only
  handles operations matching the current authorized company.
- Notifications are scoped by `(companyId, userId)`.

## 5. Company switching (future-ready)

If a company switch is added, the same session-generation rules apply: switching
company invalidates employee/attendance/report/notification/configuration
references and any route pointing at an entity from the previous company,
falling back to the new company's landing or module root. No old-company record
stays visible.

## 6. Logout

Logout clears the session and returns to `/login`. It never deletes the local
business database, but no previous-user self data (greeting, avatar, current
attendance, filters requiring identity) may render: those widgets are bound to
the current session generation and reset on `sessionChanges`.

## 7. Pending outbox isolation

Offline attendance operations remain in `sync_outbox` with their `companyId`.
They are only processed while the current session matches that company (and, for
self-attendance, that employee). Logout does not delete them, and a different
user/company can never sync another scope's operations.
