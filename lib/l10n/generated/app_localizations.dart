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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
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

  /// Common/Phase 0 UI: more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

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

  /// Common/Phase 0 UI: status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

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

  /// No description provided for @durationHoursOnly.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String durationHoursOnly(String hours);

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

  /// No description provided for @timeRange.
  ///
  /// In en, this message translates to:
  /// **'{start} → {end}'**
  String timeRange(String start, String end);

  /// No description provided for @dateTimeValue.
  ///
  /// In en, this message translates to:
  /// **'{date} · {time}'**
  String dateTimeValue(String date, String time);

  /// No description provided for @labeledValue.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String labeledValue(String label, String value);

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @moreFilters.
  ///
  /// In en, this message translates to:
  /// **'More filters'**
  String get moreFilters;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetFilters;

  /// No description provided for @periodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get periodLabel;

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

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your Bitlogix workspace.'**
  String get authSignInSubtitle;

  /// No description provided for @authIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Email or phone number'**
  String get authIdentifier;

  /// No description provided for @authIdentifierHint.
  ///
  /// In en, this message translates to:
  /// **'name@company.com'**
  String get authIdentifierHint;

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

  /// No description provided for @authSecureSession.
  ///
  /// In en, this message translates to:
  /// **'Your session stays secure on this device.'**
  String get authSecureSession;

  /// No description provided for @authSecureSessionLabel.
  ///
  /// In en, this message translates to:
  /// **'Secure session'**
  String get authSecureSessionLabel;

  /// No description provided for @authWorkforce.
  ///
  /// In en, this message translates to:
  /// **'Workforce'**
  String get authWorkforce;

  /// No description provided for @authActiveEmployees.
  ///
  /// In en, this message translates to:
  /// **'active employees'**
  String get authActiveEmployees;

  /// No description provided for @authWorking.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get authWorking;

  /// No description provided for @authAttendanceActive.
  ///
  /// In en, this message translates to:
  /// **'Attendance active'**
  String get authAttendanceActive;

  /// No description provided for @authLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get authLive;

  /// No description provided for @authDeveloperAccess.
  ///
  /// In en, this message translates to:
  /// **'Developer access'**
  String get authDeveloperAccess;

  /// No description provided for @productEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Modular business workspace'**
  String get productEyebrow;

  /// No description provided for @productHeadline.
  ///
  /// In en, this message translates to:
  /// **'Everything your business runs on.\nConnected.'**
  String get productHeadline;

  /// No description provided for @productWorkspaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Bitlogix Workspace'**
  String get productWorkspaceTitle;

  /// No description provided for @productWorkspaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unified business system'**
  String get productWorkspaceSubtitle;

  /// No description provided for @productWorkspaceFooter.
  ///
  /// In en, this message translates to:
  /// **'Connected by one workspace'**
  String get productWorkspaceFooter;

  /// No description provided for @modulePeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get modulePeople;

  /// No description provided for @moduleOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get moduleOperations;

  /// No description provided for @moduleOperationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Workflows'**
  String get moduleOperationsDesc;

  /// No description provided for @moduleCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get moduleCustomers;

  /// No description provided for @moduleCustomersDesc.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get moduleCustomersDesc;

  /// No description provided for @moduleFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get moduleFinance;

  /// No description provided for @moduleServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get moduleServices;

  /// No description provided for @moduleServicesDesc.
  ///
  /// In en, this message translates to:
  /// **'Service requests'**
  String get moduleServicesDesc;

  /// No description provided for @moduleInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get moduleInventory;

  /// No description provided for @moduleInventoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get moduleInventoryDesc;

  /// No description provided for @moduleReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get moduleReports;

  /// No description provided for @moduleReportsDesc.
  ///
  /// In en, this message translates to:
  /// **'Scheduled exports'**
  String get moduleReportsDesc;

  /// No description provided for @moduleInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get moduleInsights;

  /// No description provided for @moduleInsightsDesc.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get moduleInsightsDesc;

  /// No description provided for @authWorkdayTitle.
  ///
  /// In en, this message translates to:
  /// **'Your workday,\nall in one place.'**
  String get authWorkdayTitle;

  /// No description provided for @authWorkingDay.
  ///
  /// In en, this message translates to:
  /// **'Working day'**
  String get authWorkingDay;

  /// No description provided for @authNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get authNow;

  /// No description provided for @authShiftGeneral.
  ///
  /// In en, this message translates to:
  /// **'General shift'**
  String get authShiftGeneral;

  /// No description provided for @authShiftToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get authShiftToday;

  /// No description provided for @authWorkLocationMain.
  ///
  /// In en, this message translates to:
  /// **'Main office'**
  String get authWorkLocationMain;

  /// No description provided for @authEmployeesActiveCount.
  ///
  /// In en, this message translates to:
  /// **'{count} employees active'**
  String authEmployeesActiveCount(int count);

  /// No description provided for @authDemoUse.
  ///
  /// In en, this message translates to:
  /// **'Use a demo account'**
  String get authDemoUse;

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

  /// No description provided for @shellProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Your account, preferences and attendance settings.'**
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

  /// No description provided for @syncOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get syncOfflineTitle;

  /// No description provided for @syncOfflineMessage.
  ///
  /// In en, this message translates to:
  /// **'Changes will sync when your connection returns.'**
  String get syncOfflineMessage;

  /// No description provided for @syncServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service temporarily unavailable'**
  String get syncServiceUnavailable;

  /// No description provided for @syncSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get syncSyncing;

  /// No description provided for @syncAllChangesSynced.
  ///
  /// In en, this message translates to:
  /// **'All changes synced'**
  String get syncAllChangesSynced;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get syncPending;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @syncNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Sync needs attention'**
  String get syncNeedsAttention;

  /// No description provided for @syncRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get syncRetry;

  /// No description provided for @syncRetryNow.
  ///
  /// In en, this message translates to:
  /// **'Retry now'**
  String get syncRetryNow;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncLastSync.
  ///
  /// In en, this message translates to:
  /// **'Last sync'**
  String get syncLastSync;

  /// No description provided for @syncNever.
  ///
  /// In en, this message translates to:
  /// **'Not yet synced'**
  String get syncNever;

  /// No description provided for @syncChangesWaiting.
  ///
  /// In en, this message translates to:
  /// **'Changes waiting to sync'**
  String get syncChangesWaiting;

  /// No description provided for @syncDataAndSync.
  ///
  /// In en, this message translates to:
  /// **'Data and sync'**
  String get syncDataAndSync;

  /// No description provided for @syncNoPendingChanges.
  ///
  /// In en, this message translates to:
  /// **'No changes waiting'**
  String get syncNoPendingChanges;

  /// No description provided for @syncSyncSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Sync complete'**
  String get syncSyncSucceeded;

  /// No description provided for @syncStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync status'**
  String get syncStatusTitle;

  /// No description provided for @syncPendingOperations.
  ///
  /// In en, this message translates to:
  /// **'Pending operations'**
  String get syncPendingOperations;

  /// No description provided for @syncFailedOperations.
  ///
  /// In en, this message translates to:
  /// **'Failed operations'**
  String get syncFailedOperations;

  /// No description provided for @syncSwitchAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync'**
  String get syncSwitchAccount;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsNoItems.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notificationsNoItems;

  /// No description provided for @notificationsNoItemsMessage.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up.'**
  String get notificationsNoItemsMessage;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notificationsToday;

  /// No description provided for @notificationsEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notificationsEarlier;

  /// No description provided for @notificationsUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get notificationsUnread;

  /// No description provided for @notificationsReminders.
  ///
  /// In en, this message translates to:
  /// **'Notifications and reminders'**
  String get notificationsReminders;

  /// No description provided for @notificationsOpen.
  ///
  /// In en, this message translates to:
  /// **'Open notifications'**
  String get notificationsOpen;

  /// No description provided for @reminderAttendanceSection.
  ///
  /// In en, this message translates to:
  /// **'Attendance reminders'**
  String get reminderAttendanceSection;

  /// No description provided for @reminderShift.
  ///
  /// In en, this message translates to:
  /// **'Shift reminder'**
  String get reminderShift;

  /// No description provided for @reminderPunchOut.
  ///
  /// In en, this message translates to:
  /// **'Punch out reminder'**
  String get reminderPunchOut;

  /// No description provided for @reminderNotifyBefore.
  ///
  /// In en, this message translates to:
  /// **'Notify before shift'**
  String get reminderNotifyBefore;

  /// No description provided for @reminderMinutesBefore.
  ///
  /// In en, this message translates to:
  /// **'Minutes before'**
  String get reminderMinutesBefore;

  /// No description provided for @reminderNotificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Notification permission'**
  String get reminderNotificationPermission;

  /// No description provided for @reminderPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification permission required'**
  String get reminderPermissionRequired;

  /// No description provided for @reminderNotificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get reminderNotificationsDisabled;

  /// No description provided for @reminderNotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Reminders enabled in the app'**
  String get reminderNotificationsEnabled;

  /// No description provided for @reminderOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get reminderOpenSettings;

  /// No description provided for @reminderSaved.
  ///
  /// In en, this message translates to:
  /// **'Reminder settings saved'**
  String get reminderSaved;

  /// No description provided for @reminderSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save reminder settings'**
  String get reminderSaveFailed;

  /// No description provided for @reminderPermissionHint.
  ///
  /// In en, this message translates to:
  /// **'Enable reminders to receive shift notifications.'**
  String get reminderPermissionHint;

  /// No description provided for @notifShiftSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Your shift starts soon'**
  String get notifShiftSoonTitle;

  /// No description provided for @notifShiftSoonBody.
  ///
  /// In en, this message translates to:
  /// **'Your shift is about to start. Open attendance to check in.'**
  String get notifShiftSoonBody;

  /// No description provided for @notifPunchOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Remember to punch out'**
  String get notifPunchOutTitle;

  /// No description provided for @notifPunchOutBody.
  ///
  /// In en, this message translates to:
  /// **'Your shift has ended. Remember to punch out.'**
  String get notifPunchOutBody;

  /// No description provided for @notifShiftEndingOnBreakBody.
  ///
  /// In en, this message translates to:
  /// **'Your shift is ending. Review your attendance before leaving.'**
  String get notifShiftEndingOnBreakBody;

  /// No description provided for @notifCorrectionApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance correction approved'**
  String get notifCorrectionApprovedTitle;

  /// No description provided for @notifCorrectionApprovedBody.
  ///
  /// In en, this message translates to:
  /// **'Your attendance correction was approved and applied.'**
  String get notifCorrectionApprovedBody;

  /// No description provided for @notifCorrectionRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance correction rejected'**
  String get notifCorrectionRejectedTitle;

  /// No description provided for @notifCorrectionRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Your attendance correction request was not approved.'**
  String get notifCorrectionRejectedBody;

  /// No description provided for @notifSyncFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance needs attention'**
  String get notifSyncFailedTitle;

  /// No description provided for @notifSyncFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Some attendance changes could not be synced.'**
  String get notifSyncFailedBody;

  /// No description provided for @notifConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance needs review'**
  String get notifConflictTitle;

  /// No description provided for @notifConflictBody.
  ///
  /// In en, this message translates to:
  /// **'Your local attendance does not match the latest server record.'**
  String get notifConflictBody;

  /// No description provided for @notifPendingReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'New attendance correction request'**
  String get notifPendingReviewTitle;

  /// No description provided for @notifPendingReviewBody.
  ///
  /// In en, this message translates to:
  /// **'A correction request is waiting for review.'**
  String get notifPendingReviewBody;

  /// No description provided for @notifLeaveSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave request submitted'**
  String get notifLeaveSubmittedTitle;

  /// No description provided for @notifLeaveSubmittedBody.
  ///
  /// In en, this message translates to:
  /// **'Your leave request was submitted for approval.'**
  String get notifLeaveSubmittedBody;

  /// No description provided for @notifLeaveApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave request approved'**
  String get notifLeaveApprovedTitle;

  /// No description provided for @notifLeaveApprovedBody.
  ///
  /// In en, this message translates to:
  /// **'Your leave request was approved.'**
  String get notifLeaveApprovedBody;

  /// No description provided for @notifLeaveRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave request rejected'**
  String get notifLeaveRejectedTitle;

  /// No description provided for @notifLeaveRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Your leave request was not approved.'**
  String get notifLeaveRejectedBody;

  /// No description provided for @notifLeaveCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave request cancelled'**
  String get notifLeaveCancelledTitle;

  /// No description provided for @notifLeaveCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'A leave request was cancelled.'**
  String get notifLeaveCancelledBody;

  /// No description provided for @notifLeaveApprovalRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave approval required'**
  String get notifLeaveApprovalRequiredTitle;

  /// No description provided for @notifLeaveApprovalRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'A team leave request is waiting for your review.'**
  String get notifLeaveApprovalRequiredBody;

  /// No description provided for @notifUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notifUnknownTitle;

  /// No description provided for @notifUnknownBody.
  ///
  /// In en, this message translates to:
  /// **'You have a new notification.'**
  String get notifUnknownBody;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String timeMinutesAgo(Object count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String timeHoursAgo(Object count);

  /// No description provided for @timeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get timeYesterday;

  /// No description provided for @profileMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get profileMyProfile;

  /// No description provided for @profileOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get profileOverview;

  /// No description provided for @profileWorkInformation.
  ///
  /// In en, this message translates to:
  /// **'Work information'**
  String get profileWorkInformation;

  /// No description provided for @profileAccountAccess.
  ///
  /// In en, this message translates to:
  /// **'Account and access'**
  String get profileAccountAccess;

  /// No description provided for @profileSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get profileSecurity;

  /// No description provided for @profilePreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profilePreferences;

  /// No description provided for @profileAccess.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get profileAccess;

  /// No description provided for @profileAdministrativeAccess.
  ///
  /// In en, this message translates to:
  /// **'Administrative access'**
  String get profileAdministrativeAccess;

  /// No description provided for @profileRoles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get profileRoles;

  /// No description provided for @profileEmploymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Employment status'**
  String get profileEmploymentStatus;

  /// No description provided for @profileLoginEmail.
  ///
  /// In en, this message translates to:
  /// **'Login email'**
  String get profileLoginEmail;

  /// No description provided for @profileWorkEmail.
  ///
  /// In en, this message translates to:
  /// **'Work email'**
  String get profileWorkEmail;

  /// No description provided for @profileMyAttendance.
  ///
  /// In en, this message translates to:
  /// **'My attendance'**
  String get profileMyAttendance;

  /// No description provided for @profileViewEmployeeRecord.
  ///
  /// In en, this message translates to:
  /// **'View employment details'**
  String get profileViewEmployeeRecord;

  /// No description provided for @profileNoEmployeeLinked.
  ///
  /// In en, this message translates to:
  /// **'No employee profile is linked to this account.'**
  String get profileNoEmployeeLinked;

  /// No description provided for @profileTeamUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Team access cannot be resolved.'**
  String get profileTeamUnavailable;

  /// No description provided for @profileEmploymentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Employment information is currently unavailable.'**
  String get profileEmploymentUnavailable;

  /// No description provided for @profileCurrentCompany.
  ///
  /// In en, this message translates to:
  /// **'Current company'**
  String get profileCurrentCompany;

  /// No description provided for @profileManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get profileManage;

  /// No description provided for @settingsIntro.
  ///
  /// In en, this message translates to:
  /// **'Manage your organization, attendance configuration and preferences.'**
  String get settingsIntro;

  /// No description provided for @settingsAttendanceCategory.
  ///
  /// In en, this message translates to:
  /// **'Attendance configuration'**
  String get settingsAttendanceCategory;

  /// No description provided for @settingsAttendanceCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure how employees work and record attendance.'**
  String get settingsAttendanceCategoryDesc;

  /// No description provided for @settingsPreferencesCategory.
  ///
  /// In en, this message translates to:
  /// **'Personal preferences'**
  String get settingsPreferencesCategory;

  /// No description provided for @settingsPreferencesCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Adjust your own app preferences.'**
  String get settingsPreferencesCategoryDesc;

  /// No description provided for @settingsSystemCategory.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsSystemCategory;

  /// No description provided for @settingsSystemCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Sync and application status.'**
  String get settingsSystemCategoryDesc;

  /// No description provided for @settingsShiftDesc.
  ///
  /// In en, this message translates to:
  /// **'Set working hours, working days and break defaults.'**
  String get settingsShiftDesc;

  /// No description provided for @settingsLocationDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage workplaces and attendance location rules.'**
  String get settingsLocationDesc;

  /// No description provided for @settingsPolicyDesc.
  ///
  /// In en, this message translates to:
  /// **'Define attendance, break and correction rules.'**
  String get settingsPolicyDesc;

  /// No description provided for @settingsLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred application language.'**
  String get settingsLanguageDesc;

  /// No description provided for @settingsNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Control attendance reminders for your account.'**
  String get settingsNotificationsDesc;

  /// No description provided for @settingsSyncDesc.
  ///
  /// In en, this message translates to:
  /// **'View sync status and retry failed changes.'**
  String get settingsSyncDesc;

  /// No description provided for @shellLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get shellLeave;

  /// No description provided for @settingsLeaveCategory.
  ///
  /// In en, this message translates to:
  /// **'Leave & holidays'**
  String get settingsLeaveCategory;

  /// No description provided for @settingsLeaveCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure leave types, policies and holidays.'**
  String get settingsLeaveCategoryDesc;

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

  /// No description provided for @permissionAttendanceReportView.
  ///
  /// In en, this message translates to:
  /// **'View attendance reports'**
  String get permissionAttendanceReportView;

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
  /// **'Your workday at a glance'**
  String get dashboardSelfContext;

  /// No description provided for @dashboardNoShiftTitle.
  ///
  /// In en, this message translates to:
  /// **'Work schedule not configured'**
  String get dashboardNoShiftTitle;

  /// No description provided for @dashboardNoShiftMessage.
  ///
  /// In en, this message translates to:
  /// **'No shift has been assigned to your employee profile yet. Contact HR to complete your attendance setup.'**
  String get dashboardNoShiftMessage;

  /// No description provided for @dashboardThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get dashboardThisWeek;

  /// No description provided for @dashboardRecentAttendance.
  ///
  /// In en, this message translates to:
  /// **'Recent attendance'**
  String get dashboardRecentAttendance;

  /// No description provided for @dashboardViewFullHistory.
  ///
  /// In en, this message translates to:
  /// **'View full history'**
  String get dashboardViewFullHistory;

  /// No description provided for @dashboardNoRecentAttendance.
  ///
  /// In en, this message translates to:
  /// **'No previous attendance yet.'**
  String get dashboardNoRecentAttendance;

  /// No description provided for @dashboardNoRecentAttendanceMessage.
  ///
  /// In en, this message translates to:
  /// **'Your completed workdays will appear here.'**
  String get dashboardNoRecentAttendanceMessage;

  /// No description provided for @dashboardNoWeek.
  ///
  /// In en, this message translates to:
  /// **'No attendance recorded this week.'**
  String get dashboardNoWeek;

  /// No description provided for @dashboardWeekOff.
  ///
  /// In en, this message translates to:
  /// **'Week off'**
  String get dashboardWeekOff;

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

  /// No description provided for @dashboardLateAlertDetail.
  ///
  /// In en, this message translates to:
  /// **'Review attendance'**
  String get dashboardLateAlertDetail;

  /// No description provided for @dashboardCorrectionsAlertDetail.
  ///
  /// In en, this message translates to:
  /// **'Awaiting review'**
  String get dashboardCorrectionsAlertDetail;

  /// No description provided for @dashboardSelfCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get dashboardSelfCheckedIn;

  /// No description provided for @dashboardSelfBreakStarted.
  ///
  /// In en, this message translates to:
  /// **'Started a break'**
  String get dashboardSelfBreakStarted;

  /// No description provided for @dashboardSelfCorrectionSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted a correction'**
  String get dashboardSelfCorrectionSubmitted;

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

  /// No description provided for @cfgConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get cfgConfiguration;

  /// No description provided for @cfgShifts.
  ///
  /// In en, this message translates to:
  /// **'Shifts'**
  String get cfgShifts;

  /// No description provided for @cfgShift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get cfgShift;

  /// No description provided for @cfgPolicy.
  ///
  /// In en, this message translates to:
  /// **'Attendance policy'**
  String get cfgPolicy;

  /// No description provided for @cfgLocations.
  ///
  /// In en, this message translates to:
  /// **'Work locations'**
  String get cfgLocations;

  /// No description provided for @cfgPolicies.
  ///
  /// In en, this message translates to:
  /// **'Attendance policies'**
  String get cfgPolicies;

  /// No description provided for @cfgIntro.
  ///
  /// In en, this message translates to:
  /// **'Define when, where, and under which rules employees work.'**
  String get cfgIntro;

  /// No description provided for @cfgShiftIntro.
  ///
  /// In en, this message translates to:
  /// **'Working hours, weekdays, and planned breaks.'**
  String get cfgShiftIntro;

  /// No description provided for @cfgLocationIntro.
  ///
  /// In en, this message translates to:
  /// **'Work addresses and location validation settings.'**
  String get cfgLocationIntro;

  /// No description provided for @cfgPolicyIntro.
  ///
  /// In en, this message translates to:
  /// **'Rules prepared for future attendance workflows.'**
  String get cfgPolicyIntro;

  /// No description provided for @cfgNew.
  ///
  /// In en, this message translates to:
  /// **'Create record'**
  String get cfgNew;

  /// No description provided for @cfgEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit record'**
  String get cfgEdit;

  /// No description provided for @cfgSaved.
  ///
  /// In en, this message translates to:
  /// **'Configuration saved locally.'**
  String get cfgSaved;

  /// No description provided for @cfgStatusSaved.
  ///
  /// In en, this message translates to:
  /// **'Status updated locally.'**
  String get cfgStatusSaved;

  /// No description provided for @cfgName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get cfgName;

  /// No description provided for @cfgCode.
  ///
  /// In en, this message translates to:
  /// **'Code (optional)'**
  String get cfgCode;

  /// No description provided for @cfgDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get cfgDescription;

  /// No description provided for @cfgAll.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get cfgAll;

  /// No description provided for @cfgActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get cfgActive;

  /// No description provided for @cfgInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get cfgInactive;

  /// No description provided for @cfgActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get cfgActivate;

  /// No description provided for @cfgDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get cfgDeactivate;

  /// No description provided for @cfgStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get cfgStatus;

  /// No description provided for @cfgAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned employees'**
  String get cfgAssigned;

  /// No description provided for @cfgDeactivateMessage.
  ///
  /// In en, this message translates to:
  /// **'Existing assignments are retained. This record will no longer be available for new assignments.'**
  String get cfgDeactivateMessage;

  /// No description provided for @cfgActivateMessage.
  ///
  /// In en, this message translates to:
  /// **'Make this record available for new employee assignments.'**
  String get cfgActivateMessage;

  /// No description provided for @cfgEmpty.
  ///
  /// In en, this message translates to:
  /// **'No configuration records yet'**
  String get cfgEmpty;

  /// No description provided for @cfgEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a record to prepare employee attendance assignments.'**
  String get cfgEmptyMessage;

  /// No description provided for @cfgNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching records'**
  String get cfgNoResults;

  /// No description provided for @cfgNoResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try another search or status filter.'**
  String get cfgNoResultsMessage;

  /// No description provided for @cfgNotFound.
  ///
  /// In en, this message translates to:
  /// **'Record not found'**
  String get cfgNotFound;

  /// No description provided for @cfgNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This record is unavailable in the current company.'**
  String get cfgNotFoundMessage;

  /// No description provided for @cfgRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get cfgRequired;

  /// No description provided for @cfgDuplicateName.
  ///
  /// In en, this message translates to:
  /// **'An active record with this name already exists.'**
  String get cfgDuplicateName;

  /// No description provided for @cfgInvalidTime.
  ///
  /// In en, this message translates to:
  /// **'Choose different valid start and end times.'**
  String get cfgInvalidTime;

  /// No description provided for @cfgWorkingDaysError.
  ///
  /// In en, this message translates to:
  /// **'Select at least one working day.'**
  String get cfgWorkingDaysError;

  /// No description provided for @cfgInvalidGrace.
  ///
  /// In en, this message translates to:
  /// **'Grace must be non-negative and shorter than the shift.'**
  String get cfgInvalidGrace;

  /// No description provided for @cfgInvalidBreak.
  ///
  /// In en, this message translates to:
  /// **'Fixed break must be shorter than the shift.'**
  String get cfgInvalidBreak;

  /// No description provided for @cfgInvalidMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum work must fit within expected working time.'**
  String get cfgInvalidMinimum;

  /// No description provided for @cfgInvalidCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Enter coordinates within valid latitude and longitude ranges.'**
  String get cfgInvalidCoordinates;

  /// No description provided for @cfgInvalidRadius.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive, finite radius.'**
  String get cfgInvalidRadius;

  /// No description provided for @cfgInvalidAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive, finite accuracy limit.'**
  String get cfgInvalidAccuracy;

  /// No description provided for @cfgCountryError.
  ///
  /// In en, this message translates to:
  /// **'Enter a two-letter country code.'**
  String get cfgCountryError;

  /// No description provided for @cfgPolicyError.
  ///
  /// In en, this message translates to:
  /// **'Require location for at least one attendance event.'**
  String get cfgPolicyError;

  /// No description provided for @cfgEarlyError.
  ///
  /// In en, this message translates to:
  /// **'Enter an early arrival limit from 0 to 1440 minutes.'**
  String get cfgEarlyError;

  /// No description provided for @cfgAssignmentError.
  ///
  /// In en, this message translates to:
  /// **'Choose an active record from the current company.'**
  String get cfgAssignmentError;

  /// No description provided for @cfgStorageError.
  ///
  /// In en, this message translates to:
  /// **'Unable to read or save local configuration. Please retry.'**
  String get cfgStorageError;

  /// No description provided for @cfgStart.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get cfgStart;

  /// No description provided for @cfgEnd.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get cfgEnd;

  /// No description provided for @cfgDays.
  ///
  /// In en, this message translates to:
  /// **'Working days'**
  String get cfgDays;

  /// No description provided for @cfgGrace.
  ///
  /// In en, this message translates to:
  /// **'Grace period'**
  String get cfgGrace;

  /// No description provided for @cfgBreakMode.
  ///
  /// In en, this message translates to:
  /// **'Break mode'**
  String get cfgBreakMode;

  /// No description provided for @cfgManualBreak.
  ///
  /// In en, this message translates to:
  /// **'Manual breaks'**
  String get cfgManualBreak;

  /// No description provided for @cfgFixedBreak.
  ///
  /// In en, this message translates to:
  /// **'Fixed planned break'**
  String get cfgFixedBreak;

  /// No description provided for @cfgNoBreak.
  ///
  /// In en, this message translates to:
  /// **'No breaks'**
  String get cfgNoBreak;

  /// No description provided for @cfgBreakMinutes.
  ///
  /// In en, this message translates to:
  /// **'Planned break duration'**
  String get cfgBreakMinutes;

  /// No description provided for @cfgMinimumWork.
  ///
  /// In en, this message translates to:
  /// **'Minimum work duration (optional)'**
  String get cfgMinimumWork;

  /// No description provided for @cfgDuration.
  ///
  /// In en, this message translates to:
  /// **'Shift duration'**
  String get cfgDuration;

  /// No description provided for @cfgExpectedWork.
  ///
  /// In en, this message translates to:
  /// **'Expected working time'**
  String get cfgExpectedWork;

  /// No description provided for @cfgOvernight.
  ///
  /// In en, this message translates to:
  /// **'Overnight shift'**
  String get cfgOvernight;

  /// No description provided for @cfgSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get cfgSchedule;

  /// No description provided for @cfgMinutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get cfgMinutes;

  /// No description provided for @cfgMeters.
  ///
  /// In en, this message translates to:
  /// **'meters'**
  String get cfgMeters;

  /// No description provided for @cfgAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get cfgAddress;

  /// No description provided for @cfgAddress1.
  ///
  /// In en, this message translates to:
  /// **'Address line 1'**
  String get cfgAddress1;

  /// No description provided for @cfgAddress2.
  ///
  /// In en, this message translates to:
  /// **'Address line 2 (optional)'**
  String get cfgAddress2;

  /// No description provided for @cfgCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cfgCity;

  /// No description provided for @cfgState.
  ///
  /// In en, this message translates to:
  /// **'State / region'**
  String get cfgState;

  /// No description provided for @cfgPostal.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get cfgPostal;

  /// No description provided for @cfgCountry.
  ///
  /// In en, this message translates to:
  /// **'Country code'**
  String get cfgCountry;

  /// No description provided for @cfgLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get cfgLatitude;

  /// No description provided for @cfgLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get cfgLongitude;

  /// No description provided for @cfgRadius.
  ///
  /// In en, this message translates to:
  /// **'Allowed radius'**
  String get cfgRadius;

  /// No description provided for @cfgAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Maximum accepted accuracy'**
  String get cfgAccuracy;

  /// No description provided for @cfgValidationMode.
  ///
  /// In en, this message translates to:
  /// **'Location validation'**
  String get cfgValidationMode;

  /// No description provided for @cfgGeofenceRequired.
  ///
  /// In en, this message translates to:
  /// **'Geofence required'**
  String get cfgGeofenceRequired;

  /// No description provided for @cfgGeofencePreferred.
  ///
  /// In en, this message translates to:
  /// **'Geofence preferred'**
  String get cfgGeofencePreferred;

  /// No description provided for @cfgCaptureOnly.
  ///
  /// In en, this message translates to:
  /// **'Capture location only'**
  String get cfgCaptureOnly;

  /// No description provided for @cfgNoLocation.
  ///
  /// In en, this message translates to:
  /// **'No location validation'**
  String get cfgNoLocation;

  /// No description provided for @cfgPreview.
  ///
  /// In en, this message translates to:
  /// **'Location preview'**
  String get cfgPreview;

  /// No description provided for @cfgPreviewNote.
  ///
  /// In en, this message translates to:
  /// **'Coordinates and radius preview. A map provider can be added later.'**
  String get cfgPreviewNote;

  /// No description provided for @cfgCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get cfgCurrentLocation;

  /// No description provided for @cfgLocating.
  ///
  /// In en, this message translates to:
  /// **'Finding location…'**
  String get cfgLocating;

  /// No description provided for @cfgOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get cfgOpenSettings;

  /// No description provided for @cfgLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. You can enter coordinates manually.'**
  String get cfgLocationDenied;

  /// No description provided for @cfgLocationPermanent.
  ///
  /// In en, this message translates to:
  /// **'Location permission is blocked. Enable it in app settings.'**
  String get cfgLocationPermanent;

  /// No description provided for @cfgLocationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are off. Enable them in device settings.'**
  String get cfgLocationDisabled;

  /// No description provided for @cfgLocationTimeout.
  ///
  /// In en, this message translates to:
  /// **'Location request timed out. Retry or enter coordinates manually.'**
  String get cfgLocationTimeout;

  /// No description provided for @cfgLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Current location is unavailable. You can enter coordinates manually.'**
  String get cfgLocationUnavailable;

  /// No description provided for @cfgPoorAccuracy.
  ///
  /// In en, this message translates to:
  /// **'The captured position has poor accuracy. Review these coordinates before saving.'**
  String get cfgPoorAccuracy;

  /// No description provided for @cfgCapturedAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Captured accuracy'**
  String get cfgCapturedAccuracy;

  /// No description provided for @cfgLocationRules.
  ///
  /// In en, this message translates to:
  /// **'Location rules'**
  String get cfgLocationRules;

  /// No description provided for @cfgBreakRules.
  ///
  /// In en, this message translates to:
  /// **'Break rules'**
  String get cfgBreakRules;

  /// No description provided for @cfgTimingRules.
  ///
  /// In en, this message translates to:
  /// **'Timing rules'**
  String get cfgTimingRules;

  /// No description provided for @cfgOfflineRules.
  ///
  /// In en, this message translates to:
  /// **'Offline behavior'**
  String get cfgOfflineRules;

  /// No description provided for @cfgGeneralRules.
  ///
  /// In en, this message translates to:
  /// **'General rules'**
  String get cfgGeneralRules;

  /// No description provided for @cfgRequireLocation.
  ///
  /// In en, this message translates to:
  /// **'Require location'**
  String get cfgRequireLocation;

  /// No description provided for @cfgOutside.
  ///
  /// In en, this message translates to:
  /// **'Allow attendance outside the assigned location'**
  String get cfgOutside;

  /// No description provided for @cfgRemote.
  ///
  /// In en, this message translates to:
  /// **'Allow remote attendance'**
  String get cfgRemote;

  /// No description provided for @cfgLocationIn.
  ///
  /// In en, this message translates to:
  /// **'Require location on punch in'**
  String get cfgLocationIn;

  /// No description provided for @cfgLocationOut.
  ///
  /// In en, this message translates to:
  /// **'Require location on punch out'**
  String get cfgLocationOut;

  /// No description provided for @cfgLocationBreak.
  ///
  /// In en, this message translates to:
  /// **'Require location for breaks'**
  String get cfgLocationBreak;

  /// No description provided for @cfgRequireAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Require acceptable location accuracy'**
  String get cfgRequireAccuracy;

  /// No description provided for @cfgTrackBreaks.
  ///
  /// In en, this message translates to:
  /// **'Track breaks'**
  String get cfgTrackBreaks;

  /// No description provided for @cfgMultipleBreaks.
  ///
  /// In en, this message translates to:
  /// **'Allow multiple breaks'**
  String get cfgMultipleBreaks;

  /// No description provided for @cfgOutDuringBreak.
  ///
  /// In en, this message translates to:
  /// **'Allow punch out during a break'**
  String get cfgOutDuringBreak;

  /// No description provided for @cfgCorrections.
  ///
  /// In en, this message translates to:
  /// **'Allow employee correction requests'**
  String get cfgCorrections;

  /// No description provided for @cfgEarlyIn.
  ///
  /// In en, this message translates to:
  /// **'Allow early punch in'**
  String get cfgEarlyIn;

  /// No description provided for @cfgEarlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Early arrival limit'**
  String get cfgEarlyLimit;

  /// No description provided for @cfgLateIn.
  ///
  /// In en, this message translates to:
  /// **'Allow late punch in'**
  String get cfgLateIn;

  /// No description provided for @cfgEarlyOut.
  ///
  /// In en, this message translates to:
  /// **'Allow early punch out'**
  String get cfgEarlyOut;

  /// No description provided for @cfgOfflineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline attendance mode'**
  String get cfgOfflineMode;

  /// No description provided for @cfgOfflineNo.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get cfgOfflineNo;

  /// No description provided for @cfgOfflinePending.
  ///
  /// In en, this message translates to:
  /// **'Allow pending validation'**
  String get cfgOfflinePending;

  /// No description provided for @cfgOfflineWarning.
  ///
  /// In en, this message translates to:
  /// **'Allow with a warning'**
  String get cfgOfflineWarning;

  /// No description provided for @cfgYes.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get cfgYes;

  /// No description provided for @cfgNo.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get cfgNo;

  /// No description provided for @cfgFoundationNote.
  ///
  /// In en, this message translates to:
  /// **'Configuration only. Attendance actions and rule evaluation will be implemented in Phase 6.'**
  String get cfgFoundationNote;

  /// No description provided for @cfgInactiveAssignment.
  ///
  /// In en, this message translates to:
  /// **'Inactive • current assignment retained'**
  String get cfgInactiveAssignment;

  /// No description provided for @cfgMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get cfgMon;

  /// No description provided for @cfgTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get cfgTue;

  /// No description provided for @cfgWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get cfgWed;

  /// No description provided for @cfgThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get cfgThu;

  /// No description provided for @cfgFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get cfgFri;

  /// No description provided for @cfgSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get cfgSat;

  /// No description provided for @cfgSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get cfgSun;

  /// No description provided for @cfgActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get cfgActions;

  /// No description provided for @cfgValidation.
  ///
  /// In en, this message translates to:
  /// **'Review the highlighted fields before saving.'**
  String get cfgValidation;

  /// No description provided for @cfgPending.
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get cfgPending;

  /// No description provided for @cfgView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get cfgView;

  /// No description provided for @cfgKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get cfgKeepEditing;

  /// No description provided for @cfgDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get cfgDiscard;

  /// No description provided for @cfgDiscardMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Discard them and leave this form?'**
  String get cfgDiscardMessage;

  /// No description provided for @cfgDiscardAction.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get cfgDiscardAction;

  /// No description provided for @attendanceNotLinkedToEmployee.
  ///
  /// In en, this message translates to:
  /// **'No employee profile is linked to this account'**
  String get attendanceNotLinkedToEmployee;

  /// No description provided for @attendanceEmployeeInactive.
  ///
  /// In en, this message translates to:
  /// **'Employee account is inactive'**
  String get attendanceEmployeeInactive;

  /// No description provided for @attendanceAccountInactive.
  ///
  /// In en, this message translates to:
  /// **'Your account is inactive or your session has ended'**
  String get attendanceAccountInactive;

  /// No description provided for @attendancePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this attendance action'**
  String get attendancePermissionDenied;

  /// No description provided for @attendanceShiftNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'No shift is assigned'**
  String get attendanceShiftNotAssigned;

  /// No description provided for @attendancePolicyNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'No attendance policy is assigned'**
  String get attendancePolicyNotAssigned;

  /// No description provided for @attendanceWorkLocationRequiredButMissing.
  ///
  /// In en, this message translates to:
  /// **'No work location is assigned'**
  String get attendanceWorkLocationRequiredButMissing;

  /// No description provided for @attendanceLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location is required'**
  String get attendanceLocationRequired;

  /// No description provided for @attendanceLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Your location is unavailable'**
  String get attendanceLocationUnavailable;

  /// No description provided for @attendanceLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required'**
  String get attendanceLocationPermissionDenied;

  /// No description provided for @attendanceLocationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled'**
  String get attendanceLocationServicesDisabled;

  /// No description provided for @attendanceLocationAccuracyTooLow.
  ///
  /// In en, this message translates to:
  /// **'Location accuracy is too low'**
  String get attendanceLocationAccuracyTooLow;

  /// No description provided for @attendanceOutsideAllowedLocation.
  ///
  /// In en, this message translates to:
  /// **'You are outside the allowed work location'**
  String get attendanceOutsideAllowedLocation;

  /// No description provided for @attendanceAlreadyPunchedIn.
  ///
  /// In en, this message translates to:
  /// **'You have already punched in'**
  String get attendanceAlreadyPunchedIn;

  /// No description provided for @attendanceNotPunchedIn.
  ///
  /// In en, this message translates to:
  /// **'Not punched in'**
  String get attendanceNotPunchedIn;

  /// No description provided for @attendanceAlreadyOnBreak.
  ///
  /// In en, this message translates to:
  /// **'You are already on a break'**
  String get attendanceAlreadyOnBreak;

  /// No description provided for @attendanceNotOnBreak.
  ///
  /// In en, this message translates to:
  /// **'No active break was found'**
  String get attendanceNotOnBreak;

  /// No description provided for @attendanceBreakTrackingDisabled.
  ///
  /// In en, this message translates to:
  /// **'Break tracking is disabled'**
  String get attendanceBreakTrackingDisabled;

  /// No description provided for @attendanceMultipleBreaksNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Multiple breaks are not allowed'**
  String get attendanceMultipleBreaksNotAllowed;

  /// No description provided for @attendancePunchOutDuringBreakNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Punch out is not allowed during a break'**
  String get attendancePunchOutDuringBreakNotAllowed;

  /// No description provided for @attendanceAlreadyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Your workday is already complete'**
  String get attendanceAlreadyCompleted;

  /// No description provided for @attendanceTooEarlyToPunchIn.
  ///
  /// In en, this message translates to:
  /// **'You are too early to punch in'**
  String get attendanceTooEarlyToPunchIn;

  /// No description provided for @attendanceLatePunchInNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Late punch in is not allowed'**
  String get attendanceLatePunchInNotAllowed;

  /// No description provided for @attendanceEarlyPunchOutNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Early punch out is not allowed'**
  String get attendanceEarlyPunchOutNotAllowed;

  /// No description provided for @attendanceUnscheduledDay.
  ///
  /// In en, this message translates to:
  /// **'This is not a scheduled working day'**
  String get attendanceUnscheduledDay;

  /// No description provided for @attendanceOfflineAttendanceNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Offline attendance is not allowed'**
  String get attendanceOfflineAttendanceNotAllowed;

  /// No description provided for @attendanceInvalidAttendanceState.
  ///
  /// In en, this message translates to:
  /// **'The attendance timeline is inconsistent'**
  String get attendanceInvalidAttendanceState;

  /// No description provided for @attendancePersistenceFailure.
  ///
  /// In en, this message translates to:
  /// **'Attendance could not be saved. Please retry'**
  String get attendancePersistenceFailure;

  /// No description provided for @attendanceInvalidLocationEvidence.
  ///
  /// In en, this message translates to:
  /// **'Location evidence is invalid'**
  String get attendanceInvalidLocationEvidence;

  /// No description provided for @attendanceStaleLocationEvidence.
  ///
  /// In en, this message translates to:
  /// **'Please capture your location again'**
  String get attendanceStaleLocationEvidence;

  /// No description provided for @attendanceRemoteAttendanceNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Remote attendance is not allowed'**
  String get attendanceRemoteAttendanceNotAllowed;

  /// No description provided for @attendanceInvalidTimestamp.
  ///
  /// In en, this message translates to:
  /// **'The attendance timestamp is invalid'**
  String get attendanceInvalidTimestamp;

  /// No description provided for @attendanceDuplicateRequestId.
  ///
  /// In en, this message translates to:
  /// **'This attendance request has already been submitted'**
  String get attendanceDuplicateRequestId;

  /// No description provided for @attendanceOperationNotFound.
  ///
  /// In en, this message translates to:
  /// **'The attendance operation was not found'**
  String get attendanceOperationNotFound;

  /// No description provided for @attendanceSyncUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Attendance sync is not configured'**
  String get attendanceSyncUnavailable;

  /// No description provided for @attendanceSynchronizationFailed.
  ///
  /// In en, this message translates to:
  /// **'Attendance synchronization failed'**
  String get attendanceSynchronizationFailed;

  /// No description provided for @attendanceUnsupportedTimezone.
  ///
  /// In en, this message translates to:
  /// **'The company timezone is not supported yet'**
  String get attendanceUnsupportedTimezone;

  /// No description provided for @attendanceCompanyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Attendance is unavailable for this company'**
  String get attendanceCompanyUnavailable;

  /// No description provided for @attendanceWarningOutsideAllowedLocation.
  ///
  /// In en, this message translates to:
  /// **'Outside the office location; attendance is permitted'**
  String get attendanceWarningOutsideAllowedLocation;

  /// No description provided for @attendanceWarningOfflinePending.
  ///
  /// In en, this message translates to:
  /// **'Attendance saved and waiting to sync'**
  String get attendanceWarningOfflinePending;

  /// No description provided for @attendanceWarningLatePunchIn.
  ///
  /// In en, this message translates to:
  /// **'Late punch in'**
  String get attendanceWarningLatePunchIn;

  /// No description provided for @attendanceWarningEarlyPunchOut.
  ///
  /// In en, this message translates to:
  /// **'Early punch out'**
  String get attendanceWarningEarlyPunchOut;

  /// No description provided for @attendanceWarningUnscheduledDay.
  ///
  /// In en, this message translates to:
  /// **'Attendance on an unscheduled day'**
  String get attendanceWarningUnscheduledDay;

  /// No description provided for @attendanceNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get attendanceNotStarted;

  /// No description provided for @attendanceWorking.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get attendanceWorking;

  /// No description provided for @attendanceOnBreak.
  ///
  /// In en, this message translates to:
  /// **'On break'**
  String get attendanceOnBreak;

  /// No description provided for @attendanceCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get attendanceCompleted;

  /// No description provided for @attendanceLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get attendanceLate;

  /// No description provided for @attendancePending.
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get attendancePending;

  /// No description provided for @attendanceSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get attendanceSynced;

  /// No description provided for @attendanceFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get attendanceFailed;

  /// No description provided for @attendanceRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get attendanceRejected;

  /// No description provided for @attendancePunchIn.
  ///
  /// In en, this message translates to:
  /// **'Punch in'**
  String get attendancePunchIn;

  /// No description provided for @attendanceBreakStart.
  ///
  /// In en, this message translates to:
  /// **'Start break'**
  String get attendanceBreakStart;

  /// No description provided for @attendanceBreakEnd.
  ///
  /// In en, this message translates to:
  /// **'Resume work'**
  String get attendanceBreakEnd;

  /// No description provided for @attendancePunchOut.
  ///
  /// In en, this message translates to:
  /// **'Punch out'**
  String get attendancePunchOut;

  /// No description provided for @attendancePunchInNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Punch in is not allowed'**
  String get attendancePunchInNotAllowed;

  /// No description provided for @attendanceTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s attendance'**
  String get attendanceTodayTitle;

  /// No description provided for @attendanceWorkday.
  ///
  /// In en, this message translates to:
  /// **'YOUR WORKDAY'**
  String get attendanceWorkday;

  /// No description provided for @attendanceCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Workday complete'**
  String get attendanceCompleteTitle;

  /// No description provided for @attendancePunchingIn.
  ///
  /// In en, this message translates to:
  /// **'Punching in…'**
  String get attendancePunchingIn;

  /// No description provided for @attendancePunchingOut.
  ///
  /// In en, this message translates to:
  /// **'Punching out…'**
  String get attendancePunchingOut;

  /// No description provided for @attendanceTakeBreak.
  ///
  /// In en, this message translates to:
  /// **'Take break'**
  String get attendanceTakeBreak;

  /// No description provided for @attendanceStartingBreak.
  ///
  /// In en, this message translates to:
  /// **'Starting break…'**
  String get attendanceStartingBreak;

  /// No description provided for @attendanceResumeWork.
  ///
  /// In en, this message translates to:
  /// **'Resume work'**
  String get attendanceResumeWork;

  /// No description provided for @attendanceResumingWork.
  ///
  /// In en, this message translates to:
  /// **'Resuming work…'**
  String get attendanceResumingWork;

  /// No description provided for @attendanceWorkTime.
  ///
  /// In en, this message translates to:
  /// **'Current work time'**
  String get attendanceWorkTime;

  /// No description provided for @attendanceCurrentLoggedWorkTime.
  ///
  /// In en, this message translates to:
  /// **'Current Logged Work Time (Today)'**
  String get attendanceCurrentLoggedWorkTime;

  /// No description provided for @attendanceInsideGeofence.
  ///
  /// In en, this message translates to:
  /// **'Inside {name} Geofence ({distance})'**
  String attendanceInsideGeofence(String name, String distance);

  /// No description provided for @attendanceCurrentBreak.
  ///
  /// In en, this message translates to:
  /// **'Current break'**
  String get attendanceCurrentBreak;

  /// No description provided for @attendanceTotalBreak.
  ///
  /// In en, this message translates to:
  /// **'Total break'**
  String get attendanceTotalBreak;

  /// No description provided for @attendanceElapsedTime.
  ///
  /// In en, this message translates to:
  /// **'Elapsed time'**
  String get attendanceElapsedTime;

  /// No description provided for @attendanceWorkedTime.
  ///
  /// In en, this message translates to:
  /// **'Worked time'**
  String get attendanceWorkedTime;

  /// No description provided for @attendanceBreakTime.
  ///
  /// In en, this message translates to:
  /// **'Break time'**
  String get attendanceBreakTime;

  /// No description provided for @attendanceTodayShift.
  ///
  /// In en, this message translates to:
  /// **'Today\'s shift'**
  String get attendanceTodayShift;

  /// No description provided for @attendanceWorkLocation.
  ///
  /// In en, this message translates to:
  /// **'Work location'**
  String get attendanceWorkLocation;

  /// No description provided for @attendanceLocationChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking your location…'**
  String get attendanceLocationChecking;

  /// No description provided for @attendanceLocationReady.
  ///
  /// In en, this message translates to:
  /// **'Location ready'**
  String get attendanceLocationReady;

  /// No description provided for @attendanceInsideLocation.
  ///
  /// In en, this message translates to:
  /// **'Inside work location'**
  String get attendanceInsideLocation;

  /// No description provided for @attendanceOutsideLocation.
  ///
  /// In en, this message translates to:
  /// **'Outside work location'**
  String get attendanceOutsideLocation;

  /// No description provided for @attendanceLocationNotRequired.
  ///
  /// In en, this message translates to:
  /// **'Location verification not required'**
  String get attendanceLocationNotRequired;

  /// No description provided for @attendanceLocationRequiredNote.
  ///
  /// In en, this message translates to:
  /// **'Your location will be checked when you submit this action.'**
  String get attendanceLocationRequiredNote;

  /// No description provided for @attendanceAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Location accuracy'**
  String get attendanceAccuracy;

  /// No description provided for @attendanceRadius.
  ///
  /// In en, this message translates to:
  /// **'Allowed radius'**
  String get attendanceRadius;

  /// No description provided for @attendanceRefreshLocation.
  ///
  /// In en, this message translates to:
  /// **'Refresh location'**
  String get attendanceRefreshLocation;

  /// No description provided for @attendanceAllowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get attendanceAllowLocation;

  /// No description provided for @attendanceOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get attendanceOpenSettings;

  /// No description provided for @attendancePermissionSettings.
  ///
  /// In en, this message translates to:
  /// **'Location permission is disabled in system settings.'**
  String get attendancePermissionSettings;

  /// No description provided for @attendanceServicesNote.
  ///
  /// In en, this message translates to:
  /// **'Turn on location services to continue.'**
  String get attendanceServicesNote;

  /// No description provided for @attendanceNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get attendanceNoActivity;

  /// No description provided for @attendanceActivityNote.
  ///
  /// In en, this message translates to:
  /// **'Your punch-in and break activity will appear here.'**
  String get attendanceActivityNote;

  /// No description provided for @attendanceTodayActivity.
  ///
  /// In en, this message translates to:
  /// **'Today\'s activity'**
  String get attendanceTodayActivity;

  /// No description provided for @attendancePunchInTime.
  ///
  /// In en, this message translates to:
  /// **'Punch-in time'**
  String get attendancePunchInTime;

  /// No description provided for @attendancePunchOutTime.
  ///
  /// In en, this message translates to:
  /// **'Punch out'**
  String get attendancePunchOutTime;

  /// No description provided for @attendanceCurrentTime.
  ///
  /// In en, this message translates to:
  /// **'Current time'**
  String get attendanceCurrentTime;

  /// No description provided for @attendanceBreakStartedLabel.
  ///
  /// In en, this message translates to:
  /// **'Break started'**
  String get attendanceBreakStartedLabel;

  /// No description provided for @attendanceWorkResumedLabel.
  ///
  /// In en, this message translates to:
  /// **'Work resumed'**
  String get attendanceWorkResumedLabel;

  /// No description provided for @attendanceEndWorkday.
  ///
  /// In en, this message translates to:
  /// **'End your workday?'**
  String get attendanceEndWorkday;

  /// No description provided for @attendanceConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm attendance action'**
  String get attendanceConfirmAction;

  /// No description provided for @attendanceContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get attendanceContinue;

  /// No description provided for @attendanceCloseBreakNote.
  ///
  /// In en, this message translates to:
  /// **'Your current break will end when you punch out.'**
  String get attendanceCloseBreakNote;

  /// No description provided for @attendancePendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get attendancePendingTitle;

  /// No description provided for @attendancePendingNote.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device. Waiting for verification when sync becomes available.'**
  String get attendancePendingNote;

  /// No description provided for @attendanceFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance sync needs attention'**
  String get attendanceFailedTitle;

  /// No description provided for @attendanceFailedNote.
  ///
  /// In en, this message translates to:
  /// **'Your attendance is saved locally but could not be verified.'**
  String get attendanceFailedNote;

  /// No description provided for @attendanceRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance could not be verified'**
  String get attendanceRejectedTitle;

  /// No description provided for @attendanceRejectedNote.
  ///
  /// In en, this message translates to:
  /// **'Your recorded events are retained. Contact HR to resolve this issue.'**
  String get attendanceRejectedNote;

  /// No description provided for @attendanceRetrySync.
  ///
  /// In en, this message translates to:
  /// **'Retry sync'**
  String get attendanceRetrySync;

  /// No description provided for @attendanceRequeuedNote.
  ///
  /// In en, this message translates to:
  /// **'Attendance is queued for sync. No sync service is configured yet.'**
  String get attendanceRequeuedNote;

  /// No description provided for @attendanceNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Attendance is not configured yet'**
  String get attendanceNotConfigured;

  /// No description provided for @attendanceContactHr.
  ///
  /// In en, this message translates to:
  /// **'Contact HR to complete your attendance setup.'**
  String get attendanceContactHr;

  /// No description provided for @attendanceUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance unavailable'**
  String get attendanceUnavailableTitle;

  /// No description provided for @attendanceStartNote.
  ///
  /// In en, this message translates to:
  /// **'Punch in to begin your workday.'**
  String get attendanceStartNote;

  /// No description provided for @attendanceWorkingNote.
  ///
  /// In en, this message translates to:
  /// **'Your work time is calculated from recorded activity.'**
  String get attendanceWorkingNote;

  /// No description provided for @attendanceBreakNote.
  ///
  /// In en, this message translates to:
  /// **'Work time is paused while you are on a break.'**
  String get attendanceBreakNote;

  /// No description provided for @attendanceCompleteNote.
  ///
  /// In en, this message translates to:
  /// **'Your final totals and activity are recorded below.'**
  String get attendanceCompleteNote;

  /// No description provided for @attendanceExpectedHours.
  ///
  /// In en, this message translates to:
  /// **'Expected work'**
  String get attendanceExpectedHours;

  /// No description provided for @attendanceGrace.
  ///
  /// In en, this message translates to:
  /// **'Grace period'**
  String get attendanceGrace;

  /// No description provided for @attendanceOnTime.
  ///
  /// In en, this message translates to:
  /// **'On-time'**
  String get attendanceOnTime;

  /// No description provided for @attendanceTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get attendanceTarget;

  /// No description provided for @attendanceShiftRemaining.
  ///
  /// In en, this message translates to:
  /// **'Shift remaining'**
  String get attendanceShiftRemaining;

  /// No description provided for @attendanceOpenAttendance.
  ///
  /// In en, this message translates to:
  /// **'Open attendance'**
  String get attendanceOpenAttendance;

  /// No description provided for @attendanceViewAttendance.
  ///
  /// In en, this message translates to:
  /// **'View attendance'**
  String get attendanceViewAttendance;

  /// No description provided for @attendanceStartsAt.
  ///
  /// In en, this message translates to:
  /// **'Starts at'**
  String get attendanceStartsAt;

  /// No description provided for @attendanceWorked.
  ///
  /// In en, this message translates to:
  /// **'Worked'**
  String get attendanceWorked;

  /// No description provided for @attendanceBreak.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get attendanceBreak;

  /// No description provided for @attendanceLastCheck.
  ///
  /// In en, this message translates to:
  /// **'Last location check'**
  String get attendanceLastCheck;

  /// No description provided for @attendanceCheckingSetup.
  ///
  /// In en, this message translates to:
  /// **'Loading attendance setup'**
  String get attendanceCheckingSetup;

  /// No description provided for @attendanceWarningNote.
  ///
  /// In en, this message translates to:
  /// **'Review these details before recording your attendance.'**
  String get attendanceWarningNote;

  /// No description provided for @attendanceDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance from work location'**
  String get attendanceDistance;

  /// No description provided for @attendanceTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get attendanceTryAgain;

  /// No description provided for @attendanceLocationCaptureReady.
  ///
  /// In en, this message translates to:
  /// **'Location captured'**
  String get attendanceLocationCaptureReady;

  /// No description provided for @attendanceAccuracyLimit.
  ///
  /// In en, this message translates to:
  /// **'Required accuracy'**
  String get attendanceAccuracyLimit;

  /// No description provided for @attendanceNoLocation.
  ///
  /// In en, this message translates to:
  /// **'No work location assigned'**
  String get attendanceNoLocation;

  /// No description provided for @attendanceGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get attendanceGoodMorning;

  /// No description provided for @attendanceGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get attendanceGoodAfternoon;

  /// No description provided for @attendanceGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get attendanceGoodEvening;

  /// No description provided for @attendanceMeters.
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String attendanceMeters(String value);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance history'**
  String get historyTitle;

  /// No description provided for @historyNav.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyNav;

  /// No description provided for @historyMonthlySummary.
  ///
  /// In en, this message translates to:
  /// **'Monthly summary'**
  String get historyMonthlySummary;

  /// No description provided for @historyPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get historyPreviousMonth;

  /// No description provided for @historyNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get historyNextMonth;

  /// No description provided for @historyPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get historyPresent;

  /// No description provided for @historyLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get historyLate;

  /// No description provided for @historyIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get historyIncomplete;

  /// No description provided for @historyCompletedOnly.
  ///
  /// In en, this message translates to:
  /// **'Work and break totals include completed records only.'**
  String get historyCompletedOnly;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No attendance records'**
  String get historyEmpty;

  /// No description provided for @historyFilteredEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matching attendance records'**
  String get historyFilteredEmpty;

  /// No description provided for @historyEmptyNote.
  ///
  /// In en, this message translates to:
  /// **'No activity was recorded in this month.'**
  String get historyEmptyNote;

  /// No description provided for @historyFilteredNote.
  ///
  /// In en, this message translates to:
  /// **'Try another status or clear your filters.'**
  String get historyFilteredNote;

  /// No description provided for @historyClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get historyClearFilters;

  /// No description provided for @historyAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get historyAllStatuses;

  /// No description provided for @historyFilters.
  ///
  /// In en, this message translates to:
  /// **'Status filters'**
  String get historyFilters;

  /// No description provided for @historyApply.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get historyApply;

  /// No description provided for @historyReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get historyReset;

  /// No description provided for @historyDetails.
  ///
  /// In en, this message translates to:
  /// **'Attendance details'**
  String get historyDetails;

  /// No description provided for @historyDailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily summary'**
  String get historyDailySummary;

  /// No description provided for @historyTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get historyTimeline;

  /// No description provided for @historyBreaks.
  ///
  /// In en, this message translates to:
  /// **'Breaks'**
  String get historyBreaks;

  /// No description provided for @historyMissingOut.
  ///
  /// In en, this message translates to:
  /// **'Missing punch out'**
  String get historyMissingOut;

  /// No description provided for @historyOpenBreak.
  ///
  /// In en, this message translates to:
  /// **'Incomplete break'**
  String get historyOpenBreak;

  /// No description provided for @historyNotRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get historyNotRecorded;

  /// No description provided for @historyNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get historyNeedsAttention;

  /// No description provided for @historyIncompleteNote.
  ///
  /// In en, this message translates to:
  /// **'This record has no punch out. Final work and break totals are unavailable.'**
  String get historyIncompleteNote;

  /// No description provided for @historyOpenBreakNote.
  ///
  /// In en, this message translates to:
  /// **'No resume recorded. This break has no final duration.'**
  String get historyOpenBreakNote;

  /// No description provided for @historyGoToday.
  ///
  /// In en, this message translates to:
  /// **'Open today’s attendance'**
  String get historyGoToday;

  /// No description provided for @historyActiveNote.
  ///
  /// In en, this message translates to:
  /// **'This record is still open. Use Today for live totals and attendance actions.'**
  String get historyActiveNote;

  /// No description provided for @historyNotFound.
  ///
  /// In en, this message translates to:
  /// **'Attendance record unavailable'**
  String get historyNotFound;

  /// No description provided for @historyNotFoundNote.
  ///
  /// In en, this message translates to:
  /// **'This record was not found in your attendance history.'**
  String get historyNotFoundNote;

  /// No description provided for @historyOvernight.
  ///
  /// In en, this message translates to:
  /// **'Overnight shift'**
  String get historyOvernight;

  /// No description provided for @historyExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected duration'**
  String get historyExpected;

  /// No description provided for @historyGrace.
  ///
  /// In en, this message translates to:
  /// **'Grace period'**
  String get historyGrace;

  /// No description provided for @historyWithinArea.
  ///
  /// In en, this message translates to:
  /// **'Within assigned area'**
  String get historyWithinArea;

  /// No description provided for @historyOutsideAllowed.
  ///
  /// In en, this message translates to:
  /// **'Outside assigned area · allowed by policy'**
  String get historyOutsideAllowed;

  /// No description provided for @historyVerificationIssue.
  ///
  /// In en, this message translates to:
  /// **'Verification issue'**
  String get historyVerificationIssue;

  /// No description provided for @historyContactHr.
  ///
  /// In en, this message translates to:
  /// **'The original record is retained. Contact HR about this verification issue.'**
  String get historyContactHr;

  /// No description provided for @historyDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get historyDate;

  /// No description provided for @historyStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get historyStatus;

  /// No description provided for @historyNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get historyNow;

  /// No description provided for @historyRetry.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get historyRetry;

  /// No description provided for @historyAverageWork.
  ///
  /// In en, this message translates to:
  /// **'Average worked per completed day'**
  String get historyAverageWork;

  /// No description provided for @historyNoBreaks.
  ///
  /// In en, this message translates to:
  /// **'No breaks recorded'**
  String get historyNoBreaks;

  /// No description provided for @historyFilterCount.
  ///
  /// In en, this message translates to:
  /// **'Status filters ({count})'**
  String historyFilterCount(String count);

  /// No description provided for @correctionRequest.
  ///
  /// In en, this message translates to:
  /// **'Request correction'**
  String get correctionRequest;

  /// No description provided for @correctionMyRequests.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get correctionMyRequests;

  /// No description provided for @correctionReviewQueue.
  ///
  /// In en, this message translates to:
  /// **'Correction requests'**
  String get correctionReviewQueue;

  /// No description provided for @correctionType.
  ///
  /// In en, this message translates to:
  /// **'Correction type'**
  String get correctionType;

  /// No description provided for @correctionRequestedTime.
  ///
  /// In en, this message translates to:
  /// **'Requested date and time'**
  String get correctionRequestedTime;

  /// No description provided for @correctionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get correctionReason;

  /// No description provided for @correctionReviewNote.
  ///
  /// In en, this message translates to:
  /// **'Review note'**
  String get correctionReviewNote;

  /// No description provided for @correctionSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get correctionSubmit;

  /// No description provided for @correctionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get correctionCancel;

  /// No description provided for @correctionApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get correctionApprove;

  /// No description provided for @correctionReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get correctionReject;

  /// No description provided for @correctionPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get correctionPending;

  /// No description provided for @correctionApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get correctionApproved;

  /// No description provided for @correctionRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get correctionRejected;

  /// No description provided for @correctionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get correctionCancelled;

  /// No description provided for @correctionOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get correctionOriginal;

  /// No description provided for @correctionRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get correctionRequested;

  /// No description provided for @correctionNoRequests.
  ///
  /// In en, this message translates to:
  /// **'No correction requests'**
  String get correctionNoRequests;

  /// No description provided for @correctionMissingPunchIn.
  ///
  /// In en, this message translates to:
  /// **'Missing punch in'**
  String get correctionMissingPunchIn;

  /// No description provided for @correctionMissingPunchOut.
  ///
  /// In en, this message translates to:
  /// **'Missing punch out'**
  String get correctionMissingPunchOut;

  /// No description provided for @correctionChangePunchIn.
  ///
  /// In en, this message translates to:
  /// **'Change punch in time'**
  String get correctionChangePunchIn;

  /// No description provided for @correctionChangePunchOut.
  ///
  /// In en, this message translates to:
  /// **'Change punch out time'**
  String get correctionChangePunchOut;

  /// No description provided for @correctionMissingBreakStart.
  ///
  /// In en, this message translates to:
  /// **'Missing break start'**
  String get correctionMissingBreakStart;

  /// No description provided for @correctionMissingBreakEnd.
  ///
  /// In en, this message translates to:
  /// **'Missing break end'**
  String get correctionMissingBreakEnd;

  /// No description provided for @correctionChangeBreakStart.
  ///
  /// In en, this message translates to:
  /// **'Change break start time'**
  String get correctionChangeBreakStart;

  /// No description provided for @correctionChangeBreakEnd.
  ///
  /// In en, this message translates to:
  /// **'Change break end time'**
  String get correctionChangeBreakEnd;

  /// No description provided for @correctionPreview.
  ///
  /// In en, this message translates to:
  /// **'Effective result preview'**
  String get correctionPreview;

  /// No description provided for @correctionInvalid.
  ///
  /// In en, this message translates to:
  /// **'Check the requested time and event order.'**
  String get correctionInvalid;

  /// No description provided for @correctionSaved.
  ///
  /// In en, this message translates to:
  /// **'Correction request submitted'**
  String get correctionSaved;

  /// No description provided for @correctionReviewSaved.
  ///
  /// In en, this message translates to:
  /// **'Review saved'**
  String get correctionReviewSaved;

  /// No description provided for @correctionReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a reason'**
  String get correctionReasonRequired;

  /// No description provided for @workforceTeam.
  ///
  /// In en, this message translates to:
  /// **'Team attendance'**
  String get workforceTeam;

  /// No description provided for @workforceAll.
  ///
  /// In en, this message translates to:
  /// **'All attendance'**
  String get workforceAll;

  /// No description provided for @workforceNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get workforceNotStarted;

  /// No description provided for @workforceWorking.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get workforceWorking;

  /// No description provided for @workforceOnBreak.
  ///
  /// In en, this message translates to:
  /// **'On break'**
  String get workforceOnBreak;

  /// No description provided for @workforceCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get workforceCompleted;

  /// No description provided for @workforceIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get workforceIncomplete;

  /// No description provided for @workforceNoSchedule.
  ///
  /// In en, this message translates to:
  /// **'No schedule'**
  String get workforceNoSchedule;

  /// No description provided for @workforceNoRecord.
  ///
  /// In en, this message translates to:
  /// **'No record'**
  String get workforceNoRecord;

  /// No description provided for @workforceSearch.
  ///
  /// In en, this message translates to:
  /// **'Search employees'**
  String get workforceSearch;

  /// No description provided for @workforceNoEmployees.
  ///
  /// In en, this message translates to:
  /// **'No employees match'**
  String get workforceNoEmployees;

  /// No description provided for @workforceDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get workforceDepartment;

  /// No description provided for @workforceShift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get workforceShift;

  /// No description provided for @workforceLocation.
  ///
  /// In en, this message translates to:
  /// **'Work location'**
  String get workforceLocation;

  /// No description provided for @workforceDate.
  ///
  /// In en, this message translates to:
  /// **'Attendance date'**
  String get workforceDate;

  /// No description provided for @workforceToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get workforceToday;

  /// No description provided for @workforcePrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get workforcePrevious;

  /// No description provided for @workforceNext.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get workforceNext;

  /// No description provided for @workforcePendingCorrection.
  ///
  /// In en, this message translates to:
  /// **'Pending correction'**
  String get workforcePendingCorrection;

  /// No description provided for @workforceSort.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get workforceSort;

  /// No description provided for @workforceName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get workforceName;

  /// No description provided for @workforceNameDescending.
  ///
  /// In en, this message translates to:
  /// **'Name (Z–A)'**
  String get workforceNameDescending;

  /// No description provided for @workforceCode.
  ///
  /// In en, this message translates to:
  /// **'Employee code'**
  String get workforceCode;

  /// No description provided for @workforceAllFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get workforceAllFilter;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance reports'**
  String get reportTitle;

  /// No description provided for @reportOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get reportOverview;

  /// No description provided for @reportWorkHours.
  ///
  /// In en, this message translates to:
  /// **'Work hours'**
  String get reportWorkHours;

  /// No description provided for @reportLate.
  ///
  /// In en, this message translates to:
  /// **'Late attendance'**
  String get reportLate;

  /// No description provided for @reportBreaks.
  ///
  /// In en, this message translates to:
  /// **'Break analysis'**
  String get reportBreaks;

  /// No description provided for @reportIssues.
  ///
  /// In en, this message translates to:
  /// **'Attendance issues'**
  String get reportIssues;

  /// No description provided for @reportEmployees.
  ///
  /// In en, this message translates to:
  /// **'Employee summary'**
  String get reportEmployees;

  /// No description provided for @reportToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get reportToday;

  /// No description provided for @reportThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get reportThisWeek;

  /// No description provided for @reportThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get reportThisMonth;

  /// No description provided for @reportLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get reportLastMonth;

  /// No description provided for @reportCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get reportCustom;

  /// No description provided for @reportFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get reportFrom;

  /// No description provided for @reportTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get reportTo;

  /// No description provided for @reportScopeTeam.
  ///
  /// In en, this message translates to:
  /// **'My team'**
  String get reportScopeTeam;

  /// No description provided for @reportScopeCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get reportScopeCompany;

  /// No description provided for @reportRecordedDays.
  ///
  /// In en, this message translates to:
  /// **'Recorded workdays'**
  String get reportRecordedDays;

  /// No description provided for @reportCompletedDays.
  ///
  /// In en, this message translates to:
  /// **'Completed workdays'**
  String get reportCompletedDays;

  /// No description provided for @reportLateDays.
  ///
  /// In en, this message translates to:
  /// **'Late records'**
  String get reportLateDays;

  /// No description provided for @reportIncompleteDays.
  ///
  /// In en, this message translates to:
  /// **'Incomplete records'**
  String get reportIncompleteDays;

  /// No description provided for @reportWorkTotal.
  ///
  /// In en, this message translates to:
  /// **'Worked time'**
  String get reportWorkTotal;

  /// No description provided for @reportBreakTotal.
  ///
  /// In en, this message translates to:
  /// **'Break time'**
  String get reportBreakTotal;

  /// No description provided for @reportAverageWork.
  ///
  /// In en, this message translates to:
  /// **'Average per recorded day'**
  String get reportAverageWork;

  /// No description provided for @reportPendingCorrections.
  ///
  /// In en, this message translates to:
  /// **'Pending corrections'**
  String get reportPendingCorrections;

  /// No description provided for @reportIssueDays.
  ///
  /// In en, this message translates to:
  /// **'Days with issues'**
  String get reportIssueDays;

  /// No description provided for @reportTrend.
  ///
  /// In en, this message translates to:
  /// **'Recorded workdays by date'**
  String get reportTrend;

  /// No description provided for @reportDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get reportDaily;

  /// No description provided for @reportWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get reportWeekly;

  /// No description provided for @reportMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get reportMonthly;

  /// No description provided for @reportGroupBy.
  ///
  /// In en, this message translates to:
  /// **'Group by'**
  String get reportGroupBy;

  /// No description provided for @reportNoData.
  ///
  /// In en, this message translates to:
  /// **'No recorded attendance matches this period and filters.'**
  String get reportNoData;

  /// No description provided for @reportInProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s active attendance is provisional until punch out.'**
  String get reportInProgress;

  /// No description provided for @reportFilter.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get reportFilter;

  /// No description provided for @reportClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get reportClearFilters;

  /// No description provided for @reportEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get reportEmployee;

  /// No description provided for @reportStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get reportStatus;

  /// No description provided for @reportCorrections.
  ///
  /// In en, this message translates to:
  /// **'Corrections'**
  String get reportCorrections;

  /// No description provided for @reportAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get reportAny;

  /// No description provided for @reportYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get reportYes;

  /// No description provided for @reportNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get reportNo;

  /// No description provided for @reportApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get reportApply;

  /// No description provided for @reportExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get reportExport;

  /// No description provided for @reportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get reportCsv;

  /// No description provided for @reportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get reportPdf;

  /// No description provided for @reportExported.
  ///
  /// In en, this message translates to:
  /// **'Report saved'**
  String get reportExported;

  /// No description provided for @reportExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not export report'**
  String get reportExportFailed;

  /// No description provided for @reportLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading report'**
  String get reportLoading;

  /// No description provided for @reportRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh report'**
  String get reportRefreshFailed;

  /// No description provided for @reportUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Attendance reports are unavailable.'**
  String get reportUnavailable;

  /// No description provided for @reportDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get reportDate;

  /// No description provided for @reportWorked.
  ///
  /// In en, this message translates to:
  /// **'Worked'**
  String get reportWorked;

  /// No description provided for @reportBreak.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get reportBreak;

  /// No description provided for @reportLateBy.
  ///
  /// In en, this message translates to:
  /// **'Late by'**
  String get reportLateBy;

  /// No description provided for @reportRecorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded days'**
  String get reportRecorded;

  /// No description provided for @reportCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get reportCompleted;

  /// No description provided for @reportLateCount.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get reportLateCount;

  /// No description provided for @reportIssuesCount.
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get reportIssuesCount;

  /// No description provided for @reportPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get reportPending;

  /// No description provided for @reportShiftStart.
  ///
  /// In en, this message translates to:
  /// **'Shift start'**
  String get reportShiftStart;

  /// No description provided for @reportPunchIn.
  ///
  /// In en, this message translates to:
  /// **'Punch in'**
  String get reportPunchIn;

  /// No description provided for @reportDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get reportDepartment;

  /// No description provided for @reportLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get reportLocation;

  /// No description provided for @reportPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get reportPeriod;

  /// No description provided for @reportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated'**
  String get reportGenerated;

  /// No description provided for @reportPage.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get reportPage;

  /// No description provided for @reportSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get reportSortNewest;

  /// No description provided for @reportSortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get reportSortOldest;

  /// No description provided for @reportSortEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee name'**
  String get reportSortEmployee;

  /// No description provided for @reportSortWork.
  ///
  /// In en, this message translates to:
  /// **'Most worked time'**
  String get reportSortWork;

  /// No description provided for @reportSortBreak.
  ///
  /// In en, this message translates to:
  /// **'Most break time'**
  String get reportSortBreak;

  /// No description provided for @reportFiltersApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied filters'**
  String get reportFiltersApplied;

  /// No description provided for @attendanceNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Attendance needs review'**
  String get attendanceNeedsReview;

  /// No description provided for @attendanceConflict.
  ///
  /// In en, this message translates to:
  /// **'Attendance conflict'**
  String get attendanceConflict;

  /// No description provided for @attendanceConflictMessage.
  ///
  /// In en, this message translates to:
  /// **'Your local attendance does not match the latest server record.'**
  String get attendanceConflictMessage;

  /// No description provided for @attendanceCouldNotBeVerified.
  ///
  /// In en, this message translates to:
  /// **'Attendance could not be verified'**
  String get attendanceCouldNotBeVerified;

  /// No description provided for @attendanceNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Attendance needs attention'**
  String get attendanceNeedsAttention;

  /// No description provided for @reportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Analyze attendance activity, work hours, timing and record quality.'**
  String get reportSubtitle;

  /// No description provided for @reportActivityTrend.
  ///
  /// In en, this message translates to:
  /// **'Attendance activity'**
  String get reportActivityTrend;

  /// No description provided for @reportActivityTrendDesc.
  ///
  /// In en, this message translates to:
  /// **'Recorded records by date.'**
  String get reportActivityTrendDesc;

  /// No description provided for @reportStatusDistribution.
  ///
  /// In en, this message translates to:
  /// **'Attendance status'**
  String get reportStatusDistribution;

  /// No description provided for @reportStatusDistributionDesc.
  ///
  /// In en, this message translates to:
  /// **'Composition of recorded records.'**
  String get reportStatusDistributionDesc;

  /// No description provided for @reportWorkHoursTrend.
  ///
  /// In en, this message translates to:
  /// **'Recorded work hours'**
  String get reportWorkHoursTrend;

  /// No description provided for @reportWorkHoursTrendDesc.
  ///
  /// In en, this message translates to:
  /// **'Total recorded work time by date.'**
  String get reportWorkHoursTrendDesc;

  /// No description provided for @reportLateTrend.
  ///
  /// In en, this message translates to:
  /// **'Late attendance'**
  String get reportLateTrend;

  /// No description provided for @reportLateTrendDesc.
  ///
  /// In en, this message translates to:
  /// **'Late records by date.'**
  String get reportLateTrendDesc;

  /// No description provided for @reportBreakTrend.
  ///
  /// In en, this message translates to:
  /// **'Break time'**
  String get reportBreakTrend;

  /// No description provided for @reportBreakTrendDesc.
  ///
  /// In en, this message translates to:
  /// **'Recorded break time by date.'**
  String get reportBreakTrendDesc;

  /// No description provided for @reportIssuesByType.
  ///
  /// In en, this message translates to:
  /// **'Issues by type'**
  String get reportIssuesByType;

  /// No description provided for @reportIssuesByTypeDesc.
  ///
  /// In en, this message translates to:
  /// **'What needs attention in this period.'**
  String get reportIssuesByTypeDesc;

  /// No description provided for @reportNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get reportNeedsAttention;

  /// No description provided for @reportDetailedRecords.
  ///
  /// In en, this message translates to:
  /// **'Detailed records'**
  String get reportDetailedRecords;

  /// No description provided for @reportStatusWorking.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get reportStatusWorking;

  /// No description provided for @reportStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get reportStatusCompleted;

  /// No description provided for @reportStatusLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get reportStatusLate;

  /// No description provided for @reportStatusIssues.
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get reportStatusIssues;

  /// No description provided for @reportIssueRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected attendance'**
  String get reportIssueRejected;

  /// No description provided for @reportIssueSyncFailure.
  ///
  /// In en, this message translates to:
  /// **'Sync failure'**
  String get reportIssueSyncFailure;

  /// No description provided for @reportIssuePendingCorrection.
  ///
  /// In en, this message translates to:
  /// **'Pending correction'**
  String get reportIssuePendingCorrection;

  /// No description provided for @reportIssueMissingPunchOut.
  ///
  /// In en, this message translates to:
  /// **'Missing punch out'**
  String get reportIssueMissingPunchOut;

  /// No description provided for @reportViewTeam.
  ///
  /// In en, this message translates to:
  /// **'Team view'**
  String get reportViewTeam;

  /// No description provided for @reportViewCompany.
  ///
  /// In en, this message translates to:
  /// **'Company view'**
  String get reportViewCompany;

  /// No description provided for @reportRecordedEmployees.
  ///
  /// In en, this message translates to:
  /// **'Recorded employees'**
  String get reportRecordedEmployees;

  /// No description provided for @permissionLeaveViewSelf.
  ///
  /// In en, this message translates to:
  /// **'View own leave'**
  String get permissionLeaveViewSelf;

  /// No description provided for @permissionLeaveRequest.
  ///
  /// In en, this message translates to:
  /// **'Request leave'**
  String get permissionLeaveRequest;

  /// No description provided for @permissionLeaveCancelSelf.
  ///
  /// In en, this message translates to:
  /// **'Cancel own leave'**
  String get permissionLeaveCancelSelf;

  /// No description provided for @permissionLeaveViewTeam.
  ///
  /// In en, this message translates to:
  /// **'View team leave'**
  String get permissionLeaveViewTeam;

  /// No description provided for @permissionLeaveApproveTeam.
  ///
  /// In en, this message translates to:
  /// **'Approve team leave'**
  String get permissionLeaveApproveTeam;

  /// No description provided for @permissionLeaveViewAll.
  ///
  /// In en, this message translates to:
  /// **'View company leave'**
  String get permissionLeaveViewAll;

  /// No description provided for @permissionLeaveApproveAll.
  ///
  /// In en, this message translates to:
  /// **'Approve company leave'**
  String get permissionLeaveApproveAll;

  /// No description provided for @permissionLeaveManage.
  ///
  /// In en, this message translates to:
  /// **'Manage leave'**
  String get permissionLeaveManage;

  /// No description provided for @permissionLeaveBalanceViewSelf.
  ///
  /// In en, this message translates to:
  /// **'View own leave balance'**
  String get permissionLeaveBalanceViewSelf;

  /// No description provided for @permissionLeaveBalanceViewTeam.
  ///
  /// In en, this message translates to:
  /// **'View team leave balances'**
  String get permissionLeaveBalanceViewTeam;

  /// No description provided for @permissionLeaveBalanceViewAll.
  ///
  /// In en, this message translates to:
  /// **'View company leave balances'**
  String get permissionLeaveBalanceViewAll;

  /// No description provided for @permissionLeaveBalanceAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust leave balances'**
  String get permissionLeaveBalanceAdjust;

  /// No description provided for @permissionLeaveTypeView.
  ///
  /// In en, this message translates to:
  /// **'View leave types'**
  String get permissionLeaveTypeView;

  /// No description provided for @permissionLeaveTypeManage.
  ///
  /// In en, this message translates to:
  /// **'Manage leave types'**
  String get permissionLeaveTypeManage;

  /// No description provided for @permissionLeavePolicyView.
  ///
  /// In en, this message translates to:
  /// **'View leave policies'**
  String get permissionLeavePolicyView;

  /// No description provided for @permissionLeavePolicyManage.
  ///
  /// In en, this message translates to:
  /// **'Manage leave policies'**
  String get permissionLeavePolicyManage;

  /// No description provided for @permissionHolidayView.
  ///
  /// In en, this message translates to:
  /// **'View holidays'**
  String get permissionHolidayView;

  /// No description provided for @permissionHolidayManage.
  ///
  /// In en, this message translates to:
  /// **'Manage holidays'**
  String get permissionHolidayManage;

  /// No description provided for @permissionLeaveReportView.
  ///
  /// In en, this message translates to:
  /// **'View leave reports'**
  String get permissionLeaveReportView;

  /// No description provided for @leaveMyLeave.
  ///
  /// In en, this message translates to:
  /// **'My leave'**
  String get leaveMyLeave;

  /// No description provided for @leaveNewRequest.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get leaveNewRequest;

  /// No description provided for @leaveMyRequests.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get leaveMyRequests;

  /// No description provided for @leaveApprovals.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get leaveApprovals;

  /// No description provided for @leaveTeam.
  ///
  /// In en, this message translates to:
  /// **'Team leave'**
  String get leaveTeam;

  /// No description provided for @leaveAllNav.
  ///
  /// In en, this message translates to:
  /// **'All leave'**
  String get leaveAllNav;

  /// No description provided for @leaveBalancesNav.
  ///
  /// In en, this message translates to:
  /// **'Balances'**
  String get leaveBalancesNav;

  /// No description provided for @leaveCalendarNav.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get leaveCalendarNav;

  /// No description provided for @leaveTypesNav.
  ///
  /// In en, this message translates to:
  /// **'Leave types'**
  String get leaveTypesNav;

  /// No description provided for @leavePoliciesNav.
  ///
  /// In en, this message translates to:
  /// **'Leave policies'**
  String get leavePoliciesNav;

  /// No description provided for @holidaysNav.
  ///
  /// In en, this message translates to:
  /// **'Holidays'**
  String get holidaysNav;

  /// No description provided for @leaveTypeIntro.
  ///
  /// In en, this message translates to:
  /// **'Configure the kinds of leave employees can request.'**
  String get leaveTypeIntro;

  /// No description provided for @leavePolicyIntro.
  ///
  /// In en, this message translates to:
  /// **'Define entitlement and request rules for each leave type.'**
  String get leavePolicyIntro;

  /// No description provided for @holidayIntro.
  ///
  /// In en, this message translates to:
  /// **'Configure public, company and optional holidays.'**
  String get holidayIntro;

  /// No description provided for @leaveType.
  ///
  /// In en, this message translates to:
  /// **'Leave type'**
  String get leaveType;

  /// No description provided for @leaveCompensation.
  ///
  /// In en, this message translates to:
  /// **'Compensation'**
  String get leaveCompensation;

  /// No description provided for @leaveRequiresApproval.
  ///
  /// In en, this message translates to:
  /// **'Requires approval'**
  String get leaveRequiresApproval;

  /// No description provided for @leaveAllowsHalfDay.
  ///
  /// In en, this message translates to:
  /// **'Allows half day'**
  String get leaveAllowsHalfDay;

  /// No description provided for @leaveRequiresReason.
  ///
  /// In en, this message translates to:
  /// **'Reason required'**
  String get leaveRequiresReason;

  /// No description provided for @leaveRequiresAttachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment required'**
  String get leaveRequiresAttachment;

  /// No description provided for @leaveCompensationPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get leaveCompensationPaid;

  /// No description provided for @leaveCompensationUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get leaveCompensationUnpaid;

  /// No description provided for @leaveCompensationInformational.
  ///
  /// In en, this message translates to:
  /// **'Informational'**
  String get leaveCompensationInformational;

  /// No description provided for @leavePolicy.
  ///
  /// In en, this message translates to:
  /// **'Leave policy'**
  String get leavePolicy;

  /// No description provided for @leavePolicyLeaveType.
  ///
  /// In en, this message translates to:
  /// **'Leave type'**
  String get leavePolicyLeaveType;

  /// No description provided for @leavePolicyEntitlement.
  ///
  /// In en, this message translates to:
  /// **'Annual entitlement'**
  String get leavePolicyEntitlement;

  /// No description provided for @leavePolicyMinDays.
  ///
  /// In en, this message translates to:
  /// **'Minimum request'**
  String get leavePolicyMinDays;

  /// No description provided for @leavePolicyMaxConsecutive.
  ///
  /// In en, this message translates to:
  /// **'Maximum consecutive days'**
  String get leavePolicyMaxConsecutive;

  /// No description provided for @leavePolicyAdvanceNotice.
  ///
  /// In en, this message translates to:
  /// **'Advance notice'**
  String get leavePolicyAdvanceNotice;

  /// No description provided for @leavePolicyAllowPast.
  ///
  /// In en, this message translates to:
  /// **'Allow past requests'**
  String get leavePolicyAllowPast;

  /// No description provided for @leavePolicyPastWindow.
  ///
  /// In en, this message translates to:
  /// **'Past request window'**
  String get leavePolicyPastWindow;

  /// No description provided for @leavePolicyNegative.
  ///
  /// In en, this message translates to:
  /// **'Allow negative balance'**
  String get leavePolicyNegative;

  /// No description provided for @leavePolicyCarryForward.
  ///
  /// In en, this message translates to:
  /// **'Carry forward'**
  String get leavePolicyCarryForward;

  /// No description provided for @leavePolicyCarryLimit.
  ///
  /// In en, this message translates to:
  /// **'Carry forward limit'**
  String get leavePolicyCarryLimit;

  /// No description provided for @leavePolicyEmployment.
  ///
  /// In en, this message translates to:
  /// **'Applicable employment types'**
  String get leavePolicyEmployment;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @holiday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get holiday;

  /// No description provided for @holidayDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get holidayDate;

  /// No description provided for @holidayEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get holidayEndDate;

  /// No description provided for @holidayTypeField.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get holidayTypeField;

  /// No description provided for @holidayScopeField.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get holidayScopeField;

  /// No description provided for @holidayWorkLocations.
  ///
  /// In en, this message translates to:
  /// **'Work locations'**
  String get holidayWorkLocations;

  /// No description provided for @holidayOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional holiday'**
  String get holidayOptional;

  /// No description provided for @holidayTypePublic.
  ///
  /// In en, this message translates to:
  /// **'Public holiday'**
  String get holidayTypePublic;

  /// No description provided for @holidayTypeCompany.
  ///
  /// In en, this message translates to:
  /// **'Company holiday'**
  String get holidayTypeCompany;

  /// No description provided for @holidayTypeOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional holiday'**
  String get holidayTypeOptional;

  /// No description provided for @holidayTypeSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special closure'**
  String get holidayTypeSpecial;

  /// No description provided for @holidayScopeCompanyWide.
  ///
  /// In en, this message translates to:
  /// **'Company wide'**
  String get holidayScopeCompanyWide;

  /// No description provided for @holidayScopeSpecific.
  ///
  /// In en, this message translates to:
  /// **'Specific work locations'**
  String get holidayScopeSpecific;

  /// No description provided for @leaveRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Request leave'**
  String get leaveRequestTitle;

  /// No description provided for @leaveStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get leaveStartDate;

  /// No description provided for @leaveEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get leaveEndDate;

  /// No description provided for @leaveStartPortion.
  ///
  /// In en, this message translates to:
  /// **'First day'**
  String get leaveStartPortion;

  /// No description provided for @leaveEndPortion.
  ///
  /// In en, this message translates to:
  /// **'Last day'**
  String get leaveEndPortion;

  /// No description provided for @leaveDayFull.
  ///
  /// In en, this message translates to:
  /// **'Full day'**
  String get leaveDayFull;

  /// No description provided for @leaveDayFirstHalf.
  ///
  /// In en, this message translates to:
  /// **'First half'**
  String get leaveDayFirstHalf;

  /// No description provided for @leaveDaySecondHalf.
  ///
  /// In en, this message translates to:
  /// **'Second half'**
  String get leaveDaySecondHalf;

  /// No description provided for @leaveReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get leaveReasonLabel;

  /// No description provided for @leaveAttachmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get leaveAttachmentLabel;

  /// No description provided for @leavePreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get leavePreviewTitle;

  /// No description provided for @leaveRequestedDays.
  ///
  /// In en, this message translates to:
  /// **'Requested days'**
  String get leaveRequestedDays;

  /// No description provided for @leaveAvailableDays.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get leaveAvailableDays;

  /// No description provided for @leaveAfterApproval.
  ///
  /// In en, this message translates to:
  /// **'After approval'**
  String get leaveAfterApproval;

  /// No description provided for @leaveExcludedWeekends.
  ///
  /// In en, this message translates to:
  /// **'Weekends excluded'**
  String get leaveExcludedWeekends;

  /// No description provided for @leaveExcludedHolidays.
  ///
  /// In en, this message translates to:
  /// **'Holidays excluded'**
  String get leaveExcludedHolidays;

  /// No description provided for @leaveSubmitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get leaveSubmitRequest;

  /// No description provided for @leaveNoTypes.
  ///
  /// In en, this message translates to:
  /// **'No leave types are available.'**
  String get leaveNoTypes;

  /// No description provided for @leaveSelectType.
  ///
  /// In en, this message translates to:
  /// **'Select leave type'**
  String get leaveSelectType;

  /// No description provided for @leaveStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get leaveStatusPending;

  /// No description provided for @leaveStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get leaveStatusApproved;

  /// No description provided for @leaveStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get leaveStatusRejected;

  /// No description provided for @leaveStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get leaveStatusCancelled;

  /// No description provided for @leaveApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get leaveApprove;

  /// No description provided for @leaveReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get leaveReject;

  /// No description provided for @leaveCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get leaveCancelRequest;

  /// No description provided for @leaveReviewNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get leaveReviewNote;

  /// No description provided for @leaveCancelReason.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason'**
  String get leaveCancelReason;

  /// No description provided for @leaveEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get leaveEmployee;

  /// No description provided for @leaveDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get leaveDepartment;

  /// No description provided for @leaveDateRange.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get leaveDateRange;

  /// No description provided for @leaveApprovedBy.
  ///
  /// In en, this message translates to:
  /// **'Reviewed by'**
  String get leaveApprovedBy;

  /// No description provided for @leaveSubmittedOn.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get leaveSubmittedOn;

  /// No description provided for @leaveViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get leaveViewDetails;

  /// No description provided for @leaveApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get leaveApply;

  /// No description provided for @leaveBalancesTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave balances'**
  String get leaveBalancesTitle;

  /// No description provided for @leaveEntitlement.
  ///
  /// In en, this message translates to:
  /// **'Entitlement'**
  String get leaveEntitlement;

  /// No description provided for @leaveUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get leaveUsed;

  /// No description provided for @leavePendingBalance.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get leavePendingBalance;

  /// No description provided for @leaveAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get leaveAvailable;

  /// No description provided for @leaveAdjustBalance.
  ///
  /// In en, this message translates to:
  /// **'Adjust balance'**
  String get leaveAdjustBalance;

  /// No description provided for @leaveAdjustAdd.
  ///
  /// In en, this message translates to:
  /// **'Add days'**
  String get leaveAdjustAdd;

  /// No description provided for @leaveAdjustRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove days'**
  String get leaveAdjustRemove;

  /// No description provided for @leaveAdjustQuantity.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get leaveAdjustQuantity;

  /// No description provided for @leaveAdjustReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get leaveAdjustReason;

  /// No description provided for @leaveLedger.
  ///
  /// In en, this message translates to:
  /// **'Balance history'**
  String get leaveLedger;

  /// No description provided for @leaveNoBalance.
  ///
  /// In en, this message translates to:
  /// **'No balance records.'**
  String get leaveNoBalance;

  /// No description provided for @leaveSelectEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get leaveSelectEmployee;

  /// No description provided for @leaveEmployeeFilter.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get leaveEmployeeFilter;

  /// No description provided for @leaveCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave calendar'**
  String get leaveCalendarTitle;

  /// No description provided for @leaveCalendarLegendLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveCalendarLegendLeave;

  /// No description provided for @leaveCalendarLegendHoliday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get leaveCalendarLegendHoliday;

  /// No description provided for @leaveCalendarEmpty.
  ///
  /// In en, this message translates to:
  /// **'No leave or holidays in this period.'**
  String get leaveCalendarEmpty;

  /// No description provided for @leaveFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get leaveFrom;

  /// No description provided for @leaveTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get leaveTo;

  /// No description provided for @leaveRequestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No leave requests.'**
  String get leaveRequestsEmpty;

  /// No description provided for @leaveApprovalsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No requests are waiting for review.'**
  String get leaveApprovalsEmpty;

  /// No description provided for @leaveNoPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'You have no pending leave requests.'**
  String get leaveNoPendingRequests;

  /// No description provided for @leaveOnLeaveToday.
  ///
  /// In en, this message translates to:
  /// **'On leave today'**
  String get leaveOnLeaveToday;

  /// No description provided for @workdayScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get workdayScheduled;

  /// No description provided for @workdayWorking.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get workdayWorking;

  /// No description provided for @workdayOnBreak.
  ///
  /// In en, this message translates to:
  /// **'On break'**
  String get workdayOnBreak;

  /// No description provided for @workdayCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get workdayCompleted;

  /// No description provided for @workdayIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get workdayIncomplete;

  /// No description provided for @workdayOnLeave.
  ///
  /// In en, this message translates to:
  /// **'On leave'**
  String get workdayOnLeave;

  /// No description provided for @workdayHoliday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get workdayHoliday;

  /// No description provided for @workdayNonWorking.
  ///
  /// In en, this message translates to:
  /// **'Non-working'**
  String get workdayNonWorking;

  /// No description provided for @workdayIssue.
  ///
  /// In en, this message translates to:
  /// **'Issue'**
  String get workdayIssue;

  /// No description provided for @leavePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have access to leave.'**
  String get leavePermissionDenied;

  /// No description provided for @leaveStorageError.
  ///
  /// In en, this message translates to:
  /// **'Leave data could not be loaded.'**
  String get leaveStorageError;

  /// No description provided for @leaveUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Leave is not available.'**
  String get leaveUnavailable;

  /// No description provided for @leaveTypeInactive.
  ///
  /// In en, this message translates to:
  /// **'The selected leave type is not available.'**
  String get leaveTypeInactive;

  /// No description provided for @leaveNoEmployee.
  ///
  /// In en, this message translates to:
  /// **'Your account is not linked to an employee.'**
  String get leaveNoEmployee;

  /// No description provided for @leaveInvalidDateRange.
  ///
  /// In en, this message translates to:
  /// **'The end date must be after the start date.'**
  String get leaveInvalidDateRange;

  /// No description provided for @leaveReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'A reason is required.'**
  String get leaveReasonRequired;

  /// No description provided for @leaveNoWorkingDays.
  ///
  /// In en, this message translates to:
  /// **'The selected range has no working days.'**
  String get leaveNoWorkingDays;

  /// No description provided for @leaveMinimumDays.
  ///
  /// In en, this message translates to:
  /// **'The request is shorter than the policy minimum.'**
  String get leaveMinimumDays;

  /// No description provided for @leaveOverlapping.
  ///
  /// In en, this message translates to:
  /// **'This request overlaps an existing request.'**
  String get leaveOverlapping;

  /// No description provided for @leaveInsufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'There is not enough leave balance.'**
  String get leaveInsufficientBalance;

  /// No description provided for @leavePastRequestNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Past-dated leave is not allowed.'**
  String get leavePastRequestNotAllowed;

  /// No description provided for @leaveAdvanceNoticeRequired.
  ///
  /// In en, this message translates to:
  /// **'This request does not meet the advance notice requirement.'**
  String get leaveAdvanceNoticeRequired;

  /// No description provided for @leaveInvalidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity.'**
  String get leaveInvalidQuantity;

  /// No description provided for @leaveRequestNotFound.
  ///
  /// In en, this message translates to:
  /// **'The leave request was not found.'**
  String get leaveRequestNotFound;

  /// No description provided for @leaveAlreadyReviewed.
  ///
  /// In en, this message translates to:
  /// **'This request has already been reviewed.'**
  String get leaveAlreadyReviewed;

  /// No description provided for @leaveCannotCancelApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved leave can only be cancelled by a manager.'**
  String get leaveCannotCancelApproved;

  /// No description provided for @leaveReviewNoteRequired.
  ///
  /// In en, this message translates to:
  /// **'A note is required.'**
  String get leaveReviewNoteRequired;

  /// No description provided for @leaveSelfApprovalNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'You cannot approve your own leave.'**
  String get leaveSelfApprovalNotAllowed;

  /// No description provided for @leaveSaved.
  ///
  /// In en, this message translates to:
  /// **'Leave saved.'**
  String get leaveSaved;

  /// No description provided for @leaveRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Leave request submitted.'**
  String get leaveRequestSubmitted;

  /// No description provided for @leaveIncludeInactive.
  ///
  /// In en, this message translates to:
  /// **'Include inactive'**
  String get leaveIncludeInactive;

  /// No description provided for @leaveUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get leaveUpcoming;

  /// No description provided for @leavePendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get leavePendingApproval;

  /// No description provided for @leaveApprovedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Approved this month'**
  String get leaveApprovedThisMonth;

  /// No description provided for @leaveTeamMembers.
  ///
  /// In en, this message translates to:
  /// **'Team members'**
  String get leaveTeamMembers;

  /// No description provided for @leaveNoEmployeesOnLeave.
  ///
  /// In en, this message translates to:
  /// **'No employees are on leave today.'**
  String get leaveNoEmployeesOnLeave;

  /// No description provided for @leaveNoUpcoming.
  ///
  /// In en, this message translates to:
  /// **'No upcoming leave.'**
  String get leaveNoUpcoming;

  /// No description provided for @leaveHalfDay.
  ///
  /// In en, this message translates to:
  /// **'Half day'**
  String get leaveHalfDay;

  /// No description provided for @leaveFullDay.
  ///
  /// In en, this message translates to:
  /// **'Full day'**
  String get leaveFullDay;

  /// No description provided for @leaveReturnDate.
  ///
  /// In en, this message translates to:
  /// **'Return date'**
  String get leaveReturnDate;

  /// No description provided for @leaveStatusField.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get leaveStatusField;

  /// No description provided for @leaveReviewRequest.
  ///
  /// In en, this message translates to:
  /// **'Review request'**
  String get leaveReviewRequest;

  /// No description provided for @leaveCompanyLeave.
  ///
  /// In en, this message translates to:
  /// **'Company leave'**
  String get leaveCompanyLeave;

  /// No description provided for @leaveApprovalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave approvals'**
  String get leaveApprovalsTitle;

  /// No description provided for @leaveApprovalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review employee leave requests that require your action.'**
  String get leaveApprovalsSubtitle;

  /// No description provided for @leaveTeamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View upcoming leave, team availability and leave requests.'**
  String get leaveTeamSubtitle;

  /// No description provided for @leaveAllSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor company leave, availability and leave requests.'**
  String get leaveAllSubtitle;

  /// No description provided for @leaveOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your leave, team availability and requests.'**
  String get leaveOverviewSubtitle;

  /// No description provided for @leavePendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending requests'**
  String get leavePendingRequests;

  /// No description provided for @leaveStartingSoon.
  ///
  /// In en, this message translates to:
  /// **'Starting soon'**
  String get leaveStartingSoon;

  /// No description provided for @leaveTeamRequests.
  ///
  /// In en, this message translates to:
  /// **'Team requests'**
  String get leaveTeamRequests;

  /// No description provided for @leaveCompanyRequests.
  ///
  /// In en, this message translates to:
  /// **'Company requests'**
  String get leaveCompanyRequests;

  /// No description provided for @leaveAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get leaveAvailableBalance;

  /// No description provided for @leaveBalanceAfterApproval.
  ///
  /// In en, this message translates to:
  /// **'Balance after approval'**
  String get leaveBalanceAfterApproval;

  /// No description provided for @leaveViewEmployeeLeave.
  ///
  /// In en, this message translates to:
  /// **'View employee leave'**
  String get leaveViewEmployeeLeave;

  /// No description provided for @leaveEmployeeLeave.
  ///
  /// In en, this message translates to:
  /// **'Employee leave'**
  String get leaveEmployeeLeave;

  /// No description provided for @leaveNoPendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'No requests need your approval.'**
  String get leaveNoPendingApprovals;

  /// No description provided for @leaveSearchEmployee.
  ///
  /// In en, this message translates to:
  /// **'Search employee'**
  String get leaveSearchEmployee;

  /// No description provided for @leavePeriodAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get leavePeriodAll;

  /// No description provided for @leavePeriodToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get leavePeriodToday;

  /// No description provided for @leavePeriodThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get leavePeriodThisWeek;

  /// No description provided for @leavePeriodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get leavePeriodThisMonth;

  /// No description provided for @leavePeriodNext30.
  ///
  /// In en, this message translates to:
  /// **'Next 30 days'**
  String get leavePeriodNext30;

  /// No description provided for @leavePeriodCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get leavePeriodCustom;

  /// No description provided for @leaveClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get leaveClearFilters;

  /// No description provided for @leaveActiveFilters.
  ///
  /// In en, this message translates to:
  /// **'Active filters'**
  String get leaveActiveFilters;

  /// No description provided for @leaveManageSettings.
  ///
  /// In en, this message translates to:
  /// **'Manage leave settings'**
  String get leaveManageSettings;

  /// No description provided for @leaveViewAllLeave.
  ///
  /// In en, this message translates to:
  /// **'View all leave'**
  String get leaveViewAllLeave;

  /// No description provided for @leaveReviewQueue.
  ///
  /// In en, this message translates to:
  /// **'Review queue'**
  String get leaveReviewQueue;

  /// No description provided for @leaveNoBalanceForFilters.
  ///
  /// In en, this message translates to:
  /// **'No leave balance found for selected filters.'**
  String get leaveNoBalanceForFilters;

  /// No description provided for @leaveRequestSection.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get leaveRequestSection;

  /// No description provided for @leaveEmployeeSection.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get leaveEmployeeSection;

  /// No description provided for @leaveBalanceSection.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get leaveBalanceSection;

  /// No description provided for @leaveDecisionSection.
  ///
  /// In en, this message translates to:
  /// **'Decision'**
  String get leaveDecisionSection;

  /// No description provided for @leaveWorkingDays.
  ///
  /// In en, this message translates to:
  /// **'Working leave days'**
  String get leaveWorkingDays;

  /// No description provided for @leavePortion.
  ///
  /// In en, this message translates to:
  /// **'Portion'**
  String get leavePortion;

  /// No description provided for @leaveStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get leaveStart;

  /// No description provided for @leaveReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get leaveReturn;

  /// No description provided for @leaveOnLeave.
  ///
  /// In en, this message translates to:
  /// **'On leave'**
  String get leaveOnLeave;

  /// No description provided for @leaveUpcomingHoliday.
  ///
  /// In en, this message translates to:
  /// **'Upcoming holiday'**
  String get leaveUpcomingHoliday;

  /// No description provided for @leaveUpcomingTeamLeave.
  ///
  /// In en, this message translates to:
  /// **'Upcoming team leave'**
  String get leaveUpcomingTeamLeave;

  /// No description provided for @leavePendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'Pending approvals'**
  String get leavePendingApprovals;

  /// No description provided for @leaveMyLeaveOverview.
  ///
  /// In en, this message translates to:
  /// **'My leave'**
  String get leaveMyLeaveOverview;

  /// No description provided for @leaveTeamOverview.
  ///
  /// In en, this message translates to:
  /// **'Team leave'**
  String get leaveTeamOverview;

  /// No description provided for @leaveCompanyOverview.
  ///
  /// In en, this message translates to:
  /// **'Company leave'**
  String get leaveCompanyOverview;

  /// No description provided for @leaveEmployeeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This employee\'s leave information is unavailable.'**
  String get leaveEmployeeUnavailable;

  /// No description provided for @leaveScopeDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have access to this leave scope.'**
  String get leaveScopeDenied;

  /// No description provided for @leaveRecentRequests.
  ///
  /// In en, this message translates to:
  /// **'Recent requests'**
  String get leaveRecentRequests;

  /// No description provided for @leaveBalanceLedger.
  ///
  /// In en, this message translates to:
  /// **'Balance history'**
  String get leaveBalanceLedger;

  /// No description provided for @leaveAdjustmentAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to balance'**
  String get leaveAdjustmentAdded;

  /// No description provided for @leaveAdjustmentDeducted.
  ///
  /// In en, this message translates to:
  /// **'Deducted from balance'**
  String get leaveAdjustmentDeducted;

  /// No description provided for @leaveEffectiveDate.
  ///
  /// In en, this message translates to:
  /// **'Effective date'**
  String get leaveEffectiveDate;

  /// No description provided for @leaveCurrentAvailable.
  ///
  /// In en, this message translates to:
  /// **'Current available'**
  String get leaveCurrentAvailable;

  /// No description provided for @leavePreviewNewAvailable.
  ///
  /// In en, this message translates to:
  /// **'New available balance'**
  String get leavePreviewNewAvailable;

  /// No description provided for @leaveNoTeam.
  ///
  /// In en, this message translates to:
  /// **'No team is available for this account.'**
  String get leaveNoTeam;

  /// No description provided for @leaveApprovalsEmptyQueue.
  ///
  /// In en, this message translates to:
  /// **'You have no requests waiting for review.'**
  String get leaveApprovalsEmptyQueue;

  /// No description provided for @leaveRequestedPeriod.
  ///
  /// In en, this message translates to:
  /// **'Requested period'**
  String get leaveRequestedPeriod;

  /// No description provided for @holidayTypeFestival.
  ///
  /// In en, this message translates to:
  /// **'Festival holiday'**
  String get holidayTypeFestival;

  /// No description provided for @holidayTypeRegional.
  ///
  /// In en, this message translates to:
  /// **'Regional holiday'**
  String get holidayTypeRegional;

  /// No description provided for @holidaySourceManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get holidaySourceManual;

  /// No description provided for @holidaySourceCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied from previous year'**
  String get holidaySourceCopied;

  /// No description provided for @holidaySourceImported.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get holidaySourceImported;

  /// No description provided for @holidaySourceTemplate.
  ///
  /// In en, this message translates to:
  /// **'Company template'**
  String get holidaySourceTemplate;

  /// No description provided for @holidayCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Holiday calendar'**
  String get holidayCalendarTitle;

  /// No description provided for @holidayCalendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage public, festival, regional and company holidays.'**
  String get holidayCalendarSubtitle;

  /// No description provided for @holidayYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Holiday year'**
  String get holidayYearLabel;

  /// No description provided for @addHoliday.
  ///
  /// In en, this message translates to:
  /// **'Add holiday'**
  String get addHoliday;

  /// No description provided for @editHoliday.
  ///
  /// In en, this message translates to:
  /// **'Edit holiday'**
  String get editHoliday;

  /// No description provided for @manageHolidays.
  ///
  /// In en, this message translates to:
  /// **'Manage holidays'**
  String get manageHolidays;

  /// No description provided for @copyPreviousYear.
  ///
  /// In en, this message translates to:
  /// **'Copy previous year'**
  String get copyPreviousYear;

  /// No description provided for @importHolidays.
  ///
  /// In en, this message translates to:
  /// **'Import holidays'**
  String get importHolidays;

  /// No description provided for @setUpHolidayCalendar.
  ///
  /// In en, this message translates to:
  /// **'Set up holiday calendar'**
  String get setUpHolidayCalendar;

  /// No description provided for @startBlank.
  ///
  /// In en, this message translates to:
  /// **'Start blank'**
  String get startBlank;

  /// No description provided for @holidayCalendarStatus.
  ///
  /// In en, this message translates to:
  /// **'Holiday calendar status'**
  String get holidayCalendarStatus;

  /// No description provided for @activeHolidays.
  ///
  /// In en, this message translates to:
  /// **'Active holidays'**
  String get activeHolidays;

  /// No description provided for @nextHoliday.
  ///
  /// In en, this message translates to:
  /// **'Next holiday'**
  String get nextHoliday;

  /// No description provided for @holidayNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get holidayNotConfigured;

  /// No description provided for @noHolidaysConfigured.
  ///
  /// In en, this message translates to:
  /// **'No holidays configured for this year.'**
  String get noHolidaysConfigured;

  /// No description provided for @holidayPublishedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No company holidays have been published for this period.'**
  String get holidayPublishedEmpty;

  /// No description provided for @applyTo.
  ///
  /// In en, this message translates to:
  /// **'Applies to'**
  String get applyTo;

  /// No description provided for @holidayMultiDay.
  ///
  /// In en, this message translates to:
  /// **'Multi-day holiday'**
  String get holidayMultiDay;

  /// No description provided for @holidayBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get holidayBasicInfo;

  /// No description provided for @holidayApplicability.
  ///
  /// In en, this message translates to:
  /// **'Applicability'**
  String get holidayApplicability;

  /// No description provided for @holidayOptionality.
  ///
  /// In en, this message translates to:
  /// **'Optionality'**
  String get holidayOptionality;

  /// No description provided for @holidaySourceField.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get holidaySourceField;

  /// No description provided for @holidayDuplicateWarning.
  ///
  /// In en, this message translates to:
  /// **'A holiday with the same name, date and scope already exists.'**
  String get holidayDuplicateWarning;

  /// No description provided for @holidayImportPreview.
  ///
  /// In en, this message translates to:
  /// **'Import preview'**
  String get holidayImportPreview;

  /// No description provided for @holidayImportPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste CSV'**
  String get holidayImportPaste;

  /// No description provided for @holidayImportHint.
  ///
  /// In en, this message translates to:
  /// **'Columns: name, date, endDate, type, optional, scope, workLocations, description'**
  String get holidayImportHint;

  /// No description provided for @holidayImportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get holidayImportConfirm;

  /// No description provided for @holidayImportImported.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get holidayImportImported;

  /// No description provided for @holidayImportSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get holidayImportSkipped;

  /// No description provided for @holidayCopyNote.
  ///
  /// In en, this message translates to:
  /// **'Copied entries keep their month and day — verify festival dates before confirming.'**
  String get holidayCopyNote;

  /// No description provided for @verifyFestivalDates.
  ///
  /// In en, this message translates to:
  /// **'Copied from previous year — verify festival dates.'**
  String get verifyFestivalDates;

  /// No description provided for @holidaySelectLocations.
  ///
  /// In en, this message translates to:
  /// **'Select work locations'**
  String get holidaySelectLocations;

  /// No description provided for @holidaySearchLocations.
  ///
  /// In en, this message translates to:
  /// **'Search work locations'**
  String get holidaySearchLocations;

  /// No description provided for @holidayTypeHelperPublic.
  ///
  /// In en, this message translates to:
  /// **'Government/public holidays'**
  String get holidayTypeHelperPublic;

  /// No description provided for @holidayTypeHelperFestival.
  ///
  /// In en, this message translates to:
  /// **'Religious or festival holidays'**
  String get holidayTypeHelperFestival;

  /// No description provided for @holidayTypeHelperRegional.
  ///
  /// In en, this message translates to:
  /// **'State/regional holidays'**
  String get holidayTypeHelperRegional;

  /// No description provided for @holidayTypeHelperCompany.
  ///
  /// In en, this message translates to:
  /// **'Company-declared holidays'**
  String get holidayTypeHelperCompany;

  /// No description provided for @holidayTypeHelperClosure.
  ///
  /// In en, this message translates to:
  /// **'Special closures and shutdowns'**
  String get holidayTypeHelperClosure;

  /// No description provided for @nextHolidayDaysAway.
  ///
  /// In en, this message translates to:
  /// **'days away'**
  String get nextHolidayDaysAway;

  /// No description provided for @upcomingLeave.
  ///
  /// In en, this message translates to:
  /// **'Upcoming leave'**
  String get upcomingLeave;

  /// No description provided for @pendingRequest.
  ///
  /// In en, this message translates to:
  /// **'Pending request'**
  String get pendingRequest;

  /// No description provided for @teamCalendar.
  ///
  /// In en, this message translates to:
  /// **'Team calendar'**
  String get teamCalendar;

  /// No description provided for @reviewRequests.
  ///
  /// In en, this message translates to:
  /// **'Review requests'**
  String get reviewRequests;

  /// No description provided for @viewRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get viewRequests;

  /// No description provided for @viewUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get viewUpcoming;

  /// No description provided for @viewToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get viewToday;

  /// No description provided for @selectedDay.
  ///
  /// In en, this message translates to:
  /// **'Selected day'**
  String get selectedDay;

  /// No description provided for @dayAgenda.
  ///
  /// In en, this message translates to:
  /// **'Agenda'**
  String get dayAgenda;

  /// No description provided for @noEventsOnDay.
  ///
  /// In en, this message translates to:
  /// **'No leave or holidays on this day.'**
  String get noEventsOnDay;

  /// No description provided for @leaveAndHolidayCalendar.
  ///
  /// In en, this message translates to:
  /// **'Leave & holiday calendar'**
  String get leaveAndHolidayCalendar;

  /// No description provided for @leaveViewMode.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get leaveViewMode;

  /// No description provided for @leaveBalanceAvailableLabel.
  ///
  /// In en, this message translates to:
  /// **'available'**
  String get leaveBalanceAvailableLabel;

  /// No description provided for @leaveBalanceUsedLabel.
  ///
  /// In en, this message translates to:
  /// **'used'**
  String get leaveBalanceUsedLabel;

  /// No description provided for @leaveBalancePendingLabel.
  ///
  /// In en, this message translates to:
  /// **'pending'**
  String get leaveBalancePendingLabel;

  /// No description provided for @leaveBalanceEntitlementLabel.
  ///
  /// In en, this message translates to:
  /// **'entitlement'**
  String get leaveBalanceEntitlementLabel;

  /// No description provided for @leaveHolidayThisYear.
  ///
  /// In en, this message translates to:
  /// **'Holidays this year'**
  String get leaveHolidayThisYear;

  /// No description provided for @leaveManageHolidaysHint.
  ///
  /// In en, this message translates to:
  /// **'Manage the company\'s annual public, festival and company holiday calendar.'**
  String get leaveManageHolidaysHint;

  /// No description provided for @leaveSearchOrFilter.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get leaveSearchOrFilter;

  /// No description provided for @leaveAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get leaveAllTypes;

  /// No description provided for @leaveAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get leaveAllStatuses;

  /// No description provided for @leaveAllPeriods.
  ///
  /// In en, this message translates to:
  /// **'All periods'**
  String get leaveAllPeriods;

  /// No description provided for @leaveDayOne.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get leaveDayOne;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
