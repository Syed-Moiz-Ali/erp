import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_catalog.dart';
import 'package:modular_erp/core/security/permission_definition.dart';
import 'package:modular_erp/core/security/permission_scope.dart';

PermissionDefinition _action(
  String key,
  String submodule,
  String nameKey,
  String descriptionKey,
  int order,
  AppPermission permission,
) => PermissionDefinition(
  key: key,
  moduleId: 'services',
  submoduleId: submodule,
  featureFlag: 'services',
  nameKey: nameKey,
  descriptionKey: descriptionKey,
  order: order,
  permissions: {PermissionScope.none: permission},
);

/// Services module permission contribution. Only Phase 1 functionality
/// (directory, teams, configuration) is defined here; transaction permissions
/// arrive with their phases.
final servicesPermissionModules = <PermissionModule>[
  PermissionModule(
    id: 'services',
    nameKey: 'servicesPermModuleServices',
    order: 20,
    submodules: [
      PermissionSubmodule(
        id: 'customers',
        nameKey: 'servicesPermSubCustomers',
        order: 1,
        definitions: [
          _action(
            'services.customers.view',
            'customers',
            'servicesPermCustomersView',
            'servicesPermCustomersViewDesc',
            1,
            AppPermission.serviceCustomerView,
          ),
          _action(
            'services.customers.create',
            'customers',
            'servicesPermCustomersCreate',
            'servicesPermCustomersCreateDesc',
            2,
            AppPermission.serviceCustomerCreate,
          ),
          _action(
            'services.customers.edit',
            'customers',
            'servicesPermCustomersEdit',
            'servicesPermCustomersEditDesc',
            3,
            AppPermission.serviceCustomerEdit,
          ),
          _action(
            'services.customers.deactivate',
            'customers',
            'servicesPermCustomersDeactivate',
            'servicesPermCustomersDeactivateDesc',
            4,
            AppPermission.serviceCustomerDeactivate,
          ),
        ],
      ),
      PermissionSubmodule(
        id: 'sites',
        nameKey: 'servicesPermSubSites',
        order: 2,
        definitions: [
          _action(
            'services.sites.view',
            'sites',
            'servicesPermSitesView',
            'servicesPermSitesViewDesc',
            1,
            AppPermission.serviceSiteView,
          ),
          _action(
            'services.sites.create',
            'sites',
            'servicesPermSitesCreate',
            'servicesPermSitesCreateDesc',
            2,
            AppPermission.serviceSiteCreate,
          ),
          _action(
            'services.sites.edit',
            'sites',
            'servicesPermSitesEdit',
            'servicesPermSitesEditDesc',
            3,
            AppPermission.serviceSiteEdit,
          ),
          _action(
            'services.sites.deactivate',
            'sites',
            'servicesPermSitesDeactivate',
            'servicesPermSitesDeactivateDesc',
            4,
            AppPermission.serviceSiteDeactivate,
          ),
        ],
      ),
      PermissionSubmodule(
        id: 'teams',
        nameKey: 'servicesPermSubTeams',
        order: 3,
        definitions: [
          _action(
            'services.teams.view',
            'teams',
            'servicesPermTeamsView',
            'servicesPermTeamsViewDesc',
            1,
            AppPermission.serviceTeamView,
          ),
          _action(
            'services.teams.manage',
            'teams',
            'servicesPermTeamsManage',
            'servicesPermTeamsManageDesc',
            2,
            AppPermission.serviceTeamManage,
          ),
        ],
      ),
      PermissionSubmodule(
        id: 'configuration',
        nameKey: 'servicesPermSubConfiguration',
        order: 4,
        definitions: [
          _action(
            'services.serviceTypes.view',
            'configuration',
            'servicesPermServiceTypesView',
            'servicesPermServiceTypesViewDesc',
            1,
            AppPermission.serviceTypeView,
          ),
          _action(
            'services.serviceTypes.manage',
            'configuration',
            'servicesPermServiceTypesManage',
            'servicesPermServiceTypesManageDesc',
            2,
            AppPermission.serviceTypeManage,
          ),
          _action(
            'services.complaintTypes.view',
            'configuration',
            'servicesPermComplaintTypesView',
            'servicesPermComplaintTypesViewDesc',
            3,
            AppPermission.complaintTypeView,
          ),
          _action(
            'services.complaintTypes.manage',
            'configuration',
            'servicesPermComplaintTypesManage',
            'servicesPermComplaintTypesManageDesc',
            4,
            AppPermission.complaintTypeManage,
          ),
          _action(
            'services.priorities.view',
            'configuration',
            'servicesPermPrioritiesView',
            'servicesPermPrioritiesViewDesc',
            5,
            AppPermission.servicePriorityView,
          ),
          _action(
            'services.priorities.manage',
            'configuration',
            'servicesPermPrioritiesManage',
            'servicesPermPrioritiesManageDesc',
            6,
            AppPermission.servicePriorityManage,
          ),
          _action(
            'services.ticketTypes.view',
            'configuration',
            'servicesPermTicketTypesView',
            'servicesPermTicketTypesViewDesc',
            7,
            AppPermission.serviceTicketTypeView,
          ),
          _action(
            'services.ticketTypes.manage',
            'configuration',
            'servicesPermTicketTypesManage',
            'servicesPermTicketTypesManageDesc',
            8,
            AppPermission.serviceTicketTypeManage,
          ),
        ],
      ),
    ],
  ),
];
