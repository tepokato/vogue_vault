import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/models/address.dart';
import 'package:vogue_vault/services/appointment_service.dart';
import 'package:vogue_vault/screens/customers_page.dart';

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

  testWidgets('saved addresses appear when editing customer', (tester) async {
    final service = AppointmentService();
    await service.init();
    final address = Address(id: '1', label: 'Studio', details: '123 Main');
    await service.addAddress(address);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppointmentService>.value(
        value: service,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: CustomersPage()),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Add Address'));
    await tester.pump();

    await tester.tap(
        find.widgetWithText(DropdownButtonFormField<String>, 'Saved address'));
    await tester.pumpAndSettle();
    expect(find.text('Studio'), findsOneWidget);
    await tester.tap(find.text('Studio'));
    await tester.pump();

    final labelField = find.widgetWithText(TextFormField, 'Label');
    final labelText =
        tester.widget<TextFormField>(labelField).controller!.text;
    expect(labelText, 'Studio');

    final addressField = find.widgetWithText(TextFormField, 'Address');
    final addressText =
        tester.widget<TextFormField>(addressField).controller!.text;
    expect(addressText, '123 Main');
  });
}
