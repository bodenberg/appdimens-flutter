# Troubleshooting

## See what a strategy does

```dart
debugPrint(brand.explain());                 // current window
Text(context.explainScaling(brand));         // in a widget (also subscribes to MediaQuery)
brand.resolveScreen(ScreenSnapshot(widthDp: 800, heightDp: 1280)).explain('brand');   // any window
```

```
[brand] tablet smallestWidth=800dp / ref 360 = 2.2222 -> logarithmic(0.4) = 1.3194 x 0.9 clamp[0.85, 1.6] => factor 1.1875 rules=[large, #1]
[hud] phone smallestWidth=411dp / ref 300 = 1.37 -> linear = 1.37 => factor 1.37 then formula(base * pow(sw / 360, 0.8))
```

The line reads left to right: device class, axis value and reference, the curve and its result, multiplier, aspect ratio, bounds, the final factor, the per-value formula (`then formula(…)`) or code hook (`then transform`) when there is one, and the applied rules. `factor()` returns only the number.

## Common errors

| Message | Cause | Fix |
|---|---|---|
| `FormatException: Invalid expression at 7: unknown variable 'sww' …` | typo in a text formula | use a name from the list in the message, or switch to a [code formula](code-formulas.md), which the compiler checks |
| `'clamp' takes 3 argument(s), got 2` | wrong number of arguments | see the [function table](text-formulas.md#functions) |
| `StateError: custom strategy produced a non-finite factor (NaN)` | division by zero, `ln` of 0, NaN from a function | guard the formula (`max(x, 1)`) or clamp the factor |
| `<path> must be an object` / `must be a boolean` | wrong JSON type | see the [field tables](json.md#strategy-fields) |
| `maxValue must be >= 0` | negative value bound | value bounds limit the magnitude; use a positive number |
| `minFactor must be <= maxFactor` | crossed bounds in the declaration | swap them (crossed bounds produced by rules at runtime let the max win) |
| `No scaling strategy 'x'. Registered: …` | id not registered (`getOrThrow`, `cdpWith('x')`) | register it, load the JSON first, or check the id |
| `Expected a ScalingStrategy or a strategy id, got …` | `cdpWith` received something else | pass the strategy or its id; for a text formula use `cdpFormula` |
| `Custom curve functions cannot be encoded to JSON` · `transform functions cannot be encoded to JSON` | `toJson()` on a code function | use the text form for strategies you export |

## Frequent questions

**My function result never changes.** The factor is memoized per window. A function that reads mutable state (a setting, the time) is not re-run until the window changes. Use separate strategies and pick one, or make the setting part of the screen (a rule).

**`16.cdpWith(product)` and `16.sdp` differ.** Expected: the default reference is 300 dp of smallest width; `ratio` is `sw / 300`. `s.base * s.ratio` (or `BuiltInStrategies.scaled`) gives exactly `sdp`.

**`16.cdpWith('base * (sw / 360)')` throws `No scaling strategy`.** `cdpWith` takes an id. Use `16.cdpFormula('base * (sw / 360)')`.

**My text formula misses the fast path.** Only `base * E` qualifies. `base * sw / 360` reads as `(base * sw) / 360`; write `base * (sw / 360)`.

**The widget does not update on rotation.** `16.cdpWith(s)` reads the snapshot published by `AppDimensApp`; make sure it wraps the app (or use `AppDimensScopeBinder` in `MaterialApp.builder`), or use `context.cdp(16, s)` / `ScalingStrategyBuilder`, which subscribe the widget.

**Fonts ignore my strategy.** `csp` follows the user font scale by default. Use `FontScalePolicy.ignore` for fixed text, or `FontScalePolicy.clamp(max)` to cap it. Pass the result to `fontSize` as is: Flutter applies the `TextScaler` and the policy is pre-compensated.

**The device class is wrong on my TV or desktop build.** Detection uses the `UiModeType`, then the platform, then `sw ≥ 600`. Force the mode with `AppDimensConfig(forcedUiModeType: …)` or set `ScalingStrategies.deviceClassResolver`.

**Are the numbers the same on Android / iOS / Web?** Yes for everything that can be written as JSON (curves, rules, text formulas): a shared 540-case fixture checks every platform. Code functions run your own code, so they match as long as the code does.

[Back to the custom docs](README.md)
