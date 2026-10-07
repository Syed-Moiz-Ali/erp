# UI-3 — Universal Dashboard Visual & UX Redesign

This document describes the UI-3 redesign of the single **Universal Dashboard**
(`lib/platform/workspace/dashboard/presentation/universal_dashboard_page.dart`).

There is exactly **one** dashboard. HR and Services are never presented as two
stacked dashboards: the dashboard composes their already-permission- and
scope-filtered contributions by *user purpose* (My Day, Needs Attention,
Overview, Today's Schedule, My Work, Recent Activity). Module contributors
(`HrDashboardContributor`, `ServicesDashboardContributor`) still own all domain
reads and translation; the platform dashboard owns composition, prioritisation
and layout only.

---

## 1. Visual hierarchy and section priority

Default desktop order (adapts to available capability/content):

| # | Section | Surface | Purpose |
|---|---------|---------|---------|
| 1 | Page header (`AppPageHeader`) | plain | "Dashboard" + "Your work and company activity at a glance" + refresh |
| 2 | Context row | plain chips | Company-local business date + effective scope labels |
| 3 | My Day | surface panel(s) | Personal attendance/leave context + immediate next service work |
| 4 | Needs Attention | bordered panel | One cross-module actionable feed |
| 5 | KPI summary | plain grid | 4–6 compact operational metrics |
| 6 | Today's Schedule + My Work | two columns | Personal timeline + records assigned to me |
| 7 | Team / Company context | panels | Team workload + optional workflow stage strip |
| 8 | Recent Activity | panel | One chronological cross-module event feed |
| 9 | Quick Actions | plain | 3–6 capability-driven actions |

Two-column blocks **reflow**: if one side has no content it is dropped and the
other uses the full width — a blank column is never left behind. Card heights are
intrinsic; unrelated sections are never stretched to match.

The page always uses `AppPage`'s global 1200 px max width, centered in the main
workspace, on the UI-1 page background. No dashboard-specific width or
background exists.

---

## 2. My Day

Composed as a responsive grid (max 2 columns) of module-owned widgets plus one
dashboard-owned highlight:

- **HR** contributes `AttendanceDashboardPreview` (personal attendance state) and
  `LeaveTodayBanner` (leave/holiday context) — only with the respective
  `attendanceViewSelf` / `leaveViewSelf` grants and an employee link.
- **Dashboard highlight** (`_HighlightWork`) surfaces the single most immediate
  assigned task from the merged `myWork` projection (contributors rank active
  work executions first). This is the "next service work" panel.

If only one side is available it uses the full width. If nothing is available
the section is omitted (never an empty shell).

### Attendance widget

Compact: current state badge, shift/location context line, permitted action only
(Open attendance). No giant clock. Actions are gated by the module's own
permissions; the widget still relies on the attendance use cases for
authorization.

### Leave context

`LeaveTodayBanner` renders only when `leaveViewSelf` + employee link exist; it
shows approved leave or a company holiday using real data (`LeaveRepository`).

### Holiday

A company holiday today is shown through the same leave/holiday overlay banner
(`workdayHoliday`), with the real holiday name.

---

## 3. Services personal work

Surfaced through **My Work** and the **My Day** highlight:

- Active Work Execution first (reference, customer · unit, work, started time,
  `Continue work`).
- Next visit / assignment (`Open assignment`).
- Pending inspection (`Open inspection`).

`ServicesDashboardContributor` ranks work by presentation priority
(`execution` = 100/80, `inspection` = 60, `assignment` = 40) so the immediate
task surfaces first. This is presentation-only ranking; the underlying ordering
and permission/scope filtering come from `LocalServicesDashboardRepository`.

---

## 4. Needs Attention

One cross-module compact feed built from the existing Phase 7 attention
derivation. Rows show a semantic icon, short category, title, secondary context,
company-local date/time, a **real** priority chip (never a fabricated SLA) and a
single primary action. Items are sorted by existing logic: contributor priority
(desc) → business date (asc) → id. The list is capped (`maxAttention = 8`).

`View all` is shown only when an authorized destination route exists.

### Attention rules (every reason)

| Module | Type | Condition (existing derivation) | Priority | Tone | Destination |
|--------|------|--------------------------------|----------|------|-------------|
| HR | `lateArrivals` | Attendance exception: late arrivals today | 40 | warning | `/app/hr/attendance` |
| HR | `pendingCorrections` | Attendance correction reviews pending | 60 | warning | `/app/hr/attendance/requests` |
| Services | `openEnquiryUnassigned` | Open enquiry with no active job assignment | 55 | warning | Enquiry detail |
| Services | `visitTodayWithoutInspection` | Assignment scheduled today without inspection | 35 | warning | Assignment detail |
| Services | `pendingInspectionToday` | Inspection scheduled for today | 25 | info | Inspection detail |
| Services | `inspectionWaitingMaterials` | Inspection has WAITING material requirements | 45 | warning | Inspection detail |
| Services | `openMaterialRequest` | Open material request | 50 | info | Material request detail |
| Services | `activeWorkLine` | Active work execution with an unfinished work line | 30 | brand | Work execution detail |

The rule logic lives in the contributors/repositories, **not** in widget `if`
statements.

---

## 5. KPI selection rules

- Compact neutral cards; the semantic accent is used only for the icon/status.
- 4–6 cards are typical, driven by `rank` (lower wins) and capped at
  `maxKpis = 6` in the merged snapshot.
- Counts are already scope-aware in the contributor/read layer — an all-company
  metric is never computed and hidden by the UI.
- SELF/ASSIGNED users get fewer or no company KPIs (the read projection returns
  no company counts for them).
- A KPI is clickable only when it opens a real filtered/relevant list; static
  KPIs have no hover treatment.

### Metric definitions

| Metric | Source module | Definition | Required permission | Scope behaviour | Business-date rule | Destination |
|--------|---------------|------------|---------------------|-----------------|--------------------|-------------|
| Present today | HR | Employees on time + late today | Attendance view (self/team/all) | Highest granted attendance scope | Company-local day via `CompanyTimeService` | — |
| On leave today | HR | Employees with approved leave today | Attendance/leave view | Highest granted scope | Company-local day | — |
| Pending leave approvals | HR (leave) | Leave requests awaiting approval | `leaveApproveTeam`/`leaveApproveAll` | Team or all | Request window | — |
| Attendance exceptions | HR | Pending attendance corrections | `attendanceApprove`/`attendanceCorrect` | Team or all | Company-local day | `/app/hr/attendance/requests` |
| Team size / Employees | HR | Headcount in scope | `employeeViewTeam`/`employeeViewAll` | Team or all | as-of | — |
| Attendance rate | HR | Present ÷ expected (0–1 ratio) | Attendance view | Highest granted scope | Company-local day | — |
| Work locations / Users | HR/platform | Configured locations / user accounts | `location*` / `access` | Company | as-of | `/app/hr/work-locations`, `/app/access` |
| Open enquiries | Services | Enquiries not yet closed | `serviceEnquiryView*` | Assigned/Team/All from projection | as-of | `/app/services/enquiries?status=open` |
| Scheduled jobs | Services | Active assignments with visits | `serviceJobAssignmentView*` | Assigned/Team/All | Company-local day | `/app/services/assignments` |
| Pending inspections | Services | Inspections awaiting completion | `serviceInspectionView*` | Assigned/Team/All | Company-local day | `/app/services/inspections?status=pending` |
| Open material requests | Services | Material requests still open | `serviceMaterialRequestView*` | Assigned/Team/All | as-of | `/app/services/material-requests?status=open` |
| Work in progress | Services | Active work executions on site | `serviceWorkExecutionView*` | Assigned/Team/All | as-of | `/app/services/work-executions?status=in_progress` |
| Completed today | Services | Work executions completed today | `serviceWorkExecutionView*` | Assigned/Team/All | Company-local day | — |

Where a canonical filtered URL does not exist, opening the unfiltered list is
acceptable (no routing architecture changes were introduced).

---

## 6. Today's Schedule

A compact vertical timeline (`AppDashboardTimeline`) built from:

- HR personal shift start (HR personal scope only).
- Services assignment visit date and inspection visit time.

Times use company-local time (`AppClock` + `CompanyTimeService`). The empty state
is a compact one-liner, never a large illustration. Other employees' shifts are
not included merely because broad HR access exists.

---

## 7. My Work

Records/tasks assigned to the current user (`DashboardWorkItem`): Services
assignments, inspections and work executions; HR personal attendance/leave only
when it genuinely behaves as assigned/personal work (it does not today, so HR
does not appear here). Each row shows the transaction number, customer/site,
short description, state and one primary action.

---

## 8. Team / Company context

- **Team** rows come from the contributor's own scope logic. Services Team ≠ HR
  Department; no fake capacity percentage is computed.
- **Company** context is simply a richer composition for ALL-scoped users — still
  one Universal Dashboard.
- **Workflow overview** is a subtle horizontal stage strip
  (`AppDashboardStageStrip`) over the existing Services workflow distribution
  (Enquiries → Assignments → Inspections → Execution). Material Requests are
  documented as an optional branch and are never implied as mandatory.

---

## 9. Charts

No chart is rendered in the initial dashboard composition. The existing
contributors expose no time-series data with a real business definition for the
dashboard, and §52/§53 forbid decorative charts (no SLA/revenue/productivity).
The workflow stage strip is a distribution strip, not a chart. If a real 7-day
operational series becomes available, at most one chart would be added using
`AppLineChart` with DS colors, a muted grid and a textual equivalent.

---

## 10. Recent Activity

One chronological cross-module feed of authorized structured events. Each row
shows a semantic/module icon, a subtle module label, the localized description,
the record number/name and a relative time. The feed is never split into
per-module sections. Events for records the user cannot access are never
produced (the read layer filters before the contributor sees them).

---

## 11. Quick Actions

3–6 capability-driven, user-relevant actions (for example: request leave, new
enquiry, create assignment, open inspections). Settings/configuration shortcuts
never dominate the dashboard.

---

## 12. Responsive ordering

| Breakpoint | Behaviour |
|------------|-----------|
| Mobile (< 600) | My Day → Needs Attention → My Work → Today's Schedule → relevant KPIs → Recent Activity → optional overview → Quick Actions. KPI grid becomes a compact 2-column grid (no horizontal swipe of six). |
| Tablet (600–999) | Sections stack/reflow; KPI grid 2-column. |
| Desktop (≥ 1000) | Two-column blocks (Schedule + My Work) reflow when a side is empty; KPI grid up to 6 columns; content centered at 1200 px. |

---

## 13. Permission, scope, employee-link and module behaviour

- **Permissions**: visibility is decided by each contributor's `isVisible` and
  by the read projections. Live grant changes rebuild the dashboard (the bloc is
  keyed by `AuthContext` + locale, so a changed permission set recomputes KPIs,
  sections, actions and lists without relogin).
- **Scope**: ASSIGNED → TEAM → ALL changes are reflected because contributors
  re-read scope-filtered projections on each load.
- **Employee link**: losing the employee reference removes personal attendance /
  leave / assigned work sections (contributors require `employeeId`).
- **Module enablement**: disabling a module makes its contributor `isVisible ==
  false`, so its sections disappear cleanly with no placeholder.
- **Company switch**: the dashboard bloc is recreated per auth context and shows
  the loading skeleton, so previous-company data is never briefly shown.

---

## 14. Empty / loading / error behaviour

- **Loading**: a geometry-aware `AppDashboardSkeleton` resembling My Day, the KPI
  grid, two-column sections and activity — never a single spinner.
- **Partial/error**: a failed contributor degrades only its own sections. The
  dashboard shows a warning banner with `Retry`; a failure never masquerades as a
  valid `0`. `failedModuleIds` records which modules failed.
- **Empty (valid access, no work)**: "You're all caught up" with any personal
  context still shown.
- **First-time company**: if the only data is all-zero KPIs and there are no
  personal/list sections, a neutral first-time empty state is shown instead of
  six zero cards, with a CTA only when the user can create something.

---

## 15. Design-system components

New/refined neutral presentation components live in
`lib/design_system/components/dashboard/app_dashboard.dart`:

`AppDashboardMetricCard`, `AppDashboardAttentionRow`, `AppDashboardTimeline` /
`AppDashboardTimelineEntry`, `AppDashboardWorkRow`, `AppDashboardActivityRow`,
`AppDashboardEmptySection`, `AppDashboardStageStrip`, `AppDashboardSkeleton`.

Presentation models (`DashboardKpi`, `DashboardAttentionItem`,
`DashboardScheduleItem`, `DashboardWorkItem`, `DashboardActivityItem`) gained
presentation-only fields (`categoryLabel`, `priorityLabel`, `type`, `priority`,
`moduleLabel`, `route`) with safe defaults; contributors still translate domain
data.

All new styling consumes UI-1 tokens (`AppTypography`, `AppColors`, `AppSpacing`,
`AppRadius`, `AppStatus`) — no raw font sizes, weights, colors, radii, arbitrary
insets or shadows.

---

## 16. Accessibility

- Semantic section headings; status is never colour-only (badges carry text).
- Buttons and rows have labels; focus is visible via the shared controls.
- The timeline is a readable list for screen readers.
- Mixed-direction transaction numbers (`ENQ-`, `INS-`, `WE-`) render through
  Flutter's Unicode bidi; Arabic typography is centralized (IBM Plex Sans
  Arabic) with no local overrides.
- Text scale is validated to 1.3 (and the existing suite also exercises 1.5) with
  no overflow or clipped KPI values.
