/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Physical units module — mm / cm / inch ↔ dp / px / sp conversions.
library;

import 'dart:math' as math;

import 'package:appdimens/appdimens.dart';

/// Physical conversion constants.
abstract final class PhysicalUnitConstants {
  /// Millimeters per inch.
  static const double mmPerInch = 25.4;

  /// Centimeters per inch.
  static const double cmPerInch = 2.54;

  /// Millimeters per centimeter.
  static const double mmPerCm = 10.0;

  /// Reference dpi used when no calibrated value is available.
  static const double referenceDpi = 160.0;
}

/// EN: Physical-unit conversions (approximate real-world sizes on screen).
/// `xdpi` defaults to the density-derived estimate; pass a calibrated value
/// for exactness on specific panels.
///
/// PT: Conversões de unidades físicas (tamanhos aproximados no mundo real).
/// O `xdpi` assume o valor derivado da densidade; passe um valor calibrado
/// para exatidão em painéis específicos.
abstract final class DimenPhysicalUnits {
  /// Millimeters → logical dp.
  static double toDpFromMm(num mm,
      {required AppDimensContextLike scope, double? xdpi}) {
    final d = scope.dimenMetrics;
    final ppi = xdpi ?? d.density * PhysicalUnitConstants.referenceDpi;
    return mm.toDouble() * ppi / PhysicalUnitConstants.mmPerInch / d.density;
  }

  /// Centimeters → logical dp.
  static double toDpFromCm(num cm,
          {required AppDimensContextLike scope, double? xdpi}) =>
      toDpFromMm(cm.toDouble() * PhysicalUnitConstants.mmPerCm,
          scope: scope, xdpi: xdpi);

  /// Inches → logical dp.
  static double toDpFromInch(num inches,
          {required AppDimensContextLike scope, double? xdpi}) =>
      toDpFromMm(inches.toDouble() * PhysicalUnitConstants.mmPerInch,
          scope: scope, xdpi: xdpi);

  /// Millimeters → physical px.
  static double toPxFromMm(num mm,
          {required AppDimensContextLike scope, double? xdpi}) =>
      toDpFromMm(mm, scope: scope, xdpi: xdpi) * scope.dimenMetrics.density;

  /// Centimeters → physical px.
  static double toPxFromCm(num cm,
          {required AppDimensContextLike scope, double? xdpi}) =>
      toDpFromCm(cm, scope: scope, xdpi: xdpi) * scope.dimenMetrics.density;

  /// Inches → physical px.
  static double toPxFromInch(num inches,
          {required AppDimensContextLike scope, double? xdpi}) =>
      toDpFromInch(inches, scope: scope, xdpi: xdpi) *
      scope.dimenMetrics.density;

  /// Sp variants (divide by the font scale so rendering restores the size).
  static double toSpFromMm(num mm, {required AppDimensContextLike scope}) {
    final fs = scope.dimenMetrics.fontScale;
    final px = toPxFromMm(mm, scope: scope);
    return fs > 0 ? px / fs : px;
  }

  /// Radius from a diameter expressed in [unitType].
  static double radiusFromDiameter(num diameter, UnitType unitType,
      {required AppDimensContextLike scope}) {
    return _diameterToDp(diameter.toDouble(), unitType, scope) / 2.0;
  }

  /// Radius from a circumference expressed in [unitType].
  static double radiusFromCircumference(num circumference, UnitType unitType,
      {required AppDimensContextLike scope}) {
    final dp = _diameterToDp(circumference.toDouble(), unitType, scope) /
        (2.0 * math.pi);
    return dp / 2.0;
  }

  // ── Pure converters (no screen involvement) ─────────────────────────────

  static double mmToCm(num mm) => mm.toDouble() / PhysicalUnitConstants.mmPerCm;
  static double mmToInch(num mm) =>
      mm.toDouble() / PhysicalUnitConstants.mmPerInch;
  static double cmToMm(num cm) => cm.toDouble() * PhysicalUnitConstants.mmPerCm;
  static double cmToInch(num cm) =>
      cm.toDouble() / PhysicalUnitConstants.cmPerInch;
  static double inchToMm(num inch) =>
      inch.toDouble() * PhysicalUnitConstants.mmPerInch;
  static double inchToCm(num inch) =>
      inch.toDouble() * PhysicalUnitConstants.cmPerInch;

  static double _diameterToDp(
      double v, UnitType unitType, AppDimensContextLike scope) {
    switch (unitType) {
      case UnitType.inch:
        return toDpFromInch(v, scope: scope);
      case UnitType.cm:
        return toDpFromCm(v, scope: scope);
      case UnitType.mm:
        return toDpFromMm(v, scope: scope);
      case UnitType.sp:
        return v * scope.dimenMetrics.fontScale;
      case UnitType.dp:
        return v;
      case UnitType.px:
        return v / scope.dimenMetrics.density;
    }
  }
}

/// EN: Unit-conversion extensions (`25.mmToCm`, …).
///
/// PT: Extensões de conversão de unidades (`25.mmToCm`, …).
extension AppDimensUnitConverters on num {
  double get mmToCm => DimenPhysicalUnits.mmToCm(this);
  double get mmToInch => DimenPhysicalUnits.mmToInch(this);
  double get cmToMm => DimenPhysicalUnits.cmToMm(this);
  double get cmToInch => DimenPhysicalUnits.cmToInch(this);
  double get inchToMm => DimenPhysicalUnits.inchToMm(this);
  double get inchToCm => DimenPhysicalUnits.inchToCm(this);
}
