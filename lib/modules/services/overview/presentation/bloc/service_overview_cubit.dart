import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master_repository.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer_repository.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry_repository.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment_repository.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection_repository.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request_repository.dart';
import 'package:modular_erp/modules/services/sites/domain/service_site.dart';
import 'package:modular_erp/modules/services/sites/domain/service_site_repository.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team_repository.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution_repository.dart';

/// Permission/scope-aware "My Work" projection for a linked field employee.
///
/// Built from the same authoritative list queries used elsewhere (ASSIGNED
/// scope), so it never becomes a second source of truth.
class ServiceMyWork {
  const ServiceMyWork({
    this.assignments = const [],
    this.inspections = const [],
    this.executions = const [],
    this.assignmentCount = 0,
    this.inspectionCount = 0,
    this.executionCount = 0,
  });
  final List<ServiceJobAssignmentListItem> assignments;
  final List<ServiceInspectionListItem> inspections;
  final List<ServiceWorkExecutionListItem> executions;
  final int assignmentCount, inspectionCount, executionCount;

  bool get isEmpty =>
      assignments.isEmpty && inspections.isEmpty && executions.isEmpty;
}

class ServiceOverviewState {
  const ServiceOverviewState({
    this.loading = true,
    this.customers,
    this.activeSites,
    this.teams,
    this.serviceTypes,
    this.priorities,
    this.enquirySummary,
    this.recentEnquiries = const [],
    this.assignmentSummary,
    this.upcomingAssignments = const [],
    this.inspectionSummary,
    this.recentInspections = const [],
    this.materialRequestSummary,
    this.recentMaterialRequests = const [],
    this.workExecutionSummary,
    this.recentWorkExecutions = const [],
    this.myWork,
    this.failure,
  });
  final bool loading;
  final int? customers, activeSites, teams, serviceTypes, priorities;
  final ServiceEnquirySummary? enquirySummary;
  final List<ServiceEnquiryListItem> recentEnquiries;
  final ServiceJobAssignmentSummary? assignmentSummary;
  final List<ServiceJobAssignmentListItem> upcomingAssignments;
  final ServiceInspectionSummary? inspectionSummary;
  final List<ServiceInspectionListItem> recentInspections;
  final ServiceMaterialRequestSummary? materialRequestSummary;
  final List<ServiceMaterialRequestListItem> recentMaterialRequests;
  final ServiceWorkExecutionSummary? workExecutionSummary;
  final List<ServiceWorkExecutionListItem> recentWorkExecutions;
  final ServiceMyWork? myWork;
  final String? failure;
}

class ServiceOverviewCubit extends Cubit<ServiceOverviewState> {
  ServiceOverviewCubit(
    this.customers,
    this.sites,
    this.teams,
    this.masters,
    this.context, {
    ServiceEnquiryRepository? enquiries,
    ServiceJobAssignmentRepository? jobAssignments,
    ServiceInspectionRepository? inspections,
    ServiceMaterialRequestRepository? materialRequests,
    ServiceWorkExecutionRepository? workExecutions,
  }) : _enquiries = enquiries,
       _jobAssignments = jobAssignments,
       _inspections = inspections,
       _materialRequests = materialRequests,
       _workExecutions = workExecutions,
       super(const ServiceOverviewState());
  final ServiceCustomerRepository customers;
  final ServiceSiteRepository sites;
  final ServiceTeamRepository teams;
  final ServiceMasterRepository masters;
  final ServiceEnquiryRepository? _enquiries;
  final ServiceJobAssignmentRepository? _jobAssignments;
  final ServiceInspectionRepository? _inspections;
  final ServiceMaterialRequestRepository? _materialRequests;
  final ServiceWorkExecutionRepository? _workExecutions;
  final AuthContext context;

  bool _can(AppPermission permission) =>
      context.user.permissions.contains(permission);

