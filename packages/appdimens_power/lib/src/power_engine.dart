/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Power strategy — sub-linear curve `(axis/300)^0.75`.
///
/// EN: Formula: `base × (d/300)^0.75` — perceptual sub-linear growth.
///
/// PT: Fórmula: `base × (d/300)^0.75` — perceptual sub-linear growth.
library;

import 'package:appdimens_flutter/appdimens.dart';


/// Power strategy kernels (family port parity).
abstract final class DimenPower {
  /// Core power kernel used by every extension in this package.
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
      return base * metrics.powerScale;
    }
    // Per-axis factors are hoisted onto the snapshot (bit-exact with the
    // former per-call `pow`).
    final p = switch (effectiveQualifier) {
      DpQualifier.width => metrics.powerWidthFactor,
      DpQualifier.height => metrics.powerHeightFactor,
      DpQualifier.smallWidth => metrics.powerScale,
    };
    return StrategyResolution.applyAr(
        base * p, metrics, applyAspectRatio, customSensitivityK);
  }

  /// Starts the conditional [StrategyChain] for this strategy.
  static StrategyChain scaled(num value) => StrategyChain(
        base: value.toDouble(),
        formula: dp,
        calcType: CalcType.power,
      );
}
