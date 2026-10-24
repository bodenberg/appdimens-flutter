/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Custom scaling strategies — platform-free engine (port of Android
/// `appdimens-dynamic-custom`).
///
/// EN A strategy is an immutable configuration that turns a window into one
/// factor:
///   ratio  = axis(window) / axis(reference)
///   factor = clamp(curve(ratio) × multiplier × AR, minFactor, maxFactor)
///   dp     = formula(clampValue(base × factor, minValue, maxValue))
/// The JSON format is shared with every AppDimens platform
/// (`custom-strategy.schema.json`).
///
/// PT Uma estratégia é uma configuração imutável que transforma a janela em
/// um fator. O formato JSON é compartilhado com todas as plataformas AppDimens.
library;

import 'dart:convert';
import 'dart:math' as math;

import 'custom_expression.dart';

export 'custom_expression.dart';

/// EN Screen measure a strategy scales against. PT Medida usada pela estratégia.
enum ScalingAxis {
  smallestWidth('smallestWidth'),
  width('width'),
  height('height'),
  min('min'),
  max('max'),
  diagonal('diagonal'),
  perimeter('perimeter');

  const ScalingAxis(this.jsonName);
  final String jsonName;

  static ScalingAxis fromJson(String name) => values.firstWhere(
        (a) => a.jsonName.toLowerCase() == name.toLowerCase(),
        orElse: () => throw FormatException(
            "Unknown axis '$name'. Expected one of ${values.map((a) => a.jsonName).join(', ')}"),
      );
}

/// EN Device family matched by rules. PT Família de dispositivo das regras.
enum DeviceClass {
  phone('phone'),
  tablet('tablet'),
  desktop('desktop'),
  tv('tv'),
  watch('watch'),
  car('car'),
  vr('vr');

  const DeviceClass(this.jsonName);
  final String jsonName;

  /// EN `sw` (dp) from which a normal window counts as a tablet.
  static const double tabletMinSmallestWidthDp = 600;

  static DeviceClass fromJson(String name) => values.firstWhere(
        (d) => d.jsonName.toLowerCase() == name.toLowerCase(),
        orElse: () => throw FormatException(
            "Unknown device '$name'. Expected one of ${values.map((d) => d.jsonName).join(', ')}"),
      );
}

/// EN Immutable, platform-free description of the window.
/// PT Descrição imutável e independente de plataforma da janela.
class ScreenSnapshot {
  final double widthDp;
  final double heightDp;
  final double smallestWidthDp;
  final double density;
  final double fontScale;
  final bool isLandscape;
  final bool isMultiWindow;
  final DeviceClass device;

  ScreenSnapshot({
    required this.widthDp,
    required this.heightDp,
    double? smallestWidthDp,
    this.density = 1,
    this.fontScale = 1,
    bool? isLandscape,
    this.isMultiWindow = false,
    DeviceClass? device,
  })  : smallestWidthDp = smallestWidthDp ?? math.min(widthDp, heightDp),
        isLandscape = isLandscape ?? widthDp > heightDp,
        device = device ??
            ((smallestWidthDp ?? math.min(widthDp, heightDp)) >=
                    DeviceClass.tabletMinSmallestWidthDp
                ? DeviceClass.tablet
                : DeviceClass.phone);

  double get minDp => math.min(widthDp, heightDp);
  double get maxDp => math.max(widthDp, heightDp);

  /// EN `max / min` (≥ 1).
  double get aspectRatio => minDp > 0 ? maxDp / minDp : 1;

  double read(ScalingAxis axis) => switch (axis) {
        ScalingAxis.smallestWidth => smallestWidthDp,
        ScalingAxis.width => widthDp,
        ScalingAxis.height => heightDp,
        ScalingAxis.min => minDp,
        ScalingAxis.max => maxDp,
        ScalingAxis.diagonal => math.sqrt(minDp * minDp + maxDp * maxDp),
        ScalingAxis.perimeter => minDp + maxDp,
      };

  @override
  bool operator ==(Object other) =>
      other is ScreenSnapshot &&
      other.widthDp == widthDp &&
      other.heightDp == heightDp &&
      other.smallestWidthDp == smallestWidthDp &&
      other.density == density &&
      other.fontScale == fontScale &&
      other.isLandscape == isLandscape &&
      other.isMultiWindow == isMultiWindow &&
      other.device == device;

  @override
  int get hashCode => Object.hash(widthDp, heightDp, smallestWidthDp, density,
      fontScale, isLandscape, isMultiWindow, device);
}

/// EN Design frame (dp). Default: the AppDimens base 300×533.
class ReferenceScreen {
  final double width;
  final double height;

  ReferenceScreen({this.width = 300, this.height = 533}) {
    if (!(width.isFinite && width > 0) || !(height.isFinite && height > 0)) {
      throw ArgumentError('reference width/height must be > 0');
    }
  }

  static final ReferenceScreen standard = ReferenceScreen();

  double read(ScalingAxis axis) => switch (axis) {
        ScalingAxis.smallestWidth || ScalingAxis.min => math.min(width, height),
        ScalingAxis.width => width,
        ScalingAxis.height => height,
        ScalingAxis.max => math.max(width, height),
        ScalingAxis.diagonal => math.sqrt(width * width + height * height),
        ScalingAxis.perimeter => width + height,
      };

  @override
  bool operator ==(Object other) =>
      other is ReferenceScreen &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(width, height);
}

/// EN Pure user formula `(ratio, screen) → factor`.
typedef CurveFunction = double Function(double ratio, ScreenSnapshot screen);

/// EN Pure per-value hook `(base, scaled, screen) → dp`.
typedef ValueTransform = double Function(
    double base, double scaled, ScreenSnapshot screen);

/// EN How the axis ratio becomes a factor. PT Como a razão vira fator.
sealed class ScalingCurve {
  const ScalingCurve();

  /// `r`
  static const ScalingCurve linear = LinearScalingCurve();

  /// `r^exponent` (built-in power uses 0.75).
  factory ScalingCurve.power(double exponent) = PowerScalingCurve;

  /// `1 + k·ln(r)` (built-in logarithmic uses 0.4).
  factory ScalingCurve.logarithmic(double k) = LogarithmicScalingCurve;

  /// `1 + (r − 1)·t` (built-in interpolated uses 0.5).
  factory ScalingCurve.interpolated(double t) = InterpolatedScalingCurve;

  /// Fixed factor.
  factory ScalingCurve.constant(double factor) = ConstantScalingCurve;

  /// Piecewise linear over the **absolute** axis value (dp).
  factory ScalingCurve.breakpoints(List<Breakpoint> points) =
      BreakpointsScalingCurve;

  /// Free formula written as text (JSON-serializable, same result on every
  /// platform), e.g. `ScalingCurve.expression('pow(ratio, 0.8)')`.
  factory ScalingCurve.expression(String source) = ExpressionScalingCurve;

  /// Free pure formula (not JSON-serializable).
  factory ScalingCurve.custom(CurveFunction function) = CustomScalingCurve;

  double evaluate(double ratio, double axisDp, ScreenSnapshot screen);
}

class LinearScalingCurve extends ScalingCurve {
  const LinearScalingCurve();
  @override
  double evaluate(double ratio, double axisDp, ScreenSnapshot screen) => ratio;
  @override
  String toString() => 'linear';
  @override
  bool operator ==(Object other) => other is LinearScalingCurve;
  @override
  int get hashCode => 1;
}

class PowerScalingCurve extends ScalingCurve {
  final double exponent;
  PowerScalingCurve(this.exponent) {
    if (!exponent.isFinite) throw ArgumentError('exponent must be finite');
  }
  @override
  double evaluate(double ratio, double axisDp, ScreenSnapshot screen) =>
      ratio > 0 ? math.pow(ratio, exponent).toDouble() : 0;
  @override
  String toString() => 'power($exponent)';
  @override
  bool operator ==(Object other) =>
      other is PowerScalingCurve && other.exponent == exponent;
  @override
  int get hashCode => Object.hash('power', exponent);
}

class LogarithmicScalingCurve extends ScalingCurve {
  final double k;
  LogarithmicScalingCurve(this.k) {
    if (!k.isFinite) throw ArgumentError('k must be finite');
  }
  @override
  double evaluate(double ratio, double axisDp, ScreenSnapshot screen) =>
      ratio > 0 ? 1 + k * math.log(ratio) : 1;
  @override
  String toString() => 'logarithmic($k)';
  @override
  bool operator ==(Object other) =>
      other is LogarithmicScalingCurve && other.k == k;
  @override
  int get hashCode => Object.hash('log', k);
}

class InterpolatedScalingCurve extends ScalingCurve {
  final double t;
  InterpolatedScalingCurve(this.t) {
    if (!t.isFinite) throw ArgumentError('t must be finite');
  }
  @override
  double evaluate(double ratio, double axisDp, ScreenSnapshot screen) =>
      1 + (ratio - 1) * t;
  @override
  String toString() => 'interpolated($t)';
  @override
  bool operator ==(Object other) =>
      other is InterpolatedScalingCurve && other.t == t;
  @override
  int get hashCode => Object.hash('interp', t);
}

class ConstantScalingCurve extends ScalingCurve {
  final double factor;
  ConstantScalingCurve(this.factor) {
    if (!factor.isFinite) throw ArgumentError('factor must be finite');
  }
  @override
  double evaluate(double ratio, double axisDp, ScreenSnapshot screen) => factor;
  @override
  String toString() => 'constant($factor)';
  @override
  bool operator ==(Object other) =>
      other is ConstantScalingCurve && other.factor == factor;
  @override
  int get hashCode => Object.hash('const', factor);
}

/// EN Point of a breakpoints table. PT Ponto da tabela de breakpoints.
class Breakpoint {
  final double at;
  final double factor;
  Breakpoint(this.at, this.factor) {
    if (!at.isFinite || at < 0) {
      throw ArgumentError("breakpoint 'at' must be >= 0");
    }
    if (!factor.isFinite) {
      throw ArgumentError('breakpoint factor must be finite');
    }
  }
  @override
  bool operator ==(Object other) =>
      other is Breakpoint && other.at == at && other.factor == factor;
  @override
  int get hashCode => Object.hash(at, factor);
}

class BreakpointsScalingCurve extends ScalingCurve {
  final List<Breakpoint> points;
  BreakpointsScalingCurve(List<Breakpoint> points)
      : points = List.unmodifiable(
            [...points]..sort((a, b) => a.at.compareTo(b.at))) {
    if (this.points.isEmpty) {
      throw ArgumentError('breakpoints need at least one point');
    }
  }
  @override
  double evaluate(double ratio, double axisDp, ScreenSnapshot screen) {
    if (axisDp <= points.first.at) return points.first.factor;
    for (var i = 1; i < points.length; i++) {
      final b = points[i];
      if (axisDp <= b.at) {
        final a = points[i - 1];
        final span = b.at - a.at;
        return span <= 0
            ? b.factor
            : a.factor + (b.factor - a.factor) * ((axisDp - a.at) / span);
      }
    }
    return points.last.factor;
  }

  @override
  String toString() => 'breakpoints(${points.length})';
  @override
  bool operator ==(Object other) {
    if (other is! BreakpointsScalingCurve ||
        other.points.length != points.length) {
      return false;
    }
    for (var i = 0; i < points.length; i++) {
      if (other.points[i] != points[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(points);
}

class ExpressionScalingCurve extends ScalingCurve {
  final ScalingExpression expression;

  ExpressionScalingCurve(String source)
      : expression = ScalingExpression.parse(source, allowed: curveVariables);

  /// EN Evaluates with the full strategy context (used by [resolveScaling]).
  double evaluateWith(double ratio, double axisDp, double refDp,
          ReferenceScreen reference, ScreenSnapshot screen) =>
      expression.evaluate(
          expressionVariables(screen, ratio, axisDp, refDp, reference));

  @override
  double evaluate(double ratio, double axisDp, ScreenSnapshot screen) =>
      evaluateWith(ratio, axisDp, ratio != 0 ? axisDp / ratio : double.nan,
          ReferenceScreen.standard, screen);

  @override
  bool operator ==(Object other) =>
      other is ExpressionScalingCurve && other.expression == expression;

  @override
  int get hashCode => expression.hashCode;

  @override
  String toString() => 'expression(${expression.source})';
}

class CustomScalingCurve extends ScalingCurve {
  final CurveFunction function;
  const CustomScalingCurve(this.function);
  @override
  double evaluate(double ratio, double axisDp, ScreenSnapshot screen) =>
      function(ratio, screen);
  @override
  String toString() => 'custom';
}

/// EN Font-scale handling for text. PT Tratamento do font scale em texto.
sealed class FontScalePolicy {
  const FontScalePolicy();
  static const FontScalePolicy follow = _Follow();
  static const FontScalePolicy ignore = _Ignore();
  factory FontScalePolicy.clamp(double max) = FontScaleClamp;

  double effective(double system);
}

class _Follow extends FontScalePolicy {
  const _Follow();
  @override
  double effective(double system) => system;
}

class _Ignore extends FontScalePolicy {
  const _Ignore();
  @override
  double effective(double system) => 1;
}

class FontScaleClamp extends FontScalePolicy {
  final double max;
  FontScaleClamp(this.max) {
    if (!max.isFinite || max <= 0) {
      throw ArgumentError('fontScale max must be > 0');
    }
  }
  @override
  double effective(double system) => math.min(system, max);
  @override
  bool operator ==(Object other) => other is FontScaleClamp && other.max == max;
  @override
  int get hashCode => Object.hash('fsclamp', max);
}

/// EN When a rule applies (`min <= v < max`; every set field must match).
/// PT Quando uma regra se aplica.
class ScreenCondition {
  final Set<DeviceClass>? devices;
  final bool? landscape;
  final double? minSmallestWidth, maxSmallestWidth;
  final double? minWidth, maxWidth;
  final double? minHeight, maxHeight;
  final double? minAspectRatio, maxAspectRatio;
  final bool? multiWindow;

  const ScreenCondition({
    this.devices,
    this.landscape,
    this.minSmallestWidth,
    this.maxSmallestWidth,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.minAspectRatio,
    this.maxAspectRatio,
    this.multiWindow,
  });

  static bool _in(double v, double? min, double? max) =>
      (min == null || v >= min) && (max == null || v < max);

  bool matches(ScreenSnapshot s) {
    if (devices != null && !devices!.contains(s.device)) return false;
    if (landscape != null && s.isLandscape != landscape) return false;
    if (!_in(s.smallestWidthDp, minSmallestWidth, maxSmallestWidth)) {
      return false;
    }
    if (!_in(s.widthDp, minWidth, maxWidth)) return false;
    if (!_in(s.heightDp, minHeight, maxHeight)) return false;
    if (!_in(s.aspectRatio, minAspectRatio, maxAspectRatio)) return false;
    if (multiWindow != null && s.isMultiWindow != multiWindow) return false;
    return true;
  }
}

/// EN Partial override (null keeps the current value). PT Sobrescrita parcial.
class ScalingPatch {
  final ReferenceScreen? reference;
  final ScalingAxis? axis;
  final ScalingCurve? curve;
  final double? multiplier;
  final double? minFactor, maxFactor;
  final double? minValue, maxValue;
  final bool? aspectRatio;
  final double? sensitivity;
  final FontScalePolicy? fontScale;
  final bool? ignoreMultiWindow;
  final ValueTransform? transform;

  /// EN Per-value text formula (JSON-serializable); replaces [transform].
  final ScalingFormula? formula;

  const ScalingPatch({
    this.reference,
    this.axis,
    this.curve,
    this.multiplier,
    this.minFactor,
    this.maxFactor,
    this.minValue,
    this.maxValue,
    this.aspectRatio,
    this.sensitivity,
    this.fontScale,
    this.ignoreMultiWindow,
    this.transform,
    this.formula,
  });

  /// EN A proportional text formula (`base * E`) is screen-only.
  bool get isValueDependent =>
      minValue != null ||
      maxValue != null ||
      transform != null ||
      (formula != null && !formula!.isProportional);
}

/// EN `when` [condition] matches, apply [patch]; later rules win.
class ScalingRule {
  final ScreenCondition condition;
  final ScalingPatch patch;
  final String? name;

  const ScalingRule(this.condition, this.patch, {this.name});

  /// EN Shortcut: rule for device classes. PT Atalho: regra por dispositivo.
  factory ScalingRule.on(Set<DeviceClass> devices, ScalingPatch patch,
          {String? name}) =>
      ScalingRule(ScreenCondition(devices: devices), patch, name: name);
}

/// EN Full immutable definition of a strategy. PT Definição completa.
class ScalingConfig {
  final ReferenceScreen reference;
  final ScalingAxis axis;
  final ScalingCurve curve;
  final double multiplier;
  final double? minFactor, maxFactor;
  final double? minValue, maxValue;
  final bool aspectRatio;
  final double? sensitivity;
  final FontScalePolicy fontScale;
  final bool ignoreMultiWindow;
  final ValueTransform? transform;

  /// EN Per-value text formula; takes the place of [transform].
  final ScalingFormula? formula;
  final List<ScalingRule> rules;

  ScalingConfig({
    ReferenceScreen? reference,
    this.axis = ScalingAxis.smallestWidth,
    this.curve = ScalingCurve.linear,
    this.multiplier = 1,
    this.minFactor,
    this.maxFactor,
    this.minValue,
    this.maxValue,
    this.aspectRatio = false,
    this.sensitivity,
    this.fontScale = FontScalePolicy.follow,
    this.ignoreMultiWindow = false,
    ValueTransform? transform,
    this.formula,
    List<ScalingRule> rules = const [],
  })  : transform = formula != null ? null : transform,
        reference = reference ?? ReferenceScreen.standard,
        rules = List.unmodifiable(rules);

  /// EN True when some path depends on the value itself (not only on the
  /// screen). A proportional text formula (`base * E`) is screen-only.
  bool get isValueDependent =>
      minValue != null ||
      maxValue != null ||
      transform != null ||
      (formula != null && !formula!.isProportional) ||
      rules.any((r) => r.patch.isValueDependent);

  ScalingConfig apply(ScalingPatch p) => ScalingConfig(
        reference: p.reference ?? reference,
        axis: p.axis ?? axis,
        curve: p.curve ?? curve,
        multiplier: p.multiplier ?? multiplier,
        minFactor: p.minFactor ?? minFactor,
        maxFactor: p.maxFactor ?? maxFactor,
        minValue: p.minValue ?? minValue,
        maxValue: p.maxValue ?? maxValue,
        aspectRatio: p.aspectRatio ?? aspectRatio,
        sensitivity: p.sensitivity ?? sensitivity,
        fontScale: p.fontScale ?? fontScale,
        ignoreMultiWindow: p.ignoreMultiWindow ?? ignoreMultiWindow,
        transform: p.formula != null ? null : p.transform ?? transform,
        formula: p.transform != null && p.formula == null
            ? null
            : p.formula ?? formula,
        rules: rules,
      );

  ScalingConfig copyWith({ScalingAxis? axis, List<ScalingRule>? rules}) =>
      ScalingConfig(
        reference: reference,
        axis: axis ?? this.axis,
        curve: curve,
        multiplier: multiplier,
        minFactor: minFactor,
        maxFactor: maxFactor,
        minValue: minValue,
        maxValue: maxValue,
        aspectRatio: aspectRatio,
        sensitivity: sensitivity,
        fontScale: fontScale,
        ignoreMultiWindow: ignoreMultiWindow,
        transform: transform,
        formula: formula,
        rules: rules ?? this.rules,
      );

  /// EN Cross-field checks of the declared config (base + each rule on top).
  ScalingConfig validate() {
    void check(ScalingConfig c, String where) {
      if (c.minFactor != null &&
          c.maxFactor != null &&
          c.minFactor! > c.maxFactor!) {
        throw ArgumentError('$where: minFactor must be <= maxFactor');
      }
      if (c.minValue != null &&
          c.maxValue != null &&
          c.minValue! > c.maxValue!) {
        throw ArgumentError('$where: minValue must be <= maxValue');
      }
    }

    check(this, 'strategy');
    for (var i = 0; i < rules.length; i++) {
      check(apply(rules[i].patch), 'rules[$i]');
    }
    return this;
  }
}

/// EN Default aspect-ratio sensitivity (0.08 / 30, same as the built-ins).
const double customSensitivityDefault = 0.08 / 30;
const double _referenceAspectRatio = 1.78;

/// EN Everything a strategy needs for one window (factor + value parts).
class ResolvedScaling {
  final ScreenSnapshot screen;
  final ScalingConfig config;
  final double factor;
  final List<String> appliedRules;
  final double axisDp, referenceDp, curveFactor, aspectRatioMultiplier;

  /// EN `E` of a proportional formula (`base * E`), evaluated once for this
  /// window; NaN when the formula (if any) needs the value. `base * E` then
  /// costs one multiply, like a curve.
  /// PT `E` de uma fórmula proporcional, calculado uma vez por janela.
  final double _formulaCoefficient;

  const ResolvedScaling._(
      this.screen,
      this.config,
      this.factor,
      this.appliedRules,
      this.axisDp,
      this.referenceDp,
      this.curveFactor,
      this.aspectRatioMultiplier,
      this._formulaCoefficient);

  /// EN `base` dp → scaled dp.
  double scale(double base) {
    var out = base * factor;
    final min = config.minValue, max = config.maxValue;
    if ((min != null || max != null) && out != 0) {
      var magnitude = out.abs();
      if (min != null && magnitude < min) magnitude = min;
      if (max != null && magnitude > max) magnitude = max;
      out = out < 0 ? -magnitude : magnitude;
    }
    final f = config.formula;
    if (f != null && f.isProportional) {
      out = base * _formulaCoefficient;
    } else if (f != null) {
      final ratio = referenceDp > 0 ? axisDp / referenceDp : 1.0;
      out = f.expression.evaluate(expressionVariables(
          screen, ratio, axisDp, referenceDp, config.reference,
          base: base, scaled: out, factor: factor));
    } else {
      final t = config.transform;
      if (t != null) out = t(base, out, screen);
    }
    return out;
  }

  double get effectiveFontScale => config.fontScale.effective(screen.fontScale);

  /// EN Text size in dp after the effective font scale.
  double scaleSpDp(double base) => scale(base) * effectiveFontScale;

  /// EN Text size for `fontSize` (Flutter applies its TextScaler afterwards).
  double scaleSpUnits(double base) {
    final s = screen.fontScale;
    return s > 0 ? scale(base) * (effectiveFontScale / s) : scale(base);
  }

  String explain(String strategyId) {
    String f(double v) {
      final r = (v * 10000).round() / 10000;
      return r == r.roundToDouble() ? r.toInt().toString() : r.toString();
    }

    final c = config;
    final b = StringBuffer(
        '[$strategyId] ${screen.device.jsonName} ${c.axis.jsonName}=${f(axisDp)}dp')
      ..write(' / ref ${f(referenceDp)} = ${f(axisDp / referenceDp)}')
      ..write(' -> ${c.curve} = ${f(curveFactor)}');
    if (c.multiplier != 1) b.write(' x ${f(c.multiplier)}');
    if (c.aspectRatio) b.write(' x AR ${f(aspectRatioMultiplier)}');
    if (c.minFactor != null || c.maxFactor != null) {
      b.write(
          ' clamp[${c.minFactor == null ? '-' : f(c.minFactor!)}, ${c.maxFactor == null ? '-' : f(c.maxFactor!)}]');
    }
    b.write(' => factor ${f(factor)}');
    if (c.formula != null) {
      b.write(' then ${c.formula}');
    } else if (c.transform != null) {
      b.write(' then transform');
    }
    if (appliedRules.isNotEmpty) b.write(' rules=[${appliedRules.join(', ')}]');
    return b.toString();
  }
}

/// EN Pure resolution of [base] for [screen]. PT Resolução pura.
ResolvedScaling resolveScaling(ScalingConfig base, ScreenSnapshot screen) {
  var cfg = base;
  final applied = <String>[];
  for (var i = 0; i < base.rules.length; i++) {
    final rule = base.rules[i];
    if (rule.condition.matches(screen)) {
      cfg = cfg.apply(rule.patch);
      applied.add(rule.name ?? '#$i');
    }
  }
  final axisDp = screen.read(cfg.axis);
  final refDp = cfg.reference.read(cfg.axis);
  final ratio = refDp > 0 ? axisDp / refDp : 1.0;
  final coefficient = cfg.formula?.expression.baseCoefficient?.evaluate(
          expressionVariables(screen, ratio, axisDp, refDp, cfg.reference)) ??
      double.nan;
  if (cfg.ignoreMultiWindow && screen.isMultiWindow) {
    return ResolvedScaling._(screen, cfg, 1, List.unmodifiable(applied),
        axisDp, refDp, 1, 1, coefficient);
  }
  final curve = cfg.curve;
  final curveFactor = curve is ExpressionScalingCurve
      ? curve.evaluateWith(ratio, axisDp, refDp, cfg.reference, screen)
      : curve.evaluate(ratio, axisDp, screen);
  var factor = curveFactor * cfg.multiplier;
  var arMul = 1.0;
  if (cfg.aspectRatio) {
    final k = cfg.sensitivity ?? customSensitivityDefault;
    arMul = 1 + k * math.log(screen.aspectRatio / _referenceAspectRatio);
    factor *= arMul;
  }
  if (cfg.minFactor != null && factor < cfg.minFactor!) factor = cfg.minFactor!;
  if (cfg.maxFactor != null && factor > cfg.maxFactor!) factor = cfg.maxFactor!;
  if (!factor.isFinite) {
    throw StateError('custom strategy produced a non-finite factor ($factor)');
  }
  return ResolvedScaling._(screen, cfg, factor, List.unmodifiable(applied),
      axisDp, refDp, curveFactor, arMul, coefficient);
}

// ── JSON ──────────────────────────────────────────────────────────────────────

/// EN JSON codec for the cross-platform format. PT Codec JSON multiplataforma.
abstract final class ScalingStrategyJson {
  static const int formatVersion = 1;

  static double? _num(Object? v, String path) {
    if (v == null) return null;
    if (v is num) {
      final d = v.toDouble();
      if (!d.isFinite) throw FormatException('$path must be finite');
      return d;
    }
    throw FormatException('$path must be a number');
  }

  static double _req(Object? v, String path) =>
      _num(v, path) ?? (throw FormatException('$path is required'));

  static ScalingCurve readCurve(Object? v, String path) {
    if (v is String) return readCurve({'type': v}, path);
    if (v is! Map) throw FormatException('$path must be an object or string');
    final type = v['type'];
    return switch (type) {
      'linear' => ScalingCurve.linear,
      'power' =>
        ScalingCurve.power(_num(v['exponent'], '$path.exponent') ?? 0.75),
      'logarithmic' => ScalingCurve.logarithmic(_num(v['k'], '$path.k') ?? 0.4),
      'interpolated' =>
        ScalingCurve.interpolated(_num(v['t'], '$path.t') ?? 0.5),
      'constant' =>
        ScalingCurve.constant(_num(v['factor'], '$path.factor') ?? 1),
      'breakpoints' => () {
          final pts = v['points'];
          if (pts is! List) {
            throw FormatException('$path.points must be an array');
          }
          return ScalingCurve.breakpoints([
            for (var i = 0; i < pts.length; i++)
              Breakpoint(_req((pts[i] as Map)['at'], '$path.points[$i].at'),
                  _req((pts[i] as Map)['factor'], '$path.points[$i].factor')),
          ]);
        }(),
      'expression' => () {
          final src = v['expression'];
          if (src is! String) {
            throw FormatException('$path.expression is required');
          }
          return _parseAt(
              () => ScalingCurve.expression(src), '$path.expression');
        }(),
      _ => throw FormatException(
          "$path.type '$type' is not one of linear, power, logarithmic, interpolated, constant, breakpoints, expression"),
    };
  }

  static T _parseAt<T>(T Function() create, String path) {
    try {
      return create();
    } on FormatException catch (e) {
      throw FormatException('$path: ${e.message}');
    }
  }

  static FontScalePolicy readFontScale(Object? v, String path) {
    if (v == 'follow') return FontScalePolicy.follow;
    if (v == 'ignore') return FontScalePolicy.ignore;
    if (v is Map) return FontScalePolicy.clamp(_req(v['max'], '$path.max'));
    throw FormatException('$path must be "follow", "ignore" or {"max": n}');
  }

  static ScalingPatch readPatch(Map v, String path) {
    final clamp = v['clamp'] is Map ? v['clamp'] as Map : null;
    final valueClamp = v['valueClamp'] is Map ? v['valueClamp'] as Map : null;
    final ar = v['aspectRatio'];
    final ref = v['reference'];
    bool? aspect;
    double? sens;
    if (ar is bool) {
      aspect = ar;
    } else if (ar is Map) {
      aspect = ar['enabled'] as bool? ?? true;
      sens = _num(ar['sensitivity'], '$path.aspectRatio.sensitivity');
    } else if (ar != null) {
      throw FormatException('$path.aspectRatio must be a boolean or object');
    }
    sens ??= _num(v['sensitivity'], '$path.sensitivity');
    return ScalingPatch(
      reference: ref is Map
          ? ReferenceScreen(
              width: _num(ref['width'], '$path.reference.width') ?? 300,
              height: _num(ref['height'], '$path.reference.height') ?? 533)
          : null,
      axis: v['axis'] is String
          ? ScalingAxis.fromJson(v['axis'] as String)
          : null,
      curve: v['curve'] != null ? readCurve(v['curve'], '$path.curve') : null,
      multiplier: _num(v['multiplier'], '$path.multiplier'),
      minFactor: clamp == null ? null : _num(clamp['min'], '$path.clamp.min'),
      maxFactor: clamp == null ? null : _num(clamp['max'], '$path.clamp.max'),
      minValue: valueClamp == null
          ? null
          : _num(valueClamp['min'], '$path.valueClamp.min'),
      maxValue: valueClamp == null
          ? null
          : _num(valueClamp['max'], '$path.valueClamp.max'),
      aspectRatio: aspect,
      sensitivity: sens,
      fontScale: v['fontScale'] != null
          ? readFontScale(v['fontScale'], '$path.fontScale')
          : null,
      ignoreMultiWindow: v['ignoreMultiWindow'] as bool?,
      formula: switch (v['formula']) {
        null => null,
        final String src =>
          _parseAt(() => ScalingFormula(src), '$path.formula'),
        _ => throw FormatException('$path.formula must be a string'),
      },
    );
  }

  static ScreenCondition readCondition(Map v, String path) {
    (double?, double?) range(String key) {
      final r = v[key];
      if (r is! Map) return (null, null);
      return (
        _num(r['min'], '$path.$key.min'),
        _num(r['max'], '$path.$key.max')
      );
    }

    final d = v['device'];
    Set<DeviceClass>? devices;
    if (d is String) {
      devices = {DeviceClass.fromJson(d)};
    } else if (d is List) {
      devices = {for (final x in d) DeviceClass.fromJson(x as String)};
    } else if (d != null) {
      throw FormatException('$path.device must be a string or array');
    }
    final o = v['orientation'];
    if (o != null && o != 'portrait' && o != 'landscape') {
      throw FormatException(
          "$path.orientation '$o' must be portrait or landscape");
    }
    final sw = range('smallestWidth'),
        w = range('width'),
        h = range('height'),
        ar = range('aspectRatio');
    return ScreenCondition(
      devices: devices,
      landscape: o == null ? null : o == 'landscape',
      minSmallestWidth: sw.$1,
      maxSmallestWidth: sw.$2,
      minWidth: w.$1,
      maxWidth: w.$2,
      minHeight: h.$1,
      maxHeight: h.$2,
      minAspectRatio: ar.$1,
      maxAspectRatio: ar.$2,
      multiWindow: v['multiWindow'] as bool?,
    );
  }

  /// EN Builds a validated config from [v] on top of [parent] (parent rules first).
  static ScalingConfig readConfig(Map v, ScalingConfig parent, String path) {
    var cfg = parent.apply(readPatch(v, path));
    // Explicit `null` at the root clears inherited bounds.
    final clearFactor = v.containsKey('clamp') && v['clamp'] == null;
    final clearValue = v.containsKey('valueClamp') && v['valueClamp'] == null;
    final clearFormula = v.containsKey('formula') && v['formula'] == null;
    if (clearFactor || clearValue || clearFormula) {
      cfg = ScalingConfig(
          reference: cfg.reference,
          axis: cfg.axis,
          curve: cfg.curve,
          multiplier: cfg.multiplier,
          minFactor: clearFactor ? null : cfg.minFactor,
          maxFactor: clearFactor ? null : cfg.maxFactor,
          minValue: clearValue ? null : cfg.minValue,
          maxValue: clearValue ? null : cfg.maxValue,
          aspectRatio: cfg.aspectRatio,
          sensitivity: cfg.sensitivity,
          fontScale: cfg.fontScale,
          ignoreMultiWindow: cfg.ignoreMultiWindow,
          transform: cfg.transform,
          formula: clearFormula ? null : cfg.formula,
          rules: cfg.rules);
    }
    final rawRules = v['rules'];
    final rules = <ScalingRule>[];
    if (rawRules is List) {
      for (var i = 0; i < rawRules.length; i++) {
        final r = rawRules[i];
        if (r is! Map || r['set'] is! Map) {
          throw FormatException('$path.rules[$i].set is required');
        }
        rules.add(ScalingRule(
          readCondition(r['when'] is Map ? r['when'] as Map : const {},
              '$path.rules[$i].when'),
          readPatch(r['set'] as Map, '$path.rules[$i].set'),
          name: r['name'] as String?,
        ));
      }
    }
    return cfg.copyWith(rules: [...parent.rules, ...rules]).validate();
  }

  /// EN Parses a document, one strategy object, or an array. [lookup] resolves
  /// `extends` outside the document (registry, built-ins, presets).
  static ({Map<String, ScalingConfig> configs, String? defaultId}) parse(
      Object input, ScalingConfig? Function(String id) lookup) {
    Object? root = input;
    if (input is String) {
      try {
        root = jsonDecode(input);
      } on FormatException catch (e) {
        throw FormatException('Invalid JSON: ${e.message}');
      }
    }
    List items;
    String? defaultId;
    if (root is List) {
      items = root;
    } else if (root is Map && root.containsKey('strategies')) {
      final version = (root['version'] as num?)?.toInt() ?? formatVersion;
      if (version > formatVersion) {
        throw FormatException('Unsupported strategies format version $version');
      }
      if (root['strategies'] is! List) {
        throw const FormatException('strategies must be an array');
      }
      items = root['strategies'] as List;
      defaultId = root['default'] as String?;
    } else if (root is Map) {
      items = [root];
    } else {
      throw const FormatException('Expected a JSON object or array');
    }
    final raw = <String, Map>{};
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item is! Map) {
        throw FormatException('strategies[$i] must be an object');
      }
      final id = item['id'];
      if (id is! String || id.trim().isEmpty) {
        throw FormatException('strategies[$i].id is required');
      }
      if (raw.containsKey(id)) {
        throw FormatException("Duplicate strategy id '$id'");
      }
      raw[id] = item;
    }
    final built = <String, ScalingConfig>{};
    ScalingConfig build(String id, List<String> stack) {
      final done = built[id];
      if (done != null) return done;
      if (stack.contains(id)) {
        throw FormatException(
            "Cyclic 'extends': ${[...stack, id].join(' → ')}");
      }
      final v = raw[id]!;
      final parentId = v['extends'] as String?;
      final ScalingConfig parent;
      if (parentId == null) {
        parent = ScalingConfig();
      } else if (raw.containsKey(parentId)) {
        parent = build(parentId, [...stack, id]);
      } else {
        parent = lookup(parentId) ??
            (throw FormatException(
                "'$id' extends unknown strategy '$parentId'"));
      }
      return built[id] = readConfig(v, parent, id);
    }

    for (final id in raw.keys) {
      build(id, const []);
    }
    return (configs: built, defaultId: defaultId);
  }

  // ── encoding ──

  static Object _curve(ScalingCurve c) => switch (c) {
        LinearScalingCurve() => {'type': 'linear'},
        PowerScalingCurve(:final exponent) => {
            'type': 'power',
            'exponent': exponent
          },
        LogarithmicScalingCurve(:final k) => {'type': 'logarithmic', 'k': k},
        InterpolatedScalingCurve(:final t) => {'type': 'interpolated', 't': t},
        ConstantScalingCurve(:final factor) => {
            'type': 'constant',
            'factor': factor
          },
        BreakpointsScalingCurve(:final points) => {
            'type': 'breakpoints',
            'points': [
              for (final p in points) {'at': p.at, 'factor': p.factor}
            ],
          },
        ExpressionScalingCurve(:final expression) => {
            'type': 'expression',
            'expression': expression.source
          },
        CustomScalingCurve() =>
          throw StateError('Custom curve functions cannot be encoded to JSON'),
      };

  static Object _font(FontScalePolicy f) => switch (f) {
        FontScaleClamp(:final max) => {'max': max},
        _Ignore() => 'ignore',
        _ => 'follow',
      };

  static Map<String, Object?> _range(double? min, double? max) =>
      {if (min != null) 'min': min, if (max != null) 'max': max};

  static Map<String, Object?> _patch(ScalingPatch p, {required bool defaults}) {
    if (p.transform != null) {
      throw StateError('transform functions cannot be encoded to JSON');
    }
    final o = <String, Object?>{};
    final ref = p.reference;
    if (ref != null && (!defaults || ref != ReferenceScreen.standard)) {
      o['reference'] = {'width': ref.width, 'height': ref.height};
    }
    if (p.axis != null && (!defaults || p.axis != ScalingAxis.smallestWidth)) {
      o['axis'] = p.axis!.jsonName;
    }
    if (p.curve != null) o['curve'] = _curve(p.curve!);
    if (p.multiplier != null && (!defaults || p.multiplier != 1)) {
      o['multiplier'] = p.multiplier;
    }
    if (p.minFactor != null || p.maxFactor != null) {
      o['clamp'] = _range(p.minFactor, p.maxFactor);
    }
    if (p.minValue != null || p.maxValue != null) {
      o['valueClamp'] = _range(p.minValue, p.maxValue);
    }
    if (p.aspectRatio != null &&
        (!defaults || p.aspectRatio! || p.sensitivity != null)) {
      o['aspectRatio'] = {
        'enabled': p.aspectRatio,
        if (p.sensitivity != null) 'sensitivity': p.sensitivity
      };
    }
    if (p.fontScale != null &&
        (!defaults || p.fontScale != FontScalePolicy.follow)) {
      o['fontScale'] = _font(p.fontScale!);
    }
    if (p.ignoreMultiWindow != null && (!defaults || p.ignoreMultiWindow!)) {
      o['ignoreMultiWindow'] = p.ignoreMultiWindow;
    }
    if (p.formula != null) o['formula'] = p.formula!.source;
    return o;
  }

  static Map<String, Object?> _condition(ScreenCondition c) => {
        if (c.devices != null)
          'device': [
            for (final d in DeviceClass.values)
              if (c.devices!.contains(d)) d.jsonName
          ],
        if (c.landscape != null)
          'orientation': c.landscape! ? 'landscape' : 'portrait',
        if (c.minSmallestWidth != null || c.maxSmallestWidth != null)
          'smallestWidth': _range(c.minSmallestWidth, c.maxSmallestWidth),
        if (c.minWidth != null || c.maxWidth != null)
          'width': _range(c.minWidth, c.maxWidth),
        if (c.minHeight != null || c.maxHeight != null)
          'height': _range(c.minHeight, c.maxHeight),
        if (c.minAspectRatio != null || c.maxAspectRatio != null)
          'aspectRatio': _range(c.minAspectRatio, c.maxAspectRatio),
        if (c.multiWindow != null) 'multiWindow': c.multiWindow,
      };

  /// EN JSON-ready map for one strategy (throws for function curves / transforms).
  static Map<String, Object?> toJson(String id, ScalingConfig c) => {
        'id': id,
        ..._patch(
            ScalingPatch(
              reference: c.reference,
              axis: c.axis,
              curve: c.curve,
              multiplier: c.multiplier,
              minFactor: c.minFactor,
              maxFactor: c.maxFactor,
              minValue: c.minValue,
              maxValue: c.maxValue,
              aspectRatio: c.aspectRatio,
              sensitivity: c.sensitivity,
              fontScale: c.fontScale,
              ignoreMultiWindow: c.ignoreMultiWindow,
              transform: c.transform,
              formula: c.formula,
            ),
            defaults: true),
        if (c.rules.isNotEmpty)
          'rules': [
            for (final r in c.rules)
              {
                if (r.name != null) 'name': r.name,
                'when': _condition(r.condition),
                'set': _patch(r.patch, defaults: false),
              },
          ],
      };
}
