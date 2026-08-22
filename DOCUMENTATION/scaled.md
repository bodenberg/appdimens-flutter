# Scaled — the default strategy (sdp · hdp · wdp · ssp)

> Strategy module: `appdimens_flutter` · part of the AppDimens Flutter family

## What it is

Linear scaling against the design baseline: values grow proportionally with the chosen window axis. It is the most widely used strategy in real apps and the recommended default of the whole family.

## Calculation used

```text
out = b × (d × ι)          ι = 1/300
out = b × (1 + (d − 300) × (0.10/30 + k × ln(AR/1.78)))   // with the a suffix
```

`d` is the axis selected by the qualifier (`sw`, height or width). The aspect-ratio variant adjusts growth for very tall/very wide screens.

## How to use

```dart
import 'package:appdimens_flutter/appdimens.dart';
final pad    = 16.sdp;        // smallest-width curve
final height = 48.hdp;         // height curve
final width  = 100.wdp;        // width curve
final text   = 16.ssp;         // text (framework applies font scale)
final fixed  = 16.sem;         // text ignoring the font scale
final ar     = 16.sdpa;        // + aspect-ratio aware curve
final px     = 16.sdpPx;       // physical pixels
```

## Why use it

One multiply on the hot path (the snapshot pre-computes `scale`), zero allocations, and a mental model everyone understands: 300 dp of design width maps 1:1.

## When to use it

Default for padding, margins, icons, buttons, cards — anything without a special constraint.

## Advantages & trade-offs

| ✅ Advantages | ⚠️ Trade-offs |
|---|---|
| Fastest path in the library · predictable · identical semantics to SDP/SSP ecosystems |
|---|---|

## Recommended usage strategy

Use plain `sdp` when one curve is enough; add `a` when your layouts must stay balanced on extreme aspect ratios (foldables, tall phones, desktop windows).

---
*AppDimens Flutter 3.2.0 — see [MATHEMATICS-AND-CALCULUS.md](MATHEMATICS-AND-CALCULUS.md) for the formal derivation.*
