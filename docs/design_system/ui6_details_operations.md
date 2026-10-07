# UI-6 — Detail pages, operational workspaces, timelines, status/action hierarchy & read-only information design

This is the authoritative reference for every production **read / detail /
operational** surface in the ERP. It extends the UI-1..UI-5 design system with
one shared detail language and replaces the old "disabled form" / ad-hoc card
detail pattern.

Everything here is built from primitives in `lib/design_system` (plus the
existing Phase 7 Services workflow widgets and HR widgets). **No detail page
introduces a second content width, a disabled `TextField`, a new business
transition, or raw typography / colour / radius / spacing / shadow values.**

Global width is unchanged: every detail page renders inside `AppPage` with
`AppDimensions.contentMaxWidth = 1200`, centered. There is no
`detailMaxWidth` / `transactionMaxWidth` / `employeeProfileWidth`.

---

## Detail anatomy

```
AppPage (global 1200 content width, centered)
├─ AppDetailHeader
│   ├─ AppBreadcrumbs            (only for deep records)
│   └─ AppRecordIdentity         avatar/glyph + title + business id + description
│       └─ AppDetailStatus       status adjacent to identity
│   └─ AppMetadataRow            most useful metadata only (date · priority · technician)
│   └─ AppDetailActions          1 primary · 1–2 secondary · destructive · More menu
├─ optional AppContextBanner     compact context block (customer/site/unit…)
├─ AppInfoSection (plain/bordered/panel)
│   └─ AppInfoGrid               responsive read-only values
├─ domain operational sections   work lines / checklist / material tables / evidence
├─ related records / workflow    compact links + workflow strip
├─ AppActivityTimeline           structured business events, company-local time
└─ AppAuditMetadata              secondary created/updated info, at the bottom
```

`AppDetailPage` wraps `AppPage` and applies a uniform `AppSpacing.xxl` rhythm
between sections so every detail page has the same section spacing.

---

## Record header

`AppDetailHeader` composes `AppRecordIdentity`, `AppDetailStatus` and
`AppDetailActions` and is the single header for all detail pages.

- **Identity** — title, the human-readable business identifier (`ENQ-00042`,
  `INS-00022`, `WE-00016`, `EMP-0042`…) rendered through `AppIdentifierText`
  (directionally LTR even under RTL), and the primary descriptive text.
- **Status** — `AppDetailStatus` (an `AppStatusBadge` with text + optional
  icon/dot) sits next to the title, never buried in a later section.
- **Metadata** — `AppMetadataRow` shows only the few items that help scanning
  (date, priority, technician, visit, request date…). It is not the whole record.
- **Actions** — see below.

Raw UUIDs are never the visual identity.

## Status hierarchy

`AppStatus` (success/warning/danger/info/neutral/brand) is the one semantic
scale. Status is always text-bearing (`AppDetailStatus`/`AppStatusBadge`) so it
is never communicated by colour alone.

## Action hierarchy

`AppDetailActions` renders, in order:

1. **Primary** — the most likely operational next action (`AppPrimaryButton`).
2. **Secondary** — 1–2 actions such as Edit (`AppSecondaryButton`).
3. **Destructive** — Cancel / Deactivate, visually quieter.
4. **More** — every remaining action behind `AppActionMenu` (UI-1 More menu).

This keeps headers at 1 primary + 1–2 secondary, never seven visible buttons.

**Permission vs business state is preserved:** when there is no permission the
action is *absent*; when permission exists but business state prohibits it, the
action is present but disabled (`onPressed: null`). No unauthorized action is
revealed.

## Information grid and empty values

`AppInfoGrid` (and the refined `AppDetailsGrid`) is responsive by centralized
breakpoint, never a hardcoded column count:

| viewport | columns |
| --- | --- |
| mobile (`< 600`) | 1 |
| tablet (`600–999`) | 2 |
| desktop (`1000–1439`) | 3 (2 below 1100) |
| large desktop (`≥ 1440`) | 4 |

Values are labels + readable text, never disabled inputs. `AppDetailValue.of`
is the single empty-value convention (`Not provided` / `غير متوفر`) — the app
does not alternate between `null`, `N/A`, `-` and blank. Long text
(description/reason/remarks) is rendered as readable paragraphs, preserving line
breaks, never inside a disabled textarea.

## Related records

`AppRelatedRecordLink` is a compact label + business id + (direction-aware)
arrow. Business IDs are clickable **only** when the caller passes `onTap`, i.e.
only when the existing permission/scope model allows the destination. Without it
the link renders as plain text, so no destination is exposed beyond access.
Related-record links use existing snapshots (`view.enquiryNumber`,
`view.assignmentNumber`, …) — no full record is fetched just for an id+label.

## Workflow lineage

Workflow (related *records*) is kept separate from the Activity Timeline
(*events over time*). The existing Phase 7 `ServiceWorkflowSection` (driven by
the typed workflow resolver) renders the lineage
`Enquiry → Assignment → Inspection → [Material Request] → Work Execution` with
the current record highlighted. Material Request is visually **optional**
(the chain remains valid without it), and no future record is invented
(no "Work Execution Pending").

