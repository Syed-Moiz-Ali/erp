/// Shared route path segments and composition helpers.
///
/// Module route classes compose their paths from these names instead of
/// repeating string fragments, so a shared segment or action exists exactly
/// once. Resource-specific segments stay with their owning module.
abstract final class RouteSegments {
  const RouteSegments._();

  /// First segment of every authenticated route (`/app`).
  static const app = 'app';

  /// Shared collection-record actions.
  static const newRecord = 'new';
  static const edit = 'edit';
  static const print = 'print';
  static const import = 'import';

  /// `base/new`
  static String newPath(String base) => '$base/$newRecord';

  /// `base/edit`
  static String editPath(String base) => '$base/$edit';

  /// `base/print`
  static String printPath(String base) => '$base/$print';

  /// `base/import`
  static String importPath(String base) => '$base/$import';

  /// `base/<url-encoded id>`
  static String byId(String base, Object id) =>
      '$base/${Uri.encodeComponent('$id')}';

  /// `base/<url-encoded id>/edit`
  static String byIdEdit(String base, Object id) => editPath(byId(base, id));
}
