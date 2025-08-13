import 'package:flutter_test/flutter_test.dart';

import 'package:vogue_vault/services/role_provider.dart';
import 'package:vogue_vault/models/user_role.dart';

void main() {
  test('selectedRole is cleared when its role is removed', () {
    final provider = RoleProvider();
    provider.selectedRole = UserRole.customer;

    provider.setRoles({UserRole.professional});

    expect(provider.selectedRole, isNull);
  });

  test('selectedRole is cleared when removing selected role', () {
    final provider = RoleProvider();
    provider.selectedRole = UserRole.customer;

    provider.removeRole(UserRole.customer);

    expect(provider.selectedRole, isNull);
  });
}
