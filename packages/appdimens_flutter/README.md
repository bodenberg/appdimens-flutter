# AppDimens — Smart Responsive Dimensioning

> Part of the **AppDimens Flutter** family — Flutter port of
> [AppDimens Dynamic](https://github.com/bodenberg/appdimens-dynamic) /
> [AppDimens KMP](https://github.com/bodenberg/appdimens-kmp).

The principal artifact: core engine, immutable window snapshots, snapshot-partitioned cache and the default **Scaled** strategy (`sdp/hdp/wdp` + text `ssp/hsp/wsp`, no-font-scale `sem/hem/wem`). `16.sdp` resolves through a fast lane: one static snapshot read + one multiply.

## Installation

```yaml
dependencies:
  appdimens_flutter: ^3.2.0
```

> Prefer one dependency for everything? Use [`appdimens_bom`](https://pub.dev/packages/appdimens_bom).

## Usage

```dart
import 'package:appdimens_flutter/appdimens_flutter.dart';
final pad  = 16.sdp;    // smallest-width curve
final h    = 48.hdp;    // height curve
final size = 100.wdp;   // width curve

// conditional chain (priority: ui+qualifier → ui → qualifier → orientation)
final box = 100.scaledDp
    .screenMode(UiModeType.television, 500)
    .screenQualifier(DpQualifier.smallWidth, 600, 150);
```

## Family grammar

Every strategy shares the same API grammar — suffixes (`a` · `i` · `ia`),
orientation inverters (`Ph/Lh/Pw/Lw`), facilitators (`Rotate/Mode/Qualifier/
Screen` + Plain pairs), sp twins (`ssp`) and no-font-scale stems (`sem`):

| Stem | Axis | Sp | No font scale |
|------|------|----|----------------|
| Stem | Axis | Text (sp) | No font scale |
|---|---|---|---|
| `sdp` / `hdp` / `wdp` | smallest width / height / width | `ssp/hsp/wsp` | `sem/hem/wem` |


See the complete guide: [DOCUMENTATION/scaled.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/scaled.md) ·
[Math](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md) ·
[API conventions](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/API-CONVENTIONS.md)

## License

Apache License 2.0 — © Jean Bodenberg.
