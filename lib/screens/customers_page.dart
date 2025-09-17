import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../models/customer.dart';
import '../services/appointment_service.dart';
import '../widgets/app_scaffold.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final customers = service.customers;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.customersTitle,
      body: customers.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.noCustomersYet,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showCustomerDialog(context),
                    child: Text(l10n.addFirstCustomer),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(customer.fullName),
                  subtitle: customer.contactInfo != null
                      ? Text(customer.contactInfo!)
                      : null,
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

  Future<void> _showCustomerDialog(
    BuildContext context, {
    Customer? customer,
  }) async {
    final service = context.read<AppointmentService>();
    final firstNameController = TextEditingController(
      text: customer?.firstName ?? '',
    );
    final lastNameController = TextEditingController(
      text: customer?.lastName ?? '',
    );
    final contactController = TextEditingController(
      text: customer?.contactInfo ?? '',
    );
    final formKey = GlobalKey<FormState>();

    try {
      await showDialog(
        context: context,
        builder: (_) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(
                  customer == null
                      ? AppLocalizations.of(context)!.newCustomerTitle
                      : AppLocalizations.of(context)!.editCustomerTitle,
                ),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(
                              context,
                            )!.firstNameLabel,
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? AppLocalizations.of(context)!.firstNameRequired
                              : null,
                        ),
                        TextFormField(
                          controller: lastNameController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(
                              context,
                            )!.lastNameLabel,
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? AppLocalizations.of(context)!.lastNameRequired
                              : null,
                        ),
                        TextFormField(
                          controller: contactController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(
                              context,
                            )!.contactInfoLabel,
                          ),
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
                      final id = customer?.id ?? const Uuid().v4();
                      final newCustomer = Customer(
                        id: id,
                        firstName: firstNameController.text.trim(),
                        lastName: lastNameController.text.trim(),
                        contactInfo: contactController.text.trim().isEmpty
                            ? null
                            : contactController.text.trim(),
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
    }
  }
}
