/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Interpolated strategy — fixed 50% blend between raw and fully-scaled values.
///
/// EN: Formula: `out = b + (b·d/300 − b) × 0.5`.
///
/// PT: Fórmula: `out = b + (b·d/300 − b) × 0.5`.
library;

import 'package:appdimens_flutter/appdimens.dart';

import 'factors.dart';

/// Interpolated strategy kernels (family port parity).
abstract final class DimenInterpolated {
  /// Core interpolated kernel used by every extension in this package.
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
      return base * metrics.interpolatedScale;
    }
    // `axisDp × 1/300` equals the hoisted per-axis factor bit-for-bit.
    final axisNorm = switch (effectiveQualifier) {
      DpQualifier.smallWidth => metrics.smallestWidthDp *
          DimenCache.invBaseRatio,
      DpQualifier.width => metrics.screenWidthFactor,
      DpQualifier.height => metrics.screenHeightFactor,
    };
    final linear = base * axisNorm;
    return StrategyResolution.applyAr(
        base + (linear - base) * Interpolation.defaultBlend,
        metrics,
        applyAspectRatio,
        customSensitivityK);
  }

  /// Starts the conditional [StrategyChain] for this strategy.
  static StrategyChain scaled(num value) => StrategyChain(
        base: value.toDouble(),
        formula: dp,
        calcType: CalcType.interpolated,
      );
}
