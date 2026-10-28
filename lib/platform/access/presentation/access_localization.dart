import 'package:modular_erp/core/security/access_tree.dart';
import 'package:modular_erp/l10n/l10n.dart';

/// Resolves catalog localization keys to generated ARB getters. The Access UI
/// composes these so administrators see friendly labels, never permission keys.
extension AccessCatalogLocalization on AppLocalizations {
  String permissionModuleLabel(PermissionModule module) => switch (module) {
    PermissionModule.hr => permissionModuleHr,
    PermissionModule.company => permissionModuleCompany,
  };

  String permissionFeatureLabel(PermissionFeature feature) => switch (feature) {
    PermissionFeature.employees => permissionFeatureEmployees,
    PermissionFeature.departments => permissionFeatureDepartments,
    PermissionFeature.attendanceSelf => permissionFeatureAttendanceSelf,
    PermissionFeature.attendanceShifts => permissionFeatureAttendanceShifts,
    PermissionFeature.branches => permissionFeatureBranches,
    PermissionFeature.accessUsers => permissionFeatureAccessUsers,
    PermissionFeature.accessPermissions => permissionFeatureAccessPermissions,
    PermissionFeature.users => permissionFeatureUsers,
  };

  String permissionActionLabel(PermissionAction action) => switch (action) {
    PermissionAction.view => permissionActionView,
    PermissionAction.create => permissionActionCreate,
    PermissionAction.edit => permissionActionEdit,
    PermissionAction.deactivate => permissionActionDeactivate,
    PermissionAction.manage => permissionActionManage,
    PermissionAction.punch => permissionActionPunch,
  };

  String get permissionModuleFeatureColumn =>
      '$permissionFieldModule > $permissionFieldFeature';

  String permissionFeaturePathLabel(
    PermissionModule module,
    PermissionFeature feature,
  ) =>
      '${permissionModuleLabel(module)} · '
      '${permissionFeatureLabel(feature)}';

  String permissionUnknownKeyLabel(String key) =>
      '$permissionUnknownKey · $key';

  /// Suggested editable name, for example "View employees".
  String permissionSuggestedName(
    PermissionFeature feature,
    PermissionAction action,
  ) {
    final featureLabel = permissionFeatureLabel(feature);
    return '${permissionActionLabel(action)} '
        '${featureLabel.isEmpty ? featureLabel : featureLabel[0].toLowerCase()}'
        '${featureLabel.length > 1 ? featureLabel.substring(1) : ''}';
  }

  String moduleLabel(String key) => switch (key) {
    'hr' || 'hrPermModuleHr' => hrPermModuleHr,
    'services' || 'servicesPermModuleServices' => servicesPermModuleServices,
    'platform' || 'accessModulePlatform' => accessModulePlatform,
    _ => key,
  };

  String submoduleLabel(String key) => switch (key) {
    'employees' => hrPermSubEmployees,
    'attendance' => hrPermSubAttendance,
    'leave' => hrPermSubLeave,
    'reports' => hrPermSubReports,
    'configuration' => hrPermSubConfiguration,
    'access' => accessSubAccess,
    'customers' => servicesPermSubCustomers,
    'sites' => servicesPermSubSites,
    'teams' => servicesPermSubTeams,
    'enquiries' => servicesPermSubEnquiries,
    'jobAssignments' => servicesPermSubJobAssignments,
    'inspections' => servicesPermSubInspections,
    'materialRequests' => servicesPermSubMaterialRequests,
    'workExecutions' => servicesPermSubWorkExecutions,
    _ => key,
  };

