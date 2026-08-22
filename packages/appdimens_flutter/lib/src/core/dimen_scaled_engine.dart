/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Shared pure-math scaling kernels for the Scaled strategy (sdp/hdp/wdp/ssp).
library;

import '../common/dp_qualifier.dart';
import '../common/inverter.dart';
import 'design_scale_constants.dart';
import 'dimen_cache.dart';
import 'dimen_calculation_plumbing.dart';
import 'dimen_metrics.dart';
import 'screen_configuration.dart';

/// EN: Scaled engine. Mirrors the Kotlin `calculateScaledDp` exactly:
/// 1. Applies [Inverter] rules to swap the effective [DpQualifier].
/// 2. When [ignoreMultiWindows] is set and the window is constrained, returns
///    the base unchanged.
/// 3. Default `SMALL_WIDTH` + no custom sensitivity delegates to the snapshot
///    precomputed multipliers (single multiply).
/// 4. Other qualifiers / custom sensitivity compute inline.
///
/// PT: Motor escalado. Espelha o `calculateScaledDp` do Kotlin exatamente:
/// 1. Aplica as regras de [Inverter] para trocar o [DpQualifier] efetivo.
/// 2. Com [ignoreMultiWindows] e janela limitada, devolve a base inalterada.
/// 3. `SMALL_WIDTH` padrão + sem sensibilidade customizada usa os
///    multiplicadores pré-computados do snapshot (uma multiplicação).
/// 4. Outros qualificadores / sensibilidade customizada calculam inline.
abstract final class DimenScaledEngine {
  /// Pure-math scaled dp kernel over an explicit configuration.
  static double calculateScaledDp(
    double baseValue,
    ScreenConfiguration configuration,
    DpQualifier qualifier,
    Inverter inverter,
    bool ignoreMultiWindows,
    bool applyAspectRatio,
    double? customSensitivityK, {
    bool? knownInMultiWindow,
    DimenMetrics? metrics,
  }) {
    final actualQualifier = DimenCalculationPlumbing.effectiveQualifier(
      qualifier,
      inverter,
      configuration.isLandscape,
      configuration.isPortrait,
    );
    if (DimenCalculationPlumbing.isMultiWindowConstrained(
      configuration,
      ignoreMultiWindows,
      knownInMultiWindow:
          knownInMultiWindow ?? (metrics?.isInMultiWindowMode ?? false),
    )) {
      return baseValue;
    }
    final isDefaultSw =
        qualifier == DpQualifier.smallWidth && inverter == Inverter.standard;
    if (isDefaultSw && customSensitivityK == null) {
      final m = metrics ?? _matchingMetrics(configuration);
      if (m != null) {
        return baseValue * m.scaledMultiplier(applyAspectRatio, null);
      }
    }
    final screenDimension =
        DimenCalculationPlumbing.readScreenDp(configuration, actualQualifier);
    if (applyAspectRatio) {
      final diff = screenDimension - DesignScaleConstants.baseWidthDp;
      final k = customSensitivityK ?? DimenCache.sensitivityDefault;
      final logAr =
          DimenCalculationPlumbing.fastLn(_normalizedAr(configuration));
      return baseValue *
          (1.0 + diff * (DimenCache.adjustmentScale + k * logAr));
    }
    return baseValue * (screenDimension * DimenCache.invBaseRatio);
  }

  static DimenMetrics? _matchingMetrics(ScreenConfiguration configuration) {
    final m = AppDimensScope.metricsOrDefault;
    return m.configuration == configuration ? m : null;
  }

  static double _normalizedAr(ScreenConfiguration configuration) {
    final w = configuration.screenWidthDp.toDouble();
    final h = configuration.screenHeightDp.toDouble();
    final minD = w < h ? w : h;
    final maxD = w > h ? w : h;
    if (minD <= 0) return 1.0;
    var norm = maxD / minD / DesignScaleConstants.referenceAspectRatio;
    if (!norm.isFinite || norm <= 0) norm = 1.0;
    return norm;
  }

