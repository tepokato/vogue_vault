import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vogue_vault/models/user_profile.dart';
import 'package:vogue_vault/models/user_role.dart';
import 'package:vogue_vault/models/service_type.dart';
import 'package:vogue_vault/models/service_offering.dart';

void main() {
  group('UserProfile serialization', () {
    test('toMap and fromMap produce equivalent objects', () {
      final profile = UserProfile(
        id: 'u1',
        firstName: 'Alice',
        lastName: 'Smith',
        nickname: 'Ally',
        photoBytes: Uint8List.fromList([1, 2, 3]),
        roles: {UserRole.customer, UserRole.professional},
        offerings: [
          ServiceOffering(type: ServiceType.barber, name: 'Cut', price: 10),
          ServiceOffering(type: ServiceType.nails, name: 'Nail', price: 15),
        ],
      );

      final map = profile.toMap();
      final from = UserProfile.fromMap(map);

      expect(from, equals(profile));
      expect(from.fullName, 'Ally');
    });

    test('handles null photoBytes and empty sets', () {
      final profile = UserProfile(
        id: 'u2',
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
      final p1 = UserProfile(
        id: 'u1',
        firstName: 'Alice',
        lastName: 'Smith',
        nickname: 'Ally',
        roles: {UserRole.customer, UserRole.professional},
        offerings: [
          ServiceOffering(type: ServiceType.barber, name: 'Cut', price: 10),
        ],
      );
      final p2 = UserProfile(
        id: 'u1',
        firstName: 'Alice',
        lastName: 'Smith',
        nickname: 'Ally',
        roles: {UserRole.professional, UserRole.customer},
        offerings: [
          ServiceOffering(type: ServiceType.barber, name: 'Cut', price: 10),
        ],
      );

      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
    });

    test('profiles with different data are not equal', () {
      final p1 = UserProfile(
        id: 'u1',
        firstName: 'Alice',
        lastName: 'Smith',
      );
      final p2 = UserProfile(
        id: 'u1',
        firstName: 'Alice',
        lastName: 'Smith',
        nickname: 'Ally',
      );

      expect(p1, isNot(equals(p2)));
    });
  });
}
