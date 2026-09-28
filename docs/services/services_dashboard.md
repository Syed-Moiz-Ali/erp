# Services dashboard contribution (universal ERP Dashboard)

> **Ownership update.** Services no longer owns a separate Services
> Dashboard/Overview page and there is no `/app/services` dashboard route.
> Services contributes its operational read model to the one Universal ERP
> Dashboard via
> `lib/modules/services/overview/application/services_dashboard_contributor.dart`
> (`ServicesDashboardContributor`). The universal page is owned by
> `lib/platform/workspace/dashboard/`
> (see [../architecture/universal_dashboard.md](../architecture/universal_dashboard.md)).
> `/app/services` now redirects to the first permitted Services feature
> (Enquiries by default).

The contribution is a **read-only projection** over the existing Services
workflow (Enquiry → Job Assignment → Inspection → Material Request → Work
Execution). It introduces no new business workflow, no schema and no persisted
counter tables.

- Read model: `lib/modules/services/overview/domain/services_dashboard.dart`
  (`ServicesDashboardSnapshot` + supporting section models).
- Repository contract: `ServicesDashboardRepository` (`load` for the dashboard
  contribution, `watch` for the legacy live cubit).
- Local projection:
  `lib/modules/services/overview/data/local_services_dashboard_repository.dart`.
- Contributor:
  `lib/modules/services/overview/application/services_dashboard_contributor.dart`.
- Localization: `.../presentation/service_dashboard_localization.dart` +
  `lib/modules/services/l10n/services_{en,ar}.arb`.

There is deliberately no `DashboardMetrics` / `KpiCounts` / `AttentionQueue`
table (schema stays **v18**). Needs Attention is derived on every read.

## Purpose

Help each signed-in user understand, from real data only:

- what needs attention now,
- what is scheduled today,
- what is assigned to them,
- what is pending / in progress / completed recently.

The page adapts to the effective scope (Assigned / Team / All company) purely
from permission grants, scope resolvers and the linked Employee — never from
hardcoded roles.

## Data sources

| Area | Source |
| --- | --- |
| KPI counts | `service_enquiries`, `service_job_assignments`, `service_inspections`, `service_material_requests`, `service_work_executions` (aggregate `COUNT`, scope-filtered) |
| Needs Attention | the same transaction tables, joined to `service_job_assignment_lines`, `service_inspection_material_requirements`, `service_priorities` |
| Today's schedule | `service_job_assignments.scheduled_visit_date` + `service_inspections.visit_date` / `visit_minutes` |
| My Work | `job_assignment_lines` / `inspections.technician_employee_id` / `work_execution_lines` for the linked employee |
| Team workload | `service_teams` + `service_team_members` + assignment lines + work-execution lines |
| Workflow overview | the KPI counts |
| Recent activity | `business_activity_events` (module `services`), restricted to viewable entity ids |
| Priority | `service_priorities.name` / `rank` (actual configured data — no SLA timers) |
| Today / completed-today | `CompanyTimeService` + `AppClock` (company timezone; never the device timezone) |

The projection is built from a **fixed** number of batched, scope-filtered SQL
statements. It never runs one Customer/Site/Employee query per row (no N+1) and
only ever reads the company-local `today` once.

## Exact metric definitions

Every metric resolves to a domain the user may view. When the view permission
(or record scope) is absent the metric is **not queried** and its card is not
rendered.

| Metric | Source entity | Condition | Scope / permission |
| --- | --- | --- | --- |
| Open Enquiries | `service_enquiries` | `status = 'open'` | company; `services.enquiries.view` |
| Scheduled Jobs | `service_job_assignments` | `status = 'active'` (all active assignments carry a visit date) | Job Assignment scope (ASSIGNED/TEAM/ALL) |
| Pending Inspections | `service_inspections` | `status = 'pending'` | Inspection scope |
| Open Material Requests | `service_material_requests` | `status = 'open'` | Material Request scope |
| Work In Progress | `service_work_executions` | `status = 'inProgress'` | Work Execution scope |
| Completed Today | `service_work_executions` | `status = 'completed'` AND `execution_date = company-local today` | Work Execution scope |

KPI cards are clickable only to a canonical route the user is authorized to
open: `/app/services/enquiries?status=open`,
`/app/services/job-assignments`, `/app/services/inspections?status=pending`,
`/app/services/material-requests?status=open`,
`/app/services/work-executions?status=in_progress`. `Completed Today` is
informational. The destination itself re-checks permission/scope.

## Needs Attention rules

Derived from the real workflow, capped at 6 rows. Each row carries the
transaction type, number, customer/site, reason, relevant date/time and the
actual configured Priority (Urgent/High/Normal chips; no SLA timers).

