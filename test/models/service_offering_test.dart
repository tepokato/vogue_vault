import 'package:flutter_test/flutter_test.dart';
import 'package:vogue_vault/models/service_offering.dart';
import 'package:vogue_vault/models/service_type.dart';

void main() {
  test('defaults to first ServiceType for unknown value', () {
    final offering = ServiceOffering.fromMap({
      'type': 'unknown',
      'name': 'Mystery',
      'price': 5,
    });

    expect(offering.type, ServiceType.values.first);
    expect(offering.name, 'Mystery');
    expect(offering.price, 5);
  });
}

