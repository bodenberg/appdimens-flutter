import 'dart:math' as math;
import 'configuration.dart';

abstract final class AppDimens {
  static const baseRatio = 300.0;
  static const referenceHeight = 533.0;
  static const referenceAspectRatio = 1.78;

  static double dp(
    double value, {
    required DimensConfiguration configuration,
    DpQualifier qualifier = DpQualifier.smallWidth,
    Inverter inverter = Inverter.standard,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? sensitivity,
  }) {
    if (ignoreMultiWindows && configuration.isMultiWindow) return value;
    final dimension = configuration.dimension(qualifier, inverter: inverter);
    if (!applyAspectRatio) return value * dimension / baseRatio;
    final k = sensitivity ?? .10;
    final normalized = math.max(
      configuration.aspectRatio / referenceAspectRatio,
      .0001,
    );
    return value *
        (1 +
            (dimension - baseRatio) *
                (1 / baseRatio + k * math.log(normalized) / baseRatio));
  }

  static double sp(
    double value, {
    required DimensConfiguration configuration,
    DpQualifier qualifier = DpQualifier.smallWidth,
    bool fontScale = true,
    Inverter inverter = Inverter.standard,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? sensitivity,
  }) {
    final scaled = dp(
      value,
      configuration: configuration,
      qualifier: qualifier,
      inverter: inverter,
      ignoreMultiWindows: ignoreMultiWindows,
      applyAspectRatio: applyAspectRatio,
      sensitivity: sensitivity,
    );
    return fontScale ? scaled * configuration.fontScale : scaled;
  }

  static double rotate(
    double value, {
    required double rotationValue,
    required DimensConfiguration configuration,
    DpQualifier qualifier = DpQualifier.smallWidth,
    DimensOrientation orientation = DimensOrientation.landscape,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
  }) => dp(
    configuration.orientation == orientation ? rotationValue : value,
    configuration: configuration,
    qualifier: qualifier,
    ignoreMultiWindows: ignoreMultiWindows,
    applyAspectRatio: applyAspectRatio,
  );
  static double qualified(
    double value, {
    required double qualifiedValue,
    required DimensConfiguration configuration,
    required DpQualifier qualifier,
    required double minimum,
    DpQualifier finalQualifier = DpQualifier.smallWidth,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
  }) => dp(
    configuration.dimension(qualifier) >= minimum ? qualifiedValue : value,
    configuration: configuration,
    qualifier: finalQualifier,
    ignoreMultiWindows: ignoreMultiWindows,
    applyAspectRatio: applyAspectRatio,
  );
  static double mode(
    double value, {
    required double modeValue,
    required UiModeType mode,
    required DimensConfiguration configuration,
    DpQualifier qualifier = DpQualifier.smallWidth,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
  }) => dp(
    configuration.uiMode == mode ? modeValue : value,
    configuration: configuration,
    qualifier: qualifier,
    ignoreMultiWindows: ignoreMultiWindows,
    applyAspectRatio: applyAspectRatio,
  );
}

abstract final class AppDimensPlain {
  static double rotate(
    double value, {
    required double branch,
    required DimensOrientation orientation,
    required DimensConfiguration configuration,
  }) => configuration.orientation == orientation ? branch : value;
  static double mode(
    double value, {
    required double branch,
    required UiModeType mode,
    required DimensConfiguration configuration,
  }) => configuration.uiMode == mode ? branch : value;
  static double qualifier(
    double value, {
    required double branch,
    required DpQualifier qualifier,
    required double minimum,
    required DimensConfiguration configuration,
  }) => configuration.dimension(qualifier) >= minimum ? branch : value;
  static double screen(
    double value, {
    required double branch,
    required UiModeType mode,
    required DpQualifier qualifier,
    required double minimum,
    required DimensConfiguration configuration,
  }) =>
      configuration.uiMode == mode &&
          configuration.dimension(qualifier) >= minimum
      ? branch
      : value;
}

class _ScaledEntry {
  const _ScaledEntry(
    this.value, {
    this.mode,
    this.orientation,
    this.qualifier,
    this.minimum = 0,
  });
  final double value, minimum;
  final UiModeType? mode;
  final DimensOrientation? orientation;
  final DpQualifier? qualifier;
}

