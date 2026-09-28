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

## Services (Phase 1)

| Permission | Nav | Route | Read | Action | Mutation |
| --- | --- | --- | --- | --- | --- |
| `services.customers.view` | Services + Customers | `/app/services/customers*` | `LocalServiceCustomerRepository.watchCustomers/getCustomer` | — | — |
| `services.customers.create` | — | `/app/services/customers/new` | — | Add customer | `saveCustomer` |
| `services.customers.edit` | — | `.../:id/edit` | — | Edit | `saveCustomer(id)` |
| `services.customers.deactivate` | — | — | — | Activate/Deactivate | `setActive` |
| `services.sites.view` | Sites | `/app/services/sites*` | `LocalServiceSiteRepository.watchSites/getSite` | — | — |
| `services.sites.create` | — | `/app/services/sites/new` | — | Add site | `saveSite` |
| `services.sites.edit` | — | `.../:id/edit` | — | Edit | `saveSite(id)` |
| `services.sites.deactivate` | — | — | — | Activate/Deactivate | `setActive` |
| `services.teams.view` | Teams | `/app/services/teams*` | `LocalServiceTeamRepository.watchTeams/watchMembers` | — | — |
| `services.teams.manage` | — | `/new`, `/:id/edit` | — | Create/Edit/Deactivate/Membership | `saveTeam`/`setActive` |
| `services.serviceTypes.view` | Settings | `/app/services/settings/service-types*` | master list | — | — |
| `services.serviceTypes.manage` | — | `.../new|edit` | — | Add/Edit/Deactivate | `save`/`setActive` |
| `services.complaintTypes.view` | Settings | `.../complaint-types*` | master list | — | — |
| `services.complaintTypes.manage` | — | `.../new|edit` | — | Add/Edit/Deactivate | `save`/`setActive` |
| `services.priorities.view` | Settings | `.../priorities*` | master list | — | — |
| `services.priorities.manage` | — | `.../new|edit` | — | Add/Edit/Deactivate | `save`/`setActive` |
| `services.ticketTypes.view` | Settings | `.../ticket-types*` | master list | — | — |
| `services.ticketTypes.manage` | — | `.../new|edit` | — | Add/Edit/Deactivate | `save`/`setActive` |

The `services` feature flag must be enabled for the company. Team membership never
grants permission, and a Services permission never creates team membership.

## Services (Phase 2 — Service Enquiry)

| Permission | Scope | Nav | Route | Read | Action | Mutation |
| --- | --- | --- | --- | --- | --- | --- |
| `services.enquiries.view` | `all` | Services + Enquiries | `/app/services/enquiries`, `/:enquiryId` | `watchEnquiries`/`getEnquiry`/`watchEnquiry`, overview summary + recent, customer/site recent | — | — |
| `services.enquiries.create` | none | Enquiries (New) + Overview action | `/app/services/enquiries/new` | restricted Customer/Site reference lookup | New enquiry | `createEnquiry` |
| `services.enquiries.edit` | none | Enquiries (Edit) | `/:enquiryId/edit` | restricted Customer/Site reference lookup | Edit (OPEN only) | `updateEnquiry` |
| `services.enquiries.cancel` | none | Enquiries (Cancel) | — | — | Cancel (OPEN only) | `cancelEnquiry` |

Notes:

- `services.enquiries.edit`/`.cancel` imply `.view` through
  `permissionViewDependencies`. `.create` deliberately does **not** imply `.view`:
  a create-only operator gets the New Enquiry flow and restricted reference
  lookups (authorized by Enquiry Create), but not the company enquiry list.
- The Enquiries destination is visible with `view` **or** `create`
  (`anyPermissions`). A create-only user sees a create-oriented state instead of
  the list.
- Restricted Customer/Site reference lookups are authorized by Enquiry
  Create/Edit, never by `services.customers.view`/`services.sites.view`, so an
  Enquiry operator never gains directory access indirectly.
- Direct URLs are guarded in `NavigationResolver.routeAccess` (`/new` → create,
  `/edit` → edit, `/:id` → view); the repository re-checks every mutation.

