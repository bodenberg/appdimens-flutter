import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'configuration.dart';
import 'scaled.dart';

enum DimensStrategy {
  scaled,
  auto,
  density,
  diagonal,
  fill,
  fit,
  fluid,
  interpolated,
  logarithmic,
  percent,
  perimeter,
  power,
  physical,
  plain,
}

@immutable
class DimensRange {
  const DimensRange(this.lower, this.upper);
  final double lower, upper;
}

@immutable
class StrategyOptions {
  const StrategyOptions({
    this.qualifier = DpQualifier.smallWidth,
    this.inverter = Inverter.standard,
    this.applyAspectRatio = false,
    this.ignoreMultiWindows = false,
    this.sensitivity = .10,
    this.percent = 100,
    this.power = .75,
    this.interpolation = .5,
    this.fluidViewport = const DimensRange(320, 768),
    this.fluidScale = const DimensRange(.8, 1.2),
  });
  final DpQualifier qualifier;
  final Inverter inverter;
  final bool applyAspectRatio, ignoreMultiWindows;
  final double sensitivity, percent, power, interpolation;
  final DimensRange fluidViewport, fluidScale;
}

abstract final class DynamicDimens {
  static double resolve(
    double value, {
    required DimensStrategy strategy,
    required DimensConfiguration configuration,
    StrategyOptions options = const StrategyOptions(),
  }) {
    final c = configuration, o = options;
    if (o.ignoreMultiWindows && c.isMultiWindow) return value;
    return switch (strategy) {
      DimensStrategy.plain || DimensStrategy.physical => value,
      DimensStrategy.scaled || DimensStrategy.auto => AppDimens.dp(
        value,
        configuration: c,
        qualifier: o.qualifier,
        inverter: o.inverter,
        ignoreMultiWindows: o.ignoreMultiWindows,
        applyAspectRatio: o.applyAspectRatio,
        sensitivity: o.sensitivity,
      ),
      DimensStrategy.density =>
        value *
            c.dimension(o.qualifier, inverter: o.inverter) /
            AppDimens.baseRatio *
            c.displayScale,
      DimensStrategy.diagonal =>
        value *
            math.sqrt(
              c.screenWidth * c.screenWidth + c.screenHeight * c.screenHeight,
            ) /
            math.sqrt(300 * 300 + 533 * 533),
      DimensStrategy.perimeter =>
        value * (c.screenWidth + c.screenHeight) / 833,
      DimensStrategy.fill =>
        value * math.max(c.screenWidth / 300, c.screenHeight / 533),
      DimensStrategy.fit =>
        value * math.min(c.screenWidth / 300, c.screenHeight / 533),
      DimensStrategy.fluid => _fluid(value, c, o),
      DimensStrategy.interpolated =>
        value *
            (1 +
                (c.dimension(o.qualifier, inverter: o.inverter) / 300 - 1) *
                    o.interpolation.clamp(0, 1)),
      DimensStrategy.logarithmic => _logarithmic(
        value,
        c.dimension(o.qualifier, inverter: o.inverter) / 300,
      ),
      DimensStrategy.percent =>
        c.dimension(o.qualifier, inverter: o.inverter) *
            o.percent *
            value /
            10000,
      DimensStrategy.power =>
        value *
            math.pow(
              c.dimension(o.qualifier, inverter: o.inverter) / 300,
              o.power,
            ),
    };
  }

  static double _fluid(double value, DimensConfiguration c, StrategyOptions o) {
    final d = c.dimension(o.qualifier, inverter: o.inverter),
        span = o.fluidViewport.upper - o.fluidViewport.lower;
    if (span == 0) {
      return value *
          (d < o.fluidViewport.lower ? o.fluidScale.lower : o.fluidScale.upper);
    }
    final t = ((d - o.fluidViewport.lower) / span).clamp(0, 1);
    return value *
        (o.fluidScale.lower + t * (o.fluidScale.upper - o.fluidScale.lower));
  }

