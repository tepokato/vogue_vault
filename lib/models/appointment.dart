import 'service_type.dart';

/// Represents a scheduled appointment for a client.
class Appointment {
  /// Unique identifier for the appointment.
  final String id;

  /// Identifier of the client booking the appointment.
  final String clientId;

  /// Identifier of the service provider handling the appointment.
  final String providerId;

  /// The type of service being scheduled.
  final ServiceType service;

  /// The date and time when the appointment takes place.
  final DateTime dateTime;

  /// Creates a new [Appointment].
  Appointment({
    required this.id,
    required this.clientId,
    required this.providerId,
    required this.service,
    required this.dateTime,
  });

  /// Returns a copy of this appointment with the given fields replaced.
  Appointment copyWith({
    String? id,
    String? clientId,
    String? providerId,
    ServiceType? service,
    DateTime? dateTime,
  }) {
    return Appointment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      providerId: providerId ?? this.providerId,
      service: service ?? this.service,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  /// Creates an [Appointment] from a JSON-compatible [map].
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as String,
      clientId: map['clientId'] as String,
      providerId: map['providerId'] as String,
      service: ServiceType.values.byName(map['service'] as String),
      dateTime: DateTime.parse(map['dateTime'] as String),
    );
  }

  /// Converts this appointment into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'providerId': providerId,
      'service': service.name,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Appointment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clientId == other.clientId &&
          providerId == other.providerId &&
          service == other.service &&
          dateTime == other.dateTime;

  @override
  int get hashCode => id.hashCode ^
      clientId.hashCode ^
      providerId.hashCode ^
      service.hashCode ^
      dateTime.hashCode;
}
