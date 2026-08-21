/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Explicit-context variants (`sdpOf(context)` family) and the Java-style
/// facades (`DimenSdp` / `DimenSsp`).
import '../common/dp_qualifier.dart';
import '../common/inverter.dart';
import 'dimen_scaled_builder.dart';
import '../core/app_dimens_context.dart';
import '../core/dimen_cache.dart';
import '../core/dimen_scaled_engine.dart';

/// EN: Explicit-context Scaled resolution. Use when no `AppDimensProvider`
/// is available (tests, background isolates, pre-animation code):
/// ```dart
/// final pad = 16.sdpOf(context);
/// ```
///
/// PT: Resolução Scaled com contexto explícito. Use quando não houver
/// `AppDimensProvider` (testes, isolates em segundo plano, código pré-frame):
/// ```dart
/// final pad = 16.sdpOf(context);
/// ```
extension AppDimensScaledContext on num {
  double sdpOf(AppDimensContext context) =>
      _ctx(context, DpQualifier.smallWidth, applyAspectRatio: false);

  double sdpaOf(AppDimensContext context) =>
      _ctx(context, DpQualifier.smallWidth, applyAspectRatio: true);

  double sdpiOf(AppDimensContext context) =>
      _ctx(context, DpQualifier.smallWidth, ignoreMultiWindows: true);

  double sdpiaOf(AppDimensContext context) =>
      _ctx(context, DpQualifier.smallWidth,
          ignoreMultiWindows: true, applyAspectRatio: true);

  double hdpOf(AppDimensContext context) =>
      _ctx(context, DpQualifier.height, applyAspectRatio: false);

  double hdpaOf(AppDimensContext context) =>
      _ctx(context, DpQualifier.height, applyAspectRatio: true);

  double wdpOf(AppDimensContext context) =>
      _ctx(context, DpQualifier.width, applyAspectRatio: false);

  double wdpaOf(AppDimensContext context) =>
      _ctx(context, DpQualifier.width, applyAspectRatio: true);

  /// Physical-pixel twin of [sdpOf].
  double sdpPxOf(AppDimensContext context) =>
      sdpOf(context) * context.dimenMetrics.density;

  /// Physical-pixel twin of [hdpOf].
  double hdpPxOf(AppDimensContext context) =>
      hdpOf(context) * context.dimenMetrics.density;

  /// Physical-pixel twin of [wdpOf].
  double wdpPxOf(AppDimensContext context) =>
      wdpOf(context) * context.dimenMetrics.density;

  /// Generic full-parameter scaled dp.
  double toDynamicScaledDp(
    AppDimensContext context,
    DpQualifier qualifier, {
    Inverter inverter = Inverter.standard,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) =>
      DimenScaledEngine.resolveScaledDp(toDouble(), context, qualifier,
          inverter: inverter,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK);

  /// Generic full-parameter scaled px.
  double toDynamicScaledPx(
    AppDimensContext context,
    DpQualifier qualifier, {
    Inverter inverter = Inverter.standard,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) =>
      DimenScaledEngine.resolveScaledPx(toDouble(), context, qualifier,
          inverter: inverter,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK);

  double _ctx(
    AppDimensContext context,
    DpQualifier qualifier, {
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
  }) =>
      DimenScaledEngine.resolveScaledDp(toDouble(), context, qualifier,
              ignoreMultiWindows: ignoreMultiWindows,
              applyAspectRatio: applyAspectRatio)
          .toDouble();
}

/// EN: Sp explicit-context variants (`sspOf(context)` …).
///
/// PT: Variantes sp com contexto explícito (`sspOf(context)` …).
extension AppDimensSpContext on num {
  /// Scaled sp; the framework applies the font scale at render.
  double sspOf(AppDimensContext context, {bool fontScale = true}) =>
      DimenScaledEngine.resolveScaledSpValue(
          toDouble(), context, DpQualifier.smallWidth,
          fontScale: fontScale);

  double hspOf(AppDimensContext context, {bool fontScale = true}) =>
      DimenScaledEngine.resolveScaledSpValue(
          toDouble(), context, DpQualifier.height,
          fontScale: fontScale);

  double wspOf(AppDimensContext context, {bool fontScale = true}) =>
      DimenScaledEngine.resolveScaledSpValue(
          toDouble(), context, DpQualifier.width,
          fontScale: fontScale);

  /// Rendered physical pixels of a scaled sp value.
  double sspPxOf(AppDimensContext context, {bool fontScale = true}) =>
      DimenScaledEngine.resolveScaledSpPx(
          toDouble(), context, DpQualifier.smallWidth,
          fontScale: fontScale);
}

/// EN: Static facade mirroring the Kotlin `object DimenSdp` code API — handy
/// for non-extension call sites and for Java-like usage.
///
/// PT: Fachada estática espelhando o `object DimenSdp` do Kotlin — útil fora
/// de pontos de chamada por extensão.
abstract final class DimenSdp {
  /// Warm-up: publishes [context] as fallback metrics eagerly so the first
  /// hot-path frame pays no lazy initialization.
  static void warmupCache(AppDimensContext context) {
    AppDimensScope.publish(context.dimenMetrics);
    AppDimensScope.publishContext(context);
    AppDimensScope.publishUiModeType(context.uiModeType);
  }

  /// Starts the [DimenScaled] builder chain from [value].
  static DimenScaled scaled(num value) => DimenScaled(value.toDouble());

  static double sdp(AppDimensContext context, num value) =>
      value.sdpOf(context);

  static double sdpa(AppDimensContext context, num value) =>
      value.sdpaOf(context);

  static double sdpi(AppDimensContext context, num value) =>
      value.sdpiOf(context);

  static double sdpia(AppDimensContext context, num value) =>
      value.sdpiaOf(context);

  static double hdp(AppDimensContext context, num value) =>
      value.hdpOf(context);

  static double wdp(AppDimensContext context, num value) =>
      value.wdpOf(context);

  /// Generic scaling entry (mirrors `getDimensionInPx`).
  static double getDimensionInPx(
    AppDimensContext context,
    DpQualifier qualifier,
    num value, {
    Inverter inverter = Inverter.standard,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) =>
      value.toDynamicScaledPx(context, qualifier,
          inverter: inverter,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK);

  /// Generic scaling entry returning logical dp (mirrors `getDimensionInDp`).
  static double getDimensionInDp(
    AppDimensContext context,
    DpQualifier qualifier,
    num value, {
    Inverter inverter = Inverter.standard,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) =>
      value.toDynamicScaledDp(context, qualifier,
          inverter: inverter,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK);
}

/// EN: Static facade mirroring the Kotlin `object DimenSsp`.
///
/// PT: Fachada estática espelhando o `object DimenSsp` do Kotlin.
abstract final class DimenSsp {
  static void warmupCache(AppDimensContext context) =>
      DimenSdp.warmupCache(context);

  static double ssp(AppDimensContext context, num value,
          {bool fontScale = true}) =>
      value.sspOf(context, fontScale: fontScale);

  static double hsp(AppDimensContext context, num value,
          {bool fontScale = true}) =>
      value.hspOf(context, fontScale: fontScale);

  static double wsp(AppDimensContext context, num value,
          {bool fontScale = true}) =>
      value.wspOf(context, fontScale: fontScale);
}
