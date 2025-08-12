import 'package:collection/collection.dart';

import 'user_role.dart';
import 'service_type.dart';

/// Represents a user within the application that may assume multiple roles.
class UserProfile {
  /// Unique identifier for the user.
  final String id;

  /// Display name of the user.
  final String name;

  /// Optional path or URL to a profile image.
  final String? photoUrl;

  /// The set of roles this user can assume.
  final Set<UserRole> roles;

  /// The services offered by this user when acting as a professional.
  final Set<ServiceType> services;

  UserProfile({
    required this.id,
    required this.name,
    this.photoUrl,
    Set<UserRole>? roles,
    Set<ServiceType>? services,
  })  :
        roles = roles ?? <UserRole>{},
        services = services ?? <ServiceType>{};

  /// Returns a copy of this profile with the given fields replaced.
  UserProfile copyWith({
    String? id,
    String? name,
    String? photoUrl,
    Set<UserRole>? roles,
    Set<ServiceType>? services,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      roles: roles ?? this.roles,
      services: services ?? this.services,
    );
  }

  /// Creates a [UserProfile] from a JSON-compatible [map].
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      photoUrl: map['photoUrl'] as String?,
      roles: (map['roles'] as List?)
              ?.map((e) => UserRole.values.byName(e as String))
              .toSet() ??
          <UserRole>{},
      services: (map['services'] as List?)
              ?.map((e) => ServiceType.values.byName(e as String))
              .toSet() ??
          <ServiceType>{},
    );
  }

  /// Converts this profile to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
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
          photoUrl == other.photoUrl &&
          const SetEquality<UserRole>().equals(roles, other.roles) &&
          const SetEquality<ServiceType>().equals(services, other.services);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      photoUrl.hashCode ^
      roles.hashCode ^
      services.hashCode;
}

