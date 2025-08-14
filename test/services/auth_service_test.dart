import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cryptography/cryptography.dart';

import 'package:vogue_vault/services/auth_service.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => Directory.systemTemp.path;

  @override
  Future<String?> getApplicationSupportPath() async => Directory.systemTemp.path;

  @override
  Future<String?> getTemporaryPath() async => Directory.systemTemp.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    PathProviderPlatform.instance = _FakePathProviderPlatform();
    await Hive.initFlutter();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  test('registration and login succeed after init', () async {
    final service = AuthService();
    await service.init();

    const email = 'test@example.com';
    const password = 'secret';

    await service.register(email, password);
    expect(service.currentUser, email);

    await service.logout();
    final success = await service.login(email, password);
    expect(success, isTrue);
    expect(service.currentUser, email);
  });

  test('register stores hashed password', () async {
    final service = AuthService();
    await service.init();

    const email = 'hash@example.com';
    const password = 'mypassword';

    await service.register(email, password);

    final box = Hive.box('auth');
    final stored = box.get('users')![email] as Map;
    final salt = stored['salt'] as String;
    final hash = stored['hash'] as String;
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );
    final key = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: base64Url.decode(salt),
    );
    final expected = base64UrlEncode(await key.extractBytes());
    expect(hash, expected);
    expect(hash, isNot(password));
    expect(salt, isNotEmpty);
  });

  test('salt is stored as base64 and decodes to 16 bytes', () async {
    final service = AuthService();
    await service.init();

    const email = 'saltlen@example.com';
    const password = 'mypassword';

    await service.register(email, password);

    final box = Hive.box('auth');
    final stored = box.get('users')![email] as Map;
    final salt = stored['salt'] as String;
    final decoded = base64Url.decode(salt);
    expect(decoded.length, 16);
  });

  test('login compares hashed password', () async {
    final service = AuthService();
    await service.init();

    const email = 'login@example.com';
    const password = 'pass123';
    final saltBytes = List<int>.generate(16, (i) => i);
    final salt = base64UrlEncode(saltBytes);
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );
    final key = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: saltBytes,
    );
    final hash = base64UrlEncode(await key.extractBytes());

    final box = Hive.box('auth');
    await box.put('users', {
      email: {'salt': salt, 'hash': hash}
    });

    final success = await service.login(email, password);
    expect(success, isTrue);
    expect(service.currentUser, email);
  });

  test('duplicate registration is rejected', () async {
    final service = AuthService();
    await service.init();

    const email = 'dup@example.com';
    const password = 'password';

    await service.register(email, password);
    expect(service.register(email, password), throwsStateError);
  });
}
