import 'package:flutter/foundation.dart';

import '../models/user_role.dart';

class RoleProvider extends ChangeNotifier {
  UserRole? _selectedRole;
  Set<UserRole> _roles = {UserRole.customer, UserRole.professional};

  UserRole? get selectedRole => _selectedRole;
  Set<UserRole> get roles => _roles;

  set selectedRole(UserRole? role) {
    _selectedRole = role;
    notifyListeners();
  }

  void setRoles(Set<UserRole> roles) {
    _roles = roles;
    notifyListeners();
  }

  void clearRole() {
    _selectedRole = null;
    notifyListeners();
  }
}
