import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../l10n/app_localizations.dart';

/// A reusable selector for choosing one or more [UserRole] values.
///
/// Displays roles using a consistent [SegmentedButton] control and notifies
/// callers when the selection changes.
class RoleSelector extends StatelessWidget {
  /// Currently selected roles.
  final Set<UserRole> selected;

  /// Callback invoked when the selection changes.
  final ValueChanged<Set<UserRole>> onChanged;

  const RoleSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  String _label(AppLocalizations l10n, UserRole role) {
    switch (role) {
      case UserRole.customer:
        return l10n.customerRole;
      case UserRole.professional:
        return l10n.professionalRole;
      default:
        return role.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SegmentedButton<UserRole>(
      segments: UserRole.values
          .map((role) => ButtonSegment<UserRole>(
                value: role,
                label: Text(_label(l10n, role)),
              ))
          .toList(),
      multiSelectionEnabled: true,
      selected: selected,
      onSelectionChanged: onChanged,
    );
  }
}

