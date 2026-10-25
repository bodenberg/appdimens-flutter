# Configuration

`ScalingStrategy.define(id, …)` builds a full strategy: the [code](code-formulas.md) and [text](text-formulas.md) one-liners are shortcuts for the simplest cases of it. Its named parameters are the JSON fields, and every field below also exists in the [JSON format](json.md), on every platform.

```dart
final brand = ScalingStrategy.define('brand',          // creates AND registers "brand"
    reference: ReferenceScreen(width: 360, height: 640), // design frame (dp)
    axis: ScalingAxis.smallestWidth,                     // what to compare
    curve: ScalingCurve.power(0.8),                      // how the ratio becomes a factor
    multiplier: 1.0,
    minFactor: 0.85, maxFactor: 1.6,                     // factor bounds
    minValue: 10, maxValue: 64,                          // dp bounds (value-dependent)
    aspectRatio: true, sensitivity: 0.004,               // long/thin screen correction
    fontScale: FontScalePolicy.clamp(1.3),               // csp policy
    ignoreMultiWindow: false,
    rules: [
      ScalingRule.on({DeviceClass.tablet, DeviceClass.desktop},
          ScalingPatch(curve: ScalingCurve.logarithmic(0.4)), name: 'large'),
    ]);
```

Pass `register: false` to build a throwaway strategy. `ScalingStrategy(id, ScalingConfig(…))` wraps a config built by hand (not registered).

## The formula

```
ratio  = axis(window) / axis(reference)
factor = clamp( curve(ratio) × multiplier × AR , minFactor, maxFactor )
value  = formula( clampValue( base × factor , minValue, maxValue ) )
```

## Fields

| Field | Dart (`define` / `ScalingConfig` / `ScalingPatch`) | JSON | Default |
|---|---|---|---|
| Reference frame (dp) | `reference: ReferenceScreen(width: 360, height: 640)` | `"reference": {"width": 360, "height": 640}` | 300 × 533 |
| Axis | `axis: ScalingAxis.height` | `"axis": "height"` | `smallestWidth` |
| Curve | `curve: ScalingCurve.power(0.8)` | `"curve": {"type": "power", "exponent": 0.8}` | `linear` |
| Multiplier | `multiplier: 0.9` | `"multiplier": 0.9` | 1 |
| Factor bounds | `minFactor: 0.85, maxFactor: 1.6` | `"clamp": {"min": 0.85, "max": 1.6}` | none |
| Value bounds (dp, ≥ 0) | `minValue: 10, maxValue: 32` | `"valueClamp": {"min": 10, "max": 32}` | none |
| Aspect ratio | `aspectRatio: true, sensitivity: 0.004` | `"aspectRatio": {"enabled": true, "sensitivity": 0.004}` | off, k = 0.08 / 30 |
| Font scale (`csp`) | `fontScale: FontScalePolicy.follow` · `.ignore` · `FontScalePolicy.clamp(1.3)` | `"fontScale": "follow"` · `"ignore"` · `{"max": 1.3}` | `follow` |
| Multi-window | `ignoreMultiWindow: true` | `"ignoreMultiWindow": true` | false |
| Per-value formula | `formula: 'max(scaled, base)'` | `"formula": "max(scaled, base)"` | none |
| Per-value code hook | `transform: (base, scaled, screen) => …` | (code only) | none |
| Rules | `rules: [ScalingRule(…), ScalingRule.on(…)]` | `"rules": [{"when": {…}, "set": {…}}]` | none |
| Parent | `extend: BuiltInStrategies.power` · `BuiltInStrategies.power.extend('x', …)` | `"extends": "power"` | none |

