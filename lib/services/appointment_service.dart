import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/appointment.dart';
import '../models/service_type.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';
import '../models/customer.dart';
import '../models/address.dart';
import 'notification_service.dart';

class AppointmentService extends ChangeNotifier {
  static const _appointmentsBoxName = 'appointments';
  static const _usersBoxName = 'users';
  static const _customersBoxName = 'customers';
  static const _addressesBoxName = 'addresses';

  /// Underlying storage boxes. Hive may return values as
  /// `Map<dynamic, dynamic>` regardless of the generics provided. Using
  /// untyped boxes prevents runtime cast errors when retrieving stored maps.
  late Box _appointmentsBox;
  late Box _usersBox;
  late Box _customersBox;
  late Box _addressesBox;
  final NotificationService? _notificationService;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  AppointmentService({NotificationService? notificationService})
      : _notificationService = notificationService;

  Future<void> init() async {
    _appointmentsBox = await Hive.openBox(_appointmentsBoxName);
    _usersBox = await Hive.openBox(_usersBoxName);
    _customersBox = await Hive.openBox(_customersBoxName);
    _addressesBox = await Hive.openBox(_addressesBoxName);
    _initialized = true;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('AppointmentService has not been initialized.');
    }
  }

  List<Appointment> get appointments {
    if (!_initialized) return [];
    final appts = _appointmentsBox.values.map((m) {
      final map = Map<String, dynamic>.from(m);
      final appt = Appointment.fromMap(map);
      if (!map.containsKey('duration') ||
          !map.containsKey('customerId') ||
          !map.containsKey('guestName') ||
          !map.containsKey('location') ||
          !map.containsKey('price')) {
        _appointmentsBox.put(appt.id, appt.toMap());
      }
      return appt;
    }).toList();
    appts.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return appts;
  }

  List<UserProfile> get users {
    if (!_initialized) return [];
    return _usersBox.values.map((m) {
      final userMap = Map<String, dynamic>.from(m);
      return UserProfile.fromMap({
        ...userMap,
        'offerings':
            (userMap['offerings'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            <Map<String, dynamic>>[],
      });
    }).toList();
  }

  List<Customer> get customers {
    if (!_initialized) return [];
    return _customersBox.values
        .map((m) => Customer.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  List<Address> get addresses {
    if (!_initialized) return [];
    return _addressesBox.values
        .map((m) => Address.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  List<UserProfile> get providers =>
      users.where((u) => u.roles.contains(UserRole.professional)).toList();

  List<UserProfile> providersFor(ServiceType type) =>
      providers.where((p) => p.offerings.any((o) => o.type == type)).toList();

  UserProfile? getUser(String id) {
    _ensureInitialized();
    final map = _usersBox.get(id);
    if (map == null) return null;
    final userMap = Map<String, dynamic>.from(map);
    return UserProfile.fromMap({
      ...userMap,
      'offerings':
          (userMap['offerings'] as List?)
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
    final appt = Appointment.fromMap(appointmentMap);
    if (!appointmentMap.containsKey('duration') ||
        !appointmentMap.containsKey('customerId') ||
        !appointmentMap.containsKey('guestName') ||
        !appointmentMap.containsKey('location') ||
        !appointmentMap.containsKey('price')) {
      _appointmentsBox.put(appt.id, appt.toMap());
    }
    return appt;
  }

  Customer? getCustomer(String id) {
    _ensureInitialized();
    final map = _customersBox.get(id);
    if (map == null) return null;
    return Customer.fromMap(Map<String, dynamic>.from(map));
  }

  Address? getAddress(String id) {
    _ensureInitialized();
    final map = _addressesBox.get(id);
    if (map == null) return null;
    return Address.fromMap(Map<String, dynamic>.from(map));
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
        .map((m) => Appointment.fromMap(Map<String, dynamic>.from(m)))
        .where((a) => a.providerId == id)
        .toList();

    if (reassignedUserId != null) {
      for (final appt in affected) {
        final updated = appt.copyWith(providerId: reassignedUserId);
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

  Future<void> addCustomer(Customer customer) async {
    _ensureInitialized();
    await _customersBox.put(customer.id, customer.toMap());
    notifyListeners();
  }

  Future<void> updateCustomer(Customer customer) async {
    _ensureInitialized();
    await _customersBox.put(customer.id, customer.toMap());
    notifyListeners();
  }

  Future<void> deleteCustomer(String id) async {
    _ensureInitialized();
    await _customersBox.delete(id);
    notifyListeners();
  }

  Future<void> addAddress(Address address) async {
    _ensureInitialized();
    await _addressesBox.put(address.id, address.toMap());
    notifyListeners();
  }

  Future<void> updateAddress(Address address) async {
    _ensureInitialized();
    await _addressesBox.put(address.id, address.toMap());
    notifyListeners();
  }

  Future<void> deleteAddress(String id) async {
    _ensureInitialized();
    await _addressesBox.delete(id);
    notifyListeners();
  }

  bool _hasConflict(Appointment appointment) {
    final providerId = appointment.providerId;
    if (providerId == null) return false;
    final newStart = appointment.dateTime;
    final newEnd = newStart.add(appointment.duration);
    return appointments.any((existing) {
      if (existing.providerId != providerId) return false;
      if (existing.id == appointment.id) return false;
      final existingStart = existing.dateTime;
      final existingEnd = existingStart.add(existing.duration);
      return newStart.isBefore(existingEnd) && existingStart.isBefore(newEnd);
    });
  }

  Future<void> addAppointment(Appointment appointment) async {
    _ensureInitialized();
    if (_hasConflict(appointment)) {
      throw StateError('Appointment conflicts with existing booking.');
    }
    // providerId is persisted via the appointment's toMap representation.
    await _appointmentsBox.put(appointment.id, appointment.toMap());
    await _notificationService?.scheduleAppointmentReminder(appointment);
    notifyListeners();
  }

  Future<void> updateAppointment(Appointment appointment) async {
    _ensureInitialized();
    if (_hasConflict(appointment)) {
      throw StateError('Appointment conflicts with existing booking.');
    }
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
      if (appt.providerId == oldId) {
        final updated = appt.copyWith(providerId: newId);
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
      _customersBox.close();
      _addressesBox.close();
    }
    super.dispose();
  }
}
