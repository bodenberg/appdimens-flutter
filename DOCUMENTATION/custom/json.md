# JSON format

One JSON document describes any number of strategies. The same file loads on every AppDimens platform and gives the same numbers, so a design system can ship it as a design token, through remote config or for an A/B test.

```dart
import 'package:flutter/services.dart' show rootBundle;

final text = await rootBundle.loadString('assets/appdimens-strategies.json');
ScalingStrategies.loadJson(text);                      // registers all + applies "default"
ScalingStrategies.loadJson(jsonDecode(text));          // same, from a decoded Map / List
final brand = ScalingStrategies.getOrThrow('brand');
final json = brand.toJson();                           // export one strategy (Map)
final doc = ScalingStrategies.exportJson();            // export every registered strategy
```

Declare the file in `pubspec.yaml` (`flutter: assets: [assets/appdimens-strategies.json]`). `loadJson` takes the JSON text or an already decoded value: a document, a single strategy object, or an array of strategy objects. It returns the strategies it registered, as a `Map<String, ScalingStrategy>`.

## Document

```json
{
  "$schema": "https://github.com/bodenberg/appdimens-skills/schemas/custom-strategy.schema.json",
  "version": 1,
  "default": "brand",
  "strategies": [
    {
      "id": "brand",
      "reference": { "width": 360, "height": 640 },
      "curve": { "type": "power", "exponent": 0.8 },
      "clamp": { "min": 0.85, "max": 1.6 },
      "fontScale": { "max": 1.3 },
      "rules": [
        { "name": "large", "when": { "device": ["tablet", "desktop"] },
          "set": { "curve": { "type": "logarithmic", "k": 0.4 } } },
        { "when": { "smallestWidth": { "min": 600 }, "orientation": "landscape" },
          "set": { "multiplier": 0.9 } }
      ]
    },
    { "id": "brandText", "extends": "brand", "valueClamp": { "min": 10, "max": 32 } },
    { "id": "hud", "formula": "base * pow(sw / 360, 0.8)" }
  ]
}
```

| Key | Meaning |
|---|---|
| `version` | format version, currently 1 (`ScalingStrategyJson.formatVersion`) |
| `default` | id that becomes `ScalingStrategies.defaultStrategy` (optional) |
| `strategies[]` | the strategies, each with a unique `id` |

## Strategy fields

| Field | Example | Notes |
|---|---|---|
| `id` | `"brand"` | required, unique in the document |
| `extends` | `"power"` | another strategy of the document, a registered one, a built-in (`scaled` `power` `logarithmic` `interpolated` `diagonal` `perimeter` `fixed`) or a preset (`tabletFriendly`…). The parent's rules come first |
| `reference` | `{"width": 360, "height": 640}` | design frame (dp) |
| `axis` | `"smallestWidth"` | `smallestWidth` `width` `height` `min` `max` `diagonal` `perimeter` |
| `curve` | `"linear"` or `{"type": …}` | see the [curve table](configuration.md#curves) |
| `multiplier` | `0.9` | |
| `clamp` | `{"min": 0.85, "max": 1.6}` | factor bounds; `null` clears inherited bounds |
| `valueClamp` | `{"min": 10, "max": 32}` | dp bounds, ≥ 0; `null` clears |
| `aspectRatio` | `true` or `{"enabled": true, "sensitivity": 0.004}` | |
| `sensitivity` | `0.004` | aspect-ratio k on its own (useful in a rule) |
| `fontScale` | `"follow"` · `"ignore"` · `{"max": 1.3}` | `csp` policy |
| `ignoreMultiWindow` | `true` | |
| `formula` | `"max(scaled, base)"` | per-value [text formula](text-formulas.md); `null` clears an inherited one |
| `rules` | `[{"name": …, "when": {…}, "set": {…}}]` | `set` takes any field above except `id`, `extends` and `rules` |

## Rule conditions (`when`)

| Key | Example |
|---|---|
| `device` | `"tv"` or `["tablet", "desktop"]` (`phone` `tablet` `desktop` `tv` `watch` `car` `vr`) |
| `orientation` | `"landscape"` or `"portrait"` |
| `smallestWidth` · `width` · `height` · `aspectRatio` | `{"min": 600, "max": 840}`, with `min <= value < max` |
| `multiWindow` | `true` |

An omitted `when` matches every screen.

## Validation

Loading is strict and atomic: the whole document is parsed and validated before anything is registered, so on any error **nothing** is registered and the default does not change. Format errors throw a `FormatException` with the JSON path; bound checks and a missing `default` throw an `ArgumentError`. Catch both (for example `catch (e)`), since `ArgumentError` is an `Error`, not an `Exception`. Examples:

| Input | Error |
|---|---|
| `"curve": {"type": "cubic"}` | `FormatException`: `brand.curve.type 'cubic' is not one of linear, power, logarithmic, interpolated, constant, breakpoints, expression` |
| `"when": "tablet"` | `FormatException`: `brand.rules[0].when must be an object` |
| `"width": 600` in a condition | `FormatException`: `brand.rules[0].when.width must be an object with min/max` |
| `"ignoreMultiWindow": "true"` | `FormatException`: `brand.ignoreMultiWindow must be a boolean` |
| `"valueClamp": {"max": -1}` | `ArgumentError`: `strategy: maxValue must be >= 0` |
| `"formula": "base * sww"` | `FormatException`: `brand.formula: Invalid expression at 7: unknown variable 'sww' …` |
| `"default": "missing"` | `ArgumentError`: `No scaling strategy 'missing'. Registered: …`; nothing is registered |
| duplicate ids · `extends` cycles · unknown parent | `Duplicate strategy id 'brand'` · `Cyclic 'extends': a → b → a` · `'x' extends unknown strategy 'y'` |

To validate without registering, call `ScalingStrategyJson.parse(json, (id) => ScalingStrategies.get(id)?.config)`; it returns the parsed configs and the default id. Check a file before shipping it with the AppDimens kit (`npx appdimens-skills kit custom check <file>`), which uses the same engine and the [JSON schema](https://github.com/bodenberg/appdimens-skills/blob/main/schemas/custom-strategy.schema.json).

## Export

`strategy.toJson()` returns one strategy object (a `Map<String, Object?>`; pass it to `jsonEncode`), and `ScalingStrategies.exportJson([strategies])` a whole document with `version`, `default` and `strategies`. A document reloads unchanged. Code functions (`customScaleStrategy`, `scalingFormulaOf`, `ScalingCurve.custom`, `transform`) cannot be exported and throw a `StateError`. Use their text equivalents when you need JSON.

[Back to the custom docs](README.md)
