/// Represents an optional add-on for an appointment.
class AddOn {
  /// Display name for the add-on.
  final String name;

  /// Price for the add-on.
  final double price;

  const AddOn({
    required this.name,
    required this.price,
  });

  /// Creates a copy of the add-on with optional replacements.
  AddOn copyWith({
    String? name,
    double? price,
  }) {
    return AddOn(
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }

  /// Converts this add-on into a JSON-compatible map.
  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
      };

  /// Creates an [AddOn] from a JSON-compatible [map].
  factory AddOn.fromMap(Map<String, dynamic> map) {
    return AddOn(
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddOn &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          price == other.price;

  @override
  int get hashCode => name.hashCode ^ price.hashCode;
}
