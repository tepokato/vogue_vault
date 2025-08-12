import 'package:flutter_test/flutter_test.dart';
import 'package:vogue_vault/models/client.dart';

void main() {
  group('Client equality', () {
    test('clients with same values are equal', () {
      final c1 = Client(id: 'c1', name: 'Alice', photoUrl: 'p1');
      final c2 = Client(id: 'c1', name: 'Alice', photoUrl: 'p1');

      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));
    });

    test('clients with different values are not equal', () {
      final c1 = Client(id: 'c1', name: 'Alice', photoUrl: 'p1');
      final c2 = Client(id: 'c2', name: 'Alice', photoUrl: 'p1');

      expect(c1, isNot(equals(c2)));
    });
  });
}

