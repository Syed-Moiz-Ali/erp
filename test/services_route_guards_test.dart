import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/module_registry/navigation_resolver.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/services/configuration/data/local_service_master_repository.dart';
import 'package:modular_erp/modules/services/customers/data/local_service_customer_repository.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/material_requests/data/local_service_material_request_repository.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/sites/data/local_service_site_repository.dart';
import 'package:modular_erp/modules/services/teams/data/local_service_team_repository.dart';
import 'package:modular_erp/modules/services/work_executions/data/local_service_work_execution_repository.dart';
import 'package:modular_erp/platform/auth/data/repositories/demo_auth_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/data/local_activity_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_attachment_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_document_number_service.dart';
import 'support/memory_session_storage.dart';

class _Directory implements WorkforceDirectory {
  @override
  Future<WorkforcePersonRef?> getEmployeeReference(
    String employeeId, {
    bool includeInactive = false,
  }) async => null;
  @override
  Future<List<WorkforcePersonRef>> getEmployees(Iterable<String> ids) async =>
      const [];
  @override
  Future<List<WorkforcePersonRef>> searchAssignable({
    String query = '',
    int limit = 50,
  }) async => const [];
  @override
  Stream<List<AssignableEmployeeSummary>> watchAssignableEmployees({
    String query = '',
  }) => Stream.value(const []);
}

void main() {
  test('services transaction and master routes enforce action permissions', () {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const clock = SystemAppClock();
    final numbers = LocalDocumentNumberService(db, clock);
    final activity = LocalActivityRepository(db);
    final attachments = LocalAttachmentRepository(db, clock);
    final directory = _Directory();
    final registry = createErpRegistry(
      DemoAuthRepository(MemorySessionStorage()),
      serviceCustomerRepository: LocalServiceCustomerRepository(
        db,
        clock,
        numbers,
        activity,
      ),
      serviceSiteRepository: LocalServiceSiteRepository(
        db,
        clock,
        numbers,
        activity,
      ),
      serviceTeamRepository: LocalServiceTeamRepository(
        db,
        clock,
        numbers,
        activity,
        directory,
      ),
      serviceMasterRepository: LocalServiceMasterRepository(
        db,
        clock,
        activity,
      ),
      serviceMaterialRequestRepository: LocalServiceMaterialRequestRepository(
        db,
        clock,
        numbers,
        activity,
        directory,
        const FixedOffsetCompanyTimeService(),
      ),
      serviceWorkExecutionRepository: LocalServiceWorkExecutionRepository(
        db,
        clock,
        numbers,
        activity,
        attachments,
        directory,
        const FixedOffsetCompanyTimeService(),
      ),
      workforceDirectory: directory,
      activityRepository: activity,
    );

    final resolver = NavigationResolver(registry);
    final base = AuthContext(
      user: UserAccount(
        id: 'u1',
        displayName: 'User',
        email: 'u@erp.demo',
        companyId: 'c1',
        permissions: PermissionSet(const {}),
        status: AccountStatus.active,
      ),
      company: const CompanyContext(
        id: 'c1',
        name: 'Company',
        code: 'C',
        timezone: 'UTC',
        defaultLocale: 'en',
        enabledModules: {'services'},
      ),
    );
    AuthContext withPerms(Set<AppPermission> perms) => base.copyWith(
      user: base.user.copyWith(permissions: PermissionSet(perms)),
    );

    // Material Requests: view can read, only the matching action can mutate.
    final mrView = withPerms({AppPermission.serviceMaterialRequestViewAll});
    expect(
      resolver.routeAccess(ServicesRoutes.materialRequests, mrView),
      RouteAccess.allowed,
    );
    expect(
      resolver.routeAccess(ServicesRoutes.materialRequest('abc'), mrView),
      RouteAccess.allowed,
    );
    expect(
      resolver.routeAccess(ServicesRoutes.materialRequestsNew, mrView),
      RouteAccess.unauthorized,
    );
    expect(
      resolver.routeAccess(ServicesRoutes.materialRequestEdit('abc'), mrView),
      RouteAccess.unauthorized,
    );
    expect(
      resolver.routeAccess(ServicesRoutes.materialRequestPrint('abc'), mrView),
      RouteAccess.unauthorized,
    );
    expect(
      resolver.routeAccess(
        ServicesRoutes.materialRequestsNew,
        withPerms({AppPermission.serviceMaterialRequestCreate}),
      ),
      RouteAccess.allowed,
    );
    expect(
      resolver.routeAccess(
        ServicesRoutes.materialRequestPrint('abc'),
        withPerms({AppPermission.serviceMaterialRequestPrint}),
      ),
      RouteAccess.allowed,
    );

    // Work Executions: perform normalizes to view, but does not grant edit.
    final weView = withPerms({AppPermission.serviceWorkExecutionViewAssigned});
    expect(
      resolver.routeAccess(ServicesRoutes.workExecutions, weView),
      RouteAccess.allowed,
    );
    expect(
      resolver.routeAccess(ServicesRoutes.workExecutionsNew, weView),
      RouteAccess.unauthorized,
    );
    // Perform alone grants no View scope, so the record detail is denied.
    final wePerform = withPerms({AppPermission.serviceWorkExecutionPerform});
    expect(
      resolver.routeAccess(ServicesRoutes.workExecution('abc'), wePerform),
      RouteAccess.unauthorized,
    );
    expect(
      resolver.routeAccess(ServicesRoutes.workExecutionEdit('abc'), wePerform),
      RouteAccess.unauthorized,
    );
    // A real View grant (any scope) plus Perform can open the detail.
    expect(
      resolver.routeAccess(
        ServicesRoutes.workExecution('abc'),
        withPerms({
          AppPermission.serviceWorkExecutionViewAssigned,
          AppPermission.serviceWorkExecutionPerform,
        }),
      ),
      RouteAccess.allowed,
    );

    // Configuration masters: view reads, manage mutates.
    final masterView = withPerms({AppPermission.serviceRootCauseView});
    expect(
      resolver.routeAccess(ServicesRoutes.rootCauses, masterView),
      RouteAccess.allowed,
    );
    expect(
      resolver.routeAccess(ServicesRoutes.rootCausesNew, masterView),
      RouteAccess.unauthorized,
    );
    expect(
      resolver.routeAccess(ServicesRoutes.rootCauseEdit('abc'), masterView),
      RouteAccess.unauthorized,
    );
    final masterManage = withPerms({AppPermission.serviceRootCauseManage});
    expect(
      resolver.routeAccess(ServicesRoutes.rootCausesNew, masterManage),
      RouteAccess.allowed,
    );
    expect(
      resolver.routeAccess(ServicesRoutes.rootCauseEdit('abc'), masterManage),
      RouteAccess.allowed,
    );
  });
}
