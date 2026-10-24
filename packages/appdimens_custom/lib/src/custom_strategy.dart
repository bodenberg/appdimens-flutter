/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Custom scaling strategies — strategy object, registry, presets and the
/// Flutter binding (`AppDimensScope` snapshot → [ScreenSnapshot]).
library;

import 'package:appdimens_flutter/appdimens.dart';
import 'package:flutter/foundation.dart';

import 'custom_engine.dart';
import 'custom_scope.dart';

/// EN Device class for a core snapshot + UI mode (Flutter has no desk mode:
/// desktop platforms map to [DeviceClass.desktop]). Override with
/// [ScalingStrategies.deviceClassResolver].
/// PT Classe de dispositivo para um snapshot + modo de UI.
DeviceClass defaultDeviceClass(DimenMetrics metrics, UiModeType uiMode) {
  switch (uiMode) {
    case UiModeType.television:
      return DeviceClass.tv;
    case UiModeType.car:
      return DeviceClass.car;
    case UiModeType.watch:
      return DeviceClass.watch;
    case UiModeType.vrHeadset:
      return DeviceClass.vr;
    default:
      break;
  }
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    return DeviceClass.desktop;
  }
  return metrics.smallestWidthDp >= DeviceClass.tabletMinSmallestWidthDp
      ? DeviceClass.tablet
      : DeviceClass.phone;
}

/// EN Platform-free snapshot of a core [DimenMetrics].
ScreenSnapshot screenSnapshotOf(DimenMetrics m, [UiModeType? uiMode]) {
  final mode = uiMode ?? AppDimensScope.uiModeTypeOrDefault;
  return ScreenSnapshot(
    widthDp: m.screenWidthDp.toDouble(),
    heightDp: m.screenHeightDp.toDouble(),
    smallestWidthDp: m.smallestWidthDp,
    density: m.density,
    fontScale: m.fontScale,
    isLandscape:
        m.isLandscape || (!m.isPortrait && m.screenWidthDp > m.screenHeightDp),
    isMultiWindow: m.isInMultiWindowMode,
    device:
        (ScalingStrategies.deviceClassResolver ?? defaultDeviceClass)(m, mode),
  );
}

/// EN A named, immutable custom strategy. The factor is memoized per window
/// snapshot, so `16.cdpWith(brand)` is one multiply (plus optional bounds).
///
/// PT Estratégia personalizada nomeada e imutável; fator memoizado por snapshot.
class ScalingStrategy {
  final String id;
  final ScalingConfig config;

  /// EN True when results depend on the value itself (value bounds / transform).
  final bool isValueDependent;

  Object? _memoMetrics;
  UiModeType? _memoMode;
  ResolvedScaling? _memo;

  ScalingStrategy(this.id, ScalingConfig config)
      : config = config.validate(),
        isValueDependent = config.isValueDependent {
    if (id.trim().isEmpty) throw ArgumentError('strategy id must not be blank');
  }

  /// EN Creates **and registers** a strategy (named parameters = JSON fields).
  /// ```dart
  /// final brand = ScalingStrategy.define('brand',
  ///   reference: ReferenceScreen(width: 360, height: 640),
  ///   curve: ScalingCurve.power(0.8),
  ///   minFactor: 0.85, maxFactor: 1.6,
  ///   rules: [ScalingRule.on({DeviceClass.tablet}, ScalingPatch(curve: ScalingCurve.logarithmic(0.4)))],
  /// );
  /// // Free-form: curve: ScalingCurve.expression('pow(ratio, 0.8)'), formula: 'max(scaled, base)'
  /// ```
  factory ScalingStrategy.define(
    String id, {
    ScalingStrategy? extend,
    ReferenceScreen? reference,
    ScalingAxis? axis,
    ScalingCurve? curve,
    double? multiplier,
    double? minFactor,
    double? maxFactor,
    double? minValue,
    double? maxValue,
    bool? aspectRatio,
    double? sensitivity,
    FontScalePolicy? fontScale,
    bool? ignoreMultiWindow,
    ValueTransform? transform,
    String? formula,
    List<ScalingRule> rules = const [],
    bool register = true,
  }) {
    final parent = extend?.config ?? ScalingConfig();
    final cfg = parent
        .apply(ScalingPatch(
      reference: reference,
      axis: axis,
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
      formula: formula == null ? null : ScalingFormula(formula),
    ))
        .copyWith(rules: [...parent.rules, ...rules]);
    final s = ScalingStrategy(id, cfg);
    return register ? ScalingStrategies.register(s) : s;
  }

