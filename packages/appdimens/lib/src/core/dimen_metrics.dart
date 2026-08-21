/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// The immutable resolution snapshot — the heart of the AppDimens fast lane.
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

  DimenMetrics({
    required this.screenWidthDp,
    required this.screenHeightDp,
    required this.smallestScreenWidthDp,
    required this.densityDpi,
    double fontScale = 1.0,
    this.orientation = ScreenConfiguration.orientationUndefined,
    this.uiMode = 0,
    this.isInMultiWindowMode = false,
    ScreenConfiguration? configuration,
  })  : _fontScaleRaw = (fontScale.isFinite && fontScale > 0) ? fontScale : 1.0,
        configuration = configuration ?? const ScreenConfiguration();

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
  bool get isLandscape => orientation == ScreenConfiguration.orientationLandscape;

  /// True when the raw orientation code is portrait (1).
  bool get isPortrait => orientation == ScreenConfiguration.orientationPortrait;

  /// Current window bounds in dp — min/max sides, clamped at zero.
  late final double minDimensionDp =
      (screenWidthDp < screenHeightDp ? screenWidthDp : screenHeightDp)
          .clamp(0, 1 << 30)
          .toDouble();

  late final double maxDimensionDp =
      (screenWidthDp > screenHeightDp ? screenWidthDp : screenHeightDp)
          .clamp(0, 1 << 30)
          .toDouble();

  /// Keeps the historical `sw` contract while remaining well-defined for
  /// synthetic/test configurations where it is undefined.
  late final double smallestWidthDp = () {
    if (smallestScreenWidthDp > 0) return smallestScreenWidthDp.toDouble();
    if (minDimensionDp > 0) return minDimensionDp;
    return DesignScaleConstants.baseWidthDp;
  }();

  /// `dpi / 160`, guarded to a finite positive value.
  late final double density = () {
    final d = densityDpi / 160.0;
    return d.isFinite && d > 0 ? d : 1.0;
  }();

  /// `sw / 300` — the scaled default-path factor.
  late final double scale = smallestWidthDp * DimenCache.invBaseRatio;

  /// Precomputed WIDTH factor: `w × 1/300` (hot lane pays one field read).
  late final double screenWidthFactor = screenWidthDp * DimenCache.invBaseRatio;

  /// Precomputed HEIGHT factor: `h × 1/300`.
  late final double screenHeightFactor =
      screenHeightDp * DimenCache.invBaseRatio;

  /// `max/min` normalized by the 1.78 reference ratio, guarded to finite > 0.
  late final double normalizedAspectRatio = () {
    final raw = minDimensionDp > 0 ? maxDimensionDp / minDimensionDp : 1.0;
    final v = raw / DesignScaleConstants.referenceAspectRatio;
    return v.isFinite && v > 0 ? v : 1.0;
  }();

  /// Exact natural logarithm — computed once when the snapshot is created.
  late final double logNormalizedAspectRatio =
      math.log(normalizedAspectRatio);

  /// `1 + k_default · lnAR`.
  late final double defaultAspectRatioMultiplier =
      1 + DimenCache.sensitivityDefault * logNormalizedAspectRatio;

  /// `1 + (sw − 300) × (adjScale + k_default · lnAR)`.
  late final double defaultScaledAspectRatioMultiplier = 1 +
      (smallestWidthDp - DesignScaleConstants.baseWidthDp) *
          (DimenCache.adjustmentScale +
              DimenCache.sensitivityDefault * logNormalizedAspectRatio);

  // ───────────────────────────────────────────────────────────────────────
  // SATELLITE FACTORS — computed at most once per snapshot, only when read.
  // ───────────────────────────────────────────────────────────────────────

  /// `(sw / 300)^0.75` — power satellite default-path scale.
  late final double powerScale =
      math.pow(smallestWidthDp / DesignScaleConstants.baseWidthDp, 0.75)
          .toDouble();

  /// `1 + (sw/300 − 1) × 0.5` — interpolated satellite default-path scale.
  late final double interpolatedScale =
      1 + (smallestWidthDp * DimenCache.invBaseRatio - 1) * 0.5;

  /// `√(min² + max²) / 611.6305` — diagonal satellite default-path scale.
  late final double diagonalScale = () {
    final min2 = minDimensionDp * minDimensionDp;
    final max2 = maxDimensionDp * maxDimensionDp;
    return math.sqrt(min2 + max2) / DesignScaleConstants.baseDiagonalDp;
  }();

  /// `(min + max) / 833` — perimeter satellite default-path scale.
  late final double perimeterScale =
      (minDimensionDp + maxDimensionDp) / DesignScaleConstants.basePerimeterDp;

  /// Logarithmic satellite default-path scale (piecewise ±0.4·ln).
  late final double logarithmicScale = () {
    if (smallestWidthDp > DesignScaleConstants.baseWidthDp) {
      return 1 + 0.4 * math.log(smallestWidthDp * DimenCache.invBaseRatio);
    }
    if (smallestWidthDp > 0) {
      return 1 -
          0.4 *
              math.log(
                  DesignScaleConstants.baseWidthDp / smallestWidthDp);
    }
    return 1.0;
  }();

  /// Multiplier used by the scaled SDP/SSP path. Invalid sensitivities are
  /// rejected instead of leaking NaN or infinity into a layout.
  double scaledMultiplier(bool applyAspectRatio, double? customSensitivityK) {
    if (!applyAspectRatio) return scale;
    if (customSensitivityK == null) return defaultScaledAspectRatioMultiplier;
    if (!customSensitivityK.isFinite) {
      throw ArgumentError.value(
          customSensitivityK, 'customSensitivityK', 'must be finite');
    }
    final result = 1 +
        (smallestWidthDp - DesignScaleConstants.baseWidthDp) *
            (DimenCache.adjustmentScale +
                customSensitivityK * logNormalizedAspectRatio);
    if (!result.isFinite) {
      throw ArgumentError('customSensitivityK produces a non-finite '
          'dimension multiplier');
    }
    return result;
  }

  /// Multiplier shared by satellite strategies that apply AR after their base
  /// formula.
  double aspectRatioMultiplier(double? customSensitivityK) {
    if (customSensitivityK == null) return defaultAspectRatioMultiplier;
    if (!customSensitivityK.isFinite) {
      throw ArgumentError.value(
          customSensitivityK, 'customSensitivityK', 'must be finite');
    }
    final result = 1 + customSensitivityK * logNormalizedAspectRatio;
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
        return applyAspectRatio ? defaultScaledAspectRatioMultiplier : scale;
      case DpQualifier.width:
        return screenWidthFactor;
      case DpQualifier.height:
        return screenHeightFactor;
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
  int get hashCode => Object.hash(screenWidthDp, screenHeightDp,
      smallestScreenWidthDp, densityDpi, _fontScaleRaw, orientation, uiMode,
      isInMultiWindowMode);

  @override
  String toString() =>
      'DimenMetrics(${screenWidthDp}×${screenHeightDp}, sw=$smallestWidthDp, '
      'd=$density, fs=$fontScale, mw=$isInMultiWindowMode)';
}
