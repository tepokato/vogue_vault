import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:vogue_vault/models/client.dart';

void main() {
  group('Client model', () {
    test('toMap and fromMap produce equivalent objects', () {
      const uuid = Uuid();
      final client = Client(
        id: uuid.v4(),
        name: 'Alice',
        contact: 'alice@example.com',
        notes: 'VIP',
      );
      final map = client.toMap();
      final from = Client.fromMap(map);
      expect(from.id, client.id);
      expect(from.name, client.name);
      expect(from.contact, client.contact);
      expect(from.notes, client.notes);
    });

    test('clients with same values are equal', () {
      const uuid = Uuid();
      final id = uuid.v4();
      final c1 = Client(id: id, name: 'Bob', contact: '123');
      final c2 = Client(id: id, name: 'Bob', contact: '123');
      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));
    });

    test('clients with different values are not equal', () {
      const uuid = Uuid();
      final c1 = Client(id: uuid.v4(), name: 'A', contact: '1');
      final c2 = Client(id: uuid.v4(), name: 'B', contact: '2');
      expect(c1, isNot(equals(c2)));
    });
  });
}

