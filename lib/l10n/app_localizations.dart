import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('es'),
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

  /// Label for reminder offset
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes before'**
  String minutesBefore(int minutes);
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
      <String>['en', 'es'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
