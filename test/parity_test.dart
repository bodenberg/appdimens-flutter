import 'dart:math' as math;
import 'package:appdimens/appdimens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const baseline = DimensConfiguration(screenWidth: 300, screenHeight: 533);
  const phone = DimensConfiguration(
    screenWidth: 390,
    screenHeight: 844,
    displayScale: 3,
    fontScale: 1.25,
    uiMode: UiModeType.normal,
  );
  test('principal baseline and Android-style numeric API', () {
    expect(16.sdp(baseline), 16);
    expect(16.hdp(baseline), closeTo(16 * 533 / 300, 1e-12));
    expect(16.wdp(baseline), 16);
    expect(16.ssp(phone), 26);
    expect(16.sem(phone), 20.8);
  });
  test('principal formulas match reference vectors', () {
    expect(16.sdp(phone), 20.8);
    expect(16.powerDp(phone), closeTo(16 * math.pow(1.3, .75), 1e-12));
    expect(16.interpolatedDp(phone), 18.4);
    expect(
      16.logarithmicDp(phone),
      closeTo(16 * (1 + .4 * math.log(1.3)), 1e-12),
    );
    expect(10.percentDp(phone, percent: 100), 39);
  });
  test('all strategy equations preserve baseline where defined', () {
    for (final strategy in [
      DimensStrategy.scaled,
      DimensStrategy.auto,
      DimensStrategy.density,
      DimensStrategy.diagonal,
      DimensStrategy.fill,
      DimensStrategy.fit,
      DimensStrategy.interpolated,
      DimensStrategy.logarithmic,
      DimensStrategy.perimeter,
      DimensStrategy.power,
      DimensStrategy.physical,
      DimensStrategy.plain,
    ]) {
      final result = DynamicDimens.resolve(
        16,
        strategy: strategy,
        configuration: baseline,
      );
      expect(result, closeTo(16, 1e-9), reason: strategy.name);
    }
  });
  test('qualifiers and all eight inverters match principal contract', () {
    const landscape = DimensConfiguration(screenWidth: 800, screenHeight: 400);
    expect(
      landscape.dimension(DpQualifier.height, inverter: Inverter.phToLw),
      800,
    );
    expect(
      landscape.dimension(DpQualifier.width, inverter: Inverter.pwToLh),
      400,
    );
    expect(
      landscape.dimension(DpQualifier.smallWidth, inverter: Inverter.swToLh),
      400,
    );
    expect(
      landscape.dimension(DpQualifier.smallWidth, inverter: Inverter.swToLw),
      800,
    );
    const portrait = DimensConfiguration(screenWidth: 400, screenHeight: 800);
    expect(
      portrait.dimension(DpQualifier.height, inverter: Inverter.lhToPw),
      400,
    );
    expect(
      portrait.dimension(DpQualifier.width, inverter: Inverter.lwToPh),
      800,
    );
    expect(
      portrait.dimension(DpQualifier.smallWidth, inverter: Inverter.swToPh),
      800,
    );
    expect(
      portrait.dimension(DpQualifier.smallWidth, inverter: Inverter.swToPw),
      400,
    );
  });
  test('ScaledDp is immutable and resolves branches in declaration order', () {
    final base = 16.scaledDp;
    final configured = base
        .screen(20, qualifier: DpQualifier.smallWidth, minimum: 360)
        .mode(24, UiModeType.normal);
    expect(base.resolve(phone), 20.8);
    expect(configured.resolve(phone), 31.2);
  });
  test('AutoDp resolves specificity then threshold then declaration order', () {
    final auto = 16.autoScaledDp
        .qualifier(20, DpQualifier.smallWidth, minimum: 360)
        .screen(
          30,
          condition: const AutoCondition(
            mode: UiModeType.normal,
            qualifier: DpQualifier.smallWidth,
            minimum: 360,
          ),
        );
    expect(auto.resolve(phone), 39);
  });
  test('multi-window ignore returns design token', () {
    const split = DimensConfiguration(
      screenWidth: 400,
      screenHeight: 600,
      maximumWindowWidth: 1200,
      maximumWindowHeight: 900,
    );
    expect(
      AppDimens.dp(16, configuration: split, ignoreMultiWindows: true),
      16,
    );
  });
  test('factors fast path equals dynamic resolver', () {
    final factors = DimensFactors(phone);
    for (final strategy in [
      DimensStrategy.scaled,
      DimensStrategy.density,
      DimensStrategy.diagonal,
      DimensStrategy.perimeter,
      DimensStrategy.fit,
      DimensStrategy.fill,
      DimensStrategy.plain,
    ]) {
      expect(
        factors.resolve(16, strategy),
        DynamicDimens.resolve(16, strategy: strategy, configuration: phone),
      );
    }
  });
  test('resize and physical units match reference', () {
    expect(DimensResize.steps(minimum: 10, maximum: 20, step: 4), [
      10,
      14,
      18,
      20,
    ]);
    expect(DimensResize.largestFitting([10, 14, 18, 20], (v) => v <= 17), 14);
    expect(
      DimensUnits.points(1, from: PhysicalUnit.inch, configuration: phone),
      72,
    );
    expect(
      DimensUnits.pixels(
        1,
        from: PhysicalUnit.inch,
        configuration: phone,
        pixelsPerInch: 460,
      ),
      460,
    );
  });
}
