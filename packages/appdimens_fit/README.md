# AppDimens Fit

> Part of the **AppDimens Flutter** family — Flutter port of
> [AppDimens Dynamic](https://github.com/bodenberg/appdimens-dynamic) /
> [AppDimens KMP](https://github.com/bodenberg/appdimens-kmp).

CSS `contain` semantics: uses the smaller axis ratio so elements always fit inside their target area.

## Installation

```bash
flutter pub add appdimens_fit      # Flutter apps
dart pub add appdimens_fit         # pure-Dart packages
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  appdimens_fit: ^3.2.0
```

> 📦 Package page: [pub.dev/packages/appdimens_fit](https://pub.dev/packages/appdimens_fit)
>
> Prefer one dependency for everything? Use [`appdimens_bom`](https://pub.dev/packages/appdimens_bom).

## Usage

```dart
import 'package:appdimens_fit/appdimens_fit.dart';
final logo = 64.ftsdp;
```

## Family grammar

Every strategy shares the same API grammar — suffixes (`a` · `i` · `ia`),
orientation inverters (`Ph/Lh/Pw/Lw`), facilitators (`Rotate/Mode/Qualifier/
Screen` + Plain pairs), sp twins (`ssp`) and no-font-scale stems (`sem`):

| Stem | Axis | Sp | No font scale |
|------|------|----|----------------|
| Stem | Axis | Text (sp) | No font scale |
|---|---|---|---|
| `ftsdp` / `fthdp` / `ftwdp` | contain ratio | `ftssp/fthsp/ftwsp` | `ftsem/fthem/ftwem` |


See the complete guide: [DOCUMENTATION/fit.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/fit.md) ·
[Math](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md) ·
[API conventions](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/API-CONVENTIONS.md)

## License

Apache License 2.0 — © Jean Bodenberg.
