import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/models/appointment.dart';
import 'package:vogue_vault/models/service_type.dart';
import 'package:vogue_vault/models/customer.dart';
import 'package:vogue_vault/screens/calendar_page.dart';
import 'package:vogue_vault/services/appointment_service.dart';
import 'package:vogue_vault/services/auth_service.dart';
import 'package:table_calendar/table_calendar.dart';

class _FakeAuthService extends AuthService {
  @override
  String? get currentUser => null;
}

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
  testWidgets('selecting a date shows appointments for that day', (
    tester,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 10);
    final tomorrow = today.add(const Duration(days: 1));

    final customer = Customer(id: 'c1', firstName: 'Jane', lastName: 'Doe');
    final service = _FakeAppointmentService([
      Appointment(
        id: '1',
        service: ServiceType.barber,
        dateTime: today,
        customerId: 'c1',
        location: 'Salon',
      ),
      Appointment(
        id: '2',
        service: ServiceType.nails,
        dateTime: tomorrow,
        guestName: 'Guest',
        location: 'Home',
      ),
    ], {'c1': customer});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: _FakeAuthService()),
          ChangeNotifierProvider<AppointmentService>.value(value: service),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CalendarPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initially shows today's appointment with customer name and location
    expect(find.text('Barber - Unknown'), findsOneWidget);
    expect(find.textContaining('Jane Doe @ Salon'), findsOneWidget);
    expect(find.text('Nails - Unknown'), findsNothing);

    // Select tomorrow
    final calendarFinder = find.byType(TableCalendar<Appointment>);
    final calendarWidget = tester.widget<TableCalendar<Appointment>>(
      calendarFinder,
    );
    calendarWidget.onDaySelected!(
      DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
      DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nails - Unknown'), findsOneWidget);
    expect(find.textContaining('Guest @ Home'), findsOneWidget);
    expect(find.text('Barber - Unknown'), findsNothing);
  });
}
