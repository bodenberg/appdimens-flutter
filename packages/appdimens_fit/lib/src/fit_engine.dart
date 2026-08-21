/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Fit strategy — CSS `contain`: the smaller axis ratio wins.
///
/// EN: Formula: `base × min(minSide/300, maxSide/533)` (always fits).
///
/// PT: Fórmula: `base × min(minSide/300, maxSide/533)` (always fits).
import 'dart:math' as math;

import 'package:appdimens/appdimens.dart';

/// Fit strategy kernels (family port parity).
abstract final class DimenFit {
  /// Core fit kernel used by every extension in this package.
  static double dp(
    double base,
    DimenMetrics metrics,
    DpQualifier effectiveQualifier,
    bool applyAspectRatio,
    double? customSensitivityK,
  ) {
    final rMin = metrics.minDimensionDp / DesignScaleConstants.baseWidthDp;
    final rMax = metrics.maxDimensionDp / DesignScaleConstants.baseHeightDp;
    return StrategyResolution.applyAr(
        base * math.min(rMin, rMax), metrics, applyAspectRatio, customSensitivityK);
  }

  /// Starts the conditional [StrategyChain] for this strategy.
  static StrategyChain scaled(num value) => StrategyChain(
        base: value.toDouble(),
        formula: dp,
        calcType: CalcType.fit,
      );
}
