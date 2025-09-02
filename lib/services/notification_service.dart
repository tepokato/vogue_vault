import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';
import '../models/appointment.dart';
import '../utils/service_type_utils.dart';

class NotificationService {
  static const _settingsBoxName = 'settings';
  static const _reminderOffsetKey = 'reminderOffsetMinutes';

  final FlutterLocalNotificationsPlugin _plugin;
  late Box _settingsBox;
  bool _initialized = false;

  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    _settingsBox = await Hive.openBox(_settingsBoxName);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('NotificationService has not been initialized.');
    }
  }

  Duration get reminderOffset {
    final minutes =
        (_settingsBox.get(_reminderOffsetKey, defaultValue: 30) as int?) ?? 30;
    return Duration(minutes: minutes);
  }

  Future<void> setReminderOffset(Duration offset) async {
    _ensureInitialized();
    await _settingsBox.put(_reminderOffsetKey, offset.inMinutes);
  }

  int _notificationId(String appointmentId) => appointmentId.hashCode;

  Future<void> scheduleAppointmentReminder(
    Appointment appointment, {
    BuildContext? context,
    String? serviceName,
  }) async {
    _ensureInitialized();
    final scheduled = appointment.dateTime.subtract(reminderOffset);
    if (scheduled.isBefore(DateTime.now())) return;

    final label =
        serviceName ?? (context != null ? serviceTypeLabel(context, appointment.service) : appointment.service.name);
    final l10n = context != null ? AppLocalizations.of(context) : null;

    await _plugin.zonedSchedule(
      _notificationId(appointment.id),
      l10n?.appointmentReminderTitle ?? 'Appointment Reminder',
      l10n?.upcomingAppointmentBody(label) ?? 'Upcoming $label appointment',
      tz.TZDateTime.from(scheduled, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails('appointments', 'Appointments'),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAppointmentReminder(String appointmentId) async {
    _ensureInitialized();
    await _plugin.cancel(_notificationId(appointmentId));
  }

  Future<void> rescheduleAppointmentReminder(
    Appointment appointment, {
    BuildContext? context,
    String? serviceName,
  }) async {
    _ensureInitialized();
    await cancelAppointmentReminder(appointment.id);
    await scheduleAppointmentReminder(
      appointment,
      context: context,
      serviceName: serviceName,
    );
  }
}
