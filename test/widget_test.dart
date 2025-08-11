import 'package:flutter_test/flutter_test.dart';
import 'package:vogue_vault/main.dart';

void main() {
  testWidgets('Appointments page shows sample data', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Consultation with Alice - Sep 10 10:00 AM'), findsOneWidget);
  });
}
