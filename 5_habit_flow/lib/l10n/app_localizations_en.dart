// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Habit Flow';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonOk => 'OK';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonToday => 'Today';

  @override
  String get navHome => 'Home';

  @override
  String get navStats => 'Stats';

  @override
  String get navSettings => 'Settings';

  @override
  String get onboardingBadgeStudy => 'Study';

  @override
  String get onboardingBadgeHealth => 'Health';

  @override
  String get onboardingTitleStart => 'Master Your\n';

  @override
  String get onboardingTitleAccent => 'Routine.';

  @override
  String get onboardingDescription =>
      'Build lasting habits and track your progress with our vibrant student-focused platform.';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingExistingAccount => 'I already have an account';

  @override
  String get onboardingFooterStudents => 'JOIN 10K+ STUDENTS TODAY';

  @override
  String get authWelcomeBack => 'Welcome Back';

  @override
  String get authCreateAccount => 'Create Account';

  @override
  String get authWelcomeSubtitle => 'Let\'s continue your habit journey';

  @override
  String get authCreateSubtitle => 'Start building your habits today';

  @override
  String get authForgotPassword => 'Forgot Password?';

  @override
  String get authForgotPasswordSoon =>
      'Password recovery will be available soon.';

  @override
  String get authOrContinueWith => 'Or continue with';

  @override
  String get authTabLogin => 'Login';

  @override
  String get authTabSignUp => 'Sign Up';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'student@example.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authLoginButton => 'Log In';

  @override
  String get authSignUpButton => 'Sign Up';

  @override
  String get authGoogleButton => 'Google';

  @override
  String get authTermsPrefix => 'By continuing, you agree to our ';

  @override
  String get authTermsService => 'Terms of Service';

  @override
  String get authTermsAnd => ' and ';

  @override
  String get authTermsPrivacy => 'Privacy Policy';

  @override
  String get authTermsSuffix => '.';

  @override
  String get authAccountCreatedSuccess => 'Account created successfully!';

  @override
  String get authWelcomeBackSuccess => 'Welcome back!';

  @override
  String get authGoogleSuccess => 'Successfully signed in with Google!';

  @override
  String get authErrorEmailRequired => 'Email is required';

  @override
  String get authErrorInvalidEmail => 'Enter a valid email';

  @override
  String get authErrorPasswordRequired => 'Password is required';

  @override
  String get authErrorPasswordMinLength =>
      'Password must be at least 6 characters';

  @override
  String get authErrorWeakPassword => 'The password is too weak';

  @override
  String get authErrorEmailAlreadyInUse =>
      'An account already exists for this email';

  @override
  String get authErrorOperationNotAllowed =>
      'This sign-in method is not enabled';

  @override
  String get authErrorUserNotFound => 'No user found for this email';

  @override
  String get authErrorUserNotFoundCredential =>
      'No user found with this credential';

  @override
  String get authErrorWrongPassword => 'Wrong password';

  @override
  String get authErrorUserDisabled => 'This user account has been disabled';

  @override
  String get authErrorInvalidCredential => 'Invalid email or password';

  @override
  String get authErrorAccountExistsDifferentCredential =>
      'An account already exists with the same email but different sign-in credentials';

  @override
  String get authErrorGoogleCredentialMalformed =>
      'The Google credential is malformed or has expired';

  @override
  String get authErrorGoogleDisabled => 'Google sign-in is not enabled';

  @override
  String get authErrorUnexpected =>
      'An unexpected error occurred. Please try again.';

  @override
  String get homeUserFallback => 'User';

  @override
  String homeGreeting(Object name) {
    return 'Hi, $name';
  }

  @override
  String get homeEmptyTitle => 'No habits yet';

  @override
  String get homeEmptySubtitle => 'Tap the + button to create your first habit';

  @override
  String get homeEditHabit => 'Edit Habit';

  @override
  String get homeDeleteHabit => 'Delete Habit';

  @override
  String get homeHabitDeleted => 'Habit deleted';

  @override
  String get homeDeleteHabitTitle => 'Delete Habit';

  @override
  String get homeDeleteHabitMessage =>
      'Are you sure you want to delete this habit?';

  @override
  String get dailyProgressTitle => 'Daily Progress';

  @override
  String dailyProgressSummary(int completed, int total) {
    return '$completed of $total habits completed';
  }

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsRangeLast7Days => 'Last 7 Days';

  @override
  String get statsRangeLast30Days => 'Last 30 Days';

  @override
  String get statsRangeLast90Days => 'Last 90 Days';

  @override
  String get statsCompletion => 'Completion';

  @override
  String get statsBestStreak => 'Best Streak';

  @override
  String get statsCheckIns => 'Check-ins';

  @override
  String statsVsPreviousPeriod(Object delta) {
    return '$delta% vs previous period';
  }

  @override
  String statsDaysInRow(int days) {
    return '$days days in a row';
  }

  @override
  String statsHabitsTracked(int count) {
    return '$count habits tracked';
  }

  @override
  String get statsCategoryBreakdown => 'Category Breakdown';

  @override
  String get statsWeeklyAvg => 'Weekly Avg';

  @override
  String get statsNoCategoryData => 'No category data for this period';

  @override
  String get statsTopPerforming => 'Top Performing';

  @override
  String get statsViewAll => 'View All';

  @override
  String get statsTopPerformingEmpty =>
      'Complete your first habit to see performance insights.';

  @override
  String get statsEmptyTitle => 'No habits yet';

  @override
  String get statsEmptySubtitle =>
      'Create habits to unlock your performance stats and trend charts.';

  @override
  String get statsErrorTitle => 'Could not load statistics';

  @override
  String get statsErrorSubtitle => 'Pull down to try again.';

  @override
  String get statsTryAgain => 'Try Again';

  @override
  String statsCategoryStreak(Object category, int days) {
    return '$category • $days day streak';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'ACCOUNT';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsProfileSubtitle => 'Manage your personal details';

  @override
  String get settingsProfileSoon => 'Profile screen coming soon';

  @override
  String get settingsPreferences => 'PREFERENCES';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsDescription =>
      'Enable notifications to receive reminders for your habits.';

  @override
  String get settingsEnableNotifications => 'Enable notifications';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSupport => 'SUPPORT';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutContent => 'Habit Flow\nVersion 2.4.0';

  @override
  String get settingsHelpSupport => 'Help & Support';

  @override
  String get settingsHelpSoon => 'Help center coming soon';

  @override
  String get settingsChooseLanguage => 'Choose language';

  @override
  String get settingsLogOut => 'Log Out';

  @override
  String get settingsLogoutConfirm => 'Are you sure you want to log out?';

  @override
  String get habitFormTitleCreate => 'New Habit';

  @override
  String get habitFormTitleEdit => 'Edit Habit';

  @override
  String get habitFormSectionName => 'HABIT NAME';

  @override
  String get habitFormSectionFrequency => 'FREQUENCY';

  @override
  String get habitFormSectionCategory => 'CATEGORY';

  @override
  String get habitFormSectionReminder => 'REMINDER';

  @override
  String get habitFormSectionColor => 'HABIT COLOR';

  @override
  String get habitFormNameHint => 'Morning Yoga';

  @override
  String get habitFormNameRequired => 'Please enter a habit name';

  @override
  String get habitFormRepeatOn => 'Repeat on';

  @override
  String get habitFormWeeklyDaysPrompt =>
      'Which days should this habit be done?';

  @override
  String get habitFormSaveAction => 'Save Habit';

  @override
  String get habitFormUpdateAction => 'Update Habit';

  @override
  String get habitFormCreatedSuccess => 'Habit created successfully!';

  @override
  String get habitFormUpdatedSuccess => 'Habit updated successfully!';

  @override
  String get habitFormWeeklyReminderDaysError =>
      'Select at least one day for weekly reminders';

  @override
  String get habitFormCreateFailed => 'Failed to create habit';

  @override
  String get habitFormUpdateFailed => 'Failed to update habit';

  @override
  String get habitErrorUnauthenticated =>
      'You need to be signed in to manage habits';

  @override
  String get habitErrorNotFound => 'Habit not found';

  @override
  String get habitDetailsTitle => 'HABIT DETAILS';

  @override
  String get habitDetailsCurrentStreak => 'CURRENT STREAK';

  @override
  String habitDetailsStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Days',
      one: '1 Day',
    );
    return '$_temp0';
  }

  @override
  String get habitDetailsThisWeek => 'This Week';

  @override
  String get habitDetailsMonthlyOverview => 'Monthly Overview';

  @override
  String get habitDetailsCompletionRate => 'Completion Rate';

  @override
  String get habitDetailsTotalDays => 'TOTAL DAYS';

  @override
  String get languageOptionEnglish => 'English';

  @override
  String get languageOptionPortuguese => 'Portuguese';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryPersonal => 'Personal';

  @override
  String get categoryStudy => 'Study';

  @override
  String get categorySocial => 'Social';

  @override
  String get categoryFinance => 'Finance';

  @override
  String get frequencyDaily => 'Daily';

  @override
  String get frequencyWeekly => 'Weekly';

  @override
  String get frequencyMonthly => 'Monthly';

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayWednesday => 'Wednesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get dayFriday => 'Friday';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get daySunday => 'Sunday';

  @override
  String get dayShortMonday => 'Mon';

  @override
  String get dayShortTuesday => 'Tue';

  @override
  String get dayShortWednesday => 'Wed';

  @override
  String get dayShortThursday => 'Thu';

  @override
  String get dayShortFriday => 'Fri';

  @override
  String get dayShortSaturday => 'Sat';

  @override
  String get dayShortSunday => 'Sun';
}
