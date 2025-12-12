import 'package:flutter/material.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import 'customers_page.dart';
import 'addresses_page.dart';
import 'notification_settings_page.dart';
import '../widgets/app_scaffold.dart';

class MyBusinessPage extends StatelessWidget {
  const MyBusinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppLocalizations.of(context)!.myBusinessTitle,
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.group),
            title: Text(AppLocalizations.of(context)!.customersTitle),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomersPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(AppLocalizations.of(context)!.addressesTitle),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressesPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(
              AppLocalizations.of(context)!.notificationSettingsTitle,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
