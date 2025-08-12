/// Represents a client that can book services.
class Client {
  /// Unique identifier for the client.
  final String id;

  /// Display name of the client.
  final String name;

  /// URL or file path to the client's profile photo.
  final String? photoUrl;

  /// Creates a new [Client] instance.
  Client({required this.id, required this.name, this.photoUrl});

  /// Returns a copy of this client with the provided values replaced.
  Client copyWith({String? id, String? name, String? photoUrl}) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  /// Creates a [Client] from a JSON-compatible [map].
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] as String,
      name: map['name'] as String,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  /// Converts this client to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Client &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          photoUrl == other.photoUrl;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ photoUrl.hashCode;
}
