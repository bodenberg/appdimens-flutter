import 'package:appdimens_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the Dynamic strategy gallery', (tester) async {
    await tester.pumpWidget(const AppDimensExample());
    expect(find.text('AppDimens Dynamic Flutter 3.1.6'), findsOneWidget);
    expect(find.text('scaled'), findsOneWidget);
  });
}
