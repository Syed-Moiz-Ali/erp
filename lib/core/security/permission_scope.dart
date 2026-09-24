/// Record scope for a permission grant.
///
/// Scopes are additive metadata on top of permission identity: a grant is a
/// `(permissionKey, scope)` pair. Not every permission supports every scope.
enum PermissionScope {
  /// Action permission without record scope (create, manage, configure).
  none,

  /// Records belonging to the user's linked Employee.
  self,

  /// Operational records explicitly assigned to the employee/team (Services).
  assigned,

  /// Records inside a module-resolved organizational/team scope.
  team,

  /// Company-wide records within the active company.
  all,
}
