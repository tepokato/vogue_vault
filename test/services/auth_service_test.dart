import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';

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
    final stored = box.get('users')![email]!;
    final expected = sha256.convert(utf8.encode(password)).toString();
    expect(stored, expected);
    expect(stored, isNot(password));
  });

  test('login compares hashed password', () async {
    final service = AuthService();
    await service.init();

    const email = 'login@example.com';
    const password = 'pass123';
    final hashed = sha256.convert(utf8.encode(password)).toString();

    final box = Hive.box('auth');
    await box.put('users', {email: hashed});

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