  /// EN Resolution for [metrics] (default: current window) — memoized.
  ResolvedScaling resolve([DimenMetrics? metrics, UiModeType? uiMode]) {
    final m = metrics ?? AppDimensScope.metricsOrDefault;
    final mode = uiMode ?? AppDimensScope.uiModeTypeOrDefault;
    final memo = _memo;
    if (memo != null && identical(_memoMetrics, m) && _memoMode == mode) {
      return memo;
    }
    final r = resolveScaling(config, screenSnapshotOf(m, mode));
    _memoMetrics = m;
    _memoMode = mode;
    _memo = r;
    return r;
  }

  /// EN Resolution for an explicit snapshot (tests, previews).
  ResolvedScaling resolveScreen(ScreenSnapshot screen) =>
      resolveScaling(config, screen);

  double factor([DimenMetrics? metrics]) => resolve(metrics).factor;

  /// EN `value` dp → scaled dp (logical pixels).
  double dp(num value, [DimenMetrics? metrics]) =>
      resolve(metrics).scale(value.toDouble());

  /// EN `value` dp → physical pixels.
  double px(num value, [DimenMetrics? metrics]) {
    final r = resolve(metrics);
    return r.scale(value.toDouble()) * r.screen.density;
  }

  /// EN `fontSize` for `Text` (Flutter applies its TextScaler; the strategy
  /// font-scale policy is pre-compensated).
  double sp(num value, [DimenMetrics? metrics]) =>
      resolve(metrics).scaleSpUnits(value.toDouble());

  /// EN Final text size in dp after the effective font scale.
  double spDp(num value, [DimenMetrics? metrics]) =>
      resolve(metrics).scaleSpDp(value.toDouble());

  /// EN Text size in physical pixels.
  double spPx(num value, [DimenMetrics? metrics]) {
    final r = resolve(metrics);
    return r.scaleSpDp(value.toDouble()) * r.screen.density;
  }

  String explain([DimenMetrics? metrics]) => resolve(metrics).explain(id);

  /// EN New strategy starting from this one (parent rules first).
  ScalingStrategy extend(
    String id, {
    ReferenceScreen? reference,
    ScalingAxis? axis,
    ScalingCurve? curve,
    double? multiplier,
    double? minFactor,
    double? maxFactor,
    double? minValue,
    double? maxValue,
    bool? aspectRatio,
    double? sensitivity,
    FontScalePolicy? fontScale,
    bool? ignoreMultiWindow,
    ValueTransform? transform,
    List<ScalingRule> rules = const [],
    bool register = true,
  }) =>
      ScalingStrategy.define(id,
          extend: this,
          reference: reference,
          axis: axis,
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
          rules: rules,
          register: register);

  /// EN Same strategy on another axis. Id `"<id>@<axis>"`, cached.
  ScalingStrategy withAxis(ScalingAxis axis) {
    if (axis == config.axis) return this;
    final derivedId = '$id@${axis.jsonName}';
    return ScalingStrategies._derived.putIfAbsent(derivedId,
        () => ScalingStrategy(derivedId, config.copyWith(axis: axis)));
  }

  /// EN JSON map (throws for function curves / transforms).
  Map<String, Object?> toJson() => ScalingStrategyJson.toJson(id, config);

  @override
  String toString() => 'ScalingStrategy($id)';
}

ScalingStrategy _spec(String id, ScalingConfig c) => ScalingStrategy(id, c);

