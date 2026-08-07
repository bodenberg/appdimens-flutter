import 'configuration.dart';

sealed class ResizeBound {
  const ResizeBound();
  double points(DimensConfiguration c);
  factory ResizeBound.fixedDp(double value) = FixedDpBound;
  factory ResizeBound.fixedSp(double value) = FixedSpBound;
  factory ResizeBound.percent(double value, DpQualifier qualifier) =
      PercentBound;
}

class FixedDpBound extends ResizeBound {
  const FixedDpBound(this.value);
  final double value;
  @override
  double points(DimensConfiguration c) =>
      value.clamp(0, double.infinity).toDouble();
}

class FixedSpBound extends ResizeBound {
  const FixedSpBound(this.value);
  final double value;
  @override
  double points(DimensConfiguration c) =>
      value.clamp(0, double.infinity).toDouble() * c.fontScale;
}

class PercentBound extends ResizeBound {
  const PercentBound(this.value, this.qualifier);
  final double value;
  final DpQualifier qualifier;
  @override
  double points(DimensConfiguration c) =>
      value.clamp(0, 100).toDouble() * c.dimension(qualifier) / 100;
}

abstract final class DimensResize {
  static List<double> steps({
    required double minimum,
    required double maximum,
    required double step,
  }) {
    if (step <= 0 || minimum > maximum) throw ArgumentError();
    final out = <double>[];
    for (var x = minimum; x <= maximum && out.length < 4096; x += step) {
      out.add(x);
    }
    if ((out.isEmpty || out.last != maximum) && out.length < 4096) {
      out.add(maximum);
    }
    return out;
  }

  static double largestFitting(
    List<double> sorted,
    bool Function(double) fits,
  ) {
    var l = 0, r = sorted.length - 1, answer = 0.0;
    while (l <= r && sorted.isNotEmpty) {
      final m = l + (r - l) ~/ 2;
      if (fits(sorted[m])) {
        answer = sorted[m];
        l = m + 1;
      } else {
        r = m - 1;
      }
    }
    return answer;
  }
}
