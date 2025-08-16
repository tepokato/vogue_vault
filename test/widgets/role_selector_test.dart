import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/models/user_role.dart';
import 'package:vogue_vault/widgets/role_selector.dart';

void main() {
  testWidgets('selecting a role triggers callback', (tester) async {
    Set<UserRole>? selection;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RoleSelector(
          selected: const {},
          onChanged: (roles) => selection = roles,
        ),
      ),
    );

    await tester.tap(find.text('Professional'));
    await tester.pump();

    expect(selection, {UserRole.professional});
  });
}
