/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Resize subsystem — step tables and largest-fitting search (binary).
/// Axis basis used by the percent-based resize helpers.
enum AutoResizePercentBasis { height, width, minSide }

/// EN: Bound for a resize range: fixed dp, fixed sp, or a percent of an axis.
///
/// PT: Limite para um intervalo de redimensionamento: dp fixo, sp fixo ou um
/// percentual de um eixo.
sealed class ResizeBound {
  const ResizeBound();

  /// Resolves this bound to physical pixels.
  double resolveToPx({
    required ScreenConfigurationLike configuration,
    required double density,
    required double fontScale,
  });
}

/// Screen-configuration subset needed by bounds (avoids widget imports).
abstract interface class ScreenConfigurationLike {
  double get screenWidthDp;
  double get screenHeightDp;
  double get smallestWidthDp;
}

/// Fixed dp bound.
class ResizeFixedDp extends ResizeBound {
  final double dp;
  const ResizeFixedDp(this.dp);

  @override
  double resolveToPx(
          {required configuration, required density, required fontScale}) =>
      dp.clamp(0, double.infinity) * density;
}

/// Fixed sp bound.
class ResizeFixedSp extends ResizeBound {
  final double sp;
  const ResizeFixedSp(this.sp);

  @override
  double resolveToPx(
          {required configuration, required density, required fontScale}) =>
      sp.clamp(0, double.infinity) * density * (fontScale > 0 ? fontScale : 1.0);
}

/// Percent-of-axis bound (`value` in 0…100).
class ResizePercent extends ResizeBound {
  final double value;
  final DpQualifierLike axis;
  const ResizePercent(this.value, {this.axis = DpQualifierLike.smallWidth});

  @override
  double resolveToPx(
      {required configuration, required density, required fontScale}) {
    final axisDp = switch (axis) {
      DpQualifierLike.smallWidth => configuration.smallestWidthDp,
      DpQualifierLike.width => configuration.screenWidthDp,
      DpQualifierLike.height => configuration.screenHeightDp,
    };
    final pct = value.clamp(0, 100) / 100.0;
    return pct * axisDp * density;
  }
}

/// Local axis mirror (keeps this file independent of the common enums).
enum DpQualifierLike { smallWidth, width, height }

/// Convenience constructors mirroring the Kotlin helpers.
ResizeBound resizeFixedDp(double dp) => ResizeFixedDp(dp);
ResizeBound resizeFixedSp(double sp) => ResizeFixedSp(sp);
ResizeBound resizePercentSw(double percent) =>
    ResizePercent(percent, axis: DpQualifierLike.smallWidth);
ResizeBound resizePercentW(double percent) =>
    ResizePercent(percent, axis: DpQualifierLike.width);
ResizeBound resizePercentH(double percent) =>
    ResizePercent(percent, axis: DpQualifierLike.height);

/// EN: Resize math — builds a monotonic step table (max 4096 entries, always
/// ends at `maxPx`) and binary-searches the largest step whose predicate
/// fits. Mirrors `ResizeMath` in Kotlin.
///
/// PT: Matemática de redimensionamento — constrói uma tabela de passos
/// monotônica (máx. 4096 entradas, sempre termina em `maxPx`) e busca
/// binariamente o maior passo cujo predicado cabe. Espelha `ResizeMath`.
abstract final class ResizeMath {
  static const int maxResizeSteps = 4096;

  /// Builds the ascending candidate table `[minPx … maxPx]` by [stepPx].
  static List<double> buildResizeStepsPx(
      double minPx, double maxPx, double stepPx) {
    var lo = minPx;
    var hi = maxPx;
    if (lo > hi) {
      final t = lo;
      lo = hi;
      hi = t;
    }
    if (stepPx <= 0) return [lo];
    final capacity = (((hi - lo) / stepPx).truncate() + 2)
        .clamp(1, maxResizeSteps);
    final out = List<double>.filled(capacity, 0, growable: true);
    var count = 0;
    final epsilon = stepPx * 1e-4;
    var x = lo;
    while (x <= hi + epsilon && count < capacity) {
      out[count++] = x < hi ? x : hi;
      x += stepPx;
    }
    if (count > 0 && out[count - 1] < hi - epsilon && count < capacity) {
      out[count++] = hi;
    }
    return out.sublist(0, count);
  }

  /// Binary search for the largest fitting step; `0.0` when nothing fits.
  static double findLargestFittingResizePx(
      List<double> sortedStepsPx, bool Function(double) fits) {
    if (sortedStepsPx.isEmpty) return 0.0;
    if (sortedStepsPx.length == 1) {
      return fits(sortedStepsPx.first) ? sortedStepsPx.first : 0.0;
    }
    var low = 0;
    var high = sortedStepsPx.length - 1;
    var best = 0.0;
    while (low <= high) {
      final mid = (low + high) >> 1;
      final candidate = sortedStepsPx[mid];
      if (fits(candidate)) {
        best = candidate;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    return best;
  }

  /// `null | <= 0 | -1` all mean "unbounded".
  static int resolveAutoResizeMaxLines(int? maxLines) =>
      (maxLines == null || maxLines <= 0) ? 1 << 30 : maxLines;

  /// Truncates the measured text when [maxLength] is positive.
  static String resolveAutoResizeTextForMeasure(String text, int? maxLength) =>
      (maxLength != null && maxLength > 0) && text.length > maxLength
          ? text.substring(0, maxLength)
          : text;

  /// Converts a 0…100 percent into a 0…1 factor (clamped).
  static double percentOfBoxToFactor(double percent) =>
      (percent / 100.0).clamp(0.0, 1.0);
}

/// Precomputed resize range with a fitting resolver.
class ResizeRangePx {
  final double lowPx;
  final double highPx;
  final double stepPx;
  late final List<double> steps =
      ResizeMath.buildResizeStepsPx(lowPx, highPx, stepPx);

  ResizeRangePx({required double minPx, required double maxPx, double stepPx = 1})
      : lowPx = minPx,
        highPx = maxPx,
        stepPx = stepPx <= 0 ? 1 : stepPx;

  double resolveFitting(bool Function(double) fits) =>
      ResizeMath.findLargestFittingResizePx(steps, fits);
}
