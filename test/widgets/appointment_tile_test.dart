import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/models/appointment.dart';
import 'package:vogue_vault/models/customer.dart';
import 'package:vogue_vault/models/service_type.dart';
import 'package:vogue_vault/models/user_profile.dart';
import 'package:vogue_vault/services/appointment_service.dart';
import 'package:vogue_vault/widgets/appointment_tile.dart';

class _FakeAppointmentService extends AppointmentService {
  final Map<String, UserProfile> _users;
  final Map<String, Customer> _customers;

  _FakeAppointmentService(this._users, this._customers);

  @override
  UserProfile? getUser(String id) => _users[id];

  @override
  Customer? getCustomer(String id) => _customers[id];
}

void main() {
  testWidgets('appointment tile shows provider, customer and price', (tester) async {
    final appt = Appointment(
      id: '1',
      service: ServiceType.barber,
      dateTime: DateTime(2023, 1, 1, 10),
      duration: const Duration(hours: 1),
      providerId: 'p1',
      customerId: 'c1',
      price: 50,
      location: 'Salon',
    );
    final service = _FakeAppointmentService({
      'p1': UserProfile(id: 'p1', firstName: 'Alex', lastName: 'Smith'),
    }, {
      'c1': Customer(id: 'c1', firstName: 'Jane', lastName: 'Doe'),
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<AppointmentService>.value(
        value: service,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AppointmentTile(appointment: appt)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Barber - Alex Smith (\$50.00)'), findsOneWidget);
    expect(find.textContaining('Jane Doe @ Salon'), findsOneWidget);
  });

  testWidgets('appointment tile can hide date', (tester) async {
    final appt = Appointment(
      id: '1',
      service: ServiceType.nails,
      dateTime: DateTime(2023, 1, 1, 10),
      duration: const Duration(hours: 1),
    );

    final service = _FakeAppointmentService({}, {});

    await tester.pumpWidget(
      ChangeNotifierProvider<AppointmentService>.value(
        value: service,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppointmentTile(appointment: appt, showDate: false),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final listTile = tester.widget<ListTile>(find.byType(ListTile));
    final subtitle = listTile.subtitle as Text;
    expect(subtitle.data!.contains('2023'), isFalse);
  });
}

