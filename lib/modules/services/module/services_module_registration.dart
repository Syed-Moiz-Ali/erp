import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/router/app_route_transitions.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master_repository.dart';
import 'package:modular_erp/modules/services/configuration/presentation/bloc/service_master_blocs.dart';
import 'package:modular_erp/modules/services/configuration/presentation/pages/service_master_form_page.dart';
import 'package:modular_erp/modules/services/configuration/presentation/pages/service_master_list_page.dart';
import 'package:modular_erp/modules/services/configuration/presentation/pages/service_settings_page.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer_repository.dart';
import 'package:modular_erp/modules/services/customers/presentation/bloc/service_customer_blocs.dart';
import 'package:modular_erp/modules/services/customers/presentation/pages/service_customer_detail_page.dart';
import 'package:modular_erp/modules/services/customers/presentation/pages/service_customer_form_page.dart';
import 'package:modular_erp/modules/services/customers/presentation/pages/service_customer_list_page.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry_repository.dart';
import 'package:modular_erp/modules/services/enquiries/presentation/bloc/service_enquiry_blocs.dart';
import 'package:modular_erp/modules/services/enquiries/presentation/pages/service_enquiry_detail_page.dart';
import 'package:modular_erp/modules/services/enquiries/presentation/pages/service_enquiry_form_page.dart';
import 'package:modular_erp/modules/services/enquiries/presentation/pages/service_enquiry_list_page.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment_repository.dart';
import 'package:modular_erp/modules/services/job_assignments/presentation/bloc/service_job_assignment_blocs.dart';
import 'package:modular_erp/modules/services/job_assignments/presentation/pages/service_job_assignment_detail_page.dart';
import 'package:modular_erp/modules/services/job_assignments/presentation/pages/service_job_assignment_form_page.dart';
import 'package:modular_erp/modules/services/job_assignments/presentation/pages/service_job_assignment_list_page.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/overview/presentation/bloc/service_overview_cubit.dart';
import 'package:modular_erp/modules/services/overview/presentation/service_overview_page.dart';
import 'package:modular_erp/modules/services/sites/domain/service_site_repository.dart';
import 'package:modular_erp/modules/services/sites/presentation/bloc/service_site_blocs.dart';
import 'package:modular_erp/modules/services/sites/presentation/pages/service_site_detail_page.dart';
import 'package:modular_erp/modules/services/sites/presentation/pages/service_site_form_page.dart';
import 'package:modular_erp/modules/services/sites/presentation/pages/service_site_list_page.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team_repository.dart';
import 'package:modular_erp/modules/services/teams/presentation/bloc/service_team_blocs.dart';
import 'package:modular_erp/modules/services/teams/presentation/pages/service_team_detail_page.dart';
import 'package:modular_erp/modules/services/teams/presentation/pages/service_team_form_page.dart';
import 'package:modular_erp/modules/services/teams/presentation/pages/service_team_list_page.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';

