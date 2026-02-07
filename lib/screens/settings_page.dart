import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../services/appointment_service.dart';
import '../services/backup_service.dart';
import '../services/settings_service.dart';
import '../utils/csv_exporter.dart';
import 'notification_settings_page.dart';
import '../widgets/app_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _copyAppointmentsCsv(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final appointmentService = context.read<AppointmentService>();
    final appointments = appointmentService.appointments;

    if (appointments.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.exportCsvEmpty)));
      return;
    }

    try {
      final customersById = {
        for (final customer in appointmentService.customers)
          customer.id: customer,
      };
      final providersById = {
        for (final provider in appointmentService.users) provider.id: provider,
      };
      final csv = CsvExporter.exportAppointments(
        appointments: appointments,
        customersById: customersById,
        providersById: providersById,
      );
      await Clipboard.setData(ClipboardData(text: csv));
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.exportCsvSuccess)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.exportCsvFailed)));
      }
    }
  }

  Future<void> _copyCustomersCsv(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final appointmentService = context.read<AppointmentService>();
    final customers = appointmentService.customers;

    if (customers.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.exportCsvEmpty)));
      return;
    }

    try {
      final csv = CsvExporter.exportCustomers(customers: customers);
      await Clipboard.setData(ClipboardData(text: csv));
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.exportCsvSuccess)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.exportCsvFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final service = context.watch<SettingsService>();
    final backupService = context.watch<BackupService>();

    final lastBackup = backupService.lastBackupAt;
    final statusText = backupService.isBackingUp
        ? l10n.googleDriveBackupInProgress
        : lastBackup != null
            ? l10n.googleDriveBackupLastRun(
                DateFormat.yMMMd().add_jm().format(lastBackup.toLocal()),
              )
            : l10n.googleDriveBackupNeverRan;

    return AppScaffold(
      title: l10n.settingsTitle,
      currentDestination: AppDestination.settings,
      showSettingsButton: false,
      body: ListView(
        children: [
          _SettingsSectionHeader(title: l10n.themeLabel),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeSystem),
            value: ThemeMode.system,
            groupValue: service.themeMode,
            onChanged: (mode) {
              if (mode != null) {
                service.setThemeMode(mode);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeLight),
            value: ThemeMode.light,
            groupValue: service.themeMode,
            onChanged: (mode) {
              if (mode != null) {
                service.setThemeMode(mode);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeDark),
            value: ThemeMode.dark,
            groupValue: service.themeMode,
            onChanged: (mode) {
              if (mode != null) {
                service.setThemeMode(mode);
              }
            },
          ),
          const Divider(),
          _SettingsSectionHeader(title: l10n.languageLabel),
          ListTile(
            title: Text(l10n.languageLabel),
            trailing: DropdownButton<Locale?>(
              value: service.locale,
              onChanged: service.setLocale,
              items: [
                DropdownMenuItem<Locale?>(
                  value: null,
                  child: Text(l10n.languageSystemLabel),
                ),
                const DropdownMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                const DropdownMenuItem(
                  value: Locale('es'),
                  child: Text('Español'),
                ),
                const DropdownMenuItem(
                  value: Locale('pt'),
                  child: Text('Português'),
                ),
              ],
            ),
          ),
          const Divider(),
          _SettingsSectionHeader(title: l10n.notificationSettingsTitle),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(l10n.notificationSettingsTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsPage(),
                ),
              );
            },
          ),
          const Divider(),
          _SettingsSectionHeader(title: l10n.dataExportTitle),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(l10n.exportAppointmentsCsvTitle),
            subtitle: Text(l10n.exportAppointmentsCsvDescription),
            trailing: ElevatedButton(
              onPressed: () => _copyAppointmentsCsv(context),
              child: Text(l10n.exportCsvAction),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.exportCustomersCsvTitle),
            subtitle: Text(l10n.exportCustomersCsvDescription),
            trailing: ElevatedButton(
              onPressed: () => _copyCustomersCsv(context),
              child: Text(l10n.exportCsvAction),
            ),
          ),
          const Divider(),
          _SettingsSectionHeader(title: l10n.cloudBackupTitle),
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: Text(l10n.googleDriveBackupTitle),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.googleDriveBackupDescription),
                const SizedBox(height: 4),
                Text(statusText),
                if (backupService.lastError != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.googleDriveBackupError(backupService.lastError!),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
            trailing: backupService.isBackingUp
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      try {
                        await backupService.backUpToGoogleDrive();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.googleDriveBackupSuccess),
                            ),
                          );
                        }
                      } catch (_) {
                        if (context.mounted) {
                          final message = backupService.lastError ??
                              l10n.googleDriveBackupFailed;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        }
                      }
                    },
                    child: Text(l10n.googleDriveBackupAction),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  const _SettingsSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
