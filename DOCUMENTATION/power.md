# Power — sub-linear perceptual growth

> Strategy module: `appdimens_power` · part of the AppDimens Flutter family

## What it is

Raises the normalized axis to a fixed exponent (0.75), producing growth slower than linear — sizes increase on tablets, but less and less.

## Calculation used

```text
out = b × (d × ι)^0.75
```

The default path reuses the snapshot-memoized `powerScale` factor (one multiply, no `pow` per call).

## How to use

```dart
import 'package:appdimens_power/appdimens_power.dart';
final pad = 16.pwsdp;      // sub-linear on sw
final h   = 16.pwhdp;
final w   = 16.pwwdp;
final ar  = 16.pwsdpa;     // + aspect-ratio multiplier
```

## Why use it

Pure linear scaling makes phone UIs feel sparse on tablets; a 0.75 exponent keeps proportions pleasant without a breakpoint system.

## When to use it

Spacing, icon sizes and components that should grow moderately on large screens.

## Advantages & trade-offs

| ✅ Advantages | ⚠️ Trade-offs |
|---|---|
| Smooth, monotonic, no breakpoints · memoized fast path · AR multiplier optional |
|---|---|

## Recommended usage strategy

Choose Power when Scaled feels too aggressive on tablets but Auto/Logarithmic feel too conservative.

---
*AppDimens Flutter 3.2.0 — see [MATHEMATICS-AND-CALCULUS.md](MATHEMATICS-AND-CALCULUS.md) for the formal derivation.*
