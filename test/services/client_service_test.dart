import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:vogue_vault/services/appointment_service.dart';
import 'package:vogue_vault/services/client_service.dart';
import 'package:vogue_vault/models/client.dart';
import 'package:vogue_vault/models/appointment.dart';
import 'package:vogue_vault/models/service_type.dart';

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

  test('client CRUD operations', () async {
    final apptService = AppointmentService();
    await apptService.init();
    final service = ClientService(apptService);
    await service.init();

    const uuid = Uuid();
    final client = Client(id: uuid.v4(), name: 'Alice', contact: '1');
    await service.addClient(client);
    expect(service.clients, hasLength(1));

    final updated = client.copyWith(name: 'Bob');
    await service.updateClient(updated);
    expect(service.getClient(client.id)?.name, 'Bob');

    await service.deleteClient(client.id);
    expect(service.clients, isEmpty);
  });

  test('history returns only past appointments', () async {
    final apptService = AppointmentService();
    await apptService.init();
    final service = ClientService(apptService);
    await service.init();

    const uuid = Uuid();
    final clientId = uuid.v4();
    await service.addClient(Client(id: clientId, name: 'A', contact: '1'));

    final past = Appointment(
      id: uuid.v4(),
      clientId: clientId,
      service: ServiceType.barber,
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      duration: const Duration(hours: 1),
    );
    final future = Appointment(
      id: uuid.v4(),
      clientId: clientId,
      service: ServiceType.barber,
      dateTime: DateTime.now().add(const Duration(days: 1)),
      duration: const Duration(hours: 1),
    );
    await apptService.addAppointment(past);
    await apptService.addAppointment(future);

    final hist = service.history(clientId);
    expect(hist.map((a) => a.id), [past.id]);
  });
}

