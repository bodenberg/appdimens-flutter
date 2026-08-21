# Perimeter — half-perimeter ratio

> Strategy module: `appdimens_perimeter` · part of the AppDimens Flutter family

## What it is

Scales by the ratio of the window half-perimeter to the baseline half-perimeter (833 dp).

## Calculation used

```text
out = b × (s_min + s_max) / 833
```

Qualifier-independent; the default path reuses the memoized `perimeterScale`.

## How to use

```dart
import 'package:appdimens_perimeter/appdimens_perimeter.dart';
final size = 16.prsdp;   // same value on every axis
```

## Why use it

Averaging both sides makes the factor stable under rotation (portrait/landscape converge).

## When to use it

Elements that should react to overall window growth but stay rotation-stable, like toolbars and bottom bars.

## Advantages & trade-offs

| ✅ Advantages | ⚠️ Trade-offs |
|---|---|
| Rotation-stable · single cheap factor |
|---|---|

## Recommended usage strategy

Consider Perimeter as the orientation-agnostic sibling of Scaled.

---
*AppDimens Flutter 3.2.0 — see [MATHEMATICS-AND-CALCULUS.md](MATHEMATICS-AND-CALCULUS.md) for the formal derivation.*
