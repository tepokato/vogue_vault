import 'package:flutter_test/flutter_test.dart';
import 'package:vogue_vault/models/user_profile.dart';
import 'package:vogue_vault/models/user_role.dart';
import 'package:vogue_vault/services/role_provider.dart';
import 'package:vogue_vault/services/auth_service.dart';
import 'package:vogue_vault/services/appointment_service.dart';

class _FakeAuthService extends AuthService {
  String? _user;
  void setUser(String? id) {
    _user = id;
    notifyListeners();
  }

  @override
  String? get currentUser => _user;
}

class _FakeAppointmentService extends AppointmentService {
  final Map<String, UserProfile> _users = {};

  @override
  UserProfile? getUser(String id) => _users[id];

  @override
  Future<void> addUser(UserProfile user) async {
    _users[user.id] = user;
    notifyListeners();
  }

  @override
  Future<void> updateUser(UserProfile user) async {
    _users[user.id] = user;
    notifyListeners();
  }
}

void main() {
  test('returns empty set when no user logged in', () {
    final auth = _FakeAuthService();
    final service = _FakeAppointmentService();
    final provider = RoleProvider(auth, service);

    expect(provider.roles, isEmpty);
  });

  test('role changes in user profile propagate to provider', () async {
    final auth = _FakeAuthService();
    final service = _FakeAppointmentService();
    await service.addUser(UserProfile(
      id: 'u1',
      firstName: 'A',
      lastName: 'B',
      roles: {UserRole.customer},
    ));
    auth.setUser('u1');
    final provider = RoleProvider(auth, service);

    expect(provider.roles, {UserRole.customer});
    provider.selectedRole = UserRole.customer;

    await service.updateUser(UserProfile(
      id: 'u1',
      firstName: 'A',
      lastName: 'B',
      roles: {UserRole.professional},
    ));

    expect(provider.roles, {UserRole.professional});
    expect(provider.selectedRole, isNull);
  });
}
