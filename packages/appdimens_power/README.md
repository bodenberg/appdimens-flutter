# AppDimens Power

> Part of the **AppDimens Flutter** family — Flutter port of
> [AppDimens Dynamic](https://github.com/bodenberg/appdimens-dynamic) /
> [AppDimens KMP](https://github.com/bodenberg/appdimens-kmp).

Sub-linear perceptual growth: `base × (d/300)^0.75`. Sizes grow on large screens but progressively less — memoized factor on the default path.

## Installation

```yaml
dependencies:
  appdimens_power: ^3.2.0
```

> Prefer one dependency for everything? Use [`appdimens_bom`](https://pub.dev/packages/appdimens_bom).

## Usage

```dart
import 'package:appdimens_power/appdimens_power.dart';
final pad = 16.pwsdp;
final ar  = 16.pwsdpa;   // + aspect-ratio multiplier
```

## Family grammar

Every strategy shares the same API grammar — suffixes (`a` · `i` · `ia`),
orientation inverters (`Ph/Lh/Pw/Lw`), facilitators (`Rotate/Mode/Qualifier/
Screen` + Plain pairs), sp twins (`ssp`) and no-font-scale stems (`sem`):

| Stem | Axis | Sp | No font scale |
|------|------|----|----------------|
| Stem | Axis | Text (sp) | No font scale |
|---|---|---|---|
| `pwsdp` / `pwhdp` / `pwwdp` | smallest width / height / width | `pwssp/pwhsp/pwwsp` | `pwsem/pwhem/pwem` |


See the complete guide: [DOCUMENTATION/power.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/power.md) ·
[Math](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md) ·
[API conventions](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/API-CONVENTIONS.md)

## License

Apache License 2.0 — © Jean Bodenberg.
