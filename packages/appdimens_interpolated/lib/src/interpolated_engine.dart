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

import 'package:appdimens/appdimens.dart';

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
    final d = StrategyResolution.axisDp(metrics, effectiveQualifier);
    final linear = base * (d * DimenCache.invBaseRatio);
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
