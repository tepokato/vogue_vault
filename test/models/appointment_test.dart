import 'package:flutter_test/flutter_test.dart';
import 'package:vogue_vault/models/appointment.dart';

void main() {
  group('Appointment serialization', () {
    test('toMap and fromMap produce equivalent objects', () {
      final appointment = Appointment(
        id: 'a1',
        clientId: 'c1',
        service: 'Consultation',
        dateTime: DateTime(2023, 9, 10, 10, 0),
      );
      final map = appointment.toMap();
      final from = Appointment.fromMap(map);

      expect(from.id, appointment.id);
      expect(from.clientId, appointment.clientId);
      expect(from.service, appointment.service);
      expect(from.dateTime, appointment.dateTime);
    });

    test('fromMap validates required data', () {
      final missingFields = {'id': 'a1'};
      expect(() => Appointment.fromMap(missingFields), throwsA(isA<TypeError>()));

      final invalidDate = {
        'id': 'a1',
        'clientId': 'c1',
        'service': 'Consultation',
        'dateTime': 'invalid',
      };
      expect(() => Appointment.fromMap(invalidDate), throwsA(isA<FormatException>()));
    });
  });
}
