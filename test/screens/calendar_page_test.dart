import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:vogue_vault/l10n/app_localizations.dart';
import 'package:vogue_vault/models/appointment.dart';
import 'package:vogue_vault/models/service_type.dart';
import 'package:vogue_vault/screens/calendar_page.dart';
import 'package:vogue_vault/services/appointment_service.dart';
import 'package:table_calendar/table_calendar.dart';

class _FakeAppointmentService extends AppointmentService {
  final List<Appointment> _appointments;

  _FakeAppointmentService(this._appointments);

  @override
  List<Appointment> get appointments => _appointments;
}

void main() {
  testWidgets('selecting a date shows appointments for that day', (tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 10);
    final tomorrow = today.add(const Duration(days: 1));

    final service = _FakeAppointmentService([
      Appointment(
        id: '1',
        service: ServiceType.barber,
        dateTime: today,
        guestName: 'Alice',
      ),
      Appointment(
        id: '2',
        service: ServiceType.nails,
        dateTime: tomorrow,
        guestName: 'Bob',
      ),
    ]);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppointmentService>.value(
        value: service,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CalendarPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initially shows today's appointment
    expect(find.text('Alice - Barber'), findsOneWidget);
    expect(find.text('Bob - Nails'), findsNothing);

    // Select tomorrow
    final calendarFinder = find.byType(TableCalendar<Appointment>);
    final calendarWidget = tester.widget<TableCalendar<Appointment>>(calendarFinder);
    calendarWidget.onDaySelected!(
      DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
      DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bob - Nails'), findsOneWidget);
    expect(find.text('Alice - Barber'), findsNothing);
  });
}

