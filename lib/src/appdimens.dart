import 'package:flutter/widgets.dart';

import 'appdimens_dynamic.dart';
import 'appdimens_fixed.dart';
import 'appdimens_scale.dart';
import 'appdimens_types.dart';
import 'appdimens_utils.dart';

/// Public facade for AppDimens.
abstract final class AppDimens {
  static bool aspectRatioEnabled = true;
  static bool cacheEnabled = true;
  static bool ignoreMultiWindowAdjustment = false;

  static void configure({
    bool? aspectRatio,
    bool? cache,
    bool? ignoreMultiWindow,
  }) {
    aspectRatioEnabled = aspectRatio ?? aspectRatioEnabled;
    cacheEnabled = cache ?? cacheEnabled;
    ignoreMultiWindowAdjustment =
        ignoreMultiWindow ?? ignoreMultiWindowAdjustment;
  }

  static AppDimensFixed fixed(double value,
      {bool? ignoreMultiWindowAdjustment}) {
    final builder = AppDimensFixed(value,
        ignoreMultiWindowAdjustment: ignoreMultiWindowAdjustment ??
            AppDimens.ignoreMultiWindowAdjustment);
    return builder..cache(cacheEnabled);
  }

  static AppDimensDynamic dynamic(double value,
      {bool? ignoreMultiWindowAdjustment}) {
    final builder = AppDimensDynamic(value,
        ignoreMultiWindowAdjustment: ignoreMultiWindowAdjustment ??
            AppDimens.ignoreMultiWindowAdjustment);
    return builder..cache(cacheEnabled);
  }

  static AppDimensScale _scale(
    double value,
    AppDimensStrategy strategy, {
    Size designSize = const Size(360, 800),
    Axis axis = Axis.horizontal,
  }) =>
      AppDimensScale(value,
          strategy: strategy, designSize: designSize, axis: axis);

  static AppDimensScale balanced(double value,
          {Size designSize = const Size(360, 800)}) =>
      _scale(value, AppDimensStrategy.balanced, designSize: designSize);
  static AppDimensScale percentage(double value,
          {Axis axis = Axis.horizontal}) =>
      _scale(value, AppDimensStrategy.percentage, axis: axis);
  static AppDimensScale defaultScaling(double value,
          {Size designSize = const Size(360, 800),
          Axis axis = Axis.horizontal}) =>
      _scale(value, AppDimensStrategy.defaultScaling,
          designSize: designSize, axis: axis);
  static AppDimensScale logarithmic(double value,
          {Size designSize = const Size(360, 800)}) =>
      _scale(value, AppDimensStrategy.logarithmic, designSize: designSize);
  static AppDimensScale power(double value,
          {double exponent = .75,
          Size designSize = const Size(360, 800)}) =>
      AppDimensScale(value,
          strategy: AppDimensStrategy.power,
          exponent: exponent,
          designSize: designSize);
  static AppDimensScale fluid(double minValue,
          {required double maxValue,
          double minWidth = 320,
          double maxWidth = 1440}) =>
      AppDimensScale(minValue,
          strategy: AppDimensStrategy.fluid,
          minValue: minValue,
          maxValue: maxValue,
          minWidth: minWidth,
          maxWidth: maxWidth);
  static AppDimensScale interpolated(double value,
          {Size designSize = const Size(360, 800)}) =>
      _scale(value, AppDimensStrategy.interpolated, designSize: designSize);
  static AppDimensScale diagonal(double value,
          {Size designSize = const Size(360, 800)}) =>
      _scale(value, AppDimensStrategy.diagonal, designSize: designSize);
  static AppDimensScale perimeter(double value,
          {Size designSize = const Size(360, 800)}) =>
      _scale(value, AppDimensStrategy.perimeter, designSize: designSize);
  static AppDimensScale fit(double value,
          {Size designSize = const Size(360, 800)}) =>
      _scale(value, AppDimensStrategy.fit, designSize: designSize);
  static AppDimensScale fill(double value,
          {Size designSize = const Size(360, 800)}) =>
      _scale(value, AppDimensStrategy.fill, designSize: designSize);
  static AppDimensScale autosize(double value,
          {Size designSize = const Size(360, 800)}) =>
      _scale(value, AppDimensStrategy.autosize, designSize: designSize);
  static AppDimensScale none(double value) =>
      _scale(value, AppDimensStrategy.none);
  static AppDimensScale smart(double value) => balanced(value);

  static double dynamicPercentage(double percentage, BuildContext context,
      {ScreenType type = ScreenType.lowest}) {
    assert(percentage >= 0 && percentage <= 1);
    final size = MediaQuery.sizeOf(context);
    final dimension = type == ScreenType.lowest
        ? (size.width < size.height ? size.width : size.height)
        : (size.width > size.height ? size.width : size.height);
    return dimension * percentage;
  }

  static double dynamicPercentageDp(double percentage, BuildContext context,
          {ScreenType type = ScreenType.lowest}) =>
      dynamicPercentage(percentage, context, type: type);
  static double dynamicPercentagePx(double percentage, BuildContext context,
          {ScreenType type = ScreenType.lowest}) =>
      dynamicPercentage(percentage, context, type: type) *
      MediaQuery.devicePixelRatioOf(context);
  static double dynamicPercentageSp(double percentage, BuildContext context,
          {ScreenType type = ScreenType.lowest}) =>
      MediaQuery.textScalerOf(context)
          .scale(dynamicPercentage(percentage, context, type: type));

  static ScreenInfo getCurrentScreenInfo(BuildContext context) {
    final media = MediaQuery.of(context);
    return ScreenInfo(
      width: media.size.width,
      height: media.size.height,
      devicePixelRatio: media.devicePixelRatio,
      deviceType: DeviceType.current(context),
      uiModeType: UiModeType.current(context),
      orientation: media.orientation,
    );
  }

  static ScreenAdjustmentFactors calculateAdjustmentFactors(
          BuildContext context) =>
      AppDimensUtils.calculateAdjustmentFactors(context);

  @Deprecated('Use AppDimens.fixed')
  static AppDimensFixed fixedDp(double value) => fixed(value);
  @Deprecated('Use AppDimens.dynamic')
  static AppDimensDynamic dynamicDp(double value) => dynamic(value);
}
