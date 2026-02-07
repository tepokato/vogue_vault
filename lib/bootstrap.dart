import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'services/appointment_service.dart';
import 'services/auth_service.dart';
import 'services/backup_service.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final notificationService = NotificationService();
  await notificationService.init();
  final appointmentService = AppointmentService(
    notificationService: notificationService,
  );
  await appointmentService.init();
  final authService = AuthService();
  await authService.init();
  final settingsService = SettingsService();
  await settingsService.init();
  final backupService = BackupService(appointmentService);

  runApp(
    ChangeNotifierProvider<SettingsService>.value(
      value: settingsService,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<AppointmentService>.value(
            value: appointmentService,
          ),
          ChangeNotifierProvider<AuthService>.value(value: authService),
          ChangeNotifierProvider<BackupService>.value(value: backupService),
          Provider<NotificationService>.value(value: notificationService),
        ],
        child: const VogueVaultApp(),
      ),
    ),
  );
}
