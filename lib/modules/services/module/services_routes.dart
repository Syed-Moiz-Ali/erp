/// Canonical Services module routes (`/app/services/...`). Paths are stable
/// English identifiers and are never localized.
abstract final class ServicesRoutes {
  static const root = '/app/services';

  static const customers = '$root/customers';
  static const customersNew = '$customers/new';
  static String customer(String id) => '$customers/${Uri.encodeComponent(id)}';
  static String customerEdit(String id) => '${customer(id)}/edit';

  static const sites = '$root/sites';
  static const sitesNew = '$sites/new';
  static String site(String id) => '$sites/${Uri.encodeComponent(id)}';
  static String siteEdit(String id) => '${site(id)}/edit';

  static const teams = '$root/teams';
  static const teamsNew = '$teams/new';
  static String team(String id) => '$teams/${Uri.encodeComponent(id)}';
  static String teamEdit(String id) => '${team(id)}/edit';

  static const settings = '$root/settings';
  static const serviceTypes = '$settings/service-types';
  static const serviceTypesNew = '$serviceTypes/new';
  static String serviceType(String id) =>
      '$serviceTypes/${Uri.encodeComponent(id)}';
  static String serviceTypeEdit(String id) => '${serviceType(id)}/edit';

  static const complaintTypes = '$settings/complaint-types';
  static const complaintTypesNew = '$complaintTypes/new';
  static String complaintType(String id) =>
      '$complaintTypes/${Uri.encodeComponent(id)}';
  static String complaintTypeEdit(String id) => '${complaintType(id)}/edit';

  static const priorities = '$settings/priorities';
  static const prioritiesNew = '$priorities/new';
  static String priority(String id) => '$priorities/${Uri.encodeComponent(id)}';
  static String priorityEdit(String id) => '${priority(id)}/edit';

  static const ticketTypes = '$settings/ticket-types';
  static const ticketTypesNew = '$ticketTypes/new';
  static String ticketType(String id) =>
      '$ticketTypes/${Uri.encodeComponent(id)}';
  static String ticketTypeEdit(String id) => '${ticketType(id)}/edit';
}
