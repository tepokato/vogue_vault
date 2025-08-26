import 'service_type.dart';

/// Represents a scheduled appointment for a client.
class Appointment {
  /// Unique identifier for the appointment.
  final String id;

  /// Identifier of the user acting as the client.  If `null`, this appointment
  /// represents a guest who does not have an account in the system.
  final String? clientId;

  /// Display name for a guest client when [clientId] is `null`.
  final String? guestName;

  /// Optional contact information for a guest client.
  final String? guestContact;

  /// Identifier of the user acting as the service provider.
  ///
  /// This field is optional as appointments can now be created without
  /// assigning a specific provider.
  final String? providerId;

  /// The type of service being scheduled.
  final ServiceType service;

  /// The date and time when the appointment takes place.
  final DateTime dateTime;

  /// Length of the appointment.
  final Duration duration;

  /// Creates a new [Appointment].
  Appointment({
    required this.id,
    this.clientId,
    this.guestName,
    this.guestContact,
    this.providerId,
    required this.service,
    required this.dateTime,
    this.duration = const Duration(hours: 1),
  });

  /// Returns a copy of this appointment with the given fields replaced.
  Appointment copyWith({
    String? id,
    String? clientId,
    String? guestName,
    String? guestContact,
    String? providerId,
    ServiceType? service,
    DateTime? dateTime,
    Duration? duration,
  }) {
    return Appointment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      guestName: guestName ?? this.guestName,
      guestContact: guestContact ?? this.guestContact,
      providerId: providerId ?? this.providerId,
      service: service ?? this.service,
      dateTime: dateTime ?? this.dateTime,
      duration: duration ?? this.duration,
    );
  }

  /// Creates an [Appointment] from a JSON-compatible [map].
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as String,
      clientId: map['clientId'] as String?,
      guestName: map['guestName'] as String?,
      guestContact: map['guestContact'] as String?,
      providerId: map['providerId'] as String?,
      service: ServiceType.values.byName(map['service'] as String),
      dateTime: DateTime.parse(map['dateTime'] as String),
      duration: Duration(minutes: (map['duration'] as int?) ?? 60),
    );
  }

  /// Converts this appointment into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'guestName': guestName,
      'guestContact': guestContact,
      'providerId': providerId,
      'service': service.name,
      'dateTime': dateTime.toIso8601String(),
      'duration': duration.inMinutes,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Appointment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clientId == other.clientId &&
          guestName == other.guestName &&
          guestContact == other.guestContact &&
          providerId == other.providerId &&
          service == other.service &&
          dateTime == other.dateTime &&
          duration == other.duration;

  @override
  int get hashCode => id.hashCode ^
      clientId.hashCode ^
      guestName.hashCode ^
      guestContact.hashCode ^
      providerId.hashCode ^
      service.hashCode ^
      dateTime.hashCode ^
      duration.hashCode;
}
