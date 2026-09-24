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
import 'package:modular_erp/modules/services/sites/domain/service_site.dart';
import 'package:modular_erp/modules/services/sites/domain/service_site_repository.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team_repository.dart';

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
    this.failure,
  });
  final bool loading;
  final int? customers, activeSites, teams, serviceTypes, priorities;
  final ServiceEnquirySummary? enquirySummary;
  final List<ServiceEnquiryListItem> recentEnquiries;
  final ServiceJobAssignmentSummary? assignmentSummary;
  final List<ServiceJobAssignmentListItem> upcomingAssignments;
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
  }) : _enquiries = enquiries,
       _jobAssignments = jobAssignments,
       super(const ServiceOverviewState());
  final ServiceCustomerRepository customers;
  final ServiceSiteRepository sites;
  final ServiceTeamRepository teams;
  final ServiceMasterRepository masters;
  final ServiceEnquiryRepository? _enquiries;
  final ServiceJobAssignmentRepository? _jobAssignments;
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
      ),
    );
  }

  bool _canAny(Iterable<AppPermission> permissions) => permissions.any(_can);
}
