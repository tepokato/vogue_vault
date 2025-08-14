import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/models/service_type.dart';
import 'package:vogue_vault/utils/service_type_utils.dart';

void main() {
  Future<BuildContext> _pumpApp(WidgetTester tester, Locale? locale) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          ctx = context;
          return const SizedBox.shrink();
        }),
      ),
    );
    return ctx;
  }

  testWidgets('returns English labels', (tester) async {
    final context = await _pumpApp(tester, const Locale('en'));
    expect(serviceTypeLabel(context, ServiceType.barber), 'Barber');
    expect(serviceTypeLabel(context, ServiceType.hairdresser), 'Hairdresser');
    expect(serviceTypeLabel(context, ServiceType.nails), 'Nails');
    expect(serviceTypeLabel(context, ServiceType.tattoo), 'Tattoo Artist');
  });

  testWidgets('returns Spanish labels', (tester) async {
    final context = await _pumpApp(tester, const Locale('es'));
    expect(serviceTypeLabel(context, ServiceType.barber), 'Barbero');
    expect(serviceTypeLabel(context, ServiceType.hairdresser), 'Peluquería');
    expect(serviceTypeLabel(context, ServiceType.nails), 'Uñas');
    expect(serviceTypeLabel(context, ServiceType.tattoo), 'Tatuador');
  });
}

