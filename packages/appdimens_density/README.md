# AppDimens Density

> Part of the **AppDimens Flutter** family — Flutter port of
> [AppDimens Dynamic](https://github.com/bodenberg/appdimens-dynamic) /
> [AppDimens KMP](https://github.com/bodenberg/appdimens-kmp).

Anchors sizes to the physical pixel density (`dpi/160`) instead of the window size — for games, AR overlays and calibration UIs.

## Installation

```bash
flutter pub add appdimens_density      # Flutter apps
dart pub add appdimens_density         # pure-Dart packages
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  appdimens_density: ^3.2.0
```

> 📦 Package page: [pub.dev/packages/appdimens_density](https://pub.dev/packages/appdimens_density)
>
> Prefer one dependency for everything? Use [`appdimens_bom`](https://pub.dev/packages/appdimens_bom).

## Usage

```dart
import 'package:appdimens_density/appdimens_density.dart';
final marker = 24.dsdp;
```

## Family grammar

Every strategy shares the same API grammar — suffixes (`a` · `i` · `ia`),
orientation inverters (`Ph/Lh/Pw/Lw`), facilitators (`Rotate/Mode/Qualifier/
Screen` + Plain pairs), sp twins (`ssp`) and no-font-scale stems (`sem`):

| Stem | Axis | Sp | No font scale |
|------|------|----|----------------|
| Stem | Axis | Text (sp) | No font scale |
|---|---|---|---|
| `dsdp` / `dhdp` / `dwdp` | density-driven | `dssp/dhsp/dwsp` | `dsem/dhem/dwem` |


See the complete guide: [DOCUMENTATION/density.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/density.md) ·
[Math](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md) ·
[API conventions](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/API-CONVENTIONS.md)

## License

Apache License 2.0 — © Jean Bodenberg.
