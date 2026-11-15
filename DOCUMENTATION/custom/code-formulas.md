# Code formulas

Two one-line entry points let you write the scaling math in plain Dart. The function receives a typed **scope** `s` whose names match the [text language](text-formulas.md), so you only learn them once. The IDE autocompletes them, and a typo fails at compile time. Dart has no receiver lambdas, so every name is read through the parameter: `s.sw`, `s.pow(…)`.

| | `customScaleStrategy((s) => …)` | `scalingFormulaOf((s) => …)` |
|---|---|---|
| You return | the **factor** (every value is multiplied by it) | the **final value** |
| Scope | `ScreenScope` | `FormulaScope` (= `ScreenScope` + `base`) |
| Runs | once per window | once per value, on every call |
| Cost per value | one multiply | your function |
| JSON | no (use a text `expression` curve) | no (use a text `formula`) |

## `customScaleStrategy((s) => …)`: programmable factor

```dart
final product = customScaleStrategy((s) => s.clamp(s.width / 360, 0.85, 1.80));
final living = customScaleStrategy((s) => s.tv ? s.height / 540 : s.ratio);
final steps = customScaleStrategy((s) {
  if (s.sw < 360) return 0.9;
  if (s.sw < 600) return s.sw / 400;
  return 1.5 + (s.sw - 600) / 2000;
});
```

- Signature: `ScalingStrategy customScaleStrategy(double Function(ScreenScope s) factor, {String? id, bool? register})`.
- `register` defaults to `id != null`. Without an `id` a unique `scale#N` id is generated and the strategy is not registered. With an id it is registered, so `ScalingStrategies.get('product')` and `16.cdpWith('product')` find it.
- A non-finite factor (NaN, infinity) throws a `StateError` (`custom strategy produced a non-finite factor (NaN)`) when the window resolves.

## `scalingFormulaOf((s) => …)`: the final value

```dart
final hud = scalingFormulaOf((s) => s.base * s.pow(s.sw / 360, 0.8));
final card = scalingFormulaOf((s) => s.tablet ? s.base * 1.2 : s.base * s.ratio);
final snap = scalingFormulaOf((s) => s.round(s.base * s.sw / 360));       // whole dp only
final floor = scalingFormulaOf((s) => s.max(s.base * s.ratio, s.base));    // never smaller than the design value
```

- Signature: `ScalingStrategy scalingFormulaOf(double Function(FormulaScope s) formula, {String? id, bool? register})`.
- `base` is the value you pass: in `16.cdpWith(hud)` it is `16.0`. For `csp`, the result then follows the font-scale policy (see [font scale](configuration.md#font-scale-csp)).
- Without an `id`, a unique `formula#N` id is generated.

## Names on the scope

| Name | Type | Meaning |
|---|---|---|
| `base` | `double` | the value being scaled (`scalingFormulaOf` only) |
| `sw` | `double` | smallest width of the window (dp) |
| `width` · `height` | `double` | window width · height (dp) |
| `shortSide` · `longSide` | `double` | shorter · longer side (dp) |
| `diagonal` · `perimeter` | `double` | `√(w² + h²)` · `w + h` (dp) |
| `aspectRatio` | `double` | `longSide / shortSide` |
| `ratio` | `double` | `sw / 300`, the ratio `sdp` uses (`s.base * s.ratio` is exactly `sdp`) |
| `density` · `fontScale` | `double` | screen density · user font scale |
| `phone` `tablet` `desktop` `tv` `watch` `car` `vr` | `bool` | device class of the window |
| `landscape` · `portrait` · `multiWindow` | `bool` | orientation · split screen |
| `device` | `DeviceClass` | the device class itself (for `switch`) |
| `screen` | `ScreenSnapshot` | the whole snapshot (`widthDp`, `heightDp`, `smallestWidthDp`, `isLandscape`…) |
| `pow(x, e)` `sqrt` `ln` `log10` `exp` `abs` | `double` | math, no `dart:math` import needed |
| `round(x)` | `double` | half up: `floor(x + 0.5)` |
| `min(a, b)` `max(a, b)` `clamp(x, lo, hi)` | `double` | bounds (two arguments for `min` / `max`) |
| `lerp(a, b, t)` · `smoothstep(e0, e1, x)` | `double` | blending |

The helpers take `num` and return `double`, so `s.clamp(s.width / 360, 0.85, 1.8)` needs no `.toDouble()`, unlike `num.clamp`. The device class comes from the `UiModeType` (TV, watch, car, VR), the platform (macOS, Windows and Linux are `desktop`) and the smallest width (`sw ≥ 600` is a tablet); see [rules](configuration.md#rules).

## Rules for the function

- **Keep it pure.** It must not read mutable state, preferences or time: the factor is memoized per window. Use a different strategy (or a rule) for a different state.
- **Declare it once.** Every call to `customScaleStrategy` or `scalingFormulaOf` creates a new strategy with its own memo and a new `scale#N` / `formula#N` id. Use a top-level `final`, a `static final` in a class, or a field of your `State`, never a fresh closure in `build`.
- **Prefer the factor form when you can.** If your formula is `base × (something about the screen)`, write the something as a `customScaleStrategy`: it runs once per window and each value costs one multiply, while a `scalingFormulaOf` function runs on every call.

## When to use something else

- The formula must live in JSON, a design-token file or remote config: [Text formulas](text-formulas.md).
- You need rules per device, bounds or a font-scale policy on top of a curve: [Configuration](configuration.md). The full configuration also accepts code: `curve: ScalingCurve.custom((ratio, screen) => …)` and `transform: (base, scaled, screen) => …`.

[Back to the custom docs](README.md)
