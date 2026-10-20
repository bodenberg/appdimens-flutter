# AppDimens Flutter — library map

**Doc base (Git ref `main`):** https://github.com/bodenberg/appdimens-flutter/blob/main/

Read this file when you need package locations, resolution-mode symmetry, or core types.

---

## Pub workspace packages (3.2.0)

| Strategy | Package | Source roots |
|---|---|---|
| scaled (+ common/core) | `appdimens_flutter` | `packages/appdimens_flutter/lib/src/{common,core,scaled,flutter}` |
| *(BOM)* | `appdimens_bom` | `packages/appdimens_bom/lib/appdimens_bom.dart` |
| auto | `appdimens_auto` | `packages/appdimens_auto/lib/src/` |
| density | `appdimens_density` | `packages/appdimens_density/lib/src/` |
| diagonal | `appdimens_diagonal` | `packages/appdimens_diagonal/lib/src/` |
| fill | `appdimens_fill` | `packages/appdimens_fill/lib/src/` |
| fit | `appdimens_fit` | `packages/appdimens_fit/lib/src/` |
| fluid | `appdimens_fluid` | `packages/appdimens_fluid/lib/src/` |
| interpolated | `appdimens_interpolated` | `packages/appdimens_interpolated/lib/src/` |
| logarithmic | `appdimens_logarithmic` | `packages/appdimens_logarithmic/lib/src/` |
| percent | `appdimens_percent` | `packages/appdimens_percent/lib/src/` |
| perimeter | `appdimens_perimeter` | `packages/appdimens_perimeter/lib/src/` |
| power | `appdimens_power` | `packages/appdimens_power/lib/src/` |
| resize | `appdimens_resize` | `packages/appdimens_resize/lib/src/` |
| units (physical) | `appdimens_units` | `packages/appdimens_units/lib/src/` |
| custom (user-defined) | `appdimens_custom` | `packages/appdimens_custom/lib/src/` (`custom_engine.dart`, `custom_strategy.dart`, `custom_extensions.dart`) |

