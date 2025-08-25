import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/models/user_profile.dart';
import 'package:vogue_vault/models/user_role.dart';
import 'package:vogue_vault/screens/role_selection_page.dart';
import 'package:vogue_vault/services/appointment_service.dart';
import 'package:vogue_vault/services/auth_service.dart';
import 'package:vogue_vault/services/role_provider.dart';

class _FakeAuthService extends AuthService {
  @override
  bool get isLoggedIn => true;

  @override
  String? get currentUser => 'u1';
}

class _FakeAppointmentService extends AppointmentService {
  _FakeAppointmentService(this._user);

  final UserProfile _user;

  @override
  List<UserProfile> get users => [_user];

  @override
  UserProfile? getUser(String id) => id == _user.id ? _user : null;
}

void main() {
  testWidgets('shows buttons for available roles', (tester) async {
    final user = UserProfile(
      id: 'u1',
      firstName: 'A',
      lastName: 'B',
      roles: {UserRole.professional},
    );
    final auth = _FakeAuthService();
    final appointment = _FakeAppointmentService(user);
    final roleProvider = RoleProvider(auth, appointment);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: auth),
          ChangeNotifierProvider<AppointmentService>.value(value: appointment),
          ChangeNotifierProvider<RoleProvider>.value(value: roleProvider),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RoleSelectionPage(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Professional'), findsOneWidget);
  });

  testWidgets('new role appears automatically', (tester) async {
    final user = UserProfile(
      id: 'u1',
      firstName: 'A',
      lastName: 'B',
      roles: {UserRole.admin},
    );
    final auth = _FakeAuthService();
    final appointment = _FakeAppointmentService(user);
    final roleProvider = RoleProvider(auth, appointment);

    final original = Map<UserRole, WidgetBuilder>.from(rolePages);
    rolePages[UserRole.admin] = (_) => const SizedBox();
    addTearDown(() {
      rolePages
        ..clear()
        ..addAll(original);
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: auth),
          ChangeNotifierProvider<AppointmentService>.value(value: appointment),
          ChangeNotifierProvider<RoleProvider>.value(value: roleProvider),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RoleSelectionPage(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('admin'), findsOneWidget);
  });
}
