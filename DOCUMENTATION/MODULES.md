# Modules — AppDimens Flutter 3.2

The library ships as a **principal artifact** (`appdimens_flutter` = common + core +
scaled) plus optional strategy satellites and an all-in-one meta-package — the
same packaging philosophy as `appdimens-kmp` / `appdimens-dynamic`.

## Package graph

```text
                        ┌────────────────┐
                        │  appdimens_bom │  (meta: re-exports everything)
                        └───────┬────────┘
                                │
        ┌───────────────────────┼───────────────────────────┐
        ▼                       ▼                           ▼
 appdimens_percent   appdimens_power   …   appdimens_units
        │                       │                           │
        └───────────────┬───────┴─────────────┬─────────────┘
                        ▼                     ▼
                  ┌───────────────────────────────┐
                  │       appdimens_flutter       │  ← principal artifact
                  │  common · core · scaled       │
                  └───────────────────────────────┘
```

## Artifacts

| Package | Contents |
|---|---|
| **`appdimens_flutter`** | `common` enums (`DpQualifier`, `Inverter`, `UiModeType`, …), `core` engine (`ScreenConfiguration`, `DimenMetrics`, `DimenCache`, `DimenScaledEngine`, plumbing), **scaled** families + facilitators, `AppDimensProvider`/`AppDimensApp`, resize math primitives |
| **`appdimens_percent`** | Percent curves + literal space family (`spaceW/spaceH/spaceSw`) |
| **`appdimens_power`** | Sub-linear power curve `(d/300)^0.75` |
| **`appdimens_fluid`** | Clamped lerp between `b×0.8` and `b×1.2` over `[320, 768]` |
| **`appdimens_auto`** | Linear phones / log-damped tablets (480 dp transition) |
| **`appdimens_diagonal`** | Screen-diagonal ratio |
| **`appdimens_fill`** | CSS cover ratio |
| **`appdimens_fit`** | CSS contain ratio |
| **`appdimens_interpolated`** | Fixed 50 % blend between raw and scaled |
| **`appdimens_logarithmic`** | Symmetric ±0.4·ln damping |
| **`appdimens_perimeter`** | Half-perimeter ratio |
| **`appdimens_density`** | Physical-density alignment (dpi/160) |
| **`appdimens_resize`** | Constraint auto-fit widgets (`AutoResizeText`, `AutoResizeSquare`) + range search |
| **`appdimens_units`** | mm/cm/inch ↔ dp/px/sp conversions |
| **`appdimens_bom`** | Re-exports all of the above at one version |

## Dependency rules

1. Satellites depend **only** on `appdimens_flutter` (never on each other) — you can
   adopt exactly the strategies you need.
2. The shared grammar lives in `appdimens_flutter`' internal
   `strategy_resolution.dart`; satellites contribute only their formula.
3. Apps may depend on `appdimens_bom` for convenience or on individual
   satellites to keep the dependency tree minimal.

## Generation

The satellite packages share their extension grammar via
[`scripts/generate_satellites.py`](../scripts/generate_satellites.py). The
script is the single source of truth for stems, suffix sets, inverters,
facilitators and sp twins; per-strategy formulas are configured in its
`STRATEGIES` table together with their memoized default-path factors.

## Sample & BenchLab

| App | Path | Purpose |
|---|---|---|
| Sample | [`apps/sample`](../apps/sample) | Strategy-routing demo + benchmark dashboard (converted from the KMP/Dynamic sample app) |
| BenchLab | [`apps/benchlab`](../apps/benchlab) | Competitor benchmark: UI probe, isolate probe, legacy passes, resolution parity, report export |
