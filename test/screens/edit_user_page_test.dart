import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/models/user_profile.dart';
import 'package:vogue_vault/models/user_role.dart';
import 'package:vogue_vault/screens/edit_user_page.dart';
import 'package:vogue_vault/services/appointment_service.dart';
import 'package:vogue_vault/services/role_provider.dart';
import 'package:vogue_vault/services/auth_service.dart';

class _FakeAppointmentService extends AppointmentService {
  @override
  List<UserProfile> get users => [];

  @override
  UserProfile? getUser(String id) => null;
}

class _FakeAuthService extends AuthService {
  @override
  String? get currentUser => 'test';
}

void main() {
  testWidgets('negative price shows error', (tester) async {
    final auth = _FakeAuthService();
    final service = _FakeAppointmentService();
    final roleProvider = RoleProvider(auth, service)
      ..selectedRole = UserRole.professional;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppointmentService>.value(value: service),
          ChangeNotifierProvider<AuthService>.value(value: auth),
          ChangeNotifierProvider<RoleProvider>.value(value: roleProvider),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EditUserPage(),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Professional'));
    await tester.pump();

    await tester.tap(find.text('Add'));
    await tester.pump();

    final priceField = find.widgetWithText(TextFormField, 'Price');
    await tester.enterText(priceField, '-5');

    final formFinder = find.byType(Form);
    final formState = tester.state<FormState>(formFinder);
    expect(formState.validate(), isFalse);
    await tester.pump();
    expect(find.text('Invalid price'), findsOneWidget);
  });
}
