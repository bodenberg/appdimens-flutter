# Diagonal — screen diagonal ratio

> Strategy module: `appdimens_diagonal` · part of the AppDimens Flutter family

## What it is

Scales by the ratio of the window diagonal to the design-baseline diagonal (611.63 dp) — a single geometric measure independent of orientation.

## Calculation used

```text
out = b × √(s_min² + s_max²) / 611.6305
```

Qualifier-independent: `dgsdp`, `dghdp` and `dgwdp` resolve identically; the default path reuses the memoized `diagonalScale`.

## How to use

```dart
import 'package:appdimens_diagonal/appdimens_diagonal.dart';
final size = 16.dgsdp;   // same value on every axis
```

## Why use it

One number captures the overall “size” of the window — useful for elements that should track the device class, not an axis.

## When to use it

Media players, maps overlays, camera UIs — components tied to the physical window as a whole.

## Advantages & trade-offs

| ✅ Advantages | ⚠️ Trade-offs |
|---|---|
| Orientation-stable · single factor · cheap after memoization |
|---|---|

## Recommended usage strategy

Prefer Diagonal over Scaled when rotation should not change the element size.

---
*AppDimens Flutter 3.2.0 — see [MATHEMATICS-AND-CALCULUS.md](MATHEMATICS-AND-CALCULUS.md) for the formal derivation.*
