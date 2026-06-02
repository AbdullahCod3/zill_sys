import 'package:flutter_test/flutter_test.dart';
import 'package:zill_sys/main.dart';

void main() {
  testWidgets('App boots to the Home role chooser', (tester) async {
    await tester.pumpWidget(const ZillApp());
    await tester.pump();

    // Both role cards render on Home.
    expect(find.text("I'm the Employee"), findsOneWidget);
    expect(find.text("I'm the Customer"), findsOneWidget);
  });
}
