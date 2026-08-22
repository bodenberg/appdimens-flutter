# AppDimens Logarithmic

> Part of the **AppDimens Flutter** family — Flutter port of
> [AppDimens Dynamic](https://github.com/bodenberg/appdimens-dynamic) /
> [AppDimens KMP](https://github.com/bodenberg/appdimens-kmp).

Symmetric ±0.4·ln damping around the 300 dp baseline — the most conservative growth, ideal for density-first layouts.

## Installation

```bash
flutter pub add appdimens_logarithmic      # Flutter apps
dart pub add appdimens_logarithmic         # pure-Dart packages
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  appdimens_logarithmic: ^3.2.0
```

> 📦 Package page: [pub.dev/packages/appdimens_logarithmic](https://pub.dev/packages/appdimens_logarithmic)
>
> Prefer one dependency for everything? Use [`appdimens_bom`](https://pub.dev/packages/appdimens_bom).

## Usage

```dart
import 'package:appdimens_logarithmic/appdimens_logarithmic.dart';
final pad = 16.logsdp;
```

## Family grammar

Every strategy shares the same API grammar — suffixes (`a` · `i` · `ia`),
orientation inverters (`Ph/Lh/Pw/Lw`), facilitators (`Rotate/Mode/Qualifier/
Screen` + Plain pairs), sp twins (`ssp`) and no-font-scale stems (`sem`):

| Stem | Axis | Sp | No font scale |
|------|------|----|----------------|
| Stem | Axis | Text (sp) | No font scale |
|---|---|---|---|
| `logsdp` / `loghdp` / `logwdp` | smallest width / height / width | `logssp/loghsp/logwsp` | `logsem/loghem/logwem` |


See the complete guide: [DOCUMENTATION/logarithmic.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/logarithmic.md) ·
[Math](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md) ·
[API conventions](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/API-CONVENTIONS.md)

## License

Apache License 2.0 — © Jean Bodenberg.