  static double _logarithmic(double value, double linear) =>
      value *
      (linear >= 1 ? 1 + .4 * math.log(linear) : 1 - .4 * math.log(1 / linear));
}

@immutable
class DimensFactors {
  DimensFactors(this.configuration)
    : smallest = configuration.smallestScreenWidth / 300,
      width = configuration.screenWidth / 300,
      height = configuration.screenHeight / 300,
      diagonal =
          math.sqrt(
            configuration.screenWidth * configuration.screenWidth +
                configuration.screenHeight * configuration.screenHeight,
          ) /
          math.sqrt(300 * 300 + 533 * 533),
      perimeter =
          (configuration.screenWidth + configuration.screenHeight) / 833,
      fit = math.min(
        configuration.screenWidth / 300,
        configuration.screenHeight / 533,
      ),
      fill = math.max(
        configuration.screenWidth / 300,
        configuration.screenHeight / 533,
      );
  final DimensConfiguration configuration;
  final double smallest, width, height, diagonal, perimeter, fit, fill;
  double resolve(double value, DimensStrategy strategy) => switch (strategy) {
    DimensStrategy.scaled || DimensStrategy.auto => value * smallest,
    DimensStrategy.density => value * smallest * configuration.displayScale,
    DimensStrategy.diagonal => value * diagonal,
    DimensStrategy.perimeter => value * perimeter,
    DimensStrategy.fill => value * fill,
    DimensStrategy.fit => value * fit,
    DimensStrategy.plain || DimensStrategy.physical => value,
    _ => DynamicDimens.resolve(
      value,
      strategy: strategy,
      configuration: configuration,
    ),
  };
}

extension AppDimensStrategyNum on num {
  double dynamic(
    DimensStrategy strategy,
    DimensConfiguration c, {
    StrategyOptions options = const StrategyOptions(),
  }) => DynamicDimens.resolve(
    toDouble(),
    strategy: strategy,
    configuration: c,
    options: options,
  );
  double densityDp(
    DimensConfiguration c, {
    StrategyOptions options = const StrategyOptions(),
  }) => dynamic(DimensStrategy.density, c, options: options);
  double diagonalDp(
    DimensConfiguration c, {
    StrategyOptions options = const StrategyOptions(),
  }) => dynamic(DimensStrategy.diagonal, c, options: options);
  double fillDp(
    DimensConfiguration c, {
    StrategyOptions options = const StrategyOptions(),
  }) => dynamic(DimensStrategy.fill, c, options: options);
  double fitDp(
    DimensConfiguration c, {
    StrategyOptions options = const StrategyOptions(),
  }) => dynamic(DimensStrategy.fit, c, options: options);
  double fluidDp(
    DimensConfiguration c, {
    StrategyOptions options = const StrategyOptions(),
  }) => dynamic(DimensStrategy.fluid, c, options: options);
  double interpolatedDp(
    DimensConfiguration c, {
    StrategyOptions options = const StrategyOptions(),
  }) => dynamic(DimensStrategy.interpolated, c, options: options);
  double logarithmicDp(
    DimensConfiguration c, {
    StrategyOptions options = const StrategyOptions(),
  }) => dynamic(DimensStrategy.logarithmic, c, options: options);
  double percentDp(
    DimensConfiguration c, {
    required double percent,
    DpQualifier qualifier = DpQualifier.smallWidth,
  }) => dynamic(
    DimensStrategy.percent,
    c,
    options: StrategyOptions(qualifier: qualifier, percent: percent),
  );
  double perimeterDp(
    DimensConfiguration c, {
    StrategyOptions options = const StrategyOptions(),
  }) => dynamic(DimensStrategy.perimeter, c, options: options);
  double powerDp(
    DimensConfiguration c, {
    StrategyOptions options = const StrategyOptions(),
  }) => dynamic(DimensStrategy.power, c, options: options);
}
