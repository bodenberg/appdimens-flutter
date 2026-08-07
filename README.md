# AppDimens for Flutter

Dimensionamento responsivo, previsível e multiplataforma para **Android, iOS,
web, Windows, macOS e Linux**. O porte 3.1.6 oferece 13 estratégias imutáveis,
uma API compatível com o legado `fixed`/`dynamic` e um caminho rápido que pode
ser calculado sem `BuildContext`.

> Flutter usa pixels lógicos em todas as plataformas. O AppDimens trabalha
> nesse espaço e só converte para pixels físicos quando isso é solicitado.

## Instalação

```yaml
dependencies:
  appdimens: ^3.1.6
```

```dart
import 'package:appdimens/appdimens.dart';
```

## Início rápido

```dart
final gap = AppDimens.balanced(16).calculate(context);
final title = AppDimens.fluid(18, maxValue: 28).calculate(context);
final heroWidth = AppDimens.percentage(80).calculate(context); // 80% da largura

// Atalhos equivalentes
final icon = 24.0.logarithmic().calculate(context);
final card = 320.balanced().calculate(context);
```

Para `CustomPainter`, delegates ou loops que já conhecem a viewport, evite a
consulta ao widget tree:

```dart
final size = AppDimens.balanced(16).calculateFor(const Size(1440, 900));
```

Para o caminho mais rápido e totalmente determinístico, construa o snapshot
uma vez e reutilize-o:

```dart
const viewport = AppDimensViewport(width: 1440, height: 900);
const scale = AppDimensScale(16, strategy: AppDimensStrategy.balanced);
final size = scale.calculateViewport(viewport);
```

## As 13 estratégias

| Estratégia | Uso recomendado | Comportamento |
|---|---|---|
| `none` | valores invariáveis | mantém o valor original |
| `defaultScaling` | layouts baseados na largura | escala linear por um eixo |
| `balanced` ⭐ | UI geral multiplataforma | média geométrica dos eixos |
| `percentage` | containers e áreas | percentual da largura/altura |
| `logarithmic` | ícones/botões em telas grandes | crescimento desacelerado |
| `power` | ajuste fino | curva exponencial configurável |
| `fluid` | tipografia e espaçamento | interpolação limitada por breakpoints |
| `interpolated` | crescimento uniforme | média aritmética dos eixos |
| `diagonal` | mídia e jogos | proporção da diagonal |
| `perimeter` | painéis e superfícies | proporção do perímetro |
| `fit` | conteúdo totalmente visível | menor escala entre os eixos |
| `fill` | conteúdo cobrindo a área | maior escala entre os eixos |
| `autosize` | componentes adaptativos | patamares por menor dimensão |

Todas aceitam uma `designSize` quando aplicável. `power` aceita `exponent`;
`percentage` aceita `Axis`; e `fluid` recebe valores e larguras mínima/máxima.

## API inteligente

```dart
final button = AppDimens.smart(48)
    .forElement(ElementType.button)
    .calculate(context);
```

As dicas semânticas selecionam uma estratégia estável: texto usa `fluid`,
containers usam `percentage`, espaçamento usa `balanced` e controles usam
`logarithmic`. A seleção é explícita e inspecionável, sem heurística de runtime.

## Compatibilidade com o porte anterior

As APIs abaixo continuam disponíveis:

```dart
final fixed = AppDimens.fixed(16).calculate(context);
final dynamic = AppDimens.dynamic(16).calculate(context);
final oldExtensions = 16.fx.calculate(context) + 16.dy.calculate(context);
```

Qualificadores de dispositivo, UI mode, orientação-base, unidades `dp`, `px`,
`sp`, `mm`, `cm` e polegadas também permanecem exportados pelo pacote completo.

Overrides são determinísticos. A precedência é: interseção UI+largura, UI mode,
dispositivo, qualificador `sw`, dispositivo+largura, resolução de tela e, por
último, o algoritmo. Em qualificadores numéricos, vence o maior breakpoint que
a viewport satisfaz.

## Modularidade e equivalente ao BOM

Dart/pub resolve uma única versão por pacote e não possui BOM como Maven ou
Gradle. Portanto, o próprio `pubspec.lock` da aplicação cumpre a função de
alinhar versões. Para reduzir superfície de imports sem fragmentar versões:

```dart
import 'package:appdimens/appdimens_core.dart';  // engine, tipos e orientação
import 'package:appdimens/appdimens_units.dart'; // conversões opcionais
```

O barrel `appdimens.dart` continua sendo a opção “BOM”: exporta todos os módulos
da mesma release, impossibilitando versões internas incompatíveis.

## Desempenho

* `AppDimensScale` e `AppDimensViewport` são imutáveis e pequenos;
* `calculateFor(Size)` não consulta inherited widgets;
* o caminho direto de cálculo não aloca mapas, strings nem closures;
* cada cálculo faz apenas as operações exigidas por sua estratégia;
* `MediaQuery.sizeOf` assina somente mudanças de tamanho, reduzindo rebuilds;
* use `const AppDimensScale(...)` e reutilize builders em hot paths.

O repositório inclui um benchmark reproduzível:

```sh
flutter test benchmark/engine_benchmark_test.dart
```

Meça no hardware e no modo release da aplicação: microbenchmarks em debug não
representam AOT, GPU, layout ou custo de rasterização reais.

## Multiplataforma, orientação e janelas

O cálculo depende da viewport atual, e não de modelos fixos de aparelhos. Isso
faz resize no desktop/web, split-screen, Stage Manager e rotação atualizarem o
resultado naturalmente. `fit` e `fill` usam ambos os eixos; `percentage` permite
escolher o eixo. A API legada oferece `BaseOrientation` para designs com uma
orientação-base específica.

## Acessibilidade

AppDimens dimensiona o valor do layout. Para texto, mantenha o
`MediaQuery.textScaler` do Flutter ativo; não neutralize a preferência do
usuário. Use `fluid` para limitar a escala do design, não a escala acessível da
fonte.

## Qualidade e contribuição

O GitHub Actions executa três pipelines complementares:

* `CI`: formatação, análise, testes VM/web, cobertura, exemplo web e dry-run;
* `Workstation platforms`: testes e builds reais em Linux, Windows e macOS;
* `Publish package`: valida versão/tag e publica no pub.dev com OIDC.

Atualizações de Actions e dependências pub são monitoradas pelo Dependabot.

Antes de enviar mudanças:

```sh
dart format --set-exit-if-changed lib test example/lib
flutter analyze
flutter test
flutter test --platform chrome
flutter pub publish --dry-run
```

O pacote usa Apache-2.0. Issues e contribuições são bem-vindas no repositório.