/// EN One-liner strategy from a **text** formula, for JSON, remote config or a
/// formula that comes from outside the code. Same names as the code form
/// ([scalingFormulaOf]); the formula **is** the final value:
/// ```dart
/// final hud = scalingFormula('base * pow(sw / 360, 0.8)');
/// SizedBox(width: 48.cdpWith(hud)); // or straight: 48.cdpFormula('base * …')
/// ```
/// Variables: `base` (the value you pass, e.g. 16), `sw`, `width`, `height`,
/// `shortSide`, `longSide`, `diagonal`, `aspectRatio`, `density`, `fontScale`,
/// the device flags (`tablet`, `tv`, `landscape`, …) and `ratio` (`sw / 300`,
/// the same ratio `sdp` uses). Same language and same numbers on every
/// AppDimens platform; see `DOCUMENTATION/custom.md`.
///
/// Writing it as `base * (…)` keeps it on the one-multiply fast path (the
/// `(…)` part is computed once per window). Any other shape still works.
///
/// Without an [id] the strategy is shared per formula text (calling this again
/// with the same text returns the same instance), so it is cheap to call in
/// `build`. With an [id] it is a new strategy, registered unless
/// `register: false`. Parse errors throw a [FormatException] right away.
///
/// PT Estratégia em uma linha a partir de uma fórmula em texto — a fórmula
/// **é** o valor final. Escrever como `base * (…)` mantém o caminho rápido.
ScalingStrategy scalingFormula(String formula, {String? id, bool? register}) {
  final reg = register ?? id != null;
  if (id == null && !reg) return ScalingStrategies.formula(formula);
  final strategy = _formulaStrategy(id ?? _formulaId(formula), formula);
  return reg ? ScalingStrategies.register(strategy) : strategy;
}

/// EN One-liner strategy from a **code** formula — the result **is** the
/// final value. Typed Dart with autocomplete, no strings, no limits:
/// ```dart
/// final hud = scalingFormulaOf((s) => s.base * s.pow(s.sw / 360, 0.8));
/// final card = scalingFormulaOf((s) => s.tablet ? s.base * 1.2 : s.base * s.ratio);
/// ```
/// The function gets a [FormulaScope]: `base`, the window (`sw`, `width`,
/// `height`, `ratio`, `tablet`, `landscape`, …) and `pow`, `clamp`, `min`,
/// `max`, `lerp`… Must be pure. Declare it once (e.g. a top-level `final`).
/// Not JSON-serializable: the text form [scalingFormula] is. Without an [id] a
/// unique `formula#N` id is generated; with an [id] it is registered unless
/// `register: false`.
/// PT Estratégia em uma linha a partir de uma fórmula em **código** — o
/// resultado **é** o valor final. Dart tipado com autocomplete, sem strings.
ScalingStrategy scalingFormulaOf(double Function(FormulaScope s) formula,
    {String? id, bool? register}) {
  final reg = register ?? id != null;
  final strategy = ScalingStrategy(
      id ?? 'formula#${++ScalingStrategies._lambdaIds}',
      ScalingConfig(
          transform: (base, _, screen) => formula(FormulaScope(screen, base))));
  return reg ? ScalingStrategies.register(strategy) : strategy;
}

