import 'package:flutter/material.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../utils/password_strength.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final strength = calculatePasswordStrength(password);
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final activeColor = switch (strength) {
      PasswordStrength.weak => colors.error,
      PasswordStrength.medium => colors.tertiary,
      PasswordStrength.strong => colors.primary,
    };

    final level = switch (strength) {
      PasswordStrength.weak => 1,
      PasswordStrength.medium => 2,
      PasswordStrength.strong => 3,
    };

    final label = switch (strength) {
      PasswordStrength.weak => l10n.passwordStrengthWeak,
      PasswordStrength.medium => l10n.passwordStrengthMedium,
      PasswordStrength.strong => l10n.passwordStrengthStrong,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Semantics(
          label: '${l10n.passwordStrengthLabel}: $label',
          child: Row(
            children: List.generate(3, (index) {
              final isActive = index < level;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: isActive
                        ? activeColor
                        : colors.surfaceVariant.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${l10n.passwordStrengthLabel}: $label',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: activeColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
