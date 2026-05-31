import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// A soft, rounded surface used as the primary container across the app.
///
/// Provides a consistent radius, padding, optional tap handling and an
/// ambient shadow in light mode so content reads as gently raised.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTokens.space),
    this.onTap,
    this.color,
    this.border,
    this.elevated = true,
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final BoxBorder? border;
  final bool elevated;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = scheme.brightness == Brightness.light;
    final bg = color ?? scheme.surface;

    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppTokens.cardRadius,
          border: border ??
              (isLight
                  ? null
                  : Border.all(color: scheme.outlineVariant.withOpacity(0.6))),
          boxShadow:
              elevated && isLight ? AppTokens.softShadow(scheme.shadow) : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppTokens.cardRadius,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
