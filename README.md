# AppDimens Flutter — Smart Responsive Dimensioning

## Responsive dimensions for **Android · iOS · Web · Windows · macOS · Linux** — modular strategy library with fast-lane resolution

<p align="center">
  <a href="#-installation" title="Version">
    <img src="https://img.shields.io/badge/version-3.2.0-blue.svg" alt="Version 3.2.0">
  </a>
  &nbsp;
  <a href="LICENSE" title="Apache License 2.0">
    <img src="https://img.shields.io/badge/license-Apache%202.0-green.svg" alt="License Apache 2.0">
  </a>
  &nbsp;
  <a href="https://flutter.dev" title="Flutter">
    <img src="https://img.shields.io/badge/Flutter-3.27%2B-02569B.svg?logo=flutter&logoColor=white" alt="Flutter">
  </a>
  &nbsp;
  <a href="https://dart.dev" title="Dart">
    <img src="https://img.shields.io/badge/Dart-3.6%2B-0175C2.svg?logo=dart&logoColor=white" alt="Dart">
  </a>
  &nbsp;
  <a href="./DOCUMENTATION/README.md" title="Scaling strategies and modules">
    <img src="https://img.shields.io/badge/scaling%20modes-14-orange.svg" alt="14 scaling modes">
  </a>
</p>

<p align="center">
  <a href="./GUIDE-FOR-BEGINNERS.md" title="Step-by-step guide for beginners">
    <img src="https://img.shields.io/badge/Beginner%20guide-Step%20by%20step-f59e0b?style=for-the-badge&logo=readthedocs&logoColor=white&labelColor=b45309" alt="Beginner guide">
  </a>
  &nbsp;&nbsp;
  <a href="./DOCUMENTATION/README.md" title="Strategies, formulas, and when to use each scaling mode">
    <img src="https://img.shields.io/badge/Docs-Full%20documentation-1d4ed8?style=for-the-badge&logo=gitbook&logoColor=white&labelColor=1e3a8a" alt="Full documentation">
  </a>
  &nbsp;&nbsp;
  <a href="./PERFORMANCE.md" title="Technical performance report">
    <img src="https://img.shields.io/badge/Performance-Report-0f766e?style=for-the-badge&logo=google-analytics&logoColor=white&labelColor=134e4a" alt="Performance report">
  </a>
  &nbsp;&nbsp;
  <a href="./MIGRATION.md" title="Migrating from the deprecated 2.x API">
    <img src="https://img.shields.io/badge/Migration-2.x%20%E2%86%92%203.2-7c3aed?style=for-the-badge&logo=arrowdown&logoColor=white&labelColor=5b21b6" alt="Migration guide">
  </a>
</p>

---

