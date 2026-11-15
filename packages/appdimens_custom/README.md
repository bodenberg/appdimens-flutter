# AppDimens Custom

> Part of the **AppDimens Flutter** family — Flutter port of
> [AppDimens Dynamic](https://github.com/bodenberg/appdimens-dynamic) /
> [AppDimens KMP](https://github.com/bodenberg/appdimens-kmp).

**Your own scaling strategies.** Write the math in one line of Dart, or configure a full strategy (reference frame, axis, curve, bounds, font-scale policy, rules per device class, screen range, orientation and multi-window) that loads from the **JSON format shared with every AppDimens platform** (Android, KMP, iOS, React Native, Web, Games, .NET) with the same numbers.

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

```dart
import 'package:appdimens_custom/appdimens_custom.dart';

final product = customScaleStrategy((s) => s.clamp(s.width / 360, 0.85, 1.80));   // factor
final hud = scalingFormulaOf((s) => s.base * s.pow(s.sw / 360, 0.8));              // final value
Padding(padding: EdgeInsets.all(16.cdpWith(product)));
Text('Score', style: TextStyle(fontSize: 18.cspWith(hud)));
```

The scope `s` autocompletes `base`, `sw`, `width`, `tablet`, `pow`, `clamp`… The same formula as text, for JSON or remote config: `scalingFormula('base * pow(sw / 360, 0.8)')` or inline `16.cdpFormula('…')`. For rules and bounds: `ScalingStrategy.define('brand', …)`; to load a shared file: `ScalingStrategies.loadJson(text)`.

| File (`lib/src/`) | Contents |
|---|---|
| `custom_scope.dart` | `ScreenScope`, `FormulaScope`: the typed names of code formulas |
| `custom_strategy.dart` | `ScalingStrategy` (`define`, `extend`, `withAxis`, `explain`, `toJson`), `customScaleStrategy`, `scalingFormulaOf`, `scalingFormula`, `ScalingStrategies` registry, `BuiltInStrategies`, `CustomPresets`, device-class detection |
| `custom_extensions.dart` | `16.cdp` / `cdpWith` / `cdpFormula`, `14.csp` / `cspWith` / `cspFormula`, `…Px` variants, `context.cdp` / `context.csp` / `context.cdpFormula`, `ScalingStrategyScope`, `ScalingStrategyBuilder` |
| `custom_engine.dart` | model (`ScalingConfig`, `ScalingAxis`, `ScalingCurve`, `ScreenCondition`, `ScalingRule`, `ScalingPatch`, `FontScalePolicy`, `ScreenSnapshot`, `DeviceClass`), `resolveScaling`, `ScalingStrategyJson` |
| `custom_expression.dart` | text formula language (`ScalingExpression`, `ScalingFormula`) |

Documentation: [DOCUMENTATION/custom/](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/custom/README.md) (quick start, code formulas, text formulas, configuration, JSON, API, performance, cookbook, troubleshooting) · Schema: [custom-strategy.schema.json](https://github.com/bodenberg/appdimens-skills/blob/main/schemas/custom-strategy.schema.json)

Tests run without a device: `flutter test` in `packages/appdimens_custom`. They include the cross-platform fixture (`test/custom-strategy-fixture.json`, 540 cases) that every AppDimens platform must reproduce.

## License

Apache License 2.0 — © Jean Bodenberg.
