import 'package:flutter_test/flutter_test.dart';
import 'package:agrilink_app/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AgriLinkApp());
    expect(find.text('AgriLink'), findsOneWidget);
  });
}
