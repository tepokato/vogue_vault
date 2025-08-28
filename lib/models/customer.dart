import 'package:flutter/foundation.dart';

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

  const Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.contactInfo,
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
    );
  }

  /// Converts this customer into a JSON compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'contactInfo': contactInfo,
    };
  }

  Customer copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? contactInfo,
  }) {
    return Customer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      contactInfo: contactInfo ?? this.contactInfo,
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
          contactInfo == other.contactInfo;

  @override
  int get hashCode =>
      id.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      contactInfo.hashCode;
}

