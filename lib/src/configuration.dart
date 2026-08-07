import 'dart:math' as math;

import 'package:flutter/widgets.dart';

enum DpQualifier { smallWidth, height, width }

enum DimensOrientation { portrait, landscape }

enum UiModeType {
  normal,
  television,
  car,
  watch,
  desk,
  appliance,
  vision,
  mac,
  undefined,
}

enum Inverter {
  phToLw,
  pwToLh,
  lhToPw,
  lwToPh,
  swToLh,
  swToLw,
  swToPh,
  swToPw,
  standard,
}

@immutable
class DimensConfiguration {
  const DimensConfiguration({
    required this.screenWidth,
    required this.screenHeight,
    this.displayScale = 1,
    this.fontScale = 1,
    this.uiMode = UiModeType.undefined,
    double? maximumWindowWidth,
    double? maximumWindowHeight,
  }) : assert(screenWidth > 0),
       assert(screenHeight > 0),
       assert(displayScale > 0),
       assert(fontScale > 0),
       maximumWindowWidth = maximumWindowWidth ?? screenWidth,
       maximumWindowHeight = maximumWindowHeight ?? screenHeight;

  factory DimensConfiguration.fromMediaQuery(
    MediaQueryData data, {
    UiModeType uiMode = UiModeType.undefined,
    Size? maximumWindowSize,
  }) => DimensConfiguration(
    screenWidth: data.size.width,
    screenHeight: data.size.height,
    displayScale: data.devicePixelRatio,
    fontScale: data.textScaler.scale(1),
    uiMode: uiMode,
    maximumWindowWidth: maximumWindowSize?.width,
    maximumWindowHeight: maximumWindowSize?.height,
  );

  final double screenWidth, screenHeight, displayScale, fontScale;
  final UiModeType uiMode;
  final double maximumWindowWidth, maximumWindowHeight;
  double get smallestScreenWidth => math.min(screenWidth, screenHeight);
  DimensOrientation get orientation => screenWidth > screenHeight
      ? DimensOrientation.landscape
      : DimensOrientation.portrait;
  double get aspectRatio =>
      math.max(screenWidth, screenHeight) / smallestScreenWidth;
  bool get isMultiWindow =>
      screenWidth < maximumWindowWidth * .95 ||
      screenHeight < maximumWindowHeight * .95;

  double dimension(
    DpQualifier qualifier, {
    Inverter inverter = Inverter.standard,
  }) {
    var effective = qualifier;
    if (orientation == DimensOrientation.landscape) {
      if (inverter == Inverter.phToLw && qualifier == DpQualifier.height) {
        effective = DpQualifier.width;
      }
      if (inverter == Inverter.pwToLh && qualifier == DpQualifier.width) {
        effective = DpQualifier.height;
      }
      if (inverter == Inverter.swToLh && qualifier == DpQualifier.smallWidth) {
        effective = DpQualifier.height;
      }
      if (inverter == Inverter.swToLw && qualifier == DpQualifier.smallWidth) {
        effective = DpQualifier.width;
      }
    } else {
      if (inverter == Inverter.lhToPw && qualifier == DpQualifier.height) {
        effective = DpQualifier.width;
      }
      if (inverter == Inverter.lwToPh && qualifier == DpQualifier.width) {
        effective = DpQualifier.height;
      }
      if (inverter == Inverter.swToPh && qualifier == DpQualifier.smallWidth) {
        effective = DpQualifier.height;
      }
      if (inverter == Inverter.swToPw && qualifier == DpQualifier.smallWidth) {
        effective = DpQualifier.width;
      }
    }
    return switch (effective) {
      DpQualifier.smallWidth => smallestScreenWidth,
      DpQualifier.height => screenHeight,
      DpQualifier.width => screenWidth,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is DimensConfiguration &&
      screenWidth == other.screenWidth &&
      screenHeight == other.screenHeight &&
      displayScale == other.displayScale &&
      fontScale == other.fontScale &&
      uiMode == other.uiMode &&
      maximumWindowWidth == other.maximumWindowWidth &&
      maximumWindowHeight == other.maximumWindowHeight;
  @override
  int get hashCode => Object.hash(
    screenWidth,
    screenHeight,
    displayScale,
    fontScale,
    uiMode,
    maximumWindowWidth,
    maximumWindowHeight,
  );
}
