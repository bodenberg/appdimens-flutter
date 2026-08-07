import 'package:flutter/widgets.dart';

import 'appdimens_scale.dart';
import 'appdimens_types.dart';
import 'models/base_orientation.dart';
import 'utils/orientation_resolver.dart';

/// Compatibility builder backed by the new allocation-light engine.
///
/// Overrides are resolved in this order: intersection, UI mode, device,
/// explicit dp qualifier, device-size qualifier, screen qualifier, algorithm.
abstract class AppDimensBuilder<T extends AppDimensBuilder<T>> {
  AppDimensBuilder(
    this.initialValue,
    this.strategy, {
    this.ignoreMultiWindowAdjustment = false,
  });

  final double initialValue;
  final AppDimensStrategy strategy;
  final bool ignoreMultiWindowAdjustment;
  BaseOrientation _baseOrientation = BaseOrientation.auto;
  ScreenType _screenType = ScreenType.lowest;
  bool _cacheEnabled = true;
  Size? _cachedSize;
  double? _cachedValue;
  final Map<UiModeType, double> _ui = {};
  final Map<DeviceType, double> _devices = {};
  final Map<DpQualifier, double> _dp = {};
  final Map<ScreenQualifier, double> _screens = {};
  final List<_SizedOverride> _sized = [];
  final List<_IntersectionOverride> _intersections = [];

  T get _self => this as T;

  T screen(UiModeType type, double value) => uiMode(type, value);
  T uiMode(UiModeType type, double value) {
    _ui[type] = value;
    return clearCache();
  }

  T deviceType(DeviceType type, double value) {
    _devices[type] = value;
    return clearCache();
  }

  T screenWithSize(DeviceType type, double minimumWidth, double value) {
    _sized.add(_SizedOverride(type, minimumWidth, value));
    _sized.sort((a, b) => b.minimumWidth.compareTo(a.minimumWidth));
    return clearCache();
  }

  T screenWithQualifier(DpQualifier qualifier, int minimumWidth, double value) {
    _dp[qualifier] = value;
    return clearCache();
  }

  T dpQualifier(DpQualifier qualifier, double value) {
    _dp[qualifier] = value;
    return clearCache();
  }

  T screenQualifier(ScreenQualifier qualifier, double value) {
    _screens[qualifier] = value;
    return clearCache();
  }

  T screenWithIntersection(
    UiModeType mode,
    DpQualifier qualifier,
    int minimumWidth,
    double value,
  ) {
    _intersections.add(
      _IntersectionOverride(mode, minimumWidth.toDouble(), value),
    );
    _intersections.sort((a, b) => b.minimumWidth.compareTo(a.minimumWidth));
    return clearCache();
  }

  T intersection(UiModeType mode, DpQualifier qualifier, double value) =>
      screenWithIntersection(
        mode,
        qualifier,
        _qualifierWidth(qualifier),
        value,
      );

  T baseOrientation(BaseOrientation orientation) {
    _baseOrientation = orientation;
    return clearCache();
  }

  T screenType(ScreenType type) {
    _screenType = type;
    return clearCache();
  }

  T portraitLowest() =>
      baseOrientation(BaseOrientation.portrait).screenType(ScreenType.lowest);
  T portraitHighest() =>
      baseOrientation(BaseOrientation.portrait).screenType(ScreenType.highest);
  T landscapeLowest() =>
      baseOrientation(BaseOrientation.landscape).screenType(ScreenType.lowest);
  T landscapeHighest() =>
      baseOrientation(BaseOrientation.landscape).screenType(ScreenType.highest);

  T cache(bool enabled) {
    _cacheEnabled = enabled;
    return enabled ? _self : clearCache();
  }

  T clearCache() {
    _cachedSize = null;
    _cachedValue = null;
    return _self;
  }

  double calculate(BuildContext context) {
    final media = MediaQuery.of(context);
    if (_cacheEnabled && media.size == _cachedSize) return _cachedValue!;
    final result = calculateViewport(
      AppDimensViewport.fromMediaQuery(media),
      deviceType: DeviceType.current(context),
      uiModeType: UiModeType.current(context),
    );
    if (_cacheEnabled) {
      _cachedSize = media.size;
      _cachedValue = result;
    }
    return result;
  }

  double calculateWithoutCache(BuildContext context) {
    final media = MediaQuery.of(context);
    return calculateViewport(
      AppDimensViewport.fromMediaQuery(media),
      deviceType: DeviceType.current(context),
      uiModeType: UiModeType.current(context),
    );
  }