/// EN Strategy from a programmable **factor** — you return the number that
/// multiplies every value:
/// ```dart
/// final product = customScaleStrategy((s) => s.clamp(s.width / 360, 0.85, 1.80));
/// final living = customScaleStrategy((s) => s.tv ? s.height / 540 : s.ratio);
/// Padding(padding: EdgeInsets.all(16.cdpWith(product))); // 16 × factor
/// ```
/// The function gets a [ScreenScope] (the window, with autocomplete) and can
/// use any Dart code of yours. The factor depends only on the window, so it
/// runs once per window and every value then costs one multiply. A non-finite
/// factor throws a [StateError] when the window resolves. Without an [id] a
/// unique `scale#N` id is generated; with an [id] it is registered unless
/// `register: false`. Not JSON-serializable: for JSON, use a text curve
/// (`ScalingCurve.expression('clamp(width / 360, 0.85, 1.8)')`).
///
/// PT Estratégia a partir de um **fator** programável — você devolve o número
/// que multiplica todo valor. Roda uma vez por janela.
ScalingStrategy customScaleStrategy(double Function(ScreenScope s) factor,
    {String? id, bool? register}) {
  final reg = register ?? id != null;
  final strategy = ScalingStrategy(
      id ?? 'scale#${++ScalingStrategies._lambdaIds}',
      ScalingConfig(
          curve: ScalingCurve.custom((_, screen) => factor(ScreenScope(screen)))));
  return reg ? ScalingStrategies.register(strategy) : strategy;
}

ScalingStrategy _formulaStrategy(String id, String formula) =>
    ScalingStrategy(id, ScalingConfig(formula: ScalingFormula(formula)));

String _formulaId(String formula) => 'formula:$formula';

/// EN The built-in strategies as custom configs — parents for `extend` / `"extends"`.
abstract final class BuiltInStrategies {
  static final ScalingStrategy scaled = _spec('scaled', ScalingConfig());
  static final ScalingStrategy power =
      _spec('power', ScalingConfig(curve: ScalingCurve.power(0.75)));
  static final ScalingStrategy logarithmic =
      _spec('logarithmic', ScalingConfig(curve: ScalingCurve.logarithmic(0.4)));
  static final ScalingStrategy interpolated = _spec(
      'interpolated', ScalingConfig(curve: ScalingCurve.interpolated(0.5)));
  static final ScalingStrategy diagonal =
      _spec('diagonal', ScalingConfig(axis: ScalingAxis.diagonal));
  static final ScalingStrategy perimeter =
      _spec('perimeter', ScalingConfig(axis: ScalingAxis.perimeter));
  static final ScalingStrategy fixed =
      _spec('fixed', ScalingConfig(curve: ScalingCurve.constant(1)));

  static List<ScalingStrategy> get all =>
      [scaled, power, logarithmic, interpolated, diagonal, perimeter, fixed];
}

/// EN Ready-made strategies for common product needs.
abstract final class CustomPresets {
  static final ScalingStrategy tabletFriendly = _spec(
      'tabletFriendly',
      ScalingConfig(maxFactor: 1.8, rules: [
        ScalingRule.on({
          DeviceClass.tablet,
          DeviceClass.desktop
        }, ScalingPatch(curve: ScalingCurve.power(0.5)), name: 'large'),
      ]));
  static final ScalingStrategy compactFirst = _spec(
      'compactFirst',
      ScalingConfig(
          reference: ReferenceScreen(width: 360, height: 640),
          curve: ScalingCurve.interpolated(0.5),
          minFactor: 0.9,
          maxFactor: 1.4));
  static final ScalingStrategy tvSafe = _spec(
      'tvSafe',
      ScalingConfig(rules: [
        ScalingRule.on(
            {DeviceClass.tv},
            ScalingPatch(
                axis: ScalingAxis.height,
                reference: ReferenceScreen(width: 960, height: 540),
                minFactor: 1,
                maxFactor: 2),
            name: 'tv'),
      ]));
  static final ScalingStrategy wearable = _spec(
      'wearable',
      ScalingConfig(rules: [
        ScalingRule.on(
            {DeviceClass.watch},
            ScalingPatch(
                axis: ScalingAxis.min,
                reference: ReferenceScreen(width: 192, height: 192),
                minFactor: 0.85,
                maxFactor: 1.15),
            name: 'watch'),
      ]));
  static final ScalingStrategy gameHud = _spec(
      'gameHud',
      ScalingConfig(
          axis: ScalingAxis.min,
          curve: ScalingCurve.power(0.85),
          aspectRatio: true,
          minFactor: 0.75,
          maxFactor: 2.5,
          fontScale: FontScalePolicy.ignore));
  static final ScalingStrategy readableText = _spec(
      'readableText',
      ScalingConfig(
          curve: ScalingCurve.logarithmic(0.4),
          fontScale: FontScalePolicy.clamp(1.3)));

