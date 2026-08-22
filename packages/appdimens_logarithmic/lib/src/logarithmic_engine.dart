/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Logarithmic strategy — symmetric ±0.4·ln damping around the 300 dp baseline.
///
/// EN: Formula: `d > 300 : 1 + 0.4·ln(d/300)` · `d ≤ 300 : 1 − 0.4·ln(300/d)`.
///
/// PT: Fórmula: `d > 300 : 1 + 0.4·ln(d/300)` · `d ≤ 300 : 1 − 0.4·ln(300/d)`.
library;

import 'package:appdimens/appdimens.dart';


/// Logarithmic strategy kernels (family port parity).
abstract final class DimenLogarithmic {
  /// Core logarithmic kernel used by every extension in this package.
  static double dp(
    double base,
    DimenMetrics metrics,
    DpQualifier effectiveQualifier,
    bool applyAspectRatio,
    double? customSensitivityK,
  ) {
    // Default sw path reuses the snapshot-memoized factor (KMP parity).
    if (effectiveQualifier == DpQualifier.smallWidth &&
        !applyAspectRatio &&
        customSensitivityK == null) {
      return base * metrics.logarithmicScale;
    }
    // Per-axis piecewise factors are hoisted onto the snapshot.
    final scale = switch (effectiveQualifier) {
      DpQualifier.width => metrics.logarithmicWidthFactor,
      DpQualifier.height => metrics.logarithmicHeightFactor,
      DpQualifier.smallWidth => metrics.logarithmicScale,
    };
    return StrategyResolution.applyAr(
        base * scale, metrics, applyAspectRatio, customSensitivityK);
  }

  /// Starts the conditional [StrategyChain] for this strategy.
  static StrategyChain scaled(num value) => StrategyChain(
        base: value.toDouble(),
        formula: dp,
        calcType: CalcType.logarithmic,
      );
}
