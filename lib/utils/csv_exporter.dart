import 'package:intl/intl.dart';

import '../models/appointment.dart';
import '../models/customer.dart';
import '../models/user_profile.dart';

class CsvExporter {
  static String exportAppointments({
    required List<Appointment> appointments,
    required Map<String, Customer> customersById,
    required Map<String, UserProfile> providersById,
    DateFormat? dateFormat,
    DateFormat? timeFormat,
  }) {
    final resolvedDateFormat = dateFormat ?? DateFormat('yyyy-MM-dd');
    final resolvedTimeFormat = timeFormat ?? DateFormat('HH:mm');
    final buffer = StringBuffer();
    buffer.writeln(_csvRow([
      'Appointment ID',
      'Date',
      'Time',
      'Service',
      'Provider',
      'Customer',
      'Guest Name',
      'Location',
      'Total Price',
      'Duration (min)',
      'Buffer (min)',
      'Add-ons',
    ]));

    for (final appointment in appointments) {
      final providerName = appointment.providerId != null
          ? providersById[appointment.providerId!]?.fullName ?? ''
          : '';
      final customerName = appointment.customerId != null
          ? customersById[appointment.customerId!]?.fullName ?? ''
          : '';
      final addOnSummary = appointment.addOns
          .map((addOn) =>
              '${addOn.name} (${addOn.price.toStringAsFixed(2)})')
          .join('; ');
      final totalPrice = appointment.totalPrice;

      buffer.writeln(_csvRow([
        appointment.id,
        resolvedDateFormat.format(appointment.dateTime.toLocal()),
        resolvedTimeFormat.format(appointment.dateTime.toLocal()),
        appointment.service.name,
        providerName,
        customerName,
        appointment.guestName ?? '',
        appointment.location ?? '',
        totalPrice != null ? totalPrice.toStringAsFixed(2) : '',
        appointment.duration.inMinutes.toString(),
        appointment.bufferDuration.inMinutes.toString(),
        addOnSummary,
      ]));
    }

    return buffer.toString();
  }

  static String exportCustomers({required List<Customer> customers}) {
    final buffer = StringBuffer();
    buffer.writeln(_csvRow([
      'Customer ID',
      'First Name',
      'Last Name',
      'Contact Info',
    ]));

    for (final customer in customers) {
      buffer.writeln(_csvRow([
        customer.id,
        customer.firstName,
        customer.lastName,
        customer.contactInfo ?? '',
      ]));
    }

    return buffer.toString();
  }

  static String _csvRow(List<String> values) {
    return values.map(_escape).join(',');
  }

  static String _escape(String value) {
    final needsQuotes = value.contains(',') ||
        value.contains('\n') ||
        value.contains('\r') ||
        value.contains('"');
    if (!needsQuotes) {
      return value;
    }
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
}
