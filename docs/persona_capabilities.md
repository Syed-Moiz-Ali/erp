# Persona Capabilities

Roles are **permission bundles and presentation hints only**. Access is decided
by permissions + linked employee + module enablement + company scope, derived
once through `UserCapabilityResolver` (`lib/features/auth/domain/policies/user_capability.dart`).

## Capabilities

| Capability | Requires |
|---|---|
| `selfAttendance` | linked employee **and** `attendanceViewSelf` |
| `selfAttendanceHistory` | linked employee **and** `attendanceViewSelf` |
| `requestAttendanceCorrection` | linked employee **and** `attendanceRequestCorrection` |
| `teamAttendance` | linked employee **and** `attendanceViewTeam` (team scope is the actor's employee identity) |
| `companyAttendance` | `attendanceViewAll` (no employee link required) |
| `approveAttendanceCorrections` | `attendanceApprove` **and** (`attendanceViewTeam` **or** `attendanceViewAll`) |
| `manageEmployees` | any of `employeeViewTeam`, `employeeViewAll`, `employeeCreate`, `employeeUpdate` |
| `manageAttendanceConfiguration` | any of `shiftView`, `workLocationView`, `attendancePolicyView` |
| `viewAttendanceReports` | `attendanceReportView` **and** (`attendanceViewTeam` **or** `attendanceViewAll`) |
| `manageUsers` / `manageRoles` / `manageCompany` | `userManage` / `roleManage` / `companyManage` |
| `platformAdministration` | `companyManage` + `userManage` + `roleManage` |

Key rule: **admin authority does not imply employee self-service.** Super Admin
and Company Admin role templates deliberately exclude the self-attendance
permissions, and even a permission alone is not enough — self capabilities also
require a linked employee.

## Navigation matrix (typical, capability-driven)

| Persona | Typical destinations |
|---|---|
| Super Admin (unlinked) | Dashboard, Employees, Reports, Configuration, Profile |
| Company Admin (unlinked) | Dashboard, Employees, All Attendance, Requests, Reports, Configuration, Profile |
| HR (unlinked) | Dashboard, Employees, All Attendance, Requests, Reports, Configuration, Profile |
| HR / Manager (linked) | + My Attendance, History, My Correction Requests, Team Attendance |
| Employee | Dashboard, My Attendance, History, My Correction Requests, Profile |

The matrix is illustrative: actual visibility is computed from capabilities, so a
linked Company Admin with explicit self permissions also sees My Attendance, and
an unlinked HR never sees self destinations.

## Navigation & guards share one resolver

`ErpModule.requiredCapabilities` is enforced by `NavigationResolver.access`, and
`NavigationResolver.routeAccess` computes the same capability context from the
`AuthContext`. The sidebar, rail, bottom nav, More page, dashboards and direct
URLs therefore agree: a hidden destination is also a guarded route.

- `/app/attendance` (self) requires `selfAttendance`.
- `/app/attendance/history` requires `selfAttendanceHistory`.
- `/app/attendance/corrections` requires `requestAttendanceCorrection`.
- `/app/attendance/team` requires `teamAttendance`.
- `/app/attendance/all` requires `companyAttendance`.
- `/app/reports` requires `viewAttendanceReports`.

## Reactivity

Capabilities are derived from the live `AuthContext` / permissions, so permission
or employee-link changes propagate through the existing `sessionChanges` stream
to navigation, dashboards, profile and reminders without an app restart. No
capability is cached across a session boundary.
