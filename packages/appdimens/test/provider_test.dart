import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appdimens/appdimens.dart';

void main() {
  setUp(() {
    AppDimensScope.clear();
    DimenCache.clear();
  });

  testWidgets('AppDimensApp publishes metrics into the scope', (tester) async {
    double? resolved;

    await tester.pumpWidget(
      AppDimensApp(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = 16.sdp;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(AppDimensScope.metrics, isNotNull);
    expect(resolved, greaterThan(0));
    expect(resolved, closeTo(16 * AppDimensScope.metrics!.scale, 1e-9));

    // Facade warm-up publishes an explicit context.
    DimenSdp.warmupCache(const FakeAppDimensContext());
    expect(AppDimensScope.metricsOrDefault.smallestWidthDp, 300.0);
  });

  testWidgets('AppDimensScopeBinder republishes on MediaQuery change',
      (tester) async {
    addTearDown(tester.view.reset);
    Widget host(Size size) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      return MaterialApp(
        builder: (context, child) =>
            AppDimensScopeBinder(child: child ?? const SizedBox.shrink()),
        home: Builder(
          builder: (context) => Scaffold(
            body: Text('w=${100.wdp.toStringAsFixed(2)}'),
          ),
        ),
      );
    }

    await tester.pumpWidget(host(const Size(390, 844)));
    await tester.pump();
    expect(AppDimensScope.metrics!.screenWidthDp, 390);

    await tester.pumpWidget(host(const Size(600, 844)));
    await tester.pump();
    expect(AppDimensScope.metrics!.screenWidthDp, 600);

    final text = tester.widget<Text>(find.byType(Text)).data!;
    expect(
        text, 'w=${(100 * 600 * DimenCache.invBaseRatio).toStringAsFixed(2)}');
  });

  testWidgets('snapshotOf resolves ui-mode fallback', (tester) async {
    await tester.pumpWidget(
      AppDimensProvider(
        config: const AppDimensConfig(forcedUiModeType: UiModeType.television),
        child: Builder(builder: (context) {
          final snap = AppDimensProvider.snapshotOf(context);
          expect(snap.uiModeType, UiModeType.television);
          return const SizedBox.shrink();
        }),
      ),
    );
  });
}
