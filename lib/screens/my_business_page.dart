import 'package:flutter/material.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import 'customers_page.dart';

class MyBusinessPage extends StatelessWidget {
  const MyBusinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myBusinessTitle),
      ),
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
        ],
      ),
    );
  }
}

