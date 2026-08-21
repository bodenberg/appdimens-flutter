/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Resize strategy — constraint-based auto-fit (largest size that still fits).
import 'package:appdimens/appdimens.dart';

/// EN: Resize helpers mirroring `DimenResize` in Kotlin. The resize strategy
/// is not a scaling curve — it searches the largest candidate within
/// `[min, max]` that satisfies a fitting predicate (binary search over the
/// step table).
///
/// PT: Auxiliares de redimensionamento espelhando `DimenResize` em Kotlin. A
/// estratégia resize não é uma curva de escala — ela busca o maior candidato
/// dentro de `[min, max]` que satisfaça um predicado de encaixe (busca
/// binária na tabela de passos).
abstract final class DimenResize {
  /// Logical-px range for `[minDp, maxDp]` stepping by [stepDp].
  static ResizeRangePx rangePx(
    AppDimensContextLike scope,
    num min,
    num max, {
    num step = 2,
  }) {
    final density = scope.dimenMetrics.density;
    return ResizeRangePx(
      minPx: min.toDouble() * density,
      maxPx: max.toDouble() * density,
      stepPx: step.toDouble().clamp(0.1, double.infinity) * density,
    );
  }

  /// Range whose bounds are percents of an inner box edge.
  static ResizeRangePx rangePxPercentOfInnerBox({
    required AutoResizePercentBasis basis,
    required num minPercent,
    required num maxPercent,
    num stepDp = 2,
    required AppDimensContextLike scope,
    required double innerWidthPx,
    required double innerHeightPx,
  }) {
    final density = scope.dimenMetrics.density;
    final base = switch (basis) {
      AutoResizePercentBasis.width => innerWidthPx,
      AutoResizePercentBasis.height => innerHeightPx,
      AutoResizePercentBasis.minSide =>
        innerWidthPx < innerHeightPx ? innerWidthPx : innerHeightPx,
    };
    return ResizeRangePx(
      minPx: base * ResizeMath.percentOfBoxToFactor(minPercent.toDouble()),
      maxPx: base * ResizeMath.percentOfBoxToFactor(maxPercent.toDouble()),
      stepPx: stepDp.toDouble().clamp(0.1, double.infinity) * density,
    );
  }

  /// Largest step fitting inside the inner width.
  static double fittingInnerWidthPx(
          ResizeRangePx range, double innerWidthPx) =>
      range.resolveFitting((v) => v <= innerWidthPx);

  /// Largest step fitting inside the inner height.
  static double fittingInnerHeightPx(
          ResizeRangePx range, double innerHeightPx) =>
      range.resolveFitting((v) => v <= innerHeightPx);

  /// Largest step fitting as a square side of the inner box.
  static double fittingInnerSquareSidePx(
          ResizeRangePx range, double innerWidthPx, double innerHeightPx) {
    final limit =
        innerWidthPx < innerHeightPx ? innerWidthPx : innerHeightPx;
    return range.resolveFitting((v) => v <= limit);
  }

  /// Inner maximum dimensions after removing padding (physical px).
  static ({double width, double height}) innerMaxDimensionsPx({
    required double boxWidthPx,
    required double boxHeightPx,
    required double paddingLeftPx,
    required double paddingRightPx,
    required double paddingTopPx,
    required double paddingBottomPx,
  }) {
    final w = (boxWidthPx - paddingLeftPx - paddingRightPx)
        .clamp(1.0, double.infinity);
    final h = (boxHeightPx - paddingTopPx - paddingBottomPx)
        .clamp(1.0, double.infinity);
    return (width: w, height: h);
  }
}
