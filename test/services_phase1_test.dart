import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/module_registry/navigation_resolver.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/services/configuration/data/local_service_master_repository.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master.dart';
import 'package:modular_erp/modules/services/customers/data/local_service_customer_repository.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/enquiries/data/local_service_enquiry_repository.dart';
import 'package:modular_erp/modules/services/sites/data/local_service_site_repository.dart';
import 'package:modular_erp/modules/services/sites/domain/service_site.dart';
import 'package:modular_erp/modules/services/teams/data/local_service_team_repository.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_attachment_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_activity_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_document_number_service.dart';

class _MockAuth extends Mock implements AuthRepository {}

class _MockDirectory implements WorkforceDirectory {
  _MockDirectory(this.refs);
  final Map<String, WorkforcePersonRef> refs;
  @override
  Future<WorkforcePersonRef?> getEmployeeReference(
    String employeeId, {
    bool includeInactive = false,
  }) async => refs[employeeId];
  @override
  Future<List<WorkforcePersonRef>> getEmployees(Iterable<String> ids) async => [
    for (final id in ids)
      if (refs[id] != null) refs[id]!,
  ];
  @override
  Future<List<WorkforcePersonRef>> searchAssignable({
    String query = '',
    int limit = 50,
  }) async => refs.values.toList();
  @override
  Stream<List<AssignableEmployeeSummary>> watchAssignableEmployees({
    String query = '',
  }) => Stream.value(const []);
}

AuthContext _context({
  required Set<AppPermission> permissions,
  Set<String> enabledModules = const {
    'employees',
    'attendance',
    'leave',
    'reports',
    'settings',
    'services',
  },
  String companyId = 'c1',
}) => AuthContext(
  user: UserAccount(
    id: 'u1',
    displayName: 'User',
    email: 'u@erp.demo',
    companyId: companyId,
    permissions: PermissionSet(permissions),
    status: AccountStatus.active,
  ),
  company: CompanyContext(
    id: companyId,
    name: 'Company',
    code: 'C',
    timezone: 'UTC',
    defaultLocale: 'en',
    enabledModules: enabledModules,
  ),
);

const _customerPerms = {
  AppPermission.serviceCustomerView,
  AppPermission.serviceCustomerCreate,
  AppPermission.serviceCustomerEdit,
  AppPermission.serviceCustomerDeactivate,
  AppPermission.serviceSiteView,
  AppPermission.serviceSiteCreate,
  AppPermission.serviceSiteEdit,
  AppPermission.serviceSiteDeactivate,
  AppPermission.serviceTeamView,
  AppPermission.serviceTeamManage,
  AppPermission.serviceTypeView,
  AppPermission.serviceTypeManage,
  AppPermission.complaintTypeView,
  AppPermission.complaintTypeManage,
  AppPermission.servicePriorityView,
  AppPermission.servicePriorityManage,
  AppPermission.serviceTicketTypeView,
  AppPermission.serviceTicketTypeManage,
  AppPermission.attendanceViewAll,
};

