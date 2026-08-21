# Density — physical-density alignment

> Strategy module: `appdimens_density` · part of the AppDimens Flutter family

## What it is

Scales by the physical density ratio (`dpi / 160`), aligning sizes with the device's pixel density instead of its window size.

## Calculation used

```text
out = b × (dpi / 160)
```

The px variant multiplies by density again (matching the Kotlin engine), so `toPx` ≈ `b × density²` — intentional for pixel-exact physical sizing.

## How to use

```dart
import 'package:appdimens_density/appdimens_density.dart';
final size = 16.dsdp;   // density-driven
```

## Why use it

On very dense or very sparse screens, window-based curves can misjudge physical size; Density anchors to the hardware.

## When to use it

Games, camera overlays, AR markers, physical calibration UIs.

## Advantages & trade-offs

| ✅ Advantages | ⚠️ Trade-offs |
|---|---|
| Hardware-anchored · deterministic across window resizes |
|---|---|

## Recommended usage strategy

Rare in classic app UI — reach for it when physical size matters more than layout proportions.

---
*AppDimens Flutter 3.2.0 — see [MATHEMATICS-AND-CALCULUS.md](MATHEMATICS-AND-CALCULUS.md) for the formal derivation.*
