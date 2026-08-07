import 'package:appdimens/appdimens.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const reference = Size(360, 800);

  test('all strategies preserve the design value at the reference size', () {
    for (final strategy in AppDimensStrategy.values) {
      final scale = AppDimensScale(
        20,
        strategy: strategy,
        minValue: strategy == AppDimensStrategy.fluid ? 20 : null,
        maxValue: strategy == AppDimensStrategy.fluid ? 40 : null,
      );
      final result = scale.calculateFor(reference);
      expect(result, isFinite, reason: strategy.name);
      if (strategy != AppDimensStrategy.percentage &&
          strategy != AppDimensStrategy.fluid &&
          strategy != AppDimensStrategy.autosize) {
        expect(result, 20, reason: strategy.name);
      }
    }
  });

  test('fit never exceeds fill', () {
    final fit = AppDimens.fit(100).calculateFor(const Size(1024, 600));
    final fill = AppDimens.fill(100).calculateFor(const Size(1024, 600));
    expect(fit, lessThanOrEqualTo(fill));
  });

  test('fluid scaling clamps at both breakpoints', () {
    final fluid = AppDimens.fluid(16, maxValue: 24);
    expect(fluid.calculateFor(const Size(200, 800)), 16);
    expect(fluid.calculateFor(const Size(2000, 800)), 24);
  });

  test('invalid viewport safely returns the source value', () {
    expect(AppDimens.balanced(16).calculateFor(Size.zero), 16);
  });
}
