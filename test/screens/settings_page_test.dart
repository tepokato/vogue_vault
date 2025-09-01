import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/screens/settings_page.dart';
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

  testWidgets('toggling theme updates service', (tester) async {
    final service = SettingsService();
    await service.init();

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsService>.value(
        value: service,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(RadioListTile<ThemeMode>, 'Dark'));
    await tester.pumpAndSettle();

    expect(service.themeMode, ThemeMode.dark);
  });

  testWidgets('changing language updates service', (tester) async {
    final service = SettingsService();
    await service.init();

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsService>.value(
        value: service,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<Locale>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español').last);
    await tester.pumpAndSettle();

    expect(service.locale.languageCode, 'es');
  });
}