  static List<ScalingStrategy> get all =>
      [tabletFriendly, compactFirst, tvSafe, wearable, gameHud, readableText];
}

/// EN Process-wide registry of strategies and the default used by `16.cdp`.
/// PT Registro de estratégias e o padrão usado por `16.cdp`.
abstract final class ScalingStrategies {
  static final Map<String, ScalingStrategy> _byId = {};
  static final Map<String, ScalingStrategy> _derived = {};
  static final Map<String, ScalingStrategy> _formulas = {};
  static int _lambdaIds = 0;
  static ScalingStrategy? _default;

  /// EN Bound for distinct inline formula texts; past it, strategies are built
  /// per call (still correct).
  static const int _maxSharedFormulas = 256;

  /// EN Replaces the device-class detection (`null` = [defaultDeviceClass]).
  static DeviceClass Function(DimenMetrics metrics, UiModeType uiMode)?
      deviceClassResolver;

  /// EN Default strategy (`16.cdp`). Initially [BuiltInStrategies.scaled] (= `sdp`).
  static ScalingStrategy get defaultStrategy =>
      _default ?? BuiltInStrategies.scaled;
  static set defaultStrategy(ScalingStrategy? value) => _default = value;

  static ScalingStrategy register(ScalingStrategy s) => _byId[s.id] = s;

  static void unregister(String id) {
    _byId.remove(id);
    if (_default?.id == id) _default = null;
  }

  /// EN Registered strategy, built-in or preset.
  static ScalingStrategy? get(String id) {
    final hit = _byId[id];
    if (hit != null) return hit;
    final lower = id.toLowerCase();
    for (final s in [...BuiltInStrategies.all, ...CustomPresets.all]) {
      if (s.id.toLowerCase() == lower) return s;
    }
    return null;
  }

  static ScalingStrategy getOrThrow(String id) =>
      get(id) ??
      (throw ArgumentError(
          "No scaling strategy '$id'. Registered: ${(_byId.keys.toList()..sort()).join(', ')}"));

  static Iterable<ScalingStrategy> get registered => _byId.values;

  /// EN Parses a document (JSON text or decoded map), registers every strategy
  /// and applies its `default`.
  static Map<String, ScalingStrategy> loadJson(Object json) {
    final parsed = ScalingStrategyJson.parse(json, (id) => get(id)?.config);
    final out = <String, ScalingStrategy>{};
    parsed.configs
        .forEach((id, cfg) => out[id] = register(ScalingStrategy(id, cfg)));
    if (parsed.defaultId != null) {
      _default = out[parsed.defaultId] ?? getOrThrow(parsed.defaultId!);
    }
    return out;
  }

  /// EN Strategy whose value is the text [formula]
  /// (`'base * pow(sw / 360, 0.8)'`), shared per text and not registered
  /// (id `formula:<text>`). Same as [scalingFormula] without an id.
  /// PT Estratégia cujo valor é a [formula] em texto, compartilhada por texto.
  static ScalingStrategy formula(String formula) {
    final hit = _formulas[formula];
    if (hit != null) return hit;
    final strategy = _formulaStrategy(_formulaId(formula), formula);
    if (_formulas.length >= _maxSharedFormulas) return strategy;
    return _formulas[formula] = strategy;
  }

  /// EN Encodes strategies as a document.
  static Map<String, Object?> exportJson(
          [Iterable<ScalingStrategy>? strategies]) =>
      {
        'version': ScalingStrategyJson.formatVersion,
        if (_default != null) 'default': _default!.id,
        'strategies': [for (final s in strategies ?? _byId.values) s.toJson()],
      };

  @visibleForTesting
  static void resetForTest() {
    _byId.clear();
    _derived.clear();
    _formulas.clear();
    _default = null;
    deviceClassResolver = null;
  }
}
