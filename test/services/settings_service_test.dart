import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vogue_vault/services/settings_service.dart';

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

  test('setThemeMode persists value', () async {
    final service = SettingsService();
    await service.init();

    await service.setThemeMode(ThemeMode.dark);
    expect(service.themeMode, ThemeMode.dark);

    final reloaded = SettingsService();
    await reloaded.init();
    expect(reloaded.themeMode, ThemeMode.dark);
  });

  test('setThemeMode notifies listeners', () async {
    final service = SettingsService();
    await service.init();

    var notified = false;
    service.addListener(() {
      notified = true;
    });

    await service.setThemeMode(ThemeMode.light);
    expect(notified, isTrue);
  });

  test('setLocale persists value', () async {
    final service = SettingsService();
    await service.init();

    await service.setLocale(const Locale('es'));
    expect(service.locale, const Locale('es'));

    final reloaded = SettingsService();
    await reloaded.init();
    expect(reloaded.locale, const Locale('es'));
  });
}
