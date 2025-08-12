import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthService extends ChangeNotifier {
  static const _boxName = 'auth';
  static const _usersKey = 'users';
  static const _currentUserKey = 'currentUser';

  late Box _box;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    _initialized = true;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('AuthService has not been initialized.');
    }
  }

  Map<String, String> get _users =>
      Map<String, String>.from(_box.get(_usersKey, defaultValue: <String, String>{}));

  String? get currentUser {
    _ensureInitialized();
    return _box.get(_currentUserKey) as String?;
  }

  bool get isLoggedIn => currentUser != null;

  Future<bool> login(String email, String password) async {
    _ensureInitialized();
    final users = _users;
    final storedPassword = users[email];
    if (storedPassword == password) {
      await _box.put(_currentUserKey, email);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> register(String email, String password) async {
    _ensureInitialized();
    final users = _users;
    users[email] = password;
    await _box.put(_usersKey, users);
    await _box.put(_currentUserKey, email);
    notifyListeners();
  }

  Future<void> logout() async {
    _ensureInitialized();
    await _box.delete(_currentUserKey);
    notifyListeners();
  }
}

