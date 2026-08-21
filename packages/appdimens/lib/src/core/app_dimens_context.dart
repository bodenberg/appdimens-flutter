/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Platform-neutral window handle — every non-widget API takes one of these.
import 'dart:math' as math;
import 'dart:ui' as ui;

import '../common/dp_qualifier.dart';
import '../common/inverter.dart';
import '../common/ui_mode_type.dart';
import 'dimen_cache.dart';
import 'dimen_calculation_plumbing.dart';
import 'dimen_metrics.dart';
import 'screen_configuration.dart';

/// EN: Platform-neutral window handle. Non-widget APIs take one of these; the
/// Dart port mirrors the Kotlin contract so every calculation is testable
/// without a widget tree.
///
/// PT: Handle de janela neutro de plataforma. As APIs fora dos widgets
/// recebem um destes; a porta Dart espelha o contrato Kotlin para que todo
/// cálculo seja testável sem uma árvore de widgets.
abstract interface class AppDimensContext implements AppDimensContextLike {
  /// Immutable window-configuration snapshot.
  ScreenConfiguration get configuration;

  /// Logical density (`devicePixelRatio`), guarded to finite > 0.
  double get density;

  /// Approximate physical pixels per inch (used by the units module).
  double get xdpi;

  /// System font scale, guarded to finite > 0.
  double get fontScale;

  /// True when the window is known to be inside a multi-window mode.
  bool get isInMultiWindowMode;

  /// Detected / forced UI-mode type.
  UiModeType get uiModeType;

  /// Coherent [DimenMetrics] snapshot derived from this window handle.
  DimenMetrics get dimenMetrics;
}

/// EN: Context built from a [FlutterView] (no widget tree required). Works on
/// every Flutter platform and updates naturally because callers re-create it
/// per resolution or via [AppDimensProvider].
///
/// PT: Contexto construído a partir de um [FlutterView] (sem árvore de
/// widgets). Funciona em todas as plataformas Flutter e se atualiza
/// naturalmente porque os chamadores o recriam por resolução ou via
/// [AppDimensProvider].
class ViewAppDimensContext implements AppDimensContext {
  @override
  final ScreenConfiguration configuration;

  @override
  final double density;

  @override
  final double xdpi;

  @override
  final double fontScale;

  @override
  final bool isInMultiWindowMode;

  @override
  final UiModeType uiModeType;

  DimenMetrics? _metricsCache;

  @override
  DimenMetrics get dimenMetrics => _metricsCache ??= DimenMetrics.from(
        configuration,
        isInMultiWindowMode: isInMultiWindowMode,
      );

  ViewAppDimensContext({
    required this.configuration,
    this.density = 1.0,
    this.xdpi = 160.0,
    this.fontScale = 1.0,
    this.isInMultiWindowMode = false,
    this.uiModeType = UiModeType.undefined,
  });

  /// Builds a context from a raw [ui.FlutterView].
  factory ViewAppDimensContext.fromView(ui.FlutterView view,
      {UiModeType uiModeType = UiModeType.undefined}) {
    final dpr = view.devicePixelRatio;
    final safeDpr = dpr.isFinite && dpr > 0 ? dpr : 1.0;
    final physical = view.physicalSize;
    final widthDp = (physical.width / safeDpr).round();
    final heightDp = (physical.height / safeDpr).round();
    final fontScale = view.platformDispatcher.textScaleFactor; // guarded below
    return ViewAppDimensContext(
      configuration: ScreenConfiguration(
        screenWidthDp: math.max(widthDp, 1),
        screenHeightDp: math.max(heightDp, 1),
        smallestScreenWidthDp: 0,
        densityDpi: (safeDpr * 160).round(),
        fontScale: fontScale,
        orientation: heightDp >= widthDp
            ? ScreenConfiguration.orientationPortrait
            : ScreenConfiguration.orientationLandscape,
      ),
      density: safeDpr,
      xdpi: safeDpr * 160,
      fontScale: fontScale.isFinite && fontScale > 0 ? fontScale : 1.0,
      uiModeType: uiModeType,
    );
  }
}

/// Fixed context for tests, previews and headless engines.
class FakeAppDimensContext implements AppDimensContext {
  @override
  final ScreenConfiguration configuration;

  @override
  final double density;

  @override
  final double xdpi;

  @override
  final double fontScale;

  @override
  final bool isInMultiWindowMode;

  @override
  final UiModeType uiModeType;

  @override
  DimenMetrics get dimenMetrics => DimenMetrics.from(
        configuration,
        isInMultiWindowMode: isInMultiWindowMode,
      );

  const FakeAppDimensContext({
    this.configuration = ScreenConfiguration.baseline,
    this.density = 1.0,
    this.xdpi = 160.0,
    this.fontScale = 1.0,
    this.isInMultiWindowMode = false,
    this.uiModeType = UiModeType.undefined,
  });

  /// Phone-like baseline: 392 × 832 dp @ 2.75, font scale 1.0.
  static const FakeAppDimensContext phone = FakeAppDimensContext(
    configuration: ScreenConfiguration(
      screenWidthDp: 392,
      screenHeightDp: 832,
      densityDpi: 440,
      orientation: ScreenConfiguration.orientationPortrait,
    ),
    density: 2.75,
    xdpi: 440,
  );

  /// Tablet-like baseline: 800 × 1280 dp @ 2.0.
  static const FakeAppDimensContext tablet = FakeAppDimensContext(
    configuration: ScreenConfiguration(
      screenWidthDp: 800,
      screenHeightDp: 1280,
      densityDpi: 320,
      orientation: ScreenConfiguration.orientationLandscape,
    ),
    density: 2.0,
    xdpi: 320,
  );
}

/// Shared helpers to read the effective axis of a context.
extension AppDimensContextX on AppDimensContext {
  /// Reads the screen dimension for [qualifier] after applying [inverter].
  double axisDp(DpQualifier qualifier, Inverter inverter) =>
      DimenCalculationPlumbing.readScreenDp(
        configuration,
        DimenCalculationPlumbing.effectiveQualifier(
          qualifier,
          inverter,
          configuration.isLandscape,
          configuration.isPortrait,
        ),
      );
}
