/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Auto strategy — linear on phones, log-damped beyond the 480 dp transition.
///
/// EN: Formula: `d ≤ 480 : d/300`; else `480/300 + 0.4·ln(1 + (d−480)/300)`.
///
/// PT: Fórmula: `d ≤ 480 : d/300`; else `480/300 + 0.4·ln(1 + (d−480)/300)`.
library;

import 'package:appdimens_flutter/appdimens.dart';


/// Auto strategy kernels (family port parity).
abstract final class DimenAuto {
  /// Core auto kernel used by every extension in this package.
  static double dp(
    double base,
    DimenMetrics metrics,
    DpQualifier effectiveQualifier,
    bool applyAspectRatio,
    double? customSensitivityK,
  ) {
    // Per-axis curve factors are hoisted onto the snapshot.
    final scale = switch (effectiveQualifier) {
      DpQualifier.width => metrics.autoWidthFactor,
      DpQualifier.height => metrics.autoHeightFactor,
      DpQualifier.smallWidth => metrics.autoScale,
    };
    return StrategyResolution.applyAr(
        base * scale, metrics, applyAspectRatio, customSensitivityK);
  }

  /// Starts the conditional [StrategyChain] for this strategy.
  static StrategyChain scaled(num value) => StrategyChain(
        base: value.toDouble(),
        formula: dp,
        calcType: CalcType.auto,
      );
}