  double calculateViewport(
    AppDimensViewport viewport, {
    DeviceType deviceType = DeviceType.unknown,
    UiModeType uiModeType = UiModeType.normal,
  }) {
    final shortest = viewport.shortestSide;
    for (final rule in _intersections) {
      if (rule.mode == uiModeType && shortest >= rule.minimumWidth) {
        return rule.value;
      }
    }
    final uiValue = _ui[uiModeType];
    if (uiValue != null) return uiValue;
    final deviceValue = _devices[deviceType];
    if (deviceValue != null) return deviceValue;
    final qualifier = qualifierFor(shortest);
    final dpValue = _dp[qualifier];
    if (dpValue != null) return dpValue;
    for (final rule in _sized) {
      if (rule.device == deviceType && shortest >= rule.minimumWidth) {
        return rule.value;
      }
    }
    final screenValue = _screens[screenQualifierFor(viewport)];
    if (screenValue != null) return screenValue;

    final effective = OrientationResolver.resolveWithDimensions(
      requestedType: _screenType,
      baseOrientation: _baseOrientation,
      width: viewport.width,
      height: viewport.height,
    );
    final axis = effective == ScreenType.lowest
        ? (viewport.width <= viewport.height ? Axis.horizontal : Axis.vertical)
        : (viewport.width >= viewport.height ? Axis.horizontal : Axis.vertical);
    return AppDimensScale(
      initialValue,
      strategy: strategy,
      axis: axis,
      designSize: const Size(360, 800),
    ).calculateViewport(viewport);
  }

  double toDp(BuildContext context) => calculate(context);
  int toDpInt(BuildContext context) => calculate(context).round();
  double toPx(BuildContext context) =>
      calculate(context) * MediaQuery.of(context).devicePixelRatio;
  int toPxInt(BuildContext context) => toPx(context).round();
  double toSp(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(calculate(context));
  int toSpInt(BuildContext context) => toSp(context).round();
  double toEm(BuildContext context) => calculate(context);
  int toEmInt(BuildContext context) => calculate(context).round();

  static DpQualifier qualifierFor(double width) {
    if (width >= 960) return DpQualifier.smallestWidth960;
    if (width >= 840) return DpQualifier.smallestWidth840;
    if (width >= 720) return DpQualifier.smallestWidth720;
    if (width >= 600) return DpQualifier.smallestWidth600;
    if (width >= 480) return DpQualifier.smallestWidth480;
    if (width >= 360) return DpQualifier.smallestWidth360;
    if (width >= 320) return DpQualifier.smallestWidth320;
    if (width >= 240) return DpQualifier.smallestWidth240;
    return DpQualifier.smallestWidth160;
  }

  static ScreenQualifier screenQualifierFor(AppDimensViewport viewport) {
    final w = viewport.width;
    final h = viewport.height;
    if (w >= 1920 && h >= 1080) return ScreenQualifier.w1920h1080;
    if (w >= 1600 && h >= 900) return ScreenQualifier.w1600h900;
    if (w >= 1440 && h >= 900) return ScreenQualifier.w1440h900;
    if (w >= 1280 && h >= 800) return ScreenQualifier.w1280h800;
    if (w >= 1024 && h >= 768) return ScreenQualifier.w1024h768;
    if (w >= 800 && h >= 600) return ScreenQualifier.w800h600;
    if (w >= 640 && h >= 480) return ScreenQualifier.w640h480;
    return ScreenQualifier.w320h240;
  }

  static int _qualifierWidth(DpQualifier qualifier) => switch (qualifier) {
    DpQualifier.smallestWidth160 => 160,
    DpQualifier.smallestWidth240 => 240,
    DpQualifier.smallestWidth320 => 320,
    DpQualifier.smallestWidth360 => 360,
    DpQualifier.smallestWidth480 => 480,
    DpQualifier.smallestWidth600 => 600,
    DpQualifier.smallestWidth720 => 720,
    DpQualifier.smallestWidth840 => 840,
    DpQualifier.smallestWidth960 => 960,
  };
}

class _SizedOverride {
  const _SizedOverride(this.device, this.minimumWidth, this.value);
  final DeviceType device;
  final double minimumWidth;
  final double value;
}

class _IntersectionOverride {
  const _IntersectionOverride(this.mode, this.minimumWidth, this.value);
  final UiModeType mode;
  final double minimumWidth;
  final double value;
}
