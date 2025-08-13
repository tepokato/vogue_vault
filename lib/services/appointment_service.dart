import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/appointment.dart';
import '../models/service_type.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';

class AppointmentService extends ChangeNotifier {
  static const _appointmentsBoxName = 'appointments';
  static const _usersBoxName = 'users';

  late Box<Map<String, dynamic>> _appointmentsBox;
  late Box<Map<String, dynamic>> _usersBox;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    _appointmentsBox =
        await Hive.openBox<Map<String, dynamic>>(_appointmentsBoxName);
    _usersBox = await Hive.openBox<Map<String, dynamic>>(_usersBoxName);
    _initialized = true;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('AppointmentService has not been initialized.');
    }
  }

  Map<String, dynamic> _withProviderId(Map<String, dynamic> map) {
    return {
      ...map,
      'providerId': map['providerId'] ?? '',
    };
  }

  List<Appointment> get appointments {
    if (!_initialized) return [];
    return _appointmentsBox.values
        .map((m) => Appointment.fromMap(
            _withProviderId(Map<String, dynamic>.from(m))))
        .toList();
  }

  List<UserProfile> get users {
    if (!_initialized) return [];
    return _usersBox.values.map((m) {
      final userMap = Map<String, dynamic>.from(m);
      return UserProfile.fromMap({
        ...userMap,
        'services': userMap['services'] ?? <String>[],
      });
    }).toList();
  }

  List<UserProfile> get clients =>
      users.where((u) => u.roles.contains(UserRole.customer)).toList();

  List<UserProfile> get providers =>
      users.where((u) => u.roles.contains(UserRole.professional)).toList();

  List<UserProfile> providersFor(ServiceType type) =>
      providers.where((p) => p.services.contains(type)).toList();

  UserProfile? getUser(String id) {
    _ensureInitialized();
    final map = _usersBox.get(id);
    if (map == null) return null;
    final userMap = Map<String, dynamic>.from(map);
    return UserProfile.fromMap({
      ...userMap,
      'services': userMap['services'] ?? <String>[],
    });
  }

  Appointment? getAppointment(String id) {
    _ensureInitialized();
    final map = _appointmentsBox.get(id);
    if (map == null) return null;
    final appointmentMap = Map<String, dynamic>.from(map);
    // Ensure providerId is available for older stored appointments.
    return Appointment.fromMap(_withProviderId(appointmentMap));
  }

  Future<void> addUser(UserProfile user) async {
    _ensureInitialized();
    await _usersBox.put(user.id, user.toMap());
    notifyListeners();
  }

  Future<void> updateUser(UserProfile user) async {
    _ensureInitialized();
    await _usersBox.put(user.id, user.toMap());
    notifyListeners();
  }

  Future<void> deleteUser(String id, {String? reassignedUserId}) async {
    _ensureInitialized();

    final affected = _appointmentsBox.values
        .map((m) => Appointment.fromMap(
            _withProviderId(Map<String, dynamic>.from(m))))
        .where((a) => a.clientId == id || a.providerId == id)
        .toList();

    if (reassignedUserId != null) {
      for (final appt in affected) {
        final updated = appt.copyWith(
          clientId: appt.clientId == id ? reassignedUserId : appt.clientId,
          providerId: appt.providerId == id ? reassignedUserId : appt.providerId,
        );
        await _appointmentsBox.put(updated.id, updated.toMap());
      }
    } else {
      for (final appt in affected) {
        await _appointmentsBox.delete(appt.id);
      }
    }

    await _usersBox.delete(id);
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
      _usersBox.close();
    }
    super.dispose();
  }
}
