import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../auth/domain/entities/auth_context.dart';
import '../../auth/domain/policies/account_role_templates.dart';
import '../domain/employee.dart';
import '../domain/employee_access.dart';

abstract interface class AccountProvisioningRepository {
  Future<String?> provision(
    AuthContext actor,
    EmployeeDraft draft,
    String displayName, {
    String? existingId,
  });
  Future<void> setEnabled(String userId, bool enabled);
}

/// Local account configuration only. New credentials/invitations are intentionally
/// pending; the existing five demo identities retain their auth credentials.
class LocalAccountProvisioningRepository
    implements AccountProvisioningRepository {
  LocalAccountProvisioningRepository(this.db);
  final AppDatabase db;
  @override
  Future<String?> provision(
    AuthContext actor,
    EmployeeDraft draft,
    String displayName, {
    String? existingId,
  }) async {
    if (!draft.loginEnabled) {
      if (existingId != null) await setEnabled(existingId, false);
      return existingId;
    }
    if (!const AccountRolePolicy()
        .available(actor)
        .contains(draft.accountRole)) {
      throw const EmployeeWriteException('accountRole');
    }
    final id = existingId ?? const Uuid().v4();
    final desired = permissionsForRole(draft.accountRole).values;
    if (!desired.every((permission) => grantAllowed(actor, permission))) {
      throw const EmployeeWriteException('accountRole');
    }
    final old = await (db.select(
      db.workforceAccounts,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existingId != null &&
        (old == null || old.companyId != actor.company.id)) {
      throw const EmployeeWriteException('denied');
    }
    final email = old != null && !old.credentialPending
        ? old.email
        : draft.email.trim().toLowerCase();
    final phone = old != null && !old.credentialPending
        ? old.phone
        : normalizeEmployeePhone(draft.phone);
    final duplicate =
        await (db.select(db.workforceAccounts)..where(
              (t) =>
                  t.companyId.equals(actor.company.id) &
                  (t.email.equals(email) | t.phone.equals(phone)) &
                  t.id.equals(id).not(),
            ))
            .get();
    if (duplicate.isNotEmpty) {
      throw EmployeeWriteException(
        duplicate.any((a) => a.email == email)
            ? 'duplicateEmail'
            : 'duplicatePhone',
      );
    }
    await db
        .into(db.workforceAccounts)
        .insertOnConflictUpdate(
          WorkforceAccountsCompanion.insert(
            id: id,
            companyId: actor.company.id,
            displayName: displayName,
            email: old != null && !old.credentialPending
                ? old.email
                : draft.email.trim().toLowerCase(),
            phone: old != null && !old.credentialPending
                ? old.phone
                : normalizeEmployeePhone(draft.phone),
            role: draft.accountRole.name,
            grants: jsonEncode(desired.map((p) => p.name).toList()),
            status:
                (draft.status == EmploymentStatus.active
                        ? AccountStatus.active
                        : AccountStatus.inactive)
                    .name,
            credentialPending: Value(old?.credentialPending ?? true),
          ),
        );
    return id;
  }

  @override
  Future<void> setEnabled(String userId, bool enabled) async {
    await (db.update(
      db.workforceAccounts,
    )..where((t) => t.id.equals(userId))).write(
      WorkforceAccountsCompanion(
        status: Value(
          (enabled ? AccountStatus.active : AccountStatus.inactive).name,
        ),
      ),
    );
  }
}

class EmployeeWriteException implements Exception {
  const EmployeeWriteException(this.code);
  final String code;
}

String normalizeEmployeePhone(String value) =>
    '+${value.replaceAll(RegExp(r'[^0-9]'), '')}';
