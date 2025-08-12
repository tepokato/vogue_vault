import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/models/service_provider.dart';
import 'package:vogue_vault/models/service_type.dart';
import 'package:vogue_vault/models/user_role.dart';
import 'package:vogue_vault/models/appointment.dart';
import 'package:vogue_vault/models/client.dart';
import 'package:vogue_vault/screens/appointments_page.dart';
import 'package:vogue_vault/screens/edit_provider_page.dart';
import 'package:vogue_vault/services/appointment_service.dart';
import 'package:vogue_vault/services/role_provider.dart';

class FakeAppointmentService extends ChangeNotifier implements AppointmentService {
  final Map<String, ServiceProvider> _providers = {};

  @override
  Future<void> init() async {}

  @override
  bool get isInitialized => true;

  @override
  List<Appointment> get appointments => [];

  @override
  List<Client> get clients => [];

  @override
  List<ServiceProvider> get providers => _providers.values.toList();

  @override
  Client? getClient(String id) => null;

  @override
  Appointment? getAppointment(String id) => null;

  @override
  ServiceProvider? getProvider(String id) => _providers[id];

  @override
  Future<void> addClient(Client client) async {}

  @override
  Future<void> updateClient(Client client) async {}

  @override
  Future<void> deleteClient(String id, {String? reassignedClientId}) async {}

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
  testWidgets('Providers can be added, edited, and deleted', (tester) async {
    final service = FakeAppointmentService();
    final roleProvider = RoleProvider()..selectedRole = UserRole.professional;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppointmentService>.value(value: service),
          ChangeNotifierProvider<RoleProvider>.value(value: roleProvider),
        ],
        child: const MaterialApp(home: EditProviderPage()),
      ),
    );
    await tester.pumpAndSettle();

    // Add provider
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('New Provider'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Bob');
    await tester.tap(find.byKey(const Key('serviceTypeDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('hairdresser').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Bob'), findsOneWidget);

    // Edit provider
    await tester.tap(find.text('Bob'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Provider'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Bobby');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Bobby'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);

    // Delete provider
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    expect(find.text('Bobby'), findsNothing);
  });

  testWidgets('Appointments page navigates to providers', (tester) async {
    final service = FakeAppointmentService();
    final roleProvider = RoleProvider()..selectedRole = UserRole.professional;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppointmentService>.value(value: service),
          ChangeNotifierProvider<RoleProvider>.value(value: roleProvider),
        ],
        child: const MaterialApp(home: AppointmentsPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Providers'));
    await tester.pumpAndSettle();
    expect(find.text('Providers'), findsOneWidget);
  });
}
