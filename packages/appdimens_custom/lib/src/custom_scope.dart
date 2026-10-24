/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// EN Typed scopes for code formulas — the **same names as the text
/// formulas** (`base`, `sw`, `tablet`, `pow`, …), so the IDE autocompletes
/// them and typos fail at compile time.
/// PT Escopos tipados para fórmulas em código, com os mesmos nomes das
/// fórmulas em texto.
library;

import 'dart:math' as math;

import 'custom_engine.dart';

/// EN What a factor formula can read: the window, with the same names as the
/// text language. Values are logical pixels (dp); flags are `bool`.
/// `customScaleStrategy((s) => s.clamp(s.width / 360, 0.85, 1.8))`.
/// PT O que uma fórmula de fator pode ler: a janela, com os mesmos nomes da
/// linguagem em texto.
class ScreenScope {
  /// EN The full window snapshot. PT O snapshot completo da janela.
  final ScreenSnapshot screen;

  ScreenScope(this.screen);

  /// EN Smallest width (dp).
  double get sw => screen.smallestWidthDp;
  double get width => screen.widthDp;
  double get height => screen.heightDp;
  double get shortSide => screen.minDp;
  double get longSide => screen.maxDp;
  double get diagonal => screen.read(ScalingAxis.diagonal);
  double get perimeter => screen.read(ScalingAxis.perimeter);
  double get aspectRatio => screen.aspectRatio;
  double get density => screen.density;
  double get fontScale => screen.fontScale;

  /// EN `sw / 300` — the ratio `sdp` uses (`base * ratio` = `sdp`).
  double get ratio =>
      sw / ReferenceScreen.standard.read(ScalingAxis.smallestWidth);

  bool get landscape => screen.isLandscape;
  bool get portrait => !screen.isLandscape;
  bool get multiWindow => screen.isMultiWindow;
  DeviceClass get device => screen.device;
  bool get phone => screen.device == DeviceClass.phone;
  bool get tablet => screen.device == DeviceClass.tablet;
  bool get desktop => screen.device == DeviceClass.desktop;
  bool get tv => screen.device == DeviceClass.tv;
  bool get watch => screen.device == DeviceClass.watch;
  bool get car => screen.device == DeviceClass.car;
  bool get vr => screen.device == DeviceClass.vr;

  // EN Math helpers with the text-language names, so no import is needed.
  // PT Funções matemáticas com os nomes da linguagem em texto.
  double pow(num x, num exponent) => math.pow(x, exponent).toDouble();
  double sqrt(num x) => math.sqrt(x);
  double ln(num x) => math.log(x);
  double log10(num x) => math.log(x) / math.ln10;
  double exp(num x) => math.exp(x);
  double abs(num x) => x.abs().toDouble();

  /// EN Half up, like the text `round`: `floor(x + 0.5)`.
  double round(num x) => (x + 0.5).floorToDouble();
  double min(num a, num b) => math.min(a, b).toDouble();
  double max(num a, num b) => math.max(a, b).toDouble();
  double clamp(num x, num lower, num upper) =>
      math.max(lower, math.min(upper, x)).toDouble();
  double lerp(num a, num b, num t) => (a + (b - a) * t).toDouble();
  double smoothstep(num edge0, num edge1, num x) {
    final t = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0).toDouble();
    return t * t * (3 - 2 * t);
  }
}

/// EN [ScreenScope] plus [base], the value being scaled (the `16` in
/// `16.cdpWith(hud)`): `scalingFormulaOf((s) => s.base * s.pow(s.sw / 360, 0.8))`.
/// PT [ScreenScope] mais [base], o valor sendo escalado.
class FormulaScope extends ScreenScope {
  /// EN The value you pass. PT O valor passado.
  final double base;

  FormulaScope(super.screen, this.base);
}
