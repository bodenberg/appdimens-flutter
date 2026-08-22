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

import 'dart:math' as math;

import 'package:appdimens/appdimens.dart';

import 'factors.dart';

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
    final d = StrategyResolution.axisDp(metrics, effectiveQualifier);
    double scale;
    if (d <= AutoTransition.pointDp) {
      scale = d * DimenCache.invBaseRatio;
    } else {
      scale = AutoTransition.pointDp * DimenCache.invBaseRatio +
          AutoTransition.slope *
              math.log(
                  1 + (d - AutoTransition.pointDp) * DimenCache.invBaseRatio);
    }
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
