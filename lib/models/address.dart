/// Represents a saved location that can be reused for appointments.
class Address {
  /// Unique identifier for the address.
  final String id;

  /// Short label for the address (e.g. 'Home', 'Studio').
  final String label;

  /// Full address or description.
  final String details;

  const Address({required this.id, required this.label, required this.details});

  /// Creates an [Address] from a JSON-compatible [map].
  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] as String,
      label: map['label'] as String,
      details: map['details'] as String,
    );
  }

  /// Converts this address into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'details': details,
    };
  }

  Address copyWith({String? id, String? label, String? details}) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      details: details ?? this.details,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          details == other.details;

  @override
  int get hashCode => id.hashCode ^ label.hashCode ^ details.hashCode;
}

