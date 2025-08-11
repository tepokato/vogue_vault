class Client {
  final String id;
  final String name;

  Client({required this.id, required this.name});

  Client copyWith({String? id, String? name}) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
