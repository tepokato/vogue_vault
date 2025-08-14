import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'user_role.dart';
import 'service_offering.dart';
import 'service_type.dart';

/// Represents a user within the application that may assume multiple roles.
class UserProfile {
  /// Unique identifier for the user.
  final String id;

  /// The user's given name.
  final String firstName;

  /// The user's family name.
  final String lastName;

  /// Optional nickname for the user.
  final String? nickname;

  /// Optional raw bytes of a profile image.
  final Uint8List? photoBytes;

  /// The set of roles this user can assume.
  final Set<UserRole> roles;

  /// The services offered by this user when acting as a professional.
  final List<ServiceOffering> offerings;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.nickname,
    this.photoBytes,
    Set<UserRole>? roles,
    List<ServiceOffering>? offerings,
  })  :
        roles = Set.unmodifiable(roles ?? <UserRole>{}),
        offerings = List.unmodifiable(offerings ?? <ServiceOffering>[]);

  /// The full display name for the user.
  String get fullName => nickname ?? '$firstName $lastName';

  /// Convenience getter matching older API expecting a single name field.
  String get name => fullName;

  /// Returns a copy of this profile with the given fields replaced.
  UserProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? nickname,
    Uint8List? photoBytes,
    Set<UserRole>? roles,
    List<ServiceOffering>? offerings,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nickname: nickname ?? this.nickname,
      photoBytes: photoBytes ?? this.photoBytes,
      roles: roles != null ? Set.unmodifiable(roles) : this.roles,
      offerings:
          offerings != null ? List.unmodifiable(offerings) : this.offerings,
    );
  }

  /// Creates a [UserProfile] from a JSON-compatible [map].
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      nickname: map['nickname'] as String?,
      photoBytes: map['photoBytes'] != null
          ? base64Decode(map['photoBytes'] as String)
          : null,
      roles: Set.unmodifiable(
          (map['roles'] as List?)
                  ?.map((e) => UserRole.values.byName(e as String))
                  .toSet() ??
              <UserRole>{}),
      offerings: List.unmodifiable(
          (map['offerings'] as List?)
                  ?.map((e) => ServiceOffering.fromMap(
                      Map<String, dynamic>.from(e as Map)))
                  .toList() ??
              (map['services'] as List?)
                      ?.map((e) {
                        final type = ServiceType.values.byName(e as String);
                        return ServiceOffering(
                            type: type, name: type.name, price: 0);
                      })
                      .toList() ??
                  <ServiceOffering>[]),
    );
  }

  /// Converts this profile to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'nickname': nickname,
      'photoBytes': photoBytes != null ? base64Encode(photoBytes!) : null,
      'roles': roles.map((e) => e.name).toList(),
      'offerings': offerings.map((e) => e.toMap()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          nickname == other.nickname &&
          const ListEquality<int>().equals(photoBytes, other.photoBytes) &&
          const SetEquality<UserRole>().equals(roles, other.roles) &&
          const ListEquality<ServiceOffering>()
              .equals(offerings, other.offerings);

  @override
  int get hashCode =>
      id.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      nickname.hashCode ^
      const ListEquality<int>().hash(photoBytes) ^
      roles.hashCode ^
      const ListEquality<ServiceOffering>().hash(offerings);
}

