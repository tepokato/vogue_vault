import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:vogue_vault/services/appointment_service.dart';
import 'package:vogue_vault/models/service_type.dart';
import 'package:vogue_vault/models/appointment.dart';
import 'package:vogue_vault/models/user_profile.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => Directory.systemTemp.path;

  @override
  Future<String?> getApplicationSupportPath() async => Directory.systemTemp.path;

  @override
  Future<String?> getTemporaryPath() async => Directory.systemTemp.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    PathProviderPlatform.instance = _FakePathProviderPlatform();
    await Hive.initFlutter();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  test('legacy appointments load with default providerId', () async {
    final service = AppointmentService();
    await service.init();

    final box = Hive.box<Map<String, dynamic>>('appointments');
    await box.put('a1', {
      'id': 'a1',
      'clientId': 'c1',
      'service': ServiceType.hairdresser.name,
      'dateTime': DateTime.parse('2023-01-01').toIso8601String(),
    });

    final appts = service.appointments;
    expect(appts, hasLength(1));
    expect(appts.first.providerId, '');
  });

  test('deleteUser handles legacy appointments', () async {
    final service = AppointmentService();
    await service.init();

    final apptsBox = Hive.box<Map<String, dynamic>>('appointments');
    final usersBox = Hive.box<Map<String, dynamic>>('users');

    await usersBox.put('c1', UserProfile(id: 'c1', name: 'Client').toMap());

    await apptsBox.put('a1', {
      'id': 'a1',
      'clientId': 'c1',
      'service': ServiceType.hairdresser.name,
      'dateTime': DateTime.parse('2023-01-01').toIso8601String(),
    });

    await service.deleteUser('c1');

    expect(apptsBox.isEmpty, isTrue);
    expect(usersBox.get('c1'), isNull);
  });

  test('addAppointment supports guest clients', () async {
    final service = AppointmentService();
    await service.init();

    final appt = Appointment(
      id: 'a2',
      guestName: 'Walk-in',
      providerId: 'p1',
      service: ServiceType.barber,
      dateTime: DateTime.parse('2023-01-01'),
    );
    await service.addAppointment(appt);
    final stored = service.getAppointment('a2');
    expect(stored?.guestName, 'Walk-in');
    expect(stored?.clientId, isNull);
  });
}
