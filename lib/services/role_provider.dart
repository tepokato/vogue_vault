import 'package:flutter/foundation.dart';

import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/appointment_service.dart';

/// Provides the currently selected role for the authenticated user and exposes
/// the set of roles available on that user's [UserProfile].
class RoleProvider extends ChangeNotifier {
  RoleProvider(this._auth, this._appointments) {
    _auth.addListener(_syncRoles);
    _appointments.addListener(_syncRoles);
  }

  final AuthService _auth;
  final AppointmentService _appointments;

  UserRole? _selectedRole;

  /// The set of roles available for the current user. Falls back to
  /// `[UserRole.customer]` when no user is logged in or found.
  Set<UserRole> get roles {
    final userId = _auth.currentUser;
    if (userId == null) return {UserRole.customer};
    return _appointments.getUser(userId)?.roles ?? {UserRole.customer};
  }

  UserRole? get selectedRole => _selectedRole;

  set selectedRole(UserRole? role) {
    _selectedRole = role;
    notifyListeners();
  }

  void clearRole() {
    _selectedRole = null;
    notifyListeners();
  }

  void _syncRoles() {
    if (_selectedRole != null && !roles.contains(_selectedRole)) {
      _selectedRole = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _auth.removeListener(_syncRoles);
    _appointments.removeListener(_syncRoles);
    super.dispose();
  }
}