## Services (Phase 3 — Job Assignment & Scheduling)

| Permission | Scope | Nav | Route | Read | Action | Mutation |
| --- | --- | --- | --- | --- | --- | --- |
| `services.jobAssignments.view` | `assigned`/`team`/`all` | Services + Job assignments | `/app/services/job-assignments`, `/:assignmentId` | `watchAssignments`/`getAssignment`/`watchUpcomingAssignments`/`summary`, enquiry detail integration | — | — |
| `services.jobAssignments.create` | none | Job assignments (New) + Enquiry action | `/app/services/job-assignments/new` | restricted Enquiry/Employee/Team reference lookup | New job assignment | `createAssignment` (+ Enquiry OPEN→ASSIGNED) |
| `services.jobAssignments.edit` | none | Job assignments (Edit) | `/:assignmentId/edit` | restricted Enquiry/Employee/Team reference lookup | Edit / reassign (ACTIVE only) | `updateAssignment` |
| `services.jobAssignments.cancel` | none | Job assignments (Cancel) | — | — | Cancel (ACTIVE only) | `cancelAssignment` (+ Enquiry ASSIGNED→OPEN when last) |

Notes:

- `create`/`edit`/`cancel` imply `serviceJobAssignmentViewAll` through
  `permissionViewDependencies` (coordinators who assign operate company-wide).
- Record scope is resolved by `ServiceJobAssignmentScopeResolver` via the shared
  `AccessScopeResolver` (`all > team > assigned`): ASSIGNED = the linked employee
  is directly on a line or belongs to an assigned Service Team; TEAM = the linked
  employee's Service Teams; ALL = company. TEAM never silently becomes ALL.
- Restricted Enquiry/Employee/Team reference lookups are authorized by Job
  Assignment Create/Edit, never by the full Enquiry/HR/Team directories.
- Direct URLs are guarded in `NavigationResolver.routeAccess` (`/new` → create,
  `/edit` → edit, `/:id` → any view scope); the repository re-checks every
  mutation and the record scope on every read.

## Services (Phase 4 — Inspection)

| Permission | Scope | Nav | Route | Read | Action | Mutation |
| --- | --- | --- | --- | --- | --- | --- |
| `services.inspections.view` | `assigned`/`team`/`all` | Services + Inspections | `/app/services/inspections`, `/:id` | `watchInspections`/`getInspection`/`summary`/`watchRecentInspections`, job-assignment integration | — | — |
| `services.inspections.create` | none | Inspections (New) + Assignment action | `/new` | restricted Assignment/Enquiry/Employee/Team reference lookup | New inspection | `createInspection` |
| `services.inspections.edit` | none | Inspections (Edit) | `/:id/edit` | restricted reference lookup | Edit (PENDING only) | `updateInspection` |
| `services.inspections.complete` | none | Inspections (Complete) | — | — | Complete (PENDING only) | `completeInspection` |
| `services.inspections.cancel` | none | Inspections (Cancel) | — | — | Cancel (PENDING only) | `cancelInspection` |
| `services.rootCauses.view` | none | Settings | `/app/services/settings/root-causes*` | master list | — | — |
| `services.rootCauses.manage` | none | — | `.../new\|edit` | — | Add/Edit/Deactivate | `save`/`setActive` |
| `services.chargeResponsibilities.view` | none | Settings | `/app/services/settings/charge-responsibilities*` | master list | — | — |
| `services.chargeResponsibilities.manage` | none | — | `.../new\|edit` | — | Add/Edit/Deactivate | `save`/`setActive` |

Notes:

- Create/Edit/Complete/Cancel imply `serviceInspectionViewAll` via
  `permissionViewDependencies`. Record scope via `ServiceInspectionScopeResolver`
  (ASSIGNED = technician or directly assigned on the source assignment or in an
  assigned Service Team; TEAM never ALL; ALL = company).
- Restricted Assignment/Employee/Team lookups are authorized by Inspection
  Create/Edit, never by broad Job Assignment/HR/Team directory access.
- Before-work photo access inherits the owning Inspection (no attachment-id bypass).
- `*Manage` implies `*View` (root causes / charge responsibility).