In a `ScalingPatch` (a rule's `set`) the formula is typed: `ScalingPatch(formula: ScalingFormula('round(scaled)'))`. A formula replaces a transform and the other way round.

## Axes

| Axis | Dart | JSON | Screen value | Reference value |
|---|---|---|---|---|
| Smallest width | `ScalingAxis.smallestWidth` | `smallestWidth` | `sw` | `min(refW, refH)` |
| Width · height | `.width` · `.height` | `width` · `height` | window width · height | `refW` · `refH` |
| Shorter · longer side | `.min` · `.max` | `min` · `max` | shorter · longer side | `min` · `max` of the reference |
| Diagonal | `.diagonal` | `diagonal` | `√(w² + h²)` | `√(refW² + refH²)` |
| Perimeter | `.perimeter` | `perimeter` | `w + h` | `refW + refH` |

The built-in `hdp` divides the height by **300**. A custom `height` axis divides by `reference.height` (533 by default), which is what a designer drawing on a full frame expects.

## Curves

| Curve | Dart | JSON | Factor |
|---|---|---|---|
| Linear | `ScalingCurve.linear` | `"linear"` | `r` (= `sdp` with the default reference) |
| Power | `ScalingCurve.power(0.8)` | `{"type": "power", "exponent": 0.8}` | `r^e` (built-in power uses 0.75) |
| Logarithmic | `ScalingCurve.logarithmic(0.4)` | `{"type": "logarithmic", "k": 0.4}` | `1 + k·ln(r)` |
| Interpolated | `ScalingCurve.interpolated(0.5)` | `{"type": "interpolated", "t": 0.5}` | `1 + (r − 1)·t` |
| Constant | `ScalingCurve.constant(1)` | `{"type": "constant", "factor": 1}` | `f` (`constant(1)` = plain dp) |
| Breakpoints | `ScalingCurve.breakpoints([Breakpoint(360, 1), Breakpoint(600, 1.25)])` | `{"type": "breakpoints", "points": [{"at": 360, "factor": 1}, …]}` | piecewise linear over the **absolute** axis value (dp), clamped to the first and last points |
| Text expression | `ScalingCurve.expression('pow(ratio, 0.8)')` | `{"type": "expression", "expression": "…"}` | your formula ([text formulas](text-formulas.md)) |
| Code | `ScalingCurve.custom((ratio, screen) => …)` | (code only) | your formula, pure |

## Bounds

- `minFactor` / `maxFactor` limit the **factor**. If rules leave `min > max`, the max wins. Declared configs are validated up front (`ArgumentError`: `strategy: minFactor must be <= maxFactor`).
- `minValue` / `maxValue` limit the **resulting dp**. The bounds apply to the magnitude, so a negative offset mirrors a positive one and 0 stays 0; they must be ≥ 0. Value bounds make the strategy value-dependent (`isValueDependent` is `true`).

## Aspect ratio

`aspectRatio: true` multiplies the factor by `1 + k·ln(AR / 1.78)`, where `AR = longSide / shortSide` and the default `k` is the built-in 0.08 / 30 (`customSensitivityDefault`). Raise `sensitivity` for a stronger correction on very long or very square screens.

## Font scale (`csp`)

| Policy | Effect on `14.cspWith(brand)` |
|---|---|
| `FontScalePolicy.follow` (default) | follows the user font scale, like a plain `fontSize` |
| `FontScalePolicy.ignore` | fixed size; the system font scale is cancelled |
| `FontScalePolicy.clamp(1.3)` | follows it up to 1.3×, then stops |

`csp` / `cspWith` / `s.sp` return a value for `TextStyle.fontSize`. Flutter multiplies it by the `TextScaler`, so the policy is pre-compensated: the value is divided by the system scale and multiplied by the effective one. `s.spDp(14)` returns the final size in dp and `s.spPx(14)` in physical pixels.

## Multi-window

`ignoreMultiWindow: true` keeps values unscaled in split screen and freeform windows: the factor is 1, and formulas and transforms are skipped. Value bounds still apply. To react to split screen yourself instead, use a rule (`ScreenCondition(multiWindow: true)`) or read `multiWindow` in a formula. Multi-window comes from `DimenMetrics.isInMultiWindowMode` (force it with `AppDimensConfig(forcedMultiWindow: …)`).

## Rules

A rule changes some fields when its condition matches the window.

```dart
ScalingStrategy.define('brand',
    curve: ScalingCurve.power(0.8),
    rules: [
      ScalingRule.on({DeviceClass.tablet, DeviceClass.desktop},
          ScalingPatch(curve: ScalingCurve.logarithmic(0.4)), name: 'large'),
      ScalingRule(ScreenCondition(minSmallestWidth: 600, landscape: true),
          const ScalingPatch(multiplier: 0.9)),
      ScalingRule.on({DeviceClass.watch},
          ScalingPatch(axis: ScalingAxis.min,
              reference: ReferenceScreen(width: 192, height: 192),
              minFactor: 0.85, maxFactor: 1.15)),
      ScalingRule(ScreenCondition(landscape: true), const ScalingPatch(multiplier: 0.95)),
      ScalingRule(ScreenCondition(multiWindow: true), const ScalingPatch(maxFactor: 1.2)),
      ScalingRule(ScreenCondition(minSmallestWidth: 600),          // sw >= 600, any UI mode
          ScalingPatch(fontScale: FontScalePolicy.clamp(1.2))),
    ]);
```

| Condition | Dart (`ScreenCondition(…)`) | JSON `when` |
|---|---|---|
| Device class | `devices: {DeviceClass.tv}` (or `ScalingRule.on({…}, patch)`) | `"device": "tv"` or `["tablet", "desktop"]` |
| Orientation | `landscape: true` · `landscape: false` | `"orientation": "landscape"` · `"portrait"` |
| Smallest width / width / height (dp) | `minSmallestWidth: 600, maxWidth: 1200` (`min…` / `max…` for each) | `"smallestWidth": {"min": 600}`, `"width": {"max": 1200}`, `"height": {…}` |
| Aspect ratio | `minAspectRatio: 2` | `"aspectRatio": {"min": 2}` |
| Split screen | `multiWindow: true` | `"multiWindow": true` |

- A condition matches when **every** field set in it matches. Ranges are `min <= value < max`.
- All matching rules apply **in declaration order**. A later rule overrides the fields an earlier one set; fields a rule leaves out (`null` in the `ScalingPatch`) keep their current value.
- Applied rule names show in `explain()`. Rules without a name show as `#index`.
- Device classes: `DeviceClass.phone`, `tablet`, `desktop`, `tv`, `watch`, `car`, `vr`. On Flutter they are detected in this order: the `UiModeType` (`television`, `car`, `watch`, `vrHeadset`); macOS, Windows or Linux (not web) → `desktop`; then `sw ≥ 600` → `tablet`, otherwise `phone`. Replace the detection with `ScalingStrategies.deviceClassResolver = (metrics, uiMode) => …`, or force the UI mode with `AppDimensConfig(forcedUiModeType: …)`.

## Extending

```dart
final soft = BuiltInStrategies.power.extend('soft', curve: ScalingCurve.power(0.6));
final myTv = CustomPresets.tvSafe.extend('myTv',
    rules: [ScalingRule.on({DeviceClass.tv}, const ScalingPatch(maxFactor: 1.6))]);
final heights = brand.withAxis(ScalingAxis.height);   // "brand@height", cached per strategy
final hudText = ScalingStrategy.define('hudText', extend: brand, formula: 'round(scaled)');
```

`extend` keeps the parent's fields and rules (the parent's rules first) and lets you change any of them; it registers the child unless `register: false`. To add a text formula to a child, use `ScalingStrategy.define(id, extend: parent, formula: '…')`.

