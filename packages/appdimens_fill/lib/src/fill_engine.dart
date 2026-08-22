/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Fill strategy — CSS `cover`: the larger axis ratio wins.
///
/// EN: Formula: `base × max(minSide/300, maxSide/533)` (may crop overflow).
///
/// PT: Fórmula: `base × max(minSide/300, maxSide/533)` (may crop overflow).
library;

import 'package:appdimens/appdimens.dart';

/// Fill strategy kernels (family port parity).
abstract final class DimenFill {
  /// Core fill kernel used by every extension in this package.
  static double dp(
    double base,
    DimenMetrics metrics,
    DpQualifier effectiveQualifier,
    bool applyAspectRatio,
    double? customSensitivityK,
  ) {
    return StrategyResolution.applyAr(base * metrics.fillScale, metrics,
        applyAspectRatio, customSensitivityK);
  }

  /// Starts the conditional [StrategyChain] for this strategy.
  static StrategyChain scaled(num value) => StrategyChain(
        base: value.toDouble(),
        formula: dp,
        calcType: CalcType.fill,
      );
}
