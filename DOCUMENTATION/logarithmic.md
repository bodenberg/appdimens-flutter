# Logarithmic — symmetric damping around the baseline

> Strategy module: `appdimens_logarithmic` · part of the AppDimens Flutter family

## What it is

Piecewise log curve symmetric around 300 dp: grows with `+0.4·ln` above the baseline and shrinks gently below it.

## Calculation used

```text
d > 300 : 1 + 0.4 × ln(d × ι)
0 < d ≤ 300 : 1 − 0.4 × ln(300 / d)
```

The default sw path reuses the snapshot-memoized `logarithmicScale`.

## How to use

```dart
import 'package:appdimens_logarithmic/appdimens_logarithmic.dart';
final pad = 16.logsdp;
final h   = 16.loghdp;
final w   = 16.logwdp;
```

## Why use it

The most conservative growth of the family — values almost stop growing on very large screens.

## When to use it

Dense/professional UIs (dashboards, IDEs, data tables) where huge screens should show *more content*, not bigger content.

## Advantages & trade-offs

| ✅ Advantages | ⚠️ Trade-offs |
|---|---|
| Strong damping · symmetric below baseline · memoized default path |
|---|---|

## Recommended usage strategy

Use for density-first layouts; pair with Percent for the few hero elements that should still grow.

---
*AppDimens Flutter 3.2.0 — see [MATHEMATICS-AND-CALCULUS.md](MATHEMATICS-AND-CALCULUS.md) for the formal derivation.*
