import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/screens/auth_page.dart';
import 'package:vogue_vault/services/auth_service.dart';

class FakeAuthService extends AuthService {
  @override
  bool get isLoggedIn => false;
}

void main() {
  testWidgets('invalid email shows error', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>.value(
        value: FakeAuthService(),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AuthPage(),
        ),
      ),
    );

    final formFinder = find.byType(Form);
    final emailField = find.byType(TextFormField).first;

    await tester.enterText(emailField, 'invalid');
    final formState = tester.state<FormState>(formFinder);
    expect(formState.validate(), isFalse);
    await tester.pump();
    expect(find.text('Invalid email format'), findsOneWidget);
  });

  testWidgets('valid email passes validation', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>.value(
        value: FakeAuthService(),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AuthPage(),
        ),
      ),
    );

    final formFinder = find.byType(Form);
    final emailField = find.byType(TextFormField).first;

    await tester.enterText(emailField, 'user@example.com');
    final formState = tester.state<FormState>(formFinder);
    expect(formState.validate(), isTrue);
  });
}
