/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// The immutable resolution snapshot — the heart of the AppDimens fast lane.
library;

import 'dart:math' as math;

import '../common/dp_qualifier.dart';
import 'design_scale_constants.dart';
import 'dimen_cache.dart';
import 'screen_configuration.dart';

/// EN: A value snapshot, not a process-wide mutable "current screen". The
/// constructor contains only the inputs that affect a result; derived factors
/// are calculated once when the snapshot is created. Equality is therefore an
/// exact cache-partition key.
///
/// PT: Um snapshot de valores, não uma "tela atual" mutável do processo. O
/// construtor contém apenas as entradas que afetam o resultado; os fatores
/// derivados são calculados uma única vez na criação do snapshot. Portanto, a
/// igualdade funciona como chave exata de partição de cache.
class DimenMetrics {
  final int screenWidthDp;
  final int screenHeightDp;
  final int smallestScreenWidthDp;
  final int densityDpi;

  /// Raw font-scale bits kept for exact snapshot equality (NaN-safe).
  final double _fontScaleRaw;

  final int orientation;
  final int uiMode;
  final bool isInMultiWindowMode;

  /// The configuration this snapshot was derived from (identity helper for
  /// the engine; excluded from equality because every field already is).
  final ScreenConfiguration configuration;

  final _Derived _d;

  DimenMetrics({
    required int screenWidthDp,
    required int screenHeightDp,
    required int smallestScreenWidthDp,
    required int densityDpi,
    double fontScale = 1.0,
    this.orientation = ScreenConfiguration.orientationUndefined,
    this.uiMode = 0,
    this.isInMultiWindowMode = false,
    ScreenConfiguration? configuration,
  })  : screenWidthDp = screenWidthDp,
        screenHeightDp = screenHeightDp,
        smallestScreenWidthDp = smallestScreenWidthDp,
        densityDpi = densityDpi,
        _fontScaleRaw = (fontScale.isFinite && fontScale > 0) ? fontScale : 1.0,
        configuration = configuration ?? const ScreenConfiguration(),
        _d = _Derived.compute(
          w: screenWidthDp,
          h: screenHeightDp,
          sw: smallestScreenWidthDp,
          dpi: densityDpi,
          fontScale: fontScale,
        );

  /// Builds the metrics from a [ScreenConfiguration].
  factory DimenMetrics.from(
    ScreenConfiguration configuration, {
    bool isInMultiWindowMode = false,
  }) {
    return DimenMetrics(
      screenWidthDp: configuration.screenWidthDp,
      screenHeightDp: configuration.screenHeightDp,
      smallestScreenWidthDp: configuration.smallestScreenWidthDp,
      densityDpi: configuration.densityDpi,
      fontScale: configuration.fontScale,
      orientation: configuration.orientation,
      uiMode: configuration.uiMode,
      isInMultiWindowMode: isInMultiWindowMode,
      configuration: configuration,
    );
  }

  /// The configured font scale, normalized to a safe value.
  double get fontScale => _fontScaleRaw;

  /// True when the raw orientation code is landscape (2).
  bool get isLandscape =>
      orientation == ScreenConfiguration.orientationLandscape;

  /// True when the raw orientation code is portrait (1).
  bool get isPortrait => orientation == ScreenConfiguration.orientationPortrait;

  /// Current window bounds in dp — min/max sides, clamped at zero.
  double get minDimensionDp => _d.minDimensionDp;

  double get maxDimensionDp => _d.maxDimensionDp;

  /// Keeps the historical `sw` contract while remaining well-defined for
  /// synthetic/test configurations where it is undefined.
  double get smallestWidthDp => _d.smallestWidthDp;

  /// `dpi / 160`, guarded to a finite positive value.
  double get density => _d.density;

  /// `sw / 300` — the scaled default-path factor (plain field read: no
  /// late-initialization check on the hot lane).
  double get scale => _d.scale;

  /// Precomputed WIDTH factor: `w × 1/300`.
  double get screenWidthFactor => _d.screenWidthFactor;

