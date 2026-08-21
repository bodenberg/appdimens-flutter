# Resize — constraint-based auto-fit

> Strategy module: `appdimens_resize` · part of the AppDimens Flutter family

## What it is

Not a scaling curve: a search. It builds the candidate table `[min…max]` (capped at 4096 steps, always ending exactly at `max`) and binary-searches the **largest** candidate whose predicate fits.

## Calculation used

```text
steps = buildResizeStepsPx(minPx, maxPx, stepPx)
best  = findLargestFittingResizePx(steps, fits)   // O(log n)
```

Bounds may be fixed dp/sp or percents of an axis (`ResizeBound`, `resizePercentSw`, …).

## How to use

```dart
import 'package:appdimens_resize/appdimens_resize.dart';
// Widgets
AutoResizeText('Headline', minSp: 10, maxSp: 28, maxLines: 2),
AutoResizeSquare(min: 40, max: 120, step: 4, child: …),

// Engine-level
final range = DimenResize.rangePx(scope, 10, 100, step: 2);
final side  = DimenResize.fittingInnerSquareSidePx(range, w, h);
```

## Why use it

Text and squares must *fit*, not just scale — Resize guarantees the largest size that still fits the available space.

## When to use it

Headlines, price tags, badges, responsive squares/avatars inside flexible containers.

## Advantages & trade-offs

| ✅ Advantages | ⚠️ Trade-offs |
|---|---|
| Guaranteed fit · O(log n) search · percent and fixed bounds |
|---|---|

## Recommended usage strategy

Use `AutoResizeText` for any text with strict space limits; use engine-level helpers for custom widgets.

---
*AppDimens Flutter 3.2.0 — see [MATHEMATICS-AND-CALCULUS.md](MATHEMATICS-AND-CALCULUS.md) for the formal derivation.*
