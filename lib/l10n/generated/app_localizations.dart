import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar')
  ];

  /// Common/Phase 0 UI: appName.
  ///
  /// In en, this message translates to:
  /// **'Bitlogix ERP'**
  String get appName;

  /// Common/Phase 0 UI: brandName.
  ///
  /// In en, this message translates to:
  /// **'bitlogix'**
  String get brandName;

  /// Common/Phase 0 UI: save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Common/Phase 0 UI: cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Common/Phase 0 UI: close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Common/Phase 0 UI: confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Common/Phase 0 UI: delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Common/Phase 0 UI: edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Common/Phase 0 UI: add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Common/Phase 0 UI: search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Common/Phase 0 UI: filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Common/Phase 0 UI: clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Common/Phase 0 UI: retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// Common/Phase 0 UI: refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Common/Phase 0 UI: continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// Common/Phase 0 UI: back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Common/Phase 0 UI: next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Common/Phase 0 UI: done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Common/Phase 0 UI: yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Common/Phase 0 UI: no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Common/Phase 0 UI: loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// Common/Phase 0 UI: error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Common/Phase 0 UI: success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Common/Phase 0 UI: warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Common/Phase 0 UI: noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// Common/Phase 0 UI: somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Common/Phase 0 UI: home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Common/Phase 0 UI: dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Common/Phase 0 UI: employees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employees;

  /// Common/Phase 0 UI: attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// Common/Phase 0 UI: requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// Common/Phase 0 UI: reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// Common/Phase 0 UI: settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Common/Phase 0 UI: profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Common/Phase 0 UI: more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// Common/Phase 0 UI: login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Common/Phase 0 UI: logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Common/Phase 0 UI: email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Common/Phase 0 UI: phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Common/Phase 0 UI: emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or phone'**
  String get emailOrPhone;

  /// Common/Phase 0 UI: password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Common/Phase 0 UI: forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPassword;

  /// Common/Phase 0 UI: changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// Common/Phase 0 UI: welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// Common/Phase 0 UI: language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Common/Phase 0 UI: english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Common/Phase 0 UI: arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// Common/Phase 0 UI: active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Common/Phase 0 UI: inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Common/Phase 0 UI: pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Common/Phase 0 UI: approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// Common/Phase 0 UI: rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// Common/Phase 0 UI: failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// Common/Phase 0 UI: synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// Common/Phase 0 UI: draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// Common/Phase 0 UI: scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// Common/Phase 0 UI: workspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get workspace;

  /// Common/Phase 0 UI: overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Common/Phase 0 UI: internal.
  ///
  /// In en, this message translates to:
  /// **'Internal'**
  String get internal;

  /// Common/Phase 0 UI: designSystem.
  ///
  /// In en, this message translates to:
  /// **'Design system'**
  String get designSystem;

  /// Common/Phase 0 UI: erpWorkspace.
  ///
  /// In en, this message translates to:
  /// **'ERP workspace'**
  String get erpWorkspace;

  /// Common/Phase 0 UI: foundationPhase.
  ///
  /// In en, this message translates to:
  /// **'Foundation / Phase 0'**
  String get foundationPhase;

  /// Common/Phase 0 UI: designPreview.
  ///
  /// In en, this message translates to:
  /// **'Design preview'**
  String get designPreview;

  /// Common/Phase 0 UI: designSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The shared language of your ERP workspace.'**
  String get designSystemSubtitle;

  /// Common/Phase 0 UI: internalPreview.
  ///
  /// In en, this message translates to:
  /// **'Internal preview'**
  String get internalPreview;

  /// Common/Phase 0 UI: openDialog.
  ///
  /// In en, this message translates to:
  /// **'Open dialog'**
  String get openDialog;

  /// Common/Phase 0 UI: reviewChanges.
  ///
  /// In en, this message translates to:
  /// **'Review changes'**
  String get reviewChanges;

  /// Common/Phase 0 UI: confirmationPreview.
  ///
  /// In en, this message translates to:
  /// **'This is a preview of the shared confirmation dialog.'**
  String get confirmationPreview;

  /// Common/Phase 0 UI: looksGood.
  ///
  /// In en, this message translates to:
  /// **'Looks good'**
  String get looksGood;

  /// Common/Phase 0 UI: consistencyNotice.
  ///
  /// In en, this message translates to:
  /// **'Consistent by design. Every future module uses these foundations.'**
  String get consistencyNotice;

  /// Common/Phase 0 UI: designLanguage.
  ///
  /// In en, this message translates to:
  /// **'Design language'**
  String get designLanguage;

  /// Common/Phase 0 UI: oneSystem.
  ///
  /// In en, this message translates to:
  /// **'One system'**
  String get oneSystem;

  /// Common/Phase 0 UI: sharedAcrossModules.
  ///
  /// In en, this message translates to:
  /// **'Shared across every module'**
  String get sharedAcrossModules;

  /// Common/Phase 0 UI: dataStrategy.
  ///
  /// In en, this message translates to:
  /// **'Data strategy'**
  String get dataStrategy;

  /// Common/Phase 0 UI: localFirst.
  ///
  /// In en, this message translates to:
  /// **'Local first'**
  String get localFirst;

  /// Common/Phase 0 UI: repositorySourceOfTruth.
  ///
  /// In en, this message translates to:
  /// **'Repositories own the source of truth'**
  String get repositorySourceOfTruth;

  /// Common/Phase 0 UI: layout.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get layout;

  /// Common/Phase 0 UI: adaptive.
  ///
  /// In en, this message translates to:
  /// **'Adaptive'**
  String get adaptive;

  /// Common/Phase 0 UI: adaptiveDetail.
  ///
  /// In en, this message translates to:
  /// **'Compact through large workspaces'**
  String get adaptiveDetail;

  /// Common/Phase 0 UI: typography.
  ///
  /// In en, this message translates to:
  /// **'Typography'**
  String get typography;

  /// Common/Phase 0 UI: typographySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Inter / locally bundled / clear at every density'**
  String get typographySubtitle;

  /// Common/Phase 0 UI: typographyDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get typographyDisplay;

  /// Common/Phase 0 UI: typographyPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Page title'**
  String get typographyPageTitle;

  /// Common/Phase 0 UI: typographySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Section title'**
  String get typographySectionTitle;

  /// Common/Phase 0 UI: typographyCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Card title'**
  String get typographyCardTitle;

  /// Common/Phase 0 UI: typographyBodyLarge.
  ///
  /// In en, this message translates to:
  /// **'Body large'**
  String get typographyBodyLarge;

  /// Common/Phase 0 UI: typographyBody.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get typographyBody;

  /// Common/Phase 0 UI: typographyBodySmall.
  ///
  /// In en, this message translates to:
  /// **'Body small'**
  String get typographyBodySmall;

  /// Common/Phase 0 UI: typographyLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get typographyLabel;

  /// Common/Phase 0 UI: typographyCaption.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get typographyCaption;

  /// Common/Phase 0 UI: semanticPalette.
  ///
  /// In en, this message translates to:
  /// **'Semantic palette'**
  String get semanticPalette;

  /// Common/Phase 0 UI: colorBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get colorBrand;

  /// Common/Phase 0 UI: colorSurface.
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get colorSurface;

  /// Common/Phase 0 UI: colorBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get colorBackground;

  /// Common/Phase 0 UI: colorBorder.
  ///
  /// In en, this message translates to:
  /// **'Border'**
  String get colorBorder;

  /// Common/Phase 0 UI: colorTextPrimary.
  ///
  /// In en, this message translates to:
  /// **'Text primary'**
  String get colorTextPrimary;

  /// Common/Phase 0 UI: colorTextSecondary.
  ///
  /// In en, this message translates to:
  /// **'Text secondary'**
  String get colorTextSecondary;

  /// Common/Phase 0 UI: colorTextMuted.
  ///
  /// In en, this message translates to:
  /// **'Text muted'**
  String get colorTextMuted;

  /// Common/Phase 0 UI: colorDanger.
  ///
  /// In en, this message translates to:
  /// **'Danger'**
  String get colorDanger;

  /// Common/Phase 0 UI: colorInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get colorInfo;

  /// Common/Phase 0 UI: actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// Common/Phase 0 UI: primaryAction.
  ///
  /// In en, this message translates to:
  /// **'Primary action'**
  String get primaryAction;

  /// Common/Phase 0 UI: previewActionComplete.
  ///
  /// In en, this message translates to:
  /// **'Preview action complete'**
  String get previewActionComplete;

  /// Common/Phase 0 UI: secondaryAction.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get secondaryAction;

  /// Common/Phase 0 UI: textAction.
  ///
  /// In en, this message translates to:
  /// **'Text action'**
  String get textAction;

  /// Common/Phase 0 UI: moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// Common/Phase 0 UI: disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// Common/Phase 0 UI: saving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get saving;

  /// Common/Phase 0 UI: formControls.
  ///
  /// In en, this message translates to:
  /// **'Form controls'**
  String get formControls;

  /// Common/Phase 0 UI: formControlsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shared field styling, validation and accessible labels.'**
  String get formControlsSubtitle;

  /// Common/Phase 0 UI: fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// Common/Phase 0 UI: enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get enterName;

  /// Common/Phase 0 UI: workLocation.
  ///
  /// In en, this message translates to:
  /// **'Work location'**
  String get workLocation;

  /// Common/Phase 0 UI: office.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get office;

  /// Common/Phase 0 UI: remote.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get remote;

  /// Common/Phase 0 UI: effectiveDate.
  ///
  /// In en, this message translates to:
  /// **'Effective date'**
  String get effectiveDate;

  /// Common/Phase 0 UI: startTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get startTime;

  /// Common/Phase 0 UI: validationExample.
  ///
  /// In en, this message translates to:
  /// **'Validation example'**
  String get validationExample;

  /// Common/Phase 0 UI: informationCard.
  ///
  /// In en, this message translates to:
  /// **'Information card'**
  String get informationCard;

  /// Common/Phase 0 UI: informationCardMessage.
  ///
  /// In en, this message translates to:
  /// **'Use a concise explanation to help people make a decision.'**
  String get informationCardMessage;

  /// Common/Phase 0 UI: statusAndFeedback.
  ///
  /// In en, this message translates to:
  /// **'Status & feedback'**
  String get statusAndFeedback;

  /// Common/Phase 0 UI: localChangesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Your changes are available on this device.'**
  String get localChangesAvailable;

  /// Common/Phase 0 UI: recordsNeedAttention.
  ///
  /// In en, this message translates to:
  /// **'Some records need your attention.'**
  String get recordsNeedAttention;

  /// Common/Phase 0 UI: actionFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete this action.'**
  String get actionFailed;

  /// Common/Phase 0 UI: loadingRecords.
  ///
  /// In en, this message translates to:
  /// **'Loading records...'**
  String get loadingRecords;

  /// Common/Phase 0 UI: noRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get noRecordsYet;

  /// Common/Phase 0 UI: noRecordsMessage.
  ///
  /// In en, this message translates to:
  /// **'Records will appear here when your team gets started.'**
  String get noRecordsMessage;

  /// Common/Phase 0 UI: retryWhenConnected.
  ///
  /// In en, this message translates to:
  /// **'Please try again when a connection is available.'**
  String get retryWhenConnected;

  /// Common/Phase 0 UI: filtersAndTable.
  ///
  /// In en, this message translates to:
  /// **'Filters & table'**
  String get filtersAndTable;

  /// Common/Phase 0 UI: illustrativeRecords.
  ///
  /// In en, this message translates to:
  /// **'Illustrative records / no operational employee data'**
  String get illustrativeRecords;

  /// Common/Phase 0 UI: activeOnly.
  ///
  /// In en, this message translates to:
  /// **'Active only'**
  String get activeOnly;

  /// Common/Phase 0 UI: clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// Common/Phase 0 UI: employee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// Common/Phase 0 UI: location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Common/Phase 0 UI: status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Common/Phase 0 UI: sampleAlex.
  ///
  /// In en, this message translates to:
  /// **'Alex Morgan'**
  String get sampleAlex;

  /// Common/Phase 0 UI: sampleSam.
  ///
  /// In en, this message translates to:
  /// **'Sam Taylor'**
  String get sampleSam;

  /// Common/Phase 0 UI: dialogsAndSheets.
  ///
  /// In en, this message translates to:
  /// **'Dialogs & sheets'**
  String get dialogsAndSheets;

  /// Common/Phase 0 UI: previewDialog.
  ///
  /// In en, this message translates to:
  /// **'Preview dialog'**
  String get previewDialog;

  /// Common/Phase 0 UI: sharedDialog.
  ///
  /// In en, this message translates to:
  /// **'Shared dialog'**
  String get sharedDialog;

  /// Common/Phase 0 UI: sharedDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Focused content for a clear decision.'**
  String get sharedDialogMessage;

  /// Common/Phase 0 UI: previewBottomSheet.
  ///
  /// In en, this message translates to:
  /// **'Preview bottom sheet'**
  String get previewBottomSheet;

  /// Common/Phase 0 UI: quickDetails.
  ///
  /// In en, this message translates to:
  /// **'Quick details'**
  String get quickDetails;

  /// Common/Phase 0 UI: quickDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A shared mobile presentation pattern.'**
  String get quickDetailsSubtitle;

  /// Common/Phase 0 UI: foundationDetails.
  ///
  /// In en, this message translates to:
  /// **'Foundation details'**
  String get foundationDetails;

  /// Common/Phase 0 UI: architecture.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get architecture;

  /// Common/Phase 0 UI: featureFirst.
  ///
  /// In en, this message translates to:
  /// **'Feature first'**
  String get featureFirst;

  /// Common/Phase 0 UI: theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Common/Phase 0 UI: lightSemanticTokens.
  ///
  /// In en, this message translates to:
  /// **'Light / semantic tokens'**
  String get lightSemanticTokens;

  /// Common/Phase 0 UI: persistence.
  ///
  /// In en, this message translates to:
  /// **'Persistence'**
  String get persistence;

  /// Common/Phase 0 UI: persistenceDetail.
  ///
  /// In en, this message translates to:
  /// **'Drift + secure session storage'**
  String get persistenceDetail;

  /// Common/Phase 0 UI: internalPreviewPhase.
  ///
  /// In en, this message translates to:
  /// **'Internal preview / Phase 0'**
  String get internalPreviewPhase;

  /// Common/Phase 0 UI: workspaceTitle.
  ///
  /// In en, this message translates to:
  /// **'A foundation for what is next'**
  String get workspaceTitle;

  /// Common/Phase 0 UI: workspaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One workspace. Every ERP module.'**
  String get workspaceSubtitle;

  /// Common/Phase 0 UI: workspaceInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Your ERP starts here'**
  String get workspaceInfoTitle;

  /// Common/Phase 0 UI: workspaceInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'The local-first architecture and shared design system are ready. Business modules will be introduced in future phases.'**
  String get workspaceInfoMessage;

  /// Common/Phase 0 UI: phaseReady.
  ///
  /// In en, this message translates to:
  /// **'Phase 0 / Foundation ready'**
  String get phaseReady;

  /// Common/Phase 0 UI: pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'This page could not be found.'**
  String get pageNotFound;

  /// Common/Phase 0 UI: showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// Common/Phase 0 UI: hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// Common/Phase 0 UI: searchRecords.
  ///
  /// In en, this message translates to:
  /// **'Search records'**
  String get searchRecords;

  /// Common/Phase 0 UI: selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// Common/Phase 0 UI: selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// Common/Phase 0 UI: unableToLoadRecords.
  ///
  /// In en, this message translates to:
  /// **'Unable to load records'**
  String get unableToLoadRecords;

  /// Common/Phase 0 UI: noRecords.
  ///
  /// In en, this message translates to:
  /// **'No records'**
  String get noRecords;

  /// Common/Phase 0 UI: previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPage;

  /// Common/Phase 0 UI: nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPage;

  /// Common/Phase 0 UI: fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// Common/Phase 0 UI: emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// Common/Phase 0 UI: emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get emailInvalid;

  /// Common/Phase 0 UI: failureTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please try again.'**
  String get failureTimeout;

  /// Common/Phase 0 UI: failureOffline.
  ///
  /// In en, this message translates to:
  /// **'Connection unavailable. Your local data is still available.'**
  String get failureOffline;

  /// Common/Phase 0 UI: failureCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled.'**
  String get failureCancelled;

  /// Common/Phase 0 UI: failureSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired.'**
  String get failureSessionExpired;

  /// Common/Phase 0 UI: failureRequest.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete the request.'**
  String get failureRequest;

  /// Common/Phase 0 UI: failureInvalidData.
  ///
  /// In en, this message translates to:
  /// **'The response could not be read.'**
  String get failureInvalidData;

  /// Common/Phase 0 UI: failureLocationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Enable location services to continue.'**
  String get failureLocationDisabled;

  /// Common/Phase 0 UI: failureLocationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required for this action.'**
  String get failureLocationPermission;

  /// Common/Phase 0 UI: failureLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to determine your location.'**
  String get failureLocationUnavailable;

  /// Common/Phase 0 UI: failureStorageWrite.
  ///
  /// In en, this message translates to:
  /// **'Unable to save changes on this device.'**
  String get failureStorageWrite;

  /// Common/Phase 0 UI: failureStorageUpdate.
  ///
  /// In en, this message translates to:
  /// **'Unable to update local changes.'**
  String get failureStorageUpdate;

  /// Common/Phase 0 UI: failureSync.
  ///
  /// In en, this message translates to:
  /// **'Some changes could not be synchronized.'**
  String get failureSync;

  /// Common/Phase 0 UI: failurePreferencesWrite.
  ///
  /// In en, this message translates to:
  /// **'Language changed for this session, but could not be saved.'**
  String get failurePreferencesWrite;

  /// Common/Phase 0 UI: failurePreferencesRead.
  ///
  /// In en, this message translates to:
  /// **'Saved language could not be restored.'**
  String get failurePreferencesRead;

  /// Common/Phase 0 UI: formattingTitle.
  ///
  /// In en, this message translates to:
  /// **'Locale-aware formatting'**
  String get formattingTitle;

  /// Common/Phase 0 UI: date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Common/Phase 0 UI: time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Common/Phase 0 UI: duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Common/Phase 0 UI: number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get number;

  /// Common/Phase 0 UI: percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// Common/Phase 0 UI: currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Common/Phase 0 UI: month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// Common/Phase 0 UI: languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Language and layout update immediately.'**
  String get languageSubtitle;

  /// No description provided for @englishNativeName.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishNativeName;

  /// No description provided for @arabicNativeName.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabicNativeName;

  /// typographySample
  ///
  /// In en, this message translates to:
  /// **'{level} / Built for clarity'**
  String typographySample(String level);

  /// paginationSummary
  ///
  /// In en, this message translates to:
  /// **'{start}–{end} of {total}'**
  String paginationSummary(String start, String end, String total);

  /// durationHoursMinutes
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(String hours, String minutes);

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your company workspace.'**
  String get authSignInSubtitle;

  /// No description provided for @authIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Email or phone number'**
  String get authIdentifier;

  /// No description provided for @authIdentifierRequired.
  ///
  /// In en, this message translates to:
  /// **'Email or phone number is required'**
  String get authIdentifierRequired;

  /// No description provided for @authIdentifierInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email or phone number'**
  String get authIdentifierInvalid;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get authPasswordRequired;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email, phone number, or password.'**
  String get authInvalidCredentials;

  /// No description provided for @authLoggingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get authLoggingIn;

  /// No description provided for @authBrandStatement.
  ///
  /// In en, this message translates to:
  /// **'A connected workspace.\nA clearer working day.'**
  String get authBrandStatement;

  /// No description provided for @authBrandDescription.
  ///
  /// In en, this message translates to:
  /// **'One place for your people, operations, and the work ahead.'**
  String get authBrandDescription;

  /// No description provided for @authWorkspaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Company workspace'**
  String get authWorkspaceLabel;

  /// No description provided for @authSessionNote.
  ///
  /// In en, this message translates to:
  /// **'Your session stays signed in on this device until you sign out or it expires.'**
  String get authSessionNote;

  /// No description provided for @authInitializing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your workspace…'**
  String get authInitializing;

  /// No description provided for @authDemoAccounts.
  ///
  /// In en, this message translates to:
  /// **'Demo accounts'**
  String get authDemoAccounts;

  /// No description provided for @authDemoNotice.
  ///
  /// In en, this message translates to:
  /// **'Local demonstration only. No backend is connected.'**
  String get authDemoNotice;

  /// No description provided for @authDemoDisabled.
  ///
  /// In en, this message translates to:
  /// **'Demo authentication is disabled in this configuration. A backend has not been connected yet.'**
  String get authDemoDisabled;

  /// No description provided for @authDemoPassword.
  ///
  /// In en, this message translates to:
  /// **'Demo password'**
  String get authDemoPassword;

  /// No description provided for @authSessionStorageError.
  ///
  /// In en, this message translates to:
  /// **'We could not access the secure session. Please try again.'**
  String get authSessionStorageError;

  /// No description provided for @authServerError.
  ///
  /// In en, this message translates to:
  /// **'The sign-in service is temporarily unavailable. Please try again.'**
  String get authServerError;

  /// No description provided for @authForgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get authForgotTitle;

  /// No description provided for @authForgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the email or phone number associated with your account.'**
  String get authForgotSubtitle;

  /// No description provided for @authResetInformation.
  ///
  /// In en, this message translates to:
  /// **'If an account matches these details, password reset instructions will be sent.'**
  String get authResetInformation;

  /// No description provided for @authResetDemoNote.
  ///
  /// In en, this message translates to:
  /// **'In this demo, no email or SMS is sent.'**
  String get authResetDemoNote;

  /// No description provided for @authResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Request received'**
  String get authResetTitle;

  /// No description provided for @authBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToLogin;

  /// No description provided for @authSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Please wait…'**
  String get authSubmitting;

  /// No description provided for @authChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get authChangePassword;

  /// No description provided for @authChangeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password for your account.'**
  String get authChangeSubtitle;

  /// No description provided for @authCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get authCurrentPassword;

  /// No description provided for @authNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get authConfirmPassword;

  /// No description provided for @authPasswordConstraints.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters, including a letter and a number.'**
  String get authPasswordConstraints;

  /// No description provided for @authPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordsMismatch;

  /// No description provided for @authPasswordMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'Choose a password different from your current password'**
  String get authPasswordMustDiffer;

  /// No description provided for @authCurrentPasswordInvalid.
  ///
  /// In en, this message translates to:
  /// **'The current password is incorrect.'**
  String get authCurrentPasswordInvalid;

  /// No description provided for @authPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password updated for this demo session.'**
  String get authPasswordChanged;

  /// No description provided for @authPasswordDemoNote.
  ///
  /// In en, this message translates to:
  /// **'Demo password changes last until the app restarts. No password is stored on this device.'**
  String get authPasswordDemoNote;

  /// No description provided for @authBackToWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Back to workspace'**
  String get authBackToWorkspace;

  /// No description provided for @authConfirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your workspace?'**
  String get authConfirmLogout;

  /// No description provided for @authLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Your secure session will be removed from this device.'**
  String get authLogoutMessage;

  /// No description provided for @authHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your workspace is ready'**
  String get authHomeTitle;

  /// No description provided for @authHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are signed in. Business modules will be added in the next phases.'**
  String get authHomeSubtitle;

  /// No description provided for @authAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get authAccount;

  /// No description provided for @authCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get authCompany;

  /// No description provided for @authRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get authRole;

  /// No description provided for @authPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get authPermissions;

  /// No description provided for @authAccountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account status'**
  String get authAccountStatus;

  /// No description provided for @authStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get authStatusActive;

  /// No description provided for @authStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get authStatusSuspended;

  /// No description provided for @authStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get authStatusInactive;

  /// No description provided for @authRoleSuperAdmin.
  ///
  /// In en, this message translates to:
  /// **'Super administrator'**
  String get authRoleSuperAdmin;

  /// No description provided for @authRoleCompanyAdmin.
  ///
  /// In en, this message translates to:
  /// **'Company administrator'**
  String get authRoleCompanyAdmin;

  /// No description provided for @authRoleHr.
  ///
  /// In en, this message translates to:
  /// **'Human resources'**
  String get authRoleHr;

  /// No description provided for @authRoleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get authRoleManager;

  /// No description provided for @authRoleEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get authRoleEmployee;

  /// No description provided for @authPermissionViewer.
  ///
  /// In en, this message translates to:
  /// **'Assigned permissions'**
  String get authPermissionViewer;

  /// No description provided for @authEmployeeLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked employee record'**
  String get authEmployeeLinked;

  /// No description provided for @authEmployeeUnlinked.
  ///
  /// In en, this message translates to:
  /// **'No employee record linked'**
  String get authEmployeeUnlinked;

  /// No description provided for @authPermissionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} permissions assigned'**
  String authPermissionCount(String count);

  /// No description provided for @authGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String authGreeting(String name);

  /// No description provided for @permissionEmployeeViewSelf.
  ///
  /// In en, this message translates to:
  /// **'View own employee record'**
  String get permissionEmployeeViewSelf;

  /// No description provided for @permissionEmployeeViewTeam.
  ///
  /// In en, this message translates to:
  /// **'View team employees'**
  String get permissionEmployeeViewTeam;

  /// No description provided for @permissionEmployeeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all employees'**
  String get permissionEmployeeViewAll;

  /// No description provided for @permissionEmployeeCreate.
  ///
  /// In en, this message translates to:
  /// **'Create employees'**
  String get permissionEmployeeCreate;

  /// No description provided for @permissionEmployeeUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update employees'**
  String get permissionEmployeeUpdate;

  /// No description provided for @permissionEmployeeDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate employees'**
  String get permissionEmployeeDeactivate;

  /// No description provided for @permissionAttendanceViewSelf.
  ///
  /// In en, this message translates to:
  /// **'View own attendance'**
  String get permissionAttendanceViewSelf;

  /// No description provided for @permissionAttendanceViewTeam.
  ///
  /// In en, this message translates to:
  /// **'View team attendance'**
  String get permissionAttendanceViewTeam;

  /// No description provided for @permissionAttendanceViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all attendance'**
  String get permissionAttendanceViewAll;

  /// No description provided for @permissionAttendancePunchIn.
  ///
  /// In en, this message translates to:
  /// **'Punch in'**
  String get permissionAttendancePunchIn;

  /// No description provided for @permissionAttendancePunchOut.
  ///
  /// In en, this message translates to:
  /// **'Punch out'**
  String get permissionAttendancePunchOut;

  /// No description provided for @permissionAttendanceBreak.
  ///
  /// In en, this message translates to:
  /// **'Manage own breaks'**
  String get permissionAttendanceBreak;

  /// No description provided for @permissionAttendanceRequestCorrection.
  ///
  /// In en, this message translates to:
  /// **'Request attendance corrections'**
  String get permissionAttendanceRequestCorrection;

  /// No description provided for @permissionAttendanceCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct attendance'**
  String get permissionAttendanceCorrect;

  /// No description provided for @permissionAttendanceApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve attendance'**
  String get permissionAttendanceApprove;

  /// No description provided for @permissionShiftView.
  ///
  /// In en, this message translates to:
  /// **'View shifts'**
  String get permissionShiftView;

  /// No description provided for @permissionShiftManage.
  ///
  /// In en, this message translates to:
  /// **'Manage shifts'**
  String get permissionShiftManage;

  /// No description provided for @permissionWorkLocationView.
  ///
  /// In en, this message translates to:
  /// **'View work locations'**
  String get permissionWorkLocationView;

  /// No description provided for @permissionWorkLocationManage.
  ///
  /// In en, this message translates to:
  /// **'Manage work locations'**
  String get permissionWorkLocationManage;

  /// No description provided for @permissionAttendancePolicyView.
  ///
  /// In en, this message translates to:
  /// **'View attendance policies'**
  String get permissionAttendancePolicyView;

  /// No description provided for @permissionAttendancePolicyManage.
  ///
  /// In en, this message translates to:
  /// **'Manage attendance policies'**
  String get permissionAttendancePolicyManage;

  /// No description provided for @permissionCompanyManage.
  ///
  /// In en, this message translates to:
  /// **'Manage company'**
  String get permissionCompanyManage;

  /// No description provided for @permissionUserManage.
  ///
  /// In en, this message translates to:
  /// **'Manage user accounts'**
  String get permissionUserManage;

  /// No description provided for @permissionRoleManage.
  ///
  /// In en, this message translates to:
  /// **'Manage roles'**
  String get permissionRoleManage;

  /// No description provided for @permissionAttendanceReportView.
  ///
  /// In en, this message translates to:
  /// **'View attendance reports'**
  String get permissionAttendanceReportView;

  /// No description provided for @shellDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get shellDashboard;

  /// No description provided for @shellEmployees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get shellEmployees;

  /// No description provided for @shellAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get shellAttendance;

  /// No description provided for @shellReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get shellReports;

  /// No description provided for @shellSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get shellSettings;

  /// No description provided for @shellProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get shellProfile;

  /// No description provided for @shellMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get shellMore;

  /// No description provided for @shellGeneral.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get shellGeneral;

  /// No description provided for @shellPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get shellPeople;

  /// No description provided for @shellWorkforce.
  ///
  /// In en, this message translates to:
  /// **'Workforce'**
  String get shellWorkforce;

  /// No description provided for @shellInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get shellInsights;

  /// No description provided for @shellAdministration.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get shellAdministration;

  /// No description provided for @shellAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get shellAccount;

  /// No description provided for @shellServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get shellServices;

  /// No description provided for @shellFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get shellFinance;

  /// No description provided for @shellDashboardDescription.
  ///
  /// In en, this message translates to:
  /// **'Your workspace overview will be introduced in a later phase.'**
  String get shellDashboardDescription;

  /// No description provided for @shellEmployeesDescription.
  ///
  /// In en, this message translates to:
  /// **'Employee management will be implemented in a later phase.'**
  String get shellEmployeesDescription;

  /// No description provided for @shellAttendanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Attendance workflows will be implemented in a later phase.'**
  String get shellAttendanceDescription;

  /// No description provided for @shellReportsDescription.
  ///
  /// In en, this message translates to:
  /// **'Reporting will be implemented in a later phase.'**
  String get shellReportsDescription;

  /// No description provided for @shellSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Company settings will be implemented in a later phase.'**
  String get shellSettingsDescription;

  /// No description provided for @shellProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Profile editing will be introduced in a later phase.'**
  String get shellProfileDescription;

  /// No description provided for @shellPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready for the next phase'**
  String get shellPlaceholderTitle;

  /// No description provided for @shellPlaceholderMessage.
  ///
  /// In en, this message translates to:
  /// **'This area is reserved for a future ERP module. No business data is available yet.'**
  String get shellPlaceholderMessage;

  /// No description provided for @shellMoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore the other areas available to your account.'**
  String get shellMoreDescription;

  /// No description provided for @shellSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Global search'**
  String get shellSearchTitle;

  /// No description provided for @shellSearchMessage.
  ///
  /// In en, this message translates to:
  /// **'Global search will become available as ERP modules are added.'**
  String get shellSearchMessage;

  /// No description provided for @shellNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get shellNotifications;

  /// No description provided for @shellNoNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get shellNoNotifications;

  /// No description provided for @shellNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no notifications to display.'**
  String get shellNotificationsMessage;

  /// No description provided for @shellAccessRestricted.
  ///
  /// In en, this message translates to:
  /// **'Access restricted'**
  String get shellAccessRestricted;

  /// No description provided for @shellAccessMessage.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this area.'**
  String get shellAccessMessage;

  /// No description provided for @shellModuleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Module unavailable'**
  String get shellModuleUnavailable;

  /// No description provided for @shellModuleUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'This module is not enabled for your organization.'**
  String get shellModuleUnavailableMessage;

  /// No description provided for @shellNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get shellNotFound;

  /// No description provided for @shellNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The page you requested could not be found.'**
  String get shellNotFoundMessage;

  /// No description provided for @shellReturnToWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Return to workspace'**
  String get shellReturnToWorkspace;

  /// No description provided for @shellGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get shellGoBack;

  /// No description provided for @shellCollapseSidebar.
  ///
  /// In en, this message translates to:
  /// **'Collapse sidebar'**
  String get shellCollapseSidebar;

  /// No description provided for @shellExpandSidebar.
  ///
  /// In en, this message translates to:
  /// **'Expand sidebar'**
  String get shellExpandSidebar;

  /// No description provided for @shellCompanyInformation.
  ///
  /// In en, this message translates to:
  /// **'Company information'**
  String get shellCompanyInformation;

  /// No description provided for @shellTimezone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get shellTimezone;

  /// No description provided for @shellCompanyCode.
  ///
  /// In en, this message translates to:
  /// **'Company code'**
  String get shellCompanyCode;

  /// No description provided for @shellAccountMenu.
  ///
  /// In en, this message translates to:
  /// **'Open account menu'**
  String get shellAccountMenu;

  /// No description provided for @shellBreadcrumbs.
  ///
  /// In en, this message translates to:
  /// **'Breadcrumb navigation'**
  String get shellBreadcrumbs;

  /// No description provided for @shellNoDestinations.
  ///
  /// In en, this message translates to:
  /// **'No available destinations'**
  String get shellNoDestinations;

  /// No description provided for @shellNoDestinationsMessage.
  ///
  /// In en, this message translates to:
  /// **'No workspace areas are available for this account. Contact your administrator.'**
  String get shellNoDestinationsMessage;

  /// No description provided for @dashboardMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String dashboardMorning(String name);

  /// No description provided for @dashboardAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String dashboardAfternoon(String name);

  /// No description provided for @dashboardEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String dashboardEvening(String name);

  /// No description provided for @dashboardDemo.
  ///
  /// In en, this message translates to:
  /// **'Demo preview · {date}'**
  String dashboardDemo(String date);

  /// No description provided for @dashboardSelfContext.
  ///
  /// In en, this message translates to:
  /// **'Your workforce at a glance'**
  String get dashboardSelfContext;

  /// No description provided for @dashboardTeamContext.
  ///
  /// In en, this message translates to:
  /// **'Your team at a glance'**
  String get dashboardTeamContext;

  /// No description provided for @dashboardCompanyContext.
  ///
  /// In en, this message translates to:
  /// **'Your company workforce at a glance'**
  String get dashboardCompanyContext;

  /// No description provided for @dashboardNoScope.
  ///
  /// In en, this message translates to:
  /// **'Your workspace'**
  String get dashboardNoScope;

  /// No description provided for @dashboardToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashboardToday;

  /// No description provided for @dashboardMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get dashboardMonth;

  /// No description provided for @dashboardEmployees.
  ///
  /// In en, this message translates to:
  /// **'Total employees'**
  String get dashboardEmployees;

  /// No description provided for @dashboardTeamSize.
  ///
  /// In en, this message translates to:
  /// **'Team size'**
  String get dashboardTeamSize;

  /// No description provided for @dashboardPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get dashboardPresent;

  /// No description provided for @dashboardLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get dashboardLate;

  /// No description provided for @dashboardAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get dashboardAbsent;

  /// No description provided for @dashboardLeave.
  ///
  /// In en, this message translates to:
  /// **'On leave'**
  String get dashboardLeave;

  /// No description provided for @dashboardWorking.
  ///
  /// In en, this message translates to:
  /// **'Currently working'**
  String get dashboardWorking;

  /// No description provided for @dashboardBreak.
  ///
  /// In en, this message translates to:
  /// **'On break'**
  String get dashboardBreak;

  /// No description provided for @dashboardCorrections.
  ///
  /// In en, this message translates to:
  /// **'Pending corrections'**
  String get dashboardCorrections;

  /// No description provided for @dashboardHours.
  ///
  /// In en, this message translates to:
  /// **'Work hours'**
  String get dashboardHours;

  /// No description provided for @dashboardRate.
  ///
  /// In en, this message translates to:
  /// **'Attendance rate'**
  String get dashboardRate;

  /// No description provided for @dashboardLocations.
  ///
  /// In en, this message translates to:
  /// **'Work locations'**
  String get dashboardLocations;

  /// No description provided for @dashboardUsers.
  ///
  /// In en, this message translates to:
  /// **'Active users'**
  String get dashboardUsers;

  /// No description provided for @dashboardShift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get dashboardShift;

  /// No description provided for @dashboardLocation.
  ///
  /// In en, this message translates to:
  /// **'Work location'**
  String get dashboardLocation;

  /// No description provided for @dashboardOffice.
  ///
  /// In en, this message translates to:
  /// **'Hyderabad office · demo'**
  String get dashboardOffice;

  /// No description provided for @dashboardNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started · preview'**
  String get dashboardNotStarted;

  /// No description provided for @dashboardAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance status'**
  String get dashboardAttendance;

  /// No description provided for @dashboardAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get dashboardAttention;

  /// No description provided for @dashboardActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get dashboardActivity;

  /// No description provided for @dashboardQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get dashboardQuickActions;

  /// No description provided for @dashboardStatus.
  ///
  /// In en, this message translates to:
  /// **'Attendance snapshot'**
  String get dashboardStatus;

  /// No description provided for @dashboardOnTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get dashboardOnTime;

  /// No description provided for @dashboardPresentDetail.
  ///
  /// In en, this message translates to:
  /// **'Includes late arrivals'**
  String get dashboardPresentDetail;

  /// No description provided for @dashboardLateAlert.
  ///
  /// In en, this message translates to:
  /// **'{count} late arrivals to review'**
  String dashboardLateAlert(String count);

  /// No description provided for @dashboardCorrectionsAlert.
  ///
  /// In en, this message translates to:
  /// **'{count} corrections awaiting review'**
  String dashboardCorrectionsAlert(String count);

  /// No description provided for @dashboardCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'{name} checked in'**
  String dashboardCheckedIn(String name);

  /// No description provided for @dashboardBreakStarted.
  ///
  /// In en, this message translates to:
  /// **'{name} started a break'**
  String dashboardBreakStarted(String name);

  /// No description provided for @dashboardCorrectionSubmitted.
  ///
  /// In en, this message translates to:
  /// **'{name} submitted a correction'**
  String dashboardCorrectionSubmitted(String name);

  /// No description provided for @dashboardActivityDetail.
  ///
  /// In en, this message translates to:
  /// **'Demo attendance activity'**
  String get dashboardActivityDetail;

  /// No description provided for @dashboardNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get dashboardNoActivity;

  /// No description provided for @dashboardNoAttention.
  ///
  /// In en, this message translates to:
  /// **'Nothing needs attention'**
  String get dashboardNoAttention;

  /// No description provided for @dashboardEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No workforce data yet'**
  String get dashboardEmptyTitle;

  /// No description provided for @dashboardEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Workforce insights appear here when data and access are available.'**
  String get dashboardEmptyMessage;

  /// No description provided for @dashboardError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load your dashboard. Please try again.'**
  String get dashboardError;

  /// No description provided for @dashboardRefreshError.
  ///
  /// In en, this message translates to:
  /// **'Refresh failed. Your previous snapshot is still available.'**
  String get dashboardRefreshError;

  /// No description provided for @dashboardRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get dashboardRefresh;

  /// No description provided for @dashboardRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing dashboard'**
  String get dashboardRefreshing;

  /// No description provided for @dashboardTimeRange.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String dashboardTimeRange(String start, String end);

  /// No description provided for @durationHoursOnly.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String durationHoursOnly(String hours);

  /// No description provided for @empAdd.
  ///
  /// In en, this message translates to:
  /// **'Add employee'**
  String get empAdd;

  /// No description provided for @empEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit employee'**
  String get empEdit;

  /// No description provided for @empDetails.
  ///
  /// In en, this message translates to:
  /// **'Employee details'**
  String get empDetails;

  /// No description provided for @empPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get empPersonal;

  /// No description provided for @empEmployment.
  ///
  /// In en, this message translates to:
  /// **'Employment information'**
  String get empEmployment;

  /// No description provided for @empAttendanceConfig.
  ///
  /// In en, this message translates to:
  /// **'Attendance configuration'**
  String get empAttendanceConfig;

  /// No description provided for @empAccountAccess.
  ///
  /// In en, this message translates to:
  /// **'Account access'**
  String get empAccountAccess;

  /// No description provided for @empCode.
  ///
  /// In en, this message translates to:
  /// **'Employee code'**
  String get empCode;

  /// No description provided for @empFirst.
  ///
  /// In en, this message translates to:
  /// **'First name *'**
  String get empFirst;

  /// No description provided for @empMiddle.
  ///
  /// In en, this message translates to:
  /// **'Middle name'**
  String get empMiddle;

  /// No description provided for @empLast.
  ///
  /// In en, this message translates to:
  /// **'Last name (optional)'**
  String get empLast;

  /// No description provided for @empDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get empDepartment;

  /// No description provided for @empDesignation.
  ///
  /// In en, this message translates to:
  /// **'Designation'**
  String get empDesignation;

  /// No description provided for @empManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get empManager;

  /// No description provided for @empJoined.
  ///
  /// In en, this message translates to:
  /// **'Joining date'**
  String get empJoined;

  /// No description provided for @empType.
  ///
  /// In en, this message translates to:
  /// **'Employment type'**
  String get empType;

  /// No description provided for @empPolicy.
  ///
  /// In en, this message translates to:
  /// **'Attendance policy'**
  String get empPolicy;

  /// No description provided for @empLogin.
  ///
  /// In en, this message translates to:
  /// **'Enable app login'**
  String get empLogin;

  /// No description provided for @empGenerated.
  ///
  /// In en, this message translates to:
  /// **'Automatically generated on save'**
  String get empGenerated;

  /// No description provided for @empUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Not assigned'**
  String get empUnassigned;

  /// No description provided for @empLoginNotice.
  ///
  /// In en, this message translates to:
  /// **'Local account configuration. New credentials and invitations are not issued in this phase.'**
  String get empLoginNotice;

  /// No description provided for @empCredentialPending.
  ///
  /// In en, this message translates to:
  /// **'Credential setup pending'**
  String get empCredentialPending;

  /// No description provided for @empNoLogin.
  ///
  /// In en, this message translates to:
  /// **'No linked account'**
  String get empNoLogin;

  /// No description provided for @empActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get empActive;

  /// No description provided for @empInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get empInactive;

  /// No description provided for @empFullTime.
  ///
  /// In en, this message translates to:
  /// **'Full time'**
  String get empFullTime;

  /// No description provided for @empPartTime.
  ///
  /// In en, this message translates to:
  /// **'Part time'**
  String get empPartTime;

  /// No description provided for @empContract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get empContract;

  /// No description provided for @empIntern.
  ///
  /// In en, this message translates to:
  /// **'Intern'**
  String get empIntern;

  /// No description provided for @empTemporary.
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get empTemporary;

  /// No description provided for @empFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get empFilters;

  /// No description provided for @empClear.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get empClear;

  /// No description provided for @empApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get empApply;

  /// No description provided for @empReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get empReset;

  /// No description provided for @empAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get empAll;

  /// No description provided for @empSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get empSort;

  /// No description provided for @empNameAsc.
  ///
  /// In en, this message translates to:
  /// **'Name A–Z'**
  String get empNameAsc;

  /// No description provided for @empNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Name Z–A'**
  String get empNameDesc;

  /// No description provided for @empNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest joined'**
  String get empNewest;

  /// No description provided for @empOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest joined'**
  String get empOldest;

  /// No description provided for @empEmpty.
  ///
  /// In en, this message translates to:
  /// **'No employees yet'**
  String get empEmpty;

  /// No description provided for @empEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first employee to start managing your workforce.'**
  String get empEmptyMessage;

  /// No description provided for @empNoResults.
  ///
  /// In en, this message translates to:
  /// **'No employees found'**
  String get empNoResults;

  /// No description provided for @empNoResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try changing your search or filters.'**
  String get empNoResultsMessage;

  /// No description provided for @empNotFound.
  ///
  /// In en, this message translates to:
  /// **'Employee not found'**
  String get empNotFound;

  /// No description provided for @empNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This employee is unavailable.'**
  String get empNotFoundMessage;

  /// No description provided for @empView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get empView;

  /// No description provided for @empActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate employee'**
  String get empActivate;

  /// No description provided for @empDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate employee'**
  String get empDeactivate;

  /// No description provided for @empStatusConfirm.
  ///
  /// In en, this message translates to:
  /// **'Change employee status?'**
  String get empStatusConfirm;

  /// No description provided for @empStatusMessage.
  ///
  /// In en, this message translates to:
  /// **'This changes active workforce status and linked account access. It can be reversed.'**
  String get empStatusMessage;

  /// No description provided for @empCreated.
  ///
  /// In en, this message translates to:
  /// **'Employee created successfully'**
  String get empCreated;

  /// No description provided for @empUpdated.
  ///
  /// In en, this message translates to:
  /// **'Employee updated successfully'**
  String get empUpdated;

  /// No description provided for @empStatusSaved.
  ///
  /// In en, this message translates to:
  /// **'Employee status updated'**
  String get empStatusSaved;

  /// No description provided for @empSave.
  ///
  /// In en, this message translates to:
  /// **'Save employee'**
  String get empSave;

  /// No description provided for @empDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get empDiscard;

  /// No description provided for @empDiscardMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Discard them and leave this form?'**
  String get empDiscardMessage;

  /// No description provided for @empDiscardAction.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get empDiscardAction;

  /// No description provided for @empRequired.
  ///
  /// In en, this message translates to:
  /// **'Complete the required fields and choose a valid joining date.'**
  String get empRequired;

  /// No description provided for @empInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get empInvalidEmail;

  /// No description provided for @empInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a phone number with 7–15 digits.'**
  String get empInvalidPhone;

  /// No description provided for @empDuplicateEmail.
  ///
  /// In en, this message translates to:
  /// **'This email is already assigned to another employee.'**
  String get empDuplicateEmail;

  /// No description provided for @empDuplicatePhone.
  ///
  /// In en, this message translates to:
  /// **'This phone is already assigned to another employee.'**
  String get empDuplicatePhone;

  /// No description provided for @empInvalidManager.
  ///
  /// In en, this message translates to:
  /// **'Choose an active manager without a circular reporting relationship.'**
  String get empInvalidManager;

  /// No description provided for @empInvalidReference.
  ///
  /// In en, this message translates to:
  /// **'Choose an active department and designation.'**
  String get empInvalidReference;

  /// No description provided for @empAccountRoleError.
  ///
  /// In en, this message translates to:
  /// **'You cannot provision this account role or its permissions.'**
  String get empAccountRoleError;

  /// No description provided for @empStorageError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t complete this local operation. Please try again.'**
  String get empStorageError;

  /// No description provided for @empPending.
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get empPending;

  /// No description provided for @empBack.
  ///
  /// In en, this message translates to:
  /// **'Back to employees'**
  String get empBack;

  /// No description provided for @empSelfProfile.
  ///
  /// In en, this message translates to:
  /// **'View employee profile'**
  String get empSelfProfile;

  /// No description provided for @empRelated.
  ///
  /// In en, this message translates to:
  /// **'Related records'**
  String get empRelated;

  /// No description provided for @empPreview.
  ///
  /// In en, this message translates to:
  /// **'Attendance preview'**
  String get empPreview;

  /// No description provided for @empSelect.
  ///
  /// In en, this message translates to:
  /// **'Select an option'**
  String get empSelect;

  /// No description provided for @empActions.
  ///
  /// In en, this message translates to:
  /// **'Employee actions'**
  String get empActions;

  /// No description provided for @empCount.
  ///
  /// In en, this message translates to:
  /// **'{filtered} of {total} employees'**
  String empCount(String filtered, String total);

  /// No description provided for @empFilterCount.
  ///
  /// In en, this message translates to:
  /// **'Filters ({count})'**
  String empFilterCount(String count);

  /// No description provided for @selectOption.
  ///
  /// In en, this message translates to:
  /// **'Select an option'**
  String get selectOption;

  /// No description provided for @noSelection.
  ///
  /// In en, this message translates to:
  /// **'Not assigned'**
  String get noSelection;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
