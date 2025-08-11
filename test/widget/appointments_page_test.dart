import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/models/appointment.dart';
import 'package:vogue_vault/models/client.dart';
import 'package:vogue_vault/models/service_type.dart';
import 'package:vogue_vault/screens/appointments_page.dart';
import 'package:vogue_vault/services/appointment_service.dart';

class FakeAppointmentService extends ChangeNotifier implements AppointmentService {
  final Map<String, Appointment> _appointments = {};
  final Map<String, Client> _clients = {};

  @override
  Future<void> init() async {}

  @override
  List<Appointment> get appointments => _appointments.values.toList();

  @override
  List<Client> get clients => _clients.values.toList();

  @override
  Client? getClient(String id) => _clients[id];

  @override
  Appointment? getAppointment(String id) => _appointments[id];

  @override
  Future<void> addClient(Client client) async {
    _clients[client.id] = client;
    notifyListeners();
  }

  @override
  Future<void> updateClient(Client client) async {
    _clients[client.id] = client;
    notifyListeners();
  }

  @override
  Future<void> deleteClient(String id, {String? reassignedClientId}) async {
    if (reassignedClientId != null) {
      _appointments.updateAll((key, appt) =>
          appt.clientId == id ? appt.copyWith(clientId: reassignedClientId) : appt);
    } else {
      _appointments.removeWhere((key, appt) => appt.clientId == id);
    }
    _clients.remove(id);
    notifyListeners();
  }

  @override
  Future<void> addAppointment(Appointment appointment) async {
    _appointments[appointment.id] = appointment;
    notifyListeners();
  }

  @override
  Future<void> updateAppointment(Appointment appointment) async {
    _appointments[appointment.id] = appointment;
    notifyListeners();
  }

  @override
  Future<void> deleteAppointment(String id) async {
    _appointments.remove(id);
    notifyListeners();
  }
}

void main() {
  testWidgets('Appointments display and actions navigate', (tester) async {
    final service = FakeAppointmentService();
    final client = Client(id: 'c1', name: 'Alice');
    final appointment = Appointment(
      id: 'a1',
      clientId: 'c1',
      service: ServiceType.barber,
      dateTime: DateTime(2023, 9, 10, 10),
    );
    await service.addClient(client);
    await service.addAppointment(appointment);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppointmentService>.value(
        value: service,
        child: const MaterialApp(home: AppointmentsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alice - Barbershop'), findsOneWidget);

    await tester.tap(find.text('Alice - Barbershop'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Appointment'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('New Appointment'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Clients'));
    await tester.pumpAndSettle();
    expect(find.text('Clients'), findsOneWidget);
  });
}
