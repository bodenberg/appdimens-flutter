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
import 'dart:math' as math;

import 'package:appdimens/appdimens.dart';

import 'factors.dart';

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
    final d = StrategyResolution.axisDp(metrics, effectiveQualifier);
    double scale;
    if (d > DesignScaleConstants.baseWidthDp) {
      scale =
          1 + LogarithmicCurve.slope * math.log(d * DimenCache.invBaseRatio);
    } else if (d > 0) {
      scale = 1 -
          LogarithmicCurve.slope *
              math.log(DesignScaleConstants.baseWidthDp / d);
    } else {
      scale = 1;
    }
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
