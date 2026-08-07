import 'package:appdimens_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the real strategy gallery', (tester) async {
    await tester.pumpWidget(const AppDimensExample());
    expect(find.text('AppDimens — 13 strategies'), findsOneWidget);
    expect(find.text('balanced'), findsOneWidget);
  });
}
