/// Represents a client that can book appointments.
class Client {
  /// Unique identifier for the client.
  final String id;

  /// Full name of the client.
  final String name;

  /// Contact details such as phone number or email.
  final String contact;

  /// Optional notes about the client.
  final String? notes;

  Client({
    required this.id,
    required this.name,
    required this.contact,
    this.notes,
  });

  /// Returns a copy of this client with the given fields replaced.
  Client copyWith({
    String? id,
    String? name,
    String? contact,
    String? notes,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      notes: notes ?? this.notes,
    );
  }

  /// Creates a [Client] from a JSON-compatible [map].
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] as String,
      name: map['name'] as String,
      contact: map['contact'] as String,
      notes: map['notes'] as String?,
    );
  }

  /// Converts this client into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'notes': notes,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Client &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          contact == other.contact &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ contact.hashCode ^ notes.hashCode;
}