  /// Precomputed HEIGHT factor: `h × 1/300`.
  double get screenHeightFactor => _d.screenHeightFactor;

  /// `max/min` normalized by the 1.78 reference ratio, guarded to finite > 0.
  double get normalizedAspectRatio => _d.normalizedAspectRatio;

  /// Exact natural logarithm — computed once when the snapshot is created.
  double get logNormalizedAspectRatio => _d.logNormalizedAspectRatio;

  /// `1 + k_default · lnAR`.
  double get defaultAspectRatioMultiplier => _d.defaultAspectRatioMultiplier;

  /// `1 + (sw − 300) × (adjScale + k_default · lnAR)`.
  double get defaultScaledAspectRatioMultiplier =>
      _d.defaultScaledAspectRatioMultiplier;

  // ───────────────────────────────────────────────────────────────────────
  // SATELLITE FACTORS — eagerly derived once per snapshot (plain final
  // loads on the hot lane: no lazy-init branch, no per-call transcendental
  // re-evaluation). Axis variants cover the hdp/wdp stems of the
  // non-linear families.
  // ───────────────────────────────────────────────────────────────────────

  /// `(sw / 300)^0.75` — power satellite default-path scale.
  double get powerScale => _d.powerScale;

  /// `(w / 300)^0.75` — power WIDTH-axis factor.
  double get powerWidthFactor => _d.powerWidthFactor;

  /// `(h / 300)^0.75` — power HEIGHT-axis factor.
  double get powerHeightFactor => _d.powerHeightFactor;

  /// `1 + (sw/300 − 1) × 0.5` — interpolated satellite default-path scale.
  double get interpolatedScale => _d.interpolatedScale;

  /// `√(min² + max²) / 611.6305` — diagonal satellite default-path scale.
  double get diagonalScale => _d.diagonalScale;

  /// `(min + max) / 833` — perimeter satellite default-path scale.
  double get perimeterScale => _d.perimeterScale;

  /// Logarithmic satellite default-path scale (piecewise ±0.4·ln).
  double get logarithmicScale => _d.logarithmicScale;

  /// Logarithmic WIDTH-axis factor (piecewise ±slope·ln).
  double get logarithmicWidthFactor => _d.logarithmicWidthFactor;

  /// Logarithmic HEIGHT-axis factor (piecewise ±slope·ln).
  double get logarithmicHeightFactor => _d.logarithmicHeightFactor;

  /// Auto satellite smallest-width scale (flat below the transition point,
  /// log-curved above).
  double get autoScale => _d.autoScale;

  /// Auto WIDTH-axis factor.
  double get autoWidthFactor => _d.autoWidthFactor;

  /// Auto HEIGHT-axis factor.
  double get autoHeightFactor => _d.autoHeightFactor;

  /// `min(minDp/300, maxDp/533)` — fit (contain) scale.
  double get fitScale => _d.fitScale;

  /// `max(minDp/300, maxDp/533)` — fill (cover) scale.
  double get fillScale => _d.fillScale;

  /// Shared AR slope `adjScale + k_default · lnAR` — hoists one multiply-add
  /// out of every per-axis AR factor computation.
  double get aspectRatioSlope => _d.aspectRatioSlope;

  /// Multiplier used by the scaled SDP/SSP path. Invalid sensitivities are
  /// rejected instead of leaking NaN or infinity into a layout.
  double scaledMultiplier(bool applyAspectRatio, double? customSensitivityK) {
    if (!applyAspectRatio) return _d.scale;
    if (customSensitivityK == null) return defaultScaledAspectRatioMultiplier;
    if (!customSensitivityK.isFinite) {
      throw ArgumentError.value(
          customSensitivityK, 'customSensitivityK', 'must be finite');
    }
    final result = 1 +
        (_d.smallestWidthDp - DesignScaleConstants.baseWidthDp) *
            (DimenCache.adjustmentScale +
                customSensitivityK * _d.logNormalizedAspectRatio);
    if (!result.isFinite) {
      throw ArgumentError('customSensitivityK produces a non-finite '
          'dimension multiplier');
    }
    return result;
  }

