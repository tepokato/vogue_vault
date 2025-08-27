import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  test('schedules appointment using default offset', () async {
    final plugin = _MockNotificationsPlugin();
    when(plugin.initialize(any)).thenAnswer((_) async {});
    DateTime? scheduled;
    when(plugin.schedule(
      any,
      any,
      any,
      any,
      any,
      androidAllowWhileIdle: anyNamed('androidAllowWhileIdle'),
    )).thenAnswer((invocation) async {
      scheduled = invocation.positionalArguments[3] as DateTime;
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

    final expected = appt.dateTime.subtract(const Duration(minutes: 30));
    expect(scheduled, expected);
    verify(plugin.schedule(
      any,
      any,
      any,
      any,
      any,
      androidAllowWhileIdle: true,
    )).called(1);
  });

  test('respects custom reminder offset', () async {
    final plugin = _MockNotificationsPlugin();
    when(plugin.initialize(any)).thenAnswer((_) async {});
    DateTime? scheduled;
    when(plugin.schedule(
      any,
      any,
      any,
      any,
      any,
      androidAllowWhileIdle: anyNamed('androidAllowWhileIdle'),
    )).thenAnswer((invocation) async {
      scheduled = invocation.positionalArguments[3] as DateTime;
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

    final expected = appt.dateTime.subtract(const Duration(minutes: 10));
    expect(scheduled, expected);
  });
}
