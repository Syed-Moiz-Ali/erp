# Approved UI changes

Baseline: `ac2ec6f` (tip of `services_module`, 2026-10-08). The UI/UX is frozen
against this commit.

Only the paths listed below may differ from `ac2ec6f`. Everything else under
`lib/**/presentation/**`, `lib/shared/presentation/`, `lib/app/router/`,
`lib/app/shell/`, `lib/app/module_registry/`, `lib/design_system/`, the l10n
sources, and the module route/registration files must stay byte-identical.

## Approved: Departments (carried from 19a0b24)

Reason: the Departments module has no baseline screen. Its list/detail/form
screens follow the app's existing configuration pattern.

- `lib/modules/hr/departments/presentation/bloc/department_details_bloc.dart` - approved Departments screen (19a0b24)
- `lib/modules/hr/departments/presentation/bloc/department_form_bloc.dart` - approved Departments screen (19a0b24)
- `lib/modules/hr/departments/presentation/bloc/department_list_bloc.dart` - approved Departments screen (19a0b24)
- `lib/modules/hr/departments/presentation/pages/department_details_page.dart` - approved Departments screen (19a0b24)
- `lib/modules/hr/departments/presentation/pages/department_form_page.dart` - approved Departments screen (19a0b24)
- `lib/modules/hr/departments/presentation/pages/department_list_page.dart` - approved Departments screen (19a0b24)
- `lib/modules/hr/module/hr_module_registration.dart` - Departments destination/route registration only (19a0b24)
- `lib/app/module_registry/registered_modules.dart` - Departments repository/permission/settings wiring only (19a0b24)
- `lib/shared/presentation/configuration_landing_page.dart` - Departments settings row and count only (19a0b24)
- `lib/shared/presentation/configuration_localization.dart` - Departments field-error mapping (19a0b24; also Early punch validation copy from 350949d)
- `lib/app/router/app_routes.dart` - Departments route aliases only (19a0b24)
- `lib/modules/hr/module/hr_routes.dart` - Departments route constants only (19a0b24)
- `lib/platform/auth/presentation/auth_localization.dart` - Departments permission labels only (19a0b24)
- `lib/l10n/generated/app_ar.arb` - generated Departments strings (19a0b24; also approved Early punch strings)
- `lib/l10n/generated/app_en.arb` - generated Departments strings (19a0b24; also approved Early punch strings)
- `lib/l10n/generated/app_localizations.dart` - generated Departments strings (19a0b24; also approved Early punch strings)
- `lib/l10n/generated/app_localizations_ar.dart` - generated Departments strings (19a0b24; also approved Early punch strings)
- `lib/l10n/generated/app_localizations_en.dart` - generated Departments strings (19a0b24; also approved Early punch strings)
- `lib/modules/hr/l10n/hr_ar.arb` - Departments and Early punch strings (19a0b24, 350949d)
- `lib/modules/hr/l10n/hr_en.arb` - Departments and Early punch strings (19a0b24, 350949d)
- `lib/platform/l10n/platform_ar.arb` - Departments permission labels (19a0b24)
- `lib/platform/l10n/platform_en.arb` - Departments permission labels (19a0b24)

## Approved: Shifts backend-mode adaptation (carried from 350949d)

Reason: the backend shift contract has no working-days or break-rule fields, so
those controls are hidden in backend mode; the approved Early punch-in window
field is added.

- `lib/modules/hr/shifts/presentation/bloc/shift_form_bloc.dart` - backend-mode default working days (350949d)
- `lib/modules/hr/shifts/presentation/pages/shift_details_page.dart` - backend-mode field hiding and Early punch row (350949d)
- `lib/modules/hr/shifts/presentation/pages/shift_form_page.dart` - backend-mode section hiding and Early punch input (350949d)
- `lib/modules/hr/shifts/presentation/pages/shift_list_page.dart` - backend-mode column and mobile-summary hiding (350949d)

## Explicitly NOT approved (must not be carried)

- The route-constant refactor: `lib/app/router/route_segments.dart`, the
  `PlatformRoutes` rewrite in `lib/app/router/platform_routes.dart`,
  `lib/app/router/preview_router.dart`, and the `RouteSegments` rewrites in
  `lib/modules/hr/module/hr_routes.dart`, `lib/modules/services/module/services_routes.dart`,
  and `lib/app/router/app_routes.dart`.
- The `app_calendar.dart` responsive-layout change:
  `lib/design_system/components/specialized/app_calendar.dart`.
- Any new l10n failure copy in `lib/l10n/common/*.arb` (API error mapping must
  reuse existing messages until separately approved).
