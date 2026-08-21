# AppDimens Flutter 3.2 — Conversion Plan (KMP + Dynamic → Flutter)

> Branch: `feature/appdimens-flutter-3.2.0-modular`
> Sources analyzed: `appdimens-kmp` 1.0.1 (7 platforms) · `appdimens-dynamic` 3.1.9 (Android)
> Target: complete replacement of the deprecated `appdimens` Flutter package on `main`.

---

## 1. Analysis summary (what was extracted)

### 1.1 Shared math core (bit-identical contract)

| Constant | Value | Origin |
|---|---|---|
| `BASE_WIDTH_DP` | `300.0` | Design reference (sw) |
| `BASE_HEIGHT_DP` | `533.0` | Design reference (h) |
| `BASE_DIAGONAL_DP` | `611.6305` | √(300²+533²) |
| `BASE_PERIMETER_DP` | `833.0` | 300+533 |
| `REFERENCE_ASPECT_RATIO` | `1.78` | 16:9 |
| `INV_REFERENCE_ASPECT_RATIO` | `0.5617978` | 1/1.78 |
| `INV_BASE_RATIO` | `0.0033333334` | 1/300 |
| `ADJUSTMENT_SCALE` | `0.0033333334` | 0.10/30 |
| `SENSITIVITY_DEFAULT` | `0.0026666667` | 0.08/30 |

**Scaled kernel** (`sdp/hdp/wdp`, qualifier q, inverter inv):
```
q'   = effectiveQualifier(q, inv, orientation)
if multiWindowConstrained && ignoreMultiWindows: return base
scale = axisDp(q') / 300
if AR: base * (1 + (sw − 300) × (ADJUSTMENT_SCALE + k × ln(AR/1.78)))    // k=null → SENSITIVITY_DEFAULT
else:  base * scale
PX = dp × density ; SP px = dp × density × fontScale
```

**Per-window snapshot** (`DimenMetrics`): precomputed `scale`, `screenWidthFactor`,
`screenHeightFactor`, `defaultAspectRatioMultiplier = 1 + k_def·lnAR`,
`defaultScaledAspectRatioMultiplier = 1 + (sw−300)(ADJ_SCALE + k_def·lnAR)`,
lazy satellite scales: power `(sw/300)^0.75`, interpolated `1+(sw/300−1)×0.5`,
diagonal `√(min²+max²)/611.6305`, perimeter `(min+max)/833`,
logarithmic piecewise `±0.4·ln(...)`.

**Strategy formulas (12 curves + resize + units):**

| Strategy | Formula |
|---|---|
| Scaled | `b × d/300` (+AR variant above) |
| Percent | `b × d/300`; literal space `(p/100) × axis` |
| Power | `b × (d/300)^0.75` |
| Fluid | min=`b×0.8`, max=`b×1.2`, plateau [320, 768], linear lerp between |
| Auto | `d≤480: d/300; else 480/300 + 0.4·ln(1+(d−480)/300)` |
| Logarithmic | `d>300: 1+0.4·ln(d/300); d≤300: 1−0.4·ln(300/d)` |
| Diagonal | `√(min²+max²)/611.6305` |
| Fill (cover) | `max(min/300, max/533)` |
| Fit (contain) | `min(min/300, max/533)` |
| Interpolated | `b + (b·d/300 − b)×0.5` |
| Perimeter | `(min+max)/833` |
| Density | `b × (dpi/160)` (px path double-multiplies density, preserved) |
| Resize | step table (cap 4096) + binary search largest fitting |
| Units | `mm × xdpi / 25.4 / density` family + pure converters |

**Suffix grammar (identical across strategies 1–12):**
- none / `a` (aspect ratio) / `i` (ignore multi-window) / `ia`
- inverters: `Ph`, `Lh`, `Pw`, `Lw` (8 mappings incl. hdpLw/wdpLh combos)
- facilitators: `*Rotate`, `*Mode`, `*Qualifier`, `*Screen` (+ `Plain` logic-only)
- builder: `DimenScaled` chains with `.screen()` priority (UiMode+qualifier > UiMode > qualifier > orientation)

**Strategy prefixes:** scaled `sdp/hdp/wdp` · percent `psdp/phdp/pwdp` · power `pwsdp…` ·
fluid `fsdp…` · auto `asdp…` · diagonal `dgsdp…` · fill `flsdp…` · fit `ftsdp…` ·
interpolated `isdp…` · logarithmic `logsdp…` · perimeter `prsdp…` · density `dsdp…`.
Sp stems mirror (`ssp,hsp,wsp`) and no-font-scale (`sem,hem,wem`).

