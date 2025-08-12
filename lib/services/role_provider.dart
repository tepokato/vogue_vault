import 'package:flutter/foundation.dart';

import '../models/user_role.dart';

class RoleProvider extends ChangeNotifier {
  UserRole? _selectedRole;
  final Set<UserRole> _roles = {UserRole.customer, UserRole.professional};

  UserRole? get selectedRole => _selectedRole;
  Set<UserRole> get roles => Set.unmodifiable(_roles);

  set selectedRole(UserRole? role) {
    _selectedRole = role;
    notifyListeners();
  }

  void setRoles(Set<UserRole> roles) {
    _roles
      ..clear()
      ..addAll(roles);
    notifyListeners();
  }

  void addRole(UserRole role) {
    _roles.add(role);
    notifyListeners();
  }

  void removeRole(UserRole role) {
    _roles.remove(role);
    notifyListeners();
  }

  void clearRole() {
    _selectedRole = null;
    notifyListeners();
  }
}
