import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'hive_storage.dart';
import 'services/appointment_service.dart';
import 'services/auth_service.dart';
import 'services/backup_service.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initHiveStorage();

  final notificationService = NotificationService();
  await notificationService.init();
  final authService = AuthService();
  await authService.init();
  final appointmentService = AppointmentService(
    notificationService: notificationService,
  );
  await appointmentService.init();
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
