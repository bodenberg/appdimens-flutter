# Migration — deprecated `appdimens` 2.x → AppDimens 3.2

This branch **replaces** the deprecated Flutter library (`fx`/`dy`
builders) with a faithful port of the AppDimens Dynamic/KMP family. The old
API is gone; this guide maps every old concept to its new home.

## Concept map

| Deprecated 2.x | AppDimens 3.2 | Notes |
|---|---|---|
| `AppDimens.fixed(100).calculate(ctx)` | `100.sdpOf(ctx)` or `100.sdp` | logarithmic "fixed" model replaced by the family's Scaled curve |
| `AppDimens.dynamic(100).calculate(ctx)` | `100.sdpOf(ctx)` | proportional model = Scaled |
| `100.0.fx` / `100.dy` | `100.sdp` | extension-based, no context needed under the provider |
| `AppDimensFluid(16, 24)` | `16.fsdp` (fluid package) | plateaus ±20% over [320, 768] |
| `fluidTo(max)` / `fluidFrom(min)` | `16.fsdp` | single fluid family with clamps |
| `fxPadding()` / `dyPadding()` | `EdgeInsets.all(16.sdp)` | explicit and composable |
| `fxFontSize(18, ctx)` | `18.ssp` (or `18.sem` to ignore font scale) | |
| `AppDimensProvider` (config object) | `AppDimensApp` / `AppDimensScopeBinder` | actually publishes metrics now |
| `AppDimensUtils.calculateAdjustmentFactors` | internal engine (AR multipliers) | exposed via the `a` suffix |
| `dynamicPercentage(p, ctx)` | `(p*100).spaceW` (percent package) | literal percent of an axis |
| `calculateAvailableItemCount` | keep local; or `DimenResize` fitting helpers | |
| `DeviceType`/`ScreenQualifier` tables | `UiModeType` + `DpQualifier` facilitators | `30.sdpMode(200, UiModeType.television)`, `60.sdpQualifier(…)` |
| custom-value builders (`screen(deviceType:…)`) | `DimenScaled` chain | priority model: ui+qualifier → ui → qualifier → orientation |

## Why the breaking change?

The deprecated API advertised 13 strategies that did not exist, had
never-matching qualifier branches, inert caches/configs and a per-call
instance model measured at **microseconds** per call. Version 3.2 ports the
audited Kotlin engine instead: bit-parity formulas, a snapshot fast lane
(~6–12 ns), a real cache, and the full family grammar (`a/i/ia`, inverters,
facilitators, builders) shared with appdimens-dynamic and appdimens-kmp.

## Step-by-step

1. **Replace the dependency** with the new packages (main + the strategy
   satellites you need, or `appdimens_bom`).
2. **Wrap the app**: `AppDimensApp(child: MaterialApp(...))` (or add
   `AppDimensScopeBinder` inside `MaterialApp.builder`).
3. **Mechanical swaps** using the table above — most code is
   `fx/dy` → `sdp/wdp/hdp`.
4. **Delete** `ScreenInfo`/`DeviceType` branching; express it as
   facilitators or builder chains.
5. Run the app: without a provider the getters resolve against the 300×533
   reference, so unit tests stay deterministic.

## Versioning

- Deprecated line: `2.0.0` (and the `1.1.0` constant inside it).
- This line: **3.2.0**, aligned with the AppDimens Dynamic 3.x family so the
  whole ecosystem shares one version grammar.
