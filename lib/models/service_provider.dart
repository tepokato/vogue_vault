import 'service_type.dart';

/// Represents a service provider available for bookings.
class ServiceProvider {
  /// Unique identifier for the service provider.
  final String id;

  /// Display name of the provider.
  final String name;

  /// URL or file path to the provider's profile photo.
  final String? photoUrl;

  /// The type of service this provider offers.
  final ServiceType serviceType;

  /// Creates a new [ServiceProvider] instance.
  ServiceProvider({
    required this.id,
    required this.name,
    required this.serviceType,
    this.photoUrl,
  });

  /// Returns a copy of this provider with the provided values replaced.
  ServiceProvider copyWith({
    String? id,
    String? name,
    ServiceType? serviceType,
    String? photoUrl,
  }) {
    return ServiceProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      serviceType: serviceType ?? this.serviceType,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  /// Creates a [ServiceProvider] from a JSON-compatible [map].
  factory ServiceProvider.fromMap(Map<String, dynamic> map) {
    return ServiceProvider(
      id: map['id'] as String,
      name: map['name'] as String,
      serviceType: ServiceType.values.byName(map['serviceType'] as String),
      photoUrl: map['photoUrl'] as String?,
    );
  }

  /// Converts this provider to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'serviceType': serviceType.name,
      'photoUrl': photoUrl,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceProvider &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          serviceType == other.serviceType &&
          photoUrl == other.photoUrl;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ serviceType.hashCode ^ photoUrl.hashCode;
}

