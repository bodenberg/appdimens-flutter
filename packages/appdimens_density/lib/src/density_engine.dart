/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Density strategy — physical-density alignment against the 160 dpi reference.
///
/// EN: Formula: `base × (dpi / 160)` (qualifier-independent).
///
/// PT: Fórmula: `base × (dpi / 160)` (qualifier-independent).
import 'package:appdimens/appdimens.dart';

/// Density strategy kernels (family port parity).
abstract final class DimenDensity {
  /// Core density kernel used by every extension in this package.
  static double dp(
    double base,
    DimenMetrics metrics,
    DpQualifier effectiveQualifier,
    bool applyAspectRatio,
    double? customSensitivityK,
  ) {
    return StrategyResolution.applyAr(base * metrics.density, metrics,
        applyAspectRatio, customSensitivityK);
  }

  /// Starts the conditional [StrategyChain] for this strategy.
  static StrategyChain scaled(num value) => StrategyChain(
        base: value.toDouble(),
        formula: dp,
        calcType: CalcType.density,
      );
}
