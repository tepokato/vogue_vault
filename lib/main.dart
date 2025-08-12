import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/auth_page.dart';
import 'services/appointment_service.dart';
import 'services/auth_service.dart';
import 'services/role_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appointmentService = AppointmentService();
  await appointmentService.init();
  final authService = AuthService();
  await authService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppointmentService>.value(
          value: appointmentService,
        ),
        ChangeNotifierProvider<AuthService>.value(
          value: authService,
        ),
        ChangeNotifierProvider<RoleProvider>(
          create: (_) => RoleProvider(),
        ),
      ],
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
      // Start the app with authentication.
      home: const AuthPage(),
    );
  }
}
