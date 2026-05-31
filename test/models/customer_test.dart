import 'package:flutter_test/flutter_test.dart';

import 'package:vogue_vault/models/customer.dart';

void main() {
  test('toMap and fromMap round trip', () {
    const customer = Customer(
      id: '1',
      firstName: 'Jane',
      lastName: 'Doe',
      contactInfo: 'jane@example.com',
    );
    final map = customer.toMap();
    final fromMap = Customer.fromMap(map);
    expect(fromMap, customer);
  });
}
