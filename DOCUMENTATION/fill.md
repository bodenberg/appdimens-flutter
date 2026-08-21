# Fill — CSS cover behavior

> Strategy module: `appdimens_fill` · part of the AppDimens Flutter family

## What it is

Uses the **larger** of the two axis ratios, guaranteeing the element always covers its target area (it may overflow).

## Calculation used

```text
out = b × max(s_min/300, s_max/533)
```

The default path reuses the memoized factor after the max() is resolved per snapshot.

## How to use

```dart
import 'package:appdimens_fill/appdimens_fill.dart';
final size = 16.flsdp;   // cover-style sizing
```

## Why use it

Mirrors `BoxFit.cover` semantics for dimensioning: never leave gaps, accept cropping.

## When to use it

Backgrounds, hero images, splash art, decorative surfaces.

## Advantages & trade-offs

| ✅ Advantages | ⚠️ Trade-offs |
|---|---|
| No empty space · simple mental model (cover) |
|---|---|

## Recommended usage strategy

Pair with clipping (`ClipRect`) when overflow must be hidden.

---
*AppDimens Flutter 3.2.0 — see [MATHEMATICS-AND-CALCULUS.md](MATHEMATICS-AND-CALCULUS.md) for the formal derivation.*
