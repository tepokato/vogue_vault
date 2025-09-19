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
          ListTile(
            title: Text(l10n.themeLabel),
          ),
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
          ListTile(
            title: Text(l10n.languageLabel),
            trailing: DropdownButton<Locale?>(
              value: service.locale,
              onChanged: service.setLocale,
              items: [
                DropdownMenuItem<Locale?> (
                  value: null,
                  child: Text(l10n.themeSystem),
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
    );
  }
}
