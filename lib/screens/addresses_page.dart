import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../app/theme.dart';
import '../models/address.dart';
import '../services/appointment_service.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/ui/ui.dart';

class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final addresses = service.addresses;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.addressesTitle,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_location_alt_outlined),
          tooltip: l10n.newAddressTitle,
          onPressed: () => showAddressEditor(context),
        ),
      ],
      body: addresses.isEmpty
          ? EmptyState(
              icon: Icons.place_outlined,
              title: l10n.noAddressesYet,
              actionLabel: l10n.addFirstAddress,
              onAction: () => showAddressEditor(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.space,
                AppTokens.spaceSm,
                AppTokens.space,
                AppTokens.spaceXl,
              ),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return _AddressCard(address: address);
              },
            ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});

  final Address address;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.spaceMd),
      child: AppCard(
        onTap: () => showAddressEditor(context, address: address),
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.secondary.withOpacity(0.16),
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
              child: Icon(Icons.place_outlined, color: scheme.secondary),
            ),
            const SizedBox(width: AppTokens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(address.label, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    address.details,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
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
        title: Text(l10n.deleteAddressDialogTitle),
        content: Text(l10n.deleteAddressDialogBody),
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
      await service.deleteAddress(address.id);
    }
  }
}

/// Opens a modal sheet to create or edit an [Address].
Future<void> showAddressEditor(
  BuildContext context, {
  Address? address,
}) async {
  final service = context.read<AppointmentService>();
  final labelController = TextEditingController(text: address?.label ?? '');
  final detailsController =
      TextEditingController(text: address?.details ?? '');
  final formKey = GlobalKey<FormState>();

  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext)!;
        return EditorSheet(
          title: address == null
              ? l10n.newAddressTitle
              : l10n.editAddressTitle,
          formKey: formKey,
          fields: [
            TextFormField(
              controller: labelController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.labelLabel),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: AppTokens.spaceMd),
            TextFormField(
              controller: detailsController,
              minLines: 1,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.addressLabel),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.requiredField : null,
            ),
          ],
          onSave: () async {
            if (!formKey.currentState!.validate()) return;
            final id = address?.id ?? const Uuid().v4();
            final updated = Address(
              id: id,
              label: labelController.text.trim(),
              details: detailsController.text.trim(),
            );
            if (address == null) {
              await service.addAddress(updated);
            } else {
              await service.updateAddress(updated);
            }
            if (sheetContext.mounted) Navigator.pop(sheetContext);
          },
        );
      },
    );
  } finally {
    labelController.dispose();
    detailsController.dispose();
  }
}
