import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/appointment.dart';
import '../models/client.dart';

class AppointmentService extends ChangeNotifier {
  static const _appointmentsBoxName = 'appointments';
  static const _clientsBoxName = 'clients';

  late Box<Map<String, dynamic>> _appointmentsBox;
  late Box<Map<String, dynamic>> _clientsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _appointmentsBox =
        await Hive.openBox<Map<String, dynamic>>(_appointmentsBoxName);
    _clientsBox =
        await Hive.openBox<Map<String, dynamic>>(_clientsBoxName);
  }

  List<Appointment> get appointments =>
      _appointmentsBox.values.map(Appointment.fromMap).toList();

  List<Client> get clients =>
      _clientsBox.values.map(Client.fromMap).toList();

  Client? getClient(String id) {
    final map = _clientsBox.get(id);
    if (map == null) return null;
    return Client.fromMap(map);
  }

  Appointment? getAppointment(String id) {
    final map = _appointmentsBox.get(id);
    if (map == null) return null;
    return Appointment.fromMap(map);
  }

  Future<void> addClient(Client client) async {
    await _clientsBox.put(client.id, client.toMap());
    notifyListeners();
  }

  Future<void> updateClient(Client client) async {
    await _clientsBox.put(client.id, client.toMap());
    notifyListeners();
  }

  Future<void> deleteClient(String id) async {
    await _clientsBox.delete(id);
    notifyListeners();
  }

  Future<void> addAppointment(Appointment appointment) async {
    await _appointmentsBox.put(appointment.id, appointment.toMap());
    notifyListeners();
  }

  Future<void> updateAppointment(Appointment appointment) async {
    await _appointmentsBox.put(appointment.id, appointment.toMap());
    notifyListeners();
  }

  Future<void> deleteAppointment(String id) async {
    await _appointmentsBox.delete(id);
    notifyListeners();
  }

  @override
  void dispose() {
    _appointmentsBox.close();
    _clientsBox.close();
    super.dispose();
  }
}
