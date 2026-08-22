# AppDimens Diagonal

> Part of the **AppDimens Flutter** family — Flutter port of
> [AppDimens Dynamic](https://github.com/bodenberg/appdimens-dynamic) /
> [AppDimens KMP](https://github.com/bodenberg/appdimens-kmp).

Scales by the window diagonal against the design baseline (√(300²+533²)) — orientation-stable and qualifier-independent.

## Installation

```bash
flutter pub add appdimens_diagonal      # Flutter apps
dart pub add appdimens_diagonal         # pure-Dart packages
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  appdimens_diagonal: ^3.2.0
```

> 📦 Package page: [pub.dev/packages/appdimens_diagonal](https://pub.dev/packages/appdimens_diagonal)
>
> Prefer one dependency for everything? Use [`appdimens_bom`](https://pub.dev/packages/appdimens_bom).

## Usage

```dart
import 'package:appdimens_diagonal/appdimens_diagonal.dart';
final size = 16.dgsdp;   // same value on every axis/rotation
```

## Family grammar

Every strategy shares the same API grammar — suffixes (`a` · `i` · `ia`),
orientation inverters (`Ph/Lh/Pw/Lw`), facilitators (`Rotate/Mode/Qualifier/
Screen` + Plain pairs), sp twins (`ssp`) and no-font-scale stems (`sem`):

| Stem | Axis | Sp | No font scale |
|------|------|----|----------------|
| Stem | Axis | Text (sp) | No font scale |
|---|---|---|---|
| `dgsdp` / `dghdp` / `dgwdp` | any (independent) | `dgssp/dghsp/dgwsp` | `dgsem/dghem/dgwem` |


See the complete guide: [DOCUMENTATION/diagonal.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/diagonal.md) ·
[Math](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md) ·
[API conventions](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/API-CONVENTIONS.md)

## License

Apache License 2.0 — © Jean Bodenberg.
