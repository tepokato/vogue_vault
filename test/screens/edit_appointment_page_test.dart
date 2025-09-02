import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/models/appointment.dart';
import 'package:vogue_vault/models/customer.dart';
import 'package:vogue_vault/models/service_offering.dart';
import 'package:vogue_vault/models/service_type.dart';
import 'package:vogue_vault/models/user_profile.dart';
import 'package:vogue_vault/screens/edit_appointment_page.dart';
import 'package:vogue_vault/services/appointment_service.dart';
import 'package:vogue_vault/services/auth_service.dart';
import 'package:vogue_vault/models/address.dart';

class _FakeAuthService extends AuthService {
  @override
  String? get currentUser => 'test@example.com';
}

class _FakeAppointmentService extends AppointmentService {
  Appointment? added;
  final List<Customer> _customers;
  final List<Address> _addresses;
  final UserProfile? _user;

  _FakeAppointmentService({
    List<Customer> customers = const [],
    List<Address> addresses = const [],
    UserProfile? user,
  })  : _customers = customers,
        _addresses = addresses,
        _user = user;

  @override
  List<Customer> get customers => _customers;

  @override
  List<Address> get addresses => _addresses;

  @override
  UserProfile? getUser(String id) =>
      _user != null && _user!.id == id ? _user : null;

  @override
  Future<void> addAppointment(
    Appointment appointment, {
    BuildContext? context,
    String? serviceName,
  }) async {
    added = appointment;
  }
}

void main() {
  testWidgets('saving with guest name stores guest appointment', (tester) async {
    final auth = _FakeAuthService();
    final service = _FakeAppointmentService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: auth),
          ChangeNotifierProvider<AppointmentService>.value(value: service),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: EditAppointmentPage()),
        ),
      ),
    );

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Guest name'), 'Walk-in');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(service.added, isNotNull);
    expect(service.added!.guestName, 'Walk-in');
    expect(service.added!.customerId, isNull);
  });

  testWidgets('selecting offering populates service and price', (tester) async {
    final auth = _FakeAuthService();
    final user = UserProfile(
      id: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      offerings: const [
        ServiceOffering(type: ServiceType.barber, name: 'Cut', price: 10),
      ],
    );
    final service = _FakeAppointmentService(user: user);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: auth),
          ChangeNotifierProvider<AppointmentService>.value(value: service),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: EditAppointmentPage()),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('offeringDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Barber - Cut (\$10.00)').last);
    await tester.pump();

    final serviceField = find.byKey(const ValueKey('serviceDropdown'));
    final dropdown = tester
        .widget<DropdownButtonFormField<ServiceType>>(serviceField);
    expect(dropdown.value, ServiceType.barber);

    final priceField = find.byKey(const ValueKey('priceField'));
    final priceWidget = tester.widget<TextFormField>(priceField);
    expect(priceWidget.controller!.text, '10.00');
  });
}
