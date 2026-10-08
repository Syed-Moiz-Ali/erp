# UI-7 — Specialized Workspaces (Part A)

UI-7 targets the specialized screens that the generic UI-3…UI-6 patterns do not
cover: settings hubs, Users & Access, Company Modules and the supporting
settings/profile surfaces. Part A covers the shared specialized foundation, the
settings hubs, the permission-driven access editor, module enablement and the
supporting UX polish. Reports, charts, the leave calendar and holiday
management are covered by **Part B** (see the placeholders at the end).

**Scope discipline:** this phase changes presentation, design-system components,
localization and tests only. No domain, data, repository, route, permission,
scope, schema or outbox behaviour changed. `schemaVersion` stays **18**.

## 1. Specialized foundation

Reusable primitives live in
`lib/design_system/components/specialized/` and are exported through
`app_specialized.dart` (re-exported by `design_system.dart`):

| Component | File | Purpose |
| --- | --- | --- |
| `AppWorkspaceHeader` | `app_workspace.dart` | One `AppPageHeader` (+ optional compact summary strip); never a duplicate title card. |
| `AppWorkspaceSection` | `app_workspace.dart` | Titled block with plain / card / bordered surfaces. |
| `AppSummaryStrip`, `AppReportMetric`, `AppSummaryMetric` | `app_workspace.dart` | Compact metric language (label over a tabular value). Never giant KPI cards. |
| `AppReportToolbar`, `AppLegend` | `app_workspace.dart` | Report filter surface and colour+label legend. |
| `AppSettingsHub`, `AppSettingsGroup`, `AppSettingsItem` | `app_settings_hub.dart` | Compact grouped settings navigation. |
| `AppAccessSummary` | `app_access.dart` | Compact access summary before the matrix. |
| `AppPermissionMatrix`, `AppPermissionGroup`, `AppPermissionSubgroupPresentation`, `AppPermissionRowPresentation` | `app_access.dart` | Module → submodule → row permission matrix. |
| `AppScopeSelector`, `AppScopeOption` | `app_access.dart` | SELF / ASSIGNED / TEAM / ALL selector for scoped View permissions only. |
| `AppModuleToggleRow` | `app_access.dart` | Company module enablement row. |
| `AppCalendar*` | `app_calendar.dart` | Calendar grid, day cell, header, agenda (Part B). |

All components consume already-resolved presentation data. None of them compute
authorization, scope, module entitlement or the effective grant set.

## 2. Settings hub anatomy

A settings landing is a set of compact, grouped navigation rows — not giant
cards, a raw route list or a KPI dashboard.

- `AppSettingsHub` renders one `AppSettingsSection` per group and drops any
  group whose item list is empty. When every group is empty it degrades to the
  shared empty state.
- `AppSettingsItem` = icon + title + short description + optional **meaningful**
  count/status + a direction-aware chevron (`AppSettingsRow`).
- **Permission filtering:** each page includes an item only when the user holds
  the View grant for that master. Page discovery follows View; create/edit stays
  **Manage**-gated on the destination page. A Root-Cause-View-only user therefore
  sees *Services settings → Inspection → Root causes* and nothing else.
- HR/general settings (`ConfigurationLandingPage`) and Services settings
  (`ServiceSettingsPage`) share the same section + row language, so they read as
  one product.

Groups use **actual implemented masters only**:

- HR — Attendance (Shifts, Work locations, Attendance policies); Leave (Leave
  types, Leave policies, Holidays).
- Services — General (Service types, Complaint types, Priorities, Ticket types);
  Inspection (Root causes, Charge responsibility); Materials (Material request
  purposes).

## 3. Access editor

`UsersAccessPage` uses the UI-4 collection language (name/email/employee
link/module summary/status/actions) and never dumps raw permission keys.

`UserAccessDetailPage` renders the state owned by `UserAccessCubit`:

- **Header:** user identity, email (or "No login"), status, company and an
  explicit **Employee link** (linked employee code, or "Not linked"). An unlinked
  platform/admin user is valid and is never presented as broken.
- **`AppAccessSummary`:** compact metrics (granted permissions, module access,
  employee link). The ambiguous "broadest data scope" aggregate is deliberately
  omitted because scopes differ per permission.
- **`AppPermissionMatrix`:** module groups → submodule sections → rows. Row =
  localized business label + description + switch + (scoped View only) scope
  selector. A presentation-only search filters by label/description/key and shows
  a distinct no-match state.
- Raw permission keys are not shown; the optional technical context is reserved
  for a future debug mode.
- **Dirty state:** a `PopScope` guard warns on navigation when there are unsaved
  changes (`accessUnsavedTitle` / `accessUnsavedMessage` / Stay / Leave). Save is
  disabled until the draft differs from the saved grants.
- **Save:** confirmation dialog, single in-flight save, loading on the primary
  action, no duplicate submit.
