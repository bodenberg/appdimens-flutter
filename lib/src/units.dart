import 'configuration.dart';

enum PhysicalUnit { inch, centimeter, millimeter, point, pixel }

abstract final class DimensUnits {
  static double points(
    double value, {
    required PhysicalUnit from,
    required DimensConfiguration configuration,
    double? pixelsPerInch,
  }) => switch (from) {
    PhysicalUnit.point => value,
    PhysicalUnit.pixel => value / configuration.displayScale,
    PhysicalUnit.inch => value * 72,
    PhysicalUnit.centimeter => value * 72 / 2.54,
    PhysicalUnit.millimeter => value * 72 / 25.4,
  };
  static double pixels(
    double value, {
    required PhysicalUnit from,
    required DimensConfiguration configuration,
    double? pixelsPerInch,
  }) {
    if (from == PhysicalUnit.pixel) return value;
    if (pixelsPerInch != null) {
      if (from == PhysicalUnit.inch) return value * pixelsPerInch;
      if (from == PhysicalUnit.centimeter) return value * pixelsPerInch / 2.54;
      if (from == PhysicalUnit.millimeter) return value * pixelsPerInch / 25.4;
    }
    return points(value, from: from, configuration: configuration) *
        configuration.displayScale;
  }
}
