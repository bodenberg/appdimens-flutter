# Guide for Beginners — AppDimens Flutter

> Zero prior knowledge needed. Ten minutes from "what is responsive sizing?"
> to using the library like a pro.

## 1. The problem

You design a screen on a phone where a card is `100` dp wide. On a tablet,
`100` dp looks tiny. On a foldable half-open, somewhere in between. Hardcoded
dp values cannot adapt; percentages alone ignore density and aspect ratio.

## 2. The idea (30 seconds)

Pick a **design reference width** — AppDimens uses **300 dp**. When your app
runs on a 392 dp-wide phone, everything drawn with the library is multiplied
by `392 / 300 ≈ 1.31`. On an 800 dp tablet, by `≈ 2.67`. One number per window
("the scale"), applied to every size.

```dart
16.sdp   // 16 × scale — always proportional to the screen
```

That's the default strategy (**Scaled**). Everything else in the library is a
variation on *how* that multiplier grows.

## 3. Setup (once)

```dart
import 'package:appdimens/appdimens.dart';

void main() => runApp(
      AppDimensApp(                 // ← publishes the window snapshot
        child: MaterialApp(home: const HomePage()),
      ),
    );
```

## 4. The five extensions you'll use 95% of the time

| Extension | Reads | Use for |
|---|---|---|
| `16.sdp` | smallest width | padding, margins, radii |
| `48.hdp` | height | vertical spacing |
| `100.wdp` | width | columns, cards |
| `16.ssp` | like sdp, for text | `fontSize` |
| `16.sem` | like ssp but ignores the system font scale | logos in text |

```dart
Container(
  width: 120.wdp,
  padding: EdgeInsets.all(16.sdp),
  child: Text('Hello', fontSize: 18.ssp),
)
```

## 5. Suffixes — tiny flags with big meaning

| Suffix | Meaning |
|---|---|
| `a` | also consider the screen **shape** (aspect ratio) |
| `i` | inside split-screen, don't scale (use the raw value) |
| `ia` | both |

```dart
16.sdpa    // shape-aware
16.sdpi    // multi-window-safe
```

**Rotation helpers:** `32.sdpPh` uses the height while in portrait;
`50.hdpLw` uses the width while in landscape. Great for toolbars and banners.

## 6. When one curve isn't enough

| You want… | Use |
|---|---|
| text that never overflows its box | `AutoResizeText` (resize package) |
| "30% of the screen" | Percent: `30.spaceW` |
| slower growth on tablets | Auto (`asdp`) or Logarithmic (`logsdp`) or Power (`pwsdp`) |
| strict min/max bounds | Fluid (`fsdp`) |
| same size in any rotation | Diagonal (`dgsdp`) or Perimeter (`prsdp`) |
| real centimeters | Units package |

Each strategy lives in its own package — add only what you use:

```yaml
dependencies:
  appdimens: ^3.2.0
  appdimens_auto: ^3.2.0
```

…or take `appdimens_bom` to get everything.

## 7. Conditional sizes without spaghetti

"200 dp on TVs, 150 on wide screens, 120 in landscape, otherwise 100":

```dart
final size = 100.scaledDp
    .screenMode(UiModeType.television, 500)
    .screenQualifier(DpQualifier.smallWidth, 600, 150)
    .screenOrientation(OrientationRequest.landscape, 120);

Container(width: size.sdp);
```

The builder checks each rule by priority and scales the winner.

## 8. Is it fast?

Yes. `16.sdp` compiles down to *one table read + one multiplication*
(measured at ~6.6–8.7 ns — see [PERFORMANCE.md](PERFORMANCE.md)). There's no
per-call MediaQuery lookup, no allocation, no locks.

## 9. Testing your layout

Without a provider, extensions resolve against the reference window
(300×533): `16.sdp == 16` exactly in tests — deterministic golden tests for
free. To simulate devices:

```dart
AppDimensScope.withMetrics(
  DimenMetrics.from(ScreenConfiguration(screenWidthDp: 800, screenHeightDp: 1280)),
  () => expect(16.sdp, closeTo(16 * 800 / 300, 0.001)),
);
```

## 10. Where to go next

- All suffixes/inverters/facilitators: [DOCUMENTATION/API-CONVENTIONS.md](DOCUMENTATION/API-CONVENTIONS.md)
- The math behind every curve: [DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md](DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md)
- Strategy-by-strategy guide: [DOCUMENTATION/README.md](DOCUMENTATION/README.md)
- Coming from the old 2.x Flutter API? [MIGRATION.md](MIGRATION.md)
