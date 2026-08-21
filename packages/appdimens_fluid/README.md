# AppDimens Fluid

> Part of the **AppDimens Flutter** family — Flutter port of
> [AppDimens Dynamic](https://github.com/bodenberg/appdimens-dynamic) /
> [AppDimens KMP](https://github.com/bodenberg/appdimens-kmp).

CSS-clamp-like strategy: plateaus at `b×0.8` below 320 dp and `b×1.2` above 768 dp, with a smooth lerp between — hard bounds guaranteed.

## Installation

```yaml
dependencies:
  appdimens_fluid: ^3.2.0
```

> Prefer one dependency for everything? Use [`appdimens_bom`](https://pub.dev/packages/appdimens_bom).

## Usage

```dart
import 'package:appdimens_fluid/appdimens_fluid.dart';
final text = 16.fsdp;    // fluid clamp on smallest width
```

## Family grammar

Every strategy shares the same API grammar — suffixes (`a` · `i` · `ia`),
orientation inverters (`Ph/Lh/Pw/Lw`), facilitators (`Rotate/Mode/Qualifier/
Screen` + Plain pairs), sp twins (`ssp`) and no-font-scale stems (`sem`):

| Stem | Axis | Sp | No font scale |
|------|------|----|----------------|
| Stem | Axis | Text (sp) | No font scale |
|---|---|---|---|
| `fsdp` / `fhdp` / `fwdp` | smallest width / height / width | `fssp/fhsp/fwsp` | `fsem/fhem/fwem` |


See the complete guide: [DOCUMENTATION/fluid.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/fluid.md) ·
[Math](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md) ·
[API conventions](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/API-CONVENTIONS.md)

## License

Apache License 2.0 — © Jean Bodenberg.
