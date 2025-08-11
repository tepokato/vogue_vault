import 'service_type.dart';

class Appointment {
  final String id;
  final String clientId;
  final ServiceType service;
  final DateTime dateTime;

  Appointment({
    required this.id,
    required this.clientId,
    required this.service,
    required this.dateTime,
  });

  Appointment copyWith({
    String? id,
    String? clientId,
    ServiceType? service,
    DateTime? dateTime,
  }) {
    return Appointment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      service: service ?? this.service,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as String,
      clientId: map['clientId'] as String,
      service: ServiceType.values.byName(map['service'] as String),
      dateTime: DateTime.parse(map['dateTime'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'service': service.name,
      'dateTime': dateTime.toIso8601String(),
    };
  }
}
