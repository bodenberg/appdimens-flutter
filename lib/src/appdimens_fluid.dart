import 'package:flutter/widgets.dart';

import 'appdimens_types.dart';

@immutable
class FluidConfig {
  const FluidConfig({
    required this.minValue,
    required this.maxValue,
    required this.minWidth,
    required this.maxWidth,
  }) : assert(minWidth < maxWidth);
  final double minValue;
  final double maxValue;
  final double minWidth;
  final double maxWidth;
}

/// CSS-clamp-style interpolation with typed device and width overrides.
class AppDimensFluid {
  AppDimensFluid(this.min, this.max, {this.minWidth = 320, this.maxWidth = 768})
    : assert(minWidth < maxWidth);

  final double min;
  final double max;
  final double minWidth;
  final double maxWidth;
  final Map<DeviceType, FluidConfig> _devices = {};
  final Map<int, FluidConfig> _widths = {};

  double get preferred => (min + max) / 2;

  AppDimensFluid device(
    DeviceType type,
    double minimum,
    double maximum, {
    double? minWidth,
    double? maxWidth,
  }) {
    _devices[type] = FluidConfig(
      minValue: minimum,
      maxValue: maximum,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
    );
    return this;
  }

  AppDimensFluid screen(
    int smallestWidth,
    double minimum,
    double maximum, {
    double? minWidth,
    double? maxWidth,
  }) {
    _widths[smallestWidth] = FluidConfig(
      minValue: minimum,
      maxValue: maximum,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
    );
    return this;
  }

  double calculate(BuildContext context, {DeviceType? deviceType}) =>
      calculateForWidth(
        MediaQuery.sizeOf(context).width,
        deviceType: deviceType ?? DeviceType.current(context),
      );

  double calculateForWidth(double width, {DeviceType? deviceType}) =>
      _interpolate(width, _resolve(width, deviceType));

  double lerp(double progress) =>
      min + (max - min) * progress.clamp(0.0, 1.0).toDouble();

  FluidConfig _resolve(double width, DeviceType? deviceType) {
    final device = deviceType == null ? null : _devices[deviceType];
    if (device != null) return device;
    FluidConfig? match;
    var matchWidth = -1;
    for (final entry in _widths.entries) {
      if (width >= entry.key && entry.key > matchWidth) {
        matchWidth = entry.key;
        match = entry.value;
      }
    }
    return match ??
        FluidConfig(
          minValue: min,
          maxValue: max,
          minWidth: minWidth,
          maxWidth: maxWidth,
        );
  }

  static double _interpolate(double width, FluidConfig config) {
    final progress =
        ((width - config.minWidth) / (config.maxWidth - config.minWidth))
            .clamp(0.0, 1.0)
            .toDouble();
    return config.minValue + (config.maxValue - config.minValue) * progress;
  }
}

AppDimensFluid fluid(
  double minValue,
  double maxValue, {
  double minWidth = 320,
  double maxWidth = 768,
}) =>
    AppDimensFluid(minValue, maxValue, minWidth: minWidth, maxWidth: maxWidth);
