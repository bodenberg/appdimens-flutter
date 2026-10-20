# API Conventions — AppDimens Flutter

> The complete catalog of the shared grammar. Identical rules apply to every
> strategy — learn once, use everywhere (same contract as the Kotlin
> `COMPOSE-API-CONVENTIONS.md`).

## 1. Naming grammar

```text
[stem][axis][suffix][Px]

stem  : '' (scaled) | p | pw | f | a | dg | fl | ft | i | log | pr | d
axis  : sdp (smallest width) | hdp (height) | wdp (width)
suffix: '' | a | i | ia | Ph/Lh/Pw/Lw (+ optional a/i/ia after the inverter)
Px    : physical-pixel twin
```

Examples: `sdp`, `sdpa`, `sdpi`, `sdpia`, `sdpPh`, `sdpPha`,
`pwsdp`, `pwsdpLhia`, `logsdpPx`, `pssp` (sp), `psem` (no font scale).

## 2. Suffixes

| Suffix | Effect |
|---|---|
| *(none)* | default curve |
| **a** | aspect-ratio aware multiplier (`1 + k·ln(AR/1.78)`) |
| **i** | ignore multi-window — returns the raw base inside split-screen |
| **ia** | both |
| **Px** | returns physical pixels instead of logical dp |

## 3. Inverters

| Token | Base axis | Swaps to | When |
|---|---|---|---|
| `Ph` | SMALL_WIDTH | height | portrait |
| `Pw` | SMALL_WIDTH | width | portrait |
| `Lh` | SMALL_WIDTH | height | landscape |
| `Lw` | SMALL_WIDTH | width | landscape |
| `Lw` | HEIGHT | width | landscape (`hdpLw`) |
| `Pw` | HEIGHT | width | portrait (`hdpPw`) |
| `Lh` | WIDTH | height | landscape (`wdpLh`) |
| `Ph` | WIDTH | height | portrait (`wdpPh`) |

## 4. Facilitators

Every strategy stem exposes:

```dart
50.sdpRotate(70, orientation: OrientationRequest.landscape)   // conditional value + full scaling
30.sdpMode(200, UiModeType.television)
60.sdpQualifier(120, DpQualifier.smallWidth, 600)
40.sdpScreen(150, UiModeType.television, DpQualifier.smallWidth, 600)
```

Plus logic-only **Plain** pairs that pick between two *already-resolved*
values without scaling anything twice:

```dart
16.sdpRotatePlain(24, orientation: OrientationRequest.portrait)
30.sdpModePlain(60, UiModeType.television)
30.sdpQualifierPlain(60, DpQualifier.smallWidth, 360)
30.sdpScreenPlain(60, UiModeType.television, DpQualifier.smallWidth, 360)
```

**Nesting order is lexical**: in `30.sdpRotatePlain(...).xModePlain(...)`
the outer call resolves first — different from builder chains where priority
is defined by entry level (§5).

## 5. Builders

```dart
final chain = 100.scaledDp                 // or DimenSdp.scaled(100)
    .withAspectRatio(sensitivityK: null)   // optional AR curve
    .withIgnoreMultiWindows()              // optional suppression
    .screen(UiModeType.television, DpQualifier.smallWidth, 600, 250) // P1
    .screenMode(UiModeType.television, 500)                          // P2
    .screenQualifier(DpQualifier.smallWidth, 600, 150)               // P3
    .screenOrientation(OrientationRequest.landscape, 120);           // P4
```

Priority resolution (first match wins): **P1 ui-mode + qualifier +
orientation → P2 ui-mode → P3 qualifier → P4 orientation**; ties break by
larger qualifier threshold then declaration order. Terminals:
`.resolve(context)` / `.sdp` · `.hdp` · `.wdp` through the published scope.
Satellites expose the same model via their facade
(`DimenPercent.scaled(100)…`, `DimenAuto.scaled(100)…`) built on the generic
`StrategyChain`.

## 6. Resolution modes (Flutter adaptations)

| Mode | API | Use when |
|---|---|---|
| **Fast lane** (default) | `16.sdp`, `50.psdp`, … | inside the widget tree under `AppDimensApp`/`AppDimensScopeBinder` — one static read + multiply |
| **Explicit context** | `16.sdpOf(context)`, `16.toDynamicScaledDp(ctx, q, …)`, facades `DimenSdp.sdp(ctx, v)` | tests, isolates, code before the first frame |
| **Builder scope** | `100.scaledDp.sdp` / `.resolve(context)` | conditional chains |

The fast lane reads the snapshot published by `AppDimensProvider` (or the
fallback baseline). Without any provider the getters still work and resolve
against the 300×533 reference configuration — deterministic in tests.

## 7. sp families

| Family | Meaning |
|---|---|
| `ssp / hsp / wsp` (+ prefix per strategy) | scaled text size; the framework applies the system font scale at render |
| `…sspPx` | rendered physical pixels (density × fontScale included) |
| `sem / hem / wem` | pre-divides by the font scale so rendering cancels it ("ignore system font scale") |

### Custom strategies (`appdimens_custom`)

Custom strategies carry their own axis, aspect-ratio, multi-window and font-scale settings, so they have no prefix × suffix grid:

| Form | Meaning |
|---|---|
| `16.cdp` / `14.csp` / `16.cdpPx` / `14.cspPx` | default strategy (`ScalingStrategies.defaultStrategy`) |
| `16.cdpWith(s)` / `14.cspWith(s)` (instance or id) | explicit strategy |
| `context.cdp(16)` / `context.csp(14)` | nearest `ScalingStrategyScope`, rebuilds on `MediaQuery` changes |
| `s.dp(16)` · `s.sp(14)` · `s.spDp(14)` · `s.px(16)` | strategy-first |

`csp` / `s.sp` return a `fontSize` (Flutter applies the `TextScaler`); the strategy's font-scale policy is pre-compensated. See [custom.md](custom.md).

## 8. Complete scaled property catalog

For each of the three axes (`sdp/hdp/wdp`):

```text
sdp  sdpa  sdpi  sdpia                       sdpPx  sdpaPx  sdpiPx  sdpiaPx
sdpPh sdpPha sdpPhi sdpPhia                 sdpPhPx
sdpLh sdpLha sdpLhi sdpLhia                 sdpLhPx
sdpPw sdpPwa sdpPwi sdpPwia                 sdpPwPx
sdpLw sdpLwa sdpLwi sdpLwia                 sdpLwPx
```

…mirrored by `hdp*` (with `Lw`/`Pw` inverters), `wdp*` (with `Lh`/`Ph`),
the `ssp/hsp/wsp` families and the no-font-scale `sem/hem/wem` sets.
Satellite strategies repeat the same grid with their stem
(`psdp…`, `pwsdp…`, `fsdp…`, `asdp…`, `dgsdp…`, `flsdp…`, `ftsdp…`,
`isdp…`, `logsdp…`, `prsdp…`, `dsdp…`).

## 9. Maintenance checklist (porting from the Kotlin family)

1. New suffix/inverter? Update the generator table, regenerate satellites,
   run the parity vectors.
2. New strategy? Add an entry to `STRATEGIES` with its formula, memoized
   factor (if any), stem and calc-type; add a doc guide + vectors.
3. Never change a formula without regenerating `reference_vectors.dart`.
4. Keep bypass rules of `DimenCache.shouldBypassCache` aligned with §8 of
   MATHEMATICS-AND-CALCULUS.md.
