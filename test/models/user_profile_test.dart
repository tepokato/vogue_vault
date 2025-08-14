import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:vogue_vault/models/user_profile.dart';
import 'package:vogue_vault/models/user_role.dart';
import 'package:vogue_vault/models/service_type.dart';
import 'package:vogue_vault/models/service_offering.dart';

void main() {
  group('UserProfile serialization', () {
    test('toMap and fromMap produce equivalent objects', () {
      final uuid = const Uuid();
      final profile = UserProfile(
        id: uuid.v4(),
        firstName: 'Alice',
        lastName: 'Smith',
        nickname: 'Ally',
        photoBytes: Uint8List.fromList([1, 2, 3]),
        roles: {UserRole.customer, UserRole.professional},
        offerings: [
          ServiceOffering(type: ServiceType.barber, name: 'Cut', price: 10),
          ServiceOffering(type: ServiceType.nails, name: 'Nail', price: 15),
          ServiceOffering(type: ServiceType.tattoo, name: 'Ink', price: 25),
        ],
      );

      final map = profile.toMap();
      final from = UserProfile.fromMap(map);

      expect(from, equals(profile));
      expect(from.fullName, 'Ally');
    });

    test('handles null photoBytes and empty sets', () {
      final profile = UserProfile(
        id: const Uuid().v4(),
        firstName: 'Bob',
        lastName: 'Builder',
      );

      final map = profile.toMap();
      final from = UserProfile.fromMap(map);

      expect(from.photoBytes, isNull);
      expect(from.nickname, isNull);
      expect(from.roles, isEmpty);
      expect(from.offerings, isEmpty);
      expect(from.fullName, 'Bob Builder');
      expect(from, equals(profile));
    });
  });

  group('UserProfile equality', () {
    test('profiles with the same values are equal and hashCodes match', () {
      final uuid = const Uuid();
      final id = uuid.v4();
      final p1 = UserProfile(
        id: id,
        firstName: 'Alice',
        lastName: 'Smith',
        nickname: 'Ally',
        roles: {UserRole.customer, UserRole.professional},
        offerings: [
          ServiceOffering(type: ServiceType.barber, name: 'Cut', price: 10),
          ServiceOffering(type: ServiceType.tattoo, name: 'Ink', price: 50),
        ],
      );
      final p2 = UserProfile(
        id: id,
        firstName: 'Alice',
        lastName: 'Smith',
        nickname: 'Ally',
        roles: {UserRole.professional, UserRole.customer},
        offerings: [
          ServiceOffering(type: ServiceType.barber, name: 'Cut', price: 10),
          ServiceOffering(type: ServiceType.tattoo, name: 'Ink', price: 50),
        ],
      );

      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
    });

    test('profiles with different data are not equal', () {
      final id = const Uuid().v4();
      final p1 = UserProfile(
        id: id,
        firstName: 'Alice',
        lastName: 'Smith',
      );
      final p2 = UserProfile(
        id: id,
        firstName: 'Alice',
        lastName: 'Smith',
        nickname: 'Ally',
      );

      expect(p1, isNot(equals(p2)));
    });
  });

  group('UserProfile service type parsing', () {
    test('skips invalid service types in legacy services list', () {
      final uuid = const Uuid();
      final map = {
        'id': uuid.v4(),
        'firstName': 'Alice',
        'lastName': 'Smith',
        'services': ['barber', 'unknown']
      };

      final profile = UserProfile.fromMap(map);

      expect(profile.offerings, hasLength(1));
      expect(profile.offerings.first.type, ServiceType.barber);
    });

    test('defaults invalid offering type to first enum value', () {
      final uuid = const Uuid();
      final map = {
        'id': uuid.v4(),
        'firstName': 'Alice',
        'lastName': 'Smith',
        'offerings': [
          {'type': 'mystery', 'name': 'Mystery', 'price': 0}
        ]
      };

      final profile = UserProfile.fromMap(map);

      expect(profile.offerings, hasLength(1));
      expect(profile.offerings.first.type, ServiceType.values.first);
    });
  });
}
