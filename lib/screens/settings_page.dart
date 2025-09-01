import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../services/settings_service.dart';
import '../widgets/app_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final service = context.watch<SettingsService>();

    return AppScaffold(
      title: l10n.settingsTitle,
      body: ListView(
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('System'),
            value: ThemeMode.system,
            groupValue: service.themeMode,
            onChanged: (mode) {
              if (mode != null) {
                service.setThemeMode(mode);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: service.themeMode,
            onChanged: (mode) {
              if (mode != null) {
                service.setThemeMode(mode);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: service.themeMode,
            onChanged: (mode) {
              if (mode != null) {
                service.setThemeMode(mode);
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Language'),
            trailing: DropdownButton<Locale>(
              value: service.locale,
              onChanged: (locale) {
                if (locale != null) {
                  service.setLocale(locale);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: Locale('es'),
                  child: Text('Español'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
