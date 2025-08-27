import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/models/address.dart';
import 'package:vogue_vault/services/appointment_service.dart';
import 'package:vogue_vault/services/auth_service.dart';
import 'package:vogue_vault/screens/edit_appointment_page.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => Directory.systemTemp.path;
  @override
  Future<String?> getApplicationSupportPath() async => Directory.systemTemp.path;
  @override
  Future<String?> getTemporaryPath() async => Directory.systemTemp.path;
}

class _FakeAuthService extends AuthService {
  @override
  String? get currentUser => 'test@example.com';
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

  testWidgets('selecting saved address populates location field', (tester) async {
    final service = AppointmentService();
    await service.init();
    final address = Address(id: '1', label: 'Studio', details: '123 Main');
    await service.addAddress(address);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: _FakeAuthService()),
          ChangeNotifierProvider<AppointmentService>.value(value: service),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: EditAppointmentPage()),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, 'Saved address'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Studio').last);
    await tester.pump();

    final locationField = find.widgetWithText(TextFormField, 'Location');
    final text = tester.widget<TextFormField>(locationField).controller!.text;
    expect(text, '123 Main');
  });
}