class ScaledDp {
  const ScaledDp(this.value)
    : _entries = const [],
      applyAspectRatio = false,
      ignoreMultiWindow = false;
  const ScaledDp._(
    this.value,
    this._entries,
    this.applyAspectRatio,
    this.ignoreMultiWindow,
  );
  final double value;
  final List<_ScaledEntry> _entries;
  final bool applyAspectRatio, ignoreMultiWindow;
  ScaledDp screen(
    double value, {
    required DpQualifier qualifier,
    required double minimum,
  }) => _copy(
    entry: _ScaledEntry(value, qualifier: qualifier, minimum: minimum),
  );
  ScaledDp mode(double value, UiModeType mode) =>
      _copy(entry: _ScaledEntry(value, mode: mode));
  ScaledDp rotate(
    double value, [
    DimensOrientation orientation = DimensOrientation.landscape,
  ]) => _copy(entry: _ScaledEntry(value, orientation: orientation));
  ScaledDp aspectRatio([bool enabled = true]) =>
      ScaledDp._(value, _entries, enabled, ignoreMultiWindow);
  ScaledDp ignoreMultiWindows([bool enabled = true]) =>
      ScaledDp._(value, _entries, applyAspectRatio, enabled);
  ScaledDp _copy({required _ScaledEntry entry}) => ScaledDp._(
    value,
    List.unmodifiable([..._entries, entry]),
    applyAspectRatio,
    ignoreMultiWindow,
  );
  double resolve(
    DimensConfiguration configuration, {
    DpQualifier qualifier = DpQualifier.smallWidth,
  }) {
    var selected = value;
    for (final e in _entries) {
      if (e.mode != null && e.mode == configuration.uiMode) {
        selected = e.value;
      } else if (e.orientation != null &&
          e.orientation == configuration.orientation) {
        selected = e.value;
      } else if (e.qualifier != null &&
          configuration.dimension(e.qualifier!) >= e.minimum) {
        selected = e.value;
      }
    }
    return AppDimens.dp(
      selected,
      configuration: configuration,
      qualifier: qualifier,
      ignoreMultiWindows: ignoreMultiWindow,
      applyAspectRatio: applyAspectRatio,
    );
  }
}

extension AppDimensScaledNum on num {
  ScaledDp get scaledDp => ScaledDp(toDouble());
  double sdp(DimensConfiguration c) =>
      AppDimens.dp(toDouble(), configuration: c);
  double sdpa(DimensConfiguration c) =>
      AppDimens.dp(toDouble(), configuration: c, applyAspectRatio: true);
  double sdpi(DimensConfiguration c) =>
      AppDimens.dp(toDouble(), configuration: c, ignoreMultiWindows: true);
  double sdpia(DimensConfiguration c) => AppDimens.dp(
    toDouble(),
    configuration: c,
    ignoreMultiWindows: true,
    applyAspectRatio: true,
  );
  double hdp(DimensConfiguration c) =>
      AppDimens.dp(toDouble(), configuration: c, qualifier: DpQualifier.height);
  double wdp(DimensConfiguration c) =>
      AppDimens.dp(toDouble(), configuration: c, qualifier: DpQualifier.width);
  double ssp(DimensConfiguration c) =>
      AppDimens.sp(toDouble(), configuration: c);
  double hsp(DimensConfiguration c) =>
      AppDimens.sp(toDouble(), configuration: c, qualifier: DpQualifier.height);
  double wsp(DimensConfiguration c) =>
      AppDimens.sp(toDouble(), configuration: c, qualifier: DpQualifier.width);
  double sem(DimensConfiguration c) =>
      AppDimens.sp(toDouble(), configuration: c, fontScale: false);
  double hem(DimensConfiguration c) => AppDimens.sp(
    toDouble(),
    configuration: c,
    qualifier: DpQualifier.height,
    fontScale: false,
  );
  double wem(DimensConfiguration c) => AppDimens.sp(
    toDouble(),
    configuration: c,
    qualifier: DpQualifier.width,
    fontScale: false,
  );
  double hdpa(DimensConfiguration c) => AppDimens.dp(
    toDouble(),
    configuration: c,
    qualifier: DpQualifier.height,
    applyAspectRatio: true,
  );
  double hdpi(DimensConfiguration c) => AppDimens.dp(
    toDouble(),
    configuration: c,
    qualifier: DpQualifier.height,
    ignoreMultiWindows: true,
  );
  double hdpia(DimensConfiguration c) => AppDimens.dp(
    toDouble(),
    configuration: c,
    qualifier: DpQualifier.height,
    ignoreMultiWindows: true,
    applyAspectRatio: true,
  );
  double wdpa(DimensConfiguration c) => AppDimens.dp(
    toDouble(),
    configuration: c,
    qualifier: DpQualifier.width,
    applyAspectRatio: true,
  );
  double wdpi(DimensConfiguration c) => AppDimens.dp(
    toDouble(),
    configuration: c,
    qualifier: DpQualifier.width,
    ignoreMultiWindows: true,
  );
  double wdpia(DimensConfiguration c) => AppDimens.dp(
    toDouble(),
    configuration: c,
    qualifier: DpQualifier.width,
    ignoreMultiWindows: true,
    applyAspectRatio: true,
  );
}
