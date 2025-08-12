import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/models/appointment.dart';
import 'package:vogue_vault/models/client.dart';
import 'package:vogue_vault/models/service_provider.dart';
import 'package:vogue_vault/models/service_type.dart';
import 'package:vogue_vault/screens/welcome_page.dart';
import 'package:vogue_vault/services/appointment_service.dart';
import 'package:vogue_vault/services/role_provider.dart';
import 'package:vogue_vault/models/user_role.dart';

class FakeAppointmentService extends ChangeNotifier
    implements AppointmentService {
  final Map<String, Client> _clients = {};
  final Map<String, ServiceProvider> _providers = {};

  @override
  Future<void> init() async {}

  @override
  bool get isInitialized => true;

  @override
  List<Appointment> get appointments => [];

  @override
  List<Client> get clients => _clients.values.toList();

  @override
  List<ServiceProvider> get providers => _providers.values.toList();

  @override
  Client? getClient(String id) => _clients[id];

  @override
  Appointment? getAppointment(String id) => null;

  @override
  ServiceProvider? getProvider(String id) => _providers[id];

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
    _clients.remove(id);
    notifyListeners();
  }

  @override
  Future<void> addProvider(ServiceProvider provider) async {
    _providers[provider.id] = provider;
    notifyListeners();
  }

  @override
  Future<void> updateProvider(ServiceProvider provider) async {
    _providers[provider.id] = provider;
    notifyListeners();
  }

  @override
  Future<void> deleteProvider(String id, {String? reassignedProviderId}) async {
    _providers.remove(id);
    notifyListeners();
  }

  @override
  Future<void> addAppointment(Appointment appointment) async {}

  @override
  Future<void> updateAppointment(Appointment appointment) async {}

  @override
  Future<void> deleteAppointment(String id) async {}
}

void main() {
  testWidgets('Customers can choose a provider before scheduling', (tester) async {
    final service = FakeAppointmentService();
    await service.addProvider(
      ServiceProvider(id: 'p1', name: 'Bob', serviceType: ServiceType.barber),
    );
    await service.addProvider(
      ServiceProvider(id: 'p2', name: 'Nina', serviceType: ServiceType.nails),
    );
    await service.addClient(Client(id: 'c1', name: 'Alice'));

    final roleProvider = RoleProvider()..selectedRole = UserRole.customer;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppointmentService>.value(value: service),
          ChangeNotifierProvider<RoleProvider>.value(value: roleProvider),
        ],
        child: const MaterialApp(home: WelcomePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Barbershop'));
    await tester.pumpAndSettle();

    expect(find.text('Select Provider'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Nina'), findsNothing);

    await tester.tap(find.text('Bob'));
    await tester.pumpAndSettle();

    expect(find.text('New Appointment'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
  });
}

