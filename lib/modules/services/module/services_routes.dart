import 'package:modular_erp/app/router/route_segments.dart';

/// Canonical Services module routes (`/app/services/...`). Paths are stable
/// English identifiers and are never localized.
///
/// All paths are composed from [RouteSegments] and the named constants below —
/// no string fragment is written inline.
abstract final class ServicesRoutes {
  static const root = '/${RouteSegments.app}/services';
  static const settings = '$root/settings';

  // Enquiries.
  static const enquiries = '$root/enquiries';
  static const enquiriesNew = '$enquiries/${RouteSegments.newRecord}';
  static String enquiry(String id) => RouteSegments.byId(enquiries, id);
  static String enquiryEdit(String id) => RouteSegments.byIdEdit(enquiries, id);

  // Job assignments.
  static const assignments = '$root/job-assignments';
  static const assignmentsNew = '$assignments/${RouteSegments.newRecord}';
  static String assignment(String id) => RouteSegments.byId(assignments, id);
  static String assignmentEdit(String id) =>
      RouteSegments.byIdEdit(assignments, id);

  // Customers.
  static const customers = '$root/customers';
  static const customersNew = '$customers/${RouteSegments.newRecord}';
  static String customer(String id) => RouteSegments.byId(customers, id);
  static String customerEdit(String id) =>
      RouteSegments.byIdEdit(customers, id);

  // Sites.
  static const sites = '$root/sites';
  static const sitesNew = '$sites/${RouteSegments.newRecord}';
  static String site(String id) => RouteSegments.byId(sites, id);
  static String siteEdit(String id) => RouteSegments.byIdEdit(sites, id);

  // Teams.
  static const teams = '$root/teams';
  static const teamsNew = '$teams/${RouteSegments.newRecord}';
  static String team(String id) => RouteSegments.byId(teams, id);
  static String teamEdit(String id) => RouteSegments.byIdEdit(teams, id);

  // Configuration: service types.
  static const serviceTypes = '$settings/service-types';
  static const serviceTypesNew = '$serviceTypes/${RouteSegments.newRecord}';
  static String serviceType(String id) => RouteSegments.byId(serviceTypes, id);
  static String serviceTypeEdit(String id) =>
      RouteSegments.byIdEdit(serviceTypes, id);

  // Configuration: complaint types.
  static const complaintTypes = '$settings/complaint-types';
  static const complaintTypesNew = '$complaintTypes/${RouteSegments.newRecord}';
  static String complaintType(String id) =>
      RouteSegments.byId(complaintTypes, id);
  static String complaintTypeEdit(String id) =>
      RouteSegments.byIdEdit(complaintTypes, id);

  // Configuration: priorities.
  static const priorities = '$settings/priorities';
  static const prioritiesNew = '$priorities/${RouteSegments.newRecord}';
  static String priority(String id) => RouteSegments.byId(priorities, id);
  static String priorityEdit(String id) =>
      RouteSegments.byIdEdit(priorities, id);

  // Configuration: ticket types.
  static const ticketTypes = '$settings/ticket-types';
  static const ticketTypesNew = '$ticketTypes/${RouteSegments.newRecord}';
  static String ticketType(String id) => RouteSegments.byId(ticketTypes, id);
  static String ticketTypeEdit(String id) =>
      RouteSegments.byIdEdit(ticketTypes, id);

  // Configuration: root causes.
  static const rootCauses = '$settings/root-causes';
  static const rootCausesNew = '$rootCauses/${RouteSegments.newRecord}';
  static String rootCause(String id) => RouteSegments.byId(rootCauses, id);
  static String rootCauseEdit(String id) =>
      RouteSegments.byIdEdit(rootCauses, id);

  // Configuration: charge responsibilities.
  static const chargeResponsibilities = '$settings/charge-responsibilities';
  static const chargeResponsibilitiesNew =
      '$chargeResponsibilities/${RouteSegments.newRecord}';
  static String chargeResponsibility(String id) =>
      RouteSegments.byId(chargeResponsibilities, id);
  static String chargeResponsibilityEdit(String id) =>
      RouteSegments.byIdEdit(chargeResponsibilities, id);

  // Configuration: material request purposes.
  static const materialRequestPurposes = '$settings/material-request-purposes';
  static const materialRequestPurposesNew =
      '$materialRequestPurposes/${RouteSegments.newRecord}';
  static String materialRequestPurpose(String id) =>
      RouteSegments.byId(materialRequestPurposes, id);
  static String materialRequestPurposeEdit(String id) =>
      RouteSegments.byIdEdit(materialRequestPurposes, id);

  // Inspections.
  static const inspections = '$root/inspections';
  static const inspectionsNew = '$inspections/${RouteSegments.newRecord}';
  static String inspection(String id) => RouteSegments.byId(inspections, id);
  static String inspectionEdit(String id) =>
      RouteSegments.byIdEdit(inspections, id);

  // Material requests.
  static const materialRequests = '$root/material-requests';
  static const materialRequestsNew =
      '$materialRequests/${RouteSegments.newRecord}';
  static String materialRequest(String id) =>
      RouteSegments.byId(materialRequests, id);
  static String materialRequestEdit(String id) =>
      RouteSegments.byIdEdit(materialRequests, id);
  static String materialRequestPrint(String id) =>
      RouteSegments.printPath(materialRequest(id));

  // Work executions.
  static const workExecutions = '$root/work-executions';
  static const workExecutionsNew = '$workExecutions/${RouteSegments.newRecord}';
  static String workExecution(String id) =>
      RouteSegments.byId(workExecutions, id);
  static String workExecutionEdit(String id) =>
      RouteSegments.byIdEdit(workExecutions, id);
}
