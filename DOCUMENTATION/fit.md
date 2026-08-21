# Fit — CSS contain behavior

> Strategy module: `appdimens_fit` · part of the AppDimens Flutter family

## What it is

Uses the **smaller** of the two axis ratios, guaranteeing the element always fits inside its target area.

## Calculation used

```text
out = b × min(s_min/300, s_max/533)
```

The default path reuses the memoized factor after the min() is resolved per snapshot.

## How to use

```dart
import 'package:appdimens_fit/appdimens_fit.dart';
final size = 16.ftsdp;   // contain-style sizing
```

## Why use it

Mirrors `BoxFit.contain` semantics for dimensioning: never overflow, accept letterboxing.

## When to use it

Logos, badges, illustrations and dialogs that must remain fully visible.

## Advantages & trade-offs

| ✅ Advantages | ⚠️ Trade-offs |
|---|---|
| No overflow · safe by construction |
|---|---|

## Recommended usage strategy

Use Fit for anything that must never clip; combine with AutoResizeText for text.

---
*AppDimens Flutter 3.2.0 — see [MATHEMATICS-AND-CALCULUS.md](MATHEMATICS-AND-CALCULUS.md) for the formal derivation.*
