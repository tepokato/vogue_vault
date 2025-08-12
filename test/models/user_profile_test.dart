import 'package:flutter_test/flutter_test.dart';
import 'package:vogue_vault/models/user_profile.dart';
import 'package:vogue_vault/models/user_role.dart';
import 'package:vogue_vault/models/service_type.dart';

void main() {
  group('UserProfile serialization', () {
    test('toMap and fromMap produce equivalent objects', () {
      final profile = UserProfile(
        id: 'u1',
        name: 'Alice',
        photoUrl: 'photo.png',
        roles: {UserRole.customer, UserRole.professional},
        services: {ServiceType.barber, ServiceType.nails},
      );

      final map = profile.toMap();
      final from = UserProfile.fromMap(map);

      expect(from, equals(profile));
    });

    test('handles null photoUrl and empty sets', () {
      final profile = UserProfile(
        id: 'u2',
        name: 'Bob',
      );

      final map = profile.toMap();
      final from = UserProfile.fromMap(map);

      expect(from.photoUrl, isNull);
      expect(from.roles, isEmpty);
      expect(from.services, isEmpty);
      expect(from, equals(profile));
    });
  });

  group('UserProfile equality', () {
    test('profiles with the same values are equal and hashCodes match', () {
      final p1 = UserProfile(
        id: 'u1',
        name: 'Alice',
        roles: {UserRole.customer, UserRole.professional},
        services: {ServiceType.barber},
      );
      final p2 = UserProfile(
        id: 'u1',
        name: 'Alice',
        roles: {UserRole.professional, UserRole.customer},
        services: {ServiceType.barber},
      );

      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
    });

    test('profiles with different data are not equal', () {
      final p1 = UserProfile(
        id: 'u1',
        name: 'Alice',
      );
      final p2 = UserProfile(
        id: 'u2',
        name: 'Alice',
      );

      expect(p1, isNot(equals(p2)));
    });
  });
}