## Timeline

`AppActivityTimeline` renders structured business events only (no
UI-invented events). Each `AppActivityEntry` shows a semantic icon, localized
title, actor, company-local time, supporting metadata and optional
detail/reason. It is compact (no giant circles / long connector lines / social
feed look) and limited to a reasonable number of items. Empty timelines render
the compact `AppEmptySection`, not a blank panel. All displayed business time
uses `CompanyTimeService` via the shared formatters — no raw `DateTime.now()`
formatting in widgets.

## Attachments / evidence

`AppEvidenceGallery` is a polished read-only thumbnail grid (2 columns mobile,
more on wider canvases) using `Image.network(cacheWidth:)` so thumbnails never
decode at full resolution. Each item shows a thumbnail, description and open
action. `AppAttachmentPreview` renders a bounded full-size preview inside a
dialog. Empty evidence renders a compact `AppEmptySection`.

The three photo concepts remain **distinct**: Enquiry Detail Photos, Inspection
Before Work Photos, and Work Execution After Work Photos are never merged.

## Audit metadata

`AppAuditMetadata` renders created/updated by + at as secondary information at
the bottom of a detail page (or collapsed), never as a hero section.
`AppAuditMetadataBlock` remains available for edit/read-only contexts.

## Operational workspaces

`AppOperationalActionPanel` gives action-heavy records one clear action area
(current state, key facts, a primary operational action, secondary/destructive
actions) and uses a left accent for the active state.

Operational actions call the **existing** use cases/cubits — no business
transition is rebuilt in a widget. Feedback uses the shared
`AppFeedback`/`AppConfirmationDialog` (loading / success / error, no duplicate
submissions).

**Work Execution** is a real workspace:

- header: WE number, status, customer/site, date, primary operational action;
- work lines show line number, work, description, team/employee, state,
  start/end and the permitted action;
- `NOT_STARTED` / `IN_PROGRESS` / `FINISHED` use subtle treatment, with a left
  accent + chip for `IN_PROGRESS` (no giant coloured backgrounds);
- **Start work** appears only for an eligible `NOT_STARTED` line in scope with
  Perform permission; **End work** only for the current `IN_PROGRESS` line; a
  finished line shows Started/Ended and no Start/End action;
- **Material Used** shows Code + Description only (no Qty/UOM/Cost) plus an
  optional source MR reference;
- **After Work Evidence** is a separate gallery and is not marked "Required"
  (rule remains TBD);
- **Complete** uses the existing completion validation (disabled until all
  lines are complete); **Cancel** is destructive behind the More menu.

**Edit vs Perform** is preserved: Edit (structure/metadata) and Perform
(Start/End and permitted execution actions) are separate permissions. A
Perform-only field employee gets a clean operational surface, not a disabled
Edit page.

---

## Material concepts stay separate

- **Inspection** — Material Required (Code + Description + Status + linked MR,
  no Qty).
- **Material Request** — Material Requested + Qty (Code, Description, Batch,
  Qty, Remark) with a derived total summary.
- **Work Execution** — Material Used (Code + Description only).
- **Material Received** — owned by the Service Enquiry; downstream pages show
  the inherited read-only value and never duplicate it as mutable state.

Job Order and Quotation remain compatibility/reference values only (no fake
destination module). No "Generate Service Report" action was added.

---

## Responsive behaviour

| viewport | behaviour |
| --- | --- |
| 390 mobile | purpose-built order: identity/status → primary action → summary → critical operational content → details → related → activity/audit. No horizontal scroll (Work Execution, Attendance Today, Inspection verified). |
| 600 tablet | 2-column info grids; complex operational sections stay full width. |
| 1000/1280 desktop | 3-column info grids; header actions inline. |
| 1440/1920 large | 4-column info grids. Content still 1200 centered; `AppOperationalLayout` main+supporting split is available where it improves scanning. |

Loading uses `AppDetailSkeleton` (header + summary + sections), never a single
giant spinner. Not-found uses the shared `AppNotFoundState`; denied access uses
`AppPermissionDeniedState` with no partial data rendered. Live permission/scope
loss and module disablement are handled by the existing route-guard/access
architecture, so a detail page recomputes access and navigates/denies safely.

## RTL

All patterns support Arabic: breadcrumbs (direction-aware separators),
header actions, status chips, info grids, workflow arrows, timeline, tables,
photo galleries and More menus. Mixed-direction identifiers (emails, phones,
transaction ids, material/employee codes) are rendered through `AppIdentifierText`
to stay LTR-readable inside RTL. Workflow direction is deliberate, not a blind
mirror. Text scale 1.0 and 1.3 are overflow/clip free.

## Accessibility

Semantic headings; status announced as text; buttons labelled with context
("Edit inspection INS-00022"); related links and attachments keyboard reachable;
timeline entries ordered semantically; status/action never colour-only.

---

## Shared primitives

Domain-neutral (in `lib/design_system/components/detail/app_detail.dart`):

- `AppDetailPage`, `AppDetailHeader`, `AppRecordIdentity`, `AppDetailStatus`,
  `AppDetailActions` / `AppDetailAction`
