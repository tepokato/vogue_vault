import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/address.dart';
import '../services/appointment_service.dart';

class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final addresses = service.addresses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Addresses'),
      ),
      body: ListView.builder(
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

  Future<void> _showAddressDialog(BuildContext context, {Address? address}) async {
    final labelController = TextEditingController(text: address?.label ?? '');
    final detailsController = TextEditingController(text: address?.details ?? '');
    final formKey = GlobalKey<FormState>();

    try {
      await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(address == null ? 'New Address' : 'Edit Address'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: labelController,
                      decoration: const InputDecoration(labelText: 'Label'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: detailsController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
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
                child: const Text('Save'),
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

