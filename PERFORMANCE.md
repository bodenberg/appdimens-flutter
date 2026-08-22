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
| **Computed satellites** (auto, fluid, percent variants) | monomorphic inline kernels — same floor as the fast lane |
| **Cache** (AUTO/FLUID/FIT/FILL families) | hash lookup only when flags/custom-K force the general path |

The dominant Scaled families bypass the cache entirely — exactly like the
Kotlin engine's `shouldBypassCache`, because a multiply beats a hash lookup.

## Measured medians (CI VM, JIT)

```text
────── AppDimens engine audit (median ns/op) ──────
harness_baseline    9.86     ← closure+loop overhead floor
sdp                 8.72     ← at/below the noise floor
sdpa                6.72
hdp                 6.66
ssp                 6.66
psdp                6.62
pwsdp               6.70     ← memoized factor path
fsdp                7.80     ← lerp + clamps
asdp                6.56     ← ln beyond 480 dp
logsdp              6.60
dgsdp               6.72
prsdp               6.62
ftsdp               6.72
flsdp               6.74
dsdp                6.78
legacy_model        7.94     ← constant-folded by the JIT*
naive_rebuild     180.90     ← snapshot rebuilt per call**
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
| Fast lane vs naive rebuild-per-call | **≈ 20–27× faster** |
| Fast lane absolute cost | **~6.6–8.7 ns/op** (at/below harness noise) |
| Satellites (memoized *and* computed) | **~6.6–6.8 ns/op — same floor as `sdp`** |

Every audited stem now sits on the harness noise floor: after inlining
monomorphic kernels into the dominant getters, satellites such as `pwsdp`,
`asdp`, `fsdp`, `logsdp`, `prsdp`, `ftsdp`, `flsdp` and `dsdp` cost the same
as the plain fast lane. For perspective, the Kotlin family reports 6–30 ns/op
on-device for the same architecture — the Flutter port sits at the same level,
and both are orders of magnitude below any MediaQuery-driven recomputation
pattern in real widget code (an inherited-widget lookup alone costs more than
the whole fast lane).

## What keeps it fast

1. **Immutable snapshots** — `DimenMetrics` precomputes `scale`,
   `screenWidthFactor`, `screenHeightFactor` and both AR multipliers eagerly,
   as plain final fields (no `late` initialization checks on hot reads).
2. **Zero-allocation kernels** — extension getters resolve through static
   functions; nothing is allocated per call.
3. **Monomorphic inline kernels** — the dominant getters (`sdp/sdpa/hdp/wdp`,
   `ssp/hsp/wsp/…a`) multiply against a precomputed snapshot field directly
   instead of funneling through the shared kernel dispatch, keeping every hot
   call site monomorphic for the JIT/AOT.
4. **Bypass rules** — dominant families never touch the hash map.
5. **Deduped publication** — `AppDimensApp`/`AppDimensScopeBinder` republish
   snapshots only when metrics actually change, and identical snapshots are
   never fired twice (no timers, no per-frame work, no spurious rebuilds).

## Reproducing

```bash
flutter test apps/benchlab/test/engine_benchmark_test.dart   # engine audit
cd apps/benchlab && flutter run                              # full BenchLab UI
```
