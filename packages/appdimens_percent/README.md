# AppDimens Percent

> Part of the **AppDimens Flutter** family — Flutter port of
> [AppDimens Dynamic](https://github.com/bodenberg/appdimens-dynamic) /
> [AppDimens KMP](https://github.com/bodenberg/appdimens-kmp).

Percentage strategy: the linear Scaled law under the `psdp/phdp/pwdp` stems plus a **literal** percentage family — `30.spaceW` is exactly 30 % of the window width.

## Installation

```yaml
dependencies:
  appdimens_percent: ^3.2.0
```

> Prefer one dependency for everything? Use [`appdimens_bom`](https://pub.dev/packages/appdimens_bom).

## Usage

```dart
import 'package:appdimens_percent/appdimens_percent.dart';
final frac = 30.spaceW;     // 30% of current width
final band = 25.spaceH;     // 25% of current height
final pad  = 10.psdp;       // Scaled-law percent stem
```

## Family grammar

Every strategy shares the same API grammar — suffixes (`a` · `i` · `ia`),
orientation inverters (`Ph/Lh/Pw/Lw`), facilitators (`Rotate/Mode/Qualifier/
Screen` + Plain pairs), sp twins (`ssp`) and no-font-scale stems (`sem`):

| Stem | Axis | Sp | No font scale |
|------|------|----|----------------|
| Stem | Axis | Text (sp) | No font scale |
|---|---|---|---|
| `psdp` / `phdp` / `pwdp` | smallest width / height / width | `pssp/phsp/pwsp` | `psem/phem/pwem` |


See the complete guide: [DOCUMENTATION/percent.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/percent.md) ·
[Math](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md) ·
[API conventions](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/API-CONVENTIONS.md)

## License

Apache License 2.0 — © Jean Bodenberg.
