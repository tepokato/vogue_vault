import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/screens/appointments_page.dart';
import 'package:vogue_vault/screens/welcome_page.dart';
import 'package:vogue_vault/services/appointment_service.dart';
import 'package:vogue_vault/services/role_provider.dart';
import 'package:vogue_vault/services/auth_service.dart';
import 'package:vogue_vault/models/user_profile.dart';

class _FakeAppointmentService extends AppointmentService {
  @override
  UserProfile? getUser(String id) => null;
}

class _FakeAuthService extends AuthService {
  @override
  String? get currentUser => null;
}

void main() {
  Widget wrap(Widget child) {
    final auth = _FakeAuthService();
    final service = _FakeAppointmentService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppointmentService>.value(value: service),
        ChangeNotifierProvider<AuthService>.value(value: auth),
        ChangeNotifierProvider<RoleProvider>(
          create: (_) => RoleProvider(auth, service),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('navigation bar shows on welcome and routes to profile', (tester) async {
    await tester.pumpWidget(wrap(const WelcomePage()));

    expect(find.byTooltip('Home'), findsOneWidget);
    expect(find.byTooltip('Profile'), findsOneWidget);

    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('home button from appointments goes to welcome', (tester) async {
    await tester.pumpWidget(wrap(const AppointmentsPage()));

    expect(find.byTooltip('Home'), findsOneWidget);
    expect(find.byTooltip('Profile'), findsOneWidget);

    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
  });
}

