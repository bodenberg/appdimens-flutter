# AppDimens Custom

> Part of the **AppDimens Flutter** family — Flutter port of
> [AppDimens Dynamic](https://github.com/bodenberg/appdimens-dynamic) /
> [AppDimens KMP](https://github.com/bodenberg/appdimens-kmp).

**Your own scaling strategies.** A strategy combines:
- a reference frame and an axis;
- a curve: linear, power, logarithmic, interpolated, constant, breakpoints, a free-form text expression (`ScalingCurve.expression('pow(ratio, 0.8) * (tablet ? 0.9 : 1)')`), or a function;
- an optional per-value text formula (`formula: 'max(scaled, base)'`);
- factor and value bounds, plus a font-scale policy;
- rules per device class, screen range, orientation and multi-window.

You can define it in Dart or load it from the **JSON format shared with every AppDimens platform** (Android, KMP, iOS, React Native, Web, Games, .NET).

## Installation

```bash
flutter pub add appdimens_custom
```

```yaml
dependencies:
  appdimens_custom: ^3.2.0
```

> Prefer one dependency for everything? [`appdimens_bom`](https://pub.dev/packages/appdimens_bom) re-exports this package too.

## Usage

The simplest way is to write the math as ordinary Dart on one line; the scope (`s`) autocompletes `base`, `sw`, `width`, `tablet`, `pow`, `clamp`…

```dart
import 'package:appdimens_custom/appdimens_custom.dart';

final product = customScaleStrategy((s) => s.clamp(s.width / 360, 0.85, 1.80));   // factor, once per window
final hud = scalingFormulaOf((s) => s.base * s.pow(s.sw / 360, 0.8));              // final value
SizedBox(width: 48.cdpWith(hud));
final remote = scalingFormula('base * pow(sw / 360, 0.8)');   // same as text, for JSON / remote config
Padding(padding: EdgeInsets.all(16.cdpFormula('base * pow(sw / 360, 0.8)')));     // text, inline
```

Text formulas shaped `base * (…)` (no `base` inside the parentheses) cost one multiply per value. For rules, bounds and a font-scale policy, use the full configuration:

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

Padding(padding: EdgeInsets.all(16.cdpWith(brand)),
    child: Text('Hello', style: TextStyle(fontSize: 14.cspWith(brand))));

// Scope: context.cdp / context.csp use the nearest strategy.
ScalingStrategyScope(strategy: brand, child: Builder(builder: (context) =>
    SizedBox(width: context.cdp(48))));

// Global default: 16.cdp / 14.csp
ScalingStrategies.defaultStrategy = brand;

// JSON (same file as Android / iOS / Web…)
ScalingStrategies.loadJson(await rootBundle.loadString('assets/appdimens-strategies.json'));

// Presets and built-ins
CustomPresets.tvSafe;  BuiltInStrategies.power.extend('soft', curve: ScalingCurve.power(0.6));

debugPrint(brand.explain()); // factor breakdown + applied rules
```

| API | Returns |
|---|---|
| `16.cdp` / `16.cdpWith(s)` / `context.cdp(16)` / `s.dp(16)` | dp (logical pixels) |
| `14.csp` / `14.cspWith(s)` / `context.csp(14)` / `s.sp(14)` | `fontSize`; Flutter applies its TextScaler, and the strategy policy is pre-compensated |
| `s.spDp(14)` | final text size in dp |
| `16.cdpPx` / `s.px(16)` / `s.spPx(14)` | physical pixels |
| `16.cdpFormula('…')` / `14.cspFormula('…')` / `cdpPxFormula` / `cspPxFormula` / `context.cdpFormula(16, '…')` | same, with a text formula (shared per text) |

Guide: [DOCUMENTATION/custom.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/custom.md) · Schema: [custom-strategy.schema.json](https://github.com/bodenberg/appdimens-skills/blob/main/schemas/custom-strategy.schema.json)

## License

Apache License 2.0 — © Jean Bodenberg.
