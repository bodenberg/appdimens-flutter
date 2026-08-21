# Percent — sizes as a fraction of the screen

> Strategy module: `appdimens_percent` · part of the AppDimens Flutter family

## What it is

Same linear law as Scaled plus a **literal** percentage family that resolves exact fractions of an axis with no scaling curve.

## Calculation used

```text
psdp : out = b × (d × ι)
space: out = (p / 100) × axis
```

The `space*` family answers “30% of the width” literally — useful for proportional dividers and grids.

## How to use

```dart
import 'package:appdimens_percent/appdimens_percent.dart';
final box   = 10.psdp;      // same curve as sdp
final half  = 50.spaceW;    // 50% of the width
final band  = 25.spaceH;    // 25% of the height
final ref   = 10.spaceOf(500); // 10% of a 500 dp reference
// conditional chain
final c = DimenPercent.scaled(100).screenQualifier(DpQualifier.smallWidth, 600, 150);
```

## Why use it

Percentages communicate intent directly; the literal family avoids the classic `MediaQuery.size.width * 0.3` boilerplate and honors multi-window suppression.

## When to use it

Proportional dividers, split panes, grids, hero areas sized relative to the window.

## Advantages & trade-offs

| ✅ Advantages | ⚠️ Trade-offs |
|---|---|
| Literal semantics · multi-window aware · sp twins included |
|---|---|

## Recommended usage strategy

Prefer `spaceW/spaceH` for fractions of the window and `psdp` when you want the Scaled curve under the percent namespace (parity with the Kotlin module).

---
*AppDimens Flutter 3.2.0 — see [MATHEMATICS-AND-CALCULUS.md](MATHEMATICS-AND-CALCULUS.md) for the formal derivation.*
