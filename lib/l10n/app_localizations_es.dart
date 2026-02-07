// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Vogue Vault';

  @override
  String get appointmentsTitle => 'Citas';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get homeTooltip => 'Inicio';

  @override
  String get profileTooltip => 'Perfil';

  @override
  String get logoutTooltip => 'Cerrar sesión';

  @override
  String get professionalsTooltip => 'Profesionales';

  @override
  String get myBusinessTooltip => 'Mi Negocio';

  @override
  String get settingsTooltip => 'Configuración';

  @override
  String get myBusinessTitle => 'Mi Negocio';

  @override
  String get customersTitle => 'Clientes';

  @override
  String get newCustomerTitle => 'Nuevo cliente';

  @override
  String get editCustomerTitle => 'Editar cliente';

  @override
  String get contactInfoLabel => 'Información de contacto';

  @override
  String get calendarTooltip => 'Calendario';

  @override
  String get previousMonthTooltip => 'Mes anterior';

  @override
  String get nextMonthTooltip => 'Mes siguiente';

  @override
  String get unknownUser => 'Desconocido';

  @override
  String get userPhotoLabel => 'Foto del usuario';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get imageSelectionUnsupported => 'La selección de imágenes no es compatible con esta plataforma';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get nameRequired => 'Por favor ingresa un nombre';

  @override
  String get firstNameLabel => 'Nombre';

  @override
  String get firstNameRequired => 'Por favor ingresa un nombre';

  @override
  String get lastNameLabel => 'Apellido';

  @override
  String get lastNameRequired => 'Por favor ingresa un apellido';

  @override
  String get nicknameLabel => 'Apodo (opcional)';

  @override
  String get servicesTitle => 'Servicios';

  @override
  String get manageServicesTitle => 'Administrar servicios';

  @override
  String get saveButton => 'Guardar';

  @override
  String get addButton => 'Agregar';
  @override
  String get addAddOnButton => 'Agregar extra';
  @override
  String get addAddOnTitle => 'Agregar extra';
  @override
  String get editAddOnTitle => 'Editar extra';
  @override
  String get addOnNameLabel => 'Nombre del extra';
  @override
  String get addOnPriceLabel => 'Precio del extra';
  @override
  String get addOnNameValidation => 'Ingresa un nombre para el extra';
  @override
  String get addOnPriceValidation => 'Ingresa un precio válido para el extra';
  @override
  String get addOnsLabel => 'Extras';
  @override
  String get addOnsEmptyState => 'Aún no hay extras';
  @override
  String get editAddOnTooltip => 'Editar extra';
  @override
  String get deleteAddOnTooltip => 'Quitar extra';
  @override
  String totalWithAddOnsLabel(String price) {
    return 'Total con extras: $price';
  }

  @override
  String addOnsSummary(String names) {
    return 'Extras: $names';
  }

  @override
  String get priceLabel => 'Precio';

  @override
  String get invalidPrice => 'Precio inválido';

  @override
  String get priceRequired => 'Ingresa un precio';

  @override
  String get priceExampleHint => 'ej. 45.00';

  @override
  String get durationHelperText => 'Duración promedio de la cita en minutos';

  @override
  String get durationExampleHint => 'ej. 45';

  @override
  String get durationRequired => 'Ingresa una duración';

  @override
  String get invalidDuration => 'Ingresa un número válido de minutos';

  @override
  String get deleteUserFailed => 'No se pudo eliminar el usuario';

  @override
  String get cannotDeleteSelfTooltip => 'No puedes eliminarte a ti mismo';

  @override
  String get addUserTooltip => 'Agregar usuario';

  @override
  String get newUserTitle => 'Nuevo usuario';

  @override
  String get editUserTitle => 'Editar usuario';

  @override
  String get adminRole => 'Administrador';

  @override
  String get professionalRole => 'Profesional';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get editAppointmentTitle => 'Editar cita';

  @override
  String get newAppointmentTitle => 'Nueva cita';

  @override
  String get serviceLabel => 'Servicio';

  @override
  String get selectServiceValidation => 'Por favor selecciona un servicio';

  @override
  String get customerLabel => 'Cliente';

  @override
  String get guestNameLabel => 'Nombre del invitado';

  @override
  String get guestOrCustomerValidation => 'Por favor selecciona un cliente o ingresa un nombre de invitado';

  @override
  String get savedAddressLabel => 'Dirección guardada';

  @override
  String get locationLabel => 'Ubicación';

  @override
  String get selectDateButton => 'Seleccionar fecha';

  @override
  String get durationMinutesLabel => 'Duración (minutos)';

  @override
  String get bufferTimeLabel => 'Tiempo de buffer (minutos)';

  @override
  String get addAppointmentTooltip => 'Agregar cita';

  @override
  String get availabilityLegendAvailable => 'Espacios disponibles';

  @override
  String get availabilityLegendFull => 'Completamente reservado';

  @override
  String get invalidCredentials => 'Credenciales inválidas';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get passwordRequirementsHint =>
      'Usa al menos 8 caracteres con un número y un símbolo.';

  @override
  String get passwordStrengthLabel => 'Fortaleza';

  @override
  String get passwordStrengthWeak => 'Débil';

  @override
  String get passwordStrengthMedium => 'Media';

  @override
  String get passwordStrengthStrong => 'Fuerte';

  @override
  String get forgotPasswordButton => '¿Olvidaste tu contraseña?';

  @override
  String get resetPasswordTitle => 'Restablecer contraseña';

  @override
  String get resetPasswordDescription =>
      'Actualiza tu contraseña usando el correo de tu cuenta.';

  @override
  String get resetPasswordButton => 'Actualizar contraseña';

  @override
  String get resetPasswordSuccessMessage =>
      'Contraseña actualizada. Ya puedes iniciar sesión con la nueva.';

  @override
  String get resetPasswordErrorMessage =>
      'No pudimos encontrar una cuenta con ese correo.';

  @override
  String get currentPasswordLabel => 'Contraseña actual';

  @override
  String get newPasswordLabel => 'Nueva contraseña';

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get emailRequired => 'Por favor ingresa tu correo electrónico';

  @override
  String get invalidEmail => 'Correo electrónico inválido';

  @override
  String get invalidEmailFormat => 'Formato de correo electrónico inválido';

  @override
  String get passwordRequired => 'Por favor ingresa tu contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get changesSaved => 'Cambios guardados';

  @override
  String get loginButton => 'Ingresar';

  @override
  String get createAccount => 'Crear una cuenta';

  @override
  String get noAppointmentsScheduled => 'No hay citas programadas.';

  @override
  String get addFirstAppointment => 'Agrega tu primera cita';

  @override
  String get addBookingCta => 'Toca para añadir una cita';

  @override
  String get appointmentsEmptyDescription =>
      'Organiza tus reservas, envía recordatorios y controla los datos de tus clientes en un solo lugar.';

  @override
  String get importAppointmentsCta =>
      'Importar desde contactos o calendarios';

  @override
  String get noCustomersYet => 'Aún no hay clientes';

  @override
  String get addFirstCustomer => 'Agrega tu primer cliente';

  @override
  String get noAddressesYet => 'Aún no hay direcciones';

  @override
  String get addFirstAddress => 'Agrega tu primera dirección';

  @override
  String get serviceTypeBarber => 'Barbero';

  @override
  String get serviceTypeHairdresser => 'Peluquería';

  @override
  String get serviceTypeNails => 'Uñas';

  @override
  String get serviceTypeTattoo => 'Tatuador';

  @override
  String get appointmentConflict => 'La cita entra en conflicto con una reserva existente';

  @override
  String get deleteUserTooltip => 'Eliminar usuario';

  @override
  String get deleteAppointmentTooltip => 'Eliminar cita';

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get deleteAppointmentTitle => 'Eliminar cita';

  @override
  String get deleteAppointmentConfirmation => '¿Está seguro de que desea eliminar esta cita?';

  @override
  String get deleteUserTitle => 'Eliminar usuario';

  @override
  String get deleteUserConfirmation => '¿Está seguro de que desea eliminar este usuario?';

  @override
  String get deleteCustomerDialogTitle => 'Eliminar cliente';

  @override
  String get deleteCustomerDialogBody => '¿Está seguro de que desea eliminar este cliente?';

  @override
  String get deleteAddressDialogTitle => 'Eliminar dirección';

  @override
  String get deleteAddressDialogBody => '¿Está seguro de que desea eliminar esta dirección?';

  @override
  String get dialogCancelAction => 'Cancelar';

  @override
  String get dialogConfirmAction => 'Confirmar';

  @override
  String get searchAppointmentsLabel => 'Buscar';

  @override
  String get searchAppointmentsHint =>
      'Busca por cliente, proveedor, ubicación o servicio';

  @override
  String get appointmentTimeFilterLabel => 'Tiempo';

  @override
  String get appointmentFilterAllLabel => 'Todas';

  @override
  String get appointmentFilterUpcomingLabel => 'Próximas';

  @override
  String get appointmentFilterPastLabel => 'Pasadas';

  @override
  String get appointmentServiceFilterLabel => 'Tipo de servicio';

  @override
  String get appointmentServiceAllLabel => 'Todos los servicios';

  @override
  String get noAppointmentsMatchFilters =>
      'Ninguna cita coincide con tus filtros.';

  @override
  String get addressesTitle => 'Direcciones';

  @override
  String get newAddressTitle => 'Nueva dirección';

  @override
  String get editAddressTitle => 'Editar dirección';

  @override
  String get labelLabel => 'Etiqueta';

  @override
  String get addressLabel => 'Dirección';

  @override
  String get requiredField => 'Requerido';

  @override
  String get notificationSettingsTitle => 'Configuración de notificaciones';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get languageSystemLabel =>
      'Coincidir con el idioma del dispositivo';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get dataExportTitle => 'Exportación de datos';

  @override
  String get exportAppointmentsCsvTitle => 'Copiar CSV de citas';

  @override
  String get exportAppointmentsCsvDescription =>
      'Crea un CSV con tus citas programadas.';

  @override
  String get exportCustomersCsvTitle => 'Copiar CSV de clientes';

  @override
  String get exportCustomersCsvDescription =>
      'Crea un CSV con tu lista de clientes.';

  @override
  String get exportCsvAction => 'Copiar CSV';

  @override
  String get exportCsvSuccess => 'CSV copiado al portapapeles.';

  @override
  String get exportCsvEmpty => 'No hay datos para exportar.';

  @override
  String get exportCsvFailed => 'No se pudo preparar la exportación CSV.';

  @override
  String get cloudBackupTitle => 'Copias de seguridad en la nube';

  @override
  String get googleDriveBackupTitle => 'Copia de seguridad en Google Drive';

  @override
  String get googleDriveBackupDescription =>
      'Guarda una copia de tus datos de Vogue Vault en Google Drive.';

  @override
  String get googleDriveBackupAction => 'Hacer copia ahora';

  @override
  String get googleDriveBackupInProgress => 'Creando copia...';

  @override
  String googleDriveBackupLastRun(String time) {
    return 'Última copia: $time';
  }

  @override
  String get googleDriveBackupNeverRan => 'Aún no hay copias.';

  @override
  String get googleDriveBackupSuccess => 'Copia guardada en Google Drive.';

  @override
  String get googleDriveBackupFailed =>
      'No se pudo crear la copia en Google Drive.';

  @override
  String googleDriveBackupError(String message) {
    return 'Último error: $message';
  }

  @override
  String get appointmentReminderTitle => 'Recordatorio de cita';

  @override
  String upcomingAppointmentBody(String service) {
    return 'Próxima cita de $service';
  }

  @override
  String get reminderAtTime => 'En el momento de la cita';

  @override
  String minutesBefore(int minutes) {
    return '$minutes minutos antes';
  }

  @override
  String bufferMinutesSummary(int minutes) {
    return 'Buffer: $minutes min';
  }
}
