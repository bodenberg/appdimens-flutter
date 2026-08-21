# Performance — AppDimens Flutter 3.2

> Companion of [PERFORMANCE-COMPARATIVE.md](PERFORMANCE-COMPARATIVE.md).
> Methodology mirrors the Kotlin BenchLab (warm-up + 9 samples × 50 000 ops,
> median). All numbers below were measured with
> `apps/benchlab/test/engine_benchmark_test.dart` on the CI VM (shared
> hardware, Dart JIT) — treat them as *relative* indicators; on-device runs
> via the BenchLab app produce the authoritative figures for your hardware.

## Architecture: where the time goes

| Layer | Cost model |
|---|---|
| **Fast lane** (`16.sdp`) | one static slot read + one field read + one multiply |
| **Snapshot** (`DimenMetrics`) | every factor computed once per window configuration |
| **Memoized satellites** (power/log/diagonal/perimeter/interpolated default paths) | same as fast lane after the first use |
| **Computed satellites** (auto, fluid, percent variants) | one `ln`/branch chain (~20–40 ns) |
| **Cache** (AUTO/FLUID/FIT/FILL families) | hash lookup only when flags/custom-K force the general path |

The dominant Scaled families bypass the cache entirely — exactly like the
Kotlin engine's `shouldBypassCache`, because a multiply beats a hash lookup.

## Measured medians (CI VM, JIT)

```text
─────────── AppDimens engine audit (median ns/op) ───────────
harness_baseline   20.88     ← closure+loop overhead floor
sdp                11.42     ← at/below the noise floor
sdpa                8.60
hdp                 7.54
ssp                 6.14
pwsdp              27.10     ← memoized factor path
fsdp               42.32     ← lerp + clamps
asdp               38.26     ← ln beyond 480 dp
legacy_model        9.68     ← constant-folded by the JIT*
naive_rebuild      68.82     ← snapshot rebuilt per call**
```

\* The legacy model in this harness is constant-folded by the Dart JIT (all
inputs are compile-time constants), which makes it an optimistic lower bound.
On Android/Dalvik the equivalent legacy SDPS API measured **3.3 µs/call** in
the Kotlin family benchmarks (map lookups + no escape analysis).

\** "Naive recompute" models what hand-rolled scaling does when it reads
MediaQuery and rebuilds its scale factor on every call.

## Headline numbers

| Comparison | Result |
|---|---|
| Fast lane vs naive rebuild-per-call | **≈ 5–8× faster** |
| Fast lane absolute cost | **6–12 ns/op** (below harness noise) |
| Satellites (memoized) | **~27 ns/op** |
| Satellites (computed: auto/fluid) | **~30–45 ns/op** |

For perspective, the Kotlin family reports 6–30 ns/op on-device for the same
architecture — the Flutter port sits in the same order of magnitude, and both
are orders of magnitude below any MediaQuery-driven recomputation pattern in
real widget code (an inherited-widget lookup alone costs more than the whole
fast lane).

## What keeps it fast

1. **Immutable snapshots** — `DimenMetrics` precomputes `scale`,
   `screenWidthFactor`, `screenHeightFactor` and both AR multipliers eagerly,
   as plain final fields (no `late` initialization checks on hot reads).
2. **Zero-allocation kernels** — extension getters resolve through static
   functions; nothing is allocated per call.
3. **Bypass rules** — dominant families never touch the hash map.
4. **Event-driven publication** — `AppDimensApp`/`AppDimensScopeBinder`
   republish snapshots only when metrics actually change (no timers, no
   per-frame work).

## Reproducing

```bash
flutter test apps/benchlab/test/engine_benchmark_test.dart   # engine audit
cd apps/benchlab && flutter run                              # full BenchLab UI
```
