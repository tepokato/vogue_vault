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
  _FakeAppointmentService([List<UserProfile> users = const []])
      : _users = List<UserProfile>.from(users);

  final List<UserProfile> _users;
  String? deletedId;

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

  @override
  Future<void> deleteUser(String id, {String? reassignedUserId}) async {
    deletedId = id;
    _users.removeWhere((u) => u.id == id);
    notifyListeners();
  }
}

class _FakeAuthService extends AuthService {
  bool deleted = false;

  @override
  String? get currentUser => 'test';

  @override
  Future<void> deleteUser(String email) async {
    deleted = true;
  }
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

  testWidgets('current user does not appear in list', (tester) async {
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

    expect(find.text('Test User'), findsNothing);
    expect(find.widgetWithIcon(IconButton, Icons.delete), findsNothing);
  });

  testWidgets('delete requires confirmation', (tester) async {
    final auth = _FakeAuthService();
    final user = UserProfile(
      id: 'other',
      firstName: 'Other',
      lastName: 'User',
      roles: {UserRole.professional},
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

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Other User'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Delete user'));
    await tester.pumpAndSettle();

    expect(find.text('Other User'), findsNothing);
    expect(service.deletedId, 'other');
    expect(auth.deleted, isTrue);
  });
}