Write values like `16.sdp` and the library scales them from the live window snapshot (size, density, font scale) — on **every platform Flutter runs on**, with the same math, the same API grammar and the same performance architecture as [AppDimens Dynamic](https://github.com/bodenberg/appdimens-dynamic) and [AppDimens KMP](https://github.com/bodenberg/appdimens-kmp).

> **This is a faithful Flutter port of the AppDimens family**: same formulas (bit-parity constants), same suffix grammar (`sdp`, `sdpa`, `sdpPh`…), same facilitators, builders, inverters, cache design and fast lane.

---

## ✨ Highlights (3.2.0)

| | |
|---|---|
| 🧮 **14 scaling modes** | Scaled (default), Percent, Power, Fluid, Auto, Logarithmic, Interpolated, Diagonal, Perimeter, Fill, Fit, Density + Resize fitting + physical units |
| ⚡ **Fast lane** | `16.sdp` = one static snapshot read + one multiply (~6–12 ns on a modern JIT; the Kotlin engine measures 6–30 ns on device) |
| 🪟 **Per-window snapshots** | Immutable `DimenMetrics` published by `AppDimensProvider`; rotation, split-screen and font-scale changes self-heal — no stale values |
| 🧊 **Snapshot-partitioned cache** | Max 4 partitions × 512 entries; dominant families bypass the hash entirely (one multiply beats a lookup) |
| 🔤 **One grammar everywhere** | Suffixes `a` · `i` · `ia`, inverters `Ph/Lh/Pw/Lw`, facilitators `Rotate/Mode/Qualifier/Screen` (+ logic-only `Plain`) on every strategy |
| 🧩 **Modular** | Principal artifact `appdimens` plus one opt-in package per strategy (`appdimens_percent`, `appdimens_power`, …) and an all-in-one `appdimens_bom` |
| ♾️ **Multiplatform** | Android · iOS · Web · Windows · macOS · Linux — pure Dart engine, zero platform channels |

---

## 🚀 Quick start

### Installation

```yaml
dependencies:
  appdimens: ^3.2.0            # principal artifact (core + scaled)
  # optional strategies, exactly like the Kotlin satellite modules:
  appdimens_percent: ^3.2.0
  appdimens_auto: ^3.2.0
  # …or everything at once:
  appdimens_bom: ^3.2.0
```

> While the packages live in this monorepo, use path dependencies or publish them to pub.dev as `appdimens_*`.

### Wrap your app once

```dart
import 'package:appdimens/appdimens.dart';

void main() => runApp(
      AppDimensApp(                       // publishes the window snapshot
        child: MaterialApp(home: const MyPage()),
      ),
    );
```

### Use it

```dart
import 'package:appdimens/appdimens.dart';

Box(
  width: 100.wdp,
  height: 48.hdp,
).padding(EdgeInsets.all(16.sdp))
 .child(Text('Hello', fontSize: 16.ssp));
```

That exact code scales correctly on phones, tablets, foldables, desktop windows and the browser.

| Extension | Based on | Typical use |
|-----------|----------|-------------|
| **`sdp`** | Smallest window width | Padding, margins |
| **`hdp`** | Window height | Row height |
| **`wdp`** | Window width | Column width |
| **`ssp`** | Same idea as `sdp`, for text | `fontSize` |
| **`sem`** | Same, ignoring the system font scale | `fontSize` |

### Suffixes

| Suffix | Meaning |
|--------|---------|
| *(none)* | Default curve |
| **`a`** | Aspect-ratio aware curve |
| **`i`** | Ignore multi-window heuristic (returns the raw base inside split-screen) |
| **`ia`** | Both |

```dart
16.sdpa       // + aspect ratio
32.hdpi       // height axis + ignore multi-window
16.sspa       // scalable sp + aspect ratio
```

### Orientation inverters

```dart
32.sdpPh   // SW-based; in portrait uses height
32.sdpLw   // SW-based; in landscape uses width
50.hdpLw   // Height-based; in landscape uses width
50.wdpLh   // Width-based; in landscape uses height
```

### Facilitators

```dart
80.sdpRotate(50)                                   // landscape → 50 scaled instead
30.sdpMode(200, UiModeType.television)             // TV → 200 scaled
60.sdpQualifier(120, DpQualifier.smallWidth, 600)  // sw ≥ 600 → 120 scaled
16.sdpRotatePlain(24)                              // logic-only pick (no double scaling)
```

### Builder chain

```dart
final pad = 100.scaledDp
    .screen(UiModeType.television, DpQualifier.smallWidth, 600, 250)
    .screenMode(UiModeType.television, 500)
    .screenQualifier(DpQualifier.smallWidth, 600, 150)
    .screenOrientation(OrientationRequest.landscape, 120);
// resolved.sdp → scaled value under the current window
```

### Auto-resize widgets

```dart
AutoResizeText('Headline that must fit', minSp: 10, maxSp: 28),
AutoResizeSquare(min: 40, max: 120, child: Icon(Icons.aspect_ratio)),
```

### Explicit context (no provider needed)

```dart
final pad = 16.sdpOf(context);          // any AppDimensContext
final px  = AppDimens.getDimensionInPx(context, DpQualifier.smallWidth, 16);
```

---

## 📦 Modules

| Package | Contents |
|---|---|
| **`appdimens`** | `common`, `core` (engine/cache/metrics), **scaled** families, provider |
| **`appdimens_percent`** … **`appdimens_units`** | One package per strategy — mirrors `appdimens-kmp-*` / `appdimens-dynamic-*` |
| **`appdimens_bom`** | Meta-package re-exporting everything at a coherent version |
| **`apps/sample`** | Converted sample app (strategy routing demo + benchmark dashboard) |
| **`apps/benchlab`** | BenchLab competitor benchmark (A/B methodology, parity tables, reports) |

Full graph and dependency rules: [DOCUMENTATION/MODULES.md](DOCUMENTATION/MODULES.md).

---

## 📚 Documentation

| Resource | Use for |
|----------|---------|
| [DOCUMENTATION/README.md](DOCUMENTATION/README.md) | Per-strategy explanations (14 guides) |
| [DOCUMENTATION/API-CONVENTIONS.md](DOCUMENTATION/API-CONVENTIONS.md) | Every extension property & facilitator catalog |
| [DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md](DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md) | Formal math, constants, precision policy |
| [DOCUMENTATION/MODULES.md](DOCUMENTATION/MODULES.md) | Package graph |
| [GUIDE-FOR-BEGINNERS.md](GUIDE-FOR-BEGINNERS.md) | Plain-language walkthrough |
| [PERFORMANCE.md](PERFORMANCE.md) / [PERFORMANCE-COMPARATIVE.md](PERFORMANCE-COMPARATIVE.md) | Measured numbers and competitor comparison |
| [MIGRATION.md](MIGRATION.md) | Replacing the deprecated 2.x Flutter API |
| [LLMS.txt](LLMS.txt) · [skills/](skills/) | AI-agent resources (LLM index + agent workflow skill) |

**Recommendation order for most apps:** **Scaled** (with or without `a`) → then **percent** → then **auto**; explore the rest when you have a clear need (fluid, fit, diagonal…).

---

## 🖥️ Example apps

- **`apps/sample`** — every section of the demo (core extensions, inverters, facilitators, builder chains, auto-resize) plus a benchmark dashboard.
- **`apps/benchlab`** — the BenchLab pipeline (UI probe, isolate engine probe, legacy T1/T2/T3 passes, resolution-parity tables, report export).

```bash
flutter run --device <id> -t lib/main.dart   # inside apps/sample or apps/benchlab
```

---

## 🤝 Contributing & community

- [CONTRIBUTING.md](CONTRIBUTING.md) · [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) · [SECURITY.md](SECURITY.md)
- Strategy packages are generated from `scripts/generate_satellites.py` (single source of truth for the shared grammar).
- ⭐ Star the repository to follow updates!

---

*Apache License 2.0 — responsive layout utilities for Flutter (Android · iOS · Web · Windows · macOS · Linux). Part of the AppDimens family: [Android/Dynamic](https://github.com/bodenberg/appdimens-dynamic) · [KMP](https://github.com/bodenberg/appdimens-kmp) · Flutter.*
