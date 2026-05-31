import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/models/appointment.dart';
import 'package:vogue_vault/models/customer.dart';
import 'package:vogue_vault/models/service_type.dart';
import 'package:vogue_vault/screens/appointments_page.dart';
import 'package:vogue_vault/services/appointment_service.dart';

class _FakeAppointmentService extends AppointmentService {
  final List<Appointment> _appointments;
  final Map<String, Customer> _customers;

  _FakeAppointmentService(this._appointments, this._customers);

  @override
  List<Appointment> get appointments => _appointments;

  @override
  Customer? getCustomer(String id) => _customers[id];
}

void main() {
  testWidgets('appointments page shows customer and location', (tester) async {
    final customer = Customer(id: 'c1', firstName: 'Jane', lastName: 'Doe');
    final service = _FakeAppointmentService([
      Appointment(
        id: '1',
        service: ServiceType.barber,
        // Future date so it passes the default "upcoming" filter.
        dateTime: DateTime.now().add(const Duration(days: 1)),
        customerId: 'c1',
        location: 'Salon',
      ),
    ], {'c1': customer});

    await tester.pumpWidget(
      ChangeNotifierProvider<AppointmentService>.value(
        value: service,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AppointmentsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The redesigned card shows client and location on separate lines.
    expect(find.textContaining('Jane Doe'), findsOneWidget);
    expect(find.textContaining('Salon'), findsOneWidget);
  });
}
