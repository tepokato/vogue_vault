import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/service_type.dart';
import 'color_palette.dart';

/// Returns a localized label for the given [ServiceType].
///
/// The switch is exhaustive; a label is provided for every service type.
String serviceTypeLabel(BuildContext context, ServiceType type) {
  final l10n = AppLocalizations.of(context)!;
  switch (type) {
    case ServiceType.barber:
      return l10n.serviceTypeBarber;
    case ServiceType.hairdresser:
      return l10n.serviceTypeHairdresser;
    case ServiceType.nails:
      return l10n.serviceTypeNails;
    case ServiceType.tattoo:
      return l10n.serviceTypeTattoo;
  }
  assert(false, 'Unhandled ServiceType: $type');
  throw ArgumentError('Unhandled ServiceType: $type');
}

/// Returns an [IconData] representing the given [ServiceType].
///
/// The switch is exhaustive; each service type has a corresponding icon.
IconData serviceTypeIcon(ServiceType type) {
  switch (type) {
    case ServiceType.barber:
      return Icons.content_cut;
    case ServiceType.hairdresser:
      return Icons.brush;
    case ServiceType.nails:
      return Icons.spa;
    case ServiceType.tattoo:
      return Icons.edit;
  }
  assert(false, 'Unhandled ServiceType: $type');
  throw ArgumentError('Unhandled ServiceType: $type');
}

/// Returns a themed [Color] for the given [ServiceType].
///
/// The switch is exhaustive; each service type maps to a color.
Color serviceTypeColor(ServiceType type) {
  switch (type) {
    case ServiceType.barber:
      return AppColors.primary;
    case ServiceType.hairdresser:
      return AppColors.secondary;
    case ServiceType.nails:
      return AppColors.accent;
    case ServiceType.tattoo:
      return AppColors.background;
  }
  assert(false, 'Unhandled ServiceType: $type');
  throw ArgumentError('Unhandled ServiceType: $type');
}
