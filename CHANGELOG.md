# Changelog

All notable changes to the AppDimens Flutter package are documented here.
Format based on Keep a Changelog; versioning aligned with the AppDimens
Dynamic family.

## [3.2.0] — 2026-08-21

Complete rewrite replacing the deprecated 2.x Flutter library with a faithful,
modular port of **AppDimens Dynamic 3.1.9 / AppDimens KMP 1.0.1**.

### Added
- Principal artifact `appdimens_flutter`: common enums, `ScreenConfiguration`,
  `DimenMetrics` snapshot (eager precomputed factors), `DimenCache`
  (snapshot-partitioned, bypass rules identical to Kotlin),
  `DimenScaledEngine`, Scaled families (`sdp/hdp/wdp/ssp/hsp/wsp/sem/hem/wem`
  × `a/i/ia` × inverters × Px twins), facilitators (`Rotate/Mode/Qualifier/
  Screen` + Plain logic-only pairs), `DimenScaled`/`ScaledSp` builders,
  resize math primitives, `AppDimensApp`/`AppDimensScopeBinder`/
  `AppDimensProvider`.
- Twelve strategy satellite packages: percent (+ literal space family),
  power, fluid, auto, diagonal, fill, fit, interpolated, logarithmic,
  perimeter, density — each with memoized default-path factors where the
  Kotlin engine has them.
- `appdimens_resize` (constraint auto-fit widgets + range search) and
  `appdimens_units` (mm/cm/inch).
- `appdimens_bom` meta-package.
- Sample app (`apps/sample`) converted from the KMP/Dynamic sample:
  strategy-routing demo + benchmark dashboard.
- BenchLab app (`apps/benchlab`) converted from the KMP/Dynamic benchlab:
  UI probe, isolate engine probe, legacy passes, resolution parity, reports.
- Generated reference vectors verifying every formula against an independent
  model (tolerance ≤ 1e-6).
- Full documentation set mirroring the Kotlin repos (14 strategy guides,
  mathematics, API conventions, modules, performance).

### Removed
- Deprecated `fx`/`dy` builder API (`AppDimens.fixed/dynamic/fluid`,
  extensions, provider, physical-units of the old line). See MIGRATION.md.

### Performance
- Fast lane: one static read + one multiply (~6.6–8.7 ns on CI VM JIT).
- Monomorphic inline kernels on the dominant getters (`sdp/sdpa/hdp/wdp`,
  `ssp/hsp/wsp` and the `…a` variants): hot call sites no longer funnel
  through shared-kernel dispatch, keeping every stem at the harness noise
  floor (~6.6–6.8 ns).
- Satellites (power, fluid, auto, logarithmic, diagonal, perimeter, fit,
  interpolated, percent) resolve at the same floor as `sdp` after inlining.
- Deduped scope publication: identical `DimenMetrics` snapshots are never
  fired twice, eliminating spurious rebuilds during window changes.
- Naive rebuild-per-call pattern: ~20–27× slower than the fast lane
  (180.9 ns vs ~6.7–8.7 ns median).
