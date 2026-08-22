# AppDimens Perimeter

> Part of the **AppDimens Flutter** family — Flutter port of
> [AppDimens Dynamic](https://github.com/bodenberg/appdimens-dynamic) /
> [AppDimens KMP](https://github.com/bodenberg/appdimens-kmp).

Half-perimeter ratio `(min+max)/833` — orientation-stable growth based on both sides of the window.

## Installation

```yaml
dependencies:
  appdimens_perimeter: ^3.2.0
```

> Prefer one dependency for everything? Use [`appdimens_bom`](https://pub.dev/packages/appdimens_bom).

## Usage

```dart
import 'package:appdimens_perimeter/appdimens_perimeter.dart';
final bar = 56.prsdp;
```

## Family grammar

Every strategy shares the same API grammar — suffixes (`a` · `i` · `ia`),
orientation inverters (`Ph/Lh/Pw/Lw`), facilitators (`Rotate/Mode/Qualifier/
Screen` + Plain pairs), sp twins (`ssp`) and no-font-scale stems (`sem`):

| Stem | Axis | Sp | No font scale |
|------|------|----|----------------|
| Stem | Axis | Text (sp) | No font scale |
|---|---|---|---|
| `prsdp` / `prhdp` / `prwdp` | any (independent) | `prssp/prhsp/prwsp` | `prsem/prhem/prwem` |


See the complete guide: [DOCUMENTATION/perimeter.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/perimeter.md) ·
[Math](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md) ·
[API conventions](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/API-CONVENTIONS.md)

## License

Apache License 2.0 — © Jean Bodenberg.
