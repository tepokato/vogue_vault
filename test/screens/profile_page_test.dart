import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:vogue_vault/models/user_profile.dart';
import 'package:vogue_vault/screens/profile_page.dart';
import 'package:vogue_vault/services/appointment_service.dart';
import 'package:vogue_vault/services/auth_service.dart';

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
      String email, String oldPwd, String newPwd) async {
    pwdEmail = email;
    pwdOld = oldPwd;
    pwdNew = newPwd;
  }
}

class _FakeAppointmentService extends AppointmentService {
  final Map<String, UserProfile> store = {
    'old@example.com':
        UserProfile(id: 'old@example.com', firstName: 'Old', lastName: 'User')
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
        child: const MaterialApp(home: ProfilePage()),
      ),
    );

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Current password'), 'old');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'New password'), 'new1');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm password'), 'new2');
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
        child: const MaterialApp(home: ProfilePage()),
      ),
    );

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'new@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Current password'), 'old');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'New password'), 'new');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm password'), 'new');

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
}

