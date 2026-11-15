# Custom strategies: agent reference

Use when the user wants their own scaling (a formula, per-device rules, a shared JSON) instead of a built-in. Docs: [DOCUMENTATION/custom/](../DOCUMENTATION/custom/README.md) (start at `README.md`). Package: `appdimens_custom`, import `package:appdimens_custom/appdimens_custom.dart`.

## Decide the form

1. **A built-in passes visual QA?** Keep it. Custom strategies are for when none fits.
2. **The user describes math** ("scale by width over 360, between 0.85 and 1.8"):
   - multiplies every value → `customScaleStrategy((s) => s.clamp(s.width / 360, 0.85, 1.8))`
   - computes the final value from `base` → `scalingFormulaOf((s) => s.base * s.pow(s.sw / 360, 0.8))`
3. **The formula must live in JSON / remote config / design tokens** → text: `scalingFormula('base * pow(sw / 360, 0.8)')`, `16.cdpFormula('…')`, JSON `"formula"`.
4. **Different behavior per device / screen range / orientation, bounds, font-scale cap** → `ScalingStrategy.define('id', …, rules: [ScalingRule.on({DeviceClass.tablet}, ScalingPatch(…))])` or the JSON document.
5. **Several apps or platforms share it** → the JSON document, loaded once (`ScalingStrategies.loadJson(await rootBundle.loadString('assets/appdimens-strategies.json'))`).

## Cheat sheet

```dart
import 'package:appdimens_custom/appdimens_custom.dart';
// 16.cdpWith(s): dp · 14.cspWith(s): fontSize · cdpPxWith / cspPxWith: px · context.cdp(16, s)

final product = customScaleStrategy((s) => s.clamp(s.width / 360, 0.85, 1.8));
final hud = scalingFormulaOf((s) => s.base * s.pow(s.sw / 360, 0.8));
final brand = ScalingStrategy.define('brand',
    reference: ReferenceScreen(width: 360, height: 640), curve: ScalingCurve.power(0.8),
    minFactor: 0.85, maxFactor: 1.6, fontScale: FontScalePolicy.clamp(1.3),
    rules: [ScalingRule.on({DeviceClass.tablet, DeviceClass.desktop},
        ScalingPatch(curve: ScalingCurve.logarithmic(0.4)))]);
ScalingStrategies.defaultStrategy = brand;               // 16.cdp / 14.csp without argument
ScalingStrategyScope(strategy: hud, child: …);           // context.cdp / context.csp below it
```

Scope names (code and text; in code read them as `s.name`): `base` (formula only) `sw width height shortSide longSide diagonal perimeter aspectRatio ratio density fontScale device screen`, flags `phone tablet desktop tv watch car vr landscape portrait multiWindow`, math `pow sqrt ln log10 exp abs round min max clamp lerp smoothstep`. `ratio = sw / 300`, so `s.base * s.ratio` = `sdp`.

## Rules an agent must follow

- **Declare strategies once** (top-level `final`, `static final` in an `AppStrategies` class, or JSON). Never build `customScaleStrategy` / `scalingFormulaOf` inside `build`: each call is a new strategy with an empty memo. Inline text (`16.cdpFormula('…')`) is shared per text and is fine.
- **Functions are pure**: no state, settings or time inside. Different state → different strategy or a rule.
- **Prefer a factor** when the math is `base × screen-term`: `customScaleStrategy`, a curve, or text shaped `base * (…)` all cost one multiply. `scalingFormulaOf` runs on every call. `base * sw / 360` misses the text fast path; write `base * (sw / 360)`.
- **No overloading in Dart**: `cdpWith(x)` takes a `ScalingStrategy` or an id; text goes through `cdpFormula` / `cspFormula` / `cdpPxFormula` / `cspPxFormula`.
- **Value bounds** (`minValue` / `maxValue`) only for real absolute limits (tap targets, max text); they must be ≥ 0.
- **Text vs code**: code functions cannot be exported to JSON (`toJson()` throws `StateError`); use text when the user mentions JSON, remote config, A/B tests or other platforms.
- **Text sizes**: pass `csp` / `cspWith` straight to `fontSize`; Flutter applies the `TextScaler` and the policy is pre-compensated. Use `context.*` helpers or `ScalingStrategyBuilder` when the widget must rebuild on window changes.

## Verify

- `brand.explain()` / `context.explainScaling(brand)` prints the axis, curve, factor, applied rules and formula. `brand.resolveScreen(ScreenSnapshot(widthDp: 800, heightDp: 1280))` checks any window in a test.
- Errors: text formulas throw `FormatException` with the position; JSON throws `FormatException` with the path (bounds and a missing default: `ArgumentError`); a non-finite factor throws `StateError`. See [troubleshooting](../DOCUMENTATION/custom/troubleshooting.md).
- JSON files: `npx appdimens-skills kit custom check <file>` and `kit custom explain --formula "<text>" --devices medium-phone,medium-tablet`.
- `flutter test` in `packages/appdimens_custom` (includes the 540-case cross-platform fixture).
