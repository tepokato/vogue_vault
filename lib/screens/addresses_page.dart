import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:vogue_vault/l10n/app_localizations.dart';

import '../models/address.dart';
import '../services/appointment_service.dart';
import '../widgets/app_scaffold.dart';

class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final addresses = service.addresses;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.addressesTitle,
      body: addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.noAddressesYet,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddressDialog(context),
                    child: Text(l10n.addFirstAddress),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(address.label),
                  subtitle: Text(address.details),
                  onTap: () => _showAddressDialog(context, address: address),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await service.deleteAddress(address.id);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddressDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddressDialog(
    BuildContext context, {
    Address? address,
  }) async {
    final labelController = TextEditingController(text: address?.label ?? '');
    final detailsController = TextEditingController(
      text: address?.details ?? '',
    );
    final formKey = GlobalKey<FormState>();

    try {
      await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              address == null
                  ? AppLocalizations.of(context)!.newAddressTitle
                  : AppLocalizations.of(context)!.editAddressTitle,
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: labelController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.labelLabel,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? AppLocalizations.of(context)!.requiredField
                          : null,
                    ),
                    TextFormField(
                      controller: detailsController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.addressLabel,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? AppLocalizations.of(context)!.requiredField
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancelButton),
              ),
              TextButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final service = context.read<AppointmentService>();
                  final id = address?.id ?? const Uuid().v4();
                  final newAddress = Address(
                    id: id,
                    label: labelController.text.trim(),
                    details: detailsController.text.trim(),
                  );
                  if (address == null) {
                    await service.addAddress(newAddress);
                  } else {
                    await service.updateAddress(newAddress);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.saveButton),
              ),
            ],
          );
        },
      );
    } finally {
      labelController.dispose();
      detailsController.dispose();
    }
  }
}
