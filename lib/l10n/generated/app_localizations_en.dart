// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Bitlogix ERP';

  @override
  String get brandName => 'bitlogix';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get clear => 'Clear';

  @override
  String get retry => 'Try again';

  @override
  String get refresh => 'Refresh';

  @override
  String get continueAction => 'Continue';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get loading => 'Loading';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get noData => 'No data';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get home => 'Home';

  @override
  String get more => 'More';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get emailOrPhone => 'Email or phone';

  @override
  String get password => 'Password';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get pending => 'Pending';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get failed => 'Failed';

  @override
  String get synced => 'Synced';

  @override
  String get draft => 'Draft';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get actions => 'Actions';

  @override
  String get primaryAction => 'Primary action';

  @override
  String get previewActionComplete => 'Preview action complete';

  @override
  String get secondaryAction => 'Secondary';

  @override
  String get textAction => 'Text action';

  @override
  String get moreOptions => 'More options';

  @override
  String get disabled => 'Disabled';

  @override
  String get saving => 'Saving';

  @override
  String get fullName => 'Full name';

  @override
  String get enterName => 'Enter a name';

  @override
  String get validationExample => 'Validation example';

  @override
  String get informationCard => 'Information card';

  @override
  String get informationCardMessage =>
      'Use a concise explanation to help people make a decision.';

  @override
  String get statusAndFeedback => 'Status & feedback';

  @override
  String get localChangesAvailable =>
      'Your changes are available on this device.';

  @override
  String get recordsNeedAttention => 'Some records need your attention.';

  @override
  String get actionFailed => 'Unable to complete this action.';

  @override
  String get loadingRecords => 'Loading records...';

  @override
  String get noRecordsYet => 'No records yet';

  @override
  String get noRecordsMessage =>
      'Records will appear here when your team gets started.';

  @override
  String get retryWhenConnected =>
      'Please try again when a connection is available.';

  @override
  String get filtersAndTable => 'Filters & table';

  @override
  String get status => 'Status';

  @override
  String get pageNotFound => 'This page could not be found.';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get searchRecords => 'Search records';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectTime => 'Select time';

  @override
  String get unableToLoadRecords => 'Unable to load records';

  @override
  String get noRecords => 'No records';

  @override
  String get previousPage => 'Previous page';

  @override
  String get nextPage => 'Next page';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email address';

  @override
  String get failureTimeout => 'The request timed out. Please try again.';

  @override
  String get failureOffline =>
      'Connection unavailable. Your local data is still available.';

  @override
  String get failureCancelled => 'Request cancelled.';

  @override
  String get failureSessionExpired => 'Your session has expired.';

  @override
  String get failureRequest => 'Unable to complete the request.';

  @override
  String get failureInvalidData => 'The response could not be read.';

  @override
  String get failureLocationDisabled => 'Enable location services to continue.';

  @override
  String get failureLocationPermission =>
      'Location permission is required for this action.';

  @override
  String get failureLocationUnavailable => 'Unable to determine your location.';

  @override
  String get failureStorageWrite => 'Unable to save changes on this device.';

  @override
  String get failureStorageUpdate => 'Unable to update local changes.';

  @override
  String get failureSync => 'Some changes could not be synchronized.';

  @override
  String get failurePreferencesWrite =>
      'Language changed for this session, but could not be saved.';

  @override
  String get failurePreferencesRead => 'Saved language could not be restored.';

  @override
  String get formattingTitle => 'Locale-aware formatting';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get duration => 'Duration';

  @override
  String get number => 'Number';

  @override
  String get percentage => 'Percentage';

  @override
  String get currency => 'Currency';

  @override
  String get month => 'Month';

  @override
  String paginationSummary(String start, String end, String total) {
    return '$start–$end of $total';
  }

  @override
  String get navSectionHr => 'Human resources';

  @override
  String get navSectionServices => 'Services';

  @override
  String get navSectionSettings => 'Settings';

  @override
  String get navSectionAccount => 'Account';

  @override
  String durationHoursMinutes(String hours, String minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationHoursOnly(String hours) {
    return '${hours}h';
  }

  @override
  String get selectOption => 'Select an option';

  @override
  String get noSelection => 'Not assigned';

  @override
  String timeRange(String start, String end) {
    return '$start → $end';
  }

  @override
  String dateTimeValue(String date, String time) {
    return '$date · $time';
  }

  @override
  String labeledValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get viewDetails => 'View details';

  @override
  String get filters => 'Filters';

  @override
  String get moreFilters => 'More filters';

  @override
  String get resetFilters => 'Reset';

  @override
  String get periodLabel => 'Period';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get changePassword => 'Change password';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get workspace => 'Workspace';

  @override
  String get overview => 'Overview';

  @override
  String get internal => 'Internal';

  @override
  String get designSystem => 'Design system';

  @override
  String get erpWorkspace => 'ERP workspace';

  @override
  String get foundationPhase => 'Foundation / Phase 0';

  @override
  String get designPreview => 'Design preview';

  @override
  String get designSystemSubtitle =>
      'The shared language of your ERP workspace.';

  @override
  String get internalPreview => 'Internal preview';

  @override
  String get openDialog => 'Open dialog';

  @override
  String get reviewChanges => 'Review changes';

  @override
  String get confirmationPreview =>
      'This is a preview of the shared confirmation dialog.';

  @override
  String get looksGood => 'Looks good';

  @override
  String get consistencyNotice =>
      'Consistent by design. Every future module uses these foundations.';

  @override
  String get designLanguage => 'Design language';

  @override
  String get oneSystem => 'One system';

  @override
  String get sharedAcrossModules => 'Shared across every module';

  @override
  String get dataStrategy => 'Data strategy';

  @override
  String get localFirst => 'Local first';

  @override
  String get repositorySourceOfTruth => 'Repositories own the source of truth';

  @override
  String get layout => 'Layout';

  @override
  String get adaptive => 'Adaptive';

  @override
  String get adaptiveDetail => 'Compact through large workspaces';

  @override
  String get typography => 'Typography';

  @override
  String get typographySubtitle =>
      'Inter / locally bundled / clear at every density';

  @override
  String get typographyDisplay => 'Display';

  @override
  String get typographyPageTitle => 'Page title';

  @override
  String get typographySectionTitle => 'Section title';

  @override
  String get typographyCardTitle => 'Card title';

  @override
  String get typographyBodyLarge => 'Body large';

  @override
  String get typographyBody => 'Body';

  @override
  String get typographyBodySmall => 'Body small';

  @override
  String get typographyLabel => 'Label';

  @override
  String get typographyCaption => 'Caption';

  @override
  String get semanticPalette => 'Semantic palette';

  @override
  String get colorBrand => 'Brand';

  @override
  String get colorSurface => 'Surface';

  @override
  String get colorBackground => 'Background';

  @override
  String get colorBorder => 'Border';

  @override
  String get colorTextPrimary => 'Text primary';

  @override
  String get colorTextSecondary => 'Text secondary';

  @override
  String get colorTextMuted => 'Text muted';

  @override
  String get colorDanger => 'Danger';

  @override
  String get colorInfo => 'Info';

  @override
  String get formControls => 'Form controls';

  @override
  String get formControlsSubtitle =>
      'Shared field styling, validation and accessible labels.';

  @override
  String get illustrativeRecords =>
      'Illustrative records / no operational employee data';

  @override
  String get activeOnly => 'Active only';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get sampleAlex => 'Alex Morgan';

  @override
  String get sampleSam => 'Sam Taylor';

  @override
  String get dialogsAndSheets => 'Dialogs & sheets';

  @override
  String get previewDialog => 'Preview dialog';

  @override
  String get sharedDialog => 'Shared dialog';

  @override
  String get sharedDialogMessage => 'Focused content for a clear decision.';

  @override
  String get previewBottomSheet => 'Preview bottom sheet';

  @override
  String get quickDetails => 'Quick details';

  @override
  String get quickDetailsSubtitle => 'A shared mobile presentation pattern.';

  @override
  String get foundationDetails => 'Foundation details';

  @override
  String get architecture => 'Architecture';

  @override
  String get featureFirst => 'Feature first';

  @override
  String get theme => 'Theme';

  @override
  String get lightSemanticTokens => 'Light / semantic tokens';

  @override
  String get persistence => 'Persistence';

  @override
  String get persistenceDetail => 'Drift + secure session storage';

  @override
  String get internalPreviewPhase => 'Internal preview / Phase 0';

  @override
  String get workspaceTitle => 'A foundation for what is next';

  @override
  String get workspaceSubtitle => 'One workspace. Every ERP module.';

  @override
  String get workspaceInfoTitle => 'Your ERP starts here';

  @override
  String get workspaceInfoMessage =>
      'The local-first architecture and shared design system are ready. Business modules will be introduced in future phases.';

  @override
  String get phaseReady => 'Phase 0 / Foundation ready';

  @override
  String get languageSubtitle => 'Language and layout update immediately.';

  @override
  String get englishNativeName => 'English';

  @override
  String get arabicNativeName => 'العربية';

  @override
  String typographySample(String level) {
    return '$level / Built for clarity';
  }

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authSignInSubtitle => 'Sign in to your Bitlogix workspace.';

  @override
  String get authIdentifier => 'Email or phone number';

  @override
  String get authIdentifierHint => 'name@company.com';

  @override
  String get authIdentifierRequired => 'Email or phone number is required';

  @override
  String get authIdentifierInvalid => 'Enter a valid email or phone number';

  @override
  String get authPasswordRequired => 'Password is required';

  @override
  String get authInvalidCredentials =>
      'Incorrect email, phone number, or password.';

  @override
  String get authLoggingIn => 'Signing in…';

  @override
  String get authBrandStatement =>
      'A connected workspace.\nA clearer working day.';

  @override
  String get authBrandDescription =>
      'One place for your people, operations, and the work ahead.';

  @override
  String get authWorkspaceLabel => 'Company workspace';

  @override
  String get authSecureSession => 'Your session stays secure on this device.';

  @override
  String get authSecureSessionLabel => 'Secure session';

  @override
  String get authWorkforce => 'Workforce';

  @override
  String get authActiveEmployees => 'active employees';

  @override
  String get authWorking => 'Working';

  @override
  String get authAttendanceActive => 'Attendance active';

  @override
  String get authLive => 'Live';

  @override
  String get authDeveloperAccess => 'Developer access';

  @override
  String get productEyebrow => 'Modular business workspace';

  @override
  String get productHeadline => 'Everything your business runs on.\nConnected.';

  @override
  String get productWorkspaceTitle => 'Bitlogix Workspace';

  @override
  String get productWorkspaceSubtitle => 'Unified business system';

  @override
  String get productWorkspaceFooter => 'Connected by one workspace';

  @override
  String get modulePeople => 'People';

  @override
  String get moduleOperations => 'Operations';

  @override
  String get moduleOperationsDesc => 'Workflows';

  @override
  String get moduleCustomers => 'Customers';

  @override
  String get moduleCustomersDesc => 'Relationships';

  @override
  String get moduleFinance => 'Finance';

  @override
  String get moduleServices => 'Services';

  @override
  String get moduleServicesDesc => 'Service requests';

  @override
  String get moduleInventory => 'Inventory';

  @override
  String get moduleInventoryDesc => 'Assets';

  @override
  String get moduleReports => 'Reports';

  @override
  String get moduleReportsDesc => 'Scheduled exports';

  @override
  String get moduleInsights => 'Insights';

  @override
  String get moduleInsightsDesc => 'Overview';

  @override
  String get authWorkdayTitle => 'Your workday,\nall in one place.';

  @override
  String get authWorkingDay => 'Working day';

  @override
  String get authNow => 'Now';

  @override
  String get authShiftGeneral => 'General shift';

  @override
  String get authShiftToday => 'Today';

  @override
  String get authWorkLocationMain => 'Main office';

  @override
  String authEmployeesActiveCount(int count) {
    return '$count employees active';
  }

  @override
  String get authDemoUse => 'Use a demo account';

  @override
  String get authSessionNote =>
      'Your session stays signed in on this device until you sign out or it expires.';

  @override
  String get authInitializing => 'Preparing your workspace…';

  @override
  String get authDemoAccounts => 'Demo accounts';

  @override
  String get authDemoNotice =>
      'Local demonstration only. No backend is connected.';

  @override
  String get authDemoDisabled =>
      'Demo authentication is disabled in this configuration. A backend has not been connected yet.';

  @override
  String get authDemoPassword => 'Demo password';

  @override
  String get authSessionStorageError =>
      'We could not access the secure session. Please try again.';

  @override
  String get authServerError =>
      'The sign-in service is temporarily unavailable. Please try again.';

  @override
  String get authForgotTitle => 'Reset your password';

  @override
  String get authForgotSubtitle =>
      'Enter the email or phone number associated with your account.';

  @override
  String get authResetInformation =>
      'If an account matches these details, password reset instructions will be sent.';

  @override
  String get authResetDemoNote => 'In this demo, no email or SMS is sent.';

  @override
  String get authResetTitle => 'Request received';

  @override
  String get authBackToLogin => 'Back to sign in';

  @override
  String get authSubmitting => 'Please wait…';

  @override
  String get authChangePassword => 'Change password';

  @override
  String get authChangeSubtitle => 'Choose a strong password for your account.';

  @override
  String get authCurrentPassword => 'Current password';

  @override
  String get authNewPassword => 'New password';

  @override
  String get authConfirmPassword => 'Confirm new password';

  @override
  String get authPasswordConstraints =>
      'Use at least 8 characters, including a letter and a number.';

  @override
  String get authPasswordsMismatch => 'Passwords do not match';

  @override
  String get authPasswordMustDiffer =>
      'Choose a password different from your current password';

  @override
  String get authCurrentPasswordInvalid => 'The current password is incorrect.';

  @override
  String get authPasswordChanged => 'Password updated for this demo session.';

  @override
  String get authPasswordDemoNote =>
      'Demo password changes last until the app restarts. No password is stored on this device.';

  @override
  String get authBackToWorkspace => 'Back to workspace';

  @override
  String get authConfirmLogout => 'Sign out of your workspace?';

  @override
  String get authLogoutMessage =>
      'Your secure session will be removed from this device.';

  @override
  String get authHomeTitle => 'Your workspace is ready';

  @override
  String get authHomeSubtitle =>
      'You are signed in. Business modules will be added in the next phases.';

  @override
  String get authAccount => 'Account';

  @override
  String get authCompany => 'Company';

  @override
  String get authPermissions => 'Permissions';

  @override
  String get authAccountStatus => 'Account status';

  @override
  String get authStatusActive => 'Active';

  @override
  String get authStatusSuspended => 'Suspended';

  @override
  String get authStatusInactive => 'Inactive';

  @override
  String get authPermissionViewer => 'Assigned permissions';

  @override
  String get authEmployeeLinked => 'Linked employee record';

  @override
  String get authEmployeeUnlinked => 'No employee record linked';

  @override
  String authPermissionCount(String count) {
    return '$count permissions assigned';
  }

  @override
  String authGreeting(String name) {
    return 'Welcome, $name';
  }

  @override
  String get permissionCompanyManage => 'Manage company';

  @override
  String get permissionUserManage => 'Manage user accounts';

  @override
  String get shellDashboard => 'Dashboard';

  @override
  String get shellEmployees => 'Employees';

  @override
  String get shellAttendance => 'Attendance';

  @override
  String get shellReports => 'Reports';

  @override
  String get shellSettings => 'Settings';

  @override
  String get shellProfile => 'Profile';

  @override
  String get shellMore => 'More';

  @override
  String get shellGeneral => 'Workspace';

  @override
  String get shellPeople => 'People';

  @override
  String get shellWorkforce => 'Workforce';

  @override
  String get shellInsights => 'Insights';

  @override
  String get shellAdministration => 'Administration';

  @override
  String get shellAccount => 'Account';

  @override
  String get shellServices => 'Services';

  @override
  String get shellFinance => 'Finance';

  @override
  String get shellProfileDescription =>
      'Your account, preferences and attendance settings.';

  @override
  String get shellPlaceholderTitle => 'Ready for the next phase';

  @override
  String get shellPlaceholderMessage =>
      'This area is reserved for a future ERP module. No business data is available yet.';

  @override
  String get shellMoreDescription =>
      'Explore the other areas available to your account.';

  @override
  String get shellSearchTitle => 'Global search';

  @override
  String get shellSearchMessage =>
      'Global search will become available as ERP modules are added.';

  @override
  String get shellNotifications => 'Notifications';

  @override
  String get shellNoNotifications => 'No notifications';

  @override
  String get shellNotificationsMessage =>
      'There are no notifications to display.';

  @override
  String get shellAccessRestricted => 'Access restricted';

  @override
  String get shellAccessMessage =>
      'You do not have permission to access this area.';

  @override
  String get shellModuleUnavailable => 'Module unavailable';

  @override
  String get shellModuleUnavailableMessage =>
      'This module is not enabled for your organization.';

  @override
  String get shellNotFound => 'Page not found';

  @override
  String get shellNotFoundMessage =>
      'The page you requested could not be found.';

  @override
  String get shellReturnToWorkspace => 'Return to workspace';

  @override
  String get shellGoBack => 'Go back';

  @override
  String get shellCollapseSidebar => 'Collapse sidebar';

  @override
  String get shellExpandSidebar => 'Expand sidebar';

  @override
  String get shellCompanyInformation => 'Company information';

  @override
  String get shellTimezone => 'Time zone';

  @override
  String get shellCompanyCode => 'Company code';

  @override
  String get shellAccountMenu => 'Open account menu';

  @override
  String get shellBreadcrumbs => 'Breadcrumb navigation';

  @override
  String get shellNoDestinations => 'No available destinations';

  @override
  String get shellNoDestinationsMessage =>
      'No workspace areas are available for this account. Contact your administrator.';

  @override
  String get syncOfflineTitle => 'You\'re offline';

  @override
  String get syncOfflineMessage =>
      'Changes will sync when your connection returns.';

  @override
  String get syncServiceUnavailable => 'Service temporarily unavailable';

  @override
  String get syncSyncing => 'Syncing';

  @override
  String get syncAllChangesSynced => 'All changes synced';

  @override
  String get syncPending => 'Pending sync';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get syncNeedsAttention => 'Sync needs attention';

  @override
  String get syncRetry => 'Retry';

  @override
  String get syncRetryNow => 'Retry now';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncLastSync => 'Last sync';

  @override
  String get syncNever => 'Not yet synced';

  @override
  String get syncChangesWaiting => 'Changes waiting to sync';

  @override
  String get syncDataAndSync => 'Data and sync';

  @override
  String get syncNoPendingChanges => 'No changes waiting';

  @override
  String get syncSyncSucceeded => 'Sync complete';

  @override
  String get syncStatusTitle => 'Sync status';

  @override
  String get syncPendingOperations => 'Pending operations';

  @override
  String get syncFailedOperations => 'Failed operations';

  @override
  String get syncSwitchAccount => 'Sign in to sync';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsNoItems => 'No notifications';

  @override
  String get notificationsNoItemsMessage => 'You are all caught up.';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsToday => 'Today';

  @override
  String get notificationsEarlier => 'Earlier';

  @override
  String get notificationsUnread => 'Unread';

  @override
  String get notificationsReminders => 'Notifications and reminders';

  @override
  String get notificationsOpen => 'Open notifications';

  @override
  String get reminderAttendanceSection => 'Attendance reminders';

  @override
  String get reminderShift => 'Shift reminder';

  @override
  String get reminderPunchOut => 'Punch out reminder';

  @override
  String get reminderNotifyBefore => 'Notify before shift';

  @override
  String get reminderMinutesBefore => 'Minutes before';

  @override
  String get reminderNotificationPermission => 'Notification permission';

  @override
  String get reminderPermissionRequired => 'Notification permission required';

  @override
  String get reminderNotificationsDisabled => 'Notifications disabled';

  @override
  String get reminderNotificationsEnabled => 'Reminders enabled in the app';

  @override
  String get reminderOpenSettings => 'Open settings';

  @override
  String get reminderSaved => 'Reminder settings saved';

  @override
  String get reminderSaveFailed => 'Could not save reminder settings';

  @override
  String get reminderPermissionHint =>
      'Enable reminders to receive shift notifications.';

  @override
  String get notifShiftSoonTitle => 'Your shift starts soon';

  @override
  String get notifShiftSoonBody =>
      'Your shift is about to start. Open attendance to check in.';

  @override
  String get notifPunchOutTitle => 'Remember to punch out';

  @override
  String get notifPunchOutBody =>
      'Your shift has ended. Remember to punch out.';

  @override
  String get notifShiftEndingOnBreakBody =>
      'Your shift is ending. Review your attendance before leaving.';

  @override
  String get notifCorrectionApprovedTitle => 'Attendance correction approved';

  @override
  String get notifCorrectionApprovedBody =>
      'Your attendance correction was approved and applied.';

  @override
  String get notifCorrectionRejectedTitle => 'Attendance correction rejected';

  @override
  String get notifCorrectionRejectedBody =>
      'Your attendance correction request was not approved.';

  @override
  String get notifSyncFailedTitle => 'Attendance needs attention';

  @override
  String get notifSyncFailedBody =>
      'Some attendance changes could not be synced.';

  @override
  String get notifConflictTitle => 'Attendance needs review';

  @override
  String get notifConflictBody =>
      'Your local attendance does not match the latest server record.';

  @override
  String get notifPendingReviewTitle => 'New attendance correction request';

  @override
  String get notifPendingReviewBody =>
      'A correction request is waiting for review.';

  @override
  String get notifLeaveSubmittedTitle => 'Leave request submitted';

  @override
  String get notifLeaveSubmittedBody =>
      'Your leave request was submitted for approval.';

  @override
  String get notifLeaveApprovedTitle => 'Leave request approved';

  @override
  String get notifLeaveApprovedBody => 'Your leave request was approved.';

  @override
  String get notifLeaveRejectedTitle => 'Leave request rejected';

  @override
  String get notifLeaveRejectedBody => 'Your leave request was not approved.';

  @override
  String get notifLeaveCancelledTitle => 'Leave request cancelled';

  @override
  String get notifLeaveCancelledBody => 'A leave request was cancelled.';

  @override
  String get notifLeaveApprovalRequiredTitle => 'Leave approval required';

  @override
  String get notifLeaveApprovalRequiredBody =>
      'A team leave request is waiting for your review.';

  @override
  String get notifUnknownTitle => 'Notification';

  @override
  String get notifUnknownBody => 'You have a new notification.';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(Object count) {
    return '$count min ago';
  }

  @override
  String timeHoursAgo(Object count) {
    return '$count h ago';
  }

  @override
  String get timeYesterday => 'Yesterday';

  @override
  String get profileMyProfile => 'My profile';

  @override
  String get profileOverview => 'Overview';

  @override
  String get profileWorkInformation => 'Work information';

  @override
  String get profileAccountAccess => 'Account and access';

  @override
  String get profileSecurity => 'Security';

  @override
  String get profilePreferences => 'Preferences';

  @override
  String get profileAccess => 'Access';

  @override
  String get profileAdministrativeAccess => 'Administrative access';

  @override
  String get profileEmploymentStatus => 'Employment status';

  @override
  String get profileLoginEmail => 'Login email';

  @override
  String get profileWorkEmail => 'Work email';

  @override
  String get profileMyAttendance => 'My attendance';

  @override
  String get profileViewEmployeeRecord => 'View employment details';

  @override
  String get profileNoEmployeeLinked =>
      'No employee profile is linked to this account.';

  @override
  String get profileTeamUnavailable => 'Team access cannot be resolved.';

  @override
  String get profileEmploymentUnavailable =>
      'Employment information is currently unavailable.';

  @override
  String get profileCurrentCompany => 'Current company';

  @override
  String get profileManage => 'Manage';

  @override
  String get settingsIntro =>
      'Manage your organization, attendance configuration and preferences.';

  @override
  String get settingsAttendanceCategory => 'Attendance configuration';

  @override
  String get settingsAttendanceCategoryDesc =>
      'Configure how employees work and record attendance.';

  @override
  String get settingsPreferencesCategory => 'Personal preferences';

  @override
  String get settingsPreferencesCategoryDesc =>
      'Adjust your own app preferences.';

  @override
  String get settingsSystemCategory => 'System';

  @override
  String get settingsSystemCategoryDesc => 'Sync and application status.';

  @override
  String get settingsShiftDesc =>
      'Set working hours, working days and break defaults.';

  @override
  String get settingsLocationDesc =>
      'Manage workplaces and attendance location rules.';

  @override
  String get settingsPolicyDesc =>
      'Define attendance, break and correction rules.';

  @override
  String get settingsLanguageDesc =>
      'Choose your preferred application language.';

  @override
  String get settingsNotificationsDesc =>
      'Control attendance reminders for your account.';

  @override
  String get settingsSyncDesc => 'View sync status and retry failed changes.';

  @override
  String get shellLeave => 'Leave';

  @override
  String get settingsLeaveCategory => 'Leave & holidays';

  @override
  String get settingsLeaveCategoryDesc =>
      'Configure leave types, policies and holidays.';

  @override
  String get permissionAccessUsersView => 'View Users & Access';

  @override
  String get permissionAccessPermissionsManage => 'Manage user access';

  @override
  String get permissionCompanyModulesView => 'View company modules';

  @override
  String get permissionPlatformModulesManage => 'Manage platform modules';

  @override
  String get accessModulePlatform => 'Administration';

  @override
  String get accessSubAccess => 'Access & modules';

  @override
  String get accessUsersView => 'View users & access';

  @override
  String get accessUsersViewDesc =>
      'Open the Users & Access administration area.';

  @override
  String get accessPermissionsManage => 'Manage user access';

  @override
  String get accessPermissionsManageDesc =>
      'Grant and revoke ERP permissions and scopes.';

  @override
  String get accessModulesView => 'View company modules';

  @override
  String get accessModulesViewDesc =>
      'See which ERP modules are enabled for the company.';

  @override
  String get accessCompanyUsersManage => 'Manage company users';

  @override
  String get accessCompanyUsersManageDesc => 'Manage company user accounts.';

  @override
  String get accessPlatformCompaniesManage => 'Manage platform companies';

  @override
  String get accessPlatformCompaniesManageDesc =>
      'Platform-only: manage companies across the platform.';

  @override
  String get accessPlatformModulesManage => 'Manage platform modules';

  @override
  String get accessPlatformModulesManageDesc =>
      'Platform-only: enable or disable modules for companies.';

  @override
  String get usersAccessTitle => 'Users & access';

  @override
  String get usersAccessSubtitle =>
      'Control what each user can access and what records they can work with.';

  @override
  String get accessCompanyModules => 'Company modules';

  @override
  String get accessCompanyModulesSubtitle =>
      'Which ERP modules are enabled for this company.';

  @override
  String get accessManage => 'Manage access';

  @override
  String get accessNoLogin => 'No login';

  @override
  String get accessNoBusinessAccess => 'No business access assigned.';

  @override
  String get accessModuleHr => 'HR';

  @override
  String get accessModuleServices => 'Services';

  @override
  String get accessScopeNone => 'No access';

  @override
  String get accessScopeSelf => 'Self (own records)';

  @override
  String get accessScopeAssigned => 'Assigned to me';

  @override
  String get accessScopeTeam => 'Team (my team)';

  @override
  String get accessScopeAll => 'Company (all)';

  @override
  String get accessSaveChanges => 'Save changes';

  @override
  String get accessResetChanges => 'Reset';

  @override
  String get accessSaved => 'Access updated.';

  @override
  String get accessSaveFailed => 'Could not update access.';

  @override
  String get accessConfirmTitle => 'Update access?';

  @override
  String get accessConfirmMessage => 'Apply the access changes for this user?';

  @override
  String get accessAdded => 'Added';

  @override
  String get accessRemoved => 'Removed';

  @override
  String get accessChanged => 'Changed';

  @override
  String get accessNoChanges => 'No changes';

  @override
  String get accessSummary => 'Access summary';

  @override
  String get accessGrantedPermissions => 'Granted permissions';

  @override
  String get accessEmployeeLinked => 'Employee linked';

  @override
  String get accessEmployeeNotLinked => 'No linked employee';

  @override
  String get accessEmployeeLinkRequired =>
      'This access requires a linked active employee record.';

  @override
  String get accessSelfEscalation => 'You cannot change your own access.';

  @override
  String get accessLastAdmin =>
      'The final access administrator cannot be removed.';

  @override
  String get accessNotPermitted => 'You do not have permission to do this.';

  @override
  String get accessModuleDisabled =>
      'This module is not enabled for the company.';

  @override
  String get accessPlatformOnly =>
      'Only a platform administrator can grant this.';

  @override
  String get accessHistory => 'Access history';

  @override
  String get accessNoHistory => 'No access changes yet.';

  @override
  String get accessSearchUsers => 'Search users';

  @override
  String get accessFilterAll => 'All';

  @override
  String get accessEnabled => 'Enabled';

  @override
  String get accessDisabled => 'Disabled';

  @override
  String get accessModulesReadOnly =>
      'Module availability is managed at platform level in this demo.';

  @override
  String get accessStatusActive => 'Active';

  @override
  String get accessStatusInactive => 'Inactive';

  @override
  String get accessLogin => 'Login';

  @override
  String get accessEmployee => 'Employee';

  @override
  String get accessDesignation => 'Designation';

  @override
  String get accessDepartment => 'Department';

  @override
  String get accessClearModule => 'Clear module access';

  @override
  String get accessNoAccessAssigned => 'No access';

  @override
  String get accessPlatformOnlyBadge => 'Platform only';

  @override
  String get accessEmployeeRequiredBadge => 'Requires employee';

  @override
  String get accessGrantView => 'Grant view';

  @override
  String get accessGrantFull => 'Grant full';

  @override
  String get accessClear => 'Clear';

  @override
  String get accessHasAccess => 'Access configured';

  @override
  String get accessFullConfirmTitle => 'Grant full module access?';

  @override
  String get accessFullConfirmMessage =>
      'This grants every delegable permission for this module. You can refine scopes afterwards.';

  @override
  String get accessModuleAccess => 'Module access';

  @override
  String get accessGranted => 'Granted';

  @override
  String get accessNotGranted => 'Not granted';

  @override
  String get accessExpandAll => 'Expand all';

  @override
  String get accessCollapseAll => 'Collapse all';

  @override
  String accessUsersSummary(Object count, Object withAccess) {
    return 'Showing $count users · $withAccess with access';
  }

  @override
  String get accessScopeHint =>
      'Scope sets which records a permission applies to: Self = the user’s own records, Team = their team, Company = all records in the company.';

  @override
  String get accessScopeLabel => 'Scope';

  @override
  String get accessSelfRequiresEmployee =>
      'Personal (self) permissions need a linked employee. This user has no linked employee, so they stay off.';

  @override
  String get accessNoLinkedEmployeeTitle => 'No linked employee';

  @override
  String get accessLinkEmployeeHint =>
      'Personal permissions (punch in/out, my attendance, my leave) apply to an employee record. To enable them, link this user to an employee from HR → Employees → open the employee → Account access.';

  @override
  String get accessLinkedEmployee => 'Linked employee';

  @override
  String get accessNotLinked => 'Not linked';

  @override
  String get demoPersonaPlatformAdmin => 'Super admin';

  @override
  String get demoPersonaCompanyAdmin => 'Company admin';

  @override
  String get demoPersonaHr => 'HR';

  @override
  String get demoPersonaManager => 'Manager';

  @override
  String get demoPersonaEmployee => 'Employee';

  @override
  String get demoAccessPlatformAdmin =>
      'Platform administration · every module and every access';

  @override
  String get demoAccessCompanyAdmin => 'Every company module and access';

  @override
  String get demoAccessHr =>
      'HR: employees, attendance, leave, reports, configuration';

  @override
  String get demoAccessManager => 'Team attendance and team leave approvals';

  @override
  String get demoAccessEmployee => 'Self attendance and self leave';

  @override
  String get authDemoSignIn => 'Sign in';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get employees => 'Employees';

  @override
  String get attendance => 'Attendance';

  @override
  String get requests => 'Requests';

  @override
  String get reports => 'Reports';

  @override
  String get workLocation => 'Work location';

  @override
  String get office => 'Office';

  @override
  String get remote => 'Remote';

  @override
  String get effectiveDate => 'Effective date';

  @override
  String get startTime => 'Start time';

  @override
  String get employee => 'Employee';

  @override
  String get location => 'Location';

  @override
  String get permissionEmployeeViewSelf => 'View own employee record';

  @override
  String get permissionEmployeeViewTeam => 'View team employees';

  @override
  String get permissionEmployeeViewAll => 'View all employees';

  @override
  String get permissionEmployeeCreate => 'Create employees';

  @override
  String get permissionEmployeeUpdate => 'Update employees';

  @override
  String get permissionEmployeeDeactivate => 'Deactivate employees';

  @override
  String get permissionAttendanceViewSelf => 'View own attendance';

  @override
  String get permissionAttendanceViewTeam => 'View team attendance';

  @override
  String get permissionAttendanceViewAll => 'View all attendance';

  @override
  String get permissionAttendancePunchIn => 'Punch in';

  @override
  String get permissionAttendancePunchOut => 'Punch out';

  @override
  String get permissionAttendanceBreak => 'Manage own breaks';

  @override
  String get permissionAttendanceRequestCorrection =>
      'Request attendance corrections';

  @override
  String get permissionAttendanceCorrect => 'Correct attendance';

  @override
  String get permissionAttendanceApprove => 'Approve attendance';

  @override
  String get permissionShiftView => 'View shifts';

  @override
  String get permissionShiftManage => 'Manage shifts';

  @override
  String get permissionWorkLocationView => 'View work locations';

  @override
  String get permissionWorkLocationManage => 'Manage work locations';

  @override
  String get permissionAttendancePolicyView => 'View attendance policies';

  @override
  String get permissionAttendancePolicyManage => 'Manage attendance policies';

  @override
  String get permissionAttendanceReportView => 'View attendance reports';

  @override
  String dashboardMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String dashboardAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String dashboardEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String dashboardDemo(String date) {
    return 'Demo preview · $date';
  }

  @override
  String get dashboardSelfContext => 'Your workday at a glance';

  @override
  String get dashboardNoShiftTitle => 'Work schedule not configured';

  @override
  String get dashboardNoShiftMessage =>
      'No shift has been assigned to your employee profile yet. Contact HR to complete your attendance setup.';

  @override
  String get dashboardThisWeek => 'This week';

  @override
  String get dashboardRecentAttendance => 'Recent attendance';

  @override
  String get dashboardViewFullHistory => 'View full history';

  @override
  String get dashboardNoRecentAttendance => 'No previous attendance yet.';

  @override
  String get dashboardNoRecentAttendanceMessage =>
      'Your completed workdays will appear here.';

  @override
  String get dashboardNoWeek => 'No attendance recorded this week.';

  @override
  String get dashboardWeekOff => 'Week off';

  @override
  String get dashboardTeamContext => 'Your team at a glance';

  @override
  String get dashboardCompanyContext => 'Your company workforce at a glance';

  @override
  String get dashboardNoScope => 'Your workspace';

  @override
  String get dashboardToday => 'Today';

  @override
  String get dashboardMonth => 'This month';

  @override
  String get dashboardEmployees => 'Total employees';

  @override
  String get dashboardTeamSize => 'Team size';

  @override
  String get dashboardPresent => 'Present';

  @override
  String get dashboardLate => 'Late';

  @override
  String get dashboardAbsent => 'Absent';

  @override
  String get dashboardLeave => 'On leave';

  @override
  String get dashboardWorking => 'Currently working';

  @override
  String get dashboardBreak => 'On break';

  @override
  String get dashboardCorrections => 'Pending corrections';

  @override
  String get dashboardHours => 'Work hours';

  @override
  String get dashboardRate => 'Attendance rate';

  @override
  String get dashboardLocations => 'Work locations';

  @override
  String get dashboardUsers => 'Active users';

  @override
  String get dashboardShift => 'Shift';

  @override
  String get dashboardLocation => 'Work location';

  @override
  String get dashboardOffice => 'Hyderabad office · demo';

  @override
  String get dashboardNotStarted => 'Not started · preview';

  @override
  String get dashboardAttendance => 'Attendance status';

  @override
  String get dashboardAttention => 'Needs attention';

  @override
  String get dashboardActivity => 'Recent activity';

  @override
  String get dashboardQuickActions => 'Quick access';

  @override
  String get dashboardStatus => 'Attendance snapshot';

  @override
  String get dashboardOnTime => 'On time';

  @override
  String get dashboardPresentDetail => 'Includes late arrivals';

  @override
  String dashboardLateAlert(String count) {
    return '$count late arrivals to review';
  }

  @override
  String dashboardCorrectionsAlert(String count) {
    return '$count corrections awaiting review';
  }

  @override
  String get dashboardLateAlertDetail => 'Review attendance';

  @override
  String get dashboardCorrectionsAlertDetail => 'Awaiting review';

  @override
  String get dashboardSelfCheckedIn => 'Checked in';

  @override
  String get dashboardSelfBreakStarted => 'Started a break';

  @override
  String get dashboardSelfCorrectionSubmitted => 'Submitted a correction';

  @override
  String dashboardCheckedIn(String name) {
    return '$name checked in';
  }

  @override
  String dashboardBreakStarted(String name) {
    return '$name started a break';
  }

  @override
  String dashboardCorrectionSubmitted(String name) {
    return '$name submitted a correction';
  }

  @override
  String get dashboardActivityDetail => 'Demo attendance activity';

  @override
  String get dashboardNoActivity => 'No recent activity';

  @override
  String get dashboardNoAttention => 'Nothing needs attention';

  @override
  String get dashboardEmptyTitle => 'No workforce data yet';

  @override
  String get dashboardEmptyMessage =>
      'Workforce insights appear here when data and access are available.';

  @override
  String get dashboardError =>
      'We couldn’t load your dashboard. Please try again.';

  @override
  String get dashboardRefreshError =>
      'Refresh failed. Your previous snapshot is still available.';

  @override
  String get dashboardRefresh => 'Refresh';

  @override
  String get dashboardRefreshing => 'Refreshing dashboard';

  @override
  String dashboardTimeRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get empAdd => 'Add employee';

  @override
  String get empEdit => 'Edit employee';

  @override
  String get empDetails => 'Employee details';

  @override
  String get empPersonal => 'Personal information';

  @override
  String get empEmployment => 'Employment information';

  @override
  String get empAttendanceConfig => 'Attendance configuration';

  @override
  String get empAccountAccess => 'Account access';

  @override
  String get empCode => 'Employee code';

  @override
  String get empFirst => 'First name *';

  @override
  String get empMiddle => 'Middle name';

  @override
  String get empLast => 'Last name (optional)';

  @override
  String get empDepartment => 'Department';

  @override
  String get empDesignation => 'Designation';

  @override
  String get empManager => 'Manager';

  @override
  String get empJoined => 'Joining date';

  @override
  String get empType => 'Employment type';

  @override
  String get empPolicy => 'Attendance policy';

  @override
  String get empLogin => 'Enable app login';

  @override
  String get empGenerated => 'Automatically generated on save';

  @override
  String get empUnassigned => 'Not assigned';

  @override
  String get empLoginNotice =>
      'Local account configuration. New credentials and invitations are not issued in this phase.';

  @override
  String get empCredentialPending => 'Credential setup pending';

  @override
  String get empNoLogin => 'No linked account';

  @override
  String get empActive => 'Active';

  @override
  String get empInactive => 'Inactive';

  @override
  String get empFullTime => 'Full time';

  @override
  String get empPartTime => 'Part time';

  @override
  String get empContract => 'Contract';

  @override
  String get empIntern => 'Intern';

  @override
  String get empTemporary => 'Temporary';

  @override
  String get empFilters => 'Filters';

  @override
  String get empClear => 'Clear filters';

  @override
  String get empApply => 'Apply';

  @override
  String get empReset => 'Reset';

  @override
  String get empAll => 'All';

  @override
  String get empSort => 'Sort';

  @override
  String get empNameAsc => 'Name A–Z';

  @override
  String get empNameDesc => 'Name Z–A';

  @override
  String get empNewest => 'Newest joined';

  @override
  String get empOldest => 'Oldest joined';

  @override
  String get empEmpty => 'No employees yet';

  @override
  String get empEmptyMessage =>
      'Add your first employee to start managing your workforce.';

  @override
  String get empNoResults => 'No employees found';

  @override
  String get empNoResultsMessage => 'Try changing your search or filters.';

  @override
  String get empNotFound => 'Employee not found';

  @override
  String get empNotFoundMessage => 'This employee is unavailable.';

  @override
  String get empView => 'View';

  @override
  String get empActivate => 'Activate employee';

  @override
  String get empDeactivate => 'Deactivate employee';

  @override
  String get empStatusConfirm => 'Change employee status?';

  @override
  String get empStatusMessage =>
      'This changes active workforce status and linked account access. It can be reversed.';

  @override
  String get empCreated => 'Employee created successfully';

  @override
  String get empUpdated => 'Employee updated successfully';

  @override
  String get empStatusSaved => 'Employee status updated';

  @override
  String get empSave => 'Save employee';

  @override
  String get empDiscard => 'Discard changes?';

  @override
  String get empDiscardMessage =>
      'You have unsaved changes. Discard them and leave this form?';

  @override
  String get empDiscardAction => 'Discard';

  @override
  String get empRequired =>
      'Complete the required fields and choose a valid joining date.';

  @override
  String get empInvalidEmail => 'Enter a valid email address.';

  @override
  String get empInvalidPhone => 'Enter a phone number with 7–15 digits.';

  @override
  String get empDuplicateEmail =>
      'This email is already assigned to another employee.';

  @override
  String get empDuplicatePhone =>
      'This phone is already assigned to another employee.';

  @override
  String get empInvalidManager =>
      'Choose an active manager without a circular reporting relationship.';

  @override
  String get empInvalidReference =>
      'Choose an active department and designation.';

  @override
  String get empStorageError =>
      'We couldn’t complete this local operation. Please try again.';

  @override
  String get empPending => 'Pending sync';

  @override
  String get empBack => 'Back to employees';

  @override
  String get empSelfProfile => 'View employee profile';

  @override
  String get empRelated => 'Related records';

  @override
  String get empPreview => 'Attendance preview';

  @override
  String get empSelect => 'Select an option';

  @override
  String get empActions => 'Employee actions';

  @override
  String empCount(String filtered, String total) {
    return '$filtered of $total employees';
  }

  @override
  String empFilterCount(String count) {
    return 'Filters ($count)';
  }

  @override
  String get cfgConfiguration => 'Settings';

  @override
  String get cfgShifts => 'Shifts';

  @override
  String get cfgShift => 'Shift';

  @override
  String get cfgPolicy => 'Attendance policy';

  @override
  String get cfgLocations => 'Work locations';

  @override
  String get cfgPolicies => 'Attendance policies';

  @override
  String get cfgIntro =>
      'Define when, where, and under which rules employees work.';

  @override
  String get cfgShiftIntro => 'Working hours, weekdays, and planned breaks.';

  @override
  String get cfgLocationIntro =>
      'Work addresses and location validation settings.';

  @override
  String get cfgPolicyIntro =>
      'Rules prepared for future attendance workflows.';

  @override
  String get cfgNew => 'Create record';

  @override
  String get cfgEdit => 'Edit record';

  @override
  String get cfgSaved => 'Configuration saved locally.';

  @override
  String get cfgStatusSaved => 'Status updated locally.';

  @override
  String get cfgName => 'Name';

  @override
  String get cfgCode => 'Code (optional)';

  @override
  String get cfgDescription => 'Description';

  @override
  String get cfgAll => 'All statuses';

  @override
  String get cfgActive => 'Active';

  @override
  String get cfgInactive => 'Inactive';

  @override
  String get cfgActivate => 'Activate';

  @override
  String get cfgDeactivate => 'Deactivate';

  @override
  String get cfgStatus => 'Status';

  @override
  String get cfgAssigned => 'Assigned employees';

  @override
  String get cfgDeactivateMessage =>
      'Existing assignments are retained. This record will no longer be available for new assignments.';

  @override
  String get cfgActivateMessage =>
      'Make this record available for new employee assignments.';

  @override
  String get cfgEmpty => 'No configuration records yet';

  @override
  String get cfgEmptyMessage =>
      'Create a record to prepare employee attendance assignments.';

  @override
  String get cfgNoResults => 'No matching records';

  @override
  String get cfgNoResultsMessage => 'Try another search or status filter.';

  @override
  String get cfgNotFound => 'Record not found';

  @override
  String get cfgNotFoundMessage =>
      'This record is unavailable in the current company.';

  @override
  String get cfgRequired => 'This field is required.';

  @override
  String get cfgDuplicateName =>
      'An active record with this name already exists.';

  @override
  String get cfgInvalidTime => 'Choose different valid start and end times.';

  @override
  String get cfgWorkingDaysError => 'Select at least one working day.';

  @override
  String get cfgInvalidGrace =>
      'Grace must be non-negative and shorter than the shift.';

  @override
  String get cfgInvalidBreak => 'Fixed break must be shorter than the shift.';

  @override
  String get cfgInvalidMinimum =>
      'Minimum work must fit within expected working time.';

  @override
  String get cfgInvalidCoordinates =>
      'Enter coordinates within valid latitude and longitude ranges.';

  @override
  String get cfgInvalidRadius => 'Enter a positive, finite radius.';

  @override
  String get cfgInvalidAccuracy => 'Enter a positive, finite accuracy limit.';

  @override
  String get cfgCountryError => 'Enter a two-letter country code.';

  @override
  String get cfgPolicyError =>
      'Require location for at least one attendance event.';

  @override
  String get cfgEarlyError =>
      'Enter an early arrival limit from 0 to 1440 minutes.';

  @override
  String get cfgAssignmentError =>
      'Choose an active record from the current company.';

  @override
  String get cfgStorageError =>
      'Unable to read or save local configuration. Please retry.';

  @override
  String get cfgStart => 'Start time';

  @override
  String get cfgEnd => 'End time';

  @override
  String get cfgDays => 'Working days';

  @override
  String get cfgGrace => 'Grace period';

  @override
  String get cfgBreakMode => 'Break mode';

  @override
  String get cfgManualBreak => 'Manual breaks';

  @override
  String get cfgFixedBreak => 'Fixed planned break';

  @override
  String get cfgNoBreak => 'No breaks';

  @override
  String get cfgBreakMinutes => 'Planned break duration';

  @override
  String get cfgMinimumWork => 'Minimum work duration (optional)';

  @override
  String get cfgDuration => 'Shift duration';

  @override
  String get cfgExpectedWork => 'Expected working time';

  @override
  String get cfgOvernight => 'Overnight shift';

  @override
  String get cfgSchedule => 'Schedule';

  @override
  String get cfgMinutes => 'minutes';

  @override
  String get cfgMeters => 'meters';

  @override
  String get cfgAddress => 'Address';

  @override
  String get cfgAddress1 => 'Address line 1';

  @override
  String get cfgAddress2 => 'Address line 2 (optional)';

  @override
  String get cfgCity => 'City';

  @override
  String get cfgState => 'State / region';

  @override
  String get cfgPostal => 'Postal code';

  @override
  String get cfgCountry => 'Country code';

  @override
  String get cfgLatitude => 'Latitude';

  @override
  String get cfgLongitude => 'Longitude';

  @override
  String get cfgRadius => 'Allowed radius';

  @override
  String get cfgAccuracy => 'Maximum accepted accuracy';

  @override
  String get cfgValidationMode => 'Location validation';

  @override
  String get cfgGeofenceRequired => 'Geofence required';

  @override
  String get cfgGeofencePreferred => 'Geofence preferred';

  @override
  String get cfgCaptureOnly => 'Capture location only';

  @override
  String get cfgNoLocation => 'No location validation';

  @override
  String get cfgPreview => 'Location preview';

  @override
  String get cfgPreviewNote =>
      'Coordinates and radius preview. A map provider can be added later.';

  @override
  String get cfgCurrentLocation => 'Use current location';

  @override
  String get cfgLocating => 'Finding location…';

  @override
  String get cfgOpenSettings => 'Open settings';

  @override
  String get cfgLocationDenied =>
      'Location permission was denied. You can enter coordinates manually.';

  @override
  String get cfgLocationPermanent =>
      'Location permission is blocked. Enable it in app settings.';

  @override
  String get cfgLocationDisabled =>
      'Location services are off. Enable them in device settings.';

  @override
  String get cfgLocationTimeout =>
      'Location request timed out. Retry or enter coordinates manually.';

  @override
  String get cfgLocationUnavailable =>
      'Current location is unavailable. You can enter coordinates manually.';

  @override
  String get cfgPoorAccuracy =>
      'The captured position has poor accuracy. Review these coordinates before saving.';

  @override
  String get cfgCapturedAccuracy => 'Captured accuracy';

  @override
  String get cfgLocationRules => 'Location rules';

  @override
  String get cfgBreakRules => 'Break rules';

  @override
  String get cfgTimingRules => 'Timing rules';

  @override
  String get cfgOfflineRules => 'Offline behavior';

  @override
  String get cfgGeneralRules => 'General rules';

  @override
  String get cfgRequireLocation => 'Require location';

  @override
  String get cfgOutside => 'Allow attendance outside the assigned location';

  @override
  String get cfgRemote => 'Allow remote attendance';

  @override
  String get cfgLocationIn => 'Require location on punch in';

  @override
  String get cfgLocationOut => 'Require location on punch out';

  @override
  String get cfgLocationBreak => 'Require location for breaks';

  @override
  String get cfgRequireAccuracy => 'Require acceptable location accuracy';

  @override
  String get cfgTrackBreaks => 'Track breaks';

  @override
  String get cfgMultipleBreaks => 'Allow multiple breaks';

  @override
  String get cfgOutDuringBreak => 'Allow punch out during a break';

  @override
  String get cfgCorrections => 'Allow employee correction requests';

  @override
  String get cfgEarlyIn => 'Allow early punch in';

  @override
  String get cfgEarlyLimit => 'Early arrival limit';

  @override
  String get cfgLateIn => 'Allow late punch in';

  @override
  String get cfgEarlyOut => 'Allow early punch out';

  @override
  String get cfgOfflineMode => 'Offline attendance mode';

  @override
  String get cfgOfflineNo => 'Not allowed';

  @override
  String get cfgOfflinePending => 'Allow pending validation';

  @override
  String get cfgOfflineWarning => 'Allow with a warning';

  @override
  String get cfgYes => 'Allowed';

  @override
  String get cfgNo => 'Not allowed';

  @override
  String get cfgFoundationNote =>
      'Configuration only. Attendance actions and rule evaluation will be implemented in Phase 6.';

  @override
  String get cfgInactiveAssignment => 'Inactive • current assignment retained';

  @override
  String get cfgMon => 'Mon';

  @override
  String get cfgTue => 'Tue';

  @override
  String get cfgWed => 'Wed';

  @override
  String get cfgThu => 'Thu';

  @override
  String get cfgFri => 'Fri';

  @override
  String get cfgSat => 'Sat';

  @override
  String get cfgSun => 'Sun';

  @override
  String get cfgActions => 'Actions';

  @override
  String get cfgValidation => 'Review the highlighted fields before saving.';

  @override
  String get cfgPending => 'Pending sync';

  @override
  String get cfgView => 'View';

  @override
  String get cfgKeepEditing => 'Keep editing';

  @override
  String get cfgDiscard => 'Discard changes?';

  @override
  String get cfgDiscardMessage =>
      'You have unsaved changes. Discard them and leave this form?';

  @override
  String get cfgDiscardAction => 'Discard changes';

  @override
  String get attendanceNotLinkedToEmployee =>
      'No employee profile is linked to this account';

  @override
  String get attendanceEmployeeInactive => 'Employee account is inactive';

  @override
  String get attendanceAccountInactive =>
      'Your account is inactive or your session has ended';

  @override
  String get attendancePermissionDenied =>
      'You do not have permission for this attendance action';

  @override
  String get attendanceShiftNotAssigned => 'No shift is assigned';

  @override
  String get attendancePolicyNotAssigned => 'No attendance policy is assigned';

  @override
  String get attendanceWorkLocationRequiredButMissing =>
      'No work location is assigned';

  @override
  String get attendanceLocationRequired => 'Location is required';

  @override
  String get attendanceLocationUnavailable => 'Your location is unavailable';

  @override
  String get attendanceLocationPermissionDenied =>
      'Location permission is required';

  @override
  String get attendanceLocationServicesDisabled =>
      'Location services are disabled';

  @override
  String get attendanceLocationAccuracyTooLow => 'Location accuracy is too low';

  @override
  String get attendanceOutsideAllowedLocation =>
      'You are outside the allowed work location';

  @override
  String get attendanceAlreadyPunchedIn => 'You have already punched in';

  @override
  String get attendanceNotPunchedIn => 'Not punched in';

  @override
  String get attendanceAlreadyOnBreak => 'You are already on a break';

  @override
  String get attendanceNotOnBreak => 'No active break was found';

  @override
  String get attendanceBreakTrackingDisabled => 'Break tracking is disabled';

  @override
  String get attendanceMultipleBreaksNotAllowed =>
      'Multiple breaks are not allowed';

  @override
  String get attendancePunchOutDuringBreakNotAllowed =>
      'Punch out is not allowed during a break';

  @override
  String get attendanceAlreadyCompleted => 'Your workday is already complete';

  @override
  String get attendanceTooEarlyToPunchIn => 'You are too early to punch in';

  @override
  String get attendanceLatePunchInNotAllowed => 'Late punch in is not allowed';

  @override
  String get attendanceEarlyPunchOutNotAllowed =>
      'Early punch out is not allowed';

  @override
  String get attendanceUnscheduledDay => 'This is not a scheduled working day';

  @override
  String get attendanceOfflineAttendanceNotAllowed =>
      'Offline attendance is not allowed';

  @override
  String get attendanceInvalidAttendanceState =>
      'The attendance timeline is inconsistent';

  @override
  String get attendancePersistenceFailure =>
      'Attendance could not be saved. Please retry';

  @override
  String get attendanceInvalidLocationEvidence =>
      'Location evidence is invalid';

  @override
  String get attendanceStaleLocationEvidence =>
      'Please capture your location again';

  @override
  String get attendanceRemoteAttendanceNotAllowed =>
      'Remote attendance is not allowed';

  @override
  String get attendanceInvalidTimestamp =>
      'The attendance timestamp is invalid';

  @override
  String get attendanceDuplicateRequestId =>
      'This attendance request has already been submitted';

  @override
  String get attendanceOperationNotFound =>
      'The attendance operation was not found';

  @override
  String get attendanceSyncUnavailable => 'Attendance sync is not configured';

  @override
  String get attendanceSynchronizationFailed =>
      'Attendance synchronization failed';

  @override
  String get attendanceUnsupportedTimezone =>
      'The company timezone is not supported yet';

  @override
  String get attendanceCompanyUnavailable =>
      'Attendance is unavailable for this company';

  @override
  String get attendanceWarningOutsideAllowedLocation =>
      'Outside the office location; attendance is permitted';

  @override
  String get attendanceWarningOfflinePending =>
      'Attendance saved and waiting to sync';

  @override
  String get attendanceWarningLatePunchIn => 'Late punch in';

  @override
  String get attendanceWarningEarlyPunchOut => 'Early punch out';

  @override
  String get attendanceWarningUnscheduledDay =>
      'Attendance on an unscheduled day';

  @override
  String get attendanceNotStarted => 'Not started';

  @override
  String get attendanceWorking => 'Working';

  @override
  String get attendanceOnBreak => 'On break';

  @override
  String get attendanceCompleted => 'Completed';

  @override
  String get attendanceLate => 'Late';

  @override
  String get attendancePending => 'Pending sync';

  @override
  String get attendanceSynced => 'Synced';

  @override
  String get attendanceFailed => 'Sync failed';

  @override
  String get attendanceRejected => 'Rejected';

  @override
  String get attendancePunchIn => 'Punch in';

  @override
  String get attendanceBreakStart => 'Start break';

  @override
  String get attendanceBreakEnd => 'Resume work';

  @override
  String get attendancePunchOut => 'Punch out';

  @override
  String get attendancePunchInNotAllowed => 'Punch in is not allowed';

  @override
  String get attendanceTodayTitle => 'Today\'s attendance';

  @override
  String get attendanceWorkday => 'YOUR WORKDAY';

  @override
  String get attendanceCompleteTitle => 'Workday complete';

  @override
  String get attendancePunchingIn => 'Punching in…';

  @override
  String get attendancePunchingOut => 'Punching out…';

  @override
  String get attendanceTakeBreak => 'Take break';

  @override
  String get attendanceStartingBreak => 'Starting break…';

  @override
  String get attendanceResumeWork => 'Resume work';

  @override
  String get attendanceResumingWork => 'Resuming work…';

  @override
  String get attendanceWorkTime => 'Current work time';

  @override
  String get attendanceCurrentLoggedWorkTime =>
      'Current Logged Work Time (Today)';

  @override
  String attendanceInsideGeofence(String name, String distance) {
    return 'Inside $name Geofence ($distance)';
  }

  @override
  String get attendanceCurrentBreak => 'Current break';

  @override
  String get attendanceTotalBreak => 'Total break';

  @override
  String get attendanceElapsedTime => 'Elapsed time';

  @override
  String get attendanceWorkedTime => 'Worked time';

  @override
  String get attendanceBreakTime => 'Break time';

  @override
  String get attendanceTodayShift => 'Today\'s shift';

  @override
  String get attendanceWorkLocation => 'Work location';

  @override
  String get attendanceLocationChecking => 'Checking your location…';

  @override
  String get attendanceLocationReady => 'Location ready';

  @override
  String get attendanceInsideLocation => 'Inside work location';

  @override
  String get attendanceOutsideLocation => 'Outside work location';

  @override
  String get attendanceLocationNotRequired =>
      'Location verification not required';

  @override
  String get attendanceLocationRequiredNote =>
      'Your location will be checked when you submit this action.';

  @override
  String get attendanceAccuracy => 'Location accuracy';

  @override
  String get attendanceRadius => 'Allowed radius';

  @override
  String get attendanceRefreshLocation => 'Refresh location';

  @override
  String get attendanceAllowLocation => 'Allow location';

  @override
  String get attendanceOpenSettings => 'Open settings';

  @override
  String get attendancePermissionSettings =>
      'Location permission is disabled in system settings.';

  @override
  String get attendanceServicesNote => 'Turn on location services to continue.';

  @override
  String get attendanceNoActivity => 'No activity yet';

  @override
  String get attendanceActivityNote =>
      'Your punch-in and break activity will appear here.';

  @override
  String get attendanceTodayActivity => 'Today\'s activity';

  @override
  String get attendancePunchInTime => 'Punch-in time';

  @override
  String get attendancePunchOutTime => 'Punch out';

  @override
  String get attendanceCurrentTime => 'Current time';

  @override
  String get attendanceBreakStartedLabel => 'Break started';

  @override
  String get attendanceWorkResumedLabel => 'Work resumed';

  @override
  String get attendanceEndWorkday => 'End your workday?';

  @override
  String get attendanceConfirmAction => 'Confirm attendance action';

  @override
  String get attendanceContinue => 'Continue';

  @override
  String get attendanceCloseBreakNote =>
      'Your current break will end when you punch out.';

  @override
  String get attendancePendingTitle => 'Pending sync';

  @override
  String get attendancePendingNote =>
      'Saved on this device. Waiting for verification when sync becomes available.';

  @override
  String get attendanceFailedTitle => 'Attendance sync needs attention';

  @override
  String get attendanceFailedNote =>
      'Your attendance is saved locally but could not be verified.';

  @override
  String get attendanceRejectedTitle => 'Attendance could not be verified';

  @override
  String get attendanceRejectedNote =>
      'Your recorded events are retained. Contact HR to resolve this issue.';

  @override
  String get attendanceRetrySync => 'Retry sync';

  @override
  String get attendanceRequeuedNote =>
      'Attendance is queued for sync. No sync service is configured yet.';

  @override
  String get attendanceNotConfigured => 'Attendance is not configured yet';

  @override
  String get attendanceContactHr =>
      'Contact HR to complete your attendance setup.';

  @override
  String get attendanceUnavailableTitle => 'Attendance unavailable';

  @override
  String get attendanceStartNote => 'Punch in to begin your workday.';

  @override
  String get attendanceWorkingNote =>
      'Your work time is calculated from recorded activity.';

  @override
  String get attendanceBreakNote =>
      'Work time is paused while you are on a break.';

  @override
  String get attendanceCompleteNote =>
      'Your final totals and activity are recorded below.';

  @override
  String get attendanceExpectedHours => 'Expected work';

  @override
  String get attendanceGrace => 'Grace period';

  @override
  String get attendanceOnTime => 'On-time';

  @override
  String get attendanceTarget => 'Target';

  @override
  String get attendanceShiftRemaining => 'Shift remaining';

  @override
  String get attendanceOpenAttendance => 'Open attendance';

  @override
  String get attendanceViewAttendance => 'View attendance';

  @override
  String get attendanceStartsAt => 'Starts at';

  @override
  String get attendanceWorked => 'Worked';

  @override
  String get attendanceBreak => 'Break';

  @override
  String get attendanceLastCheck => 'Last location check';

  @override
  String get attendanceCheckingSetup => 'Loading attendance setup';

  @override
  String get attendanceWarningNote =>
      'Review these details before recording your attendance.';

  @override
  String get attendanceDistance => 'Distance from work location';

  @override
  String get attendanceTryAgain => 'Try again';

  @override
  String get attendanceLocationCaptureReady => 'Location captured';

  @override
  String get attendanceAccuracyLimit => 'Required accuracy';

  @override
  String get attendanceNoLocation => 'No work location assigned';

  @override
  String get attendanceGoodMorning => 'Good morning';

  @override
  String get attendanceGoodAfternoon => 'Good afternoon';

  @override
  String get attendanceGoodEvening => 'Good evening';

  @override
  String attendanceMeters(String value) {
    return '$value m';
  }

  @override
  String get historyTitle => 'Attendance history';

  @override
  String get historyNav => 'History';

  @override
  String get historyMonthlySummary => 'Monthly summary';

  @override
  String get historyPreviousMonth => 'Previous month';

  @override
  String get historyNextMonth => 'Next month';

  @override
  String get historyPresent => 'Present';

  @override
  String get historyLate => 'Late';

  @override
  String get historyIncomplete => 'Incomplete';

  @override
  String get historyCompletedOnly =>
      'Work and break totals include completed records only.';

  @override
  String get historyEmpty => 'No attendance records';

  @override
  String get historyFilteredEmpty => 'No matching attendance records';

  @override
  String get historyEmptyNote => 'No activity was recorded in this month.';

  @override
  String get historyFilteredNote => 'Try another status or clear your filters.';

  @override
  String get historyClearFilters => 'Clear filters';

  @override
  String get historyAllStatuses => 'All statuses';

  @override
  String get historyFilters => 'Status filters';

  @override
  String get historyApply => 'Apply filters';

  @override
  String get historyReset => 'Reset';

  @override
  String get historyDetails => 'Attendance details';

  @override
  String get historyDailySummary => 'Daily summary';

  @override
  String get historyTimeline => 'Timeline';

  @override
  String get historyBreaks => 'Breaks';

  @override
  String get historyMissingOut => 'Missing punch out';

  @override
  String get historyOpenBreak => 'Incomplete break';

  @override
  String get historyNotRecorded => 'Not recorded';

  @override
  String get historyNeedsAttention => 'Needs attention';

  @override
  String get historyIncompleteNote =>
      'This record has no punch out. Final work and break totals are unavailable.';

  @override
  String get historyOpenBreakNote =>
      'No resume recorded. This break has no final duration.';

  @override
  String get historyGoToday => 'Open today’s attendance';

  @override
  String get historyActiveNote =>
      'This record is still open. Use Today for live totals and attendance actions.';

  @override
  String get historyNotFound => 'Attendance record unavailable';

  @override
  String get historyNotFoundNote =>
      'This record was not found in your attendance history.';

  @override
  String get historyOvernight => 'Overnight shift';

  @override
  String get historyExpected => 'Expected duration';

  @override
  String get historyGrace => 'Grace period';

  @override
  String get historyWithinArea => 'Within assigned area';

  @override
  String get historyOutsideAllowed =>
      'Outside assigned area · allowed by policy';

  @override
  String get historyVerificationIssue => 'Verification issue';

  @override
  String get historyContactHr =>
      'The original record is retained. Contact HR about this verification issue.';

  @override
  String get historyDate => 'Date';

  @override
  String get historyStatus => 'Status';

  @override
  String get historyNow => 'Now';

  @override
  String get historyRetry => 'Refresh';

  @override
  String get historyAverageWork => 'Average worked per completed day';

  @override
  String get historyNoBreaks => 'No breaks recorded';

  @override
  String historyFilterCount(String count) {
    return 'Status filters ($count)';
  }

  @override
  String get correctionRequest => 'Request correction';

  @override
  String get correctionMyRequests => 'My requests';

  @override
  String get correctionReviewQueue => 'Correction requests';

  @override
  String get correctionType => 'Correction type';

  @override
  String get correctionRequestedTime => 'Requested date and time';

  @override
  String get correctionReason => 'Reason';

  @override
  String get correctionReviewNote => 'Review note';

  @override
  String get correctionSubmit => 'Submit request';

  @override
  String get correctionCancel => 'Cancel request';

  @override
  String get correctionApprove => 'Approve';

  @override
  String get correctionReject => 'Reject';

  @override
  String get correctionPending => 'Pending';

  @override
  String get correctionApproved => 'Approved';

  @override
  String get correctionRejected => 'Rejected';

  @override
  String get correctionCancelled => 'Cancelled';

  @override
  String get correctionOriginal => 'Original';

  @override
  String get correctionRequested => 'Requested';

  @override
  String get correctionNoRequests => 'No correction requests';

  @override
  String get correctionMissingPunchIn => 'Missing punch in';

  @override
  String get correctionMissingPunchOut => 'Missing punch out';

  @override
  String get correctionChangePunchIn => 'Change punch in time';

  @override
  String get correctionChangePunchOut => 'Change punch out time';

  @override
  String get correctionMissingBreakStart => 'Missing break start';

  @override
  String get correctionMissingBreakEnd => 'Missing break end';

  @override
  String get correctionChangeBreakStart => 'Change break start time';

  @override
  String get correctionChangeBreakEnd => 'Change break end time';

  @override
  String get correctionPreview => 'Effective result preview';

  @override
  String get correctionInvalid => 'Check the requested time and event order.';

  @override
  String get correctionSaved => 'Correction request submitted';

  @override
  String get correctionReviewSaved => 'Review saved';

  @override
  String get correctionReasonRequired => 'Enter a reason';

  @override
  String get workforceTeam => 'Team attendance';

  @override
  String get workforceAll => 'All attendance';

  @override
  String get workforceNotStarted => 'Not started';

  @override
  String get workforceWorking => 'Working';

  @override
  String get workforceOnBreak => 'On break';

  @override
  String get workforceCompleted => 'Completed';

  @override
  String get workforceIncomplete => 'Incomplete';

  @override
  String get workforceNoSchedule => 'No schedule';

  @override
  String get workforceNoRecord => 'No record';

  @override
  String get workforceSearch => 'Search employees';

  @override
  String get workforceNoEmployees => 'No employees match';

  @override
  String get workforceDepartment => 'Department';

  @override
  String get workforceShift => 'Shift';

  @override
  String get workforceLocation => 'Work location';

  @override
  String get workforceDate => 'Attendance date';

  @override
  String get workforceToday => 'Today';

  @override
  String get workforcePrevious => 'Previous day';

  @override
  String get workforceNext => 'Next day';

  @override
  String get workforcePendingCorrection => 'Pending correction';

  @override
  String get workforceSort => 'Sort by';

  @override
  String get workforceName => 'Name';

  @override
  String get workforceNameDescending => 'Name (Z–A)';

  @override
  String get workforceCode => 'Employee code';

  @override
  String get workforceAllFilter => 'All';

  @override
  String get reportTitle => 'Attendance reports';

  @override
  String get reportOverview => 'Overview';

  @override
  String get reportWorkHours => 'Work hours';

  @override
  String get reportLate => 'Late attendance';

  @override
  String get reportBreaks => 'Break analysis';

  @override
  String get reportIssues => 'Attendance issues';

  @override
  String get reportEmployees => 'Employee summary';

  @override
  String get reportToday => 'Today';

  @override
  String get reportThisWeek => 'This week';

  @override
  String get reportThisMonth => 'This month';

  @override
  String get reportLastMonth => 'Last month';

  @override
  String get reportCustom => 'Custom range';

  @override
  String get reportFrom => 'From';

  @override
  String get reportTo => 'To';

  @override
  String get reportScopeTeam => 'My team';

  @override
  String get reportScopeCompany => 'Company';

  @override
  String get reportRecordedDays => 'Recorded workdays';

  @override
  String get reportCompletedDays => 'Completed workdays';

  @override
  String get reportLateDays => 'Late records';

  @override
  String get reportIncompleteDays => 'Incomplete records';

  @override
  String get reportWorkTotal => 'Worked time';

  @override
  String get reportBreakTotal => 'Break time';

  @override
  String get reportAverageWork => 'Average per recorded day';

  @override
  String get reportPendingCorrections => 'Pending corrections';

  @override
  String get reportIssueDays => 'Days with issues';

  @override
  String get reportTrend => 'Recorded workdays by date';

  @override
  String get reportDaily => 'Daily';

  @override
  String get reportWeekly => 'Weekly';

  @override
  String get reportMonthly => 'Monthly';

  @override
  String get reportGroupBy => 'Group by';

  @override
  String get reportNoData =>
      'No recorded attendance matches this period and filters.';

  @override
  String get reportInProgress =>
      'Today\'s active attendance is provisional until punch out.';

  @override
  String get reportFilter => 'Filters';

  @override
  String get reportClearFilters => 'Clear filters';

  @override
  String get reportEmployee => 'Employee';

  @override
  String get reportStatus => 'Status';

  @override
  String get reportCorrections => 'Corrections';

  @override
  String get reportAny => 'Any';

  @override
  String get reportYes => 'Yes';

  @override
  String get reportNo => 'No';

  @override
  String get reportApply => 'Apply';

  @override
  String get reportExport => 'Export';

  @override
  String get reportCsv => 'Export CSV';

  @override
  String get reportPdf => 'Export PDF';

  @override
  String get reportExported => 'Report saved';

  @override
  String get reportExportFailed => 'Could not export report';

  @override
  String get reportLoading => 'Loading report';

  @override
  String get reportRefreshFailed => 'Could not refresh report';

  @override
  String get reportUnavailable => 'Attendance reports are unavailable.';

  @override
  String get reportDate => 'Date';

  @override
  String get reportWorked => 'Worked';

  @override
  String get reportBreak => 'Break';

  @override
  String get reportLateBy => 'Late by';

  @override
  String get reportRecorded => 'Recorded days';

  @override
  String get reportCompleted => 'Completed';

  @override
  String get reportLateCount => 'Late';

  @override
  String get reportIssuesCount => 'Issues';

  @override
  String get reportPending => 'Pending';

  @override
  String get reportShiftStart => 'Shift start';

  @override
  String get reportPunchIn => 'Punch in';

  @override
  String get reportDepartment => 'Department';

  @override
  String get reportLocation => 'Location';

  @override
  String get reportPeriod => 'Period';

  @override
  String get reportGenerated => 'Generated';

  @override
  String get reportPage => 'Page';

  @override
  String get reportSortNewest => 'Newest first';

  @override
  String get reportSortOldest => 'Oldest first';

  @override
  String get reportSortEmployee => 'Employee name';

  @override
  String get reportSortWork => 'Most worked time';

  @override
  String get reportSortBreak => 'Most break time';

  @override
  String get reportFiltersApplied => 'Applied filters';

  @override
  String get attendanceNeedsReview => 'Attendance needs review';

  @override
  String get attendanceConflict => 'Attendance conflict';

  @override
  String get attendanceConflictMessage =>
      'Your local attendance does not match the latest server record.';

  @override
  String get attendanceCouldNotBeVerified => 'Attendance could not be verified';

  @override
  String get attendanceNeedsAttention => 'Attendance needs attention';

  @override
  String get reportSubtitle =>
      'Analyze attendance activity, work hours, timing and record quality.';

  @override
  String get reportActivityTrend => 'Attendance activity';

  @override
  String get reportActivityTrendDesc => 'Recorded records by date.';

  @override
  String get reportStatusDistribution => 'Attendance status';

  @override
  String get reportStatusDistributionDesc => 'Composition of recorded records.';

  @override
  String get reportWorkHoursTrend => 'Recorded work hours';

  @override
  String get reportWorkHoursTrendDesc => 'Total recorded work time by date.';

  @override
  String get reportLateTrend => 'Late attendance';

  @override
  String get reportLateTrendDesc => 'Late records by date.';

  @override
  String get reportBreakTrend => 'Break time';

  @override
  String get reportBreakTrendDesc => 'Recorded break time by date.';

  @override
  String get reportIssuesByType => 'Issues by type';

  @override
  String get reportIssuesByTypeDesc => 'What needs attention in this period.';

  @override
  String get reportNeedsAttention => 'Needs attention';

  @override
  String get reportDetailedRecords => 'Detailed records';

  @override
  String get reportStatusWorking => 'Working';

  @override
  String get reportStatusCompleted => 'Completed';

  @override
  String get reportStatusLate => 'Late';

  @override
  String get reportStatusIssues => 'Issues';

  @override
  String get reportIssueRejected => 'Rejected attendance';

  @override
  String get reportIssueSyncFailure => 'Sync failure';

  @override
  String get reportIssuePendingCorrection => 'Pending correction';

  @override
  String get reportIssueMissingPunchOut => 'Missing punch out';

  @override
  String get reportViewTeam => 'Team view';

  @override
  String get reportViewCompany => 'Company view';

  @override
  String get reportRecordedEmployees => 'Recorded employees';

  @override
  String get permissionLeaveViewSelf => 'View own leave';

  @override
  String get permissionLeaveRequest => 'Request leave';

  @override
  String get permissionLeaveCancelSelf => 'Cancel own leave';

  @override
  String get permissionLeaveViewTeam => 'View team leave';

  @override
  String get permissionLeaveApproveTeam => 'Approve team leave';

  @override
  String get permissionLeaveViewAll => 'View company leave';

  @override
  String get permissionLeaveApproveAll => 'Approve company leave';

  @override
  String get permissionLeaveManage => 'Manage leave';

  @override
  String get permissionLeaveBalanceViewSelf => 'View own leave balance';

  @override
  String get permissionLeaveBalanceViewTeam => 'View team leave balances';

  @override
  String get permissionLeaveBalanceViewAll => 'View company leave balances';

  @override
  String get permissionLeaveBalanceAdjust => 'Adjust leave balances';

  @override
  String get permissionLeaveTypeView => 'View leave types';

  @override
  String get permissionLeaveTypeManage => 'Manage leave types';

  @override
  String get permissionLeavePolicyView => 'View leave policies';

  @override
  String get permissionLeavePolicyManage => 'Manage leave policies';

  @override
  String get permissionHolidayView => 'View holidays';

  @override
  String get permissionHolidayManage => 'Manage holidays';

  @override
  String get permissionLeaveReportView => 'View leave reports';

  @override
  String get leaveMyLeave => 'My leave';

  @override
  String get leaveNewRequest => 'New request';

  @override
  String get leaveMyRequests => 'My requests';

  @override
  String get leaveApprovals => 'Approvals';

  @override
  String get leaveTeam => 'Team leave';

  @override
  String get leaveAllNav => 'All leave';

  @override
  String get leaveBalancesNav => 'Balances';

  @override
  String get leaveCalendarNav => 'Calendar';

  @override
  String get leaveTypesNav => 'Leave types';

  @override
  String get leavePoliciesNav => 'Leave policies';

  @override
  String get holidaysNav => 'Holidays';

  @override
  String get leaveTypeIntro =>
      'Configure the kinds of leave employees can request.';

  @override
  String get leavePolicyIntro =>
      'Define entitlement and request rules for each leave type.';

  @override
  String get holidayIntro => 'Configure public, company and optional holidays.';

  @override
  String get leaveType => 'Leave type';

  @override
  String get leaveCompensation => 'Compensation';

  @override
  String get leaveRequiresApproval => 'Requires approval';

  @override
  String get leaveAllowsHalfDay => 'Allows half day';

  @override
  String get leaveRequiresReason => 'Reason required';

  @override
  String get leaveRequiresAttachment => 'Attachment required';

  @override
  String get leaveCompensationPaid => 'Paid';

  @override
  String get leaveCompensationUnpaid => 'Unpaid';

  @override
  String get leaveCompensationInformational => 'Informational';

  @override
  String get leavePolicy => 'Leave policy';

  @override
  String get leavePolicyLeaveType => 'Leave type';

  @override
  String get leavePolicyEntitlement => 'Annual entitlement';

  @override
  String get leavePolicyMinDays => 'Minimum request';

  @override
  String get leavePolicyMaxConsecutive => 'Maximum consecutive days';

  @override
  String get leavePolicyAdvanceNotice => 'Advance notice';

  @override
  String get leavePolicyAllowPast => 'Allow past requests';

  @override
  String get leavePolicyPastWindow => 'Past request window';

  @override
  String get leavePolicyNegative => 'Allow negative balance';

  @override
  String get leavePolicyCarryForward => 'Carry forward';

  @override
  String get leavePolicyCarryLimit => 'Carry forward limit';

  @override
  String get leavePolicyEmployment => 'Applicable employment types';

  @override
  String get days => 'days';

  @override
  String get holiday => 'Holiday';

  @override
  String get holidayDate => 'Date';

  @override
  String get holidayEndDate => 'End date';

  @override
  String get holidayTypeField => 'Type';

  @override
  String get holidayScopeField => 'Scope';

  @override
  String get holidayWorkLocations => 'Work locations';

  @override
  String get holidayOptional => 'Optional holiday';

  @override
  String get holidayTypePublic => 'Public holiday';

  @override
  String get holidayTypeCompany => 'Company holiday';

  @override
  String get holidayTypeOptional => 'Optional holiday';

  @override
  String get holidayTypeSpecial => 'Special closure';

  @override
  String get holidayScopeCompanyWide => 'Company wide';

  @override
  String get holidayScopeSpecific => 'Specific work locations';

  @override
  String get leaveRequestTitle => 'Request leave';

  @override
  String get leaveStartDate => 'Start date';

  @override
  String get leaveEndDate => 'End date';

  @override
  String get leaveStartPortion => 'First day';

  @override
  String get leaveEndPortion => 'Last day';

  @override
  String get leaveDayFull => 'Full day';

  @override
  String get leaveDayFirstHalf => 'First half';

  @override
  String get leaveDaySecondHalf => 'Second half';

  @override
  String get leaveReasonLabel => 'Reason';

  @override
  String get leaveAttachmentLabel => 'Attachment';

  @override
  String get leavePreviewTitle => 'Summary';

  @override
  String get leaveRequestedDays => 'Requested days';

  @override
  String get leaveAvailableDays => 'Available';

  @override
  String get leaveAfterApproval => 'After approval';

  @override
  String get leaveExcludedWeekends => 'Weekends excluded';

  @override
  String get leaveExcludedHolidays => 'Holidays excluded';

  @override
  String get leaveSubmitRequest => 'Submit request';

  @override
  String get leaveNoTypes => 'No leave types are available.';

  @override
  String get leaveSelectType => 'Select leave type';

  @override
  String get leaveStatusPending => 'Pending';

  @override
  String get leaveStatusApproved => 'Approved';

  @override
  String get leaveStatusRejected => 'Rejected';

  @override
  String get leaveStatusCancelled => 'Cancelled';

  @override
  String get leaveApprove => 'Approve';

  @override
  String get leaveReject => 'Reject';

  @override
  String get leaveCancelRequest => 'Cancel request';

  @override
  String get leaveReviewNote => 'Note';

  @override
  String get leaveCancelReason => 'Cancellation reason';

  @override
  String get leaveEmployee => 'Employee';

  @override
  String get leaveDepartment => 'Department';

  @override
  String get leaveDateRange => 'Dates';

  @override
  String get leaveApprovedBy => 'Reviewed by';

  @override
  String get leaveSubmittedOn => 'Submitted';

  @override
  String get leaveViewDetails => 'View details';

  @override
  String get leaveApply => 'Apply';

  @override
  String get leaveBalancesTitle => 'Leave balances';

  @override
  String get leaveEntitlement => 'Entitlement';

  @override
  String get leaveUsed => 'Used';

  @override
  String get leavePendingBalance => 'Pending';

  @override
  String get leaveAvailable => 'Available';

  @override
  String get leaveAdjustBalance => 'Adjust balance';

  @override
  String get leaveAdjustAdd => 'Add days';

  @override
  String get leaveAdjustRemove => 'Remove days';

  @override
  String get leaveAdjustQuantity => 'Days';

  @override
  String get leaveAdjustReason => 'Reason';

  @override
  String get leaveLedger => 'Balance history';

  @override
  String get leaveNoBalance => 'No balance records.';

  @override
  String get leaveSelectEmployee => 'Employee';

  @override
  String get leaveEmployeeFilter => 'Employee';

  @override
  String get leaveCalendarTitle => 'Leave calendar';

  @override
  String get leaveCalendarLegendLeave => 'Leave';

  @override
  String get leaveCalendarLegendHoliday => 'Holiday';

  @override
  String get leaveCalendarEmpty => 'No leave or holidays in this period.';

  @override
  String get leaveFrom => 'From';

  @override
  String get leaveTo => 'To';

  @override
  String get leaveRequestsEmpty => 'No leave requests.';

  @override
  String get leaveApprovalsEmpty => 'No requests are waiting for review.';

  @override
  String get leaveNoPendingRequests => 'You have no pending leave requests.';

  @override
  String get leaveOnLeaveToday => 'On leave today';

  @override
  String get workdayScheduled => 'Scheduled';

  @override
  String get workdayWorking => 'Working';

  @override
  String get workdayOnBreak => 'On break';

  @override
  String get workdayCompleted => 'Completed';

  @override
  String get workdayIncomplete => 'Incomplete';

  @override
  String get workdayOnLeave => 'On leave';

  @override
  String get workdayHoliday => 'Holiday';

  @override
  String get workdayNonWorking => 'Non-working';

  @override
  String get workdayIssue => 'Issue';

  @override
  String get leavePermissionDenied => 'You do not have access to leave.';

  @override
  String get leaveStorageError => 'Leave data could not be loaded.';

  @override
  String get leaveUnavailable => 'Leave is not available.';

  @override
  String get leaveTypeInactive => 'The selected leave type is not available.';

  @override
  String get leaveNoEmployee => 'Your account is not linked to an employee.';

  @override
  String get leaveInvalidDateRange =>
      'The end date must be after the start date.';

  @override
  String get leaveReasonRequired => 'A reason is required.';

  @override
  String get leaveNoWorkingDays => 'The selected range has no working days.';

  @override
  String get leaveMinimumDays =>
      'The request is shorter than the policy minimum.';

  @override
  String get leaveOverlapping => 'This request overlaps an existing request.';

  @override
  String get leaveInsufficientBalance => 'There is not enough leave balance.';

  @override
  String get leavePastRequestNotAllowed => 'Past-dated leave is not allowed.';

  @override
  String get leaveAdvanceNoticeRequired =>
      'This request does not meet the advance notice requirement.';

  @override
  String get leaveInvalidQuantity => 'Enter a valid quantity.';

  @override
  String get leaveRequestNotFound => 'The leave request was not found.';

  @override
  String get leaveAlreadyReviewed => 'This request has already been reviewed.';

  @override
  String get leaveCannotCancelApproved =>
      'Approved leave can only be cancelled by a manager.';

  @override
  String get leaveReviewNoteRequired => 'A note is required.';

  @override
  String get leaveSelfApprovalNotAllowed =>
      'You cannot approve your own leave.';

  @override
  String get leaveSaved => 'Leave saved.';

  @override
  String get leaveRequestSubmitted => 'Leave request submitted.';

  @override
  String get leaveIncludeInactive => 'Include inactive';

  @override
  String get leaveUpcoming => 'Upcoming';

  @override
  String get leavePendingApproval => 'Pending approval';

  @override
  String get leaveApprovedThisMonth => 'Approved this month';

  @override
  String get leaveTeamMembers => 'Team members';

  @override
  String get leaveNoEmployeesOnLeave => 'No employees are on leave today.';

  @override
  String get leaveNoUpcoming => 'No upcoming leave.';

  @override
  String get leaveHalfDay => 'Half day';

  @override
  String get leaveFullDay => 'Full day';

  @override
  String get leaveReturnDate => 'Return date';

  @override
  String get leaveStatusField => 'Status';

  @override
  String get leaveReviewRequest => 'Review request';

  @override
  String get leaveCompanyLeave => 'Company leave';

  @override
  String get leaveApprovalsTitle => 'Leave approvals';

  @override
  String get leaveApprovalsSubtitle =>
      'Review employee leave requests that require your action.';

  @override
  String get leaveTeamSubtitle =>
      'View upcoming leave, team availability and leave requests.';

  @override
  String get leaveAllSubtitle =>
      'Monitor company leave, availability and leave requests.';

  @override
  String get leaveOverviewSubtitle =>
      'Your leave, team availability and requests.';

  @override
  String get leavePendingRequests => 'Pending requests';

  @override
  String get leaveStartingSoon => 'Starting soon';

  @override
  String get leaveTeamRequests => 'Team requests';

  @override
  String get leaveCompanyRequests => 'Company requests';

  @override
  String get leaveAvailableBalance => 'Available balance';

  @override
  String get leaveBalanceAfterApproval => 'Balance after approval';

  @override
  String get leaveViewEmployeeLeave => 'View employee leave';

  @override
  String get leaveEmployeeLeave => 'Employee leave';

  @override
  String get leaveNoPendingApprovals => 'No requests need your approval.';

  @override
  String get leaveSearchEmployee => 'Search employee';

  @override
  String get leavePeriodAll => 'All';

  @override
  String get leavePeriodToday => 'Today';

  @override
  String get leavePeriodThisWeek => 'This week';

  @override
  String get leavePeriodThisMonth => 'This month';

  @override
  String get leavePeriodNext30 => 'Next 30 days';

  @override
  String get leavePeriodCustom => 'Custom';

  @override
  String get leaveClearFilters => 'Clear filters';

  @override
  String get leaveActiveFilters => 'Active filters';

  @override
  String get leaveManageSettings => 'Manage leave settings';

  @override
  String get leaveViewAllLeave => 'View all leave';

  @override
  String get leaveReviewQueue => 'Review queue';

  @override
  String get leaveNoBalanceForFilters =>
      'No leave balance found for selected filters.';

  @override
  String get leaveRequestSection => 'Request';

  @override
  String get leaveEmployeeSection => 'Employee';

  @override
  String get leaveBalanceSection => 'Balance';

  @override
  String get leaveDecisionSection => 'Decision';

  @override
  String get leaveWorkingDays => 'Working leave days';

  @override
  String get leavePortion => 'Portion';

  @override
  String get leaveStart => 'Start';

  @override
  String get leaveReturn => 'Return';

  @override
  String get leaveOnLeave => 'On leave';

  @override
  String get leaveUpcomingHoliday => 'Upcoming holiday';

  @override
  String get leaveUpcomingTeamLeave => 'Upcoming team leave';

  @override
  String get leavePendingApprovals => 'Pending approvals';

  @override
  String get leaveMyLeaveOverview => 'My leave';

  @override
  String get leaveTeamOverview => 'Team leave';

  @override
  String get leaveCompanyOverview => 'Company leave';

  @override
  String get leaveEmployeeUnavailable =>
      'This employee\'s leave information is unavailable.';

  @override
  String get leaveScopeDenied => 'You do not have access to this leave scope.';

  @override
  String get leaveRecentRequests => 'Recent requests';

  @override
  String get leaveBalanceLedger => 'Balance history';

  @override
  String get leaveAdjustmentAdded => 'Added to balance';

  @override
  String get leaveAdjustmentDeducted => 'Deducted from balance';

  @override
  String get leaveEffectiveDate => 'Effective date';

  @override
  String get leaveCurrentAvailable => 'Current available';

  @override
  String get leavePreviewNewAvailable => 'New available balance';

  @override
  String get leaveNoTeam => 'No team is available for this account.';

  @override
  String get leaveApprovalsEmptyQueue =>
      'You have no requests waiting for review.';

  @override
  String get leaveRequestedPeriod => 'Requested period';

  @override
  String get holidayTypeFestival => 'Festival holiday';

  @override
  String get holidayTypeRegional => 'Regional holiday';

  @override
  String get holidaySourceManual => 'Manual';

  @override
  String get holidaySourceCopied => 'Copied from previous year';

  @override
  String get holidaySourceImported => 'Imported';

  @override
  String get holidaySourceTemplate => 'Company template';

  @override
  String get holidayCalendarTitle => 'Holiday calendar';

  @override
  String get holidayCalendarSubtitle =>
      'Manage public, festival, regional and company holidays.';

  @override
  String get holidayYearLabel => 'Holiday year';

  @override
  String get addHoliday => 'Add holiday';

  @override
  String get editHoliday => 'Edit holiday';

  @override
  String get manageHolidays => 'Manage holidays';

  @override
  String get copyPreviousYear => 'Copy previous year';

  @override
  String get importHolidays => 'Import holidays';

  @override
  String get setUpHolidayCalendar => 'Set up holiday calendar';

  @override
  String get startBlank => 'Start blank';

  @override
  String get holidayCalendarStatus => 'Holiday calendar status';

  @override
  String get activeHolidays => 'Active holidays';

  @override
  String get nextHoliday => 'Next holiday';

  @override
  String get holidayNotConfigured => 'Not configured';

  @override
  String get noHolidaysConfigured => 'No holidays configured for this year.';

  @override
  String get holidayPublishedEmpty =>
      'No company holidays have been published for this period.';

  @override
  String get applyTo => 'Applies to';

  @override
  String get holidayMultiDay => 'Multi-day holiday';

  @override
  String get holidayBasicInfo => 'Basic information';

  @override
  String get holidayApplicability => 'Applicability';

  @override
  String get holidayOptionality => 'Optionality';

  @override
  String get holidaySourceField => 'Source';

  @override
  String get holidayDuplicateWarning =>
      'A holiday with the same name, date and scope already exists.';

  @override
  String get holidayImportPreview => 'Import preview';

  @override
  String get holidayImportPaste => 'Paste CSV';

  @override
  String get holidayImportHint =>
      'Columns: name, date, endDate, type, optional, scope, workLocations, description';

  @override
  String get holidayImportConfirm => 'Import';

  @override
  String get holidayImportImported => 'Imported';

  @override
  String get holidayImportSkipped => 'Skipped';

  @override
  String get holidayCopyNote =>
      'Copied entries keep their month and day — verify festival dates before confirming.';

  @override
  String get verifyFestivalDates =>
      'Copied from previous year — verify festival dates.';

  @override
  String get holidaySelectLocations => 'Select work locations';

  @override
  String get holidaySearchLocations => 'Search work locations';

  @override
  String get holidayTypeHelperPublic => 'Government/public holidays';

  @override
  String get holidayTypeHelperFestival => 'Religious or festival holidays';

  @override
  String get holidayTypeHelperRegional => 'State/regional holidays';

  @override
  String get holidayTypeHelperCompany => 'Company-declared holidays';

  @override
  String get holidayTypeHelperClosure => 'Special closures and shutdowns';

  @override
  String get nextHolidayDaysAway => 'days away';

  @override
  String get upcomingLeave => 'Upcoming leave';

  @override
  String get pendingRequest => 'Pending request';

  @override
  String get teamCalendar => 'Team calendar';

  @override
  String get reviewRequests => 'Review requests';

  @override
  String get viewRequests => 'Requests';

  @override
  String get viewUpcoming => 'Upcoming';

  @override
  String get viewToday => 'Today';

  @override
  String get selectedDay => 'Selected day';

  @override
  String get dayAgenda => 'Agenda';

  @override
  String get noEventsOnDay => 'No leave or holidays on this day.';

  @override
  String get leaveAndHolidayCalendar => 'Leave & holiday calendar';

  @override
  String get leaveViewMode => 'View';

  @override
  String get leaveBalanceAvailableLabel => 'available';

  @override
  String get leaveBalanceUsedLabel => 'used';

  @override
  String get leaveBalancePendingLabel => 'pending';

  @override
  String get leaveBalanceEntitlementLabel => 'entitlement';

  @override
  String get leaveHolidayThisYear => 'Holidays this year';

  @override
  String get leaveManageHolidaysHint =>
      'Manage the company\'s annual public, festival and company holiday calendar.';

  @override
  String get leaveSearchOrFilter => 'Search';

  @override
  String get leaveAllTypes => 'All types';

  @override
  String get leaveAllStatuses => 'All statuses';

  @override
  String get leaveAllPeriods => 'All periods';

  @override
  String get leaveDayOne => 'day';

  @override
  String get hrPermModuleHr => 'Human resources';

  @override
  String get hrPermSubEmployees => 'Employees';

  @override
  String get hrPermSubAttendance => 'Attendance';

  @override
  String get hrPermSubLeave => 'Leave & holidays';

  @override
  String get hrPermSubReports => 'Reports';

  @override
  String get hrPermSubConfiguration => 'Configuration';

  @override
  String get hrPermEmployeesView => 'View employee records';

  @override
  String get hrPermEmployeesViewDesc =>
      'See employee records within the selected scope.';

  @override
  String get hrPermEmployeesCreate => 'Create employee';

  @override
  String get hrPermEmployeesCreateDesc => 'Add new employees to the company.';

  @override
  String get hrPermEmployeesEdit => 'Edit employee';

  @override
  String get hrPermEmployeesEditDesc =>
      'Update employee details and assignments.';

  @override
  String get hrPermEmployeesDeactivate => 'Deactivate employee';

  @override
  String get hrPermEmployeesDeactivateDesc =>
      'Deactivate or reactivate employee records.';

  @override
  String get hrPermAttendanceSelfView => 'View my attendance';

  @override
  String get hrPermAttendanceSelfViewDesc =>
      'View personal attendance and history.';

  @override
  String get hrPermAttendanceSelfPunch => 'Punch in';

  @override
  String get hrPermAttendanceSelfPunchDesc => 'Start the workday.';

  @override
  String get hrPermAttendanceSelfPunchOut => 'Punch out';

  @override
  String get hrPermAttendanceSelfPunchOutDesc => 'End the workday.';

  @override
  String get hrPermAttendanceSelfBreak => 'Take a break';

  @override
  String get hrPermAttendanceSelfBreakDesc => 'Start and end breaks.';

  @override
  String get hrPermAttendanceSelfCorrection => 'Request attendance correction';

  @override
  String get hrPermAttendanceSelfCorrectionDesc =>
      'Submit attendance correction requests.';

  @override
  String get hrPermAttendanceRecordsView => 'View attendance records';

  @override
  String get hrPermAttendanceRecordsViewDesc =>
      'See workforce attendance within the selected scope.';

  @override
  String get hrPermAttendanceCorrectionsReview =>
      'Review attendance corrections';

  @override
  String get hrPermAttendanceCorrectionsReviewDesc =>
      'Approve or reject attendance correction requests.';

  @override
  String get hrPermAttendanceCorrectionsApply => 'Apply attendance corrections';

  @override
  String get hrPermAttendanceCorrectionsApplyDesc =>
      'Directly correct attendance records.';

  @override
  String get hrPermAttendanceReportsView => 'View attendance reports';

  @override
  String get hrPermAttendanceReportsViewDesc =>
      'See attendance reports and analytics.';

  @override
  String get hrPermLeaveSelfView => 'View my leave';

  @override
  String get hrPermLeaveSelfViewDesc => 'View personal leave requests.';

  @override
  String get hrPermLeaveSelfRequest => 'Request leave';

  @override
  String get hrPermLeaveSelfRequestDesc => 'Submit new leave requests.';

  @override
  String get hrPermLeaveSelfCancel => 'Cancel my leave';

  @override
  String get hrPermLeaveSelfCancelDesc =>
      'Cancel personal pending leave requests.';

  @override
  String get hrPermLeaveSelfBalance => 'View my balance';

  @override
  String get hrPermLeaveSelfBalanceDesc => 'View personal leave balances.';

  @override
  String get hrPermLeaveRecordsView => 'View leave records';

  @override
  String get hrPermLeaveRecordsViewDesc =>
      'See leave records within the selected scope.';

  @override
  String get hrPermLeaveRequestsReview => 'Review leave requests';

  @override
  String get hrPermLeaveRequestsReviewDesc =>
      'Approve or reject leave requests within the selected scope.';

  @override
  String get hrPermLeaveBalancesView => 'View leave balances';

  @override
  String get hrPermLeaveBalancesViewDesc =>
      'See leave balances within the selected scope.';

  @override
  String get hrPermLeaveBalancesAdjust => 'Adjust leave balances';

  @override
  String get hrPermLeaveBalancesAdjustDesc =>
      'Add or deduct leave balance for employees.';

  @override
  String get hrPermLeaveSettingsManage => 'Manage leave settings';

  @override
  String get hrPermLeaveSettingsManageDesc =>
      'Manage leave configuration overall.';

  @override
  String get hrPermLeaveTypesView => 'View leave types';

  @override
  String get hrPermLeaveTypesViewDesc => 'See leave types.';

  @override
  String get hrPermLeaveTypesManage => 'Manage leave types';

  @override
  String get hrPermLeaveTypesManageDesc => 'Create and edit leave types.';

  @override
  String get hrPermLeavePoliciesView => 'View leave policies';

  @override
  String get hrPermLeavePoliciesViewDesc => 'See leave policies.';

  @override
  String get hrPermLeavePoliciesManage => 'Manage leave policies';

  @override
  String get hrPermLeavePoliciesManageDesc => 'Create and edit leave policies.';

  @override
  String get hrPermHolidaysView => 'View holidays';

  @override
  String get hrPermHolidaysViewDesc => 'See the holiday calendar.';

  @override
  String get hrPermHolidaysManage => 'Manage holidays';

  @override
  String get hrPermHolidaysManageDesc => 'Configure holidays and calendars.';

  @override
  String get hrPermReportsLeaveView => 'View leave reports';

  @override
  String get hrPermReportsLeaveViewDesc => 'See leave reports and analytics.';

  @override
  String get hrPermShiftsView => 'View shifts';

  @override
  String get hrPermShiftsViewDesc => 'See shift configuration.';

  @override
  String get hrPermShiftsManage => 'Manage shifts';

  @override
  String get hrPermShiftsManageDesc => 'Create and edit shifts.';

  @override
  String get hrPermLocationsView => 'View work locations';

  @override
  String get hrPermLocationsViewDesc => 'See work location configuration.';

  @override
  String get hrPermLocationsManage => 'Manage work locations';

  @override
  String get hrPermLocationsManageDesc => 'Create and edit work locations.';

  @override
  String get hrPermPoliciesView => 'View attendance policies';

  @override
  String get hrPermPoliciesViewDesc => 'See attendance policy configuration.';

  @override
  String get hrPermPoliciesManage => 'Manage attendance policies';

  @override
  String get hrPermPoliciesManageDesc => 'Create and edit attendance policies.';

  @override
  String get servicesPermModuleServices => 'Services';

  @override
  String get servicesPermSubCustomers => 'Customers';

  @override
  String get servicesPermSubSites => 'Service sites';

  @override
  String get servicesPermSubTeams => 'Service teams';

  @override
  String get servicesPermSubConfiguration => 'Configuration';

  @override
  String get servicesPermCustomersView => 'View customers';

  @override
  String get servicesPermCustomersViewDesc =>
      'See the service customer directory.';

  @override
  String get servicesPermCustomersCreate => 'Create customer';

  @override
  String get servicesPermCustomersCreateDesc => 'Add new service customers.';

  @override
  String get servicesPermCustomersEdit => 'Edit customer';

  @override
  String get servicesPermCustomersEditDesc => 'Update customer details.';

  @override
  String get servicesPermCustomersDeactivate => 'Deactivate customer';

  @override
  String get servicesPermCustomersDeactivateDesc =>
      'Deactivate or reactivate customers.';

  @override
  String get servicesPermSitesView => 'View service sites';

  @override
  String get servicesPermSitesViewDesc => 'See service sites.';

  @override
  String get servicesPermSitesCreate => 'Create site';

  @override
  String get servicesPermSitesCreateDesc => 'Add service sites to customers.';

  @override
  String get servicesPermSitesEdit => 'Edit site';

  @override
  String get servicesPermSitesEditDesc => 'Update site details.';

  @override
  String get servicesPermSitesDeactivate => 'Deactivate site';

  @override
  String get servicesPermSitesDeactivateDesc =>
      'Deactivate or reactivate sites.';

  @override
  String get servicesPermTeamsView => 'View service teams';

  @override
  String get servicesPermTeamsViewDesc => 'See service teams and membership.';

  @override
  String get servicesPermTeamsManage => 'Manage service teams';

  @override
  String get servicesPermTeamsManageDesc =>
      'Create teams and manage membership.';

  @override
  String get servicesPermServiceTypesView => 'View service types';

  @override
  String get servicesPermServiceTypesViewDesc =>
      'See configured service types.';

  @override
  String get servicesPermServiceTypesManage => 'Manage service types';

  @override
  String get servicesPermServiceTypesManageDesc =>
      'Create and edit service types.';

  @override
  String get servicesPermComplaintTypesView => 'View complaint types';

  @override
  String get servicesPermComplaintTypesViewDesc =>
      'See configured complaint types.';

  @override
  String get servicesPermComplaintTypesManage => 'Manage complaint types';

  @override
  String get servicesPermComplaintTypesManageDesc =>
      'Create and edit complaint types.';

  @override
  String get servicesPermPrioritiesView => 'View priorities';

  @override
  String get servicesPermPrioritiesViewDesc =>
      'See configured service priorities.';

  @override
  String get servicesPermPrioritiesManage => 'Manage priorities';

  @override
  String get servicesPermPrioritiesManageDesc =>
      'Create and edit service priorities.';

  @override
  String get servicesPermTicketTypesView => 'View ticket types';

  @override
  String get servicesPermTicketTypesViewDesc => 'See configured ticket types.';

  @override
  String get servicesPermTicketTypesManage => 'Manage ticket types';

  @override
  String get servicesPermTicketTypesManageDesc =>
      'Create and edit ticket types.';

  @override
  String get permissionServiceCustomerView => 'View customers';

  @override
  String get permissionServiceCustomerCreate => 'Create customer';

  @override
  String get permissionServiceCustomerEdit => 'Edit customer';

  @override
  String get permissionServiceCustomerDeactivate => 'Deactivate customer';

  @override
  String get permissionServiceSiteView => 'View service sites';

  @override
  String get permissionServiceSiteCreate => 'Create site';

  @override
  String get permissionServiceSiteEdit => 'Edit site';

  @override
  String get permissionServiceSiteDeactivate => 'Deactivate site';

  @override
  String get permissionServiceTeamView => 'View service teams';

  @override
  String get permissionServiceTeamManage => 'Manage service teams';

  @override
  String get permissionServiceTypeView => 'View service types';

  @override
  String get permissionServiceTypeManage => 'Manage service types';

  @override
  String get permissionComplaintTypeView => 'View complaint types';

  @override
  String get permissionComplaintTypeManage => 'Manage complaint types';

  @override
  String get permissionServicePriorityView => 'View priorities';

  @override
  String get permissionServicePriorityManage => 'Manage priorities';

  @override
  String get permissionServiceTicketTypeView => 'View ticket types';

  @override
  String get permissionServiceTicketTypeManage => 'Manage ticket types';

  @override
  String get servicesNavOverview => 'Overview';

  @override
  String get servicesNavCustomers => 'Customers';

  @override
  String get servicesNavSites => 'Sites';

  @override
  String get servicesNavTeams => 'Teams';

  @override
  String get servicesNavSettings => 'Services settings';

  @override
  String get servicesOverviewSubtitle =>
      'Manage your service directory, teams and operational configuration.';

  @override
  String get servicesSummaryCustomers => 'Customers';

  @override
  String get servicesSummarySites => 'Active sites';

  @override
  String get servicesSummaryTeams => 'Service teams';

  @override
  String get servicesSetupTitle => 'Setup';

  @override
  String get servicesSetupServiceTypes => 'Service types';

  @override
  String get servicesSetupPriorities => 'Priorities';

  @override
  String get servicesSetupReady => 'Configured';

  @override
  String get servicesSetupMissing => 'Not configured';

  @override
  String get servicesDirectoryTitle => 'Customer directory';

  @override
  String get servicesRecentCustomers => 'Recent customers';

  @override
  String get servicesNoCustomersYet => 'No customers yet';

  @override
  String get servicesCustomersTitle => 'Customers';

  @override
  String get servicesCustomerAdd => 'Add customer';

  @override
  String get servicesCustomerEdit => 'Edit customer';

  @override
  String get servicesCustomerCode => 'Code';

  @override
  String get servicesCustomerName => 'Name';

  @override
  String get servicesCustomerKind => 'Type';

  @override
  String get servicesCustomerKindIndividual => 'Individual';

  @override
  String get servicesCustomerKindOrganization => 'Organization';

  @override
  String get servicesCustomerMobile => 'Mobile';

  @override
  String get servicesCustomerAlternateMobile => 'Alternate mobile';

  @override
  String get servicesCustomerEmail => 'Email';

  @override
  String get servicesCustomerNotes => 'Notes';

  @override
  String get servicesCustomerSites => 'Sites';

  @override
  String get servicesCustomerContact => 'Contact';

  @override
  String get servicesCustomerLastUpdated => 'Last updated';

  @override
  String get servicesCustomerSaved => 'Customer saved.';

  @override
  String get servicesCustomerStorageError => 'Could not save the customer.';

  @override
  String get servicesCustomerNotFound => 'Customer not found.';

  @override
  String get servicesCustomerEmpty => 'No customers yet';

  @override
  String get servicesCustomerEmptyMessage =>
      'Add your first customer to get started.';

  @override
  String get servicesCustomerNoResults => 'No customers match your search.';

  @override
  String get servicesCustomerRequired => 'This field is required.';

  @override
  String get servicesCustomerInvalidMobile => 'Enter a valid mobile number.';

  @override
  String get servicesCustomerInvalidEmail => 'Enter a valid email.';

  @override
  String get servicesCustomerDuplicateMobile =>
      'A customer with this mobile already exists.';

  @override
  String get servicesCustomerDuplicateEmail =>
      'A customer with this email already exists.';

  @override
  String get servicesCustomerDeactivate => 'Deactivate';

  @override
  String get servicesCustomerActivate => 'Activate';

  @override
  String get servicesCustomerSearch => 'Search customers';

  @override
  String get servicesCustomerAllStatuses => 'All statuses';

  @override
  String get servicesCustomerActivity => 'Activity';

  @override
  String get servicesCustomerNoActivity => 'No activity yet.';

  @override
  String get servicesCustomerSelect => 'Select customer';

  @override
  String get servicesCustomerStatus => 'Status';

  @override
  String get servicesCustomerDiscardMessage => 'You have unsaved changes.';

  @override
  String get servicesCustomerDiscardAction => 'Discard';

  @override
  String get servicesSitesTitle => 'Service sites';

  @override
  String get servicesSiteAdd => 'Add site';

  @override
  String get servicesSiteEdit => 'Edit site';

  @override
  String get servicesSiteCode => 'Code';

  @override
  String get servicesSiteName => 'Site name';

  @override
  String get servicesSiteCustomer => 'Customer';

  @override
  String get servicesSiteTenant => 'Tenant';

  @override
  String get servicesSiteBuilding => 'Building';

  @override
  String get servicesSiteUnit => 'Unit';

  @override
  String get servicesSiteContactName => 'Contact name';

  @override
  String get servicesSiteContactMobile => 'Contact mobile';

  @override
  String get servicesSiteContactEmail => 'Contact email';

  @override
  String get servicesSiteAddress1 => 'Address';

  @override
  String get servicesSiteAddress2 => 'Address line 2';

  @override
  String get servicesSiteArea => 'Area';

  @override
  String get servicesSiteCity => 'City';

  @override
  String get servicesSiteState => 'State/region';

  @override
  String get servicesSitePostalCode => 'Postal code';

  @override
  String get servicesSiteCountry => 'Country';

  @override
  String get servicesSiteLatitude => 'Latitude';

  @override
  String get servicesSiteLongitude => 'Longitude';

  @override
  String get servicesSiteNotes => 'Notes';

  @override
  String get servicesSiteBuildingUnit => 'Building / unit';

  @override
  String get servicesSiteSaved => 'Site saved.';

  @override
  String get servicesSiteStorageError => 'Could not save the site.';

  @override
  String get servicesSiteNotFound => 'Site not found.';

  @override
  String get servicesSiteEmpty => 'No sites yet';

  @override
  String get servicesSiteEmptyMessage =>
      'Add a site to a customer to schedule work.';

  @override
  String get servicesSiteNoResults => 'No sites match your search.';

  @override
  String get servicesSiteRequired => 'This field is required.';

  @override
  String get servicesSiteDeactivate => 'Deactivate';

  @override
  String get servicesSiteActivate => 'Activate';

  @override
  String get servicesSiteSearch => 'Search sites';

  @override
  String get servicesSiteDetails => 'Site';

  @override
  String get servicesSiteActivity => 'Activity';

  @override
  String get servicesSiteLocation => 'Location';

  @override
  String get servicesSiteIdentity => 'Site identity';

  @override
  String get servicesSiteAddress => 'Address';

  @override
  String get servicesSiteContact => 'Contact';

  @override
  String get servicesSiteCustomerRequired => 'Select a customer.';

  @override
  String get servicesSiteSelectCustomer => 'Select customer';

  @override
  String get servicesTeamsTitle => 'Service teams';

  @override
  String get servicesTeamAdd => 'Add team';

  @override
  String get servicesTeamEdit => 'Edit team';

  @override
  String get servicesTeamCode => 'Code';

  @override
  String get servicesTeamName => 'Team name';

  @override
  String get servicesTeamDescription => 'Description';

  @override
  String get servicesTeamLead => 'Team lead';

  @override
  String get servicesTeamMembers => 'Members';

  @override
  String get servicesTeamMemberAdd => 'Add member';

  @override
  String get servicesTeamMemberSearch => 'Search employees';

  @override
  String get servicesTeamNoMembers => 'No members yet';

  @override
  String get servicesTeamSaved => 'Team saved.';

  @override
  String get servicesTeamStorageError => 'Could not save the team.';

  @override
  String get servicesTeamNotFound => 'Team not found.';

  @override
  String get servicesTeamEmpty => 'No teams yet';

  @override
  String get servicesTeamEmptyMessage =>
      'Create a team to group employees for service work.';

  @override
  String get servicesTeamNoResults => 'No teams match your search.';

  @override
  String get servicesTeamRequired => 'This field is required.';

  @override
  String get servicesTeamDeactivate => 'Deactivate';

  @override
  String get servicesTeamActivate => 'Activate';

  @override
  String get servicesTeamSearch => 'Search teams';

  @override
  String get servicesTeamDetails => 'Team';

  @override
  String get servicesTeamActivity => 'Activity';

  @override
  String get servicesTeamLeadOptional => 'No lead';

  @override
  String get servicesTeamSelectLead => 'Select lead';

  @override
  String get servicesTeamMembersCount => 'Members';

  @override
  String get servicesSettingsTitle => 'Services settings';

  @override
  String get servicesSettingsSubtitle =>
      'Configure the master data used by service operations.';

  @override
  String get servicesServiceTypesTitle => 'Service types';

  @override
  String get servicesComplaintTypesTitle => 'Complaint types';

  @override
  String get servicesPrioritiesTitle => 'Priorities';

  @override
  String get servicesTicketTypesTitle => 'Ticket types';

  @override
  String get servicesAddMaster => 'Add';

  @override
  String get servicesEditMaster => 'Edit';

  @override
  String get servicesMasterCode => 'Code';

  @override
  String get servicesMasterName => 'Name';

  @override
  String get servicesMasterDescription => 'Description';

  @override
  String get servicesMasterSortOrder => 'Sort order';

  @override
  String get servicesMasterRank => 'Rank';

  @override
  String get servicesMasterDefault => 'Default';

  @override
  String get servicesMasterServiceType => 'Service type';

  @override
  String get servicesMasterSaved => 'Saved.';

  @override
  String get servicesMasterStorageError => 'Could not save.';

  @override
  String get servicesMasterNotFound => 'Record not found.';

  @override
  String get servicesMasterEmpty => 'Nothing configured yet';

  @override
  String get servicesMasterNoResults => 'No records match your search.';

  @override
  String get servicesMasterRequired => 'This field is required.';

  @override
  String get servicesMasterDeactivate => 'Deactivate';

  @override
  String get servicesMasterActivate => 'Activate';

  @override
  String get servicesMasterSearch => 'Search';

  @override
  String get servicesMasterGeneric => 'General';

  @override
  String get servicesMasterNameRequired => 'Name is required.';

  @override
  String get servicesMasterCodeRequired => 'Code is required.';

  @override
  String get servicesMasterDuplicateCode =>
      'A record with this code already exists.';

  @override
  String get servicesMasterDuplicateName =>
      'A record with this name already exists.';

  @override
  String servicesCustomerCount(String filtered, String total) {
    return '$filtered of $total customers';
  }

  @override
  String servicesSiteCount(String filtered, String total) {
    return '$filtered of $total sites';
  }

  @override
  String servicesTeamCount(String filtered, String total) {
    return '$filtered of $total teams';
  }

  @override
  String get servicesActivityCreated => 'Created';

  @override
  String get servicesActivityUpdated => 'Updated';

  @override
  String get servicesActivityActivated => 'Activated';

  @override
  String get servicesActivityDeactivated => 'Deactivated';

  @override
  String get servicesActivityMembersUpdated => 'Team members updated';

  @override
  String get servicesActivityUnknown => 'Activity';

  @override
  String get servicesCustomerContactSection => 'Contact details';

  @override
  String get servicesSiteAddressSection => 'Address';

  @override
  String get servicesTeamLeadSection => 'Team lead';

  @override
  String get servicesTeamLeadNone => 'No team lead assigned';

  @override
  String get servicesCustomerNoSites => 'No service sites yet.';

  @override
  String get servicesDenied =>
      'You do not have permission to perform this action.';

  @override
  String get permissionServiceEnquiryView => 'View enquiries';

  @override
  String get permissionServiceEnquiryCreate => 'Create enquiry';

  @override
  String get permissionServiceEnquiryEdit => 'Edit enquiry';

  @override
  String get permissionServiceEnquiryCancel => 'Cancel enquiry';

  @override
  String get servicesPermSubEnquiries => 'Enquiries';

  @override
  String get servicesPermEnquiriesView => 'View enquiries';

  @override
  String get servicesPermEnquiriesViewDesc =>
      'View the company service enquiry queue and enquiry details.';

  @override
  String get servicesPermEnquiriesCreate => 'Create enquiry';

  @override
  String get servicesPermEnquiriesCreateDesc =>
      'Log a new service enquiry, including restricted customer and site reference lookup.';

  @override
  String get servicesPermEnquiriesEdit => 'Edit enquiry';

  @override
  String get servicesPermEnquiriesEditDesc => 'Edit an open service enquiry.';

  @override
  String get servicesPermEnquiriesCancel => 'Cancel enquiry';

  @override
  String get servicesPermEnquiriesCancelDesc =>
      'Cancel an open service enquiry (kept historically).';

  @override
  String get servicesNavEnquiries => 'Enquiries';

  @override
  String get servicesEnquiriesTitle => 'Service enquiries';

  @override
  String servicesEnquiryCount(String filtered, String total) {
    return '$filtered of $total enquiries';
  }

  @override
  String get servicesEnquirySearch =>
      'Search by number, customer, mobile, site, building or unit';

  @override
  String get servicesEnquiryAllStatuses => 'All statuses';

  @override
  String get servicesEnquiryEmpty => 'No service enquiries yet.';

  @override
  String get servicesEnquiryEmptyMessage =>
      'Log the first service enquiry to start the operational queue.';

  @override
  String get servicesEnquiryNoResults => 'No enquiries match your filters.';

  @override
  String get servicesEnquiryAdd => 'New enquiry';

  @override
  String get servicesEnquiryColumnEnquiry => 'Enquiry';

  @override
  String get servicesEnquiryColumnCustomer => 'Customer';

  @override
  String get servicesEnquiryColumnSite => 'Site';

  @override
  String get servicesEnquiryColumnService => 'Service / complaint';

  @override
  String get servicesEnquiryColumnPriority => 'Priority';

  @override
  String get servicesEnquiryColumnTicket => 'Ticket type';

  @override
  String get servicesEnquiryColumnStatus => 'Status';

  @override
  String get servicesEnquiryColumnCreated => 'Created';

  @override
  String get servicesEnquiryStatusOpen => 'Open';

  @override
  String get servicesEnquiryStatusCancelled => 'Cancelled';

  @override
  String get servicesEnquiryFilterTitle => 'Filters';

  @override
  String get servicesEnquiryFilterStatus => 'Status';

  @override
  String get servicesEnquiryFilterServiceType => 'Service type';

  @override
  String get servicesEnquiryFilterComplaintType => 'Complaint type';

  @override
  String get servicesEnquiryFilterPriority => 'Priority';

  @override
  String get servicesEnquiryFilterTicketType => 'Ticket type';

  @override
  String get servicesEnquiryFilterCreatedFrom => 'Created from';

  @override
  String get servicesEnquiryFilterCreatedTo => 'Created to';

  @override
  String get servicesEnquiryDetailCustomerSection => 'Customer & location';

  @override
  String get servicesEnquiryDetailServiceSection => 'Service details';

  @override
  String get servicesEnquiryDetailComplaintSection => 'Complaint';

  @override
  String get servicesEnquiryDetailRecord => 'Record';

  @override
  String get servicesEnquiryDetailActivity => 'Activity';

  @override
  String get servicesEnquiryCustomerCode => 'Customer code';

  @override
  String get servicesEnquiryCustomerName => 'Customer';

  @override
  String get servicesEnquiryCustomerMobile => 'Customer mobile';

  @override
  String get servicesEnquirySite => 'Service site';

  @override
  String get servicesEnquiryTenant => 'Tenant';

  @override
  String get servicesEnquiryBuilding => 'Building';

  @override
  String get servicesEnquiryUnit => 'Unit';

  @override
  String get servicesEnquiryAddress => 'Address';

  @override
  String get servicesEnquiryContact => 'Contact';

  @override
  String get servicesEnquiryServiceType => 'Service type';

  @override
  String get servicesEnquiryComplaintType => 'Complaint type';

  @override
  String get servicesEnquiryPriority => 'Priority';

  @override
  String get servicesEnquiryTicketType => 'Ticket type';

  @override
  String get servicesEnquiryDescription => 'Complaint details';

  @override
  String get servicesEnquiryCreatedBy => 'Created by';

  @override
  String get servicesEnquiryCreatedAt => 'Created at';

  @override
  String get servicesEnquiryUpdatedBy => 'Updated by';

  @override
  String get servicesEnquiryUpdatedAt => 'Updated at';

  @override
  String get servicesEnquiryVersion => 'Version';

  @override
  String get servicesEnquiryCancelledAt => 'Cancelled at';

  @override
  String get servicesEnquiryCancelReason => 'Cancellation reason';

  @override
  String get servicesEnquiryNoActivity => 'No activity yet.';

  @override
  String get servicesEnquiryEdit => 'Edit enquiry';

  @override
  String get servicesEnquiryCancel => 'Cancel enquiry';

  @override
  String get servicesEnquiryCreate => 'Create enquiry';

  @override
  String get servicesEnquiryCancelConfirmTitle => 'Cancel enquiry?';

  @override
  String get servicesEnquiryCancelConfirmMessage =>
      'The cancelled enquiry stays available historically and cannot be edited afterwards.';

  @override
  String get servicesEnquiryCancelReasonHint => 'Optional cancellation reason';

  @override
  String get servicesEnquiryCreated => 'Enquiry created.';

  @override
  String get servicesEnquiryUpdated => 'Enquiry updated.';

  @override
  String get servicesEnquiryCancelled => 'Enquiry cancelled.';

  @override
  String get servicesEnquiryFormNew => 'New enquiry';

  @override
  String get servicesEnquiryFormEdit => 'Edit enquiry';

  @override
  String get servicesEnquirySectionCustomerLocation => 'Customer & location';

  @override
  String get servicesEnquirySectionService => 'Service details';

  @override
  String get servicesEnquirySectionComplaint => 'Complaint';

  @override
  String get servicesEnquirySectionSummary => 'Summary';

  @override
  String get servicesEnquirySelectCustomer => 'Select a customer';

  @override
  String get servicesEnquirySelectSite => 'Select a service site';

  @override
  String get servicesEnquiryChangeCustomer => 'Change customer';

  @override
  String get servicesEnquiryChangeSite => 'Change site';

  @override
  String get servicesEnquiryCreateCustomer => 'Create customer';

  @override
  String get servicesEnquiryCreateSite => 'Add site';

  @override
  String get servicesEnquiryNoSitesForCustomer =>
      'No active sites for this customer.';

  @override
  String get servicesEnquiryNoComplaintTypes =>
      'No complaint types are available for this service type.';

  @override
  String get servicesEnquiryDescriptionHint =>
      'Describe the complaint or service request';

  @override
  String get servicesEnquiryCustomerRequired => 'Select a customer.';

  @override
  String get servicesEnquirySiteRequired => 'Select a service site.';

  @override
  String get servicesEnquiryServiceTypeRequired => 'Select a service type.';

  @override
  String get servicesEnquiryComplaintTypeRequired => 'Select a complaint type.';

  @override
  String get servicesEnquiryPriorityRequired => 'Select a priority.';

  @override
  String get servicesEnquiryTicketTypeRequired => 'Select a ticket type.';

  @override
  String get servicesEnquiryDescriptionRequired =>
      'Enter the complaint details.';

  @override
  String get servicesEnquiryDescriptionTooLong =>
      'The complaint details are too long.';

  @override
  String get servicesEnquiryDenied =>
      'You do not have permission to perform this action.';

  @override
  String get servicesEnquiryNotFound => 'Enquiry not found.';

  @override
  String get servicesEnquiryNotEditable => 'Only open enquiries can be edited.';

  @override
  String get servicesEnquiryAlreadyCancelled =>
      'This enquiry is already cancelled.';

  @override
  String get servicesEnquiryCustomerNotFound => 'Customer not found.';

  @override
  String get servicesEnquiryCustomerInactive =>
      'The selected customer is inactive.';

  @override
  String get servicesEnquirySiteNotFound => 'Service site not found.';

  @override
  String get servicesEnquirySiteInactive =>
      'The selected service site is inactive.';

  @override
  String get servicesEnquirySiteCustomerMismatch =>
      'The selected site does not belong to the selected customer.';

  @override
  String get servicesEnquiryServiceTypeInvalid =>
      'The selected service type is not available.';

  @override
  String get servicesEnquiryComplaintTypeInvalid =>
      'The selected complaint type is not available.';

  @override
  String get servicesEnquiryComplaintTypeMismatch =>
      'The complaint type does not match the selected service type.';

  @override
  String get servicesEnquiryPriorityInvalid =>
      'The selected priority is not available.';

  @override
  String get servicesEnquiryTicketTypeInvalid =>
      'The selected ticket type is not available.';

  @override
  String get servicesEnquirySequenceFailed =>
      'Could not allocate an enquiry number.';

  @override
  String get servicesEnquiryStorageError =>
      'Could not save the enquiry. Please try again.';

  @override
  String get servicesActivityCancelled => 'Cancelled';

  @override
  String get servicesOverviewEnquiriesOpen => 'Open enquiries';

  @override
  String get servicesOverviewEnquiriesToday => 'Enquiries today';

  @override
  String get servicesOverviewEnquiriesHigh => 'High / urgent open';

  @override
  String get servicesOverviewRecentEnquiries => 'Recent enquiries';

  @override
  String get servicesOverviewNewEnquiry => 'New enquiry';

  @override
  String get servicesOverviewNoEnquiries => 'No enquiries yet.';

  @override
  String get servicesEnquiryRecentForCustomer => 'Recent enquiries';

  @override
  String get servicesEnquiryRecentForSite => 'Recent enquiries';

  @override
  String get servicesEnquiryNoneForCustomer =>
      'No enquiries for this customer yet.';

  @override
  String get servicesEnquiryNoneForSite => 'No enquiries for this site yet.';

  @override
  String get servicesEnquiryDetailsSection => 'Enquiry details';

  @override
  String get servicesEnquiryAddDetail => 'Add another issue';

  @override
  String get servicesEnquiryRemoveDetail => 'Remove issue';

  @override
  String servicesEnquiryDetailLine(String index) {
    return 'Issue $index';
  }

  @override
  String get servicesEnquiryDetailDescription => 'Description';

  @override
  String get servicesEnquiryDetailStatus => 'Status';

  @override
  String get servicesEnquiryDetailStatusOpen => 'Open';

  @override
  String get servicesEnquiryDetailStatusClosed => 'Closed';

  @override
  String get servicesEnquiryPhotos => 'Photos';

  @override
  String get servicesEnquiryAddPhotos => 'Add photos';

  @override
  String get servicesEnquiryMaterialReceived => 'Material received';

  @override
  String get servicesEnquiryMaterialReceivedYes => 'Yes';

  @override
  String get servicesEnquiryMaterialReceivedNo => 'No';

  @override
  String get servicesEnquiryNoDetails => 'No details recorded.';

  @override
  String get servicesEnquiryDetailsRequired =>
      'Add at least one enquiry detail.';

  @override
  String get servicesEnquiryDetailDescriptionRequired =>
      'Enter a description for each enquiry detail.';

  @override
  String get servicesEnquiryAttachmentUnsupportedType =>
      'Unsupported file type.';

  @override
  String get servicesEnquiryAttachmentTooLarge => 'File is too large.';

  @override
  String get servicesEnquiryAttachmentLimitReached =>
      'Attachment limit reached.';

  @override
  String get servicesEnquiryAttachmentFailure => 'Could not attach the file.';

  @override
  String get attachmentUploaded => 'Uploaded';

  @override
  String get attachmentLocalOnly => 'Local';

  @override
  String get attachmentPendingUpload => 'Pending';

  @override
  String get attachmentFailed => 'Failed';

  @override
  String get attachmentPendingDelete => 'Deleting';

  @override
  String get attachmentDeleted => 'Deleted';

  @override
  String get servicesNavJobAssignments => 'Job assignments';

  @override
  String get servicesPermSubJobAssignments => 'Job assignments';

  @override
  String get servicesPermJobAssignmentsView => 'View job assignments';

  @override
  String get servicesPermJobAssignmentsViewDesc =>
      'View the company job assignment queue within your record scope.';

  @override
  String get servicesPermJobAssignmentsCreate => 'Create job assignment';

  @override
  String get servicesPermJobAssignmentsCreateDesc =>
      'Assign work from an eligible enquiry, including restricted enquiry, employee and team reference lookup.';

  @override
  String get servicesPermJobAssignmentsEdit => 'Edit job assignment';

  @override
  String get servicesPermJobAssignmentsEditDesc =>
      'Edit or reassign an active job assignment.';

  @override
  String get servicesPermJobAssignmentsCancel => 'Cancel job assignment';

  @override
  String get servicesPermJobAssignmentsCancelDesc =>
      'Cancel an active job assignment (kept historically).';

  @override
  String get permissionServiceJobAssignmentView => 'View job assignments';

  @override
  String get permissionServiceJobAssignmentCreate => 'Create job assignment';

  @override
  String get permissionServiceJobAssignmentEdit => 'Edit job assignment';

  @override
  String get permissionServiceJobAssignmentCancel => 'Cancel job assignment';

  @override
  String get servicesJobAssignmentsTitle => 'Job assignments';

  @override
  String servicesJobAssignmentCount(String filtered, String total) {
    return '$filtered of $total job assignments';
  }

  @override
  String get servicesJobAssignmentSearch =>
      'Search by assignment, enquiry, customer, mobile, site, employee or team';

  @override
  String get servicesJobAssignmentAllStatuses => 'All statuses';

  @override
  String get servicesJobAssignmentStatusActive => 'Active';

  @override
  String get servicesJobAssignmentStatusCancelled => 'Cancelled';

  @override
  String get servicesJobAssignmentEmpty => 'No job assignments yet.';

  @override
  String get servicesJobAssignmentEmptyMessage =>
      'Create a job assignment from an open service enquiry.';

  @override
  String get servicesJobAssignmentNoResults =>
      'No job assignments match your filters.';

  @override
  String get servicesJobAssignmentAdd => 'New job assignment';

  @override
  String get servicesJobAssignmentColumnAssignment => 'Assignment';

  @override
  String get servicesJobAssignmentColumnEnquiry => 'Enquiry';

  @override
  String get servicesJobAssignmentColumnCustomerSite => 'Customer / site';

  @override
  String get servicesJobAssignmentColumnVisitDate => 'Visit date';

  @override
  String get servicesJobAssignmentColumnAssignedTo => 'Assigned to';

  @override
  String get servicesJobAssignmentColumnPriority => 'Priority';

  @override
  String get servicesJobAssignmentColumnStatus => 'Status';

  @override
  String get servicesJobAssignmentColumnCreated => 'Created';

  @override
  String get servicesJobAssignmentFilterTitle => 'Filters';

  @override
  String get servicesJobAssignmentFilterStatus => 'Status';

  @override
  String get servicesJobAssignmentFilterPriority => 'Priority';

  @override
  String get servicesJobAssignmentFilterVisitFrom => 'Visit from';

  @override
  String get servicesJobAssignmentFilterVisitTo => 'Visit to';

  @override
  String get servicesJobAssignmentFormNew => 'New job assignment';

  @override
  String get servicesJobAssignmentFormEdit => 'Edit job assignment';

  @override
  String get servicesJobAssignmentCreate => 'Create job assignment';

  @override
  String get servicesJobAssignmentSectionJobContext => 'Job context';

  @override
  String get servicesJobAssignmentSectionSchedule => 'Schedule';

  @override
  String get servicesJobAssignmentSectionCustomerLocation =>
      'Customer & location';

  @override
  String get servicesJobAssignmentSectionServiceContext => 'Service context';

  @override
  String get servicesJobAssignmentSectionSourceIssues =>
      'Source enquiry issues';

  @override
  String get servicesJobAssignmentSectionWork => 'Work assignment';

  @override
  String get servicesJobAssignmentNo => 'Assignment no';

  @override
  String get servicesJobAssignmentDate => 'Assignment date';

  @override
  String get servicesJobAssignmentVisitDate => 'Visit date';

  @override
  String get servicesJobAssignmentEnquiry => 'Enquiry';

  @override
  String get servicesJobAssignmentSelectEnquiry => 'Select an eligible enquiry';

  @override
  String get servicesJobAssignmentChangeEnquiry => 'Change enquiry';

  @override
  String get servicesJobAssignmentNoIssues => 'No enquiry issues recorded.';

  @override
  String get servicesJobAssignmentMaterialReceived => 'Material received';

  @override
  String get servicesJobAssignmentWork => 'Work';

  @override
  String get servicesJobAssignmentTechnician => 'Technician';

  @override
  String get servicesJobAssignmentServiceTeam => 'Service team';

  @override
  String get servicesJobAssignmentLineStatus => 'Status';

  @override
  String get servicesJobAssignmentLineStatusPending => 'Pending';

  @override
  String get servicesJobAssignmentDescriptionForWork => 'Description for work';

  @override
  String get servicesJobAssignmentAddLine => 'Add work item';

  @override
  String get servicesJobAssignmentRemoveLine => 'Remove work item';

  @override
  String servicesJobAssignmentLineTitle(String index) {
    return 'Work item $index';
  }

  @override
  String get servicesJobAssignmentNoTargets =>
      'Assign an employee, a service team, or both.';

  @override
  String get servicesJobAssignmentDetailContext => 'Enquiry context';

  @override
  String get servicesJobAssignmentDetailWork => 'Work items';

  @override
  String get servicesJobAssignmentDetailAudit => 'Record';

  @override
  String get servicesJobAssignmentDetailActivity => 'Activity';

  @override
  String get servicesJobAssignmentEdit => 'Edit assignment';

  @override
  String get servicesJobAssignmentCancel => 'Cancel assignment';

  @override
  String get servicesJobAssignmentCancelConfirmTitle => 'Cancel assignment?';

  @override
  String get servicesJobAssignmentCancelConfirmMessage =>
      'The cancelled assignment stays available historically and cannot be edited afterwards.';

  @override
  String get servicesJobAssignmentCreated => 'Job assignment created.';

  @override
  String get servicesJobAssignmentUpdated => 'Job assignment updated.';

  @override
  String get servicesJobAssignmentCancelled => 'Job assignment cancelled.';

  @override
  String get servicesJobAssignmentNoActivity => 'No activity yet.';

  @override
  String get servicesJobAssignmentCreatedBy => 'Created by';

  @override
  String get servicesJobAssignmentCreatedAt => 'Created at';

  @override
  String get servicesJobAssignmentUpdatedBy => 'Updated by';

  @override
  String get servicesJobAssignmentUpdatedAt => 'Updated at';

  @override
  String get servicesJobAssignmentVersion => 'Version';

  @override
  String get servicesJobAssignmentCancelledAt => 'Cancelled at';

  @override
  String get servicesJobAssignmentEnquiryRequired => 'Select an enquiry.';

  @override
  String get servicesJobAssignmentVisitDateRequired => 'Select a visit date.';

  @override
  String get servicesJobAssignmentLinesRequired =>
      'Add at least one work item.';

  @override
  String get servicesJobAssignmentWorkRequired =>
      'Enter the work for each item.';

  @override
  String get servicesJobAssignmentWorkTooLong => 'The work text is too long.';

  @override
  String get servicesJobAssignmentDescriptionTooLong =>
      'The description is too long.';

  @override
  String get servicesJobAssignmentTargetRequired =>
      'Assign an employee, a service team, or both.';

  @override
  String get servicesJobAssignmentEnquiryNotFound => 'Enquiry not found.';

  @override
  String get servicesJobAssignmentEnquiryNotOpen =>
      'Only open enquiries can be assigned.';

  @override
  String get servicesJobAssignmentAlreadyActive =>
      'This enquiry already has an active job assignment.';

  @override
  String get servicesJobAssignmentNotFound => 'Job assignment not found.';

  @override
  String get servicesJobAssignmentNotEditable =>
      'Only active job assignments can be edited.';

  @override
  String get servicesJobAssignmentAlreadyCancelled =>
      'This job assignment is already cancelled.';

  @override
  String get servicesJobAssignmentEmployeeInvalid =>
      'The selected employee is not available.';

  @override
  String get servicesJobAssignmentTeamInvalid =>
      'The selected service team is not available.';

  @override
  String get servicesJobAssignmentEmployeeNotInTeam =>
      'The selected employee is not a member of the selected service team.';

  @override
  String get servicesJobAssignmentSequenceFailed =>
      'Could not allocate an assignment number.';

  @override
  String get servicesJobAssignmentDenied =>
      'You do not have permission to perform this action.';

  @override
  String get servicesJobAssignmentStorageError =>
      'Could not save the job assignment. Please try again.';

  @override
  String get servicesActivityAssigned => 'Assigned';

  @override
  String get servicesActivityReopened => 'Reopened';

  @override
  String get servicesOverviewAssignmentsScheduled => 'Scheduled assignments';

  @override
  String get servicesOverviewAssignmentsToday => 'Visits today';

  @override
  String get servicesOverviewAssignmentsUpcoming => 'Upcoming visits';

  @override
  String get servicesOverviewRecentAssignments => 'Upcoming assignments';

  @override
  String get servicesOverviewNoAssignments => 'No upcoming assignments.';

  @override
  String get servicesEnquiryAssignmentSection => 'Job assignment';

  @override
  String get servicesEnquiryCreateAssignment => 'Create job assignment';

  @override
  String get servicesEnquiryViewAssignment => 'View job assignment';

  @override
  String get servicesEnquiryStatusAssigned => 'Assigned';

  @override
  String get notifServiceWorkAssignedTitle => 'Service work assigned';

  @override
  String get notifServiceWorkAssignedBody =>
      'You have been assigned service work.';

  @override
  String get servicesJobAssignmentGenerated => 'Generated when saved';
}