  String permissionLabel(String key) => switch (key) {
    'hrPermEmployeesView' => hrPermEmployeesView,
    'hrPermEmployeesCreate' => hrPermEmployeesCreate,
    'hrPermEmployeesEdit' => hrPermEmployeesEdit,
    'hrPermEmployeesDeactivate' => hrPermEmployeesDeactivate,
    'hrPermAttendanceSelfView' => hrPermAttendanceSelfView,
    'hrPermAttendanceSelfPunch' => hrPermAttendanceSelfPunch,
    'hrPermAttendanceSelfPunchOut' => hrPermAttendanceSelfPunchOut,
    'hrPermAttendanceSelfBreak' => hrPermAttendanceSelfBreak,
    'hrPermAttendanceSelfCorrection' => hrPermAttendanceSelfCorrection,
    'hrPermAttendanceRecordsView' => hrPermAttendanceRecordsView,
    'hrPermAttendanceCorrectionsReview' => hrPermAttendanceCorrectionsReview,
    'hrPermAttendanceCorrectionsApply' => hrPermAttendanceCorrectionsApply,
    'hrPermAttendanceReportsView' => hrPermAttendanceReportsView,
    'hrPermLeaveSelfView' => hrPermLeaveSelfView,
    'hrPermLeaveSelfRequest' => hrPermLeaveSelfRequest,
    'hrPermLeaveSelfCancel' => hrPermLeaveSelfCancel,
    'hrPermLeaveSelfBalance' => hrPermLeaveSelfBalance,
    'hrPermLeaveRecordsView' => hrPermLeaveRecordsView,
    'hrPermLeaveRequestsReview' => hrPermLeaveRequestsReview,
    'hrPermLeaveBalancesView' => hrPermLeaveBalancesView,
    'hrPermLeaveBalancesAdjust' => hrPermLeaveBalancesAdjust,
    'hrPermLeaveSettingsManage' => hrPermLeaveSettingsManage,
    'hrPermLeaveTypesView' => hrPermLeaveTypesView,
    'hrPermLeaveTypesManage' => hrPermLeaveTypesManage,
    'hrPermLeavePoliciesView' => hrPermLeavePoliciesView,
    'hrPermLeavePoliciesManage' => hrPermLeavePoliciesManage,
    'hrPermHolidaysView' => hrPermHolidaysView,
    'hrPermHolidaysManage' => hrPermHolidaysManage,
    'hrPermReportsLeaveView' => hrPermReportsLeaveView,
    'hrPermShiftsView' => hrPermShiftsView,
    'hrPermShiftsManage' => hrPermShiftsManage,
    'hrPermLocationsView' => hrPermLocationsView,
    'hrPermLocationsManage' => hrPermLocationsManage,
    'hrPermPoliciesView' => hrPermPoliciesView,
    'hrPermPoliciesManage' => hrPermPoliciesManage,
    'accessUsersView' => accessUsersView,
    'accessPermissionsManage' => accessPermissionsManage,
    'accessModulesView' => accessModulesView,
    'accessCompanyUsersManage' => accessCompanyUsersManage,
    'accessPlatformCompaniesManage' => accessPlatformCompaniesManage,
    'accessPlatformModulesManage' => accessPlatformModulesManage,
    'servicesPermCustomersView' => servicesPermCustomersView,
    'servicesPermCustomersCreate' => servicesPermCustomersCreate,
    'servicesPermCustomersEdit' => servicesPermCustomersEdit,
    'servicesPermCustomersDeactivate' => servicesPermCustomersDeactivate,
    'servicesPermSitesView' => servicesPermSitesView,
    'servicesPermSitesCreate' => servicesPermSitesCreate,
    'servicesPermSitesEdit' => servicesPermSitesEdit,
    'servicesPermSitesDeactivate' => servicesPermSitesDeactivate,
    'servicesPermTeamsView' => servicesPermTeamsView,
    'servicesPermTeamsManage' => servicesPermTeamsManage,
    'servicesPermServiceTypesView' => servicesPermServiceTypesView,
    'servicesPermServiceTypesManage' => servicesPermServiceTypesManage,
    'servicesPermComplaintTypesView' => servicesPermComplaintTypesView,
    'servicesPermComplaintTypesManage' => servicesPermComplaintTypesManage,
    'servicesPermPrioritiesView' => servicesPermPrioritiesView,
    'servicesPermPrioritiesManage' => servicesPermPrioritiesManage,
    'servicesPermTicketTypesView' => servicesPermTicketTypesView,
    'servicesPermTicketTypesManage' => servicesPermTicketTypesManage,
    'servicesPermEnquiriesView' => servicesPermEnquiriesView,
    'servicesPermEnquiriesCreate' => servicesPermEnquiriesCreate,
    'servicesPermEnquiriesEdit' => servicesPermEnquiriesEdit,
    'servicesPermEnquiriesCancel' => servicesPermEnquiriesCancel,
    'servicesPermJobAssignmentsView' => servicesPermJobAssignmentsView,
    'servicesPermJobAssignmentsCreate' => servicesPermJobAssignmentsCreate,
    'servicesPermJobAssignmentsEdit' => servicesPermJobAssignmentsEdit,
    'servicesPermJobAssignmentsCancel' => servicesPermJobAssignmentsCancel,
    'servicesPermInspectionsView' => servicesPermInspectionsView,
    'servicesPermInspectionsCreate' => servicesPermInspectionsCreate,
    'servicesPermInspectionsEdit' => servicesPermInspectionsEdit,
    'servicesPermInspectionsComplete' => servicesPermInspectionsComplete,
    'servicesPermInspectionsCancel' => servicesPermInspectionsCancel,
    'servicesPermRootCausesView' => servicesPermRootCausesView,
    'servicesPermRootCausesManage' => servicesPermRootCausesManage,
    'servicesPermChargeResponsibilitiesView' =>
      servicesPermChargeResponsibilitiesView,
    'servicesPermChargeResponsibilitiesManage' =>
      servicesPermChargeResponsibilitiesManage,
    'servicesPermMaterialRequestPurposesView' =>
      servicesPermMaterialRequestPurposesView,
    'servicesPermMaterialRequestPurposesManage' =>
      servicesPermMaterialRequestPurposesManage,
    'servicesPermMaterialRequestsView' => servicesPermMaterialRequestsView,
    'servicesPermMaterialRequestsCreate' => servicesPermMaterialRequestsCreate,
    'servicesPermMaterialRequestsEdit' => servicesPermMaterialRequestsEdit,
    'servicesPermMaterialRequestsCancel' => servicesPermMaterialRequestsCancel,
    'servicesPermMaterialRequestsPrint' => servicesPermMaterialRequestsPrint,
    'servicesPermWorkExecutionsView' => servicesPermWorkExecutionsView,
    'servicesPermWorkExecutionsCreate' => servicesPermWorkExecutionsCreate,
    'servicesPermWorkExecutionsEdit' => servicesPermWorkExecutionsEdit,
    'servicesPermWorkExecutionsPerform' => servicesPermWorkExecutionsPerform,
    'servicesPermWorkExecutionsComplete' => servicesPermWorkExecutionsComplete,
    'servicesPermWorkExecutionsCancel' => servicesPermWorkExecutionsCancel,
    _ => key,
  };

