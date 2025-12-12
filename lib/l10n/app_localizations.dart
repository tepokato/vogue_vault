import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('es'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Vogue Vault'**
  String get appTitle;

  /// No description provided for @appointmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointmentsTitle;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @homeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTooltip;

  /// No description provided for @profileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTooltip;

  /// No description provided for @logoutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTooltip;

  /// No description provided for @professionalsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Professionals'**
  String get professionalsTooltip;

  /// No description provided for @myBusinessTooltip.
  ///
  /// In en, this message translates to:
  /// **'My Business'**
  String get myBusinessTooltip;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @myBusinessTitle.
  ///
  /// In en, this message translates to:
  /// **'My Business'**
  String get myBusinessTitle;

  /// No description provided for @customersTitle.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customersTitle;

  /// No description provided for @newCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'New Customer'**
  String get newCustomerTitle;

  /// No description provided for @editCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomerTitle;

  /// No description provided for @contactInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact info'**
  String get contactInfoLabel;

  /// No description provided for @calendarTooltip.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTooltip;

  /// No description provided for @previousMonthTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonthTooltip;

  /// No description provided for @nextMonthTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonthTooltip;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownUser;

  /// No description provided for @userPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'User photo'**
  String get userPhotoLabel;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @imageSelectionUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Image selection not supported on this platform'**
  String get imageSelectionUnsupported;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get nameRequired;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a first name'**
  String get firstNameRequired;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a last name'**
  String get lastNameRequired;

  /// No description provided for @nicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname (optional)'**
  String get nicknameLabel;

  /// No description provided for @servicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get servicesTitle;

  /// No description provided for @manageServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Services'**
  String get manageServicesTitle;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @invalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Invalid price'**
  String get invalidPrice;

  /// No description provided for @priceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a price'**
  String get priceRequired;

  /// No description provided for @priceExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 45.00'**
  String get priceExampleHint;

  /// No description provided for @durationHelperText.
  ///
  /// In en, this message translates to:
  /// **'Average appointment length in minutes'**
  String get durationHelperText;

  /// No description provided for @durationExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 45'**
  String get durationExampleHint;

  /// No description provided for @durationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a duration'**
  String get durationRequired;

  /// No description provided for @invalidDuration.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number of minutes'**
  String get invalidDuration;

  /// No description provided for @deleteUserFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete user'**
  String get deleteUserFailed;

  /// No description provided for @cannotDeleteSelfTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete yourself'**
  String get cannotDeleteSelfTooltip;

  /// No description provided for @addUserTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add user'**
  String get addUserTooltip;

  /// No description provided for @newUserTitle.
  ///
  /// In en, this message translates to:
  /// **'New User'**
  String get newUserTitle;

  /// No description provided for @editUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUserTitle;

  /// No description provided for @adminRole.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminRole;

  /// No description provided for @professionalRole.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get professionalRole;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @editAppointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Appointment'**
  String get editAppointmentTitle;

  /// No description provided for @newAppointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'New Appointment'**
  String get newAppointmentTitle;

  /// No description provided for @serviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get serviceLabel;

  /// No description provided for @selectServiceValidation.
  ///
  /// In en, this message translates to:
  /// **'Please select a service'**
  String get selectServiceValidation;

  /// No description provided for @customerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerLabel;

  /// No description provided for @guestNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Guest name'**
  String get guestNameLabel;

  /// No description provided for @guestOrCustomerValidation.
  ///
  /// In en, this message translates to:
  /// **'Please select a customer or enter a guest name'**
  String get guestOrCustomerValidation;

  /// No description provided for @savedAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved address'**
  String get savedAddressLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @selectDateButton.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDateButton;

  /// No description provided for @durationMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get durationMinutesLabel;

  /// No description provided for @addAppointmentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add appointment'**
  String get addAppointmentTooltip;

  /// No description provided for @availabilityLegendAvailable.
  ///
  /// In en, this message translates to:
  /// **'Open slots'**
  String get availabilityLegendAvailable;

  /// No description provided for @availabilityLegendFull.
  ///
  /// In en, this message translates to:
  /// **'Fully booked'**
  String get availabilityLegendFull;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get invalidCredentials;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordRequirementsHint.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters with a number and symbol.'**
  String get passwordRequirementsHint;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordButton;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Update your password using your account email.'**
  String get resetPasswordDescription;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get resetPasswordButton;

  /// No description provided for @resetPasswordSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Password updated. You can sign in with your new password.'**
  String get resetPasswordSuccessMessage;

  /// No description provided for @resetPasswordErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn't find an account with that email.'**
  String get resetPasswordErrorMessage;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormat;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get changesSaved;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @noAppointmentsScheduled.
  ///
  /// In en, this message translates to:
  /// **'No appointments scheduled.'**
  String get noAppointmentsScheduled;

  /// No description provided for @addFirstAppointment.
  ///
  /// In en, this message translates to:
  /// **'Add your first appointment'**
  String get addFirstAppointment;

  /// No description provided for @appointmentsEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep bookings organized, send reminders, and track client details in one place.'**
  String get appointmentsEmptyDescription;

  /// No description provided for @importAppointmentsCta.
  ///
  /// In en, this message translates to:
  /// **'Import from contacts or calendars'**
  String get importAppointmentsCta;

  /// No description provided for @noCustomersYet.
  ///
  /// In en, this message translates to:
  /// **'No customers yet'**
  String get noCustomersYet;

  /// No description provided for @addFirstCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add your first customer'**
  String get addFirstCustomer;

  /// No description provided for @noAddressesYet.
  ///
  /// In en, this message translates to:
  /// **'No addresses yet'**
  String get noAddressesYet;

  /// No description provided for @addFirstAddress.
  ///
  /// In en, this message translates to:
  /// **'Add your first address'**
  String get addFirstAddress;

  /// No description provided for @serviceTypeBarber.
  ///
  /// In en, this message translates to:
  /// **'Barber'**
  String get serviceTypeBarber;

  /// No description provided for @serviceTypeHairdresser.
  ///
  /// In en, this message translates to:
  /// **'Hairdresser'**
  String get serviceTypeHairdresser;

  /// No description provided for @serviceTypeNails.
  ///
  /// In en, this message translates to:
  /// **'Nails'**
  String get serviceTypeNails;

  /// No description provided for @serviceTypeTattoo.
  ///
  /// In en, this message translates to:
  /// **'Tattoo Artist'**
  String get serviceTypeTattoo;

  /// No description provided for @appointmentConflict.
  ///
  /// In en, this message translates to:
  /// **'Appointment conflicts with existing booking'**
  String get appointmentConflict;

  /// No description provided for @deleteUserTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete user'**
  String get deleteUserTooltip;

  /// No description provided for @deleteAppointmentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete appointment'**
  String get deleteAppointmentTooltip;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @deleteAppointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Appointment'**
  String get deleteAppointmentTitle;

  /// No description provided for @deleteAppointmentConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this appointment?'**
  String get deleteAppointmentConfirmation;

  /// No description provided for @deleteUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUserTitle;

  /// No description provided for @deleteUserConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this user?'**
  String get deleteUserConfirmation;

  /// No description provided for @deleteCustomerDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Customer'**
  String get deleteCustomerDialogTitle;

  /// No description provided for @deleteCustomerDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this customer?'**
  String get deleteCustomerDialogBody;

  /// No description provided for @deleteAddressDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Address'**
  String get deleteAddressDialogTitle;

  /// No description provided for @deleteAddressDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this address?'**
  String get deleteAddressDialogBody;

  /// No description provided for @dialogCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancelAction;

  /// No description provided for @dialogConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dialogConfirmAction;

  /// No description provided for @searchAppointmentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchAppointmentsLabel;

  /// No description provided for @searchAppointmentsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by client, provider, location, or service'**
  String get searchAppointmentsHint;

  /// No description provided for @appointmentTimeFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get appointmentTimeFilterLabel;

  /// No description provided for @appointmentFilterAllLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get appointmentFilterAllLabel;

  /// No description provided for @appointmentFilterUpcomingLabel.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get appointmentFilterUpcomingLabel;

  /// No description provided for @appointmentFilterPastLabel.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get appointmentFilterPastLabel;

  /// No description provided for @appointmentServiceFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Service type'**
  String get appointmentServiceFilterLabel;

  /// No description provided for @appointmentServiceAllLabel.
  ///
  /// In en, this message translates to:
  /// **'All services'**
  String get appointmentServiceAllLabel;

  /// No description provided for @noAppointmentsMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No appointments match your filters yet.'**
  String get noAppointmentsMatchFilters;

  /// No description provided for @addressesTitle.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addressesTitle;

  /// No description provided for @newAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'New Address'**
  String get newAddressTitle;

  /// No description provided for @editAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get editAddressTitle;

  /// No description provided for @labelLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get labelLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageSystemLabel.
  ///
  /// In en, this message translates to:
  /// **'Match device language'**
  String get languageSystemLabel;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @appointmentReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment Reminder'**
  String get appointmentReminderTitle;

  /// No description provided for @upcomingAppointmentBody.
  ///
  /// In en, this message translates to:
  /// **'Upcoming {service} appointment'**
  String upcomingAppointmentBody(String service);

  /// Label for reminder offset
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes before'**
  String minutesBefore(int minutes);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
