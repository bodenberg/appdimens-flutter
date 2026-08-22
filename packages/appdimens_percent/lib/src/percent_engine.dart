/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Percent strategy engine — `base × axis/300` plus the literal percentage
/// family (`spaceW`, `spaceH`, …).
library;

import 'package:appdimens_flutter/appdimens.dart';

/// EN: Percent strategy kernels. The dp/sp curves follow the same linear law
/// as Scaled (`b × d/300`, qualifier-driven) while the **space** family
/// resolves *literal* percentages of an axis without any scaling curve.
///
/// PT: Kernels da estratégia Percent. As curvas dp/sp seguem a mesma lei
/// linear do Scaled (`b × d/300`, dirigida pelo qualificador), enquanto a
/// família **space** resolve percentuais *literais* de um eixo sem curva de
/// escala.
abstract final class DimenPercent {
  /// Linear percent kernel used by the `psdp/phdp/pwdp` families.
  static double dp(
    double base,
    DimenMetrics metrics,
    DpQualifier effectiveQualifier,
    bool applyAspectRatio,
    double? customSensitivityK,
  ) =>
      StrategyResolution.applyAr(
        base * switch (effectiveQualifier) {
          DpQualifier.smallWidth => metrics.smallestWidthDp *
              DimenCache.invBaseRatio,
          DpQualifier.width => metrics.screenWidthFactor,
          DpQualifier.height => metrics.screenHeightFactor,
        },
        metrics,
        applyAspectRatio,
        customSensitivityK,
      );

  /// Starts the conditional [StrategyChain] for this strategy.
  static StrategyChain scaled(num value) => StrategyChain(
        base: value.toDouble(),
        formula: dp,
        calcType: CalcType.percent,
      );

  // ── Literal space family ───────────────────────────────────────────────

  /// `(percent / 100) × smallest width`.
  static double spaceSw(double percent) =>
      _literal(percent, AppDimensScope.metricsOrDefault.smallestWidthDp);

  /// `(percent / 100) × current width`.
  static double spaceW(double percent) => _literal(
      percent, AppDimensScope.metricsOrDefault.screenWidthDp.toDouble());

  /// `(percent / 100) × current height`.
  static double spaceH(double percent) => _literal(
      percent, AppDimensScope.metricsOrDefault.screenHeightDp.toDouble());

  /// `(percent / 100) × referenceDp` (custom reference).
  static double space(double percent, double referenceDp) =>
      _literal(percent, referenceDp);

  static double _literal(double percent, double dimension) {
    if (!percent.isFinite) return 0;
    return (percent / 100.0) * dimension;
  }
}

/// EN: Literal percentage math shared by the space family (mirrors
/// `PercentSpaceMath`).
///
/// PT: Matemática de percentual literal compartilhada pela família space
/// (espelha `PercentSpaceMath`).
abstract final class PercentSpaceMath {
  /// `(percent/100) × axis` honoring the multi-window suppression flag.
  static double literalPercentOfScreen(
      double percent, DpQualifier qualifier, bool ignoreMultiWindows) {
    if (!percent.isFinite) return 0;
    final m = AppDimensScope.metricsOrDefault;
    if (ignoreMultiWindows && m.isInMultiWindowMode) return percent;
    final dim = switch (qualifier) {
      DpQualifier.smallWidth => m.smallestWidthDp,
      DpQualifier.width => m.screenWidthDp.toDouble(),
      DpQualifier.height => m.screenHeightDp.toDouble(),
    };
    return (percent / 100.0) * dim;
  }

  /// `(percent/100) × referenceDp`.
  static double literalPercentOfReference(double percent, double referenceDp) {
    if (!percent.isFinite) return 0;
    return (percent / 100.0) * referenceDp;
  }
}
