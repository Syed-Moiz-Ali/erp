import 'package:modular_erp/platform/access/data/access_user_directory.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';

import 'demo_auth_source.dart';

/// Test-only directory backed by the in-memory demo accounts. Read model only;
/// it never duplicates employee data.
class DemoAccessUserDirectory implements AccessUserDirectory {
  const DemoAccessUserDirectory(this.source);
  final DemoAuthSource source;

  @override
  Stream<List<AccessUserListItem>> watchUsers({required String companyId}) =>
      Stream.value([
        for (final account in source.accounts)
          if (account.context.company.id == companyId)
            AccessUserListItem(
              userId: account.context.user.id,
              displayName: account.context.user.displayName,
              email: account.context.user.loginId,
              hasLogin: true,
              accountStatus: account.context.user.status.name,
              employeeId: account.context.employeeReference?.id,
            ),
      ]);
}
