import 'package:flutter_test/flutter_test.dart';

import 'package:vogue_vault/models/customer.dart';
import 'package:vogue_vault/models/address.dart';

void main() {
  test('toMap and fromMap include addresses', () {
    const address = Address(id: 'a', label: 'Home', details: '123 Main');
    const customer = Customer(
      id: '1',
      firstName: 'Jane',
      lastName: 'Doe',
      contactInfo: 'jane@example.com',
      addresses: [address],
    );
    final map = customer.toMap();
    final fromMap = Customer.fromMap(map);
    expect(fromMap, customer);
  });
}
