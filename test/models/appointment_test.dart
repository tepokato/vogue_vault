import 'package:flutter_test/flutter_test.dart';
import 'package:vogue_vault/models/appointment.dart';
import 'package:vogue_vault/models/service_type.dart';

void main() {
  group('Appointment serialization', () {
    test('toMap and fromMap produce equivalent objects', () {
      final appointment = Appointment(
        id: 'a1',
        clientId: 'c1',
        providerId: 'p1',
        service: ServiceType.barber,
        dateTime: DateTime(2023, 9, 10, 10, 0),
      );
      final map = appointment.toMap();
      final from = Appointment.fromMap(map);

      expect(from.id, appointment.id);
      expect(from.clientId, appointment.clientId);
      expect(from.providerId, appointment.providerId);
      expect(from.service, appointment.service);
      expect(from.dateTime, appointment.dateTime);
    });

    test('supports guest clients', () {
      final appointment = Appointment(
        id: 'a2',
        guestName: 'Walk-in',
        guestContact: '555-1234',
        providerId: 'p1',
        service: ServiceType.barber,
        dateTime: DateTime(2023, 9, 10, 11, 0),
      );
      final map = appointment.toMap();
      final from = Appointment.fromMap(map);

      expect(from.clientId, isNull);
      expect(from.guestName, appointment.guestName);
      expect(from.guestContact, appointment.guestContact);
    });

    test('fromMap validates required data', () {
      final missingFields = {'id': 'a1'};
      expect(() => Appointment.fromMap(missingFields), throwsA(isA<TypeError>()));

      final invalidDate = {
        'id': 'a1',
        'clientId': 'c1',
        'providerId': 'p1',
        'service': 'barber',
        'dateTime': 'invalid',
      };
      expect(() => Appointment.fromMap(invalidDate), throwsA(isA<FormatException>()));
    });
  });

  group('Appointment equality', () {
    test('appointments with the same values are equal', () {
      final a1 = Appointment(
        id: 'a1',
        clientId: 'c1',
        providerId: 'p1',
        service: ServiceType.barber,
        dateTime: DateTime(2023, 9, 10, 10, 0),
      );
      final a2 = Appointment(
        id: 'a1',
        clientId: 'c1',
        providerId: 'p1',
        service: ServiceType.barber,
        dateTime: DateTime(2023, 9, 10, 10, 0),
      );

      expect(a1, equals(a2));
      expect(a1.hashCode, equals(a2.hashCode));
    });

    test('appointments with same guest values are equal', () {
      final dt = DateTime(2023, 9, 10, 10, 0);
      final a1 = Appointment(
        id: 'a1',
        guestName: 'Walk-in',
        guestContact: '555',
        providerId: 'p1',
        service: ServiceType.barber,
        dateTime: dt,
      );
      final a2 = Appointment(
        id: 'a1',
        guestName: 'Walk-in',
        guestContact: '555',
        providerId: 'p1',
        service: ServiceType.barber,
        dateTime: dt,
      );
      expect(a1, equals(a2));
      expect(a1.hashCode, equals(a2.hashCode));
    });

    test('appointments with different values are not equal', () {
      final a1 = Appointment(
        id: 'a1',
        clientId: 'c1',
        providerId: 'p1',
        service: ServiceType.barber,
        dateTime: DateTime(2023, 9, 10, 10, 0),
      );
      final a2 = Appointment(
        id: 'a2',
        clientId: 'c1',
        providerId: 'p1',
        service: ServiceType.barber,
        dateTime: DateTime(2023, 9, 10, 10, 0),
      );

      expect(a1, isNot(equals(a2)));
    });
  });
}
