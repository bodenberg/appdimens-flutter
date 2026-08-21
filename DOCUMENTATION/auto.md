# Auto — linear on phones, log-damped on large screens

> Strategy module: `appdimens_auto` · part of the AppDimens Flutter family

## What it is

Behaves exactly like Scaled up to 480 dp, then grows logarithmically — the pragmatic “phones linear, tablets damped” hybrid.

## Calculation used

```text
d ≤ 480 : d × ι
d > 480 : 480 × ι + 0.4 × ln(1 + (d − 480) × ι)
```

The transition point (480 dp) separates typical phones from tablets/desktops; the 0.4 slope controls post-transition damping.

## How to use

```dart
import 'package:appdimens_auto/appdimens_auto.dart';
final pad = 16.asdp;
final h   = 16.ahdp;
final w   = 16.awdp;
final ar  = 16.asdpa;
```

## Why use it

Keeps phone layouts pixel-familiar while preventing tablet blow-up — without per-device tables.

## When to use it

Apps that run unchanged from phones to tablets and desktop windows and want restrained growth after 480 dp.

## Advantages & trade-offs

| ✅ Advantages | ⚠️ Trade-offs |
|---|---|
| Familiar on phones · self-limiting on big screens · memoized ln only beyond the transition |
|---|---|

## Recommended usage strategy

The family's second recommendation after Scaled; adopt it when you notice tablet layouts feeling inflated.

---
*AppDimens Flutter 3.2.0 — see [MATHEMATICS-AND-CALCULUS.md](MATHEMATICS-AND-CALCULUS.md) for the formal derivation.*
