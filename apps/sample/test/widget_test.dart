import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appdimens_sample/main.dart';

void main() {
  testWidgets('Sample app boots and renders the demo screen', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SampleApp());
    await tester.pumpAndSettle();

    expect(find.text('AppDimens SDP Demo'), findsOneWidget);
    expect(find.text('Responsive dimensions on every screen'), findsOneWidget);

    // Live resize updates the routed demo values without swapping the tree.
    tester.view.physicalSize = const Size(600, 844);
    await tester.pump();
    await tester.pump();

    expect(find.byType(DemoScreen), findsOneWidget);
  });
}