void main() {
  late AppDatabase db;
  late LocalServiceCustomerRepository customers;
  late LocalServiceSiteRepository sites;
  late LocalServiceTeamRepository teams;
  late LocalServiceMasterRepository masters;
  late LocalServiceEnquiryRepository enquiries;
  const clock = SystemAppClock();

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    final numbers = LocalDocumentNumberService(db, clock);
    final activity = LocalActivityRepository(db);
    customers = LocalServiceCustomerRepository(db, clock, numbers, activity);
    sites = LocalServiceSiteRepository(db, clock, numbers, activity);
    teams = LocalServiceTeamRepository(
      db,
      clock,
      numbers,
      activity,
      _MockDirectory({
        'e1': const WorkforcePersonRef(
          id: 'e1',
          name: 'Ali',
          employeeCode: 'EMP-1',
        ),
        'e2': const WorkforcePersonRef(
          id: 'e2',
          name: 'Sara',
          employeeCode: 'EMP-2',
        ),
      }),
    );
    masters = LocalServiceMasterRepository(db, clock, activity);
    enquiries = LocalServiceEnquiryRepository(
      db,
      clock,
      numbers,
      activity,
      LocalAttachmentRepository(db, clock),
    );
  });
  tearDown(() => db.close());

  group('customer directory', () {
    test('creates with a company-scoped display code', () async {
      final context = _context(permissions: _customerPerms);
      final created = await customers.saveCustomer(
        context,
        const ServiceCustomerDraft(name: 'ABC', mobile: '+971500000001'),
      );
      expect(created, isA<Success<ServiceCustomer>>());
      expect(
        (created as Success<ServiceCustomer>).value.customerCode,
        'CUS-000001',
      );
      final second = await customers.saveCustomer(
        context,
        const ServiceCustomerDraft(name: 'Gulf', mobile: '+971500000002'),
      );
      expect(
        (second as Success<ServiceCustomer>).value.customerCode,
        'CUS-000002',
      );
    });

    test('is company scoped and denies without permission', () async {
      await customers.saveCustomer(
        _context(permissions: _customerPerms),
        const ServiceCustomerDraft(name: 'ABC', mobile: '+971500000001'),
      );
      final other = await customers.getCustomer(
        _context(permissions: _customerPerms, companyId: 'c2'),
        'missing',
      );
      expect(other, isA<Success<ServiceCustomer?>>());
      expect((other as Success<ServiceCustomer?>).value, isNull);

      final denied = await customers.saveCustomer(
        _context(permissions: const {AppPermission.serviceCustomerView}),
        const ServiceCustomerDraft(name: 'X', mobile: '+1'),
      );
      expect(denied, isA<Failed<ServiceCustomer>>());
    });

    test('detects duplicate mobile and supports deactivation', () async {
      final context = _context(permissions: _customerPerms);
      final created =
          (await customers.saveCustomer(
                    context,
                    const ServiceCustomerDraft(
                      name: 'ABC',
                      mobile: '+971500000001',
                    ),
                  )
                  as Success<ServiceCustomer>)
              .value;
      final duplicate = await customers.saveCustomer(
        context,
        const ServiceCustomerDraft(name: 'Other', mobile: '+971500000001'),
      );
      expect(
        (duplicate as Failed<ServiceCustomer>).failure.code,
        'servicesCustomerDuplicateMobile',
      );
      expect(
        await customers.setActive(context, created.id, false),
        isA<Success<void>>(),
      );
      final page = await customers.watchCustomers(context).first;
      expect(
        (page as Success<ServiceCustomerPage>).value.items.single.status,
        ConfigurationStatus.inactive,
      );
    });
  });

  group('service sites', () {
    test('requires a same-company customer', () async {
      final context = _context(permissions: _customerPerms);
      final customer =
          (await customers.saveCustomer(
                    context,
                    const ServiceCustomerDraft(
                      name: 'ABC',
                      mobile: '+971500000001',
                    ),
                  )
                  as Success<ServiceCustomer>)
              .value;
      final site = await sites.saveSite(
        context,
        ServiceSiteDraft(
          customerId: customer.id,
          siteName: 'Tower 1',
          addressLine1: 'Main Rd',
          city: 'Dubai',
        ),
      );
      expect(site, isA<Success<ServiceSite>>());
      expect((site as Success<ServiceSite>).value.siteCode, 'SITE-000001');

      final bad = await sites.saveSite(
        context,
        const ServiceSiteDraft(
          customerId: 'nope',
          siteName: 'X',
          addressLine1: 'Y',
          city: 'Z',
        ),
      );
      expect(
        (bad as Failed<ServiceSite>).failure.code,
        'servicesSiteCustomerRequired',
      );
    });
  });

  group('service teams', () {
    test('replaces membership, auto-adds lead and resolves members', () async {
      final context = _context(permissions: _customerPerms);
      final team = await teams.saveTeam(
        context,
        const ServiceTeamDraft(
          name: 'Electrical',
          leadEmployeeId: 'e1',
          memberIds: ['e2'],
        ),
      );
      expect(team, isA<Success<ServiceTeam>>());
      final id = (team as Success<ServiceTeam>).value.id;
      final members = await teams.watchMembers(context, id).first;
      final views = (members as Success<List<ServiceTeamMemberView>>).value;
      expect(views.map((m) => m.employeeId).toSet(), {'e1', 'e2'});
    });
  });

  group('configuration masters', () {
    test('manage implies view and codes are unique per company', () async {
      final context = _context(permissions: _customerPerms);
      final created = await masters.save(
        ServiceMasterKind.serviceType,
        context,
        const ServiceMasterDraft(code: 'ELEC', name: 'Electrical'),
      );
      expect(created, isA<Success<ServiceMasterRecord>>());
      final duplicate = await masters.save(
        ServiceMasterKind.serviceType,
        context,
        const ServiceMasterDraft(code: 'ELEC', name: 'Electrical 2'),
      );
      expect(
        (duplicate as Failed<ServiceMasterRecord>).failure.code,
        'servicesMasterDuplicateCode',
      );
    });
  });

  group('navigation wiring', () {
    ModuleRegistry registry() => createErpRegistry(
      _MockAuth(),
      serviceCustomerRepository: customers,
      serviceSiteRepository: sites,
      serviceTeamRepository: teams,
      serviceMasterRepository: masters,
      serviceEnquiryRepository: enquiries,
      workforceDirectory: _MockDirectory(const {}),
      activityRepository: LocalActivityRepository(db),
    );

    test('services appears only with a usable Services permission', () {
      final resolver = NavigationResolver(registry());
      final withGrant = resolver.resolve(
        _context(permissions: {AppPermission.serviceCustomerView}).company,
        _context(
          permissions: {AppPermission.serviceCustomerView},
        ).user.permissions,
      );
      expect(withGrant.destinations.map((d) => d.id), contains('services'));
      expect(
        withGrant.destinations.map((d) => d.id),
        contains('services-customers'),
      );

      final noGrant = resolver.resolve(
        _context(permissions: const {}).company,
        _context(permissions: const {}).user.permissions,
      );
      expect(
        noGrant.destinations.map((d) => d.id),
        isNot(contains('services')),
      );
    });

    test('services hidden when the module is disabled', () {
      final resolver = NavigationResolver(registry());
      final context = _context(
        permissions: {AppPermission.serviceCustomerView},
        enabledModules: {'dashboard', 'services-disabled'},
      );
      expect(
        resolver
            .resolve(context.company, context.user.permissions)
            .destinations
            .map((d) => d.id),
        isNot(contains('services')),
      );
    });

    test('navigation groups destinations by business module section', () {
      final resolver = NavigationResolver(registry());
      final context = _context(permissions: _customerPerms);
      final nav = resolver.resolve(context.company, context.user.permissions);
      final sections = nav.sectionsFor(nav.desktop);

      expect(sections.keys, contains(NavigationSection.hr));
      expect(sections.keys, contains(NavigationSection.services));
      expect(
        sections[NavigationSection.services]!.map((d) => d.id),
        containsAll([
          'services',
          'services-customers',
          'services-sites',
          'services-teams',
        ]),
      );
      expect(
        sections[NavigationSection.hr]!.every(
          (d) => d.section == NavigationSection.hr,
        ),
        isTrue,
      );
    });

    test('enquiry routes are permission guarded and cannot be bypassed', () {
      final resolver = NavigationResolver(registry());
      const base = '/app/services/enquiries';

      final viewOnly = _context(
        permissions: {AppPermission.serviceEnquiryView},
      );
      expect(resolver.routeAccess(base, viewOnly), RouteAccess.allowed);
      expect(resolver.routeAccess('$base/abc', viewOnly), RouteAccess.allowed);
      expect(
        resolver.routeAccess('$base/new', viewOnly),
        RouteAccess.unauthorized,
      );
      expect(
        resolver.routeAccess('$base/abc/edit', viewOnly),
        RouteAccess.unauthorized,
      );

      final createOnly = _context(
        permissions: {AppPermission.serviceEnquiryCreate},
      );
      expect(
        resolver.routeAccess('$base/new', createOnly),
        RouteAccess.allowed,
      );
      expect(
        resolver.routeAccess('$base/abc', createOnly),
        RouteAccess.unauthorized,
      );

      final none = _context(permissions: const {});
      expect(resolver.routeAccess(base, none), RouteAccess.unauthorized);

      // The Enquiries destination is visible with view or create only.
      expect(
        resolver
            .resolve(createOnly.company, createOnly.user.permissions)
            .destinations
            .map((d) => d.id),
        contains('services-enquiries'),
      );
    });
  });
}
