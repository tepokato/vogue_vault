import 'service_type.dart';

/// Represents a service provider available for bookings.
class ServiceProvider {
  /// Unique identifier for the service provider.
  final String id;

  /// Display name of the provider.
  final String name;

  /// The type of service this provider offers.
  final ServiceType serviceType;

  /// Creates a new [ServiceProvider] instance.
  ServiceProvider({
    required this.id,
    required this.name,
    required this.serviceType,
  });

  /// Returns a copy of this provider with the provided values replaced.
  ServiceProvider copyWith({
    String? id,
    String? name,
    ServiceType? serviceType,
  }) {
    return ServiceProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      serviceType: serviceType ?? this.serviceType,
    );
  }

  /// Creates a [ServiceProvider] from a JSON-compatible [map].
  factory ServiceProvider.fromMap(Map<String, dynamic> map) {
    return ServiceProvider(
      id: map['id'] as String,
      name: map['name'] as String,
      serviceType: ServiceType.values.byName(map['serviceType'] as String),
    );
  }

  /// Converts this provider to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'serviceType': serviceType.name,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceProvider &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          serviceType == other.serviceType;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ serviceType.hashCode;
}

