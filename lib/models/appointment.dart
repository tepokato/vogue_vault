import 'service_type.dart';

/// Represents a scheduled appointment.
class Appointment {
  /// Unique identifier for the appointment.
  final String id;

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
    this.providerId,
    required this.service,
    required this.dateTime,
    this.duration = const Duration(hours: 1),
  });

  /// Returns a copy of this appointment with the given fields replaced.
  Appointment copyWith({
    String? id,
    String? providerId,
    ServiceType? service,
    DateTime? dateTime,
    Duration? duration,
  }) {
    return Appointment(
      id: id ?? this.id,
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
          providerId == other.providerId &&
          service == other.service &&
          dateTime == other.dateTime &&
          duration == other.duration;

  @override
  int get hashCode =>
      id.hashCode ^
      providerId.hashCode ^
      service.hashCode ^
      dateTime.hashCode ^
      duration.hashCode;
}
