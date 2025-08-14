import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:vogue_vault/services/appointment_service.dart';
import 'package:vogue_vault/models/service_type.dart';
import 'package:vogue_vault/models/appointment.dart';
import 'package:vogue_vault/models/user_profile.dart';
import 'package:vogue_vault/models/service_offering.dart';
import 'package:vogue_vault/models/user_role.dart';

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

  test('appointments getter returns appointments sorted by date', () async {
    final service = AppointmentService();
    await service.init();

    final uuid = const Uuid();
    final providerId = uuid.v4();
    final laterId = uuid.v4();
    final earlierId = uuid.v4();
    final later = Appointment(
      id: laterId,
      providerId: providerId,
      service: ServiceType.barber,
      dateTime: DateTime.parse('2023-01-02'),
    );
    final earlier = Appointment(
      id: earlierId,
      providerId: providerId,
      service: ServiceType.barber,
      dateTime: DateTime.parse('2023-01-01'),
    );

    await service.addAppointment(later);
    await service.addAppointment(earlier);

    final appts = service.appointments;
    expect(appts.map((a) => a.id), [earlierId, laterId]);
  });

  test('legacy appointments load with default providerId', () async {
    final service = AppointmentService();
    await service.init();

    final uuid = const Uuid();
    final box = Hive.box('appointments');
    final id = uuid.v4();
    final clientId = uuid.v4();
    await box.put(id, {
      'id': id,
      'clientId': clientId,
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

    final uuid = const Uuid();
    final apptsBox = Hive.box('appointments');
    final usersBox = Hive.box('users');

    final clientId = uuid.v4();
    final apptId = uuid.v4();

    await usersBox.put(
        clientId,
        UserProfile(
          id: clientId,
          firstName: 'Client',
          lastName: 'User',
        ).toMap());

    await apptsBox.put(apptId, {
      'id': apptId,
      'clientId': clientId,
      'service': ServiceType.hairdresser.name,
      'dateTime': DateTime.parse('2023-01-01').toIso8601String(),
    });

    await service.deleteUser(clientId);

    expect(apptsBox.isEmpty, isTrue);
    expect(usersBox.get(clientId), isNull);
  });

  test('addAppointment supports guest clients', () async {
    final service = AppointmentService();
    await service.init();

    final uuid = const Uuid();
    final id = uuid.v4();
    final appt = Appointment(
      id: id,
      guestName: 'Walk-in',
      providerId: uuid.v4(),
      service: ServiceType.barber,
      dateTime: DateTime.parse('2023-01-01'),
    );
    await service.addAppointment(appt);
    final stored = service.getAppointment(id);
    expect(stored?.guestName, 'Walk-in');
    expect(stored?.clientId, isNull);
  });

  test('providersFor filters by offerings', () async {
    final service = AppointmentService();
    await service.init();

    final uuid = const Uuid();
    final p1Id = uuid.v4();
    final p2Id = uuid.v4();
    final p3Id = uuid.v4();
    final p1 = UserProfile(
      id: p1Id,
      firstName: 'Pro',
      lastName: 'One',
      roles: {UserRole.professional},
      offerings: [
        ServiceOffering(type: ServiceType.barber, name: 'Cut', price: 10),
      ],
    );
    final p2 = UserProfile(
      id: p2Id,
      firstName: 'Pro',
      lastName: 'Two',
      roles: {UserRole.professional},
      offerings: [
        ServiceOffering(type: ServiceType.nails, name: 'Nail', price: 20),
      ],
    );
    final p3 = UserProfile(
      id: p3Id,
      firstName: 'Pro',
      lastName: 'Three',
      roles: {UserRole.professional},
      offerings: [
        ServiceOffering(type: ServiceType.tattoo, name: 'Ink', price: 50),
      ],
    );

    await service.addUser(p1);
    await service.addUser(p2);
    await service.addUser(p3);

    final barbers = service.providersFor(ServiceType.barber);
    expect(barbers.map((p) => p.id), [p1Id]);

    final nailTechs = service.providersFor(ServiceType.nails);
    expect(nailTechs.map((p) => p.id), [p2Id]);

    final tattooArtists = service.providersFor(ServiceType.tattoo);
    expect(tattooArtists.map((p) => p.id), [p3Id]);
  });
}