Full graph: [DOCUMENTATION/MODULES.md](../DOCUMENTATION/MODULES.md). Satellites depend only on `appdimens_flutter`. `appdimens_bom` re-exports everything at one version. Satellite extension files are generated from [`scripts/generate_satellites.py`](https://github.com/bodenberg/appdimens-flutter/blob/main/scripts/generate_satellites.py) — edit the generator, not the generated stems.

## Source layout (`packages/appdimens_flutter`)

- **`lib/src/common/`** — shared enums/value types: `DpQualifier` (smallWidth, height, width), `Inverter` (8 mappings + standard), `DimensOrientation`, `UiModeType` (incl. fold states), `UnitType`.
- **`lib/src/core/`** — cross-cutting engine: `ScreenConfiguration` (immutable window config), `DimenMetrics` (per-window snapshot with eagerly precomputed factors: scale, width/height factors, AR multipliers, lazy satellite scales), `DimenCache` (snapshot-partitioned cache, max 4×512 entries, bypass rules identical to the Kotlin engine; `AppDimensScope` fast-lane slot; no persistence), `DimenCalculationPlumbing` (inverter resolution, axis reads, multi-window heuristic), `DimenScaledEngine` (scaled kernels incl. sp semantics), `DesignScaleConstants`, resize math (`ResizeMath`, `ResizeBound`, `AutoResizePercentBasis`, `ResizeRangePx`).
- **`lib/src/scaled/`** — Scaled family: `dimen_sdp_extensions.dart` (`num.sdp/hdp/wdp` × suffixes/inverters/Px + facilitators + Plain pairs), `dimen_ssp_extensions.dart` (`ssp/hsp/wsp` + `sem/hem/wem`), `dimen_sdp_facade.dart` (`DimenSdp`/`DimenSsp` facades + explicit-context extensions), `dimen_scaled_builder.dart` (`DimenScaled` / `ScaledSp` chains).
- **`lib/src/flutter/`** — `AppDimensApp` (observer-based root publisher), `AppDimensScopeBinder` (MediaQuery-driven in-tree publisher for `MaterialApp.builder`), `AppDimensProvider` (InheritedWidget snapshot), `publishAppDimensContext`.
- **`lib/src/internals/strategy_resolution.dart`** — shared grammar used by satellites: `StrategyFormula`, `StrategyResolution`, `StrategyBranching`, generic `StrategyChain` builder.

Satellite packages follow the same shape: `<strategy>_engine.dart` (formula + memoized default path + facade) and `<strategy>_extensions.dart` (stems × grammar).

## Resolution modes

| Mode | Entry points | Notes |
|---|---|---|
| Fast lane | `16.sdp`, `50.psdp`, … | static slot read + multiply; needs a published scope |
| Explicit context | `16.sdpOf(ctx)`, `16.toDynamicScaledDp/Px(ctx, q, …)`, `DimenSdp.sdp(ctx, v)` | deterministic 300×533 fallback without provider; ideal for tests/isolates |
| Builders | `100.scaledDp.screen(...).sdp` / `.resolve(context)`; `Dimen<Strategy>.scaled(v)` → `StrategyChain` | priority: ui+qualifier → ui → qualifier → orientation |

## Strategy → documentation file

| Package suffix | Doc |
|---------------|-----|
| scaled | [DOCUMENTATION/scaled.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/scaled.md) |
| percent | [DOCUMENTATION/percent.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/percent.md) |
| power | [DOCUMENTATION/power.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/power.md) |
| fluid | [DOCUMENTATION/fluid.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/fluid.md) |
| auto | [DOCUMENTATION/auto.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/auto.md) |
| diagonal | [DOCUMENTATION/diagonal.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/diagonal.md) |
| fill | [DOCUMENTATION/fill.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/fill.md) |
| fit | [DOCUMENTATION/fit.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/fit.md) |
| interpolated | [DOCUMENTATION/interpolated.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/interpolated.md) |
| logarithmic | [DOCUMENTATION/logarithmic.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/logarithmic.md) |
| perimeter | [DOCUMENTATION/perimeter.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/perimeter.md) |
| density | [DOCUMENTATION/density.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/density.md) |
| resize | [DOCUMENTATION/resize.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/resize.md) |
| units (physical) | [DOCUMENTATION/physical-units.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/physical-units.md) |
| custom (user-defined) | [DOCUMENTATION/custom.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/custom.md) |

**Formal docs:** [MATHEMATICS-AND-CALCULUS.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md) · [API-CONVENTIONS.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/API-CONVENTIONS.md)
**Performance:** [PERFORMANCE.md](https://github.com/bodenberg/appdimens-flutter/blob/main/PERFORMANCE.md) · [PERFORMANCE-COMPARATIVE.md](https://github.com/bodenberg/appdimens-flutter/blob/main/PERFORMANCE-COMPARATIVE.md)

---

## Apps (not published to pub.dev)

Use for pattern reference:

- **Sample** — [main.dart](https://github.com/bodenberg/appdimens-flutter/blob/main/apps/sample/lib/main.dart) (demo sections) · [demo_routing.dart](https://github.com/bodenberg/appdimens-flutter/blob/main/apps/sample/lib/demo_routing.dart) (12-strategy dispatch) · [benchmark_screen.dart](https://github.com/bodenberg/appdimens-flutter/blob/main/apps/sample/lib/benchmark_screen.dart) (calc/micro/macro/compare dashboard)
- **BenchLab** — [main.dart](https://github.com/bodenberg/appdimens-flutter/blob/main/apps/benchlab/lib/main.dart) · [benchmark_runner.dart](https://github.com/bodenberg/appdimens-flutter/blob/main/apps/benchlab/lib/benchmark_runner.dart) (UI probe, isolate probe, legacy passes) · [engine audit test](https://github.com/bodenberg/appdimens-flutter/blob/main/apps/benchlab/test/engine_benchmark_test.dart)

---

## Internal `CalcType`

Debug/cache tagging only — end users think in strategy names. Values: auto, diagonal, fill, fit, fluid, interpolated, logarithmic, percent, perimeter, power, resize, scaled, unities, aspectRatio, density.
Source: [dimen_cache.dart](https://github.com/bodenberg/appdimens-flutter/blob/main/packages/appdimens_flutter/lib/src/core/dimen_cache.dart)

---

## What this file intentionally omits

`ignoreMultiWindows`, `*i`, and `*ia` suffix workflows — omitted from the interactive guidance.
