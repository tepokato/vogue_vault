import 'package:flutter/foundation.dart';

import '../models/user_role.dart';

class RoleProvider extends ChangeNotifier {
  UserRole? _selectedRole;

  UserRole? get selectedRole => _selectedRole;

  set selectedRole(UserRole? role) {
    _selectedRole = role;
    notifyListeners();
  }
}
