/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Design reference constants shared across all strategy modules (no formulas).
abstract final class DesignScaleConstants {
  /// EN Reference smallest-width of the design baseline.
  /// PT Menor largura de referência da linha de base de design.
  static const double baseWidthDp = 300;

  /// EN Reference height of the design baseline.
  /// PT Altura de referência da linha de base de design.
  static const double baseHeightDp = 533;

  /// EN √(300² + 533²) — diagonal of the design baseline.
  /// PT √(300² + 533²) — diagonal da linha de base de design.
  static const double baseDiagonalDp = 611.6305;

  /// EN 300 + 533 — perimeter of the design baseline.
  /// PT 300 + 533 — perímetro da linha de base de design.
  static const double basePerimeterDp = 833;

  /// EN Reference aspect ratio (16:9 ≈ 1.78).
  /// PT Proporção de tela de referência (16:9 ≈ 1,78).
  static const double referenceAspectRatio = 1.78;

  /// EN `1 / 1.78`.
  /// PT `1 / 1,78`.
  static const double invReferenceAspectRatio = 0.5617978;
}
