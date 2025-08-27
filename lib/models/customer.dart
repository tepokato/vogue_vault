import 'package:flutter/foundation.dart';

import 'address.dart';

/// Represents a customer of the professional.
class Customer {
  /// Unique identifier for the customer.
  final String id;

  /// Customer first name.
  final String firstName;

  /// Customer last name.
  final String lastName;

  /// Optional contact information such as phone or email.
  final String? contactInfo;

  /// Addresses associated with the customer.
  final List<Address> addresses;

  const Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.contactInfo,
    this.addresses = const [],
  });

  /// Convenience full name getter.
  String get fullName => '$firstName $lastName';

  /// Creates a [Customer] from a JSON compatible [map].
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      contactInfo: map['contactInfo'] as String?,
      addresses: (map['addresses'] as List?)
              ?.map((e) =>
                  Address.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );
  }

  /// Converts this customer into a JSON compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'contactInfo': contactInfo,
      'addresses': addresses.map((a) => a.toMap()).toList(),
    };
  }

  Customer copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? contactInfo,
    List<Address>? addresses,
  }) {
    return Customer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      contactInfo: contactInfo ?? this.contactInfo,
      addresses: addresses ?? this.addresses,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          contactInfo == other.contactInfo &&
          listEquals(addresses, other.addresses);

  @override
  int get hashCode =>
      id.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      contactInfo.hashCode ^
      addresses.hashCode;
}

