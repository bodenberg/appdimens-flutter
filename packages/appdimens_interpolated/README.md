# AppDimens Interpolated

> Part of the **AppDimens Flutter** family — Flutter port of
> [AppDimens Dynamic](https://github.com/bodenberg/appdimens-dynamic) /
> [AppDimens KMP](https://github.com/bodenberg/appdimens-kmp).

Fixed 50 % blend between the raw value and the fully-scaled value — exactly half of linear growth.

## Installation

```bash
flutter pub add appdimens_interpolated      # Flutter apps
dart pub add appdimens_interpolated         # pure-Dart packages
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  appdimens_interpolated: ^3.2.0
```

> 📦 Package page: [pub.dev/packages/appdimens_interpolated](https://pub.dev/packages/appdimens_interpolated)
>
> Prefer one dependency for everything? Use [`appdimens_bom`](https://pub.dev/packages/appdimens_bom).

## Usage

```dart
import 'package:appdimens_interpolated/appdimens_interpolated.dart';
final pad = 16.isdp;
```

## Family grammar

Every strategy shares the same API grammar — suffixes (`a` · `i` · `ia`),
orientation inverters (`Ph/Lh/Pw/Lw`), facilitators (`Rotate/Mode/Qualifier/
Screen` + Plain pairs), sp twins (`ssp`) and no-font-scale stems (`sem`):

| Stem | Axis | Sp | No font scale |
|------|------|----|----------------|
| Stem | Axis | Text (sp) | No font scale |
|---|---|---|---|
| `isdp` / `ihdp` / `iwdp` | smallest width / height / width | `issp/ihsp/iwsp` | `isem/ihem/iwem` |


See the complete guide: [DOCUMENTATION/interpolated.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/interpolated.md) ·
[Math](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md) ·
[API conventions](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/API-CONVENTIONS.md)

## License

Apache License 2.0 — © Jean Bodenberg.
