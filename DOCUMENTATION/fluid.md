# Fluid — clamped interpolation between min and max

> Strategy module: `appdimens_fluid` · part of the AppDimens Flutter family

## What it is

CSS-`clamp`-like behavior: the value plateaus at `b×0.8` on small screens, at `b×1.2` on large ones, and interpolates linearly between 320 and 768 dp.

## Calculation used

```text
d ≤ 320 : b × 0.8
320 < d < 768 : lerp(b×0.8, b×1.2, (d − 320) / 448)
d ≥ 768 : b × 1.2
```

Plateaus guarantee hard bounds — typography never becomes unreadably small or comically large.

## How to use

```dart
import 'package:appdimens_fluid/appdimens_fluid.dart';
final size = 16.fsdp;      // fluid on sw
final h    = 16.fhdp;
final w    = 16.fwdp;
```

## Why use it

Designers specify a safe range once and the engine interpolates inside it; no manual breakpoints.

## When to use it

Typography scales, paddings and component sizes with strict min/max requirements.

## Advantages & trade-offs

| ✅ Advantages | ⚠️ Trade-offs |
|---|---|
| Hard clamps · smooth in between · tiny constant-time formula |
|---|---|

## Recommended usage strategy

The default range (±20% over [320, 768]) fits most typography; combine with `a` if the clamp should follow the aspect ratio too.

---
*AppDimens Flutter 3.2.0 — see [MATHEMATICS-AND-CALCULUS.md](MATHEMATICS-AND-CALCULUS.md) for the formal derivation.*
