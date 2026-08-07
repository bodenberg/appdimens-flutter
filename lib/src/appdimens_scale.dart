import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The thirteen algorithms exposed by AppDimens Dynamic.
enum AppDimensStrategy {
  balanced,
  percentage,
  defaultScaling,
  logarithmic,
  power,
  fluid,
  interpolated,
  diagonal,
  perimeter,
  fit,
  fill,
  autosize,
  none,
}

enum ElementType { spacing, icon, text, button, container, radius }

/// All environmental input consumed by the calculation engine.
///
/// Keeping this value independent from Flutter's widget tree makes the hot
/// path deterministic and directly benchmarkable on every Dart platform.
@immutable
class AppDimensViewport {
  const AppDimensViewport({
    required this.width,
    required this.height,
    this.devicePixelRatio = 1,
    this.textScaleFactor = 1,
  })  : assert(width >= 0),
        assert(height >= 0),
        assert(devicePixelRatio > 0),
        assert(textScaleFactor > 0);

  factory AppDimensViewport.fromMediaQuery(MediaQueryData data) =>
      AppDimensViewport(
        width: data.size.width,
        height: data.size.height,
        devicePixelRatio: data.devicePixelRatio,
        textScaleFactor: data.textScaler.scale(1),
      );

  final double width;
  final double height;
  final double devicePixelRatio;
  final double textScaleFactor;

  double get shortestSide => math.min(width, height);
  double get longestSide => math.max(width, height);
  double get diagonal => math.sqrt(width * width + height * height);
  double get perimeter => 2 * (width + height);
  bool get isEmpty => width <= 0 || height <= 0;
}

/// Immutable configuration and calculation object.
@immutable
class AppDimensScale {
  const AppDimensScale(
    this.value, {
    required this.strategy,
    this.designSize = const Size(360, 800),
    this.axis = Axis.horizontal,
    this.exponent = .75,
    this.minValue,
    this.maxValue,
    this.minWidth = 320,
    this.maxWidth = 1440,
  })  : assert(value.isFinite),
        assert(designSize.width > 0 && designSize.height > 0),
        assert(exponent > 0),
        assert(minWidth < maxWidth);

  final double value;
  final AppDimensStrategy strategy;
  final Size designSize;
  final Axis axis;
  final double exponent;
  final double? minValue;
  final double? maxValue;
  final double minWidth;
  final double maxWidth;

  AppDimensScale forElement(ElementType element) => copyWith(
        strategy: switch (element) {
          ElementType.container => AppDimensStrategy.percentage,
          ElementType.text => AppDimensStrategy.fluid,
          ElementType.spacing || ElementType.radius =>
            AppDimensStrategy.balanced,
          ElementType.icon || ElementType.button =>
            AppDimensStrategy.logarithmic,
        },
      );

  AppDimensScale copyWith({
    AppDimensStrategy? strategy,
    Size? designSize,
    Axis? axis,
    double? exponent,
    double? minValue,
    double? maxValue,
    double? minWidth,
    double? maxWidth,
  }) =>
      AppDimensScale(
        value,
        strategy: strategy ?? this.strategy,
        designSize: designSize ?? this.designSize,
        axis: axis ?? this.axis,
        exponent: exponent ?? this.exponent,
        minValue: minValue ?? this.minValue,
        maxValue: maxValue ?? this.maxValue,
        minWidth: minWidth ?? this.minWidth,
        maxWidth: maxWidth ?? this.maxWidth,
      );

  double calculate(BuildContext context) =>
      calculateViewport(AppDimensViewport.fromMediaQuery(MediaQuery.of(context)));

  double calculateFor(Size size) => calculateViewport(
        AppDimensViewport(width: size.width, height: size.height),
      );

  double calculateViewport(AppDimensViewport viewport) {
    if (viewport.isEmpty ||
        !viewport.width.isFinite ||
        !viewport.height.isFinite) {
      return value;
    }
    final wr = viewport.width / designSize.width;
    final hr = viewport.height / designSize.height;
    final shortestRatio = viewport.shortestSide /
        math.min(designSize.width, designSize.height);
    final raw = switch (strategy) {
      AppDimensStrategy.balanced => value * math.sqrt(wr * hr),
      AppDimensStrategy.percentage =>
        (axis == Axis.horizontal ? viewport.width : viewport.height) *
            value /
            100,
      AppDimensStrategy.defaultScaling =>
        value * (axis == Axis.horizontal ? wr : hr),
      AppDimensStrategy.logarithmic =>
        value * (1 + math.log(math.max(shortestRatio, .01))),
      AppDimensStrategy.power =>
        value * math.pow(shortestRatio, exponent),
      AppDimensStrategy.fluid => _fluid(viewport.width),
      AppDimensStrategy.interpolated => value * (wr + hr) / 2,
      AppDimensStrategy.diagonal =>
        value * viewport.diagonal / _designDiagonal,
      AppDimensStrategy.perimeter =>
        value * viewport.perimeter / _designPerimeter,
      AppDimensStrategy.fit => value * math.min(wr, hr),
      AppDimensStrategy.fill => value * math.max(wr, hr),
      AppDimensStrategy.autosize =>
        value * _autosizeFactor(viewport.shortestSide),
      AppDimensStrategy.none => value,
    };
    return raw
        .clamp(minValue ?? -double.maxFinite, maxValue ?? double.maxFinite)
        .toDouble();
  }

  double get _designDiagonal => math.sqrt(
        designSize.width * designSize.width +
            designSize.height * designSize.height,
      );
  double get _designPerimeter => 2 * (designSize.width + designSize.height);

  double _fluid(double width) {
    final low = minValue ?? value;
    final high = maxValue ?? value;
    final t = ((width - minWidth) / (maxWidth - minWidth))
        .clamp(0.0, 1.0)
        .toDouble();
    return low + (high - low) * t;
  }

  double _autosizeFactor(double shortestSide) {
    if (shortestSide < 360) return .9;
    if (shortestSide < 600) return 1;
    if (shortestSide < 840) return 1.15;
    if (shortestSide < 1200) return 1.3;
    return 1.45;
  }
}