- `AppInfoSection`, `AppInfoGrid`, `AppInfoItem`, `AppMetadataRow`,
  `AppMetadataItem`, `AppContextBanner`, `AppRelatedRecordLink`
- `AppActivityTimeline`, `AppActivityEntry`
- `AppEvidenceGallery`, `AppEvidenceItem`, `AppAttachmentPreview`
- `AppOperationalActionPanel`, `AppOperationalFact`
- `AppAuditMetadata`, `AppEmptySection`, `AppDetailErrorState`,
  `AppDetailValue`, `AppIdentifierText`, `AppPersonIdentity`, `AppRecordGlyph`

Refined/reused: `AppDetailsGrid` (now responsive), `AppTimeline`,
`AppDetailSkeleton`, `AppChangeComparison`, `AppEmptyState`/`AppNotFoundState`/
`AppPermissionDeniedState`, attachment thumbnails, `ServiceWorkflowSection`.

Domain views stay domain-specific (no generic reflection renderer):
`InspectionChecklistView`-style inline checklist, work-line views, employee
identity header.

---

## Screen inventory

| Screen | Module | Classification | Status |
| --- | --- | --- | --- |
| Employee Details | HR | DETAIL | migrated (record header + metadata + action hierarchy) |
| Attendance Today | HR | OPERATIONAL WORKSPACE | migrated (status near identity; existing state card/timeline retained) |
| Attendance Day Detail | HR | CALENDAR/AGENDA DETAIL | migrated (AppDetailHeader + breadcrumbs) |
| Attendance Workforce Detail | HR | OPERATIONAL DETAIL | migrated (AppDetailHeader) |
| Attendance Correction Detail / Review | HR | REVIEW/APPROVAL | migrated (status in header; current-vs-requested `AppChangeComparison` retained) |
| Leave Request Detail | HR | REVIEW/APPROVAL | migrated (status near identity; decision actions) |
| Shift Detail | HR | CONFIGURATION DETAIL | migrated (via `ConfigurationDetailsLayout`) |
| Work Location Detail | HR | CONFIGURATION DETAIL | migrated (via `ConfigurationDetailsLayout`) |
| Attendance Policy Detail | HR | CONFIGURATION DETAIL | migrated (via `ConfigurationDetailsLayout`) |
| Leave Type / Leave Policy / Holiday Detail | HR | CONFIGURATION DETAIL | migrated (via `ConfigurationDetailsLayout`) |
| Customer Detail | Services | DETAIL | migrated |
| Site Detail | Services | DETAIL | migrated |
| Service Team Detail | Services | DETAIL | migrated (members show employee identity) |
| Enquiry Detail | Services | DETAIL | migrated (compact customer context; per-line issues/photos retained) |
| Job Assignment Detail | Services | DETAIL | migrated |
| Inspection Detail | Services | DETAIL | migrated (Root Cause promoted as key finding) |
| Material Request Detail | Services | DETAIL | migrated (print secondary; empty values normalised) |
| Work Execution Detail | Services | OPERATIONAL WORKSPACE | migrated (active work-line accent; operational hierarchy) |
| User Access Detail | Platform | CONFIGURATION/REVIEW DETAIL | migrated header; access editor/matrix preserved |
| My Profile | Platform | SELF-SERVICE DETAIL | migrated header; account/HR distinction preserved |

### Not migrated (with exact reason)

- **Leave Calendar month grid** — §63 explicitly excludes redesigning
  month-grid logic; the calendar is not a generic detail page. Day-agenda chips
  use existing UI-1 components.
- **Notification detail** — there is deliberately no separate notification
  detail page; deep links open the canonical business detail (§124).
- **HR report drill-downs** — report analytics are deferred to UI-7 (§120).
- **Change Password / reminder / sync settings** — these are self-service
  *action* surfaces (forms/navigation), not record detail pages; they remain on
  their UI-5/UI-2 treatments.
- **Services master configuration detail** — the master list routes view users
  to the list and managers to Edit; no standalone detail route exists, so no
  detail page was invented (§64).

---

## Before / after architecture

**Before**

- `FormPage(readOnly: true)`-style detail pages with disabled fields.
- Ad-hoc cards, a column of cards, or a dump of database fields.
- Status rendered inside a later card/badge row, not near identity.
- Actions in an unordered row; permission and business-state actions mixed.
- Key/value shown as raw fields, empty values as `null`/`N/A`/blank.
- No shared timeline/evidence/audit treatment.

**After**

- `AppDetailPage` → `AppDetailHeader` (strong record identity, business id,
  status adjacent, disciplined actions) → `AppContextBanner` → meaningful
  `AppInfoSection`/`AppInfoGrid` sections → operational sections → related
  records/workflow → `AppActivityTimeline` → `AppAuditMetadata`.
- Purpose-built read-only components, one empty-value convention, compact
  evidence galleries, secondary audit metadata.
- Domain logic untouched: typed workflow/action resolvers, permissions, scope,
  routes, repositories and schema (`18`) are unchanged.

No business/permission/scope/route/repository/schema change was introduced by
UI-6.