  /// Multiplier shared by satellite strategies that apply AR after their base
  /// formula.
  double aspectRatioMultiplier(double? customSensitivityK) {
    if (customSensitivityK == null) return _d.defaultAspectRatioMultiplier;
    if (!customSensitivityK.isFinite) {
      throw ArgumentError.value(
          customSensitivityK, 'customSensitivityK', 'must be finite');
    }
    final result = 1 + customSensitivityK * _d.logNormalizedAspectRatio;
    if (!result.isFinite) {
      throw ArgumentError('customSensitivityK produces a non-finite '
          'aspect-ratio multiplier');
    }
    return result;
  }

  /// Fast-lane kernel: the multiplier for [qualifier] honoring AR.
  double fastScaledMultiplier(DpQualifier qualifier, bool applyAspectRatio) {
    switch (qualifier) {
      case DpQualifier.smallWidth:
        return applyAspectRatio
            ? _d.defaultScaledAspectRatioMultiplier
            : _d.scale;
      case DpQualifier.width:
        return _d.screenWidthFactor;
      case DpQualifier.height:
        return _d.screenHeightFactor;
    }
  }

  /// Baseline snapshot (300 × 533 @ 160dpi, fs 1.0, undefined orientation).
  static final DimenMetrics baseline = DimenMetrics.from(
    ScreenConfiguration.baseline,
  );

  @override
  bool operator ==(Object other) {
    return other is DimenMetrics &&
        other.screenWidthDp == screenWidthDp &&
        other.screenHeightDp == screenHeightDp &&
        other.smallestScreenWidthDp == smallestScreenWidthDp &&
        other.densityDpi == densityDpi &&
        other._fontScaleRaw == _fontScaleRaw &&
        other.orientation == orientation &&
        other.uiMode == uiMode &&
        other.isInMultiWindowMode == isInMultiWindowMode;
  }

  @override
  int get hashCode => Object.hash(
      screenWidthDp,
      screenHeightDp,
      smallestScreenWidthDp,
      densityDpi,
      _fontScaleRaw,
      orientation,
      uiMode,
      isInMultiWindowMode);

  @override
  String toString() =>
      'DimenMetrics($screenWidthDp×$screenHeightDp, sw=$smallestWidthDp, '
      'd=$density, fs=$fontScale, mw=$isInMultiWindowMode)';
}

/// Eagerly computed derived factors — plain final fields, so every hot-lane
/// read is a single field load (no `late` initialization checks, no
/// transcendental re-evaluation per call).
class _Derived {
  final double minDimensionDp;
  final double maxDimensionDp;
  final double smallestWidthDp;
  final double density;
  final double scale;
  final double screenWidthFactor;
  final double screenHeightFactor;
  final double normalizedAspectRatio;
  final double logNormalizedAspectRatio;
  final double defaultAspectRatioMultiplier;
  final double defaultScaledAspectRatioMultiplier;

  // Satellite factors (eager; pure functions of this snapshot).
  final double powerScale;
  final double powerWidthFactor;
  final double powerHeightFactor;
  final double interpolatedScale;
  final double diagonalScale;
  final double perimeterScale;
  final double logarithmicScale;
  final double logarithmicWidthFactor;
  final double logarithmicHeightFactor;
  final double autoScale;
  final double autoWidthFactor;
  final double autoHeightFactor;
  final double fitScale;
  final double fillScale;
  final double aspectRatioSlope;

  _Derived._(
    this.minDimensionDp,
    this.maxDimensionDp,
    this.smallestWidthDp,
    this.density,
    this.scale,
    this.screenWidthFactor,
    this.screenHeightFactor,
    this.normalizedAspectRatio,
    this.logNormalizedAspectRatio,
    this.defaultAspectRatioMultiplier,
    this.defaultScaledAspectRatioMultiplier,
    this.powerScale,
    this.powerWidthFactor,
    this.powerHeightFactor,
    this.interpolatedScale,
    this.diagonalScale,
    this.perimeterScale,
    this.logarithmicScale,
    this.logarithmicWidthFactor,
    this.logarithmicHeightFactor,
    this.autoScale,
    this.autoWidthFactor,
    this.autoHeightFactor,
    this.fitScale,
    this.fillScale,
    this.aspectRatioSlope,
  );

