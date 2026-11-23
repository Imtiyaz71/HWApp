import 'package:flutter_test/flutter_test.dart';
import 'package:ourhomeworks/main.dart';

void main() {
  testWidgets('App starts smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OurHomeworksApp());
    expect(find.byType(OurHomeworksApp), findsOneWidget);
  });
}
