import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/client.dart';
import '../models/appointment.dart';
import 'appointment_service.dart';

class ClientService extends ChangeNotifier {
  static const _clientsBoxName = 'clients';

  final AppointmentService _appointmentService;
  late Box _clientsBox;
  bool _initialized = false;

  ClientService(this._appointmentService);

  bool get isInitialized => _initialized;

  Future<void> init() async {
    _clientsBox = await Hive.openBox(_clientsBoxName);
    _initialized = true;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('ClientService has not been initialized.');
    }
  }

  List<Client> get clients {
    if (!_initialized) return [];
    return _clientsBox.values
        .map((m) => Client.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  Client? getClient(String id) {
    _ensureInitialized();
    final map = _clientsBox.get(id);
    if (map == null) return null;
    return Client.fromMap(Map<String, dynamic>.from(map));
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

  Future<void> deleteClient(String id) async {
    _ensureInitialized();
    await _clientsBox.delete(id);
    notifyListeners();
  }

  List<Appointment> history(String clientId) {
    _ensureInitialized();
    final now = DateTime.now();
    return _appointmentService.appointments
        .where((a) => a.clientId == clientId && a.dateTime.isBefore(now))
        .toList();
  }

  @override
  void dispose() {
    if (_initialized) {
      _clientsBox.close();
    }
    super.dispose();
  }
}

