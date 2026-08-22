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
library;

import 'package:appdimens_flutter/appdimens.dart';

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
    return StrategyResolution.applyAr(base * metrics.fitScale, metrics,
        applyAspectRatio, customSensitivityK);
  }

  /// Starts the conditional [StrategyChain] for this strategy.
  static StrategyChain scaled(num value) => StrategyChain(
        base: value.toDouble(),
        formula: dp,
        calcType: CalcType.fit,
      );
}
