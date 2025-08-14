import 'package:flutter/material.dart';

import '../models/service_type.dart';

/// Returns a human-readable label for the given [ServiceType].
///
/// The switch is exhaustive; a label is provided for every service type.
String serviceTypeLabel(ServiceType type) {
  switch (type) {
    case ServiceType.barber:
      return 'Barbershop';
    case ServiceType.hairdresser:
      return 'Hairdresser';
    case ServiceType.nails:
      return 'Nails';
    case ServiceType.tattoo:
      return 'Tattoo Artist';
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
      return Colors.blue;
    case ServiceType.hairdresser:
      return Colors.purple;
    case ServiceType.nails:
      return Colors.pink;
    case ServiceType.tattoo:
      return Colors.black;
  }
  assert(false, 'Unhandled ServiceType: $type');
  throw ArgumentError('Unhandled ServiceType: $type');
}
