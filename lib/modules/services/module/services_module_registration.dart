import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/router/app_route_transitions.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
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
import 'package:modular_erp/modules/services/inspections/domain/service_inspection_repository.dart';
import 'package:modular_erp/modules/services/inspections/presentation/bloc/service_inspection_blocs.dart';
import 'package:modular_erp/modules/services/inspections/presentation/pages/service_inspection_detail_page.dart';
import 'package:modular_erp/modules/services/inspections/presentation/pages/service_inspection_form_page.dart';
import 'package:modular_erp/modules/services/inspections/presentation/pages/service_inspection_list_page.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request_repository.dart';
import 'package:modular_erp/modules/services/material_requests/presentation/bloc/service_material_request_blocs.dart';
import 'package:modular_erp/modules/services/material_requests/presentation/pages/service_material_request_detail_page.dart';
import 'package:modular_erp/modules/services/material_requests/presentation/pages/service_material_request_form_page.dart';
import 'package:modular_erp/modules/services/material_requests/presentation/pages/service_material_request_list_page.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution_repository.dart';
import 'package:modular_erp/modules/services/work_executions/presentation/bloc/service_work_execution_blocs.dart';
import 'package:modular_erp/modules/services/work_executions/presentation/pages/service_work_execution_detail_page.dart';
import 'package:modular_erp/modules/services/work_executions/presentation/pages/service_work_execution_form_page.dart';
import 'package:modular_erp/modules/services/work_executions/presentation/pages/service_work_execution_list_page.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow_repository.dart';
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
  ServiceInspectionRepository? inspections,
  ServiceMaterialRequestRepository? materialRequests,
  ServiceWorkExecutionRepository? workExecutions,
  ServiceWorkflowRepository? workflow,
  WorkforceDirectory? workforce,
  ActivityRepository? activity,
  AppDatabase? database,
  AppClock? clock,
  CompanyTimeService? time,
}) {
  if (customers == null || sites == null || teams == null || masters == null) {
    return const [];
  }
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
      ServiceMasterKind.rootCause => (
        'services-root-causes',
        ServicesRoutes.rootCauses,
        ServicesRoutes.rootCauses,
        ServicesRoutes.rootCausesNew,
        ServicesRoutes.rootCause,
      ),
      ServiceMasterKind.chargeResponsibility => (
        'services-charge-responsibilities',
        ServicesRoutes.chargeResponsibilities,
        ServicesRoutes.chargeResponsibilities,
        ServicesRoutes.chargeResponsibilitiesNew,
        ServicesRoutes.chargeResponsibility,
      ),
      ServiceMasterKind.materialRequestPurpose => (
        'services-material-request-purposes',
        ServicesRoutes.materialRequestPurposes,
        ServicesRoutes.materialRequestPurposes,
        ServicesRoutes.materialRequestPurposesNew,
        ServicesRoutes.materialRequestPurpose,
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
                // Read-only detail: a View-only user must never receive an
                // editable Save form. Editing lives on the `/edit` child route
                // which the route guard restricts to Manage.
                return BlocProvider(
                  create: (_) =>
                      ServiceMasterFormCubit(masters, kind, account, masterId)
                        ..init(),
                  child: ServiceMasterFormPage(
                    kind: kind,
                    id: masterId,
                    readOnly: true,
                  ),
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
                      workExecutions: workExecutions,
                      workflow: workflow,
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
                      inspections: inspections,
                      workExecutions: workExecutions,
                      workflow: workflow,
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
        if (inspections != null && workforce != null)
          destination(
            ErpModule(
              id: 'services-inspections',
              moduleId: AppModuleIds.services,
              name: (l) => l.servicesNavInspections,
              icon: Icons.fact_check_outlined,
              selectedIcon: Icons.fact_check,
              route: ServicesRoutes.inspections,
              navigationGroup: NavigationGroup.services,
              order: 3,
              anyPermissions: {
                AppPermission.serviceInspectionViewAssigned,
                AppPermission.serviceInspectionViewTeam,
                AppPermission.serviceInspectionViewAll,
              },
            ),
            (context) {
              final account = context.read<AuthBloc>().state.context!;
              return BlocProvider(
                create: (_) =>
                    ServiceInspectionListCubit(inspections, masters, account)
                      ..start(),
                child: const ServiceInspectionListPage(),
              );
            },
            children: [
              GoRoute(
                path: 'new',
                name: 'services-inspection-new',
                builder: (context, state) {
                  final account = context.read<AuthBloc>().state.context!;
                  final assignmentId =
                      state.uri.queryParameters['assignmentId'];
                  return BlocProvider(
                    create: (_) => ServiceInspectionFormCubit(
                      inspections,
                      masters,
                      account,
                      null,
                      initialJobAssignmentId: assignmentId,
                    )..init(),
                    child: const ServiceInspectionFormPage(),
                  );
                },
              ),
              GoRoute(
                path: ':inspectionId',
                name: 'services-inspection-details',
                builder: (context, state) {
                  final account = context.read<AuthBloc>().state.context!;
                  final inspectionId = state.pathParameters['inspectionId']!;
                  return BlocProvider(
                    create: (_) => ServiceInspectionDetailCubit(
                      inspections,
                      activity!,
                      account,
                      inspectionId,
                    )..start(),
                    child: ServiceInspectionDetailPage(
                      inspectionId: inspectionId,
                      materialRequests: materialRequests,
                      workExecutions: workExecutions,
                      workflow: workflow,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'services-inspection-edit',
                    builder: (context, state) {
                      final account = context.read<AuthBloc>().state.context!;
                      final inspectionId =
                          state.pathParameters['inspectionId']!;
                      return BlocProvider(
                        create: (_) => ServiceInspectionFormCubit(
                          inspections,
                          masters,
                          account,
                          inspectionId,
                        )..init(),
                        child: ServiceInspectionFormPage(
                          inspectionId: inspectionId,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        if (materialRequests != null && workforce != null)
          destination(
            ErpModule(
              id: 'services-material-requests',
              moduleId: AppModuleIds.services,
              name: (l) => l.servicesNavMaterialRequests,
              icon: Icons.request_quote_outlined,
              selectedIcon: Icons.request_quote,
              route: ServicesRoutes.materialRequests,
              navigationGroup: NavigationGroup.services,
              order: 4,
              anyPermissions: {
                AppPermission.serviceMaterialRequestViewAssigned,
                AppPermission.serviceMaterialRequestViewTeam,
                AppPermission.serviceMaterialRequestViewAll,
              },
            ),
            (context) {
              final account = context.read<AuthBloc>().state.context!;
              return BlocProvider(
                create: (_) => ServiceMaterialRequestListCubit(
                  materialRequests,
                  masters,
                  account,
                )..start(),
                child: const ServiceMaterialRequestListPage(),
              );
            },
            children: [
              GoRoute(
                path: 'new',
                name: 'services-material-request-new',
                builder: (context, state) {
                  final account = context.read<AuthBloc>().state.context!;
                  final inspectionId =
                      state.uri.queryParameters['inspectionId'];
                  return BlocProvider(
                    create: (_) => ServiceMaterialRequestFormCubit(
                      materialRequests,
                      masters,
                      account,
                      null,
                      initialInspectionId: inspectionId,
                    )..init(),
                    child: const ServiceMaterialRequestFormPage(),
                  );
                },
              ),
              GoRoute(
                path: ':requestId',
                name: 'services-material-request-details',
                builder: (context, state) {
                  final account = context.read<AuthBloc>().state.context!;
                  final requestId = state.pathParameters['requestId']!;
                  return BlocProvider(
                    create: (_) => ServiceMaterialRequestDetailCubit(
                      materialRequests,
                      activity!,
                      account,
                      requestId,
                    )..start(),
                    child: ServiceMaterialRequestDetailPage(
                      requestId: requestId,
                      workflow: workflow,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'services-material-request-edit',
                    builder: (context, state) {
                      final account = context.read<AuthBloc>().state.context!;
                      final requestId = state.pathParameters['requestId']!;
                      return BlocProvider(
                        create: (_) => ServiceMaterialRequestFormCubit(
                          materialRequests,
                          masters,
                          account,
                          requestId,
                        )..init(),
                        child: ServiceMaterialRequestFormPage(
                          requestId: requestId,
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'print',
                    name: 'services-material-request-print',
                    builder: (context, state) {
                      final account = context.read<AuthBloc>().state.context!;
                      final requestId = state.pathParameters['requestId']!;
                      return BlocProvider(
                        create: (_) => ServiceMaterialRequestDetailCubit(
                          materialRequests,
                          activity!,
                          account,
                          requestId,
                        )..start(),
                        child: ServiceMaterialRequestDetailPage(
                          requestId: requestId,
                          workflow: workflow,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        if (workExecutions != null && workforce != null)
          destination(
            ErpModule(
              id: 'services-work-executions',
              moduleId: AppModuleIds.services,
              name: (l) => l.servicesNavWorkExecution,
              icon: Icons.engineering_outlined,
              selectedIcon: Icons.engineering,
              route: ServicesRoutes.workExecutions,
              navigationGroup: NavigationGroup.services,
              order: 5,
              anyPermissions: {
                AppPermission.serviceWorkExecutionViewAssigned,
                AppPermission.serviceWorkExecutionViewTeam,
                AppPermission.serviceWorkExecutionViewAll,
              },
            ),
            (context) {
              final account = context.read<AuthBloc>().state.context!;
              return BlocProvider(
                create: (_) =>
                    ServiceWorkExecutionListCubit(workExecutions, account)
                      ..start(),
                child: const ServiceWorkExecutionListPage(),
              );
            },
            children: [
              GoRoute(
                path: 'new',
                name: 'services-work-execution-new',
                builder: (context, state) {
                  final account = context.read<AuthBloc>().state.context!;
                  final inspectionId =
                      state.uri.queryParameters['inspectionId'];
                  return BlocProvider(
                    create: (_) => ServiceWorkExecutionFormCubit(
                      workExecutions,
                      account,
                      null,
                      initialInspectionId: inspectionId,
                    )..init(),
                    child: ServiceWorkExecutionFormPage(
                      teamRepository: teams,
                      workforce: workforce,
                    ),
                  );
                },
              ),
              GoRoute(
                path: ':executionId',
                name: 'services-work-execution-details',
                builder: (context, state) {
                  final account = context.read<AuthBloc>().state.context!;
                  final executionId = state.pathParameters['executionId']!;
                  return BlocProvider(
                    create: (_) => ServiceWorkExecutionDetailCubit(
                      workExecutions,
                      activity!,
                      account,
                      executionId,
                    )..start(),
                    child: ServiceWorkExecutionDetailPage(
                      executionId: executionId,
                      workflow: workflow,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'services-work-execution-edit',
                    builder: (context, state) {
                      final account = context.read<AuthBloc>().state.context!;
                      final executionId = state.pathParameters['executionId']!;
                      return BlocProvider(
                        create: (_) => ServiceWorkExecutionFormCubit(
                          workExecutions,
                          account,
                          executionId,
                        )..init(),
                        child: ServiceWorkExecutionFormPage(
                          executionId: executionId,
                          teamRepository: teams,
                          workforce: workforce,
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
            order: 6,
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
            order: 7,
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
            order: 8,
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
            order: 9,
            // Derived from every implemented Services master's View grant so a
            // user with only one master View (including Root Cause or Charge
            // Responsibility) still sees Services Settings. The Settings page
            // itself renders only the master rows the user may view.
            anyPermissions: {
              AppPermission.serviceTypeView,
              AppPermission.complaintTypeView,
              AppPermission.servicePriorityView,
              AppPermission.serviceTicketTypeView,
              AppPermission.serviceRootCauseView,
              AppPermission.serviceChargeResponsibilityView,
              AppPermission.serviceMaterialRequestPurposeView,
            },
          ),
          (_) => const ServiceSettingsPage(),
        ),
        masterDestination(ServiceMasterKind.serviceType),
        masterDestination(ServiceMasterKind.complaintType),
        masterDestination(ServiceMasterKind.priority),
        masterDestination(ServiceMasterKind.ticketType),
        masterDestination(ServiceMasterKind.rootCause),
        masterDestination(ServiceMasterKind.chargeResponsibility),
        masterDestination(ServiceMasterKind.materialRequestPurpose),
      ],
    ),
  ];
}

AppPermission _masterView(ServiceMasterKind kind) => switch (kind) {
  ServiceMasterKind.serviceType => AppPermission.serviceTypeView,
  ServiceMasterKind.complaintType => AppPermission.complaintTypeView,
  ServiceMasterKind.priority => AppPermission.servicePriorityView,
  ServiceMasterKind.ticketType => AppPermission.serviceTicketTypeView,
  ServiceMasterKind.rootCause => AppPermission.serviceRootCauseView,
  ServiceMasterKind.chargeResponsibility =>
    AppPermission.serviceChargeResponsibilityView,
  ServiceMasterKind.materialRequestPurpose =>
    AppPermission.serviceMaterialRequestPurposeView,
};
