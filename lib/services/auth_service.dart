import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthService extends ChangeNotifier {
  static const _boxName = 'auth';
  static const _usersKey = 'users';
  static const _currentUserKey = 'currentUser';
  static const _encryptionKey = 'authEncryptionKey';

  /// Underlying storage box. We avoid using a typed [Box] here because
  /// Hive may return values as `Map<dynamic, dynamic>` regardless of the
  /// generics provided. Using an untyped box prevents runtime cast errors
  /// when retrieving stored maps.
  late Box _box;
  bool _initialized = false;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool get isInitialized => _initialized;

  Future<void> init() async {
    final key = await _getOrCreateEncryptionKey();
    final cipher = HiveAesCipher(key);
    try {
      // Attempt to open as an encrypted box.
      _box = await Hive.openBox(_boxName, encryptionCipher: cipher);
    } on HiveError {
      // If opening fails, migrate data from an unencrypted box.
      final legacyBox = await Hive.openBox(_boxName);
      final legacyData = Map<dynamic, dynamic>.from(legacyBox.toMap());
      await legacyBox.deleteFromDisk();
      _box = await Hive.openBox(_boxName, encryptionCipher: cipher);
      if (legacyData.isNotEmpty) {
        await _box.putAll(legacyData);
      }
    }
    _initialized = true;
  }

  Future<List<int>> _getOrCreateEncryptionKey() async {
    final stored = await _secureStorage.read(key: _encryptionKey);
    if (stored != null) {
      return base64Url.decode(stored);
    }
    final key = Hive.generateSecureKey();
    await _secureStorage.write(
        key: _encryptionKey, value: base64UrlEncode(key));
    return key;
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
            Map<String, String>.from(value),
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

  List<int> _generateSalt([int length = 16]) {
    final rand = Random.secure();
    return List<int>.generate(length, (_) => rand.nextInt(256));
  }

  Future<String> _hashPassword(String password, String salt) async {
    final saltBytes = base64Url.decode(salt);
    final secretKey = await _pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: saltBytes,
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
    final saltBytes = _generateSalt();
    final salt = base64UrlEncode(saltBytes);
    final hashed = await _hashPassword(password, salt);
    users[email] = {'salt': salt, 'hash': hashed};
    await _box.put(_usersKey, users);
    await _box.put(_currentUserKey, {'email': email});
    notifyListeners();
  }

  Future<void> changeEmail(String oldEmail, String newEmail) async {
    _ensureInitialized();
    final users = _users;
    if (!users.containsKey(oldEmail)) {
      throw StateError('User $oldEmail not found.');
    }
    if (users.containsKey(newEmail)) {
      throw StateError('User with email $newEmail already exists.');
    }
    final creds = users.remove(oldEmail)!;
    users[newEmail] = creds;
    await _box.put(_usersKey, users);
    if (currentUser == oldEmail) {
      await _box.put(_currentUserKey, {'email': newEmail});
    }
    notifyListeners();
  }

  Future<void> changePassword(
      String email, String oldPwd, String newPwd) async {
    _ensureInitialized();
    final users = _users;
    final user = users[email];
    if (user == null) {
      throw StateError('User $email not found.');
    }
    final salt = user['salt'];
    final hash = user['hash'];
    if (salt == null || hash == null) {
      throw StateError('Invalid credentials for $email.');
    }
    final currentHash = await _hashPassword(oldPwd, salt);
    if (currentHash != hash) {
      throw StateError('Incorrect current password.');
    }
    final newSaltBytes = _generateSalt();
    final newSalt = base64UrlEncode(newSaltBytes);
    final newHash = await _hashPassword(newPwd, newSalt);
    users[email] = {'salt': newSalt, 'hash': newHash};
    await _box.put(_usersKey, users);
    notifyListeners();
  }

  Future<void> logout() async {
    _ensureInitialized();
    await _box.delete(_currentUserKey);
    notifyListeners();
  }

  Future<void> deleteUser(String email) async {
    _ensureInitialized();
    final users = _users;

    if (currentUser == email) {
      throw StateError('Cannot delete the current user');
    }

    users.remove(email);
    await _box.put(_usersKey, users);
    notifyListeners();
  }
}
