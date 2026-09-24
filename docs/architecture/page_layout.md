# Page layout system

Every business module (HR, Services, Settings, and future Inventory/Sales/
Finance/Purchase) shares **one** page layout system with **one** content width.

## The shared primitive

`AppPage` (`lib/design_system/components/layout/app_page.dart`) is the single
page shell. It owns:

- responsive outer padding — `AppSpacing.lg` (16) on compact, `AppSpacing.section`
  (32) otherwise, using `AppBreakpoints` (compact `<600`, medium `600–1000`,
  expanded `1000–1440`, large `≥1440`);
- the single global content width `AppDimensions.contentMaxWidth` (1200);
- **horizontal centering** inside the main workspace (after the sidebar), so the
  left and right free space are always equal;
- the optional `header` and `filters` slots, which share the **same** content
  boundary as the body (headers, search, filters, sort, tables, cards, forms,
  pagination and activity all align to the same two content edges).

Feature children own only internal section spacing — never outer page padding.

## One global width (mandatory)

```
width     = min(availableWorkspaceWidth, AppDimensions.contentMaxWidth)
alignment = center
```

- **Every** screen uses the same width: lists, tables, create/edit forms,
  details, dashboards, reports, settings. There are **no** per-screen width
  modes (no form/standard/wide). A page never chooses its own width.
- On large monitors the content stops growing at the max width; the remaining
  space is split equally left and right.
- Centering is relative to the **main workspace** (after the sidebar), not the
  whole browser window.
- Mobile/tablet remain fluid: content is `availableWidth - padding`, with equal
  side padding; the desktop max width is never forced on small screens.

## Tables

Tables respect the common width. If a table has too many columns it uses
horizontal scrolling **inside its own container** (or compact/mobile card
representations) — the page width is never expanded to fit a table.

## Rules

- Feature pages must never establish their own outer horizontal page origin or
  width (no page-level `Center`/`ConstrainedBox`/`SizedBox(width:)`/
  `FractionallySizedBox`/custom `EdgeInsets`/`maxWidth`).
- Do not double-constrain: one page-level width only; internal grids/columns are
  fine, an inner page wrapper is not.
- Primary header actions align to the page content boundary, never the viewport
  edge.
- Do not confuse page outer padding with card internal padding.
- Arabic/RTL: centering and padding are symmetric/logical; there is no LTR-only
  positioning.

## Reference

`AppPage` is the single shell used by every feature page. Layout regression
tests (`test/page_layout_test.dart`, `test/services_widget_test.dart`) assert
that all screens share one left/right page edge with equal free space, and that
content stops growing at 1920.