### Built-ins as configs

`BuiltInStrategies.scaled`, `power`, `logarithmic`, `interpolated`, `diagonal`, `perimeter` and `fixed` (all in `BuiltInStrategies.all`). Their factors match the built-in packages on the default smallest-width path (checked against `DimenMetrics.powerScale` / `logarithmicScale` / … in the tests), so they are a safe starting point.

### Presets (`CustomPresets`)

| Preset | Id | What it does |
|---|---|---|
| `tabletFriendly` | `tabletFriendly` | Linear on phones; `power(0.5)` on tablets and desktop; factor ≤ 1.8 |
| `compactFirst` | `compactFirst` | Reference 360×640, `interpolated(0.5)`, factor 0.9–1.4 |
| `tvSafe` | `tvSafe` | On TV: height axis vs 540 dp, factor 1–2 |
| `wearable` | `wearable` | On watch: shorter side vs 192 dp, factor 0.85–1.15 |
| `gameHud` | `gameHud` | Shorter side, `power(0.85)`, aspect ratio on, 0.75–2.5, fixed-size text |
| `readableText` | `readableText` | `logarithmic(0.4)`, font scale capped at 1.3 |

Presets are not registered by default, but `ScalingStrategies.get('tvSafe')` and JSON `extends` find them by id (case-insensitive).

[Back to the custom docs](README.md)
