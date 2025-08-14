import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthService extends ChangeNotifier {
  static const _boxName = 'auth';
  static const _usersKey = 'users';
  static const _currentUserKey = 'currentUser';

  /// Underlying storage box. We avoid using a typed [Box] here because
  /// Hive may return values as `Map<dynamic, dynamic>` regardless of the
  /// generics provided. Using an untyped box prevents runtime cast errors
  /// when retrieving stored maps.
  late Box _box;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> init() async {
    // Open the box without generics to bypass implicit casts from Hive.
    _box = await Hive.openBox(_boxName);
    _initialized = true;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('AuthService has not been initialized.');
    }
  }

  Map<String, String> get _users {
    final raw = _box.get(_usersKey);
    if (raw is Map) {
      return Map<String, String>.from(raw);
    }
    return <String, String>{};
  }

  String? get currentUser {
    _ensureInitialized();
    final raw = _box.get(_currentUserKey);
    if (raw is Map) {
      return raw['email'] as String?;
    }
    return null;
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

