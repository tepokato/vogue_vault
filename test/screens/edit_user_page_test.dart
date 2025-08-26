import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/screens/edit_user_page.dart';
import 'package:vogue_vault/screens/profile_page.dart';
import 'package:vogue_vault/services/appointment_service.dart';
import 'package:vogue_vault/services/auth_service.dart';
import 'package:vogue_vault/models/user_profile.dart';
import 'package:vogue_vault/models/user_role.dart';

class _FakeAppointmentService extends AppointmentService {
  _FakeAppointmentService([this._users = const []]);

  final List<UserProfile> _users;

  @override
  List<UserProfile> get users => _users;

  @override
  UserProfile? getUser(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }
}

class _FakeAuthService extends AuthService {
  @override
  String? get currentUser => 'test';
}

void main() {
  testWidgets('services link navigates to profile page', (tester) async {
    final auth = _FakeAuthService();
    final service = _FakeAppointmentService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppointmentService>.value(value: service),
          ChangeNotifierProvider<AuthService>.value(value: auth),
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

    expect(find.text('Services'), findsOneWidget);

    await tester.tap(find.text('Services'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfilePage), findsOneWidget);
  });

  testWidgets('delete button disabled for current user', (tester) async {
    final auth = _FakeAuthService();
    final user = UserProfile(
      id: 'test',
      firstName: 'Test',
      lastName: 'User',
      roles: {UserRole.admin},
    );
    final service = _FakeAppointmentService([user]);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppointmentService>.value(value: service),
          ChangeNotifierProvider<AuthService>.value(value: auth),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EditUserPage(),
        ),
      ),
    );

    final deleteFinder = find.widgetWithIcon(IconButton, Icons.delete);
    expect(deleteFinder, findsOneWidget);
    final button = tester.widget<IconButton>(deleteFinder);
    expect(button.onPressed, isNull);
  });
}
