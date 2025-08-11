import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/welcome_page.dart';
import 'services/appointment_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider<AppointmentService>(
      create: (_) {
        final service = AppointmentService();
        unawaited(service.init());
        return service;
      },
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
      home: const WelcomePage(),
    );
  }
}
