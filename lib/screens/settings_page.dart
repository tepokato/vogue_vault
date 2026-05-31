import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../app/theme.dart';
import '../services/appointment_service.dart';
import '../services/backup_service.dart';
import '../services/settings_service.dart';
import '../utils/csv_exporter.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/ui/ui.dart';
import 'notification_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _copyAppointmentsCsv(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final appointmentService = context.read<AppointmentService>();
    final appointments = appointmentService.appointments;
    if (appointments.isEmpty) {
      _toast(context, l10n.exportCsvEmpty);
      return;
    }
    try {
      final customersById = {
        for (final c in appointmentService.customers) c.id: c,
      };
      final providersById = {
        for (final p in appointmentService.users) p.id: p,
      };
      final csv = CsvExporter.exportAppointments(
        appointments: appointments,
        customersById: customersById,
        providersById: providersById,
      );
      await Clipboard.setData(ClipboardData(text: csv));
      if (context.mounted) _toast(context, l10n.exportCsvSuccess);
    } catch (_) {
      if (context.mounted) _toast(context, l10n.exportCsvFailed);
    }
  }

  Future<void> _copyCustomersCsv(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final appointmentService = context.read<AppointmentService>();
    final customers = appointmentService.customers;
    if (customers.isEmpty) {
      _toast(context, l10n.exportCsvEmpty);
      return;
    }
    try {
      final csv = CsvExporter.exportCustomers(customers: customers);
      await Clipboard.setData(ClipboardData(text: csv));
      if (context.mounted) _toast(context, l10n.exportCsvSuccess);
    } catch (_) {
      if (context.mounted) _toast(context, l10n.exportCsvFailed);
    }
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsService>();
    // The cloud backup feature is optional: when no [BackupService] is wired
    // up (e.g. lightweight tests) the section is simply hidden.
    BackupService? backupService;
    try {
      backupService = context.watch<BackupService>();
    } on ProviderNotFoundException {
      backupService = null;
    }

    return AppScaffold(
      title: l10n.settingsTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.space,
          AppTokens.spaceSm,
          AppTokens.space,
          AppTokens.spaceXl,
        ),
        children: [
          _SettingsGroup(
            title: l10n.themeLabel,
            children: [
              for (final entry in {
                ThemeMode.system: l10n.themeSystem,
                ThemeMode.light: l10n.themeLight,
                ThemeMode.dark: l10n.themeDark,
              }.entries)
                RadioListTile<ThemeMode>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.value),
                  value: entry.key,
                  groupValue: settings.themeMode,
                  onChanged: (m) {
                    if (m != null) settings.setThemeMode(m);
                  },
                ),
            ],
          ),
          const SizedBox(height: AppTokens.space),
          _SettingsGroup(
            title: l10n.languageLabel,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.translate),
                title: Text(l10n.languageLabel),
                trailing: DropdownButton<Locale?>(
                  value: settings.locale,
                  underline: const SizedBox.shrink(),
                  onChanged: settings.setLocale,
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
            ],
          ),
          const SizedBox(height: AppTokens.space),
          _SettingsGroup(
            title: l10n.notificationSettingsTitle,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_outlined),
                title: Text(l10n.notificationSettingsTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationSettingsPage(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space),
          _SettingsGroup(
            title: l10n.dataExportTitle,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_note_outlined),
                title: Text(l10n.exportAppointmentsCsvTitle),
                subtitle: Text(l10n.exportAppointmentsCsvDescription),
                trailing: FilledButton.tonal(
                  onPressed: () => _copyAppointmentsCsv(context),
                  child: Text(l10n.exportCsvAction),
                ),
              ),
              const Divider(height: AppTokens.spaceLg),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.people_outline),
                title: Text(l10n.exportCustomersCsvTitle),
                subtitle: Text(l10n.exportCustomersCsvDescription),
                trailing: FilledButton.tonal(
                  onPressed: () => _copyCustomersCsv(context),
                  child: Text(l10n.exportCsvAction),
                ),
              ),
            ],
          ),
          if (backupService != null) ...[
            const SizedBox(height: AppTokens.space),
            _buildBackupGroup(context, l10n, backupService),
          ],
        ],
      ),
    );
  }

  Widget _buildBackupGroup(
    BuildContext context,
    AppLocalizations l10n,
    BackupService backupService,
  ) {
    final lastBackup = backupService.lastBackupAt;
    final statusText = backupService.isBackingUp
        ? l10n.googleDriveBackupInProgress
        : lastBackup != null
            ? l10n.googleDriveBackupLastRun(
                DateFormat.yMMMd().add_jm().format(lastBackup.toLocal()),
              )
            : l10n.googleDriveBackupNeverRan;

    return _SettingsGroup(
      title: l10n.cloudBackupTitle,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.cloud_upload_outlined),
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
              : FilledButton.tonal(
                  onPressed: () => _backup(context, backupService, l10n),
                  child: Text(l10n.googleDriveBackupAction),
                ),
        ),
      ],
    );
  }

  Future<void> _backup(
    BuildContext context,
    BackupService backupService,
    AppLocalizations l10n,
  ) async {
    try {
      await backupService.backUpToGoogleDrive();
      if (context.mounted) _toast(context, l10n.googleDriveBackupSuccess);
    } catch (_) {
      if (context.mounted) {
        _toast(context,
            backupService.lastError ?? l10n.googleDriveBackupFailed);
      }
    }
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.spaceSm),
            child: Text(title, style: theme.textTheme.titleMedium),
          ),
          ...children,
        ],
      ),
    );
  }
}
