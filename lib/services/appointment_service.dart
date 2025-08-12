import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/appointment.dart';
import '../models/client.dart';
import '../models/service_provider.dart';

class AppointmentService extends ChangeNotifier {
  static const _appointmentsBoxName = 'appointments';
  static const _clientsBoxName = 'clients';
  static const _providersBoxName = 'providers';

  late Box<Map<String, dynamic>> _appointmentsBox;
  late Box<Map<String, dynamic>> _clientsBox;
  late Box<Map<String, dynamic>> _providersBox;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    await Hive.initFlutter();
    _appointmentsBox =
        await Hive.openBox<Map<String, dynamic>>(_appointmentsBoxName);
    _clientsBox =
        await Hive.openBox<Map<String, dynamic>>(_clientsBoxName);
    _providersBox =
        await Hive.openBox<Map<String, dynamic>>(_providersBoxName);
    _initialized = true;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('AppointmentService has not been initialized.');
    }
  }

  List<Appointment> get appointments {
    if (!_initialized) return [];
    return _appointmentsBox.values
        .map((m) => Appointment.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  List<Client> get clients {
    if (!_initialized) return [];
    // photoUrl is parsed within Client.fromMap.
    return _clientsBox.values
        .map((m) => Client.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  List<ServiceProvider> get providers {
    if (!_initialized) return [];
    // photoUrl is parsed within ServiceProvider.fromMap.
    return _providersBox.values
        .map((m) => ServiceProvider.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  Client? getClient(String id) {
    _ensureInitialized();
    final map = _clientsBox.get(id);
    if (map == null) return null;
    final clientMap = Map<String, dynamic>.from(map);
    return Client.fromMap(clientMap);
  }

  Appointment? getAppointment(String id) {
    _ensureInitialized();
    final map = _appointmentsBox.get(id);
    if (map == null) return null;
    final appointmentMap = Map<String, dynamic>.from(map);
    // Ensure providerId is available for older stored appointments.
    return Appointment.fromMap({
      ...appointmentMap,
      'providerId': appointmentMap['providerId'] ?? '',
    });
  }

  ServiceProvider? getProvider(String id) {
    _ensureInitialized();
    final map = _providersBox.get(id);
    if (map == null) return null;
    final providerMap = Map<String, dynamic>.from(map);
    return ServiceProvider.fromMap(providerMap);
  }

  Future<void> addClient(Client client) async {
    _ensureInitialized();
    // photoUrl is persisted via the client's toMap representation.
    await _clientsBox.put(client.id, client.toMap());
    notifyListeners();
  }

  Future<void> updateClient(Client client) async {
    _ensureInitialized();
    // photoUrl is persisted via the client's toMap representation.
    await _clientsBox.put(client.id, client.toMap());
    notifyListeners();
  }

  Future<void> deleteClient(String id, {String? reassignedClientId}) async {
    _ensureInitialized();

    final affected = _appointmentsBox.values
        .map(Appointment.fromMap)
        .where((a) => a.clientId == id)
        .toList();

    if (reassignedClientId != null) {
      for (final appt in affected) {
        final updated = appt.copyWith(clientId: reassignedClientId);
        await _appointmentsBox.put(updated.id, updated.toMap());
      }
    } else {
      for (final appt in affected) {
        await _appointmentsBox.delete(appt.id);
      }
    }

    await _clientsBox.delete(id);
    notifyListeners();
  }

  Future<void> addProvider(ServiceProvider provider) async {
    _ensureInitialized();
    // photoUrl is persisted via the provider's toMap representation.
    await _providersBox.put(provider.id, provider.toMap());
    notifyListeners();
  }

  Future<void> updateProvider(ServiceProvider provider) async {
    _ensureInitialized();
    // photoUrl is persisted via the provider's toMap representation.
    await _providersBox.put(provider.id, provider.toMap());
    notifyListeners();
  }

  Future<void> deleteProvider(String id, {String? reassignedProviderId}) async {
    _ensureInitialized();

    final affected = _appointmentsBox.values
        .map(Appointment.fromMap)
        .where((a) => a.providerId == id)
        .toList();

    if (reassignedProviderId != null) {
      for (final appt in affected) {
        final updated = appt.copyWith(providerId: reassignedProviderId);
        await _appointmentsBox.put(updated.id, updated.toMap());
      }
    } else {
      for (final appt in affected) {
        await _appointmentsBox.delete(appt.id);
      }
    }

    await _providersBox.delete(id);
    notifyListeners();
  }

  Future<void> addAppointment(Appointment appointment) async {
    _ensureInitialized();
    // providerId is persisted via the appointment's toMap representation.
    await _appointmentsBox.put(appointment.id, appointment.toMap());
    notifyListeners();
  }

  Future<void> updateAppointment(Appointment appointment) async {
    _ensureInitialized();
    // providerId is persisted via the appointment's toMap representation.
    await _appointmentsBox.put(appointment.id, appointment.toMap());
    notifyListeners();
  }

  Future<void> deleteAppointment(String id) async {
    _ensureInitialized();
    await _appointmentsBox.delete(id);
    notifyListeners();
  }

  @override
  void dispose() {
    if (_initialized) {
      _appointmentsBox.close();
      _clientsBox.close();
      _providersBox.close();
    }
    super.dispose();
  }
}
