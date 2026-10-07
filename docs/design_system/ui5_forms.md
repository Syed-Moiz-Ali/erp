# UI-5 — Create/Edit forms, input UX, reference selectors, repeaters & attachments

This is the authoritative reference for every production Create/Edit surface in
the ERP. It extends `docs/design_system/forms.md` (the original form pass) with
the UI-5 refinements: mode-aware headers, external labels everywhere, a shared
long-form action bar, boolean settings rows, read-only context, searchable
reference selectors, standardised date/time controls, repeatable child sections,
polished attachments and validation presentation.

Everything is built from primitives in `lib/design_system` plus the shared
Services widgets. **No form introduces a second content width, local input
decorations, raw typography/colour/radius/shadow values, or its own upload
subsystem.**

## Form anatomy

```
AppPage (global 1200 content width, centered)
└─ AppPageHeader  mode-aware title + concise subtitle + short-form actions
└─ optional AppAlert / AppFormErrorSummary (top-level failure)
└─ grouped AppFormSection surfaces (never one giant card, never one card per field)
│  ├─ AppFormGrid (responsive internal columns)
│  ├─ AppBooleanSettingRow (settings, not field-shaped switches)
│  ├─ AppReadOnlyContextSection / AppGeneratedValueField / AppAuditMetadataBlock
│  ├─ AppRepeatableSection + AppRepeatableItemCard
│  └─ ServiceAttachmentStrip
└─ AppFormActions (long-form Cancel / Save bar)
```

`AppFormPage` owns the shell for Services forms. HR configuration forms compose
the same `AppPage` + `AppPageHeader` + `AppFormSection` + `AppFormActions`
inside `ConfigurationFormLayout`, and bind the dirty guard through
`ConfigurationFormBinding`. Create and Edit always reuse one composition — only
title, defaults, save operation and audit visibility differ.

## Field grid

`AppFormGrid` is a 12-column grid with `AppFormSpan` weights
(`quarter 3`, `third 4`, `half 6`, `twoThirds 8`, `threeQuarters 9`, `full 12`).
Desktop honours the requested spans, tablet collapses spans ≥ 9 to full and
otherwise to at most two columns, mobile always collapses to a single column.
Widths derive from the shared `AppSpacing.lg` gutter — never `SizedBox(width…)`
hacks. Field width matches data: `Code`/`Sort order`/`Rank` compact, `Name`
medium, `Description`/`Remarks` full-row multiline.

## Labels, required & optional

All input primitives use **external labels above the field**
(`AppFieldLabelGroup`) — this removes the outlined floating-label/border
collision. Required fields set `required: true` and render a single
centralised ` *`. Placeholders are examples, never the label. Helper text is
selective (`Code → stable internal reference`, `Sort order → lower values
appear first`) and never explains the obvious.

## Helper & error text

Helper text and validation errors are rendered by the field decoration directly
below the field using UI-1 semantic tokens. Boolean rows accept `errorText` and
render it beneath the settings row. There is no SnackBar-only or dialog-only
validation, no red border without an explanation, and no all-fields error burst
on first render — errors appear after interaction or submit.

## Read-only context & generated values

