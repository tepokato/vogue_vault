import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/appointment.dart';
import '../models/service_type.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';

class AppointmentService extends ChangeNotifier {
  static const _appointmentsBoxName = 'appointments';
  static const _usersBoxName = 'users';

  /// Underlying storage boxes. Hive may return values as
  /// `Map<dynamic, dynamic>` regardless of the generics provided. Using
  /// untyped boxes prevents runtime cast errors when retrieving stored maps.
  late Box _appointmentsBox;
  late Box _usersBox;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    _appointmentsBox = await Hive.openBox(_appointmentsBoxName);
    _usersBox = await Hive.openBox(_usersBoxName);
    _initialized = true;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('AppointmentService has not been initialized.');
    }
  }

  List<Appointment> get appointments {
    if (!_initialized) return [];
    final appts = _appointmentsBox.values
        .map((m) =>
            Appointment.fromMap(Map<String, dynamic>.from(m)))
        .toList();
    appts.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return appts;
  }

  List<UserProfile> get users {
    if (!_initialized) return [];
    return _usersBox.values.map((m) {
      final userMap = Map<String, dynamic>.from(m);
      return UserProfile.fromMap({
        ...userMap,
        'offerings': (userMap['offerings'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            <Map<String, dynamic>>[],
      });
    }).toList();
  }
  List<UserProfile> get providers =>
      users.where((u) => u.roles.contains(UserRole.professional)).toList();

  List<UserProfile> providersFor(ServiceType type) =>
      providers
          .where((p) => p.offerings.any((o) => o.type == type))
          .toList();

  UserProfile? getUser(String id) {
    _ensureInitialized();
    final map = _usersBox.get(id);
    if (map == null) return null;
    final userMap = Map<String, dynamic>.from(map);
    return UserProfile.fromMap({
      ...userMap,
      'offerings': (userMap['offerings'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          <Map<String, dynamic>>[],
    });
  }

  Appointment? getAppointment(String id) {
    _ensureInitialized();
    final map = _appointmentsBox.get(id);
    if (map == null) return null;
    final appointmentMap = Map<String, dynamic>.from(map);
    return Appointment.fromMap(appointmentMap);
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
        .map((m) =>
            Appointment.fromMap(Map<String, dynamic>.from(m)))
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

  Future<void> renameUserId(String oldId, String newId) async {
    _ensureInitialized();
    final userMap = _usersBox.get(oldId);
    if (userMap != null) {
      await _usersBox.put(newId, userMap);
      await _usersBox.delete(oldId);
    }
    for (final m in _appointmentsBox.values) {
      final map = Map<String, dynamic>.from(m);
      final appt = Appointment.fromMap(map);
      var updated = appt;
      if (appt.clientId == oldId) {
        updated = updated.copyWith(clientId: newId);
      }
      if (appt.providerId == oldId) {
        updated = updated.copyWith(providerId: newId);
      }
      if (updated != appt) {
        await _appointmentsBox.put(updated.id, updated.toMap());
      }
    }
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
