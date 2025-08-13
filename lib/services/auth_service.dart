import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthService extends ChangeNotifier {
  static const _boxName = 'auth';
  static const _usersKey = 'users';
  static const _currentUserKey = 'currentUser';

  late Box<Map<String, String>> _box;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> init() async {
    _box = await Hive.openBox<Map<String, String>>(_boxName);
    _initialized = true;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('AuthService has not been initialized.');
    }
  }

  Map<String, String> get _users =>
      _box.get(_usersKey) ?? <String, String>{};

  String? get currentUser {
    _ensureInitialized();
    return _box.get(_currentUserKey)?['email'];
  }

  bool get isLoggedIn => currentUser != null;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> login(String email, String password) async {
    _ensureInitialized();
    final users = _users;
    final storedPassword = users[email];
    final hashed = _hashPassword(password);
    if (storedPassword == hashed) {
      await _box.put(_currentUserKey, {'email': email});
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> register(String email, String password) async {
    _ensureInitialized();
    final users = _users;
    if (users.containsKey(email)) {
      throw StateError('User with email $email already exists.');
    }
    users[email] = _hashPassword(password);
    await _box.put(_usersKey, users);
    await _box.put(_currentUserKey, {'email': email});
    notifyListeners();
  }

  Future<void> logout() async {
    _ensureInitialized();
    await _box.delete(_currentUserKey);
    notifyListeners();
  }
}