**Performance architecture extracted from KMP/Dynamic:**
- Immutable per-window snapshot with eager precomputed factors (fast lane = identity check + multiply).
- Fast-lane bypass: SCALED/PERCENT/DENSITY/DIAGONAL/INTERPOLATED/PERIMETER skip cache on default path (~raw multiply); POWER/LOGARITHMIC conditional; AUTO/FLUID/FIT/FILL cached.
- Snapshot-partitioned cache (max 4 partitions × 512 entries), coherent per configuration.
- Event-driven config watcher → in Flutter this is the widget tree itself: `AppDimensProvider` rebuilds on MediaQuery changes and republishes the snapshot.

### 1.2 Flutter-specific adaptations

| Kotlin/KMP concept | Flutter equivalent |
|---|---|
| Compose fast lane (`metricsScope ?: LocalDimenMetrics`) | Static `AppDimensScope.slot` published by `AppDimensProvider` (MediaQuery-driven) |
| `AppDimensContext` (window handle) | `AppDimensContext` from `BuildContext`/`FlutterView` or manual construction (testable, platform-neutral) |
| `@Composable val Number.sdp: Dp` | `num.sdp` getter (scope fast lane) **and** `num.sdpOf(context)` explicit variant |
| `Dp` / `TextUnit` | `double` (logical px) / helpers returning `EdgeInsets`, `TextStyle`, widgets |
| `BoxWithConstraints` resize API | LayoutBuilder-based `AutoResizeText`, `autoResizeTextSp(...)`, `autoResizeSquareSize(...)` |
| DimenCache packed Long keys | Web-safe composite key objects (64-bit packing unsafe on JS); hot paths bypass cache anyway |
| BOM module | `appdimens_bom` meta-package pinning all satellites |

---

## 2. Repository layout (modular monorepo — pub workspace)

```
├── pubspec.yaml                     # pub workspace root
├── packages/
│   ├── appdimens/                   # MAIN: core + scaled + plain + provider (family principal artifact)
│   ├── appdimens_percent/  appdimens_power/   appdimens_fluid/
│   ├── appdimens_auto/     appdimens_density/ appdimens_diagonal/
│   ├── appdimens_fill/     appdimens_fit/     appdimens_interpolated/
│   ├── appdimens_logarithmic/ appdimens_perimeter/ appdimens_resize/
│   ├── appdimens_units/
│   └── appdimens_bom/               # meta-package (all satellites, one dependency)
├── apps/
│   ├── sample/                      # converted sample app (demo + benchmark dashboard)
│   └── benchlab/                    # converted BenchLab (A/B methodology, parity, reports)
├── DOCUMENTATION/                   # docs mirroring the Dynamic repo structure (14 strategy guides…)
├── README.md  GUIDE-FOR-BEGINNERS.md  PERFORMANCE.md  PERFORMANCE-COMPARATIVE.md
│   MIGRATION.md  CHANGELOG.md  CONTRIBUTING.md  CODE_OF_CONDUCT.md  SECURITY.md
└── example → apps/sample (compatibility link documented in README)
```

Version: **3.2.0** (aligned with the AppDimens Dynamic 3.x family). SDK: Dart ≥3.3 / Flutter ≥3.19.

---

## 3. Execution order (as requested)

1. **Main module** `packages/appdimens`: common enums → design constants → ScreenConfiguration → DimenMetrics → DimenCalculationPlumbing → DimenCache (snapshot-partitioned + fast slot) → scaled kernels → sdp/hdp/wdp/ssp/hsp/wsp/sem families + inverters + facilitators + Plain branch → DimenScaled/ScaledSp builders → AppDimensContext + AppDimensProvider/CompositionLocals → resize core (ResizeMath/ResizeBound).
2. **Satellites**: each mirrors KMP file-for-file (extensions + object facade + factors), same prefix grammar.
3. **Sample app**: DemoCalc routing (12 strategies), core/inverter/facilitator/builder/auto-resize sections, benchmark dashboard (calc/micro/macro/compare).
4. **Benchlab**: Benchmark A (UI chunked probe vs competitors), Benchmark B (isolate engine), legacy T1/T2/T3 passes, resolution-parity tables, ratio banners, report generator.
5. **Tests & audit**: numeric parity vectors (from KMP tests + dynamic parity module), kernel equivalence (fast vs full path), cache coherence, inverter matrix, resize search, units conversions; `flutter analyze` clean.
6. **Documentation**: full DOCUMENTATION/ set + beautiful root README at the level of the KMP/Dynamic repos.

## 4. Quality gates

- `dart format --set-exit-if-changed`, `flutter analyze --fatal-infos`, `flutter test` green across all packages.
- Parity: every formula verified against reference vectors computed independently (Python float model of the Kotlin code) with tolerance ≤ 2 ulp / 0.05 dp.
- API audit checklist against `_refs/appdimens-dynamic/DOCUMENTATION/COMPOSE-API-CONVENTIONS.md` Appendix A/B.
