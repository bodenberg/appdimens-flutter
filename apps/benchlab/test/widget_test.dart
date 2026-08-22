import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appdimens_benchlab/main.dart';

void main() {
  testWidgets('BenchLab boots and renders its screen', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BenchLabApp());
    await tester.pumpAndSettle();

    expect(find.byType(BenchlabScreen), findsOneWidget);
  });
}
