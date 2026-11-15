# Quick start

## 1. Install

```yaml
dependencies:
  appdimens_flutter: ^3.2.0
  appdimens_custom: ^3.2.0     # or appdimens_bom, which re-exports it
```

`appdimens_custom` is new and not on pub.dev yet; until it is, point the dependency at `packages/appdimens_custom` of this repository (a `path:` or `git:` dependency). Once it is published, `flutter pub add appdimens_custom` does the same.

```dart
import 'package:appdimens_custom/appdimens_custom.dart';   // strategies, extensions, widgets
```

Values follow the window published by `AppDimensApp` (or `AppDimensScopeBinder`), exactly like `16.sdp`. Without a provider they resolve against the 300 × 533 baseline.

## 2. Write the math (recommended)

Declare the strategy **once** (for example as a top-level `final`), then use it anywhere.

```dart
// Factor: the number that multiplies every value
final product = customScaleStrategy((s) => s.clamp(s.width / 360, 0.85, 1.80));

// Formula: the final value (`base` = the value you pass, the 16 in 16.cdpWith(hud))
final hud = scalingFormulaOf((s) => s.base * s.pow(s.sw / 360, 0.8));
```

The function receives a typed scope `s`. The IDE autocompletes `s.width`, `s.sw`, `s.height`, `s.ratio`, `s.tablet`, `s.tv`, `s.landscape`, `s.pow`, `s.clamp`, `s.min`, `s.max`, `s.lerp`… and a typo is a compile error. Any other Dart works too (`if`, `switch`, your own helpers). The full list is in [Code formulas](code-formulas.md).

## 3. Use it

```dart
Padding(padding: EdgeInsets.all(16.cdpWith(product)));          // dp (logical pixels)
Text('Score', style: TextStyle(fontSize: 18.cspWith(hud)));     // fontSize; Flutter applies the TextScaler
final px = 24.cdpPxWith(product);                               // physical pixels

// In a build method: also subscribes the widget to MediaQuery size and text scale
SizedBox(width: context.cdp(48, product));
```

## 4. Make it the default (optional)

```dart
ScalingStrategies.defaultStrategy = product;       // app-wide: 16.cdp now uses product

ScalingStrategyScope(                              // one subtree: context.cdp / context.csp
  strategy: hud,
  child: Builder(builder: (context) =>
      Text('Lives', style: TextStyle(fontSize: context.csp(14)))),
);
```

## 5. The same thing as text (for JSON and remote config)

```dart
final remote = scalingFormula('base * pow(sw / 360, 0.8)');
Padding(padding: EdgeInsets.all(16.cdpFormula('base * (sw / 360)')));   // inline, shared per text
```

The text form uses the same names (flags are 1 or 0) and works in the strategies JSON (`{"id": "hud", "formula": "base * pow(sw / 360, 0.8)"}`). Dart has no overloading, so the text variants have their own names: `cdpFormula`, `cspFormula`, `cdpPxFormula`, `cspPxFormula`. `16.cdpWith('hud')` takes a strategy **id**, not a formula. See [Text formulas](text-formulas.md).

## 6. Need more structure?

Rules per device class, factor bounds, a font-scale cap or a different reference frame go in the full configuration:

```dart
final brand = ScalingStrategy.define('brand',
    reference: ReferenceScreen(width: 360, height: 640),
    curve: ScalingCurve.power(0.8),
    minFactor: 0.85,
    maxFactor: 1.6,
    fontScale: FontScalePolicy.clamp(1.3),
    rules: [
      ScalingRule.on({DeviceClass.tablet, DeviceClass.desktop},
          ScalingPatch(curve: ScalingCurve.logarithmic(0.4)), name: 'large'),
    ]);
```

See [Configuration](configuration.md) and [JSON format](json.md).

## 7. Check the numbers

```dart
debugPrint(product.explain());
// [scale#1] phone smallestWidth=411dp / ref 300 = 1.37 -> custom = 1.1417 => factor 1.1417
Text(context.explainScaling(product));
```

[Back to the custom docs](README.md)
