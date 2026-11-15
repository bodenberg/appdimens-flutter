# Cookbook

Ready-to-use strategies. Each one shows the code form and, where it matters, the JSON form.

## Grow on phones, calm down on tablets

```dart
final calm = customScaleStrategy((s) => s.sw < 600 ? s.ratio : 2 + (s.sw - 600) / 1000);
```

```dart
final calm = CustomPresets.tabletFriendly;        // linear on phones, power(0.5) on tablets, ≤ 1.8
```

## Design frame of 360 dp, never below 85% or above 160%

```dart
final brand = customScaleStrategy((s) => s.clamp(s.sw / 360, 0.85, 1.6));
```

```json
{ "id": "brand", "reference": { "width": 360, "height": 640 }, "clamp": { "min": 0.85, "max": 1.6 } }
```

## Sublinear growth (big screens grow slower)

```dart
final soft = customScaleStrategy((s) => s.pow(s.sw / 360, 0.75));
```

```json
{ "id": "soft", "reference": { "width": 360, "height": 640 }, "curve": { "type": "power", "exponent": 0.75 } }
```

## TV: scale by height, 10-foot UI

```dart
final living = customScaleStrategy((s) => s.tv ? s.clamp(s.height / 540, 1, 2) : s.ratio);
```

```json
{ "id": "living", "rules": [ { "when": { "device": "tv" },
  "set": { "axis": "height", "reference": { "width": 960, "height": 540 }, "clamp": { "min": 1, "max": 2 } } } ] }
```

## Watch: almost fixed sizes

```dart
final wrist = customScaleStrategy((s) => s.watch ? s.clamp(s.shortSide / 192, 0.85, 1.15) : s.ratio);
```

## Game HUD: shorter side, aspect-ratio aware

```dart
final hud = ScalingStrategy.define('hud',
    axis: ScalingAxis.min,
    curve: ScalingCurve.power(0.85),
    aspectRatio: true,
    minFactor: 0.75,
    maxFactor: 2.5,
    fontScale: FontScalePolicy.ignore);   // HUD text never follows the system font size
```

## Readable text: grow slowly, cap the font scale

```dart
final body = ScalingStrategy.define('body',
    curve: ScalingCurve.logarithmic(0.4), fontScale: FontScalePolicy.clamp(1.3));
Text('…', style: TextStyle(fontSize: 16.cspWith(body)));
```

## Minimum tap target

```dart
final touch = ScalingStrategy.define('touch', minValue: 48);
SizedBox.square(dimension: 40.cdpWith(touch));   // never below 48 dp
```

## Whole dp only

```dart
final snap = scalingFormulaOf((s) => s.round(s.base * s.ratio));
```

```json
{ "id": "snap", "formula": "round(base * ratio)" }
```

## Never smaller than the design value

```dart
final floor = scalingFormulaOf((s) => s.max(s.base * s.ratio, s.base));
```

## Split screen: keep the design values

```dart
final steady = ScalingStrategy.define('steady', ignoreMultiWindow: true);
```

## Landscape phones: a bit smaller

```dart
final brand = ScalingStrategy.define('brand',
    curve: ScalingCurve.power(0.8),
    rules: [
      ScalingRule(ScreenCondition(maxSmallestWidth: 600, landscape: true),
          const ScalingPatch(multiplier: 0.9)),
    ]);
```

## A/B test or remote config

```dart
final json = remoteConfig.getString('appdimens_strategies');   // a strategies document
try {
  ScalingStrategies.loadJson(json);                            // atomic: a bad document changes nothing
} catch (e) {
  debugPrint('bad strategies JSON: $e');                       // FormatException or ArgumentError
}
Padding(padding: EdgeInsets.all(16.cdpWith('brand')));
```

## One growth law for a design system

Ship a single `appdimens-strategies.json` with the design tokens, load it in every app (`ScalingStrategies.loadJson(await rootBundle.loadString(…))` on Flutter, `loadAsset` on Android, `loadJson` elsewhere), and use the ids only. Android, iOS, React Native, Web, KMP, Games and .NET read the same file and get the same numbers.

[Back to the custom docs](README.md)
