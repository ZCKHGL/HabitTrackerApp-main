// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Habit Tracker';

  @override
  String get language => 'Language';

  @override
  String get indonesian => 'Indonesian';

  @override
  String get english => 'English';

  @override
  String get settings => 'Settings';

  @override
  String get add => 'Add';

  @override
  String get emptyHabit => 'No habits yet.\nTap + to add one.';

  @override
  String get followSystem => 'Follow System Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get deleteHabit => 'Delete Habit?';

  @override
  String deleteConfirm(Object habitName) {
    return 'Delete \"$habitName\" and its history?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String habitDeleted(Object habitName) {
    return 'Habit \"$habitName\" deleted';
  }

  @override
  String get lightActivity => 'Light activity';

  @override
  String get highActivity => 'High activity';

  @override
  String get analytics => 'Analytics';

  @override
  String get history => 'History';

  @override
  String get noHistory => 'No history yet';

  @override
  String get startCompletingHabits =>
      'Start completing habits to see your history';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get addHabit => 'Add Habit';

  @override
  String get save => 'SAVE';

  @override
  String get habitNameEmpty => 'Habit name cannot be empty';

  @override
  String get habitCategory => 'Habit Category';

  @override
  String get goodHabit => 'Good Habit';

  @override
  String get badHabit => 'Bad Habit';

  @override
  String get colorAssigned => 'Color assigned automatically';

  @override
  String get type => 'Type';

  @override
  String get untimed => 'Untimed';

  @override
  String get timed => 'Timed';

  @override
  String get target => 'Target';

  @override
  String get completed => 'Completed';

  @override
  String get notCompleted => 'Not Completed';

  @override
  String get monthly => 'Monthly';

  @override
  String get consistency => 'Consistency';

  @override
  String get streak => 'Streak';

  @override
  String get percentage => 'Percentage';

  @override
  String get noData => 'No data available';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get jan => 'Jan';

  @override
  String get feb => 'Feb';

  @override
  String get mar => 'Mar';

  @override
  String get apr => 'Apr';

  @override
  String get jun => 'Jun';

  @override
  String get jul => 'Jul';

  @override
  String get aug => 'Aug';

  @override
  String get sep => 'Sep';

  @override
  String get oct => 'Oct';

  @override
  String get nov => 'Nov';

  @override
  String get dec => 'Dec';

  @override
  String get useTimer => 'Use Timer';

  @override
  String get setDuration => 'Set Duration';

  @override
  String get colorBlueAutomatic => 'Color: Blue (automatic for good habits)';

  @override
  String get colorRedAutomatic => 'Color: Red (automatic for bad habits)';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get createAccount => 'Create Account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get loginSubtitle => 'Sign in to sync your habits across devices';

  @override
  String get createAccountSubtitle => 'Create an account to sync your habits';

  @override
  String get loginSubtitleShort => 'Sync your data across devices';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get guest => 'Guest';

  @override
  String get guestDescription => 'Using app without account';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get enterEmailFirst => 'Please enter your email first';

  @override
  String get passwordResetSent => 'Password reset email sent';

  @override
  String get accountCreated => 'Account created successfully! Please login.';
}
