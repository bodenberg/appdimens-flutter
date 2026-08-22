/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Perimeter strategy — half-perimeter ratio against the design baseline.
///
/// EN: Formula: `base × (minSide + maxSide) / 833` (qualifier-independent).
///
/// PT: Fórmula: `base × (minSide + maxSide) / 833` (qualifier-independent).
library;

import 'package:appdimens/appdimens.dart';

/// Perimeter strategy kernels (family port parity).
abstract final class DimenPerimeter {
  /// Core perimeter kernel used by every extension in this package.
  static double dp(
    double base,
    DimenMetrics metrics,
    DpQualifier effectiveQualifier,
    bool applyAspectRatio,
    double? customSensitivityK,
  ) {
    if (!applyAspectRatio && customSensitivityK == null) {
      return base * metrics.perimeterScale;
    }
    return StrategyResolution.applyAr(base * metrics.perimeterScale, metrics,
        applyAspectRatio, customSensitivityK);
  }

  /// Starts the conditional [StrategyChain] for this strategy.
  static StrategyChain scaled(num value) => StrategyChain(
        base: value.toDouble(),
        formula: dp,
        calcType: CalcType.perimeter,
      );
}
