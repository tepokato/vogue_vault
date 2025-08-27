import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../models/address.dart';
import '../models/customer.dart';
import '../services/appointment_service.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final customers = service.customers;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.customersTitle),
      ),
      body: ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(customer.fullName),
            subtitle:
                customer.contactInfo != null ? Text(customer.contactInfo!) : null,
            onTap: () => _showCustomerDialog(context, customer: customer),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await service.deleteCustomer(customer.id);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCustomerDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showCustomerDialog(BuildContext context,
      {Customer? customer}) async {
    final firstNameController =
        TextEditingController(text: customer?.firstName ?? '');
    final lastNameController =
        TextEditingController(text: customer?.lastName ?? '');
    final contactController =
        TextEditingController(text: customer?.contactInfo ?? '');
    final formKey = GlobalKey<FormState>();
    final addressesData = (customer?.addresses ?? [])
        .map((a) => {
              'id': a.id,
              'label': TextEditingController(text: a.label),
              'details': TextEditingController(text: a.details),
            })
        .toList();

    try {
      await showDialog(
        context: context,
        builder: (_) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(customer == null
                    ? AppLocalizations.of(context)!.newCustomerTitle
                    : AppLocalizations.of(context)!.editCustomerTitle),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.firstNameLabel),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? AppLocalizations.of(context)!
                                      .firstNameRequired
                                  : null,
                        ),
                        TextFormField(
                          controller: lastNameController,
                          decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.lastNameLabel),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? AppLocalizations.of(context)!
                                      .lastNameRequired
                                  : null,
                        ),
                        TextFormField(
                          controller: contactController,
                          decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!
                                      .contactInfoLabel),
                        ),
                        for (var i = 0; i < addressesData.length; i++) ...[
                          TextFormField(
                            controller: addressesData[i]['label']
                                as TextEditingController,
                            decoration:
                                const InputDecoration(labelText: 'Label'),
                          ),
                          TextFormField(
                            controller: addressesData[i]['details']
                                as TextEditingController,
                            decoration:
                                const InputDecoration(labelText: 'Address'),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                final data = addressesData.removeAt(i);
                                (data['label'] as TextEditingController)
                                    .dispose();
                                (data['details'] as TextEditingController)
                                    .dispose();
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              addressesData.add({
                                'id': const Uuid().v4(),
                                'label': TextEditingController(),
                                'details': TextEditingController(),
                              });
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Address'),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child:
                        Text(AppLocalizations.of(context)!.cancelButton),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final service = context.read<AppointmentService>();
                      final id = customer?.id ?? const Uuid().v4();
                      final addresses = addressesData
                          .map((data) => Address(
                                id: data['id'] as String,
                                label: (data['label'] as TextEditingController)
                                    .text
                                    .trim(),
                                details:
                                    (data['details'] as TextEditingController)
                                        .text
                                        .trim(),
                              ))
                          .where((a) =>
                              a.label.isNotEmpty && a.details.isNotEmpty)
                          .toList();
                      final newCustomer = Customer(
                        id: id,
                        firstName: firstNameController.text.trim(),
                        lastName: lastNameController.text.trim(),
                        contactInfo: contactController.text.trim().isEmpty
                            ? null
                            : contactController.text.trim(),
                        addresses: addresses,
                      );
                      if (customer == null) {
                        await service.addCustomer(newCustomer);
                      } else {
                        await service.updateCustomer(newCustomer);
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.saveButton),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      firstNameController.dispose();
      lastNameController.dispose();
      contactController.dispose();
      for (final data in addressesData) {
        (data['label'] as TextEditingController).dispose();
        (data['details'] as TextEditingController).dispose();
      }
    }
  }
}

