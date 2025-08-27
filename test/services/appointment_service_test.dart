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
import 'package:vogue_vault/models/address.dart';
import 'package:vogue_vault/models/customer.dart';

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

    const uuid = Uuid();
    final laterId = uuid.v4();
    final earlierId = uuid.v4();
    final later = Appointment(
      id: laterId,
      service: ServiceType.barber,
      dateTime: DateTime.parse('2023-01-02'),
      duration: const Duration(hours: 1),
    );
    final earlier = Appointment(
      id: earlierId,
      service: ServiceType.barber,
      dateTime: DateTime.parse('2023-01-01'),
      duration: const Duration(hours: 1),
    );

    await service.addAppointment(later);
    await service.addAppointment(earlier);

    final appts = service.appointments;
    expect(appts.map((a) => a.id), [earlierId, laterId]);
    expect(appts.first.providerId, isNull);
  });

  test('appointments load with null providerId', () async {
    final service = AppointmentService();
    await service.init();

    const uuid = Uuid();
    final box = Hive.box('appointments');
    final id = uuid.v4();
    await box.put(id, {
      'id': id,
      'service': ServiceType.hairdresser.name,
      'dateTime': DateTime.parse('2023-01-01').toIso8601String(),
    });

    final appts = service.appointments;
    expect(appts, hasLength(1));
    expect(appts.first.providerId, isNull);
  });

  test('deleteUser removes appointments for provider', () async {
    final service = AppointmentService();
    await service.init();

    const uuid = Uuid();
    final apptsBox = Hive.box('appointments');
    final usersBox = Hive.box('users');

    final providerId = uuid.v4();
    final apptId = uuid.v4();

    await usersBox.put(
      providerId,
      UserProfile(
        id: providerId,
        firstName: 'Provider',
        lastName: 'User',
      ).toMap(),
    );

    await apptsBox.put(apptId, {
      'id': apptId,
      'providerId': providerId,
      'service': ServiceType.hairdresser.name,
      'dateTime': DateTime.parse('2023-01-01').toIso8601String(),
    });

    await service.deleteUser(providerId);

    expect(apptsBox.isEmpty, isTrue);
    expect(usersBox.get(providerId), isNull);
  });

  test('addAppointment persists duration', () async {
    final service = AppointmentService();
    await service.init();

    const uuid = Uuid();
    final id = uuid.v4();
    final appt = Appointment(
      id: id,
      service: ServiceType.barber,
      dateTime: DateTime.parse('2023-01-01'),
      duration: const Duration(minutes: 90),
    );
    await service.addAppointment(appt);
    final stored = service.getAppointment(id);
    expect(stored?.duration, const Duration(minutes: 90));
  });

  test('addAppointment persists customer and location', () async {
    final service = AppointmentService();
    await service.init();

    const uuid = Uuid();
    final id = uuid.v4();
    final customerId = uuid.v4();
    final appt = Appointment(
      id: id,
      customerId: customerId,
      location: 'Studio',
      service: ServiceType.barber,
      dateTime: DateTime.parse('2023-01-01'),
      duration: const Duration(hours: 1),
    );
    await service.addAppointment(appt);
    final stored = service.getAppointment(id)!;
    expect(stored.customerId, customerId);
    expect(stored.location, 'Studio');
  });

  test('guest appointments do not create customers', () async {
    final service = AppointmentService();
    await service.init();

    const uuid = Uuid();
    final id = uuid.v4();
    final appt = Appointment(
      id: id,
      guestName: 'Walk-in',
      service: ServiceType.barber,
      dateTime: DateTime.parse('2023-01-01'),
      duration: const Duration(hours: 1),
    );
    await service.addAppointment(appt);

    final stored = service.getAppointment(id)!;
    expect(stored.guestName, 'Walk-in');
    expect(stored.customerId, isNull);
    expect(service.customers, isEmpty);
  });

  test('customer addresses are stored globally', () async {
    final service = AppointmentService();
    await service.init();

    const uuid = Uuid();
    final address = Address(id: uuid.v4(), label: 'Home', details: '123 Main');
    final customer = Customer(
      id: uuid.v4(),
      firstName: 'John',
      lastName: 'Doe',
      addresses: [address],
    );

    await service.addCustomer(customer);
    expect(service.addresses, contains(address));
  });

  test('address CRUD operations', () async {
    final service = AppointmentService();
    await service.init();

    const uuid = Uuid();
    final id = uuid.v4();
    final address = Address(id: id, label: 'Studio', details: '123 Main');

    await service.addAddress(address);
    expect(service.addresses.map((a) => a.id), [id]);

    final updated = address.copyWith(details: '456 Side');
    await service.updateAddress(updated);
    expect(service.getAddress(id)!.details, '456 Side');

    await service.deleteAddress(id);
    expect(service.addresses, isEmpty);
  });

  test('appointments default duration and are updated', () async {
    final service = AppointmentService();
    await service.init();

    const uuid = Uuid();
    final box = Hive.box('appointments');
    final id = uuid.v4();
    await box.put(id, {
      'id': id,
      'service': ServiceType.barber.name,
      'dateTime': DateTime.parse('2023-01-01').toIso8601String(),
    });

    final appt = service.getAppointment(id);
    expect(appt?.duration, const Duration(hours: 1));
    final stored = Map<String, dynamic>.from(box.get(id));
    expect(stored['duration'], 60);
  });

  test('providersFor filters by offerings', () async {
    final service = AppointmentService();
    await service.init();

    const uuid = Uuid();
    final p1Id = uuid.v4();
    final p2Id = uuid.v4();
    final p3Id = uuid.v4();
    final p1 = UserProfile(
      id: p1Id,
      firstName: 'Pro',
      lastName: 'One',
      roles: {UserRole.professional},
      offerings: [
        const ServiceOffering(type: ServiceType.barber, name: 'Cut', price: 10),
      ],
    );
    final p2 = UserProfile(
      id: p2Id,
      firstName: 'Pro',
      lastName: 'Two',
      roles: {UserRole.professional},
      offerings: [
        const ServiceOffering(type: ServiceType.nails, name: 'Nail', price: 20),
      ],
    );
    final p3 = UserProfile(
      id: p3Id,
      firstName: 'Pro',
      lastName: 'Three',
      roles: {UserRole.professional},
      offerings: [
        const ServiceOffering(type: ServiceType.tattoo, name: 'Ink', price: 50),
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

  test('renameUserId moves profile and updates appointments', () async {
    final service = AppointmentService();
    await service.init();
    const uuid = Uuid();
    final oldId = uuid.v4();
    final newId = uuid.v4();

    final user = UserProfile(id: oldId, firstName: 'Old', lastName: 'User');
    await service.addUser(user);

    final appt = Appointment(
      id: uuid.v4(),
      providerId: oldId,
      service: ServiceType.barber,
      dateTime: DateTime.parse('2023-01-01'),
      duration: const Duration(hours: 1),
    );
    await service.addAppointment(appt);

    await service.renameUserId(oldId, newId);

    expect(service.getUser(oldId), isNull);
    expect(service.getUser(newId), isNotNull);
    final updatedAppt = service.getAppointment(appt.id)!;
    expect(updatedAppt.providerId, newId);
  });

  test('addAppointment throws on provider time conflict', () async {
    final service = AppointmentService();
    await service.init();

    const uuid = Uuid();
    final providerId = uuid.v4();
    final appt1 = Appointment(
      id: uuid.v4(),
      providerId: providerId,
      service: ServiceType.barber,
      dateTime: DateTime(2023, 1, 1, 10),
      duration: const Duration(hours: 1),
    );
    final appt2 = Appointment(
      id: uuid.v4(),
      providerId: providerId,
      service: ServiceType.barber,
      dateTime: DateTime(2023, 1, 1, 10, 30),
      duration: const Duration(hours: 1),
    );
    await service.addAppointment(appt1);
    expect(() => service.addAppointment(appt2), throwsA(isA<StateError>()));
  });

  test('updateAppointment throws on provider time conflict', () async {
    final service = AppointmentService();
    await service.init();

    const uuid = Uuid();
    final providerId = uuid.v4();
    final appt1 = Appointment(
      id: uuid.v4(),
      providerId: providerId,
      service: ServiceType.barber,
      dateTime: DateTime(2023, 1, 1, 10),
      duration: const Duration(hours: 1),
    );
    final appt2 = Appointment(
      id: uuid.v4(),
      providerId: providerId,
      service: ServiceType.barber,
      dateTime: DateTime(2023, 1, 1, 12),
      duration: const Duration(hours: 1),
    );
    await service.addAppointment(appt1);
    await service.addAppointment(appt2);
    final moved = appt2.copyWith(dateTime: DateTime(2023, 1, 1, 10, 30));
    expect(() => service.updateAppointment(moved), throwsA(isA<StateError>()));
  });
}
