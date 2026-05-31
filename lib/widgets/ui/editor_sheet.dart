import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';

/// A reusable bottom-sheet editor scaffold for simple create/edit forms.
///
/// Renders a grab handle, title, a [Form] wrapping [fields] and a primary
/// save button. Callers own their controllers and validation.
class EditorSheet extends StatelessWidget {
  const EditorSheet({
    super.key,
    required this.title,
    required this.formKey,
    required this.fields,
    required this.onSave,
    this.saveLabel,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> fields;
  final Future<void> Function() onSave;
  final String? saveLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTokens.spaceLg,
        AppTokens.space,
        AppTokens.spaceLg,
        AppTokens.spaceLg + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppTokens.space),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: AppTokens.pillRadius,
                ),
              ),
            ),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppTokens.spaceLg),
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: fields,
              ),
            ),
            const SizedBox(height: AppTokens.spaceLg),
            FilledButton(
              onPressed: onSave,
              child: Text(saveLabel ?? l10n.saveButton),
            ),
          ],
        ),
      ),
    );
  }
}
