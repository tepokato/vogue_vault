import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/models/appointment.dart';
import 'package:vogue_vault/models/customer.dart';
import 'package:vogue_vault/screens/edit_appointment_page.dart';
import 'package:vogue_vault/services/appointment_service.dart';
import 'package:vogue_vault/models/address.dart';

class _FakeAppointmentService extends AppointmentService {
  Appointment? added;
  final List<Customer> _customers;
  final List<Address> _addresses;

  _FakeAppointmentService({
    List<Customer> customers = const [],
    List<Address> addresses = const [],
  })  : _customers = customers,
        _addresses = addresses;

  @override
  List<Customer> get customers => _customers;

  @override
  List<Address> get addresses => _addresses;

  @override
  Future<void> addAppointment(Appointment appointment) async {
    added = appointment;
  }
}

void main() {
  testWidgets('saving with guest name stores guest appointment', (tester) async {
    final service = _FakeAppointmentService();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppointmentService>.value(
        value: service,
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
}
