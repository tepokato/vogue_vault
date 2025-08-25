import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  test('formats date and time in localized style', () {
    const locale = 'en_US';
    final dt = DateTime(2023, 9, 10, 10, 0);
    final formatted = DateFormat.yMMMd(locale).add_jm().format(dt);
    expect(formatted, 'Sep 10, 2023 10:00 AM');
  });
}

