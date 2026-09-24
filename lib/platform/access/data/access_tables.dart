import 'package:drift/drift.dart';

/// Company-scoped explicit permission grant. One effective grant per
/// `(companyId, userId, permissionKey)`; scope is a single value per grant.
///
/// Grants are additive: a grant means allowed, absence means not allowed. There
/// are deliberately no deny/priority/inheritance rules.
@DataClassName('UserPermissionGrantRow')
class UserPermissionGrants extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get userId => text()();
  TextColumn get permissionKey => text()();
  TextColumn get scopeKey => text()();
  TextColumn get grantedByUserId => text()();
  DateTimeColumn get grantedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get requestId => text().nullable()();
  TextColumn get syncStatus => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}
