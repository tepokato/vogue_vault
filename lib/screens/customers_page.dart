import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../app/theme.dart';
import '../models/customer.dart';
import '../services/appointment_service.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/ui/ui.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final customers = service.customers
      ..sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.customersTitle,
      actions: [
        IconButton(
          icon: const Icon(Icons.person_add_alt_1_outlined),
          tooltip: l10n.newCustomerTitle,
          onPressed: () => showCustomerEditor(context),
        ),
      ],
      body: customers.isEmpty
          ? EmptyState(
              icon: Icons.groups_outlined,
              title: l10n.noCustomersYet,
              actionLabel: l10n.addFirstCustomer,
              onAction: () => showCustomerEditor(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.space,
                AppTokens.spaceSm,
                AppTokens.space,
                AppTokens.spaceXl,
              ),
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                return _CustomerCard(customer: customer);
              },
            ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer});

  final Customer customer;

  String get _initials {
    final f = customer.firstName.isNotEmpty ? customer.firstName[0] : '';
    final l = customer.lastName.isNotEmpty ? customer.lastName[0] : '';
    final i = (f + l).toUpperCase();
    return i.isEmpty ? '?' : i;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.spaceMd),
      child: AppCard(
        onTap: () => showCustomerEditor(context, customer: customer),
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: scheme.primary.withOpacity(0.14),
              child: Text(
                _initials,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                ),
              ),
            ),
            const SizedBox(width: AppTokens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.fullName, style: theme.textTheme.titleSmall),
                  if (customer.contactInfo != null &&
                      customer.contactInfo!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      customer.contactInfo!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.deleteButton,
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final service = context.read<AppointmentService>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteCustomerDialogTitle),
        content: Text(l10n.deleteCustomerDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.dialogCancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.dialogConfirmAction),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      await service.deleteCustomer(customer.id);
    }
  }
}

/// Opens a modal sheet to create or edit a [Customer].
Future<void> showCustomerEditor(
  BuildContext context, {
  Customer? customer,
}) async {
  final service = context.read<AppointmentService>();
  final firstNameController =
      TextEditingController(text: customer?.firstName ?? '');
  final lastNameController =
      TextEditingController(text: customer?.lastName ?? '');
  final contactController =
      TextEditingController(text: customer?.contactInfo ?? '');
  final formKey = GlobalKey<FormState>();

  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext)!;
        return EditorSheet(
          title: customer == null
              ? l10n.newCustomerTitle
              : l10n.editCustomerTitle,
          formKey: formKey,
          fields: [
            TextFormField(
              controller: firstNameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.firstNameLabel),
              validator: (v) => v == null || v.trim().isEmpty
                  ? l10n.firstNameRequired
                  : null,
            ),
            const SizedBox(height: AppTokens.spaceMd),
            TextFormField(
              controller: lastNameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.lastNameLabel),
              validator: (v) => v == null || v.trim().isEmpty
                  ? l10n.lastNameRequired
                  : null,
            ),
            const SizedBox(height: AppTokens.spaceMd),
            TextFormField(
              controller: contactController,
              decoration: InputDecoration(labelText: l10n.contactInfoLabel),
            ),
          ],
          onSave: () async {
            if (!formKey.currentState!.validate()) return;
            final id = customer?.id ?? const Uuid().v4();
            final updated = Customer(
              id: id,
              firstName: firstNameController.text.trim(),
              lastName: lastNameController.text.trim(),
              contactInfo: contactController.text.trim().isEmpty
                  ? null
                  : contactController.text.trim(),
            );
            if (customer == null) {
              await service.addCustomer(updated);
            } else {
              await service.updateCustomer(updated);
            }
            if (sheetContext.mounted) Navigator.pop(sheetContext);
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
