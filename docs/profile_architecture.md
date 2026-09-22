# Profile Architecture

The product has **two distinct profile surfaces**. They must not be merged.

| | My Profile | Employee Record |
|---|---|---|
| Route | `/app/profile` | `/app/employees/:employeeId` |
| Purpose | personal self-service | organizational HR/Admin record |
| Audience | the signed-in user | HR, Admin, Manager (scoped) |
| Data | UserAccount + linked Employee (read-only employment) | full Employee + assignments + account access + admin actions |
| Editing | account only (language, notification preferences, password) | HR/Admin controlled fields |

## UserAccount vs Employee

They are separate domain entities. `UserAccount` owns authentication,
permissions, role, company access, locale and notification preferences.
`Employee` owns employee code, name, department, designation, manager, joining
date, employment status, shift, work location and attendance policy.

The link is `AuthContext.employeeReference` → the employee for the **current
company**. A `UserAccount` may have **no** employee link (common for Super Admin
and Company Admin); this is a first-class, fully supported state.

## My Profile data model

`MyProfileCubit` aggregates `MyProfileCubit -> MyProfileViewModel`:

- `account` — the current `AuthContext` (always);
- `employee` — the linked `Employee` (only when linked);
- `references` — departments/designations/managers/shifts/locations/policies for
  readable labels, reusing the same repository lookup as Employee Details;
- `capabilities` — the shared `UserCapabilityContext`;
- `employeeUnavailable` — the link points to a missing record.

It is reactive: it listens to `AuthRepository.sessionChanges` and to
`EmployeeRepository.watchEmployee`, so HR edits to the employee appear in My
Profile without a manual refresh. When there is no link it issues **no** employee
/ shift / attendance queries.

## Section visibility

- **Account / Overview** — always.
- **Employment / Work information** — only when a linked employee resolves.
- **My Attendance** — only when `selfAttendanceHistory` capability holds.
- **Account & access / Access summary** — always (grouped, human-readable; raw
  permission enum names are never shown).
- **Security / Preferences** — always; attendance reminder preferences appear
  only for linked, self-capable users.

An unlinked admin never sees an employment section, employee code, shift,
location or attendance summary, and never a "No data" employment placeholder.

## Self-edit boundaries

My Profile does not edit HR-controlled fields (employee code, department,
designation, manager, shift, location, policy). Only account-level preferences
and the existing change-password flow are editable. Permissions/roles are never
self-editable.

## Employee Record remains organizational

`/app/employees/:employeeId` keeps its Overview / Employment / Attendance
Configuration / Account Access sections and admin actions. Opening one's own
record there is still an organizational view; My Profile is not redirected to it
and vice versa. A "View employment details" action is offered in My Profile only
to users who can manage employees.