## Services (Phase 5 — Request for Material)

| Permission | Scope | Nav | Route | Read | Action | Mutation |
| --- | --- | --- | --- | --- | --- | --- |
| `services.materialRequests.view` | `assigned`/`team`/`all` | Services + Material Requests | `/app/services/material-requests`, `/:id` | `watchRequests`/`getRequest`/`summary`/`watchRecentRequests`, Inspection integration | — | — |
| `services.materialRequests.create` | none | Material Requests (New) + Overview/Inspection actions | `/app/services/material-requests/new` | restricted eligible-Inspection lookup + source context | New material request | `createRequest` (+ `WAITING→REQUESTED`) |
| `services.materialRequests.edit` | none | Material Requests (Edit) | `/:id/edit` | restricted source context | Edit / reconcile lines (OPEN only) | `updateRequest` |
| `services.materialRequests.cancel` | none | Material Requests (Cancel) | — | — | Cancel (OPEN only) | `cancelRequest` (+ `REQUESTED→WAITING`) |
| `services.materialRequests.print` | none | Material Requests (Print) | `/:id/print` | document read via view scope | Print | `MaterialRequestPrintService` |
| `services.materialRequestPurposes.view` | none | Settings | `/app/services/settings/material-request-purposes*` | purpose master list | — | — |
| `services.materialRequestPurposes.manage` | none | — | `.../new\|edit` | — | Add/Edit/Deactivate | `save`/`setActive` |

Notes:

- Create/Edit/Cancel/Print imply `serviceMaterialRequestViewAll` via
  `permissionViewDependencies`. Record scope via
  `ServiceMaterialRequestScopeResolver` (ASSIGNED = Inspection technician or
  directly assigned on the source assignment or in an assigned Service Team; TEAM
  never ALL; ALL = company).
- Restricted eligible-Inspection lookups are authorized by Material Request Create,
  never by broad Inspection access.
- Direct print invocation enforces View + Print + object scope.
- `*Manage` implies `*View` (purposes).

## Services (Phase 6 — Work Execution)

| Permission | Scope | Nav | Route | Read | Action | Mutation |
| --- | --- | --- | --- | --- | --- | --- |
| `services.workExecutions.view` | `assigned`/`team`/`all` | Services + Work Execution | `/app/services/work-executions`, `/:id` | `watchExecutions`/`getExecution`/`summary`/`watchRecentExecutions`, Inspection/Job Assignment/Enquiry integrations | — | — |
| `services.workExecutions.create` | none | Work Execution (New) + Overview/Inspection actions | `/app/services/work-executions/new` | restricted eligible-Inspection lookup + source context | New work execution | `createExecution` |
| `services.workExecutions.edit` | none | Work Execution (Edit) | `/:id/edit` | restricted source context | Edit references/work lines (open only) | `updateExecution` |
| `services.workExecutions.perform` | none | Work Execution (actions) | `/:id` | — | Start Work / End Work / add Material Used / add After Work Photos | `startWorkLine`/`endWorkLine`/`addMaterialUsed`/`removeMaterialUsed`/`addPhotoEntry`/`updatePhotoEntryDescription`/`removePhotoEntry` |
| `services.workExecutions.complete` | none | Work Execution (Complete) | — | — | Complete Work Execution (all lines finished) | `completeExecution` |
| `services.workExecutions.cancel` | none | Work Execution (Cancel) | — | — | Cancel (not after COMPLETED) | `cancelExecution` |

Notes:

- Create/Edit/Perform/Complete/Cancel imply `serviceWorkExecutionViewAll` via
  `permissionViewDependencies`. Record scope via
  `ServiceWorkExecutionScopeResolver` (ASSIGNED = directly on a work line, on the
  source Job Assignment line, the source Inspection technician, or in an assigned
  Service Team; TEAM never ALL; ALL = company).
- **Edit and Perform are separate**: structural edits require `edit`; Start/End,
  Material Used and After Work Photos require `perform`. Both are enforced in the
  UI and in use-case/repository authorization.
