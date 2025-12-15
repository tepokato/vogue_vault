import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../services/backup_service.dart';
import '../services/settings_service.dart';
import 'notification_settings_page.dart';
import '../widgets/app_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
