# Interpolated — moderated linear growth

> Strategy module: `appdimens_interpolated` · part of the AppDimens Flutter family

## What it is

Blends the raw base and the fully-scaled value at a fixed 50%, softening linear growth by half.

## Calculation used

```text
linear = b × (d × ι)
out = b + (linear − b) × 0.5
```

The default sw path reuses the snapshot-memoized `interpolatedScale`.

## How to use

```dart
import 'package:appdimens_interpolated/appdimens_interpolated.dart';
final pad = 16.isdp;
final h   = 16.ihdp;
final w   = 16.iwdp;
```

## Why use it

When linear scaling is 30% too strong but you still want proportionality, Interpolated is exactly “half of it”.

## When to use it

Fine-tuning passes: teams that already use Scaled but want gentler growth on tablets without changing curves.

## Advantages & trade-offs

| ✅ Advantages | ⚠️ Trade-offs |
|---|---|
| Trivially predictable · memoized fast path · one knob (the blend) |
|---|---|

## Recommended usage strategy

Great migration step: swap `sdp` → `isdp` app-wide to halve the scaling effect.

---
*AppDimens Flutter 3.2.0 — see [MATHEMATICS-AND-CALCULUS.md](MATHEMATICS-AND-CALCULUS.md) for the formal derivation.*