  Future<void> load() async {
    emit(const ServiceOverviewState());
    int? customerTotal, siteTotal, teamTotal, typeTotal, priorityTotal;
    ServiceEnquirySummary? summary;
    var recent = const <ServiceEnquiryListItem>[];
    if (_can(AppPermission.serviceCustomerView)) {
      final r = await customers.watchCustomers(context, pageSize: 1).first;
      if (r case Success<ServiceCustomerPage>(:final value)) {
        customerTotal = value.total;
      }
    }
    if (_can(AppPermission.serviceSiteView)) {
      final r = await sites
          .watchSites(context, status: ConfigurationStatus.active, pageSize: 1)
          .first;
      if (r case Success<ServiceSitePage>(:final value)) {
        siteTotal = value.total;
      }
    }
    if (_can(AppPermission.serviceTeamView)) {
      final r = await teams.watchTeams(context, pageSize: 1).first;
      if (r case Success<ServiceTeamPage>(:final value)) {
        teamTotal = value.total;
      }
    }
    if (_can(AppPermission.serviceTypeView)) {
      final r = await masters
          .watchList(ServiceMasterKind.serviceType, context, pageSize: 1)
          .first;
      if (r case Success<ServiceMasterPage>(:final value)) {
        typeTotal = value.total;
      }
    }
    if (_can(AppPermission.servicePriorityView)) {
      final r = await masters
          .watchList(ServiceMasterKind.priority, context, pageSize: 1)
          .first;
      if (r case Success<ServiceMasterPage>(:final value)) {
        priorityTotal = value.total;
      }
    }
    final enquiries = _enquiries;
    if (enquiries != null && _can(AppPermission.serviceEnquiryView)) {
      final r = await enquiries.summary(context);
      if (r case Success<ServiceEnquirySummary>(:final value)) {
        summary = value;
      }
      final recentResult = await enquiries
          .watchRecentEnquiries(context, limit: 5)
          .first;
      if (recentResult case Success<List<ServiceEnquiryListItem>>(
        :final value,
      )) {
        recent = value;
      }
    }
    ServiceJobAssignmentSummary? assignmentSummary;
    var upcoming = const <ServiceJobAssignmentListItem>[];
    final jobAssignments = _jobAssignments;
    if (jobAssignments != null &&
        _canAny([
          AppPermission.serviceJobAssignmentViewAssigned,
          AppPermission.serviceJobAssignmentViewTeam,
          AppPermission.serviceJobAssignmentViewAll,
        ])) {
      final r = await jobAssignments.summary(context);
      if (r case Success<ServiceJobAssignmentSummary>(:final value)) {
        assignmentSummary = value;
      }
      final upcomingResult = await jobAssignments
          .watchUpcomingAssignments(context, limit: 5)
          .first;
      if (upcomingResult case Success<List<ServiceJobAssignmentListItem>>(
        :final value,
      )) {
        upcoming = value;
      }
    }
    ServiceInspectionSummary? inspectionSummary;
    var recentInspections = const <ServiceInspectionListItem>[];
    final inspections = _inspections;
    if (inspections != null &&
        _canAny([
          AppPermission.serviceInspectionViewAssigned,
          AppPermission.serviceInspectionViewTeam,
          AppPermission.serviceInspectionViewAll,
        ])) {
      final r = await inspections.summary(context);
      if (r case Success<ServiceInspectionSummary>(:final value)) {
        inspectionSummary = value;
      }
      final recentResult = await inspections
          .watchRecentInspections(context, limit: 5)
          .first;
      if (recentResult case Success<List<ServiceInspectionListItem>>(
        :final value,
      )) {
        recentInspections = value;
      }
    }
    ServiceMaterialRequestSummary? materialRequestSummary;
    var recentMaterialRequests = const <ServiceMaterialRequestListItem>[];
    final materialRequests = _materialRequests;
    if (materialRequests != null &&
        _canAny([
          AppPermission.serviceMaterialRequestViewAssigned,
          AppPermission.serviceMaterialRequestViewTeam,
          AppPermission.serviceMaterialRequestViewAll,
        ])) {
      final r = await materialRequests.summary(context);
      if (r case Success<ServiceMaterialRequestSummary>(:final value)) {
        materialRequestSummary = value;
      }
      final recentResult = await materialRequests
          .watchRecentRequests(context, limit: 5)
          .first;
      if (recentResult case Success<List<ServiceMaterialRequestListItem>>(
        :final value,
      )) {
        recentMaterialRequests = value;
      }
    }
    ServiceWorkExecutionSummary? workExecutionSummary;
    var recentWorkExecutions = const <ServiceWorkExecutionListItem>[];
    final workExecutions = _workExecutions;
    if (workExecutions != null &&
        _canAny([
          AppPermission.serviceWorkExecutionViewAssigned,
          AppPermission.serviceWorkExecutionViewTeam,
          AppPermission.serviceWorkExecutionViewAll,
        ])) {
      final r = await workExecutions.summary(context);
      if (r case Success<ServiceWorkExecutionSummary>(:final value)) {
        workExecutionSummary = value;
      }
      final recentResult = await workExecutions
          .watchRecentExecutions(context, limit: 5)
          .first;
      if (recentResult case Success<List<ServiceWorkExecutionListItem>>(
        :final value,
      )) {
        recentWorkExecutions = value;
      }
    }
    final myWork = await _loadMyWork();
    emit(
      ServiceOverviewState(
        loading: false,
        customers: customerTotal,
        activeSites: siteTotal,
        teams: teamTotal,
        serviceTypes: typeTotal,
        priorities: priorityTotal,
        enquirySummary: summary,
        recentEnquiries: recent,
        assignmentSummary: assignmentSummary,
        upcomingAssignments: upcoming,
        inspectionSummary: inspectionSummary,
        recentInspections: recentInspections,
        materialRequestSummary: materialRequestSummary,
        recentMaterialRequests: recentMaterialRequests,
        workExecutionSummary: workExecutionSummary,
        recentWorkExecutions: recentWorkExecutions,
        myWork: myWork,
      ),
    );
  }