  String permissionDescription(String key) => switch (key) {
    'hrPermEmployeesViewDesc' => hrPermEmployeesViewDesc,
    'hrPermEmployeesCreateDesc' => hrPermEmployeesCreateDesc,
    'hrPermEmployeesEditDesc' => hrPermEmployeesEditDesc,
    'hrPermEmployeesDeactivateDesc' => hrPermEmployeesDeactivateDesc,
    'hrPermAttendanceSelfViewDesc' => hrPermAttendanceSelfViewDesc,
    'hrPermAttendanceSelfPunchDesc' => hrPermAttendanceSelfPunchDesc,
    'hrPermAttendanceSelfPunchOutDesc' => hrPermAttendanceSelfPunchOutDesc,
    'hrPermAttendanceSelfBreakDesc' => hrPermAttendanceSelfBreakDesc,
    'hrPermAttendanceSelfCorrectionDesc' => hrPermAttendanceSelfCorrectionDesc,
    'hrPermAttendanceRecordsViewDesc' => hrPermAttendanceRecordsViewDesc,
    'hrPermAttendanceCorrectionsReviewDesc' =>
      hrPermAttendanceCorrectionsReviewDesc,
    'hrPermAttendanceCorrectionsApplyDesc' =>
      hrPermAttendanceCorrectionsApplyDesc,
    'hrPermAttendanceReportsViewDesc' => hrPermAttendanceReportsViewDesc,
    'hrPermLeaveSelfViewDesc' => hrPermLeaveSelfViewDesc,
    'hrPermLeaveSelfRequestDesc' => hrPermLeaveSelfRequestDesc,
    'hrPermLeaveSelfCancelDesc' => hrPermLeaveSelfCancelDesc,
    'hrPermLeaveSelfBalanceDesc' => hrPermLeaveSelfBalanceDesc,
    'hrPermLeaveRecordsViewDesc' => hrPermLeaveRecordsViewDesc,
    'hrPermLeaveRequestsReviewDesc' => hrPermLeaveRequestsReviewDesc,
    'hrPermLeaveBalancesViewDesc' => hrPermLeaveBalancesViewDesc,
    'hrPermLeaveBalancesAdjustDesc' => hrPermLeaveBalancesAdjustDesc,
    'hrPermLeaveSettingsManageDesc' => hrPermLeaveSettingsManageDesc,
    'hrPermLeaveTypesViewDesc' => hrPermLeaveTypesViewDesc,
    'hrPermLeaveTypesManageDesc' => hrPermLeaveTypesManageDesc,
    'hrPermLeavePoliciesViewDesc' => hrPermLeavePoliciesViewDesc,
    'hrPermLeavePoliciesManageDesc' => hrPermLeavePoliciesManageDesc,
    'hrPermHolidaysViewDesc' => hrPermHolidaysViewDesc,
    'hrPermHolidaysManageDesc' => hrPermHolidaysManageDesc,
    'hrPermReportsLeaveViewDesc' => hrPermReportsLeaveViewDesc,
    'hrPermShiftsViewDesc' => hrPermShiftsViewDesc,
    'hrPermShiftsManageDesc' => hrPermShiftsManageDesc,
    'hrPermLocationsViewDesc' => hrPermLocationsViewDesc,
    'hrPermLocationsManageDesc' => hrPermLocationsManageDesc,
    'hrPermPoliciesViewDesc' => hrPermPoliciesViewDesc,
    'hrPermPoliciesManageDesc' => hrPermPoliciesManageDesc,
    'accessUsersViewDesc' => accessUsersViewDesc,
    'accessPermissionsManageDesc' => accessPermissionsManageDesc,
    'accessModulesViewDesc' => accessModulesViewDesc,
    'accessCompanyUsersManageDesc' => accessCompanyUsersManageDesc,
    'accessPlatformCompaniesManageDesc' => accessPlatformCompaniesManageDesc,
    'accessPlatformModulesManageDesc' => accessPlatformModulesManageDesc,
    'servicesPermCustomersViewDesc' => servicesPermCustomersViewDesc,
    'servicesPermCustomersCreateDesc' => servicesPermCustomersCreateDesc,
    'servicesPermCustomersEditDesc' => servicesPermCustomersEditDesc,
    'servicesPermCustomersDeactivateDesc' =>
      servicesPermCustomersDeactivateDesc,
    'servicesPermSitesViewDesc' => servicesPermSitesViewDesc,
    'servicesPermSitesCreateDesc' => servicesPermSitesCreateDesc,
    'servicesPermSitesEditDesc' => servicesPermSitesEditDesc,
    'servicesPermSitesDeactivateDesc' => servicesPermSitesDeactivateDesc,
    'servicesPermTeamsViewDesc' => servicesPermTeamsViewDesc,
    'servicesPermTeamsManageDesc' => servicesPermTeamsManageDesc,
    'servicesPermServiceTypesViewDesc' => servicesPermServiceTypesViewDesc,
    'servicesPermServiceTypesManageDesc' => servicesPermServiceTypesManageDesc,
    'servicesPermComplaintTypesViewDesc' => servicesPermComplaintTypesViewDesc,
    'servicesPermComplaintTypesManageDesc' =>
      servicesPermComplaintTypesManageDesc,
    'servicesPermPrioritiesViewDesc' => servicesPermPrioritiesViewDesc,
    'servicesPermPrioritiesManageDesc' => servicesPermPrioritiesManageDesc,
    'servicesPermTicketTypesViewDesc' => servicesPermTicketTypesViewDesc,
    'servicesPermTicketTypesManageDesc' => servicesPermTicketTypesManageDesc,
    'servicesPermEnquiriesViewDesc' => servicesPermEnquiriesViewDesc,
    'servicesPermEnquiriesCreateDesc' => servicesPermEnquiriesCreateDesc,
    'servicesPermEnquiriesEditDesc' => servicesPermEnquiriesEditDesc,
    'servicesPermEnquiriesCancelDesc' => servicesPermEnquiriesCancelDesc,
    'servicesPermJobAssignmentsViewDesc' => servicesPermJobAssignmentsViewDesc,
    'servicesPermJobAssignmentsCreateDesc' =>
      servicesPermJobAssignmentsCreateDesc,
    'servicesPermJobAssignmentsEditDesc' => servicesPermJobAssignmentsEditDesc,
    'servicesPermJobAssignmentsCancelDesc' =>
      servicesPermJobAssignmentsCancelDesc,
    'servicesPermInspectionsViewDesc' => servicesPermInspectionsViewDesc,
    'servicesPermInspectionsCreateDesc' => servicesPermInspectionsCreateDesc,
    'servicesPermInspectionsEditDesc' => servicesPermInspectionsEditDesc,
    'servicesPermInspectionsCompleteDesc' =>
      servicesPermInspectionsCompleteDesc,
    'servicesPermInspectionsCancelDesc' => servicesPermInspectionsCancelDesc,
    'servicesPermRootCausesViewDesc' => servicesPermRootCausesViewDesc,
    'servicesPermRootCausesManageDesc' => servicesPermRootCausesManageDesc,
    'servicesPermChargeResponsibilitiesViewDesc' =>
      servicesPermChargeResponsibilitiesViewDesc,
    'servicesPermChargeResponsibilitiesManageDesc' =>
      servicesPermChargeResponsibilitiesManageDesc,
    'servicesPermMaterialRequestPurposesViewDesc' =>
      servicesPermMaterialRequestPurposesViewDesc,
    'servicesPermMaterialRequestPurposesManageDesc' =>
      servicesPermMaterialRequestPurposesManageDesc,
    'servicesPermMaterialRequestsViewDesc' =>
      servicesPermMaterialRequestsViewDesc,
    'servicesPermMaterialRequestsCreateDesc' =>
      servicesPermMaterialRequestsCreateDesc,
    'servicesPermMaterialRequestsEditDesc' =>
      servicesPermMaterialRequestsEditDesc,
    'servicesPermMaterialRequestsCancelDesc' =>
      servicesPermMaterialRequestsCancelDesc,
    'servicesPermMaterialRequestsPrintDesc' =>
      servicesPermMaterialRequestsPrintDesc,
    'servicesPermWorkExecutionsViewDesc' => servicesPermWorkExecutionsViewDesc,
    'servicesPermWorkExecutionsCreateDesc' =>
      servicesPermWorkExecutionsCreateDesc,
    'servicesPermWorkExecutionsEditDesc' => servicesPermWorkExecutionsEditDesc,
    'servicesPermWorkExecutionsPerformDesc' =>
      servicesPermWorkExecutionsPerformDesc,
    'servicesPermWorkExecutionsCompleteDesc' =>
      servicesPermWorkExecutionsCompleteDesc,
    'servicesPermWorkExecutionsCancelDesc' =>
      servicesPermWorkExecutionsCancelDesc,
    _ => key,
  };

  String scopeLabel(String scope) => switch (scope) {
    'none' => accessScopeNone,
    'self' => accessScopeSelf,
    'assigned' => accessScopeAssigned,
    'team' => accessScopeTeam,
    'all' => accessScopeAll,
    _ => scope,
  };
}
