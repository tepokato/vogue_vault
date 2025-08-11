import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:hive/hive.dart';
import 'package:vogue_vault/models/appointment.dart';
import 'package:vogue_vault/models/client.dart';
import 'package:vogue_vault/models/service_type.dart';
import 'package:vogue_vault/services/appointment_service.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  FakePathProviderPlatform(this.path);

  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;

  @override
  Future<String?> getApplicationSupportPath() async => path;

  @override
  Future<String?> getTemporaryPath() async => path;

  @override
  Future<String?> getLibraryPath() async => path;

  @override
  Future<String?> getDownloadsPath() async => path;

  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) async => [path];

  @override
  Future<String?> getExternalStoragePath() async => path;
}

void main() {
  late AppointmentService service;
  late Directory tempDir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp();
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);
    service = AppointmentService();
    await service.init();
  });

  tearDown(() async {
    service.dispose();
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  group('Client operations', () {
    test('add client stores client and notifies listeners', () async {
      final client = Client(id: 'c1', name: 'Alice');
      var notified = false;
      service.addListener(() => notified = true);

      await service.addClient(client);

      expect(service.getClient('c1'), equals(client));
      expect(service.clients, contains(client));
      expect(notified, isTrue);
    });

    test('update client updates data and notifies listeners', () async {
      final client = Client(id: 'c1', name: 'Alice');
      await service.addClient(client);

      final updated = client.copyWith(name: 'Alice Updated');
      var notified = false;
      service.addListener(() => notified = true);

      await service.updateClient(updated);

      expect(service.getClient('c1'), equals(updated));
      expect(service.clients.length, 1);
      expect(notified, isTrue);
    });

    test('delete client removes client and related appointments', () async {
      final client = Client(id: 'c1', name: 'Alice');
      final appointment = Appointment(
        id: 'a1',
        clientId: 'c1',
        service: ServiceType.barber,
        dateTime: DateTime(2023, 9, 10, 10, 0),
      );
      await service.addClient(client);
      await service.addAppointment(appointment);

      var notified = false;
      service.addListener(() => notified = true);

      await service.deleteClient('c1');

      expect(service.getClient('c1'), isNull);
      expect(service.clients, isEmpty);
      expect(service.getAppointment('a1'), isNull);
      expect(service.appointments, isEmpty);
      expect(notified, isTrue);
    });

    test('delete client reassigns appointments when id provided', () async {
      final c1 = Client(id: 'c1', name: 'Alice');
      final c2 = Client(id: 'c2', name: 'Bob');
      final appointment = Appointment(
        id: 'a1',
        clientId: 'c1',
        service: ServiceType.barber,
        dateTime: DateTime(2023, 9, 10, 10, 0),
      );
      await service.addClient(c1);
      await service.addClient(c2);
      await service.addAppointment(appointment);

      await service.deleteClient('c1', reassignedClientId: 'c2');

      final updated = service.getAppointment('a1');
      expect(updated?.clientId, 'c2');
      expect(service.getClient('c1'), isNull);
      expect(service.clients.length, 1);
    });
  });

  group('Appointment operations', () {
    test('add appointment stores appointment and notifies listeners', () async {
      final appointment = Appointment(
        id: 'a1',
        clientId: 'c1',
        service: ServiceType.barber,
        dateTime: DateTime(2023, 9, 10, 10, 0),
      );
      var notified = false;
      service.addListener(() => notified = true);

      await service.addAppointment(appointment);

      expect(service.getAppointment('a1'), equals(appointment));
      expect(service.appointments, contains(appointment));
      expect(notified, isTrue);
    });

    test('update appointment updates data and notifies listeners', () async {
      final appointment = Appointment(
        id: 'a1',
        clientId: 'c1',
        service: ServiceType.barber,
        dateTime: DateTime(2023, 9, 10, 10, 0),
      );
      await service.addAppointment(appointment);

      final updated = appointment.copyWith(
        service: ServiceType.hairdresser,
        dateTime: DateTime(2023, 9, 11, 11, 0),
      );
      var notified = false;
      service.addListener(() => notified = true);

      await service.updateAppointment(updated);

      expect(service.getAppointment('a1'), equals(updated));
      expect(service.appointments.length, 1);
      expect(notified, isTrue);
    });

    test('delete appointment removes appointment and notifies listeners', () async {
      final appointment = Appointment(
        id: 'a1',
        clientId: 'c1',
        service: ServiceType.barber,
        dateTime: DateTime(2023, 9, 10, 10, 0),
      );
      await service.addAppointment(appointment);

      var notified = false;
      service.addListener(() => notified = true);

      await service.deleteAppointment('a1');

      expect(service.getAppointment('a1'), isNull);
      expect(service.appointments, isEmpty);
      expect(notified, isTrue);
    });
  });
}