  factory _Derived.compute({
    required int w,
    required int h,
    required int sw,
    required int dpi,
    required double fontScale,
  }) {
    final minDim = (w < h ? w : h).clamp(0, 1 << 30).toDouble();
    final maxDim = (w > h ? w : h).clamp(0, 1 << 30).toDouble();
    final smallest = sw > 0
        ? sw.toDouble()
        : minDim > 0
            ? minDim
            : DesignScaleConstants.baseWidthDp;
    final rawDensity = dpi / 160.0;
    final safeDensity =
        rawDensity.isFinite && rawDensity > 0 ? rawDensity : 1.0;
    final rawAr = minDim > 0 ? maxDim / minDim : 1.0;
    var norm = rawAr / DesignScaleConstants.referenceAspectRatio;
    if (!norm.isFinite || norm <= 0) norm = 1.0;
    final lnAr = math.log(norm);

    // Per-axis doubles (exact integer values; identical to axisDp reads).
    final wd = w.toDouble();
    final hd = h.toDouble();

    // Power curve — `(axis/300)^0.75` (Stevens' exponent parity).
    const pwExp = 0.75; // PowerFactors.exponent
    final powerSw =
        math.pow(smallest * DimenCache.invBaseRatio, pwExp).toDouble();
    final powerW = math.pow(wd * DimenCache.invBaseRatio, pwExp).toDouble();
    final powerH = math.pow(hd * DimenCache.invBaseRatio, pwExp).toDouble();

    // Logarithmic curve — piecewise ±0.4·ln around the 300 dp reference
    // (`LogarithmicCurve.slope` parity).
    const logSlope = 0.4;
    double logFactor(double d) {
      if (d > DesignScaleConstants.baseWidthDp) {
        return 1 + logSlope * math.log(d * DimenCache.invBaseRatio);
      }
      if (d > 0) {
        return 1 - logSlope * math.log(DesignScaleConstants.baseWidthDp / d);
      }
      return 1.0;
    }

    // Auto curve — flat linear below the transition point, log-curved above
    // (`AutoTransition.pointDp` / `.slope` parity).
    const autoPoint = 480.0;
    const autoSlope = 0.4;
    double autoFactor(double d) {
      if (d <= autoPoint) return d * DimenCache.invBaseRatio;
      return autoPoint * DimenCache.invBaseRatio +
          autoSlope *
              math.log(1 + (d - autoPoint) * DimenCache.invBaseRatio);
    }

    // Fit / fill — contain/cover ratios against the 300×533 reference.
    final fitRatioMin = minDim / DesignScaleConstants.baseWidthDp;
    final fitRatioMax = maxDim / DesignScaleConstants.baseHeightDp;

    return _Derived._(
      minDim,
      maxDim,
      smallest,
      safeDensity,
      smallest * DimenCache.invBaseRatio,
      w * DimenCache.invBaseRatio,
      h * DimenCache.invBaseRatio,
      norm,
      lnAr,
      1 + DimenCache.sensitivityDefault * lnAr,
      1 +
          (smallest - DesignScaleConstants.baseWidthDp) *
              (DimenCache.adjustmentScale +
                  DimenCache.sensitivityDefault * lnAr),
      powerSw,
      powerW,
      powerH,
      1 + (smallest * DimenCache.invBaseRatio - 1) * 0.5,
      math.sqrt(minDim * minDim + maxDim * maxDim) /
          DesignScaleConstants.baseDiagonalDp,
      (minDim + maxDim) / DesignScaleConstants.basePerimeterDp,
      logFactor(smallest),
      logFactor(wd),
      logFactor(hd),
      autoFactor(smallest),
      autoFactor(wd),
      autoFactor(hd),
      math.min(fitRatioMin, fitRatioMax),
      math.max(fitRatioMin, fitRatioMax),
      DimenCache.adjustmentScale + DimenCache.sensitivityDefault * lnAr,
    );
  }
}
