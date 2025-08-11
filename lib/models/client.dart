/// Represents a client that can book services.
class Client {
  /// Unique identifier for the client.
  final String id;

  /// Display name of the client.
  final String name;

  /// Creates a new [Client] instance.
  Client({required this.id, required this.name});

  /// Returns a copy of this client with the provided values replaced.
  Client copyWith({String? id, String? name}) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  /// Creates a [Client] from a JSON-compatible [map].
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }

  /// Converts this client to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Client &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
