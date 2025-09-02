import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:vogue_vault/services/settings_service.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async =>
      Directory.systemTemp.path;

  @override
  Future<String?> getApplicationSupportPath() async =>
      Directory.systemTemp.path;

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

  testWidgets('MaterialApp updates when locale changes', (tester) async {
    final service = SettingsService();
    await service.init();

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsService>.value(
        value: service,
        child: Consumer<SettingsService>(
          builder: (_, settings, __) {
            return MaterialApp(
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('es')],
              locale: settings.locale,
            );
          },
        ),
      ),
    );

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).locale, isNull);

    await service.setLocale(const Locale('es'));
    await tester.pump();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
      const Locale('es'),
    );
  });
}
