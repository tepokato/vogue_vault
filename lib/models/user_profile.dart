import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'user_role.dart';
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
  final Set<ServiceType> services;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.nickname,
    this.photoBytes,
    Set<UserRole>? roles,
    Set<ServiceType>? services,
  })  :
        roles = Set.unmodifiable(roles ?? <UserRole>{}),
        services = Set.unmodifiable(services ?? <ServiceType>{});

  /// The full display name for the user.
  String get fullName => nickname ?? '$firstName $lastName';

  /// Returns a copy of this profile with the given fields replaced.
  UserProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? nickname,
    Uint8List? photoBytes,
    Set<UserRole>? roles,
    Set<ServiceType>? services,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nickname: nickname ?? this.nickname,
      photoBytes: photoBytes ?? this.photoBytes,
      roles: roles != null ? Set.unmodifiable(roles) : this.roles,
      services: services != null ? Set.unmodifiable(services) : this.services,
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
      services: Set.unmodifiable(
          (map['services'] as List?)
                  ?.map((e) => ServiceType.values.byName(e as String))
                  .toSet() ??
              <ServiceType>{}),
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
      'services': services.map((e) => e.name).toList(),
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
          const SetEquality<ServiceType>().equals(services, other.services);

  @override
  int get hashCode =>
      id.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      nickname.hashCode ^
      const ListEquality<int>().hash(photoBytes) ^
      roles.hashCode ^
      services.hashCode;
}

