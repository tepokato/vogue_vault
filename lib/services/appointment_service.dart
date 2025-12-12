import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/appointment.dart';
import '../models/service_type.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';
import '../models/customer.dart';
import '../models/address.dart';
import 'notification_service.dart';

/// Handles persistence and validation for appointments, users, customers, and
/// addresses. The service owns the Hive boxes and keeps them in sync with
/// in-memory models.
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

  /// Opens backing stores for all managed entity types. Call this before
  /// accessing any getters or mutations to avoid runtime errors.
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

  /// Returns true when the stored appointment map is missing fields that were
  /// introduced in newer app versions. Used to opportunistically upgrade
  /// legacy data when it is read.
  bool _isLegacyAppointmentMap(Map<String, dynamic> map) {
    return !map.containsKey('duration') ||
        !map.containsKey('customerId') ||
        !map.containsKey('guestName') ||
        !map.containsKey('location') ||
        !map.containsKey('price');
  }

  /// Converts loosely typed Hive data into an [Appointment] while also writing
  /// back any missing fields to keep stored records consistent.
  Appointment _deserializeAppointment(dynamic value) {
    final map = Map<String, dynamic>.from(value);
    final appointment = Appointment.fromMap(map);
    if (_isLegacyAppointmentMap(map)) {
      _appointmentsBox.put(appointment.id, appointment.toMap());
    }
    return appointment;
  }

  /// Converts stored user maps into [UserProfile] instances and normalizes
  /// nested offerings to avoid type exceptions from Hive's dynamic values.
  UserProfile _deserializeUser(dynamic value) {
    final userMap = Map<String, dynamic>.from(value);
    return UserProfile.fromMap({
      ...userMap,
      'offerings':
          (userMap['offerings'] as List?)
                  ?.map((e) => Map<String, dynamic>.from(e as Map))
                  .toList() ??
              <Map<String, dynamic>>[],
    });
  }

  List<Appointment> get appointments {
    if (!_initialized) return [];
    final appts =
        _appointmentsBox.values.map(_deserializeAppointment).toList();
    appts.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return appts;
  }

  List<UserProfile> get users {
    if (!_initialized) return [];
    return _usersBox.values.map(_deserializeUser).toList();
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
    return _deserializeUser(map);
  }

  Appointment? getAppointment(String id) {
    _ensureInitialized();
    final map = _appointmentsBox.get(id);
    if (map == null) return null;
    return _deserializeAppointment(map);
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
    await _saveEntity(_usersBox, user.id, user.toMap());
  }

  Future<void> updateUser(UserProfile user) async {
    await _saveEntity(_usersBox, user.id, user.toMap());
  }

  /// Removes a provider and optionally reassigns their appointments to another
  /// provider. If no reassignment is provided, the related appointments are
  /// deleted to avoid orphaned bookings.
  Future<void> deleteUser(String id, {String? reassignedUserId}) async {
    _ensureInitialized();

    final affected = _appointmentsBox.values
        .map(_deserializeAppointment)
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
    await _saveEntity(_customersBox, customer.id, customer.toMap());
  }

  Future<void> updateCustomer(Customer customer) async {
    await _saveEntity(_customersBox, customer.id, customer.toMap());
  }

  Future<void> deleteCustomer(String id) async {
    _ensureInitialized();
    await _customersBox.delete(id);
    notifyListeners();
  }

  Future<void> addAddress(Address address) async {
    await _saveEntity(_addressesBox, address.id, address.toMap());
  }

  Future<void> updateAddress(Address address) async {
    await _saveEntity(_addressesBox, address.id, address.toMap());
  }

  Future<void> deleteAddress(String id) async {
    _ensureInitialized();
    await _addressesBox.delete(id);
    notifyListeners();
  }

  /// Checks whether the provided appointment overlaps with any existing
  /// appointment for the same provider. The comparison ignores the appointment
  /// being edited by matching on the ID.
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

  Future<void> addAppointment(
    Appointment appointment, {
    BuildContext? context,
    String? serviceName,
  }) async {
    _ensureInitialized();
    if (_hasConflict(appointment)) {
      throw StateError('Appointment conflicts with existing booking.');
    }
    // providerId is persisted via the appointment's toMap representation to
    // keep storage and in-memory data aligned with the same source of truth.
    await _appointmentsBox.put(appointment.id, appointment.toMap());
    await _notificationService?.scheduleAppointmentReminder(
      appointment,
      context: context,
      serviceName: serviceName,
    );
    notifyListeners();
  }

  Future<void> updateAppointment(
    Appointment appointment, {
    BuildContext? context,
    String? serviceName,
  }) async {
    _ensureInitialized();
    if (_hasConflict(appointment)) {
      throw StateError('Appointment conflicts with existing booking.');
    }
    // providerId is persisted via the appointment's toMap representation to
    // keep storage and in-memory data aligned with the same source of truth.
    await _appointmentsBox.put(appointment.id, appointment.toMap());
    await _notificationService?.rescheduleAppointmentReminder(
      appointment,
      context: context,
      serviceName: serviceName,
    );
    notifyListeners();
  }

  Future<void> deleteAppointment(String id) async {
    _ensureInitialized();
    await _notificationService?.cancelAppointmentReminder(id);
    await _appointmentsBox.delete(id);
    notifyListeners();
  }

  Future<void> _saveEntity(Box box, String id, Map<String, dynamic> data) async {
    _ensureInitialized();
    await box.put(id, data);
    notifyListeners();
  }

  /// Updates stored appointments to reference a user's new identifier. This is
  /// primarily used when an email change alters the canonical user ID.
  Future<void> renameUserId(String oldId, String newId) async {
    _ensureInitialized();
    final userMap = _usersBox.get(oldId);
    if (userMap != null) {
      await _usersBox.put(newId, userMap);
      await _usersBox.delete(oldId);
    }
    for (final m in _appointmentsBox.values) {
      final appt = _deserializeAppointment(m);
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
