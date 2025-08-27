import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/models/service_offering.dart';
import 'package:vogue_vault/models/service_type.dart';
import 'package:vogue_vault/widgets/service_offering_editor.dart';

void main() {
  testWidgets('negative price shows error', (tester) async {
    var offerings = [
      ServiceOffering(type: ServiceType.values.first, name: '', price: 0),
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Form(
            child: ServiceOfferingEditor(
              offerings: offerings,
              onChanged: (list) => offerings = list,
            ),
          ),
        ),
      ),
    );

    final priceField = find.widgetWithText(TextFormField, 'Price');
    await tester.enterText(priceField, '-5');

    final formState = tester.state<FormState>(find.byType(Form));
    expect(formState.validate(), isFalse);
    await tester.pump();
    expect(find.text('Invalid price'), findsOneWidget);
  });

  testWidgets('add button adds offering', (tester) async {
    var offerings = <ServiceOffering>[];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ServiceOfferingEditor(
            offerings: offerings,
            onChanged: (list) => offerings = list,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(offerings.length, 1);
  });

  testWidgets('displays localized service type labels', (tester) async {
    var offerings = [
      ServiceOffering(type: ServiceType.barber, name: '', price: 0),
    ];

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ServiceOfferingEditor(
            offerings: offerings,
            onChanged: (list) => offerings = list,
          ),
        ),
      ),
    );

    expect(find.text('Barbero'), findsOneWidget);
    expect(find.text('barber'), findsNothing);
  });
}
