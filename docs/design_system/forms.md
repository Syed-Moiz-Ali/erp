# Forms design system

Standardized Create/Edit form architecture for the ERP. It applies to every
Services master, directory and transaction form, and is built entirely from
shared primitives in `lib/design_system` — no screen-specific padding or width
hacks.

## Global width

Every form renders inside `AppPage`, the single global centered ERP content
width (`AppDimensions.contentMaxWidth`). Forms never introduce a second
narrower/wider centered wrapper. `AppFormPage` wraps `AppPage` so all forms
inherit the same outer bounds as lists, dashboards and detail screens.

## Form shell — `AppFormPage`

`AppFormPage` composes the whole shell:

- `AppPageHeader` with a **mode-aware title** (`Add priority` / `Edit priority`,
  `New enquiry`, `Add customer`, …) and an optional short subtitle.
- Top-right actions: a secondary `AppTextButton` Cancel and a primary
  `AppPrimaryButton` Save/Create. Primary/secondary hierarchy is fixed; loading
  disables duplicate submit via `AppPrimaryButton(loading: …)`.
- An optional danger `AppAlert` for storage failures.
- A loading skeleton (`AppFormSkeleton`) while an existing edit record is being
  fetched, so the form never renders blank then pops in.
- A centralized not-found state (`AppErrorState`) when an edit record is
  missing, instead of an empty form.

`FormNavigationGuard` (dirty-form warning) and the existing `AppFeedback`
snackbar mechanisms are unchanged.

## Form grid — `AppFormGrid`

A 12-column responsive grid:

| Breakpoint | Behaviour |
| --- | --- |
| Compact (mobile) | single column (span 12) |
| Medium (tablet) | up to two columns (spans ≥ 9 stay full width) |
| Expanded / large (desktop) | requested spans |

Pass `spans` (one per child) using `AppFormSpan`:

```dart
AppFormGrid(
  spans: [AppFormSpan.half, AppFormSpan.half, AppFormSpan.full],
  children: [codeField, nameField, descriptionField],
)
```

Conventions: `Code` 4–6, `Name` 6–8, `Description` 12, `Sort order` 3,
`Rank` 3. Never stretch a tiny numeric field to full width.

## Field labels

All input primitives use **external top labels** by default
(`AppTextField.labelAbove = true`). This is the single label pattern for
Services forms and fixes the outlined floating-label/border collision at the
current density. `AppFieldLabelGroup` renders the label, the optional required
indicator (`Name *`) and an optional trailing control. Helper text
(`helperText`) is subtle and only used when it adds value.

Required fields set `required: true`; the indicator is centralized. Validation
errors render directly below the affected field through the same decoration and
never shift the form unpredictably.

### Input primitives

`AppTextField`, `AppSelectField<T>`, `ServiceReferenceField<T>`,
`AppDateField`, `AppTimeField`, `AppNumberField`, `AppSearchField` — all share
the same shell (`AppFieldShell` focus halo), radius, border token and compact
enterprise height.

## Boolean setting rows — `AppBooleanSettingRow`

A settings row with label + optional description + aligned toggle. The whole
row is a tap target (switch label is tappable), supports disabled/loading and
mirrors under RTL. Use it instead of an isolated `AppSwitchField`.

## Read-only context — `AppReadOnlyContextSection`

Inherited values (customer, mobile, tenant, building, unit, complaint,
priority, material received, generated numbers) render as key/value context,
never as disabled inputs:

```dart
AppReadOnlyContextSection(title: l.section, fields: [
  AppDetailField(label: l.customer, value: source.customerName),
])
```

System-generated values use `AppGeneratedValueField` (shows the value or a
"generated when saved" fallback). Audit values use `AppAuditMetadataBlock` on
detail/edit pages; audit fields are never editable inputs.

## Repeatable editors

`AppRepeatableSection` renders a section title with a compact `+ Add …` action
in the header, then item cards. `AppRepeatableItemCard` renders each item's
number/title, optional status chip, a subtle remove icon with tooltip, then its
fields. Editors (`EnquiryDetailEditor`, `AssignmentWorkEditor`,
`InspectionChecklistEditor`, `MaterialRequestLinesEditor`,
`WorkExecutionLinesEditor`, …) render only the item cards; the owning form owns
the section header + Add action. This keeps desktop compact and mobile stacked
with no eight-field rows.

## Attachments

`ServiceAttachmentStrip` + `AttachmentThumbnail` provide the single attachment
treatment: a labelled strip, `+ Add photos`, thumbnails with file name and
upload status, and a remove action. Native file controls are never shown.

## Create/Edit reuse

Each domain has one form view, one state model and one validation path; Create
and Edit differ only by initial values, page title, save operation and (where
applicable) audit metadata. There is no separate Create vs Edit layout.
