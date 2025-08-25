import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/models/user_profile.dart';
import 'package:vogue_vault/screens/profile_page.dart';
import 'package:vogue_vault/services/appointment_service.dart';
import 'package:vogue_vault/services/auth_service.dart';
import 'package:vogue_vault/widgets/service_offering_editor.dart';

class _FakeAuthService extends AuthService {
  String? _user = 'old@example.com';
  String? changedOld;
  String? changedNew;
  String? pwdEmail;
  String? pwdOld;
  String? pwdNew;

  @override
  String? get currentUser => _user;

  @override
  Future<void> changeEmail(String oldEmail, String newEmail) async {
    changedOld = oldEmail;
    changedNew = newEmail;
    _user = newEmail;
  }

  @override
  Future<void> changePassword(
    String email,
    String oldPwd,
    String newPwd,
  ) async {
    pwdEmail = email;
    pwdOld = oldPwd;
    pwdNew = newPwd;
  }
}

class _FakeAppointmentService extends AppointmentService {
  final Map<String, UserProfile> store = {
    'old@example.com': UserProfile(
      id: 'old@example.com',
      firstName: 'Old',
      lastName: 'User',
    ),
  };
  String? renameOld;
  String? renameNew;

  @override
  UserProfile? getUser(String id) => store[id];

  @override
  Future<void> updateUser(UserProfile user) async {
    store[user.id] = user;
  }

  @override
  Future<void> renameUserId(String oldId, String newId) async {
    renameOld = oldId;
    renameNew = newId;
    final profile = store.remove(oldId);
    if (profile != null) {
      store[newId] = profile.copyWith(id: newId);
    }
  }
}

class _RegisterAuthService extends AuthService {
  String? registeredEmail;
  String? registeredPassword;

  @override
  String? get currentUser => null;

  @override
  Future<void> register(String email, String password) async {
    registeredEmail = email;
    registeredPassword = password;
  }
}

class _RegisterAppointmentService extends AppointmentService {
  UserProfile? addedUser;

  @override
  Future<void> addUser(UserProfile user) async {
    addedUser = user;
  }
}

void main() {
  testWidgets('mismatched passwords show error', (tester) async {
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
          home: ProfilePage(),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Current password'),
      'old',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'New password'),
      'new1',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm password'),
      'new2',
    );
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('saving calls changeEmail and changePassword', (tester) async {
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
          home: ProfilePage(),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'new@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Current password'),
      'old',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'New password'),
      'new',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm password'),
      'new',
    );

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(auth.changedOld, 'old@example.com');
    expect(auth.changedNew, 'new@example.com');
    expect(auth.pwdEmail, 'new@example.com');
    expect(auth.pwdOld, 'old');
    expect(auth.pwdNew, 'new');
    expect(appt.renameOld, 'old@example.com');
    expect(appt.renameNew, 'new@example.com');
  });

  testWidgets('new user profile hides home button', (tester) async {
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
          home: ProfilePage(isNewUser: true),
        ),
      ),
    );

    expect(find.byTooltip('Home'), findsNothing);
    expect(find.byType(ServiceOfferingEditor), findsNothing);
  });

  testWidgets('registration allows empty offerings', (tester) async {
    final auth = _RegisterAuthService();
    final appt = _RegisterAppointmentService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: auth),
          ChangeNotifierProvider<AppointmentService>.value(value: appt),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProfilePage(isNewUser: true),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'First name'),
      'New',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Last name'),
      'User',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'new@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'New password'),
      'pass',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm password'),
      'pass',
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(auth.registeredEmail, 'new@example.com');
    expect(appt.addedUser, isNotNull);
    expect(appt.addedUser!.offerings, isEmpty);
  });
}