Inherited values (Company, downstream Customer/Mobile/Building/Unit, Complaint,
Priority, Material Received, upstream document numbers) render as key/value
`AppReadOnlyContextSection` / `AppDetailField`, **never** disabled `TextField`s.
System-generated numbers use `AppGeneratedValueField` (create: "Generated when
saved"; edit: the value). Audit metadata uses `AppAuditMetadataBlock`. Company
is shell context and is never re-presented as an editable transaction dropdown.

## Reference selectors

`ServiceReferenceField` + `showServiceReferencePicker` provide one searchable
picker used for Customer, Site, Employee, Team, Enquiry, Job Assignment,
Inspection, Leave Type/Policy, Shift, Work Location and Services masters:

- states: idle, searching, results, no results, error + retry, selected,
  disabled;
- debounced search (250 ms) so queries do not run per keystroke;
- company-scoped, permission-safe, context-restricted search via existing
  reference APIs — no full-directory grant;
- selected value shows a label plus context (code/mobile/building/unit or
  employee code + designation), never a raw UUID;
- clear is offered only when the field is nullable;
- Customer → Site dependency recomputes and validates against the existing
  business rules.

## Date & time

`AppDateField` and `AppTimeField` are the single date/time controls (visit
dates, leave dates, holiday date, shift start/end). They preserve `AppClock` /
`CompanyTimeService` company-local semantics. System-generated business dates
are not made editable. Document numbers are never editable inputs.

## Boolean settings

`AppBooleanSettingRow` is the one boolean pattern: external label + optional
supporting text + aligned toggle, whole row tappable, RTL-mirrored, with
disabled/loading/error states. Switches are never placed inside a bordered
field-shaped box. All production boolean fields migrated in this pass.

## Repeatable child sections

`AppRepeatableSection` provides the title + count + `+ Add …` header action +
empty prompt; `AppRepeatableItemCard` renders each item's number/title, optional
status chip and a subtle remove icon (no giant red delete). Sections are dynamic
1..N or 0..N — five blank legacy rows are never hardcoded. Reordering is only
used where the domain persists `sortOrder`. Editors render item cards only, so
desktop stays compact and mobile stacks one item per card with no eight-field
rows.

## Attachments

`ServiceAttachmentStrip` + `AttachmentThumbnail` are the single attachment
treatment built on the existing `AttachmentRepository`: labelled strip,
`+ Add photos`, multiple files, thumbnail-style tiles, filename and upload
state (pending/uploading/uploaded/failed), **retry** for failed/local uploads,
and remove where allowed. Enquiry photos, Inspection Before Work photos and Work
Execution After Work photos remain distinct categories. No native "Choose File"
UI, no new upload subsystem, no owner-authorization change; thumbnails are
metadata tiles rather than full-resolution decodes.

## Actions & submission

Short forms use `AppPageHeader` top-right secondary Cancel + primary Save.
Long forms use the `AppFormActions` bottom bar (cancel on the logical start,
primary on the logical end, subtle top hairline, inside the 1200 width,
RTL-safe). The two are not duplicated. `AppPrimaryButton(loading:)` disables
duplicate submission and preserves width. Success uses centralised feedback (no
modal success dialog); failure keeps field errors and entered state.

## Dirty state, loading, not found

`FormNavigationGuard` / `ConfigurationFormBinding` retain the dirty-form
confirmation on Back/Cancel/browser navigation. Edit loads through
`AppFormSkeleton` (never blank-then-pop). Missing records use the shared
not-found / error state. Revoked permission resolves safely with no active
Save.

## Responsive, RTL, accessibility

Verified at 390 / 600 / 768 / 1000 / 1280 / 1440 / 1920 with LTR and RTL and
text scale 1.0/1.3: single-column mobile, 1–2 column tablet, intentional desktop
composition, no horizontal overflow, sticky/action controls safe-area aware.
Labels, grids, selectors, icons, date/time, switch rows, repeaters, attachments
and actions mirror under RTL; email, phone, codes, references, material codes,
numbers and time stay LTR within Arabic. Controls carry semantic labels and
required state, errors are linked to fields, switch labels activate the control,
attachment retry/remove are labelled and repeater items carry accessible
identity. Enter does not accidentally submit long forms and Escape does not
silently discard.

## Migration inventory

Legend: **Services** = composed with `AppFormPage`; **HR** = composed with
`AppPageHeader` + `AppFormSection` + `AppFormActions` (via
`ConfigurationFormLayout`). All rows below use external labels, UI-1 tokens,
responsive `AppFormGrid`, and have no raw field styling.

| Area | Form | Create/Edit source | Status |
| --- | --- | --- | --- |
| Services master | Service Type | `service_master_form_page.dart` | Migrated (shared master pattern) |
| Services master | Complaint Type | `service_master_form_page.dart` | Migrated |
| Services master | Priority (benchmark) | `service_master_form_page.dart` | Migrated |
| Services master | Ticket Type | `service_master_form_page.dart` | Migrated |
| Services master | Root Cause | `service_master_form_page.dart` | Migrated |
| Services master | Charge Responsibility | `service_master_form_page.dart` | Migrated |
| Services master | Material Request Purpose | `service_master_form_page.dart` | Migrated |
| Services directory | Customer | `service_customer_form_page.dart` | Migrated |
| Services directory | Site | `service_site_form_page.dart` | Migrated |
| Services directory | Service Team | `service_team_form_page.dart` | Migrated |
| Services transaction | Enquiry | `service_enquiry_form_page.dart` | Migrated |
| Services transaction | Job Assignment | `service_job_assignment_form_page.dart` | Migrated |
| Services transaction | Inspection | `service_inspection_form_page.dart` | Migrated |
| Services transaction | Material Request | `service_material_request_form_page.dart` | Migrated |
| Services transaction | Work Execution | `service_work_execution_form_page.dart` | Migrated |
| HR | Employee | `employee_form_page.dart` | Migrated (boolean rows this pass) |
| HR | Shift | `shift_form_page.dart` | Migrated (boolean rows this pass) |
| HR | Work Location | `work_location_form_page.dart` | Migrated (boolean rows this pass) |
| HR | Attendance Policy (benchmark) | `attendance_policy_form_page.dart` | Migrated (boolean rows, textarea, spans) |
| HR | Leave Request | `leave_request_form_page.dart` | Migrated this pass (grouped sections, action bar) |
| HR | Leave Type | `leave_type_pages.dart` | Migrated (boolean rows, textarea) |
| HR | Leave Policy | `leave_policy_pages.dart` | Migrated (boolean rows, spans) |
| HR | Holiday | `holiday_pages.dart` | Migrated this pass (no giant card, action bar, boolean rows) |
| HR | Leave Balance Adjustment | `leave_balances_page.dart` | Migrated (boolean row, tokenised error) |
| HR | Attendance Correction | `attendance_correction_pages.dart` | Existing sectioned `AppPageHeader` form — no boolean settings; not re-structured |
| Platform | Users & Access | `user_access_detail_page.dart` | Deliberately not the entity form shell — a permission matrix editor (`AppPageHeader` + module cards + scope chips); no entity Create/Edit semantics |
| Platform | Company Modules | `company_modules_page.dart` | Read-only settings surface (no Create/Edit form) |
| Platform | My Profile | `my_profile_page.dart` | Read-only self-service profile (no Create/Edit form) |
| Platform | Reminder / Sync settings | `reminder_settings_page.dart`, `sync_settings_page.dart` | Settings surfaces, not entity Create/Edit forms |
| Auth | Change Password | `change_password_page.dart` | Auth flow, styled by UI-1; out of Create/Edit scope |

### Exclusions and reasons

- **Attendance Correction** already uses `AppPageHeader` + `AppFormSection`
  grouping and exposes no boolean settings or stretched fields; it was not
  re-structured to avoid churn in an existing, correct pattern.
- **Users & Access** is a permission editor (module → submodule → action /
  scope), not an entity form; converting it to the generic form shell would
  harm usability and risk permission semantics. It already uses `AppPageHeader`
  actions, chips and grouped cards, and hides all editable controls without
  manage permission.
- **Company Modules** and **My Profile** are read-only; there is no production
  Create/Edit form to migrate.
- **Reminder/Sync settings** and **Change Password** are settings/auth flows,
  not Create/Edit entity forms.

## Tests

`test/ui5_forms_test.dart` covers the shared grid, boolean row, read-only
context/generated values, action bar, error summary, reference field + picker
(search/loading/empty/error+retry/select/clear/disabled/RTL), repeater
(add/remove/dynamic/empty), attachments (add/multiple/uploaded/failed/retry/
remove/localised) and the 390→1920 × LTR/RTL × 1.0/1.3 viewport matrix.
`test/services_form_redesign_test.dart` and `test/configuration_widget_test.dart`
cover the Services and HR form integrations, permission routes and dirty guards.
