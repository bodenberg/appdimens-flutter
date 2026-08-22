/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Diagonal strategy — screen-diagonal ratio against the design baseline.
///
/// EN: Formula: `base × √(min² + max²) / 611.6305` (qualifier-independent).
///
/// PT: Fórmula: `base × √(min² + max²) / 611.6305` (qualifier-independent).
library;

import 'package:appdimens/appdimens.dart';

/// Diagonal strategy kernels (family port parity).
abstract final class DimenDiagonal {
  /// Core diagonal kernel used by every extension in this package.
  static double dp(
    double base,
    DimenMetrics metrics,
    DpQualifier effectiveQualifier,
    bool applyAspectRatio,
    double? customSensitivityK,
  ) {
    if (!applyAspectRatio && customSensitivityK == null) {
      return base * metrics.diagonalScale;
    }
    return StrategyResolution.applyAr(base * metrics.diagonalScale, metrics,
        applyAspectRatio, customSensitivityK);
  }

  /// Starts the conditional [StrategyChain] for this strategy.
  static StrategyChain scaled(num value) => StrategyChain(
        base: value.toDouble(),
        formula: dp,
        calcType: CalcType.diagonal,
      );
}
