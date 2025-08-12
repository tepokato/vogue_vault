import 'package:flutter/material.dart';

import '../models/service_type.dart';

String serviceTypeLabel(ServiceType type) {
  switch (type) {
    case ServiceType.barber:
      return 'Barbershop';
    case ServiceType.hairdresser:
      return 'Hairdresser';
    case ServiceType.nails:
      return 'Nails';
  }
  assert(false, 'Unhandled ServiceType: $type');
  throw ArgumentError('Unhandled ServiceType: $type');
}

IconData serviceTypeIcon(ServiceType type) {
  switch (type) {
    case ServiceType.barber:
      return Icons.content_cut;
    case ServiceType.hairdresser:
      return Icons.brush;
    case ServiceType.nails:
      return Icons.spa;
  }
  assert(false, 'Unhandled ServiceType: $type');
  throw ArgumentError('Unhandled ServiceType: $type');
}

Color serviceTypeColor(ServiceType type) {
  switch (type) {
    case ServiceType.barber:
      return Colors.blue;
    case ServiceType.hairdresser:
      return Colors.purple;
    case ServiceType.nails:
      return Colors.pink;
  }
  assert(false, 'Unhandled ServiceType: $type');
  throw ArgumentError('Unhandled ServiceType: $type');
}
