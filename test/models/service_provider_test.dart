import 'package:flutter_test/flutter_test.dart';
import 'package:vogue_vault/models/service_provider.dart';
import 'package:vogue_vault/models/service_type.dart';

void main() {
  group('ServiceProvider serialization', () {
    test('toMap and fromMap produce equivalent objects', () {
      final provider = ServiceProvider(
        id: 's1',
        name: 'Bob',
        serviceType: ServiceType.barber,
      );
      final map = provider.toMap();
      final from = ServiceProvider.fromMap(map);

      expect(from.id, provider.id);
      expect(from.name, provider.name);
      expect(from.serviceType, provider.serviceType);
    });

    test('fromMap validates required data', () {
      final missing = {'id': 's1'};
      expect(() => ServiceProvider.fromMap(missing), throwsA(isA<TypeError>()));
    });
  });

  group('ServiceProvider equality', () {
    test('providers with same values are equal', () {
      final p1 = ServiceProvider(
        id: 's1',
        name: 'Bob',
        serviceType: ServiceType.barber,
      );
      final p2 = ServiceProvider(
        id: 's1',
        name: 'Bob',
        serviceType: ServiceType.barber,
      );

      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
    });

    test('providers with different values are not equal', () {
      final p1 = ServiceProvider(
        id: 's1',
        name: 'Bob',
        serviceType: ServiceType.barber,
      );
      final p2 = ServiceProvider(
        id: 's2',
        name: 'Bob',
        serviceType: ServiceType.barber,
      );

      expect(p1, isNot(equals(p2)));
    });
  });
}

