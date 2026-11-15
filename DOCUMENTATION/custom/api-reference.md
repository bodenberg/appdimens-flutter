# API reference

Everything is exported by `package:appdimens_custom/appdimens_custom.dart`. Values are logical pixels (dp) unless the name says `Px`.

## Building strategies

| Function | Returns | Notes |
|---|---|---|
| `customScaleStrategy((s) => factor, {id, register})` | `ScalingStrategy` | programmable factor, `ScreenScope` parameter ([code formulas](code-formulas.md)) |
| `scalingFormulaOf((s) => value, {id, register})` | `ScalingStrategy` | code formula, `FormulaScope` parameter |
| `scalingFormula('text', {id, register})` | `ScalingStrategy` | text formula, shared per text without an id ([text formulas](text-formulas.md)) |
| `ScalingStrategy.define(id, {extend, reference, axis, curve, …, rules, register = true})` | `ScalingStrategy` | full configuration ([configuration](configuration.md)) |
| `strategy.extend(id, {…, register = true})` | `ScalingStrategy` | child of an existing strategy |
| `strategy.withAxis(axis)` | `ScalingStrategy` | same strategy on another axis, id `"<id>@<axis>"`, cached per strategy |
| `ScalingStrategy(id, ScalingConfig(…))` | `ScalingStrategy` | wrap a config built by hand (not registered) |
| `BuiltInStrategies.scaled` … `fixed` · `CustomPresets.tvSafe` … | `ScalingStrategy` | ready-made parents |

## Registry: `ScalingStrategies`

| Member | Notes |
|---|---|
| `defaultStrategy` | strategy used by `16.cdp` / `14.csp` and `context.cdp` without a scope; initially `BuiltInStrategies.scaled`; set `null` to reset |
| `register(strategy)` · `unregister(id)` | add or replace · remove (also clears the default if it had that id) |
| `get(id)` · `getOrThrow(id)` | lookup, including built-ins and presets; `getOrThrow` throws `ArgumentError` |
| `registered` | strategies registered by the app |
| `formula('text')` | shared text-formula strategy (id `formula:<text>`, not registered) |
| `loadJson(json)` | register a [JSON document](json.md) (text or decoded) and apply its `default`; atomic |
| `exportJson([strategies])` | encode strategies as a document |
| `deviceClassResolver` | replace the device-class detection: `(DimenMetrics metrics, UiModeType uiMode) => DeviceClass` |

## `num` extensions (`AppDimensCustom`)

They read the window published by `AppDimensApp` / `AppDimensScopeBinder`, like `16.sdp`.

| Call | Returns |
|---|---|
| `16.cdp` · `16.cdpWith(strategy or id)` · `16.cdpFormula('text')` | `double` dp |
| `16.cdpPx` · `16.cdpPxWith(…)` · `16.cdpPxFormula('text')` | `double` physical px |
| `14.csp` · `14.cspWith(…)` · `14.cspFormula('text')` | `double` for `fontSize` (policy pre-compensated; Flutter applies the `TextScaler`) |
| `14.cspPx` · `14.cspPxWith(…)` · `14.cspPxFormula('text')` | `double` text physical px |

`cdpWith` and friends accept a `ScalingStrategy` or a registered id (`String`); any other type throws `ArgumentError`. Dart has no overloading, so text formulas go through the `…Formula` variants.

## `BuildContext` helpers (`AppDimensCustomContext`)

They also subscribe the widget to `MediaQuery` size and text scale, so it rebuilds on rotation and resize.

| Call | Returns |
|---|---|
| `context.cdp(16, [strategy])` · `context.cdpPx(16, [strategy])` · `context.csp(14, [strategy])` | dp · px · `fontSize`, with the nearest `ScalingStrategyScope` (or the given strategy / id) |
| `context.cdpFormula(16, 'text')` · `context.cdpPxFormula(16, 'text')` · `context.cspFormula(14, 'text')` | same, with a text formula |
| `context.scalingStrategy` | strategy in effect here (scope, then the default) |
| `context.explainScaling([strategy])` | debug line |

## Widgets

| Widget | Notes |
|---|---|
| `ScalingStrategyScope(strategy: s, child: …)` | provides `s` to a subtree; `ScalingStrategyScope.of(context)` returns the nearest one, else the default |
| `ScalingStrategyBuilder(strategy: s, builder: (context, s) => …)` | rebuilds when the window snapshot changes (`AppDimensScope.notifier` + `MediaQuery`) and hands out the strategy in effect |

Without an explicit strategy, `context.cdp(16)` uses the nearest `ScalingStrategyScope`, then `ScalingStrategies.defaultStrategy`. `16.cdp` always uses the default.

## Strategy members

| Member | Notes |
|---|---|
| `id` · `config` · `isValueDependent` | identity · full `ScalingConfig` · whether results depend on the value |
| `dp(v, [metrics])` · `px(v, [metrics])` | dp · physical px |
| `sp(v, [metrics])` · `spDp(v, [metrics])` · `spPx(v, [metrics])` | `fontSize` · final text dp · text px |
| `factor([metrics])` · `explain([metrics])` | debug, for the current window or a given `DimenMetrics` |
| `resolve([metrics, uiMode])` → `ResolvedScaling` | memoized per window: `factor`, `appliedRules`, `screen`, `scale(base)`, `scaleSpDp(base)`, `scaleSpUnits(base)`, `explain(id)` |
| `resolveScreen(snapshot)` | platform-free resolution (tests, previews), not memoized |
| `toJson()` | export (throws `StateError` for code functions) |

`ScreenSnapshot(widthDp:, heightDp:, smallestWidthDp:, density:, fontScale:, isLandscape:, isMultiWindow:, device:)` builds a window by hand, for tests and previews (only `widthDp` and `heightDp` are required). `screenSnapshotOf(metrics, [uiMode])` converts a core `DimenMetrics`, and `defaultDeviceClass(metrics, uiMode)` is the built-in detection. `resolveScaling(config, screen)` is the pure engine function.

[Back to the custom docs](README.md)