- **Access history:** compact per-user timeline of what changed, by whom, when
  and the scope transition (for example "Assigned → Team"). No serialized
  payloads.

### 3.1 Permission and scope presentation

- View vs Manage: a View grant exposes the screen; Manage gates create/edit.
- **Scoped View** permissions expose SELF / ASSIGNED / TEAM / ALL with
  business-friendly labels (`accessScopeSelf`, `accessScopeAssigned`, …).
- **Action** permissions (perform/create/edit/complete/cancel/print) never show
  a fake independent scope — visibility follows the View scope
  (`accessActionScopeNote`). This reinforces the hard invariant that an action
  permission never widens record visibility.
- **Configuration** permissions are scope-less.
- **Manage → View dependency:** permissions whose Manage counterpart is granted
  render the paired View row as `Included` and locked, because runtime
  normalization (`permissionViewDependencies`) already derives it. The editor
  never makes the user reason about a hidden dependency.
- **Employee-link requirement:** rows that require a linked active employee show
  a concise requirement note when the target has no link, and a denied reason
  instead of a vague failed save.
- **Self-escalation / last-admin:** unchanged business rules; the UI surfaces the
  business-friendly message (`accessSelfEscalation`, `accessLastAdmin`) rather
  than internal exception text.

### 3.2 Accessibility & keyboard

- Every permission control announces its name, enabled/disabled state and scope
  ("View work executions, Scope: Assigned").
- Module groups are `Semantics(button: true, expanded: …)`; expand/collapse,
  permission toggles, scope chips and save/cancel are keyboard reachable through
  the standard `Focus`/`InkWell` traversal.
- Mobile uses grouped cards/rows with the scope below the row — no wide matrix
  horizontal scroll.

## 4. Company Modules UX

`CompanyModulesPage` is intentionally distinct from the access editor: it shows
which ERP modules are enabled **for the company**, not who can access them.

- Compact rows (`AppModuleToggleRow`): icon, name, description, UI-1 switch and
  an Enabled/Disabled status badge.
- No invented module dependencies; no giant coloured "enabled" card.
- Module availability is a platform-level concern, so the rows render read-only
  in this build and an info card states the rule: *module enabled for the company
  ≠ user has access*. No confirmation flow is invented where none exists.

## 5. Supporting UX

- **Profile** keeps read-only identity sections plus supporting actions only; it
  never duplicates the HR employee record.
- **Change password** uses the standard form primitives (`AppPasswordField` with
  show/hide), clear validation and only the real backend/domain rules — no
  invented strength rules.
- **Reminder settings** use settings-row patterns; no new preferences.
- **Sync status** is presented as calm infrastructure status (last sync, pending,
  failed, retry) with no raw stack traces or database errors.
- Notifications keep the UI-4 collection; only existing specialized states were
  left in place.

## 6. Responsive strategy

- Every specialized screen still uses `AppPage` (single global content width,
  centred). There is deliberately **no** `reportMaxWidth`, `calendarMaxWidth` or
  `accessEditorMaxWidth`.
- `AppPermissionMatrix` uses dense rows on compact widths and grouped cards with
  the scope selector beneath the label; no horizontal matrix scrolling.
- `AppSummaryStrip` reflows 2-up on mobile and up to 4-up on wide canvases.

## 7. RTL

- All primitives use directional padding/alignment (`EdgeInsetsDirectional`,
  `AlignmentDirectional`) and mirror chevrons by `Directionality`.
- Scope and status labels are localized; enum formatting such as
  `PermissionScope.assigned` is never exposed.
- Access and calendar data render correctly under mixed direction.

## 8. Accessibility summary

Announce name + enabled + scope for permission controls; provide text
equivalents for colour/legend meaning; keep day/event semantics explicit for the
calendar (Part B). No meaning is carried by colour alone.

## 9. Module-polish process

1. Inventory every HR/Services/platform route and mark its migration state.
2. Replace surviving bespoke styling with the existing UI-1…UI-6 primitives
   instead of inventing a new component per problem.
3. Classify remaining raw style values as (a) valid design-system
   implementation, (b) legitimate one-off optical detail, or (c) migration debt.
4. Remove only **confirmed-unused** presentation code; never touch domain or
   repository code.

See `audit_ui1.md` for the current migrated / remaining / excluded classification.

## 10. Part B placeholders

The following sections will be completed by UI-7 Part B and are intentionally
left as placeholders here:

- **Reports** — attendance/leave report workspaces, filters, toolbar, summary
  metrics, detail table, drill-down, export/print, loading/error/empty states.
- **Charts** — chart policy, allowed chart types, colours, axes, tooltips, empty
  states, text equivalents.
- **Leave calendar** — calendar header, month grid, today/selected day, holiday
  overlay, event display/count, selected-day agenda, touch, RTL, accessibility.
- **Holiday management** — year navigation, summary, copy prior year, type
  legend.