  /// Full-path scaled **dp** resolution against a window-like scope.
  static double resolveScaledDp(
    double base,
    AppDimensContextLike scope,
    DpQualifier qualifier, {
    Inverter inverter = Inverter.standard,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) {
    final configuration = scope.configuration;

    // Fast lane: dominant path — one coherent snapshot read + one multiply.
    if (DimenCache.isEnabled &&
        inverter == Inverter.standard &&
        !ignoreMultiWindows &&
        customSensitivityK == null &&
        (qualifier == DpQualifier.smallWidth || !applyAspectRatio)) {
      return base *
          scope.dimenMetrics.fastScaledMultiplier(qualifier, applyAspectRatio);
    }

    final key = CacheKey(
      baseValue: base,
      isLandscape: configuration.isLandscape,
      ignoreMultiWindows: ignoreMultiWindows,
      calcType: CalcType.scaled,
      qualifier: qualifier,
      inverter: inverter,
      applyAspectRatio: applyAspectRatio,
      valueType: ValueType.dp,
      customSensitivityK: customSensitivityK,
    );
    final metrics = scope.dimenMetrics;
    return DimenCache.getOrPutFor(metrics, key, () {
      return calculateScaledDp(
        base,
        configuration,
        qualifier,
        inverter,
        ignoreMultiWindows,
        applyAspectRatio,
        customSensitivityK,
        knownInMultiWindow: metrics.isInMultiWindowMode,
        metrics: metrics,
      );
    });
  }

  /// Full-path scaled **px** resolution against a window-like scope.
  static double resolveScaledPx(
    double base,
    AppDimensContextLike scope,
    DpQualifier qualifier, {
    Inverter inverter = Inverter.standard,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) {
    final dp = resolveScaledDp(base, scope, qualifier,
        inverter: inverter,
        ignoreMultiWindows: ignoreMultiWindows,
        applyAspectRatio: applyAspectRatio,
        customSensitivityK: customSensitivityK);
    return dp * scope.dimenMetrics.density;
  }

  /// Scaled sp value (logical sp): with `fontScale` the framework applies the
  /// system font scale at render; without it the value pre-divides by the
  /// scale so rendering cancels it back.
  static double resolveScaledSpValue(
    double base,
    AppDimensContextLike scope,
    DpQualifier qualifier, {
    bool fontScale = true,
    Inverter inverter = Inverter.standard,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) {
    final configuration = scope.configuration;
    final key = CacheKey(
      baseValue: base,
      isLandscape: configuration.isLandscape,
      ignoreMultiWindows: ignoreMultiWindows,
      calcType: CalcType.scaled,
      qualifier: qualifier,
      inverter: inverter,
      applyAspectRatio: applyAspectRatio,
      valueType: fontScale ? ValueType.spWithScale : ValueType.spNoScale,
      customSensitivityK: customSensitivityK,
    );
    final metrics = scope.dimenMetrics;
    return DimenCache.getOrPutFor(metrics, key, () {
      final scaledDp = calculateScaledDp(
        base,
        configuration,
        qualifier,
        inverter,
        ignoreMultiWindows,
        applyAspectRatio,
        customSensitivityK,
        knownInMultiWindow: metrics.isInMultiWindowMode,
        metrics: metrics,
      );
      if (fontScale) return scaledDp;
      final fs = metrics.fontScale;
      return fs > 0 ? scaledDp / fs : scaledDp;
    });
  }

  /// Rendered physical pixels of a scaled sp resolution.
  static double resolveScaledSpPx(
    double base,
    AppDimensContextLike scope,
    DpQualifier qualifier, {
    bool fontScale = true,
    Inverter inverter = Inverter.standard,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) {
    final value = resolveScaledSpValue(base, scope, qualifier,
        fontScale: fontScale,
        inverter: inverter,
        ignoreMultiWindows: ignoreMultiWindows,
        applyAspectRatio: applyAspectRatio,
        customSensitivityK: customSensitivityK);
    final fs = fontScale ? scope.dimenMetrics.fontScale : 1.0;
    return value * scope.dimenMetrics.density * (fs > 0 ? fs : 1.0);
  }
}
