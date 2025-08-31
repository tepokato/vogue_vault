import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:vogue_vault/services/notification_service.dart';
import 'package:vogue_vault/models/appointment.dart';
import 'package:vogue_vault/models/service_type.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async =>
      Directory.systemTemp.path;

  @override
  Future<String?> getApplicationSupportPath() async =>
      Directory.systemTemp.path;

  @override
  Future<String?> getTemporaryPath() async => Directory.systemTemp.path;
}

class _MockNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    PathProviderPlatform.instance = _FakePathProviderPlatform();
    await Hive.initFlutter();
    tz.initializeTimeZones();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  test('schedules appointment using default offset', () async {
    final plugin = _MockNotificationsPlugin();
    when(plugin.initialize(any)).thenAnswer((_) async {});
    tz.TZDateTime? scheduled;
    when(plugin.zonedSchedule(
      any,
      any,
      any,
      any,
      any,
      androidAllowWhileIdle: anyNamed('androidAllowWhileIdle'),
      uiLocalNotificationDateInterpretation:
          anyNamed('uiLocalNotificationDateInterpretation'),
    )).thenAnswer((invocation) async {
      scheduled = invocation.positionalArguments[3] as tz.TZDateTime;
    });

    final service = NotificationService(plugin: plugin);
    await service.init();

    final appt = Appointment(
      id: '1',
      service: ServiceType.barber,
      dateTime: DateTime.now().add(const Duration(hours: 2)),
      duration: const Duration(hours: 1),
    );
    await service.scheduleAppointmentReminder(appt);

    final expected =
        tz.TZDateTime.from(appt.dateTime.subtract(const Duration(minutes: 30)), tz.local);
    expect(scheduled, expected);
    verify(plugin.zonedSchedule(
      any,
      any,
      any,
      any,
      any,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    )).called(1);
  });

  test('respects custom reminder offset', () async {
    final plugin = _MockNotificationsPlugin();
    when(plugin.initialize(any)).thenAnswer((_) async {});
    tz.TZDateTime? scheduled;
    when(plugin.zonedSchedule(
      any,
      any,
      any,
      any,
      any,
      androidAllowWhileIdle: anyNamed('androidAllowWhileIdle'),
      uiLocalNotificationDateInterpretation:
          anyNamed('uiLocalNotificationDateInterpretation'),
    )).thenAnswer((invocation) async {
      scheduled = invocation.positionalArguments[3] as tz.TZDateTime;
    });

    final service = NotificationService(plugin: plugin);
    await service.init();
    await service.setReminderOffset(const Duration(minutes: 10));

    final appt = Appointment(
      id: '2',
      service: ServiceType.hairdresser,
      dateTime: DateTime.now().add(const Duration(hours: 1)),
      duration: const Duration(hours: 1),
    );
    await service.scheduleAppointmentReminder(appt);

    final expected =
        tz.TZDateTime.from(appt.dateTime.subtract(const Duration(minutes: 10)), tz.local);
    expect(scheduled, expected);
  });

  test('cancelAppointmentReminder cancels notification', () async {
    final plugin = _MockNotificationsPlugin();
    when(plugin.initialize(any)).thenAnswer((_) async {});
    when(plugin.cancel(any)).thenAnswer((_) async {});

    final service = NotificationService(plugin: plugin);
    await service.init();

    const id = 'cancel-id';
    await service.cancelAppointmentReminder(id);

    verify(plugin.cancel(id.hashCode)).called(1);
  });

  test('rescheduleAppointmentReminder cancels and schedules', () async {
    final plugin = _MockNotificationsPlugin();
    when(plugin.initialize(any)).thenAnswer((_) async {});
    when(plugin.cancel(any)).thenAnswer((_) async {});
    when(plugin.zonedSchedule(
      any,
      any,
      any,
      any,
      any,
      androidAllowWhileIdle: anyNamed('androidAllowWhileIdle'),
      uiLocalNotificationDateInterpretation:
          anyNamed('uiLocalNotificationDateInterpretation'),
    )).thenAnswer((_) async {});

    final service = NotificationService(plugin: plugin);
    await service.init();

    final appt = Appointment(
      id: '3',
      service: ServiceType.barber,
      dateTime: DateTime.now().add(const Duration(hours: 2)),
      duration: const Duration(hours: 1),
    );

    await service.rescheduleAppointmentReminder(appt);

    verify(plugin.cancel(appt.id.hashCode)).called(1);
    verify(plugin.zonedSchedule(
      appt.id.hashCode,
      any,
      any,
      any,
      any,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    )).called(1);
  });
}
