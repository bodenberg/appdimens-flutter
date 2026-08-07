import 'package:flutter/widgets.dart';

import 'appdimens_dynamic.dart';
import 'appdimens_fixed.dart';
import 'appdimens_fluid.dart';
import 'appdimens_scale.dart';

extension AppDimensNumExtension on num {
  double get _value => toDouble();
  AppDimensFixed get fx => AppDimensFixed(_value);
  AppDimensDynamic get dy => AppDimensDynamic(_value);
  AppDimensFixed get fxIgnoreMultiWindow =>
      AppDimensFixed(_value, ignoreMultiWindowAdjustment: true);
  AppDimensDynamic get dyIgnoreMultiWindow =>
      AppDimensDynamic(_value, ignoreMultiWindowAdjustment: true);

  AppDimensScale balanced({Size designSize = const Size(360, 800)}) =>
      AppDimensScale(_value,
          strategy: AppDimensStrategy.balanced, designSize: designSize);
  AppDimensScale defaultScaling(
          {Size designSize = const Size(360, 800),
          Axis axis = Axis.horizontal}) =>
      AppDimensScale(_value,
          strategy: AppDimensStrategy.defaultScaling,
          designSize: designSize,
          axis: axis);
  AppDimensScale percentage({Axis axis = Axis.horizontal}) => AppDimensScale(
      _value,
      strategy: AppDimensStrategy.percentage,
      axis: axis);
  AppDimensScale logarithmic({Size designSize = const Size(360, 800)}) =>
      AppDimensScale(_value,
          strategy: AppDimensStrategy.logarithmic, designSize: designSize);
  AppDimensScale power(
          {double exponent = .75,
          Size designSize = const Size(360, 800)}) =>
      AppDimensScale(_value,
          strategy: AppDimensStrategy.power,
          exponent: exponent,
          designSize: designSize);
  AppDimensScale interpolated({Size designSize = const Size(360, 800)}) =>
      AppDimensScale(_value,
          strategy: AppDimensStrategy.interpolated, designSize: designSize);
  AppDimensScale diagonal({Size designSize = const Size(360, 800)}) =>
      AppDimensScale(_value,
          strategy: AppDimensStrategy.diagonal, designSize: designSize);
  AppDimensScale perimeter({Size designSize = const Size(360, 800)}) =>
      AppDimensScale(_value,
          strategy: AppDimensStrategy.perimeter, designSize: designSize);
  AppDimensScale fit({Size designSize = const Size(360, 800)}) =>
      AppDimensScale(_value,
          strategy: AppDimensStrategy.fit, designSize: designSize);
  AppDimensScale fill({Size designSize = const Size(360, 800)}) =>
      AppDimensScale(_value,
          strategy: AppDimensStrategy.fill, designSize: designSize);
  AppDimensScale autosize({Size designSize = const Size(360, 800)}) =>
      AppDimensScale(_value,
          strategy: AppDimensStrategy.autosize, designSize: designSize);
  AppDimensScale none() =>
      AppDimensScale(_value, strategy: AppDimensStrategy.none);

  AppDimensFluid fluidTo(double maximum,
          {double minWidth = 320, double maxWidth = 768}) =>
      AppDimensFluid(_value, maximum,
          minWidth: minWidth, maxWidth: maxWidth);
  AppDimensFluid fluidFrom(double minimum,
          {double minWidth = 320, double maxWidth = 768}) =>
      AppDimensFluid(minimum, _value,
          minWidth: minWidth, maxWidth: maxWidth);
}

extension AppDimensWidgetExtension on Widget {
  Widget fxPadding(double value, BuildContext context) => Padding(
      padding: EdgeInsets.all(AppDimensFixed(value).calculate(context)),
      child: this);
  Widget dyPadding(double value, BuildContext context) => Padding(
      padding: EdgeInsets.all(AppDimensDynamic(value).calculate(context)),
      child: this);
  Widget fxMargin(double value, BuildContext context) => Container(
      margin: EdgeInsets.all(AppDimensFixed(value).calculate(context)),
      child: this);
  Widget dyMargin(double value, BuildContext context) => Container(
      margin: EdgeInsets.all(AppDimensDynamic(value).calculate(context)),
      child: this);
  Widget fxBorderRadius(double value, BuildContext context) => ClipRRect(
      borderRadius:
          BorderRadius.circular(AppDimensFixed(value).calculate(context)),
      child: this);
  Widget dyBorderRadius(double value, BuildContext context) => ClipRRect(
      borderRadius:
          BorderRadius.circular(AppDimensDynamic(value).calculate(context)),
      child: this);
  Widget fluidPadding(double minimum, double maximum, BuildContext context) =>
      Padding(
          padding: EdgeInsets.all(
              AppDimensFluid(minimum, maximum).calculate(context)),
          child: this);
  Widget fluidMargin(double minimum, double maximum, BuildContext context) =>
      Container(
          margin: EdgeInsets.all(
              AppDimensFluid(minimum, maximum).calculate(context)),
          child: this);
  Widget fluidBorderRadius(
          double minimum, double maximum, BuildContext context) =>
      ClipRRect(
          borderRadius: BorderRadius.circular(
              AppDimensFluid(minimum, maximum).calculate(context)),
          child: this);
}

extension AppDimensTextStyleExtension on TextStyle {
  TextStyle fxFontSize(double value, BuildContext context) =>
      copyWith(fontSize: AppDimensFixed(value).calculate(context));
  TextStyle dyFontSize(double value, BuildContext context) =>
      copyWith(fontSize: AppDimensDynamic(value).calculate(context));
  TextStyle fluidFontSize(
          double minimum, double maximum, BuildContext context) =>
      copyWith(
          fontSize: AppDimensFluid(minimum, maximum).calculate(context));
}
