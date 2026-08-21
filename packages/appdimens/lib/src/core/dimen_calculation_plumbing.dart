/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Strategy-agnostic screen plumbing shared by every strategy module.
import 'dart:math' as math;

import '../common/dp_qualifier.dart';
import '../common/inverter.dart';
import 'design_scale_constants.dart';
import 'screen_configuration.dart';

/// EN: Inverter resolution, multi-window detection and dp reads. Each strategy
/// module applies its own formula on top of this.
///
/// PT: Resolução de inversores, detecção de multi-janela e leituras em dp.
/// Cada módulo de estratégia aplica sua própria fórmula sobre isto.
abstract final class DimenCalculationPlumbing {
  /// Applies the [inverter] swap rule to [qualifier] for the given orientation.
  static DpQualifier effectiveQualifier(
    DpQualifier qualifier,
    Inverter inverter,
    bool isLandscape,
    bool isPortrait,
  ) {
    switch (inverter) {
      case Inverter.standard:
        return qualifier;
      case Inverter.phToLw:
        if (isLandscape && qualifier == DpQualifier.height) {
          return DpQualifier.width;
        }
        return qualifier;
      case Inverter.pwToLh:
        if (isLandscape && qualifier == DpQualifier.width) {
          return DpQualifier.height;
        }
        return qualifier;
      case Inverter.lhToPw:
        if (isPortrait && qualifier == DpQualifier.height) {
          return DpQualifier.width;
        }
        return qualifier;
      case Inverter.lwToPh:
        if (isPortrait && qualifier == DpQualifier.width) {
          return DpQualifier.height;
        }
        return qualifier;
      case Inverter.swToLh:
        if (isLandscape && qualifier == DpQualifier.smallWidth) {
          return DpQualifier.height;
        }
        return qualifier;
      case Inverter.swToLw:
        if (isLandscape && qualifier == DpQualifier.smallWidth) {
          return DpQualifier.width;
        }
        return qualifier;
      case Inverter.swToPh:
        if (isPortrait && qualifier == DpQualifier.smallWidth) {
          return DpQualifier.height;
        }
        return qualifier;
      case Inverter.swToPw:
        if (isPortrait && qualifier == DpQualifier.smallWidth) {
          return DpQualifier.width;
        }
        return qualifier;
    }
  }

  /// True when multi-window suppression applies. [knownInMultiWindow] carries
  /// the authoritative answer when available; otherwise the dimension
  /// heuristic (`(sw − w) ≥ sw × 10%`) is a best-effort fallback.
  static bool isMultiWindowConstrained(
    ScreenConfiguration configuration,
    bool ignoreMultiWindows, {
    bool? knownInMultiWindow,
  }) {
    if (!ignoreMultiWindows) return false;
    if (knownInMultiWindow != null) return knownInMultiWindow;
    final swDp = configuration.smallestScreenWidthDp.toDouble();
    if (swDp <= 0) return false;
    final cwDp = configuration.screenWidthDp.toDouble();
    return (swDp - cwDp) >= (swDp * 0.1);
  }

  /// Reads the real window axis in dp for the resolved qualifier.
  static double readScreenDp(
      ScreenConfiguration configuration, DpQualifier actualQualifier) {
    switch (actualQualifier) {
      case DpQualifier.height:
        return configuration.screenHeightDp.toDouble();
      case DpQualifier.width:
        return configuration.screenWidthDp.toDouble();
      case DpQualifier.smallWidth:
        return configuration.effectiveSmallestWidthDp.toDouble();
    }
  }

  /// Smallest window side in dp.
  static double smallestSideDp(ScreenConfiguration configuration) =>
      configuration.screenWidthDp < configuration.screenHeightDp
          ? configuration.screenWidthDp.toDouble()
          : configuration.screenHeightDp.toDouble();

  /// Largest window side in dp.
  static double largestSideDp(ScreenConfiguration configuration) =>
      configuration.screenWidthDp > configuration.screenHeightDp
          ? configuration.screenWidthDp.toDouble()
          : configuration.screenHeightDp.toDouble();

  /// Multiplicative factor for optional aspect-ratio correction:
  /// `1 + sensitivity × ln(ar / 1.78)` (guarded to `1.0` on degenerate input).
  static double aspectRatioMultiplier(
      ScreenConfiguration configuration, double sensitivity) {
    final sm = smallestSideDp(configuration);
    final lg = largestSideDp(configuration);
    if (sm <= 0) return 1.0;
    final ar = lg / sm;
    if (!ar.isFinite) return 1.0;
    final arg = ar * DesignScaleConstants.invReferenceAspectRatio;
    if (!arg.isFinite || arg <= 0) return 1.0;
    return 1 + sensitivity * math.log(arg);
  }

  /// Guarded `ln`: exact logarithm when finite and positive, `0.0` otherwise.
  static double fastLn(double v) =>
      (v.isFinite && v > 0) ? math.log(v) : 0.0;
}
