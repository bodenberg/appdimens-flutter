# Physical units — mm · cm · inch

> Strategy module: `appdimens_units` · part of the AppDimens Flutter family

## What it is

Approximates real-world sizes on screen using density (and an optional calibrated `xdpi`), with pure unit↔unit converters.

## Calculation used

```text
mm → dp = mm × xdpi / 25.4 / density
cm = mm × 10   ·   inch = mm × 25.4
```

Defaults assume `xdpi = density × 160`; pass a calibrated ppi for exactness on specific panels.

## How to use

```dart
import 'package:appdimens_units/appdimens_units.dart';
final card = DimenPhysicalUnits.toDpFromMm(85, scope: scope);   // credit-card width
final px   = DimenPhysicalUnits.toPxFromInch(2, scope: scope);
final cm   = 25.4.mmToCm;
final r    = DimenPhysicalUnits.radiusFromDiameter(50, UnitType.mm, scope: scope);
```

## Why use it

Some UIs must match the physical world: print previews, rulers, ID-card frames, medical or industrial tools.

## When to use it

Any feature where on-screen size must approximate physical size.

## Advantages & trade-offs

| ✅ Advantages | ⚠️ Trade-offs |
|---|---|
| Real-world semantics · pure converters included · radius helpers |
|---|---|

## Recommended usage strategy

Calibrate `xdpi` on the devices that matter; treat results as approximations elsewhere.

---
*AppDimens Flutter 3.2.0 — see [MATHEMATICS-AND-CALCULUS.md](MATHEMATICS-AND-CALCULUS.md) for the formal derivation.*
