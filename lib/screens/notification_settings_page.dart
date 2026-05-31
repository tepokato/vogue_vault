import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../app/theme.dart';
import '../services/notification_service.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/ui/ui.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final List<Duration> _options = const [
    Duration(minutes: 0),
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(minutes: 60),
    Duration(minutes: 120),
    Duration(minutes: 1440),
  ];

  late Duration _selected;

  @override
  void initState() {
    super.initState();
    _selected = context.read<NotificationService>().reminderOffset;
  }

  Future<void> _save() async {
    await context.read<NotificationService>().setReminderOffset(_selected);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.changesSaved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppScaffold(
      title: l10n.notificationSettingsTitle,
      showProfileButton: false,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.space,
                AppTokens.spaceSm,
                AppTokens.space,
                AppTokens.space,
              ),
              children: [
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.spaceSm,
                    vertical: AppTokens.spaceSm,
                  ),
                  child: Column(
                    children: [
                      for (final d in _options)
                        RadioListTile<Duration>(
                          title: Text(
                            d.inMinutes == 0
                                ? l10n.reminderAtTime
                                : l10n.minutesBefore(d.inMinutes),
                          ),
                          value: d,
                          groupValue: _selected,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selected = value);
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.space,
              0,
              AppTokens.space,
              AppTokens.space,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: Text(l10n.saveButton),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
