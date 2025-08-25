import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/models/user_profile.dart';
import 'package:vogue_vault/screens/manage_services_page.dart';
import 'package:vogue_vault/services/appointment_service.dart';
import 'package:vogue_vault/services/auth_service.dart';

class _FakeAuthService extends AuthService {
  @override
  String? get currentUser => 'test@example.com';
}

class _FakeAppointmentService extends AppointmentService {
  UserProfile profile = UserProfile(
    id: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    offerings: const [],
  );
  UserProfile? updated;

  @override
  UserProfile? getUser(String id) => id == profile.id ? profile : null;

  @override
  Future<void> updateUser(UserProfile user) async {
    updated = user;
    profile = user;
  }
}

void main() {
  testWidgets('saves updated offerings through service', (tester) async {
    final auth = _FakeAuthService();
    final appt = _FakeAppointmentService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: auth),
          ChangeNotifierProvider<AppointmentService>.value(value: appt),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ManageServicesPage(),
        ),
      ),
    );

    await tester.tap(find.text('Add'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(appt.updated, isNotNull);
    expect(appt.updated!.offerings, isNotEmpty);
  });
}
