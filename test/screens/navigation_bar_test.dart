import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/widgets/app_scaffold.dart';
import 'package:vogue_vault/widgets/main_shell.dart';
import 'package:vogue_vault/services/appointment_service.dart';
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
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('main shell shows bottom nav and a profile shortcut',
      (tester) async {
    await tester.pumpWidget(
      wrap(const MainShell(initialDestination: AppDestination.appointments)),
    );
    await tester.pumpAndSettle();

    // Primary navigation lives in the shell's NavigationBar.
    expect(find.byType(NavigationBar), findsOneWidget);
    // Only the active tab's app bar is on-stage, so a single profile shortcut.
    expect(find.byTooltip('Profile'), findsOneWidget);
    // No legacy "Home"/"Settings" app bar buttons.
    expect(find.byTooltip('Home'), findsNothing);
    expect(find.byTooltip('Settings'), findsNothing);
  });

  testWidgets('back from profile returns to the shell', (tester) async {
    await tester.pumpWidget(
      wrap(const MainShell(initialDestination: AppDestination.appointments)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // The appointments tab title is back on-stage (also appears as a nav label).
    expect(find.text('Appointments'), findsWidgets);
  });
}
