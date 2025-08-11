import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/models/appointment.dart';
import 'package:vogue_vault/models/client.dart';
import 'package:vogue_vault/models/service_type.dart';
import 'package:vogue_vault/screens/appointments_page.dart';
import 'package:vogue_vault/services/appointment_service.dart';

class FakeAppointmentService extends AppointmentService {
  FakeAppointmentService({
    required List<Appointment> appointments,
    required List<Client> clients,
  })  : _appointments = appointments,
        _clients = {for (final c in clients) c.id: c};

  final List<Appointment> _appointments;
  final Map<String, Client> _clients;

  @override
  List<Appointment> get appointments => _appointments;

  @override
  List<Client> get clients => _clients.values.toList();

  @override
  Client? getClient(String id) => _clients[id];

  @override
  Appointment? getAppointment(String id) {
    try {
      return _appointments.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteAppointment(String id) async {
    _appointments.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}

void main() {
  testWidgets('Appointments page shows appointment titles and navigates',
      (tester) async {
    final client = Client(id: 'c1', name: 'Alice');
    final appointment = Appointment(
      id: 'a1',
      clientId: client.id,
      service: ServiceType.barber,
      dateTime: DateTime(2023, 9, 10, 10, 0),
    );
    final service = FakeAppointmentService(
      appointments: [appointment],
      clients: [client],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppointmentService>.value(
        value: service,
        child: const MaterialApp(
          home: AppointmentsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Alice - Barbershop'), findsOneWidget);

    await tester.tap(find.text('Alice - Barbershop'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Appointment'), findsOneWidget);
  });
}

