import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/app/access/erp_access_catalog.dart';
import 'package:modular_erp/app/module_registry/navigation_resolver.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/data/repositories/demo_auth_repository.dart';
import 'support/memory_session_storage.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/platform/access/domain/grant_authority.dart';
import 'package:modular_erp/platform/access/domain/user_permission_grant.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

class _MockAccessRepository extends Mock implements AccessRepository {}

AuthContext _actor({
  String id = 'admin',
  required Set<AppPermission> permissions,
}) => AuthContext(
  user: UserAccount(
    id: id,
    displayName: 'Admin',
    email: 'admin@erp.demo',
    companyId: 'c1',
    role: AppRole.companyAdmin,
    permissions: PermissionSet(permissions),
    status: AccountStatus.active,
  ),
  company: const CompanyContext(
    id: 'c1',
    name: 'Company',
    code: 'C',
    timezone: 'UTC',
    defaultLocale: 'en',
    enabledModules: {'hr'},
  ),
);

void main() {
  const authority = GrantAuthorityResolver();
  final catalog = erpAccessCatalog;
  final leaveView = catalog.byKey('hr.leave.records.view')!;
  final platformCompanies = catalog.byKey('platform.companies.manage')!;
  final attendanceSelf = catalog.byKey('hr.attendance.self.view')!;

  group('grant authority', () {
    test('access management requires the explicit permission', () {
      final without = _actor(permissions: {AppPermission.employeeViewAll});
      expect(authority.canManageAccess(without).allowed, isFalse);
      final withPermission = _actor(
        permissions: {AppPermission.accessPermissionsManage},
      );
      expect(authority.canManageAccess(withPermission).allowed, isTrue);
    });

    test('self-escalation is refused', () {
      final actor = _actor(
        id: 'admin',
        permissions: {AppPermission.accessPermissionsManage},
      );
      final decision = authority.canEditTarget(actor, 'admin');
      expect(decision.allowed, isFalse);
      expect(decision.reason, AccessDecisionReason.selfEscalation);
    });

    test('company administrator cannot grant platform-only permissions', () {
      final companyAdmin = _actor(
        permissions: {
          AppPermission.accessPermissionsManage,
          AppPermission.employeeViewAll,
        },
      );
      final decision = authority.canGrant(
        companyAdmin,
        platformCompanies,
        targetHasEmployeeLink: true,
        moduleEnabled: true,
      );
      expect(decision.allowed, isFalse);
      expect(decision.reason, AccessDecisionReason.platformOnly);
    });

    test('platform administrator can grant platform-only permissions', () {
      final platformAdmin = _actor(
        permissions: {
          AppPermission.accessPermissionsManage,
          AppPermission.platformModulesManage,
        },
      );
      expect(
        authority
            .canGrant(
              platformAdmin,
              platformCompanies,
              targetHasEmployeeLink: false,
              moduleEnabled: true,
            )
            .allowed,
        isTrue,
      );
    });

    test('grant ceiling: cannot delegate beyond own authority', () {
      final limited = _actor(
        permissions: {AppPermission.accessPermissionsManage},
      );
      final decision = authority.canGrant(
        limited,
        leaveView,
        targetHasEmployeeLink: true,
        moduleEnabled: true,
      );
      expect(decision.allowed, isFalse);
      expect(decision.reason, AccessDecisionReason.notPermitted);
    });

    test('employee-link required permissions are refused without a link', () {
      final actor = _actor(
        permissions: {
          AppPermission.accessPermissionsManage,
          AppPermission.attendanceViewSelf,
        },
      );
      final decision = authority.canGrant(
        actor,
        attendanceSelf,
        targetHasEmployeeLink: false,
        moduleEnabled: true,
      );
      expect(decision.allowed, isFalse);
      expect(decision.reason, AccessDecisionReason.employeeLinkRequired);
    });

    test('disabled module grants are refused', () {
      final actor = _actor(
        permissions: {
          AppPermission.accessPermissionsManage,
          AppPermission.leaveViewTeam,
        },
      );
      final decision = authority.canGrant(
        actor,
        leaveView,
        targetHasEmployeeLink: true,
        moduleEnabled: false,
      );
      expect(decision.allowed, isFalse);
      expect(decision.reason, AccessDecisionReason.moduleDisabled);
    });
  });

  group('validateReplacement', () {
    test('last access administrator cannot lose access management', () {
      final actor = _actor(
        id: 'admin',
        permissions: {AppPermission.accessPermissionsManage},
      );
      final result = authority.validateReplacement(
        actor,
        targetUserId: 'someone-else',
        grants: const [
          PermissionGrantInput(
            key: 'hr.employees.view',
            scope: PermissionScope.all,
          ),
        ],
        catalog: catalog,
        enabledModules: const {'employees'},
        targetHasEmployeeLink: true,
        targetIsLastAccessAdmin: true,
      );
      expect(result, isA<Failed<void>>());
      expect((result as Failed<void>).failure.code, 'access.lastAdmin');
    });

    test('unknown keys and unsupported scopes are refused', () {
      final actor = _actor(
        permissions: {
          AppPermission.accessPermissionsManage,
          AppPermission.employeeViewAll,
        },
      );
      final unknown = authority.validateReplacement(
        actor,
        targetUserId: 'u2',
        grants: const [
          PermissionGrantInput(key: 'nope.nope', scope: PermissionScope.all),
        ],
        catalog: catalog,
        enabledModules: const {'employees'},
        targetHasEmployeeLink: true,
        targetIsLastAccessAdmin: false,
      );
      expect(
        (unknown as Failed<void>).failure.code,
        'access.unknownPermission',
      );

      final badScope = authority.validateReplacement(
        actor,
        targetUserId: 'u2',
        grants: const [
          PermissionGrantInput(
            key: 'hr.employees.create',
            scope: PermissionScope.team,
          ),
        ],
        catalog: catalog,
        enabledModules: const {'employees'},
        targetHasEmployeeLink: true,
        targetIsLastAccessAdmin: false,
      );
      expect(
        (badScope as Failed<void>).failure.code,
        'access.unsupportedScope',
      );
    });

    test('a valid replacement succeeds', () {
      final actor = _actor(
        permissions: {
          AppPermission.accessPermissionsManage,
          AppPermission.employeeViewAll,
        },
      );
      final result = authority.validateReplacement(
        actor,
        targetUserId: 'u2',
        grants: const [
          PermissionGrantInput(
            key: 'hr.employees.view',
            scope: PermissionScope.all,
          ),
        ],
        catalog: catalog,
        enabledModules: const {'employees'},
        targetHasEmployeeLink: true,
        targetIsLastAccessAdmin: false,
      );
      expect(result, isA<Success<void>>());
    });
  });

  group('access route guards', () {
    final source = DemoAuthSource();
    late DemoAuthRepository repository;
    late NavigationResolver resolver;
    setUp(() {
      repository = DemoAuthRepository(MemorySessionStorage(), source: source);
      final registry = createErpRegistry(
        repository,
        accessRepository: _MockAccessRepository(),
        accessCatalog: erpAccessCatalog,
        accessAuthority: const GrantAuthorityResolver(),
      );
      resolver = NavigationResolver(registry);
    });
    tearDown(() => repository.dispose());

    AuthContext account(AppRole role) =>
        source.accounts.firstWhere((a) => a.context.user.role == role).context;

    test('direct URL to Users & Access is blocked without permission', () {
      expect(
        resolver.routeAccess(AppRoutes.access, account(AppRole.hr)),
        RouteAccess.unauthorized,
      );
      expect(
        resolver.routeAccess(AppRoutes.modules, account(AppRole.hr)),
        RouteAccess.unauthorized,
      );
    });

    test('platform administrator can reach access administration', () {
      expect(
        resolver.routeAccess(AppRoutes.access, account(AppRole.superAdmin)),
        RouteAccess.allowed,
      );
      expect(
        resolver.routeAccess(AppRoutes.modules, account(AppRole.superAdmin)),
        RouteAccess.allowed,
      );
    });
  });
}
