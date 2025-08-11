import 'package:flutter/material.dart';
import 'screens/appointments_page.dart';
import 'services/appointment_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = AppointmentService();
  await service.init();
  runApp(
    ChangeNotifierProvider<AppointmentService>.value(
      value: service,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vogue Vault',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AppointmentsPage(),
    );
  }
}
