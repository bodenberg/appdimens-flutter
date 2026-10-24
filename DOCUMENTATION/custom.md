# Custom strategies (`appdimens_custom`)

**Package:** `appdimens_custom` (also re-exported by `appdimens_bom`) · Port of Android `appdimens-dynamic-custom` / KMP `appdimens-kmp-custom`.
See [MODULES.md](MODULES.md) · [Mathematics](MATHEMATICS-AND-CALCULUS.md#custom-strategies) · [API conventions](API-CONVENTIONS.md)

When none of the built-in curves fits, or one growth law must be shared by several apps and platforms, define **your own** strategy. The configuration is identical on every AppDimens platform (Android, KMP, iOS, React Native, Web, Games, .NET) and can be loaded from JSON.

## Quick start: just write the formula

The easiest way is to write the math yourself, as ordinary Dart on one line. The function gets a scope with everything you can use (`base`, `sw`, `width`, `tablet`, `pow`, `clamp`…), the IDE autocompletes it, and a typo is a compile error. There is nothing to configure.

```dart
import 'package:appdimens_custom/appdimens_custom.dart';

// 1. Formula: the result is the final value (`base` = the value you pass, e.g. 16)
final hud = scalingFormulaOf((s) => s.base * s.pow(s.sw / 360, 0.8));
final card = scalingFormulaOf((s) => s.tablet ? s.base * 1.2 : s.base * s.ratio);

// 2. Factor: the result multiplies every value
final product = customScaleStrategy((s) => s.clamp(s.width / 360, 0.85, 1.80));
final living = customScaleStrategy((s) => s.tv ? s.height / 540 : s.ratio);

Padding(padding: EdgeInsets.all(16.cdpWith(product)));          // 16 × factor
Text('Score', style: TextStyle(fontSize: 18.cspWith(hud)));     // text follows the TextScaler
```

Declare each strategy once (for example as a top-level `final`), then use it anywhere: `16.cdpWith(s)`, `context.cdp(16, s)`, `ScalingStrategyScope(strategy: s, …)`. Pass `id:` to name and register one.

### What you can use in the function

| Name | Meaning |
|---|---|
| `base` | the value you pass (`16` in `16.cdpWith(hud)`), only in `scalingFormulaOf` (`FormulaScope`) |
| `sw` · `width` · `height` | smallest width · window width · window height (dp) |
| `shortSide` · `longSide` · `diagonal` · `perimeter` · `aspectRatio` | other window measures |
| `ratio` | `sw / 300`, the ratio `sdp` uses (`base * ratio` is the same as `sdp`) |
| `phone` `tablet` `desktop` `tv` `watch` `car` `vr` · `landscape` `portrait` `multiWindow` | `bool` |
| `density` · `fontScale` · `device` · `screen` | screen density · user font scale · `DeviceClass` · the whole `ScreenSnapshot` |
| `pow` `sqrt` `ln` `log10` `exp` `abs` `round` `min` `max` `clamp` `lerp` `smoothstep` | math, no import needed |

Anything else from Dart or your own code also works (`switch`, your helpers). Strategies must be pure: they must not read mutable state, because results are memoized per window. A non-finite factor throws a `StateError` when the window resolves.

| Form | You return | Cost per value | JSON |
|---|---|---|---|
| `customScaleStrategy((s) => …)` | the **factor** | one multiply (runs once per window) | no |
| `scalingFormulaOf((s) => …)` | the final value | your function, per value | no |
| `scalingFormula('…')` / `16.cdpFormula('…')` | the final value, as text | one multiply when shaped `base * (…)`, otherwise the formula is evaluated | yes |

### Text formulas (for JSON and remote config)

When the formula has to live outside the code, in a JSON file, a remote config or an A/B test, write the same thing as text. It uses the same names (flags are 1/0):

```dart
final remote = scalingFormula('base * pow(sw / 360, 0.8)');
Padding(padding: EdgeInsets.all(16.cdpFormula('base * (tablet ? 0.9 : 1) * clamp(sw / 360, 0.85, 1.6)')));  // inline
context.cdpFormula(16, 'base * (sw / 360)');   // also subscribes to MediaQuery
```

`cdpFormula` / `cdpPxFormula` / `cspFormula` / `cspPxFormula` take the formula text (`cdpWith('…')` still takes a strategy **id**). `ScalingStrategies.formula('…')` returns the shared strategy for a text; `scalingFormula('…', id: 'hud')` builds a named one and registers it.

Text is checked when the strategy is created: an unknown name throws a `FormatException` right away with its position and the list of valid names (e.g. `unknown variable 'sww' (allowed: aspectRatio, base, …)`). The same text works in the strategies JSON (`{"id": "hud", "formula": "base * pow(sw / 360, 0.8)"}`) and gives the same numbers on every AppDimens platform. Operators and functions are listed in [Free-form formulas](#free-form-formulas-no-limits-from-the-built-in-curves).

**Fast path.** A text formula shaped `base * (…)`, where the `(…)` part does not read `base`, costs one multiply per value, because the `(…)` part is computed once per window. `base * sw / 360` is evaluated as written, `(base * sw) / 360`, so write `base * (sw / 360)` to get the fast path. In code, prefer `customScaleStrategy` for the same effect.

For rules per device, factor bounds or a font-scale policy, use the full configuration below.

## What it computes

```
ratio  = axis(window) / axis(reference)
factor = clamp( curve(ratio) × multiplier × AR , minFactor, maxFactor )
dp     = formula( clampValue( base × factor , minValue, maxValue ) )
```

Rules override any field per **device class** (`phone`, `tablet`, `desktop`, `tv`, `watch`, `car`, `vr`), **screen range** (smallest width, width, height, aspect ratio), **orientation** and **multi-window**.

## Define

```dart
import 'package:appdimens_custom/appdimens_custom.dart';

final brand = ScalingStrategy.define(
  'brand',
  reference: ReferenceScreen(width: 360, height: 640),   // design frame
  curve: ScalingCurve.power(0.8),                         // sublinear growth
  minFactor: 0.85,
  maxFactor: 1.6,
  fontScale: FontScalePolicy.clamp(1.3),                  // csp follows the user font scale up to 1.3×
  rules: [
    ScalingRule.on({DeviceClass.tablet, DeviceClass.desktop},
        ScalingPatch(curve: ScalingCurve.logarithmic(0.4)), name: 'large'),
    ScalingRule(ScreenCondition(landscape: true, minSmallestWidth: 600),
        const ScalingPatch(multiplier: 0.9)),
    ScalingRule.on({DeviceClass.watch},
        ScalingPatch(axis: ScalingAxis.min, reference: ReferenceScreen(width: 192, height: 192),
            minFactor: 0.85, maxFactor: 1.15)),
  ],
);
```

`ScalingStrategy.define` **registers** the strategy, so `ScalingStrategies.get('brand')` finds it. Pass `register: false` for throwaway instances.

## Use

```dart
Padding(
  padding: EdgeInsets.all(16.cdpWith(brand)),                   // dp
  child: Text('Hello', style: TextStyle(fontSize: 14.cspWith(brand))),
);

brand.dp(16); brand.sp(14); brand.px(8); brand.spDp(14);       // strategy-first form

ScalingStrategies.defaultStrategy = brand;                      // global default
16.cdp; 14.csp;                                                 // BuiltInStrategies.scaled (= sdp) until set
```

### Scope and context helpers

```dart
ScalingStrategyScope(
  strategy: CustomPresets.tvSafe,
  child: Builder(builder: (context) => Text('Living room',
      style: TextStyle(fontSize: context.csp(18)))),          // nearest scope, else the default
);

ScalingStrategyBuilder(builder: (context, s) => SizedBox(width: s.dp(48)));  // rebuilds on window changes
Text(context.explainScaling());
```

The `context.*` helpers subscribe the widget to `MediaQuery` size and text scale. `ScalingStrategyBuilder` also listens to `AppDimensScope.notifier`.

### Text and `TextScaler`

`csp` / `cspWith` / `s.sp` return a value for `fontSize`. Flutter multiplies it by the `TextScaler`, and the strategy's policy is pre-compensated: `FontScalePolicy.ignore` keeps text fixed, and `FontScalePolicy.clamp(1.3)` caps it at 1.3×. `s.spDp(v)` returns the final size in dp.

## Configuration fields

| Field | Dart | JSON | Default |
|---|---|---|---|
| Reference frame | `reference: ReferenceScreen(width: 360, height: 640)` | `"reference": {"width": 360, "height": 640}` | 300 × 533 |
| Axis | `axis: ScalingAxis.height` | `"axis": "height"` | `smallestWidth` |
| Curve | `ScalingCurve.linear` · `.power(e)` · `.logarithmic(k)` · `.interpolated(t)` · `.constant(f)` · `.breakpoints([Breakpoint(360, 1), …])` · `.expression('…')` (free-form text, see below) · `.custom((ratio, screen) => …)` | `"curve": {"type": "power", "exponent": 0.8}` … | `linear` |
| Multiplier | `multiplier: 0.9` | `"multiplier": 0.9` | 1 |
| Factor bounds | `minFactor` / `maxFactor` | `"clamp": {"min", "max"}` | none |
| Value bounds (dp, magnitude) | `minValue` / `maxValue` | `"valueClamp": {"min", "max"}` | none |
| Aspect ratio | `aspectRatio: true, sensitivity: 0.004` | `"aspectRatio": {"enabled": true, "sensitivity": 0.004}` | off, k = 0.08/30 |
| Font scale | `FontScalePolicy.follow` · `.ignore` · `.clamp(1.3)` | `"follow"` · `"ignore"` · `{"max": 1.3}` | follow |
| Multi-window | `ignoreMultiWindow: true` | `"ignoreMultiWindow": true` | false |
| Per-value formula | `formula: 'max(scaled, base)'` | `"formula": "max(scaled, base)"` | none |
| Per-value hook (code) | `transform: (base, scaled, screen) => …` | — | none |
| Rules | `rules: [ScalingRule(...)]` | `"rules": [{"when": {…}, "set": {…}}]` | none |
| Parent | `extend: BuiltInStrategies.power` / `power.extend('x', …)` | `"extends": "power"` | — |

## Free-form formulas (no limits from the built-in curves)

You are not limited to the built-in curves. Write the formula yourself, as **text** that also works in JSON and gives the same result on every AppDimens platform:

- **Curve expression** returns the **factor** from the screen. It is computed once per window, like any curve, and stays on the one-multiply fast path.
  `"curve": {"type": "expression", "expression": "pow(ratio, 0.8) * (tablet ? 0.9 : 1)"}`
- **Formula** returns the **final value** for each input. It can use `base`, `scaled` and `factor`, and replaces or post-processes the result. The strategy then becomes value-dependent, so results are cached per window.
  `"formula": "base * pow(sw / 360, 0.7) + 2"` · `"formula": "max(scaled, base)"`

| | |
|---|---|
| Operators | `+ - * / % ^` (`^` = power, right-associative; `%` keeps the dividend's sign), `== != < <= > >=`, `&& \|\| !`, `cond ? a : b`, `( )` |
| Functions | `min(a, b, …)` `max(a, b, …)` `clamp(x, lo, hi)` `pow` `sqrt` `ln`/`log` `log10` `log2` `exp` `abs` `sign` `floor` `ceil` `round` (half up) `lerp(a, b, t)` `step(edge, x)` `smoothstep(e0, e1, x)` |
| Screen variables | `sw` `width` `height` `shortSide` `longSide` `diagonal` `perimeter` `aspectRatio` `density` `fontScale`; flags (1/0): `landscape` `portrait` `multiWindow` `phone` `tablet` `desktop` `tv` `watch` `car` `vr`; constants `pi` `e`, `true` / `false` |
| Curve variables | screen variables + `ratio` (axis / reference), `axis` (dp), `ref` (reference dp), `refWidth`, `refHeight` |
| Formula variables | curve variables + `base` (input), `scaled` (base × factor after `valueClamp`), `factor` |

Expressions are parsed when the strategy is created. Unknown variables or functions, wrong arity and syntax errors fail early with the position and the JSON path (e.g. `brand.rules[0].set.curve.expression`). A non-finite factor (for example, a division by zero) throws when the strategy resolves. Rules can swap expressions per device like any other field, and `"formula": null` clears an inherited formula.

For anything the language cannot express, use a code-only function: `ScalingCurve.custom((ratio, screen) => …)` (factor) or `transform: (base, scaled, screen) => …` (value). Both have full access to your code, but they cannot be serialized to JSON.

```dart
final hud = ScalingStrategy.define('hud',
    curve: ScalingCurve.expression(
        'clamp(pow(shortSide / 360, 0.85) * (1 + 0.05 * log(aspectRatio / 1.78)), 0.8, 2)'),
    formula: 'round(scaled)', // whole dp only
    rules: [
      ScalingRule.on({DeviceClass.tv},
          ScalingPatch(curve: ScalingCurve.expression('height / 540'))),
    ]);
```

How rules apply:
- Ranges are `min <= value < max`.
- All matching rules apply in declaration order, and a later rule overrides the fields an earlier one set.
- If combined bounds cross, the max bound wins.
- Applied rule names show up in `explain()`. Unnamed rules show as `#index`.

## JSON, presets and built-ins

```dart
ScalingStrategies.loadJson(await rootBundle.loadString('assets/appdimens-strategies.json'));
final soft = BuiltInStrategies.power.extend('soft', curve: ScalingCurve.power(0.6));
final heights = brand.withAxis(ScalingAxis.height);   // "brand@height", cached
final json = brand.toJson();                           // export (ScalingStrategies.exportJson())
```

| Preset | Id | Behaviour |
|---|---|---|
| `CustomPresets.tabletFriendly` | `tabletFriendly` | linear on phones; `power(0.5)` on tablets/desktop; factor ≤ 1.8 |
| `CustomPresets.compactFirst` | `compactFirst` | reference 360×640, `interpolated(0.5)`, 0.9–1.4 |
| `CustomPresets.tvSafe` | `tvSafe` | on TV: height vs 540 dp, 1–2 |
| `CustomPresets.wearable` | `wearable` | on watch: shorter side vs 192 dp, 0.85–1.15 |
| `CustomPresets.gameHud` | `gameHud` | shorter side, `power(0.85)`, aspect ratio on, 0.75–2.5, fixed text |
| `CustomPresets.readableText` | `readableText` | `logarithmic(0.4)`, font scale ≤ 1.3 |

`extends` may name another strategy of the same document, a registered strategy, a built-in (`scaled`, `power`, `logarithmic`, `interpolated`, `diagonal`, `perimeter`, `fixed`) or a preset. The parent's rules come first. Errors are `FormatException`s that name the path. Schema: [custom-strategy.schema.json](https://github.com/bodenberg/appdimens-skills/blob/main/schemas/custom-strategy.schema.json).

## Device class on Flutter

The device class is detected in this order:
1. `UiModeType` (`television`, `car`, `watch`, `vrHeadset`).
2. macOS / Windows / Linux → `desktop`.
3. Size: `sw >= 600` → `tablet`, otherwise `phone`.

You can override this with `ScalingStrategies.deviceClassResolver = (metrics, uiMode) => …`, or force the UI mode with `AppDimensConfig(forcedUiModeType: …)`.

## Performance and parity

- The factor is memoized per snapshot and UI mode, so `16.cdpWith(brand)` is one multiply.
- Value bounds, `formula` and `transform` add a few operations per call.
- Keep `ScalingCurve.custom` and `transform` pure.
- `packages/appdimens_custom/test/custom-strategy-fixture.json`, generated by the Kotlin reference engine, runs in CI with a relative tolerance of 1e-4.
- Built-in parity is also checked against `DimenMetrics.powerScale` / `logarithmicScale` / ….

[Back to index](README.md)
