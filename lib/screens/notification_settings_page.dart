import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../services/notification_service.dart';
import '../widgets/app_scaffold.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final List<Duration> _options = const [
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(minutes: 60),
  ];

  late Duration _selected;

  @override
  void initState() {
    super.initState();
    final service = context.read<NotificationService>();
    _selected = service.reminderOffset;
  }

  Future<void> _save() async {
    final service = context.read<NotificationService>();
    await service.setReminderOffset(_selected);
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: _options
                    .map(
                      (d) => RadioListTile<Duration>(
                        title: Text(l10n.minutesBefore(d.inMinutes)),
                        value: d,
                        groupValue: _selected,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selected = value);
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(l10n.saveButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
