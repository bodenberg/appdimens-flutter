/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Fluid strategy — clamped lerp between `base×0.8` and `base×1.2` over `[320, 768]` dp.
///
/// EN: Formula: plateau at `b×0.8` below 320 dp, plateau at `b×1.2` above 768 dp, linear lerp between.
///
/// PT: Fórmula: plateau at `b×0.8` below 320 dp, plateau at `b×1.2` above 768 dp, linear lerp between.
library;

import 'package:appdimens_flutter/appdimens.dart';

import 'factors.dart';

/// Fluid strategy kernels (family port parity).
abstract final class DimenFluid {
  /// Core fluid kernel used by every extension in this package.
  static double dp(
    double base,
    DimenMetrics metrics,
    DpQualifier effectiveQualifier,
    bool applyAspectRatio,
    double? customSensitivityK,
  ) {
    final d = StrategyResolution.axisDp(metrics, effectiveQualifier);
    final minV = base * FluidRange.minScale;
    final maxV = base * FluidRange.maxScale;
    if (d <= FluidRange.minWidth) {
      return StrategyResolution.applyAr(
          minV, metrics, applyAspectRatio, customSensitivityK);
    }
    if (d >= FluidRange.maxWidth) {
      return StrategyResolution.applyAr(
          maxV, metrics, applyAspectRatio, customSensitivityK);
    }
    final t =
        (d - FluidRange.minWidth) / (FluidRange.maxWidth - FluidRange.minWidth);
    final lerped = minV + (maxV - minV) * t;
    return StrategyResolution.applyAr(
        lerped, metrics, applyAspectRatio, customSensitivityK);
  }

  /// Starts the conditional [StrategyChain] for this strategy.
  static StrategyChain scaled(num value) => StrategyChain(
        base: value.toDouble(),
        formula: dp,
        calcType: CalcType.fluid,
      );
}
