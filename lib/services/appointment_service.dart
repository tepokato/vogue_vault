import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/appointment.dart';
import '../models/client.dart';

class AppointmentService extends ChangeNotifier {
  static const _appointmentsBoxName = 'appointments';
  static const _clientsBoxName = 'clients';

  late Box<Map<String, dynamic>> _appointmentsBox;
  late Box<Map<String, dynamic>> _clientsBox;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    await Hive.initFlutter();
    _appointmentsBox =
        await Hive.openBox<Map<String, dynamic>>(_appointmentsBoxName);
    _clientsBox =
        await Hive.openBox<Map<String, dynamic>>(_clientsBoxName);
    _initialized = true;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('AppointmentService has not been initialized.');
    }
  }

  List<Appointment> get appointments {
    if (!_initialized) return [];
    return _appointmentsBox.values.map(Appointment.fromMap).toList();
  }

  List<Client> get clients {
    if (!_initialized) return [];
    return _clientsBox.values.map(Client.fromMap).toList();
  }

  Client? getClient(String id) {
    _ensureInitialized();
    final map = _clientsBox.get(id);
    if (map == null) return null;
    return Client.fromMap(map);
  }

  Appointment? getAppointment(String id) {
    _ensureInitialized();
    final map = _appointmentsBox.get(id);
    if (map == null) return null;
    return Appointment.fromMap(map);
  }

  Future<void> addClient(Client client) async {
    _ensureInitialized();
    await _clientsBox.put(client.id, client.toMap());
    notifyListeners();
  }

  Future<void> updateClient(Client client) async {
    _ensureInitialized();
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

  Future<void> addAppointment(Appointment appointment) async {
    _ensureInitialized();
    await _appointmentsBox.put(appointment.id, appointment.toMap());
    notifyListeners();
  }

  Future<void> updateAppointment(Appointment appointment) async {
    _ensureInitialized();
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
    }
    super.dispose();
  }
}