- Restricted eligible-Inspection lookups are authorized by Work Execution Create,
  never by broad Inspection access.
- After-work photo access inherits Work Execution authorization; before-work photo
  access inherits the owning Inspection (no attachment-id bypass).
- `perform` requires an active linked Employee for ASSIGNED/self scope.

## Services (Phase 7 — workflow integration)

Phase 7 introduces **no new permission**. Every Services permission above is
additionally consumed by the workflow read model and its shared components:

| Consumer | Permissions re-checked |
| --- | --- |
| `ServiceWorkflowRepository.watchChain` / `loadChain` | The owning view permission **and** scope resolver for each node: `serviceEnquiryView` (all); `serviceJobAssignmentView*`; `serviceInspectionView*`; `serviceMaterialRequestView*`; `serviceWorkExecutionView*`. |
| `ServiceWorkflowRepository.summary` | Same view permissions/scopes; a metric is only computed when the corresponding scope resolver is not `none`. |
| `ServiceWorkflowRepository.watchActivity` | Same per-node authorization; only events from viewable records are merged. |
| `ServiceWorkflowTimeline` / `ServiceWorkflowSection` | Resolves through the read model; a restricted node shows no reference number. |
| `ServiceWorkflowActionResolver` | Every action is gated by its own action permission (create/edit/complete/cancel/print/perform) in addition to the view scope. |
| Services Overview / My Work | Metrics and "My Work" are gated by the view permissions and resolved with ASSIGNED/TEAM/ALL scope. |

Enforcement rules:

- **Module disablement.** If the company's `services` module is disabled, every
  Services scope resolver returns `none`, the navigation disappears, dashboard
  cards/My Work are absent and deep links resolve to the safe forbidden fallback.
- **Live refresh.** A grant/revoke while signed in refreshes the sidebar,
  subnavigation, dashboard cards, buttons, routes and record access without a
  new login; the workflow section re-reads the current `AuthContext`.
- **No decorative permission.** Every Services permission maps to real
  navigation, a real route, a real read, a real action and a real mutation (see
  the per-phase tables above).

## Services (Phase 8 — dashboard contribution)

Services introduces **no new permission**. The `ServicesDashboardContributor`
(read-only projection) contributes to the one Universal ERP Dashboard and
consumes every Services view/scope/action permission directly:

| Consumer | Permissions re-checked |
| --- | --- |
| Universal dashboard (`/app/dashboard`) | Always reachable; Services content appears only when the Services module is enabled and the user holds at least one Services view/create permission. There is no `/app/services` dashboard destination — `/app/services` redirects to the first permitted Services feature (or the dashboard). |
| `ServicesDashboardContributor` visibility | `services.*.view`/`.create` (any) plus the Services module enabled. When false, no Services query runs at all. |
| `ServicesDashboardRepository` | A metric/section is computed only when `services.enquiries.view`, `services.jobAssignments.view`, `services.inspections.view`, `services.materialRequests.view` or `services.workExecutions.view` (with a non-`none` record scope) is granted. Restricted domains are not queried. |
| `ServicesDashboardRepository` recent activity | `business_activity_events` are restricted to entity ids inside each domain's scope clause; no all-company timeline is loaded then filtered. |
| Dashboard quick actions | `services.enquiries.create`, `services.jobAssignments.create`, `services.inspections.create`, `services.materialRequests.create`, `services.workExecutions.create` — hidden, never disabled. |
| Dashboard KPI links / attention / My Work actions | Only canonical routes the user is authorized to open; each route re-checks permission and scope. |

Enforcement rules:

- **Scope, not role.** The contribution derives its scope indicator and every
  query from the same `AccessScopeResolver`-backed Services scope resolvers used
  by the repositories; TEAM never becomes ALL, and Services Team is never mixed
  with HR department/team.
- **Live refresh.** A grant/revoke or company switch re-runs the projection
  through the current `AuthContext` without a re-login; the dashboard bloc is
  keyed by that context.
- **No duplicate persistence.** Needs Attention is a derived read model; no
  dashboard/KPI/attention table exists (schema v18).

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
