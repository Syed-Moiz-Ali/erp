# Permission coverage matrix

Every registered permission must have a real consumer. This matrix maps each
permission to where it is enforced: **Nav** (navigation/discovery), **Route**
(direct URL guard), **Read** (query scope), **Action** (button/menu visibility),
**Mutation** (write authorization) and **Scope** (record scope resolver).

Navigation and route guards are centralized: HR destinations declare
`requiredPermissions` / `anyPermissions` / capabilities in
`modules/hr/module/hr_module_registration.dart` and are evaluated by
`NavigationResolver`. Configuration routes additionally require `*Manage` for
`/new` and `/edit`.

## HR

| Permission | Nav | Route | Read | Action | Mutation | Scope |
| --- | --- | --- | --- | --- | --- | --- |
| `hr.employees.view` | Employees destination | `/app/hr/employees*` | `LocalEmployeeRepository.watchEmployees` via `EmployeeScopeResolver` | — | — | `EmployeeScopeResolver` (self/team/all) |
| `hr.employees.create` | — | `/app/hr/employees/new` | — | Add Employee | `saveEmployee` | — |
| `hr.employees.edit` | — | `/app/hr/employees/:id/edit` | — | Edit | `saveEmployee(id)` | team/all via scope resolver |
| `hr.employees.deactivate` | — | — | — | Activate/Deactivate | `setActive` | — |
| `hr.attendance.self.view` | Attendance destination | `/app/hr/attendance` | `AttendanceBloc` self | self landing | — | linked employee |
| `hr.attendance.self.punch` | — | — | — | Punch In | `ExecuteAttendanceAction` | linked employee + policy/location |
| `hr.attendance.self.punchOut` | — | — | — | Punch Out | `ExecuteAttendanceAction` | linked employee + state |
| `hr.attendance.self.break` | — | — | — | Break/Resume | `ExecuteAttendanceAction` | linked employee + policy |
| `hr.attendance.self.correctionRequest` | — | `/app/hr/attendance/corrections/new/:dayId` | — | Request Correction | correction create | linked employee |
| `hr.attendance.records.view` | Attendance Team/All | `/app/hr/attendance/team|all` | `WorkforceAttendanceReadRepository` | — | — | `AttendanceScopeResolver` (team/all) |
| `hr.attendance.corrections.review` | Requests destination | `/app/hr/attendance/requests*` | correction queue | Approve/Reject | correction review | team/all |
| `hr.attendance.corrections.apply` | — | — | — | correct | `attendanceCorrect` | — |
| `hr.attendance.reports.view` | Reports destination | `/app/hr/reports` | `LocalAttendanceReportRepository` | Export | export | `AttendanceScopeResolver` |
| `hr.leave.self.view` | Leave destination | `/app/hr/leave`, `/my-requests` | `LocalLeaveRepository` self | — | — | linked employee |
| `hr.leave.self.request` | — | `/app/hr/leave/request` | — | New Request | leave request create | linked employee |
| `hr.leave.self.cancel` | — | — | — | Cancel | leave cancel | linked employee + state |
| `hr.leave.self.balanceView` | — | — | balance card | — | — | linked employee |
| `hr.leave.records.view` | Leave Team/All | `/app/hr/leave/team|all` | leave list | — | — | team/all |
| `hr.leave.requests.review` | Approvals | `/app/hr/leave/approvals` | review queue | Approve/Reject | review | team/all |
| `hr.leave.balances.view` | Balances | `/app/hr/leave/balances` | balance list | — | — | team/all |
| `hr.leave.balances.adjust` | — | — | — | Adjust Balance | ledger adjust | — |
| `hr.leave.settings.manage` | Settings | `/app/hr/settings` | — | — | — | — |
| `hr.leave.types.view` | Settings | `/app/hr/settings/leave-types` | list | — | — | — |
| `hr.leave.types.manage` | — | `.../new|edit` | — | Add/Edit/Deactivate | save | — |
| `hr.leave.policies.view` | Settings | `/app/hr/settings/leave-policies` | list | — | — | — |
| `hr.leave.policies.manage` | — | `.../new|edit` | — | Add/Edit/Deactivate | save | — |
| `hr.holidays.view` | Settings | `/app/hr/settings/holidays` | calendar | — | — | — |
| `hr.holidays.manage` | — | `.../new|edit|import` | — | Add/Edit/Copy/Import/Deactivate | save | — |
| `hr.reports.leave.view` | Reports | `/app/hr/reports` | leave report | Export | export | scope |
| `hr.attendance.shifts.view` | Settings | `/app/hr/settings/shifts` | list | — | — | — |
| `hr.attendance.shifts.manage` | — | `.../new|edit` | — | Add/Edit/Deactivate | save | — |
| `hr.attendance.locations.view` | Settings | `/app/hr/settings/work-locations` | list | — | — | — |
| `hr.attendance.locations.manage` | — | `.../new|edit` | — | Add/Edit/Deactivate | save | — |
| `hr.attendance.policies.view` | Settings | `/app/hr/settings/attendance-policies` | list | — | — | — |
| `hr.attendance.policies.manage` | — | `.../new|edit` | — | Add/Edit/Deactivate | save | — |

## Platform / access

| Permission | Nav | Route | Read | Action | Mutation |
| --- | --- | --- | --- | --- | --- |
| `company.access.users.view` | Settings → Users & access | `/app/settings/access*` | `AccessRepository.watchUsers` | Manage Access (read-only editor) | — |
| `company.access.permissions.manage` | Settings → Users & access | `/app/settings/access*` | grants | Save Changes | `replaceGrants` + `GrantAuthorityResolver` |
| `company.modules.view` | Settings → Company modules | `/app/settings/modules` | module enablement | — | — |
| `company.users.manage` | Settings | — | — | employee account provisioning | provisioning |
| `company.roles.manage` | Settings | — | — | role metadata | provisioning |
| `platform.companies.manage` | — | — | — | platform-only | platform-only |
| `platform.modules.manage` | — | — | — | platform-only | platform-only |

## Notes

- `*Manage` implies `*View` through `permissionViewDependencies` (single
  normalization point), so a manage-only grant never hides its screen.
- Scope is encoded in the granted `PermissionScope` and resolved by the module
  scope resolvers, so `TEAM` never behaves like `ALL`.
- Access management is itself permission-gated and self-escalation protected.

## Adding a module

A new module must provide permission definitions (catalog contribution), a
capability resolver, a scope resolver, navigation/route requirements and
use-case authorization. Registering only Access-UI checkboxes is not sufficient;
the matrix above is the acceptance test for every new permission.
