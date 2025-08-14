import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
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

  Map<String, Map<String, String>> get _users {
    final raw = _box.get(_usersKey);
    if (raw is Map) {
      return raw.map((key, value) {
        if (value is Map) {
          return MapEntry(
            key as String,
            Map<String, String>.from(value as Map),
          );
        }
        return MapEntry(key as String, <String, String>{});
      });
    }
    return <String, Map<String, String>>{};
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

  final Pbkdf2 _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 100000,
    bits: 256,
  );

  String _generateSalt([int length = 16]) {
    final rand = Random.secure();
    final saltBytes = List<int>.generate(length, (_) => rand.nextInt(256));
    return base64UrlEncode(saltBytes);
  }

  Future<String> _hashPassword(String password, String salt) async {
    final secretKey = await _pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: utf8.encode(salt),
    );
    final bytes = await secretKey.extractBytes();
    return base64UrlEncode(bytes);
  }

  Future<bool> login(String email, String password) async {
    _ensureInitialized();
    final users = _users;
    final user = users[email];
    if (user == null) {
      return false;
    }
    final salt = user['salt'];
    final storedHash = user['hash'];
    if (salt == null || storedHash == null) {
      return false;
    }
    final hashed = await _hashPassword(password, salt);
    if (storedHash == hashed) {
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
    final salt = _generateSalt();
    final hashed = await _hashPassword(password, salt);
    users[email] = {'salt': salt, 'hash': hashed};
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

