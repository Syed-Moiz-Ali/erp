import 'package:modular_erp/core/security/app_permission.dart';

/// Documented safe-restriction strategy for backend-authenticated sessions.
///
/// The supplied MassERP login contract returns identity, branch and coarse
/// `transactionAccess`/`reportAccess` flags but **no permission grant list**.
/// Rather than inventing privileges, a backend session is granted:
///
/// * **no business permissions** — [permissions] is empty, so every
///   permission-gated route/action stays denied until an authoritative grant
///   source (the existing local access layer or a future permission endpoint)
///   provides them; and
/// * **no module enablement** — [enabledModules] is empty because the backend
///   does not expose module flags. Dashboard and Profile are `alwaysAvailable`
///   and remain reachable, so authentication still yields a usable landing.
///
/// This intentionally avoids granting all permissions, assuming an admin role,
/// or reusing demo grants for production users.
abstract final class BackendSessionPolicy {
  const BackendSessionPolicy._();

  /// No business capability is granted from the login contract alone.
  static final PermissionSet permissions = PermissionSet(
    const <AppPermission>[],
  );

  /// Module enablement is unknown to the client; leave it empty.
  static const Set<String> enabledModules = <String>{};

  static const String defaultLocale = 'en';
}
