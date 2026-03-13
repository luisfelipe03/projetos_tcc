import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit Flow'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @onboardingBadgeStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get onboardingBadgeStudy;

  /// No description provided for @onboardingBadgeHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get onboardingBadgeHealth;

  /// No description provided for @onboardingTitleStart.
  ///
  /// In en, this message translates to:
  /// **'Master Your\n'**
  String get onboardingTitleStart;

  /// No description provided for @onboardingTitleAccent.
  ///
  /// In en, this message translates to:
  /// **'Routine.'**
  String get onboardingTitleAccent;

  /// No description provided for @onboardingDescription.
  ///
  /// In en, this message translates to:
  /// **'Build lasting habits and track your progress with our vibrant student-focused platform.'**
  String get onboardingDescription;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingExistingAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get onboardingExistingAccount;

  /// No description provided for @onboardingFooterStudents.
  ///
  /// In en, this message translates to:
  /// **'JOIN 10K+ STUDENTS TODAY'**
  String get onboardingFooterStudents;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get authWelcomeBack;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s continue your habit journey'**
  String get authWelcomeSubtitle;

  /// No description provided for @authCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start building your habits today'**
  String get authCreateSubtitle;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authForgotPassword;

  /// No description provided for @authForgotPasswordSoon.
  ///
  /// In en, this message translates to:
  /// **'Password recovery will be available soon.'**
  String get authForgotPasswordSoon;

  /// No description provided for @authOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get authOrContinueWith;

  /// No description provided for @authTabLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authTabLogin;

  /// No description provided for @authTabSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authTabSignUp;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'student@example.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get authLoginButton;

  /// No description provided for @authSignUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUpButton;

  /// No description provided for @authGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get authGoogleButton;

  /// No description provided for @authTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get authTermsPrefix;

  /// No description provided for @authTermsService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get authTermsService;

  /// No description provided for @authTermsAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get authTermsAnd;

  /// No description provided for @authTermsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authTermsPrivacy;

  /// No description provided for @authTermsSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get authTermsSuffix;

  /// No description provided for @authAccountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get authAccountCreatedSuccess;

  /// No description provided for @authWelcomeBackSuccess.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get authWelcomeBackSuccess;

  /// No description provided for @authGoogleSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully signed in with Google!'**
  String get authGoogleSuccess;

  /// No description provided for @authErrorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get authErrorEmailRequired;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get authErrorPasswordRequired;

  /// No description provided for @authErrorPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authErrorPasswordMinLength;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for this email'**
  String get authErrorEmailAlreadyInUse;

  /// No description provided for @authErrorOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This sign-in method is not enabled'**
  String get authErrorOperationNotAllowed;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found for this email'**
  String get authErrorUserNotFound;

  /// No description provided for @authErrorUserNotFoundCredential.
  ///
  /// In en, this message translates to:
  /// **'No user found with this credential'**
  String get authErrorUserNotFoundCredential;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This user account has been disabled'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get authErrorInvalidCredential;

  /// No description provided for @authErrorAccountExistsDifferentCredential.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with the same email but different sign-in credentials'**
  String get authErrorAccountExistsDifferentCredential;

  /// No description provided for @authErrorGoogleCredentialMalformed.
  ///
  /// In en, this message translates to:
  /// **'The Google credential is malformed or has expired'**
  String get authErrorGoogleCredentialMalformed;

  /// No description provided for @authErrorGoogleDisabled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not enabled'**
  String get authErrorGoogleDisabled;

  /// No description provided for @authErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get authErrorUnexpected;

  /// No description provided for @homeUserFallback.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get homeUserFallback;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String homeGreeting(Object name);

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No habits yet'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to create your first habit'**
  String get homeEmptySubtitle;

  /// No description provided for @homeEditHabit.
  ///
  /// In en, this message translates to:
  /// **'Edit Habit'**
  String get homeEditHabit;

  /// No description provided for @homeDeleteHabit.
  ///
  /// In en, this message translates to:
  /// **'Delete Habit'**
  String get homeDeleteHabit;

  /// No description provided for @homeHabitDeleted.
  ///
  /// In en, this message translates to:
  /// **'Habit deleted'**
  String get homeHabitDeleted;

  /// No description provided for @homeDeleteHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Habit'**
  String get homeDeleteHabitTitle;

  /// No description provided for @homeDeleteHabitMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this habit?'**
  String get homeDeleteHabitMessage;

  /// No description provided for @dailyProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Progress'**
  String get dailyProgressTitle;

  /// No description provided for @dailyProgressSummary.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} habits completed'**
  String dailyProgressSummary(int completed, int total);

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statsRangeLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get statsRangeLast7Days;

  /// No description provided for @statsRangeLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get statsRangeLast30Days;

  /// No description provided for @statsRangeLast90Days.
  ///
  /// In en, this message translates to:
  /// **'Last 90 Days'**
  String get statsRangeLast90Days;

  /// No description provided for @statsCompletion.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get statsCompletion;

  /// No description provided for @statsBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get statsBestStreak;

  /// No description provided for @statsCheckIns.
  ///
  /// In en, this message translates to:
  /// **'Check-ins'**
  String get statsCheckIns;

  /// No description provided for @statsVsPreviousPeriod.
  ///
  /// In en, this message translates to:
  /// **'{delta}% vs previous period'**
  String statsVsPreviousPeriod(Object delta);

  /// No description provided for @statsDaysInRow.
  ///
  /// In en, this message translates to:
  /// **'{days} days in a row'**
  String statsDaysInRow(int days);

  /// No description provided for @statsHabitsTracked.
  ///
  /// In en, this message translates to:
  /// **'{count} habits tracked'**
  String statsHabitsTracked(int count);

  /// No description provided for @statsCategoryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Category Breakdown'**
  String get statsCategoryBreakdown;

  /// No description provided for @statsWeeklyAvg.
  ///
  /// In en, this message translates to:
  /// **'Weekly Avg'**
  String get statsWeeklyAvg;

  /// No description provided for @statsNoCategoryData.
  ///
  /// In en, this message translates to:
  /// **'No category data for this period'**
  String get statsNoCategoryData;

  /// No description provided for @statsTopPerforming.
  ///
  /// In en, this message translates to:
  /// **'Top Performing'**
  String get statsTopPerforming;

  /// No description provided for @statsViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get statsViewAll;

  /// No description provided for @statsTopPerformingEmpty.
  ///
  /// In en, this message translates to:
  /// **'Complete your first habit to see performance insights.'**
  String get statsTopPerformingEmpty;

  /// No description provided for @statsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No habits yet'**
  String get statsEmptyTitle;

  /// No description provided for @statsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create habits to unlock your performance stats and trend charts.'**
  String get statsEmptySubtitle;

  /// No description provided for @statsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load statistics'**
  String get statsErrorTitle;

  /// No description provided for @statsErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pull down to try again.'**
  String get statsErrorSubtitle;

  /// No description provided for @statsTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get statsTryAgain;

  /// No description provided for @statsCategoryStreak.
  ///
  /// In en, this message translates to:
  /// **'{category} • {days} day streak'**
  String statsCategoryStreak(Object category, int days);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get settingsAccount;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @settingsProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your personal details'**
  String get settingsProfileSubtitle;

  /// No description provided for @settingsProfileSoon.
  ///
  /// In en, this message translates to:
  /// **'Profile screen coming soon'**
  String get settingsProfileSoon;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get settingsPreferences;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications to receive reminders for your habits.'**
  String get settingsNotificationsDescription;

  /// No description provided for @settingsEnableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get settingsEnableNotifications;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get settingsSupport;

  /// No description provided for @settingsDevelopment.
  ///
  /// In en, this message translates to:
  /// **'DEVELOPMENT'**
  String get settingsDevelopment;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutContent.
  ///
  /// In en, this message translates to:
  /// **'Habit Flow\nVersion 2.4.0'**
  String get settingsAboutContent;

  /// No description provided for @settingsHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get settingsHelpSupport;

  /// No description provided for @settingsHelpSoon.
  ///
  /// In en, this message translates to:
  /// **'Help center coming soon'**
  String get settingsHelpSoon;

  /// No description provided for @settingsSeedDatabase.
  ///
  /// In en, this message translates to:
  /// **'Populate Test Data'**
  String get settingsSeedDatabase;

  /// No description provided for @settingsSeedDatabaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create fake habits and completion history'**
  String get settingsSeedDatabaseSubtitle;

  /// No description provided for @settingsSeederInProgress.
  ///
  /// In en, this message translates to:
  /// **'Creating fake data...'**
  String get settingsSeederInProgress;

  /// No description provided for @settingsSeederSuccess.
  ///
  /// In en, this message translates to:
  /// **'{habits} habits and {completions} completions created'**
  String settingsSeederSuccess(int habits, int completions);

  /// No description provided for @settingsSeederFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create fake data'**
  String get settingsSeederFailed;

  /// No description provided for @settingsChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get settingsChooseLanguage;

  /// No description provided for @settingsLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get settingsLogOut;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get settingsLogoutConfirm;

  /// No description provided for @habitFormTitleCreate.
  ///
  /// In en, this message translates to:
  /// **'New Habit'**
  String get habitFormTitleCreate;

  /// No description provided for @habitFormTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Habit'**
  String get habitFormTitleEdit;

  /// No description provided for @habitFormSectionName.
  ///
  /// In en, this message translates to:
  /// **'HABIT NAME'**
  String get habitFormSectionName;

  /// No description provided for @habitFormSectionFrequency.
  ///
  /// In en, this message translates to:
  /// **'FREQUENCY'**
  String get habitFormSectionFrequency;

  /// No description provided for @habitFormSectionCategory.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get habitFormSectionCategory;

  /// No description provided for @habitFormSectionReminder.
  ///
  /// In en, this message translates to:
  /// **'REMINDER'**
  String get habitFormSectionReminder;

  /// No description provided for @habitFormSectionColor.
  ///
  /// In en, this message translates to:
  /// **'HABIT COLOR'**
  String get habitFormSectionColor;

  /// No description provided for @habitFormNameHint.
  ///
  /// In en, this message translates to:
  /// **'Morning Yoga'**
  String get habitFormNameHint;

  /// No description provided for @habitFormNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a habit name'**
  String get habitFormNameRequired;

  /// No description provided for @habitFormRepeatOn.
  ///
  /// In en, this message translates to:
  /// **'Repeat on'**
  String get habitFormRepeatOn;

  /// No description provided for @habitFormWeeklyDaysPrompt.
  ///
  /// In en, this message translates to:
  /// **'Which days should this habit be done?'**
  String get habitFormWeeklyDaysPrompt;

  /// No description provided for @habitFormSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save Habit'**
  String get habitFormSaveAction;

  /// No description provided for @habitFormUpdateAction.
  ///
  /// In en, this message translates to:
  /// **'Update Habit'**
  String get habitFormUpdateAction;

  /// No description provided for @habitFormCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Habit created successfully!'**
  String get habitFormCreatedSuccess;

  /// No description provided for @habitFormUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Habit updated successfully!'**
  String get habitFormUpdatedSuccess;

  /// No description provided for @habitFormWeeklyReminderDaysError.
  ///
  /// In en, this message translates to:
  /// **'Select at least one day for weekly reminders'**
  String get habitFormWeeklyReminderDaysError;

  /// No description provided for @habitFormCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create habit'**
  String get habitFormCreateFailed;

  /// No description provided for @habitFormUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update habit'**
  String get habitFormUpdateFailed;

  /// No description provided for @habitErrorUnauthenticated.
  ///
  /// In en, this message translates to:
  /// **'You need to be signed in to manage habits'**
  String get habitErrorUnauthenticated;

  /// No description provided for @habitErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Habit not found'**
  String get habitErrorNotFound;

  /// No description provided for @habitDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'HABIT DETAILS'**
  String get habitDetailsTitle;

  /// No description provided for @habitDetailsCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'CURRENT STREAK'**
  String get habitDetailsCurrentStreak;

  /// No description provided for @habitDetailsStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 Day} other{{days} Days}}'**
  String habitDetailsStreakDays(int days);

  /// No description provided for @habitDetailsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get habitDetailsThisWeek;

  /// No description provided for @habitDetailsMonthlyOverview.
  ///
  /// In en, this message translates to:
  /// **'Monthly Overview'**
  String get habitDetailsMonthlyOverview;

  /// No description provided for @habitDetailsCompletionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get habitDetailsCompletionRate;

  /// No description provided for @habitDetailsTotalDays.
  ///
  /// In en, this message translates to:
  /// **'TOTAL DAYS'**
  String get habitDetailsTotalDays;

  /// No description provided for @languageOptionEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageOptionEnglish;

  /// No description provided for @languageOptionPortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languageOptionPortuguese;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get categoryPersonal;

  /// No description provided for @categoryStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get categoryStudy;

  /// No description provided for @categorySocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get categorySocial;

  /// No description provided for @categoryFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get categoryFinance;

  /// No description provided for @frequencyDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get frequencyDaily;

  /// No description provided for @frequencyWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get frequencyWeekly;

  /// No description provided for @frequencyMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get frequencyMonthly;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @dayShortMonday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayShortMonday;

  /// No description provided for @dayShortTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayShortTuesday;

  /// No description provided for @dayShortWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayShortWednesday;

  /// No description provided for @dayShortThursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayShortThursday;

  /// No description provided for @dayShortFriday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayShortFriday;

  /// No description provided for @dayShortSaturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get dayShortSaturday;

  /// No description provided for @dayShortSunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get dayShortSunday;
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
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
