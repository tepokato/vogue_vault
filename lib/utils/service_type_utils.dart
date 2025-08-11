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
}