/// Services module destination composition (Overview, Customers, Sites, Teams
/// and Configuration). Returns an empty list when the data layer is unavailable
/// so the module simply does not register.
List<AppModule> buildServicesModules({
  ServiceCustomerRepository? customers,
  ServiceSiteRepository? sites,
  ServiceTeamRepository? teams,
  ServiceMasterRepository? masters,
  ServiceEnquiryRepository? enquiries,
  ServiceJobAssignmentRepository? jobAssignments,
  WorkforceDirectory? workforce,
  ActivityRepository? activity,
}) {
  if (customers == null || sites == null || teams == null || masters == null) {
    return const [];
  }
  final allViewPermissions = {
    AppPermission.serviceCustomerView,
    AppPermission.serviceSiteView,
    AppPermission.serviceTeamView,
    AppPermission.serviceTypeView,
    AppPermission.complaintTypeView,
    AppPermission.servicePriorityView,
    AppPermission.serviceTicketTypeView,
  };
  RegisteredDestination destination(
    ErpModule navigation,
    WidgetBuilder builder, {
    List<RouteBase> children = const [],
  }) => RegisteredDestination(
    navigation: navigation,
    routes: [
      GoRoute(
        path: navigation.route,
        name: navigation.id,
        pageBuilder: (context, state) =>
            AppRouteTransitions.page(context, state, builder(context)),
        routes: children,
      ),
    ],
  );

  RegisteredDestination masterDestination(ServiceMasterKind kind) {
    final (id, route, listRoute, newRoute, detailsRoute) = switch (kind) {
      ServiceMasterKind.serviceType => (
        'services-service-types',
        ServicesRoutes.serviceTypes,
        ServicesRoutes.serviceTypes,
        ServicesRoutes.serviceTypesNew,
        ServicesRoutes.serviceType,
      ),
      ServiceMasterKind.complaintType => (
        'services-complaint-types',
        ServicesRoutes.complaintTypes,
        ServicesRoutes.complaintTypes,
        ServicesRoutes.complaintTypesNew,
        ServicesRoutes.complaintType,
      ),
      ServiceMasterKind.priority => (
        'services-priorities',
        ServicesRoutes.priorities,
        ServicesRoutes.priorities,
        ServicesRoutes.prioritiesNew,
        ServicesRoutes.priority,
      ),
      ServiceMasterKind.ticketType => (
        'services-ticket-types',
        ServicesRoutes.ticketTypes,
        ServicesRoutes.ticketTypes,
        ServicesRoutes.ticketTypesNew,
        ServicesRoutes.ticketType,
      ),
    };
    return RegisteredDestination(
      navigation: ErpModule(
        id: id,
        moduleId: AppModuleIds.services,
        name: (l) => serviceMasterTitle(l, kind),
        icon: Icons.tune_outlined,
        route: route,
        navigationGroup: NavigationGroup.services,
        order: 20,
        desktopVisible: false,
        mobileVisible: false,
        anyPermissions: {_masterView(kind)},
      ),
      routes: [
        GoRoute(
          path: listRoute,
          name: id,
          builder: (context, state) {
            final account = context.read<AuthBloc>().state.context!;
            return BlocProvider(
              create: (_) =>
                  ServiceMasterListCubit(masters, kind, account)..start(),
              child: ServiceMasterListPage(kind: kind),
            );
          },
          routes: [
            GoRoute(
              path: 'new',
              name: '$id-new',
              builder: (context, state) {
                final account = context.read<AuthBloc>().state.context!;
                return BlocProvider(
                  create: (_) =>
                      ServiceMasterFormCubit(masters, kind, account, null)
                        ..init(),
                  child: ServiceMasterFormPage(kind: kind),
                );
              },
            ),
            GoRoute(
              path: ':id',
              name: '$id-details',
              builder: (context, state) {
                final account = context.read<AuthBloc>().state.context!;
                final masterId = state.pathParameters['id']!;
                return BlocProvider(
                  create: (_) =>
                      ServiceMasterFormCubit(masters, kind, account, masterId)
                        ..init(),
                  child: ServiceMasterFormPage(kind: kind, id: masterId),
                );
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  name: '$id-edit',
                  builder: (context, state) {
                    final account = context.read<AuthBloc>().state.context!;
                    final masterId = state.pathParameters['id']!;
                    return BlocProvider(
                      create: (_) => ServiceMasterFormCubit(
                        masters,
                        kind,
                        account,
                        masterId,
                      )..init(),
                      child: ServiceMasterFormPage(kind: kind, id: masterId),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  return [
    AppModule(
      id: AppModuleIds.services,
      destinations: [
        destination(
          ErpModule(
            id: 'services',
            moduleId: AppModuleIds.services,
            name: (l) => l.servicesPermModuleServices,
            icon: Icons.handyman_outlined,
            selectedIcon: Icons.handyman,
            route: ServicesRoutes.root,
            navigationGroup: NavigationGroup.services,
            order: 0,
            anyPermissions: allViewPermissions,
          ),
          (context) {
            final account = context.read<AuthBloc>().state.context!;
            return BlocProvider(
              create: (_) => ServiceOverviewCubit(
                customers,
                sites,
                teams,
                masters,
                account,
                enquiries: enquiries,
                jobAssignments: jobAssignments,
              )..load(),
              child: const ServiceOverviewPage(),
            );
          },
        ),
        if (enquiries != null && activity != null)
          destination(
            ErpModule(
              id: 'services-enquiries',
              moduleId: AppModuleIds.services,
              name: (l) => l.servicesNavEnquiries,
              icon: Icons.support_agent_outlined,
              selectedIcon: Icons.support_agent,
              route: ServicesRoutes.enquiries,
              navigationGroup: NavigationGroup.services,
              order: 1,
              anyPermissions: {
                AppPermission.serviceEnquiryView,
                AppPermission.serviceEnquiryCreate,
              },
            ),
            (context) {
              final account = context.read<AuthBloc>().state.context!;
              return BlocProvider(
                create: (_) =>
                    ServiceEnquiryListCubit(enquiries, masters, account)
                      ..start(),
                child: const ServiceEnquiryListPage(),
              );
            },
            children: [
              GoRoute(
                path: 'new',
                name: 'services-enquiry-new',
                builder: (context, state) {
                  final account = context.read<AuthBloc>().state.context!;
                  return BlocProvider(
                    create: (_) => ServiceEnquiryFormCubit(
                      enquiries,
                      masters,
                      account,
                      null,
                    )..init(),
                    child: const ServiceEnquiryFormPage(),
                  );
                },
              ),
              GoRoute(
                path: ':enquiryId',
                name: 'services-enquiry-details',
                builder: (context, state) {
                  final account = context.read<AuthBloc>().state.context!;
                  final enquiryId = state.pathParameters['enquiryId']!;
                  return BlocProvider(
                    create: (_) => ServiceEnquiryDetailCubit(
                      enquiries,
                      activity,
                      account,
                      enquiryId,
                    )..start(),
                    child: ServiceEnquiryDetailPage(
                      enquiryId: enquiryId,
                      jobAssignments: jobAssignments,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'services-enquiry-edit',
                    builder: (context, state) {
                      final account = context.read<AuthBloc>().state.context!;
                      final enquiryId = state.pathParameters['enquiryId']!;
                      return BlocProvider(
                        create: (_) => ServiceEnquiryFormCubit(
                          enquiries,
                          masters,
                          account,
                          enquiryId,
                        )..init(),
                        child: ServiceEnquiryFormPage(enquiryId: enquiryId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        if (jobAssignments != null && workforce != null)
          destination(
            ErpModule(
              id: 'services-job-assignments',
              moduleId: AppModuleIds.services,
              name: (l) => l.servicesNavJobAssignments,
              icon: Icons.assignment_ind_outlined,
              selectedIcon: Icons.assignment_ind,
              route: ServicesRoutes.assignments,
              navigationGroup: NavigationGroup.services,
              order: 2,
              anyPermissions: {
                AppPermission.serviceJobAssignmentViewAssigned,
                AppPermission.serviceJobAssignmentViewTeam,
                AppPermission.serviceJobAssignmentViewAll,
                AppPermission.serviceJobAssignmentCreate,
              },
            ),
            (context) {
              final account = context.read<AuthBloc>().state.context!;
              return BlocProvider(
                create: (_) => ServiceJobAssignmentListCubit(
                  jobAssignments,
                  masters,
                  account,
                )..start(),
                child: const ServiceJobAssignmentListPage(),
              );
            },
            children: [
              GoRoute(
                path: 'new',
                name: 'services-job-assignment-new',
                builder: (context, state) {
                  final account = context.read<AuthBloc>().state.context!;
                  final enquiryId = state.uri.queryParameters['enquiryId'];
                  return BlocProvider(
                    create: (_) => ServiceJobAssignmentFormCubit(
                      jobAssignments,
                      workforce,
                      teams,
                      account,
                      null,
                      initialEnquiryId: enquiryId,
                    )..init(),
                    child: const ServiceJobAssignmentFormPage(),
                  );
                },
              ),
              GoRoute(
                path: ':assignmentId',
                name: 'services-job-assignment-details',
                builder: (context, state) {
                  final account = context.read<AuthBloc>().state.context!;
                  final assignmentId = state.pathParameters['assignmentId']!;
                  return BlocProvider(
                    create: (_) => ServiceJobAssignmentDetailCubit(
                      jobAssignments,
                      activity!,
                      account,
                      assignmentId,
                    )..start(),
                    child: ServiceJobAssignmentDetailPage(
                      assignmentId: assignmentId,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'services-job-assignment-edit',
                    builder: (context, state) {
                      final account = context.read<AuthBloc>().state.context!;
                      final assignmentId =
                          state.pathParameters['assignmentId']!;
                      return BlocProvider(
                        create: (_) => ServiceJobAssignmentFormCubit(
                          jobAssignments,
                          workforce,
                          teams,
                          account,
                          assignmentId,
                        )..init(),
                        child: ServiceJobAssignmentFormPage(
                          assignmentId: assignmentId,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        destination(
          ErpModule(
            id: 'services-customers',
            moduleId: AppModuleIds.services,
            name: (l) => l.servicesNavCustomers,
            icon: Icons.business_outlined,
            route: ServicesRoutes.customers,
            navigationGroup: NavigationGroup.services,
            order: 3,
            requiredPermissions: {AppPermission.serviceCustomerView},
          ),
          (context) {
            final account = context.read<AuthBloc>().state.context!;
            return BlocProvider(
              create: (_) =>
                  ServiceCustomerListCubit(customers, account)..start(),
              child: const ServiceCustomerListPage(),
            );
          },
          children: [
            GoRoute(
              path: 'new',
              name: 'services-customer-new',
              builder: (context, state) {
                final account = context.read<AuthBloc>().state.context!;
                return BlocProvider(
                  create: (_) =>
                      ServiceCustomerFormCubit(customers, account, null)
                        ..init(),
                  child: ServiceCustomerFormPage(
                    returnSelection: state.uri.queryParameters['select'] == '1',
                  ),
                );
              },
            ),
            GoRoute(
              path: ':customerId',
              name: 'services-customer-details',
              builder: (context, state) {
                final account = context.read<AuthBloc>().state.context!;
                final customerId = state.pathParameters['customerId']!;
                return BlocProvider(
                  create: (_) => ServiceCustomerDetailCubit(
                    customers,
                    sites,
                    activity!,
                    account,
                    customerId,
                  )..start(),
                  child: ServiceCustomerDetailPage(
                    customerId: customerId,
                    enquiries: enquiries,
                  ),
                );
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  name: 'services-customer-edit',
                  builder: (context, state) {
                    final account = context.read<AuthBloc>().state.context!;
                    final customerId = state.pathParameters['customerId']!;
                    return BlocProvider(
                      create: (_) => ServiceCustomerFormCubit(
                        customers,
                        account,
                        customerId,
                      )..init(),
                      child: ServiceCustomerFormPage(customerId: customerId),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        destination(
          ErpModule(
            id: 'services-sites',
            moduleId: AppModuleIds.services,
            name: (l) => l.servicesNavSites,
            icon: Icons.location_on_outlined,
            route: ServicesRoutes.sites,
            navigationGroup: NavigationGroup.services,
            order: 4,
            requiredPermissions: {AppPermission.serviceSiteView},
          ),
          (context) {
            final account = context.read<AuthBloc>().state.context!;
            return BlocProvider(
              create: (_) => ServiceSiteListCubit(sites, account)..start(),
              child: const ServiceSiteListPage(),
            );
          },
          children: [
            GoRoute(
              path: 'new',
              name: 'services-site-new',
              builder: (context, state) {
                final account = context.read<AuthBloc>().state.context!;
                final customerId = state.uri.queryParameters['customerId'];
                return BlocProvider(
                  create: (_) => ServiceSiteFormCubit(
                    sites,
                    customers,
                    account,
                    null,
                    preselectedCustomerId: customerId,
                  )..init(),
                  child: ServiceSiteFormPage(
                    preselectedCustomerId: customerId,
                    returnSelection: state.uri.queryParameters['select'] == '1',
                  ),
                );
              },
            ),
            GoRoute(
              path: ':siteId',
              name: 'services-site-details',
              builder: (context, state) {
                final account = context.read<AuthBloc>().state.context!;
                final siteId = state.pathParameters['siteId']!;
                return BlocProvider(
                  create: (_) =>
                      ServiceSiteDetailCubit(sites, customers, account, siteId)
                        ..start(),
                  child: ServiceSiteDetailPage(
                    siteId: siteId,
                    enquiries: enquiries,
                  ),
                );
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  name: 'services-site-edit',
                  builder: (context, state) {
                    final account = context.read<AuthBloc>().state.context!;
                    final siteId = state.pathParameters['siteId']!;
                    return BlocProvider(
                      create: (_) => ServiceSiteFormCubit(
                        sites,
                        customers,
                        account,
                        siteId,
                      )..init(),
                      child: ServiceSiteFormPage(siteId: siteId),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        destination(
          ErpModule(
            id: 'services-teams',
            moduleId: AppModuleIds.services,
            name: (l) => l.servicesNavTeams,
            icon: Icons.groups_outlined,
            route: ServicesRoutes.teams,
            navigationGroup: NavigationGroup.services,
            order: 5,
            requiredPermissions: {AppPermission.serviceTeamView},
          ),
          (context) {
            final account = context.read<AuthBloc>().state.context!;
            return BlocProvider(
              create: (_) => ServiceTeamListCubit(teams, account)..start(),
              child: const ServiceTeamListPage(),
            );
          },
          children: [
            GoRoute(
              path: 'new',
              name: 'services-team-new',
              builder: (context, state) {
                final account = context.read<AuthBloc>().state.context!;
                return BlocProvider(
                  create: (_) =>
                      ServiceTeamFormCubit(teams, workforce!, account, null)
                        ..init(),
                  child: const ServiceTeamFormPage(),
                );
              },
            ),
            GoRoute(
              path: ':teamId',
              name: 'services-team-details',
              builder: (context, state) {
                final account = context.read<AuthBloc>().state.context!;
                final teamId = state.pathParameters['teamId']!;
                return BlocProvider(
                  create: (_) =>
                      ServiceTeamDetailCubit(teams, account, teamId)..start(),
                  child: ServiceTeamDetailPage(teamId: teamId),
                );
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  name: 'services-team-edit',
                  builder: (context, state) {
                    final account = context.read<AuthBloc>().state.context!;
                    final teamId = state.pathParameters['teamId']!;
                    return BlocProvider(
                      create: (_) => ServiceTeamFormCubit(
                        teams,
                        workforce!,
                        account,
                        teamId,
                      )..init(),
                      child: ServiceTeamFormPage(teamId: teamId),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        destination(
          ErpModule(
            id: 'services-settings',
            moduleId: AppModuleIds.services,
            name: (l) => l.servicesNavSettings,
            icon: Icons.settings_outlined,
            route: ServicesRoutes.settings,
            navigationGroup: NavigationGroup.services,
            order: 6,
            anyPermissions: {
              AppPermission.serviceTypeView,
              AppPermission.complaintTypeView,
              AppPermission.servicePriorityView,
              AppPermission.serviceTicketTypeView,
            },
          ),
          (_) => const ServiceSettingsPage(),
        ),
        masterDestination(ServiceMasterKind.serviceType),
        masterDestination(ServiceMasterKind.complaintType),
        masterDestination(ServiceMasterKind.priority),
        masterDestination(ServiceMasterKind.ticketType),
      ],
    ),
  ];
}

AppPermission _masterView(ServiceMasterKind kind) => switch (kind) {
  ServiceMasterKind.serviceType => AppPermission.serviceTypeView,
  ServiceMasterKind.complaintType => AppPermission.complaintTypeView,
  ServiceMasterKind.priority => AppPermission.servicePriorityView,
  ServiceMasterKind.ticketType => AppPermission.serviceTicketTypeView,
};
