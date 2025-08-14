import 'dart:developer' as developer;

import 'service_type.dart';

/// Represents a specific service a professional offers including name and price.
class ServiceOffering {
  /// The type of service.
  final ServiceType type;

  /// The display name of the service.
  final String name;

  /// The price of the service.
  final double price;

  const ServiceOffering({
    required this.type,
    required this.name,
    required this.price,
  });

  /// Creates a copy of this offering with optional replacements.
  ServiceOffering copyWith({
    ServiceType? type,
    String? name,
    double? price,
  }) {
    return ServiceOffering(
      type: type ?? this.type,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }

  /// Converts this offering into a JSON-compatible map.
  Map<String, dynamic> toMap() => {
        'type': type.name,
        'name': name,
        'price': price,
      };

  /// Creates a [ServiceOffering] from a JSON-compatible [map].
  factory ServiceOffering.fromMap(Map<String, dynamic> map) {
    final typeName = map['type'] as String?;
    final serviceType = ServiceType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () {
        developer.log('Unknown service type: $typeName',
            name: 'ServiceOffering');
        return ServiceType.values.first;
      },
    );

    return ServiceOffering(
      type: serviceType,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceOffering &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          price == other.price;

  @override
  int get hashCode => type.hashCode ^ name.hashCode ^ price.hashCode;
}

