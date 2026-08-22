# AppDimens Auto

> Part of the **AppDimens Flutter** family — Flutter port of
> [AppDimens Dynamic](https://github.com/bodenberg/appdimens-dynamic) /
> [AppDimens KMP](https://github.com/bodenberg/appdimens-kmp).

Linear on phones, logarithmically damped beyond the 480 dp transition — the pragmatic hybrid recommended as the second choice after Scaled.

## Installation

```bash
flutter pub add appdimens_auto      # Flutter apps
dart pub add appdimens_auto         # pure-Dart packages
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  appdimens_auto: ^3.2.0
```

> 📦 Package page: [pub.dev/packages/appdimens_auto](https://pub.dev/packages/appdimens_auto)
>
> Prefer one dependency for everything? Use [`appdimens_bom`](https://pub.dev/packages/appdimens_bom).

## Usage

```dart
import 'package:appdimens_auto/appdimens_auto.dart';
final pad = 16.asdp;
final w   = 800.awdp;
```

## Family grammar

Every strategy shares the same API grammar — suffixes (`a` · `i` · `ia`),
orientation inverters (`Ph/Lh/Pw/Lw`), facilitators (`Rotate/Mode/Qualifier/
Screen` + Plain pairs), sp twins (`ssp`) and no-font-scale stems (`sem`):

| Stem | Axis | Sp | No font scale |
|------|------|----|----------------|
| Stem | Axis | Text (sp) | No font scale |
|---|---|---|---|
| `asdp` / `ahdp` / `awdp` | smallest width / height / width | `assp/ahsp/awsp` | `asem/ahem/awem` |


See the complete guide: [DOCUMENTATION/auto.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/auto.md) ·
[Math](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md) ·
[API conventions](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/API-CONVENTIONS.md)

## License

Apache License 2.0 — © Jean Bodenberg.
