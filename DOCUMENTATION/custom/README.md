# Custom strategies: documentation

**Package:** `appdimens_custom` (also re-exported by `appdimens_bom`) · one import: `package:appdimens_custom/appdimens_custom.dart` · port of Android `appdimens-dynamic-custom` / KMP `appdimens-kmp-custom`

The built-in strategies (`sdp`, `pwsdp`, `asdp`…) cover most apps. When yours needs its **own** growth law, this package lets you write it, in one line of Dart or as a full configuration that is shared through JSON with every AppDimens platform (Android, KMP, iOS, React Native, Web, Games, .NET).

## Pick a form

| You want to… | Use | Read |
|---|---|---|
| Write the math yourself, in Dart, with autocomplete | `customScaleStrategy((s) => s.clamp(s.width / 360, 0.85, 1.8))` (factor) · `scalingFormulaOf((s) => s.base * s.pow(s.sw / 360, 0.8))` (value) | [Quick start](quick-start.md) · [Code formulas](code-formulas.md) |
| Keep the formula in JSON or remote config | `scalingFormula('base * pow(sw / 360, 0.8)')` · `16.cdpFormula('…')` | [Text formulas](text-formulas.md) |
| Different behavior per device, screen range or orientation, bounds, font-scale policy | `ScalingStrategy.define('brand', …)` | [Configuration](configuration.md) |
| Share one definition across apps and platforms | a strategies JSON file | [JSON format](json.md) |

## Guides

1. [Quick start](quick-start.md): install, the four forms and your first strategy in five minutes.
2. [Code formulas](code-formulas.md): `customScaleStrategy((s) => …)` and `scalingFormulaOf((s) => …)`, with every name available on the scope `s`.
3. [Text formulas](text-formulas.md): the formula language (operators, functions, variables, errors, fast path).
4. [Configuration](configuration.md): reference frame, axes, curves, bounds, aspect ratio, font scale, multi-window, rules, `extend`, built-ins and presets.
5. [JSON format](json.md): the cross-platform document, loading, exporting and validation errors.
6. [API reference](api-reference.md): every `num` extension, `BuildContext` helper, widget, the registry and the debug helpers.
7. [Performance](performance.md): what each form costs and how memoization works.
8. [Cookbook](cookbook.md): ready-to-use recipes (tablets, TV, watch, game HUD, readable text, A/B tests).
9. [Troubleshooting](troubleshooting.md): error messages, `explain()`, and frequent questions.

## How it works, in one picture

```
ratio  = axis(window) / axis(reference)                  // e.g. sw / 300
factor = clamp( curve(ratio) × multiplier × AR , min, max )   // once per window
value  = formula( clampValue( base × factor ) )           // per value, only if needed
```

`customScaleStrategy((s) => …)` replaces the whole `factor` line. `scalingFormulaOf((s) => …)` replaces the whole `value` line. The full configuration lets you set each piece and change it per device with rules. The numbers are the same on every AppDimens platform: a shared 540-case fixture checks it.

[Back to the documentation index](../README.md) · [Overview page](../custom.md)