  /// "My Work" uses ASSIGNED scope: the linked employee's own assignments,
  /// pending inspections and active work executions (Phase 7 §29).
  Future<ServiceMyWork?> _loadMyWork() async {
    final employeeId = context.employeeReference?.id;
    if (employeeId == null) return null;
    var assignments = const <ServiceJobAssignmentListItem>[];
    var assignmentCount = 0;
    var inspections = const <ServiceInspectionListItem>[];
    var inspectionCount = 0;
    var executions = const <ServiceWorkExecutionListItem>[];
    var executionCount = 0;

    final jobAssignments = _jobAssignments;
    if (jobAssignments != null &&
        _canAny([
          AppPermission.serviceJobAssignmentViewAssigned,
          AppPermission.serviceJobAssignmentViewTeam,
          AppPermission.serviceJobAssignmentViewAll,
        ])) {
      final result = await jobAssignments
          .watchAssignments(
            context,
            employeeId: employeeId,
            status: ServiceJobAssignmentStatus.active,
            pageSize: 5,
          )
          .first;
      if (result case Success<ServiceJobAssignmentPage>(:final value)) {
        assignments = value.items;
        assignmentCount = value.filtered;
      }
    }
    final inspectionsRepo = _inspections;
    if (inspectionsRepo != null &&
        _canAny([
          AppPermission.serviceInspectionViewAssigned,
          AppPermission.serviceInspectionViewTeam,
          AppPermission.serviceInspectionViewAll,
        ])) {
      final result = await inspectionsRepo
          .watchInspections(
            context,
            technicianEmployeeId: employeeId,
            status: ServiceInspectionStatus.pending,
            pageSize: 5,
          )
          .first;
      if (result case Success<ServiceInspectionPage>(:final value)) {
        inspections = value.items;
        inspectionCount = value.filtered;
      }
    }
    final workExecutions = _workExecutions;
    if (workExecutions != null &&
        _canAny([
          AppPermission.serviceWorkExecutionViewAssigned,
          AppPermission.serviceWorkExecutionViewTeam,
          AppPermission.serviceWorkExecutionViewAll,
        ])) {
      final result = await workExecutions
          .watchExecutions(
            context,
            employeeId: employeeId,
            status: ServiceWorkExecutionStatus.inProgress,
            pageSize: 5,
          )
          .first;
      if (result case Success<ServiceWorkExecutionPage>(:final value)) {
        executions = value.items;
        executionCount = value.filtered;
      }
    }
    if (assignments.isEmpty &&
        inspections.isEmpty &&
        executions.isEmpty &&
        assignmentCount == 0 &&
        inspectionCount == 0 &&
        executionCount == 0) {
      return null;
    }
    return ServiceMyWork(
      assignments: assignments,
      inspections: inspections,
      executions: executions,
      assignmentCount: assignmentCount,
      inspectionCount: inspectionCount,
      executionCount: executionCount,
    );
  }

  bool _canAny(Iterable<AppPermission> permissions) => permissions.any(_can);
}
