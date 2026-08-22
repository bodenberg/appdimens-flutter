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

  testWidgets('live window resize recomputes .wdp values (KMP parity)',
      (tester) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);

    await tester.pumpWidget(
      AppDimensApp(
        child: MaterialApp(
          home: Scaffold(
            body: AppDimensReactiveBuilder(
              builder: (context) =>
                  Text('w=${100.wdp.toStringAsFixed(2)}'),
            ),
          ),
        ),
      ),
    );
    expect(AppDimensScope.metrics!.screenWidthDp, 390);

    // Live resize WITHOUT re-pumping a new widget tree — mirrors a user
    // dragging the window edge on desktop/web or entering split-screen.
    tester.view.physicalSize = const Size(600, 844);
    await tester.pump();
    await tester.pump();

    expect(AppDimensScope.metrics!.screenWidthDp, 600);
    final text = tester.widget<Text>(find.byType(Text)).data!;
    expect(
      text,
      'w=${(100 * 600 * DimenCache.invBaseRatio).toStringAsFixed(2)}',
    );
  });

  testWidgets('ignore-multi-window variants (i suffix) stay unscaled while '
      'multi-window is active, scaled twins keep adjusting', (tester) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);

    double? sdpValue;
    double? sdpiValue;
    await tester.pumpWidget(
      AppDimensApp(
        config: const AppDimensConfig(forcedMultiWindow: true),
        child: MaterialApp(
          home: Builder(builder: (context) {
            sdpValue = 16.sdp;
            sdpiValue = 16.sdpi;
            return const SizedBox.shrink();
          }),
        ),
      ),
    );

    // Multi-window active: plain `.sdp` keeps scaling with the live window,
    // `.sdpi` returns the raw base (no adjustment).
    expect(AppDimensScope.metrics!.isInMultiWindowMode, isTrue);
    expect(sdpiValue, 16.0);
    expect(sdpValue, closeTo(16 * AppDimensScope.metrics!.scale, 1e-9));

    // Without multi-window both scale identically.
    double? plainSdp;
    double? plainSdpi;
    await tester.pumpWidget(
      AppDimensApp(
        child: MaterialApp(
          home: Builder(builder: (context) {
            plainSdp = 16.sdp;
            plainSdpi = 16.sdpi;
            return const SizedBox.shrink();
          }),
        ),
      ),
    );
    expect(AppDimensScope.metrics!.isInMultiWindowMode, isFalse);
    expect(plainSdp, closeTo(plainSdpi!, 1e-9));
  });
}
