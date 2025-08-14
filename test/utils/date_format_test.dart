import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  test('formats date and time in localized style', () {
    Intl.defaultLocale = 'en_US';
    final dt = DateTime(2023, 9, 10, 10, 0);
    final formatted = DateFormat.yMMMd().add_jm().format(dt);
    expect(formatted, 'Sep 10, 2023 10:00 AM');
  });
}

