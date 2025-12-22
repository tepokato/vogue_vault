import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../utils/service_type_utils.dart';

/// Displays information about an [Appointment] in a [ListTile].
///
/// The tile shows the service type, provider, optional price, time range,
/// customer name and optional location. Consumers may supply [onTap] and
/// [trailing] widgets to customize interactions.
class AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;
  final Widget? trailing;

  /// Whether the date portion should be included in the subtitle.
  ///
  /// [AppointmentsPage] shows the date while [CalendarPage] omits it because
  /// the date is already selected in the calendar. Defaults to `true`.
  final bool showDate;

  const AppointmentTile({
    super.key,
    required this.appointment,
    this.onTap,
    this.trailing,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final locale = Localizations.localeOf(context).toString();

    final providerName = appointment.providerId != null
        ? service.getUser(appointment.providerId!)?.name ??
            AppLocalizations.of(context)!.unknownUser
        : AppLocalizations.of(context)!.unknownUser;
    final customerName = appointment.customerId != null
        ? service.getCustomer(appointment.customerId!)?.fullName ??
            AppLocalizations.of(context)!.unknownUser
        : appointment.guestName ??
            AppLocalizations.of(context)!.unknownUser;

    final buffer = StringBuffer();
    if (showDate) {
      buffer
          .write(DateFormat.yMMMd(locale).format(appointment.dateTime.toLocal()));
      buffer.write(' ');
    }
    buffer.write(DateFormat.jm(locale).format(appointment.dateTime.toLocal()));
    buffer.write(' - ');
    buffer.write(DateFormat.jm(locale)
        .format(appointment.dateTime.toLocal().add(appointment.duration)));
    buffer.write('\n');
    buffer.write(customerName);
    if (appointment.location != null) {
      buffer.write(' @ ${appointment.location}');
    }

    final priceStr = appointment.price != null
        ? ' (${NumberFormat.simpleCurrency(locale: locale).format(appointment.price)})'
        : '';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: serviceTypeColor(appointment.service),
        child: ImageIcon(
          AssetImage(serviceTypeIcon(appointment.service)),
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      title: Text(
        '${serviceTypeLabel(context, appointment.service)} - $providerName$priceStr',
      ),
      subtitle: Text(buffer.toString()),
      isThreeLine: true,
      onTap: onTap,
      trailing: trailing,
    );
  }
}