| Rule | Query |
| --- | --- |
| Open enquiry with no active Job Assignment | `service_enquiries` where `status='open'` and no `active` `service_job_assignments` for it |
| Visit today without an Inspection | active assignments with `scheduled_visit_date = today` and no non-cancelled Inspection |
| Inspection scheduled today | `service_inspections` with `status='pending'` and `visit_date = today` |
| Inspection with waiting materials | non-cancelled inspections with a `service_inspection_material_requirements` row `status='waiting'` and `removed_at IS NULL` |
| Open Material Request | `service_material_requests` where `status='open'` (optional branch — never implied as mandatory) |
| Active work line | `service_work_executions` where `status='inProgress'` |

Quick actions on a row navigate to the canonical detail route. A row is only
created from a domain the user may view, so no restricted record can leak.

## Today's schedule

Sources are `JobAssignment.scheduledVisitDate` (date only) and
`Inspection.visitDate` + `visitMinutes` (date + time). The list is sorted by
time (timed inspections first, then date-only assignments) and shows the
time/customer/site/enquiry reference, assigned employee/team, workflow stage and
status. It is built entirely on the company-local today. Empty state:
*"No visits scheduled today."* No full calendar component is built.

## My Work

Shown when the user has a linked Employee (or an operational scope). It lists
real records assigned to the employee: active Job Assignments, pending
Inspections (technician or assigned on the source assignment), and in-progress
Work Executions. The primary next action is permission-driven:
`Start work` / `Continue work` (Work Execution Perform), `Open inspection`
(Inspection view), `View assignment` (Job Assignment view). Empty state:
*"Nothing currently assigned."*

## Team Workload

Only for TEAM or ALL scope with Job Assignment visibility, using the actual
`ServiceTeam` relationships (never an HR Department). For TEAM scope the teams
are limited to the linked employee's active teams. Each row shows compact real
counts — active assignments, today's visits, work in progress — plus two bars.
No fake capacity percentage is produced. Empty state:
*"No active team workload."*

## Workflow overview

A compact stage distribution from the real counts:
Enquiry → Job Assignment → Inspection → Material Request → Work Execution.
Material Request is flagged **Optional** and is never drawn as a mandatory
funnel step. Only stages the user can view are listed. Counts are also rendered
textually, so the bars are not colour/length-only.

## Recent activity

Structured `BusinessActivityEvents` from the `services` module, restricted to
entity ids the user may view (the scope clause is applied per entity type inside
SQL). Event keys are localized at render time — no English sentence is stored.
Empty state: *"No recent service activity."*

## Quick actions

Context-aware and capability-only: New enquiry
(`services.enquiries.create`), Create job assignment, New inspection, New
material request, New work execution (each gated by its own create permission).
Actions the user cannot perform are hidden, never disabled.

## Empty / loading / error states

- **Global empty** — no operational records: an intentional empty state
  ("No service activity yet" with a New enquiry CTA when create is allowed; an
  assigned-only user sees "No work assigned to you right now.").
- **Per-section empty** — compact inline messages (Needs Attention shows
  "You're all caught up.").
- **Loading** — a dashboard-shaped skeleton (`AppDashboardSkeleton`) matching
  the final geometry, not a lone spinner.
- **Error** — an error card with Retry inside the normal page shell; the
  sidebar/navigation is not removed.
- **Partial failure** — each optional section is loaded independently, so one
  failing projection cannot blank the whole dashboard.

## Permission / scope behavior

- A domain whose view permission/scope is absent is neither queried nor shown
  (no KPI, no section, no count). The repository queries only the allowed scope;
  it never loads all-company data and hides it in widgets.
- ASSIGNED sees only records where the linked employee is directly assigned or
  belongs to an assigned Service Team. TEAM sees the linked employee's Service
  Teams and never silently becomes ALL. ALL is company-scoped.
- The header shows a subtle informational scope indicator ("Viewing: Assigned
  work / Team scope / All company services / No service scope"); it is not a
  selector.
- Live grant/revoke and a company switch recompute the whole dashboard without a
  re-login (`AuthBloc` context change → `ServiceDashboardCubit.updateContext`).

## Responsive behavior

Everything stays inside the one global centered `AppPage` width.

- **Desktop / large** — KPI row, quick actions, then a 2-column layout: left
  Needs Attention + Today's schedule; right My Work + Team workload; then
  full-width Workflow overview and Recent activity.
- **Tablet** — the 2 columns become balanced and stack responsively.
- **Mobile (compact)** — the 2-column shell stacks to a single column ordered
  Attention → My Work → Today's schedule → KPIs → Team workload → Workflow →
  Quick actions → Recent activity, with large touch targets and no compressed
  desktop tables.

All layouts are built with logical (`EdgeInsetsDirectional`/`AlignmentDirectional`)
tokens, so Arabic mirrors correctly. Status is never colour-only (badges always
carry text/icon); icon-only rows carry semantics labels; sections expose textual
equivalents of their bars.

## Out of scope

No Revenue / SLA / Inventory / Job Order / Quotation / Billing metrics, no
Service Reports, no technician efficiency / first-time-fix / CSAT / response-time
/ capacity percentages. Material Received remains Enquiry context only and never
drives dashboard workflow logic.
