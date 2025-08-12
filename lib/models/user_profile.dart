import 'package:collection/collection.dart';

import 'user_role.dart';

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

  UserProfile({
    required this.id,
    required this.name,
    this.photoUrl,
    Set<UserRole>? roles,
  }) : roles = roles ?? <UserRole>{};

  /// Returns a copy of this profile with the given fields replaced.
  UserProfile copyWith({
    String? id,
    String? name,
    String? photoUrl,
    Set<UserRole>? roles,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      roles: roles ?? this.roles,
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
    );
  }

  /// Converts this profile to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'roles': roles.map((e) => e.name).toList(),
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
          const SetEquality<UserRole>().equals(roles, other.roles);

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ photoUrl.hashCode ^ roles.hashCode;
}

