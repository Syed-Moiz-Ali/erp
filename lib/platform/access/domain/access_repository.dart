import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';
import 'user_permission_grant.dart';

/// Read model for the Users & Access list. Built from UserAccount +
/// optional linked Employee; never a duplicate access-user entity.
class AccessUserListItem {
  const AccessUserListItem({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.hasLogin,
    required this.accountStatus,
    this.employeeId,
    this.employeeCode,
    this.designationName,
    this.departmentName,
    this.isEmployeeActive = true,
  });
  final String userId, displayName, email;
  final bool hasLogin;
  final String accountStatus;
  final String? employeeId, employeeCode, designationName, departmentName;
  final bool isEmployeeActive;
}

/// Company-scoped access administration repository.
///
/// Local Drift is the source of truth now; the interface stays backend-ready so
/// the editor is never wired directly to a DAO.
abstract interface class AccessRepository {
  Stream<List<AccessUserListItem>> watchUsers({required String companyId});

  Stream<List<UserPermissionGrant>> watchGrants({
    required String companyId,
    required String userId,
  });

  /// All active grants in a company (used for list summaries).
  Stream<List<UserPermissionGrant>> watchCompanyGrants({
    required String companyId,
  });

  Future<Result<List<UserPermissionGrant>>> getGrants({
    required String companyId,
    required String userId,
  });

  Stream<List<BusinessActivityEvent>> watchHistory({
    required String companyId,
    required String userId,
  });

  /// Replaces the user's effective grants atomically (grants + access audit
  /// events + outbox mutation). Idempotent by `requestId`.
  Future<Result<void>> replaceGrants({
    required String companyId,
    required String actorUserId,
    required String targetUserId,
    required String requestId,
    required List<PermissionGrantInput> grants,
  });
}
