# AppDimens Dynamic for Flutter

Porte Flutter **3.1.6** com o mesmo modelo mental e a mesma matemática do
[AppDimens Dynamic Android](https://github.com/bodenberg/appdimens-dynamic) e do
[AppDimens Apple](https://github.com/bodenberg/appdimens-ios). Android `dp`, Apple points e
Flutter logical pixels ocupam o mesmo papel no layout.

Referências auditadas: Android `e5d904fb12dd214cc9e22e20937216fa686c8e4e` e Apple
`9f1ab1030e69d4a41f5caecde1e8231f2299b9a0`.

## Instalação e módulos

```yaml
dependencies:
  appdimens: ^3.1.6
```

| AppDimens Dynamic | Flutter entrypoint |
|---|---|
| principal (`scaled`, common/core/plain) | `package:appdimens/appdimens_core.dart` |
| strategies | `package:appdimens/appdimens_strategies.dart` |
| auto | `package:appdimens/appdimens_auto.dart` |
| resize | `package:appdimens/appdimens_resize.dart` |
| units | `package:appdimens/appdimens_units.dart` |
| BOM/aggregate | `package:appdimens/appdimens.dart` |

O pub resolve uma única versão do pacote; por isso o aggregate é o equivalente seguro ao BOM.

## Quick start — Scaled

```dart
final c = context.dimensConfiguration;

final padding = 16.sdp(c);
final width = 100.wdp(c);
final height = 48.hdp(c);
final text = 16.ssp(c);
final textIgnoringSystemScale = 16.sem(c);
```

| API | Base |
|---|---|
| `sdp` / `ssp` / `sem` | menor dimensão da janela |
| `wdp` / `wsp` / `wem` | largura atual |
| `hdp` / `hsp` / `hem` | altura atual |
| sufixo `a` | correção opcional de aspect ratio |
| sufixo `i` | preserva o token em multi-window |
| sufixo `ia` | combina ambos |

## Configuração Flutter

```dart
AppDimensProvider(
  config: const AppDimensConfig(uiMode: UiModeType.television),
  child: MyApp(),
)
```

`context.dimensConfiguration` lê uma única janela Flutter via `MediaQuery`. Para testes,
renderizadores ou isolates, construa o snapshot diretamente:

```dart
const c = DimensConfiguration(
  screenWidth: 390,
  screenHeight: 844,
  displayScale: 3,
  fontScale: 1.2,
);
```

## Builders equivalentes

```dart
final value = 16.scaledDp
    .screen(20, qualifier: DpQualifier.smallWidth, minimum: 600)
    .mode(24, UiModeType.television)
    .rotate(18)
    .aspectRatio()
    .ignoreMultiWindows()
    .resolve(c);
```

`ScaledDp` e `AutoDp` são imutáveis. `AutoDp` usa a mesma prioridade da referência:
modo > qualifier > orientação; depois maior threshold e ordem de declaração.

## Estratégias

```dart
final power = 16.dynamic(
  DimensStrategy.power,
  c,
  options: const StrategyOptions(power: .75),
);
final direct = 16.powerDp(c);
```

| Estratégia | Fórmula |
|---|---|
| scaled/auto | `v × d/300` |
| density | `v × d/300 × displayScale` |
| diagonal | `v × hypot(w,h)/hypot(300,533)` |
| perimeter | `v × (w+h)/833` |
| fit/fill | `v × min/max(w/300,h/533)` |
| interpolated | `v × [1+(d/300−1)t]` |
| power | `v × (d/300)^p` |
| logarithmic | amortecimento `0.4 × ln(d/300)` |
| percent | `d × percent × v / 10,000` |
| fluid | interpolação limitada de viewport e escala |
| plain/physical | identidade |

`DimensFactors` pré-calcula fatores imutáveis para hot loops:

```dart
final factors = DimensFactors(c);
final frameValue = factors.resolve(16, DimensStrategy.diagonal);
```

## Qualifiers e inverters

`DpQualifier.smallWidth`, `.width` e `.height` correspondem diretamente à principal.
Também estão presentes os oito mapeamentos: `phToLw`, `pwToLh`, `lhToPw`, `lwToPh`,
`swToLh`, `swToLw`, `swToPh` e `swToPw`. Como `default` é palavra reservada em Dart,
o caso neutro chama-se `Inverter.standard`.

## Resize e unidades

```dart
final candidates = DimensResize.steps(minimum: 12, maximum: 32, step: 2);
final best = DimensResize.largestFitting(candidates, (v) => measure(v));
final mm = DimensUnits.points(10, from: PhysicalUnit.millimeter, configuration: c);
```

Conversões físicas seguem `72 points = 1 inch`. Informe `pixelsPerInch` para pixels
fisicamente calibrados; `displayScale` não é PPI.

## Validação

```sh
dart format --output=none --set-exit-if-changed lib test benchmark
flutter analyze --fatal-infos
flutter test
flutter test benchmark/engine_benchmark_test.dart
flutter pub publish --dry-run
```

Suporta Android, iOS, web, Windows, macOS e Linux sem código nativo por plataforma.
