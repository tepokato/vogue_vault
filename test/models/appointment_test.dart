import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:vogue_vault/models/appointment.dart';
import 'package:vogue_vault/models/service_type.dart';

void main() {
  group('Appointment serialization', () {
    test('toMap and fromMap produce equivalent objects', () {
      const uuid = Uuid();
      final id = uuid.v4();
      final appointment = Appointment(
        id: id,
        service: ServiceType.barber,
        dateTime: DateTime(2023, 9, 10, 10, 0),
        duration: const Duration(minutes: 45),
      );
      final map = appointment.toMap();
      final from = Appointment.fromMap(map);

      expect(from.id, appointment.id);
      expect(from.providerId, isNull);
      expect(from.service, appointment.service);
      expect(from.dateTime, appointment.dateTime);
      expect(from.duration, appointment.duration);
    });

    test('fromMap validates required data', () {
      const uuid = Uuid();
      final missingFields = {'id': uuid.v4()};
      expect(
        () => Appointment.fromMap(missingFields),
        throwsA(isA<TypeError>()),
      );

      final invalidDate = {
        'id': uuid.v4(),
        'service': 'barber',
        'dateTime': 'invalid',
      };
      expect(
        () => Appointment.fromMap(invalidDate),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Appointment equality', () {
    test('appointments with the same values are equal', () {
      const uuid = Uuid();
      final id = uuid.v4();
      final a1 = Appointment(
        id: id,
        service: ServiceType.barber,
        dateTime: DateTime(2023, 9, 10, 10, 0),
        duration: const Duration(hours: 1),
      );
      final a2 = Appointment(
        id: id,
        service: ServiceType.barber,
        dateTime: DateTime(2023, 9, 10, 10, 0),
        duration: const Duration(hours: 1),
      );

      expect(a1, equals(a2));
      expect(a1.hashCode, equals(a2.hashCode));
    });

    test('appointments with different values are not equal', () {
      const uuid = Uuid();
      final id1 = uuid.v4();
      final id2 = uuid.v4();
      final a1 = Appointment(
        id: id1,
        service: ServiceType.barber,
        dateTime: DateTime(2023, 9, 10, 10, 0),
        duration: const Duration(hours: 1),
      );
      final a2 = Appointment(
        id: id2,
        service: ServiceType.barber,
        dateTime: DateTime(2023, 9, 10, 10, 0),
        duration: const Duration(hours: 1),
      );

      expect(a1, isNot(equals(a2)));
    });
  });
}
