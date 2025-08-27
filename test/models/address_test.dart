import 'package:flutter_test/flutter_test.dart';

import 'package:vogue_vault/models/address.dart';

void main() {
  test('toMap and fromMap work correctly', () {
    const address = Address(id: '1', label: 'Studio', details: '123 Main');
    final map = address.toMap();
    final fromMap = Address.fromMap(map);
    expect(fromMap, address);
  });
}

