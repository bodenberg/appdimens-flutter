# Performance Comparative — AppDimens Flutter vs common alternatives

> Numbers from the CI-VM audit (`apps/benchlab/test/engine_benchmark_test.dart`,
> JIT, medians of 9 × 50 000 ops). On-device figures belong to the Kotlin
> family reports (Dynamic 3.1.9: ~7–30 ns/op on Snapdragon 888) and to the
> BenchLab app on your hardware.

## Contestants

| Library | Model |
|---|---|
| **AppDimens 3.2 fast lane** | published snapshot + one multiply |
| **Naive recompute** | rebuild `min(w,h)/300` from the window every call (typical hand-rolled "sdp") |
| **Legacy per-call model** | fresh instance + resolve per call (the deprecated 2.x Flutter API shape) |

## Results (median ns/op)

| Operation | AppDimens | Naive recompute | Legacy model* |
|---|---:|---:|---:|
| constant 16 dp | **11.4** | 68.8 | 9.7† |
| sdpa (+AR) | **8.6** | — | — |
| hdp / ssp | **6–10** | 68.8 | — |

† constant-folded by the JIT in this harness — an optimistic floor; real
legacy implementations pay map lookups and allocations that the Kotlin
family measured at **3.3 µs/call** on device.

## Ratios (medians)

```text
Fast lane vs naive rebuild-per-call   ≈ 5–8× faster
Fast lane vs legacy SDPS (on-device, from the Kotlin report) ≈ 100–400× faster
```

## Resolution parity

All approaches agree on the *math*; the differences are architectural:

| Value (392 dp phone) | AppDimens | Naive | Legacy formula |
|---|---:|---:|---:|
| 1 dp → px-class value | 1.3066667 | 1.3066666… | identical law |
| 10 dp | 13.066667 | 13.066667 | identical law |
| 100 dp | 130.66667 | 130.66667 | identical law |

The BenchLab UI renders this table live (Legacy T1/T2/T3 passes) and exports
a text report with checksums.

## Why the fast lane wins in real apps

A naive implementation inside a widget must read `MediaQuery.of(context)` —
an inherited-widget dependency lookup — before doing any math. That single
lookup costs more than the entire AppDimens resolution. The fast lane reads a
plain static field instead, and the snapshot it points to is republished only
when the window configuration actually changes.

## Methodology checklist (same as the Kotlin BenchLab)

- 20 000 warm-up calls per workload
- 9 samples × 50 000 measured ops, median reported
- Array-driven bases so neither side is constant-folded
- Checksum accumulation prevents dead-code elimination
- Alternating execution order across samples
