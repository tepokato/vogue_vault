import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'user_role.dart';
import 'service_type.dart';

/// Represents a user within the application that may assume multiple roles.
class UserProfile {
  /// Unique identifier for the user.
  final String id;

  /// Display name of the user.
  final String name;

  /// Optional raw bytes of a profile image.
  final Uint8List? photoBytes;

  /// The set of roles this user can assume.
  final Set<UserRole> roles;

  /// The services offered by this user when acting as a professional.
  final Set<ServiceType> services;

  UserProfile({
    required this.id,
    required this.name,
    this.photoBytes,
    Set<UserRole>? roles,
    Set<ServiceType>? services,
  })  :
        roles = Set.unmodifiable(roles ?? <UserRole>{}),
        services = Set.unmodifiable(services ?? <ServiceType>{});

  /// Returns a copy of this profile with the given fields replaced.
  UserProfile copyWith({
    String? id,
    String? name,
    Uint8List? photoBytes,
    Set<UserRole>? roles,
    Set<ServiceType>? services,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      photoBytes: photoBytes ?? this.photoBytes,
      roles: roles != null ? Set.unmodifiable(roles) : this.roles,
      services: services != null ? Set.unmodifiable(services) : this.services,
    );
  }

  /// Creates a [UserProfile] from a JSON-compatible [map].
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
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
      'name': name,
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
          name == other.name &&
          const ListEquality<int>().equals(photoBytes, other.photoBytes) &&
          const SetEquality<UserRole>().equals(roles, other.roles) &&
          const SetEquality<ServiceType>().equals(services, other.services);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      const ListEquality<int>().hash(photoBytes) ^
      roles.hashCode ^
      services.hashCode;
}

